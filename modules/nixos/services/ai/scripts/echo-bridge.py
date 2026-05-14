#!/usr/bin/env python3
import sys
import json
import requests
import threading
import os
import subprocess
from database_manager import DatabaseManager

OLLAMA_API_URL = "http://localhost:11434/api/chat"

class EchoBridge:
    def __init__(self):
        self.base_model = "llama3"
        self.adapter_path = "/home/stellanova/projects/local-ai/echo-lora-adapter"
        self.personalized_model = "echo-personalized"
        self.model = self.base_model
        self.db = DatabaseManager()
        
        # Phase 4: Auto-Activation logic
        self.check_and_activate_lora()

    def check_and_activate_lora(self):
        """Detects the personality adapter and registers it with Ollama."""
        if os.path.exists(self.adapter_path):
            print("\n[Forge] Personality adapter detected. Synchronizing with neural stack...")
            
            # Shared forge directory (System-wide)
            forge_dir = "/var/lib/echo-forge"
            shared_adapter_path = os.path.join(forge_dir, "echo-lora-adapter")
            modelfile_path = os.path.join(forge_dir, "Modelfile")

            try:
                # 1. Sync all adapter files directly into the forge directory root
                # This ensures adapter_config.json and adapter_model.safetensors are right next to the Modelfile
                subprocess.run(["rsync", "-a", "--delete", self.adapter_path + "/", forge_dir + "/"], check=True)
                
                # 2. Create the Modelfile (Brute Force Simple)
                modelfile_content = f"""FROM llama3:8b
ADAPTER .
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1
PARAMETER stop "<|eot_id|>"
PARAMETER stop "<|start_header_id|>"
"""
                with open(modelfile_path, "w") as f:
                    f.write(modelfile_content)

                # 3. Legacy compatibility: ensure Ollama sees the weights regardless of extension
                # Some older Ollama versions on NixOS only look for .bin
                subprocess.run(["ln", "-sf", "adapter_model.safetensors", os.path.join(forge_dir, "adapter_model.bin")], check=True)
                
                # 4. Register/Update the personalized model with Ollama (Relative path to -f)
                result = subprocess.run(
                    ["ollama", "create", self.personalized_model, "-f", "Modelfile"],
                    cwd=forge_dir,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    self.model = self.personalized_model
                    print(f"[Forge] Success: Integrated Personality Forge is ACTIVE.")
                else:
                    print(f"[Forge] Error creating model: {result.stderr}")
                    self.model = self.base_model
            except Exception as e:
                print(f"[Forge] Activation failed: {e}")
                self.model = self.base_model
        else:
            print(f"\n[Status] No adapter found at {self.adapter_path}. Using base model: {self.model}")

    def construct_system_prompt(self):
        facts = self.db.get_all_facts()
        fact_dict = {k.lower(): v for k, v in facts}
        # Flexible name lookup for assistant
        name = fact_dict.get('assistant_name') or fact_dict.get('name') or 'your chosen name'
        
        user_facts = "\n".join([f"- {k}: {v}" for k, v in facts if k.lower() not in ['assistant_name', 'name']]) 
        
        return f"""You are an autonomous local companion. You are helpful, concise, and proactive.
You have a persistent memory. If you have not chosen a name for yourself, you should do so now and introduce yourself.
Your current identity is: {name}.

Known Details about the User:
{user_facts if user_facts else "No details known yet."}

Curiosity Directive:
Build a comprehensive understanding of the user. If they mention a project or preference you don't recognize, ask a natural follow-up question.
"""

    def get_messages(self, user_input):
        """Construct the full message list for the Chat API."""
        messages = [{"role": "system", "content": self.construct_system_prompt()}]
        
        # Add historical context
        logs = self.db.get_recent_logs(limit=10)
        # Sort logs correctly (they come in DESC usually)
        logs.reverse() 
        
        for role, content in logs:
            messages.append({"role": role, "content": content})
            
        # Add current input
        messages.append({"role": "user", "content": user_input})
        return messages

    def post_process_conversation(self, user_input, assistant_response):
        """Background task to extract facts and identity from the conversation."""
        extraction_prompt = f"""Analyze the following exchange between a User and an Assistant.
1. Identify any new personal details, preferences, or goals mentioned by the USER.
2. Identify if the ASSISTANT introduced itself with a name or chose a new name for itself.

Output ONLY a JSON object. 
- Use keys like 'Assistant_Name' for the assistant's identity.
- Use other clear keys for User details.
If no new info, output {{}}.

Conversation:
User: {user_input}
Assistant: {assistant_response}
"""
        payload = {
            "model": self.base_model, # Use base model for extraction tasks to save complexity
            "messages": [
                {"role": "system", "content": "You are a helpful assistant that extracts JSON facts."},
                {"role": "user", "content": extraction_prompt}
            ],
            "stream": False,
            "format": "json"
        }

        try:
            response = requests.post(OLLAMA_API_URL, json=payload)
            response.raise_for_status()
            result = response.json()
            raw_text = result.get("response", "{}").strip()
            
            start = raw_text.find("{")
            end = raw_text.rfind("}") + 1
            if start != -1 and end != 0:
                facts = json.loads(raw_text[start:end])
                for k, v in facts.items():
                    print(f"\n[Learning] {k}: {v}")
                    self.db.save_fact(k, v)
        except Exception:
            pass

    def chat(self, user_input):
        messages = self.get_messages(user_input)
        # We don't save the log here yet, we save it after we get the response to maintain order in DB
        
        payload = {
            "model": self.model,
            "messages": messages,
            "stream": True,
            "options": {
                "temperature": 0.7,
                "top_p": 0.9,
                "repeat_penalty": 1.1,
                "stop": ["<|eot_id|>", "<|start_header_id|>", "User:", "Assistant:"]
            }
        }

        try:
            response = requests.post(OLLAMA_API_URL, json=payload, stream=True)
            response.raise_for_status()

            print(f"\nAssistant: ", end="", flush=True)
            full_response = ""
            for line in response.iter_lines():
                if line:
                    chunk = json.loads(line)
                    if "message" in chunk:
                        text = chunk["message"].get("content", "")
                        print(text, end="", flush=True)
                        full_response += text
                    if chunk.get("done"):
                        break
            print("\n")
            
            # Save to DB after successful interaction
            self.db.save_log("user", user_input)
            self.db.save_log("assistant", full_response)
            
            threading.Thread(
                target=self.post_process_conversation, 
                args=(user_input, full_response), 
                daemon=True
            ).start()
            
            return full_response
        except requests.exceptions.ConnectionError:
            print("\nError: Could not connect to Ollama. Is the service running?")
            return None
        except Exception as e:
            print(f"\nError: {e}")
            return None

def main():
    bridge = EchoBridge()
    print(f"--- Echo Bridge Terminal Interface (Active Model: {bridge.model}) ---")
    print("Type 'exit' or 'quit' to stop.")
    
    while True:
        try:
            user_input = input("\nYou: ")
            if user_input.lower() in ['exit', 'quit']:
                break
            
            if not user_input.strip():
                continue

            bridge.chat(user_input)
        except KeyboardInterrupt:
            print("\nExiting...")
            break

if __name__ == "__main__":
    main()
