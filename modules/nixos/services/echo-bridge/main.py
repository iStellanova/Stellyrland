#!/usr/bin/env python3
import json
import uuid
import time
import asyncio
import psycopg2
import httpx
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, BackgroundTasks
from fastapi.responses import StreamingResponse, JSONResponse

OLLAMA_URL = "http://127.0.0.1:11434"
DB_DSN = "dbname=ai_memory user=stellanova host=127.0.0.1"
SESSION_TIMEOUT = 1800  # 30 minutes of inactivity to rotate session UUID

# In-memory mapping: client_id -> {"session_id": UUID, "last_activity": float}
# Note: Survives only as long as this process runs. Rebuilt on NixOS rebuilds.
SESSION_MAP = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manages the lifecycle of resources. Reuses connection pools to avoid leaks."""
    app.state.client = httpx.AsyncClient(timeout=120.0)
    yield
    await app.state.client.aclose()


app = FastAPI(title="Echo Memory Bridge", version="1.0.0", lifespan=lifespan)


def get_db_connection():
    """Establishes a connection to the PostgreSQL database."""
    return psycopg2.connect(DB_DSN)


def resolve_client_id(request: Request) -> str:
    """Hybrid Client Identifier Heuristic:
    1. Custom Header X-Echo-Client
    2. Session Cookie echo-session-id
    3. User-Agent string parsing
    4. Fallback to IP address
    """
    # 1. Header lookup
    client_id = request.headers.get("X-Echo-Client")
    if client_id:
        return f"header:{client_id}"

    # 2. Cookie lookup
    client_id = request.cookies.get("echo-session-id")
    if client_id:
        return f"cookie:{client_id}"

    # 3. User-Agent heuristics
    user_agent = request.headers.get("user-agent", "").lower()
    if "oterm" in user_agent:
        return "client:oterm"
    if "open-webui" in user_agent or "openwebui" in user_agent or "python-httpx" in user_agent:
        return "client:open-webui"

    # 4. Fallback to client host/IP
    client_ip = request.client.host if request.client else "127.0.0.1"
    return f"ip:{client_ip}"


def get_session_id(client_id: str) -> uuid.UUID:
    """Retrieves or rotates the in-memory session UUID for a client."""
    now = time.time()
    if client_id in SESSION_MAP:
        sess = SESSION_MAP[client_id]
        if now - sess["last_activity"] < SESSION_TIMEOUT:
            sess["last_activity"] = now
            return sess["session_id"]

    new_uuid = uuid.uuid4()
    SESSION_MAP[client_id] = {
        "session_id": new_uuid,
        "last_activity": now
    }
    return new_uuid


def assemble_system_prompt() -> str:
    """Assembles active rules, facts, and traits from Postgres into a system prompt.
    Runs synchronously and should be wrapped in an executor when called from async paths.
    """
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # 1. Retrieve active rules ordered by priority
        cur.execute("SELECT rule FROM rules WHERE active = TRUE ORDER BY priority DESC")
        rules = [row[0] for row in cur.fetchall()]

        # 2. Retrieve facts with confidence >= 0.7
        cur.execute("SELECT key, value FROM facts WHERE confidence >= 0.7 ORDER BY updated_at DESC")
        facts = [f"{row[0]}: {row[1]}" for row in cur.fetchall()]

        # 3. Retrieve extreme traits (> 0.7 or < 0.3)
        cur.execute("SELECT trait, score FROM traits WHERE score > 0.7 OR score < 0.3")
        traits = []
        for row in cur.fetchall():
            status = "high" if row[1] > 0.7 else "low"
            traits.append(f"Your trait '{row[0]}' is currently {status} (score: {row[1]:.2f}). Adjust your tone accordingly.")

        cur.close()
        conn.close()
    except Exception as e:
        # Prevent crash if Postgres schema isn't fully ready or migrations are running
        print(f"[Echo Bridge] Error fetching cognitive memory from DB: {e}")
        rules, facts, traits = [], [], []

    sys_prompt = "You are Echo, a highly personalized Cognitive AI.\n\n"
    if rules:
        sys_prompt += "### Dynamic Rules:\n" + "\n".join(f"- {r}" for r in rules) + "\n\n"
    if facts:
        sys_prompt += "### User Facts:\n" + "\n".join(f"- {f}" for f in facts) + "\n\n"
    if traits:
        sys_prompt += "### Behavioral Traits:\n" + "\n".join(f"- {t}" for t in traits) + "\n"

    return sys_prompt


def log_interaction_to_db(session_id: uuid.UUID, user_message: str, assistant_message: str):
    """Saves both the user message and assistant reply to the episodic log.
    Called via background_tasks which runs it safely in a background thread pool.
    """
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Log User Message
        cur.execute(
            "INSERT INTO messages (session_id, role, content, processed) VALUES (%s, %s, %s, FALSE)",
            (str(session_id), "user", user_message)
        )
        # Log Assistant Message
        cur.execute(
            "INSERT INTO messages (session_id, role, content, processed) VALUES (%s, %s, %s, FALSE)",
            (str(session_id), "assistant", assistant_message)
        )

        conn.commit()
        cur.close()
        conn.close()
        print(f"[Echo Bridge] Successfully logged message exchange for session {session_id}.")
    except Exception as e:
        print(f"[Echo Bridge] Error logging conversation to DB: {e}")


# =====================================================================
# Streaming Generators (Non-Blocking Chunks & Post-Stream Log Triggers)
# =====================================================================

async def stream_ollama_chat(r, session_id: uuid.UUID, user_msg: str, background_tasks: BackgroundTasks):
    """Streams NDJSON tokens back to the client while buffering the assistant response for async database logging."""
    assistant_buffer = []
    line_buffer = ""
    try:
        async for chunk in r.aiter_text():
            yield chunk.encode('utf-8')
            line_buffer += chunk
            while '\n' in line_buffer:
                line, line_buffer = line_buffer.split('\n', 1)
                if line.strip():
                    try:
                        data = json.loads(line)
                        if "message" in data and "content" in data["message"]:
                            assistant_buffer.append(data["message"]["content"])
                    except Exception:
                        pass
    finally:
        await r.aclose()
        full_assistant_msg = "".join(assistant_buffer)
        if user_msg and full_assistant_msg:
            background_tasks.add_task(log_interaction_to_db, session_id, user_msg, full_assistant_msg)


async def stream_openai_chat(r, session_id: uuid.UUID, user_msg: str, background_tasks: BackgroundTasks):
    """Streams SSE tokens back to the client while buffering the assistant response for async database logging."""
    assistant_buffer = []
    line_buffer = ""
    try:
        async for chunk in r.aiter_text():
            yield chunk.encode('utf-8')
            line_buffer += chunk
            while '\n' in line_buffer:
                line, line_buffer = line_buffer.split('\n', 1)
                line = line.strip()
                if line.startswith("data:"):
                    data_str = line[5:].strip()
                    if data_str == "[DONE]":
                        continue
                    try:
                        data = json.loads(data_str)
                        if "choices" in data and len(data["choices"]) > 0:
                            choice = data["choices"][0]
                            if "delta" in choice and "content" in choice["delta"]:
                                assistant_buffer.append(choice["delta"]["content"])
                    except Exception:
                        pass
    finally:
        await r.aclose()
        full_assistant_msg = "".join(assistant_buffer)
        if user_msg and full_assistant_msg:
            background_tasks.add_task(log_interaction_to_db, session_id, user_msg, full_assistant_msg)


async def stream_ollama_generate(r, session_id: uuid.UUID, user_prompt: str, background_tasks: BackgroundTasks):
    """Streams raw generation tokens back to the client while buffering the assistant response for async DB logging."""
    assistant_buffer = []
    line_buffer = ""
    try:
        async for chunk in r.aiter_text():
            yield chunk.encode('utf-8')
            line_buffer += chunk
            while '\n' in line_buffer:
                line, line_buffer = line_buffer.split('\n', 1)
                if line.strip():
                    try:
                        data = json.loads(line)
                        if "response" in data:
                            assistant_buffer.append(data["response"])
                    except Exception:
                        pass
    finally:
        await r.aclose()
        full_assistant_msg = "".join(assistant_buffer)
        if user_prompt and full_assistant_msg:
            background_tasks.add_task(log_interaction_to_db, session_id, user_prompt, full_assistant_msg)


# =====================================================================
# Intercept endpoints (Injections, Routing, Session Allocation)
# =====================================================================

def optimize_request_options(body: dict):
    """Enforces high-performance context and generation limits to prevent memory bloat."""
    options = body.get("options", {})
    if "num_ctx" not in options:
        options["num_ctx"] = 8192  # Capped at 8k context for blazing-fast local GPU execution
    body["options"] = options


@app.post("/api/chat")
async def chat_endpoint(request: Request, background_tasks: BackgroundTasks):
    body = await request.json()

    # Client-Session mapping
    client_id = resolve_client_id(request)
    session_id = get_session_id(client_id)

    # Extract user message
    messages = body.get("messages", [])
    user_msg = ""
    for msg in reversed(messages):
        if msg.get("role") == "user":
            user_msg = msg.get("content", "")
            break

    # Context Prompt Injection (Offloaded to a thread pool to unblock event loop)
    loop = asyncio.get_running_loop()
    sys_prompt = await loop.run_in_executor(None, assemble_system_prompt)

    sys_idx = -1
    for idx, msg in enumerate(messages):
        if msg.get("role") == "system":
            sys_idx = idx
            break

    if sys_idx != -1:
        messages[sys_idx]["content"] = sys_prompt + "\n\n" + messages[sys_idx]["content"]
    else:
        messages.insert(0, {"role": "system", "content": sys_prompt})

    body["messages"] = messages
    optimize_request_options(body)
    stream = body.get("stream", True)

    client = request.app.state.client
    if stream:
        req = client.build_request("POST", f"{OLLAMA_URL}/api/chat", json=body)
        r = await client.send(req, stream=True)
        return StreamingResponse(
            stream_ollama_chat(r, session_id, user_msg, background_tasks),
            media_type="application/x-ndjson"
        )
    else:
        r = await client.post(f"{OLLAMA_URL}/api/chat", json=body)
        data = r.json()
        full_assistant_msg = data.get("message", {}).get("content", "")
        if user_msg and full_assistant_msg:
            background_tasks.add_task(log_interaction_to_db, session_id, user_msg, full_assistant_msg)
        return JSONResponse(content=data, status_code=r.status_code)


@app.post("/v1/chat/completions")
async def openai_chat_endpoint(request: Request, background_tasks: BackgroundTasks):
    body = await request.json()

    client_id = resolve_client_id(request)
    session_id = get_session_id(client_id)

    messages = body.get("messages", [])
    user_msg = ""
    for msg in reversed(messages):
        if msg.get("role") == "user":
            user_msg = msg.get("content", "")
            break

    # Context Prompt Injection (Offloaded to a thread pool to unblock event loop)
    loop = asyncio.get_running_loop()
    sys_prompt = await loop.run_in_executor(None, assemble_system_prompt)

    sys_idx = -1
    for idx, msg in enumerate(messages):
        if msg.get("role") == "system":
            sys_idx = idx
            break

    if sys_idx != -1:
        messages[sys_idx]["content"] = sys_prompt + "\n\n" + messages[sys_idx]["content"]
    else:
        messages.insert(0, {"role": "system", "content": sys_prompt})

    body["messages"] = messages
    optimize_request_options(body)
    stream = body.get("stream", False)

    client = request.app.state.client
    if stream:
        req = client.build_request("POST", f"{OLLAMA_URL}/v1/chat/completions", json=body)
        r = await client.send(req, stream=True)
        return StreamingResponse(
            stream_openai_chat(r, session_id, user_msg, background_tasks),
            media_type="text/event-stream"
        )
    else:
        r = await client.post(f"{OLLAMA_URL}/v1/chat/completions", json=body)
        data = r.json()
        full_assistant_msg = ""
        if "choices" in data and len(data["choices"]) > 0:
            full_assistant_msg = data["choices"][0].get("message", {}).get("content", "")
        if user_msg and full_assistant_msg:
            background_tasks.add_task(log_interaction_to_db, session_id, user_msg, full_assistant_msg)
        return JSONResponse(content=data, status_code=r.status_code)


@app.post("/api/generate")
async def generate_endpoint(request: Request, background_tasks: BackgroundTasks):
    body = await request.json()

    client_id = resolve_client_id(request)
    session_id = get_session_id(client_id)

    user_prompt = body.get("prompt", "")

    # Context Prompt Injection (Offloaded to a thread pool to unblock event loop)
    loop = asyncio.get_running_loop()
    sys_prompt = await loop.run_in_executor(None, assemble_system_prompt)

    existing_system = body.get("system", "")
    if existing_system:
        body["system"] = sys_prompt + "\n\n" + existing_system
    else:
        body["system"] = sys_prompt

    optimize_request_options(body)
    stream = body.get("stream", True)
    client = request.app.state.client

    if stream:
        req = client.build_request("POST", f"{OLLAMA_URL}/api/generate", json=body)
        r = await client.send(req, stream=True)
        return StreamingResponse(
            stream_ollama_generate(r, session_id, user_prompt, background_tasks),
            media_type="application/x-ndjson"
        )
    else:
        r = await client.post(f"{OLLAMA_URL}/api/generate", json=body)
        data = r.json()
        full_assistant_msg = data.get("response", "")
        if user_prompt and full_assistant_msg:
            background_tasks.add_task(log_interaction_to_db, session_id, user_prompt, full_assistant_msg)
        return JSONResponse(content=data, status_code=r.status_code)


# =====================================================================
# Transparent Catch-All Proxy Router (For Ollama management/tags endpoints)
# =====================================================================

@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"])
async def catch_all_proxy(request: Request, path: str):
    url = f"{OLLAMA_URL}/{path}"

    headers = dict(request.headers)
    headers.pop("host", None)  # Prevent binding conflicts on host redirection

    params = dict(request.query_params)
    content = await request.body()

    client = request.app.state.client
    req = client.build_request(
        method=request.method,
        url=url,
        headers=headers,
        params=params,
        content=content
    )

    r = await client.send(req, stream=True)
    return StreamingResponse(
        r.aiter_raw(),
        status_code=r.status_code,
        headers=dict(r.headers)
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
