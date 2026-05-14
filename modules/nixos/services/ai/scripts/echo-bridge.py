#!/usr/bin/env python3
import sys
import json
import requests
import threading
import os
import subprocess
from database_manager import DatabaseManager

OLLAMA_API_URL = "http://localhost:11434/api/generate"

class EchoBridge:
    def __init__(self):
        self.base_model = "llama3"
        self.personalized_model = "echo-personalized"
        self.model = self.base_model
        self.db = DatabaseManager()
        
        # Phase 4: Auto-Activation logic
        self.check_and_activate_lora()

    def check_and_activate_lora(self):
        """Detects a merged personality and registers it with Ollama."""
        project_dir = os.path.expanduser("~/projects/local-ai")
        merged_model_src = os.path.join(project_dir, "echo-merged")
        
        # Shared forge directory for Ollama access
        forge_dir = "/var/lib/echo-forge"
        merged_model_dest = os.path.join(forge_dir, "echo-merged")
        modelfile_path = os.path.join(forge_dir, "Modelfile")

        if os.path.exists(merged_model_src):
            print("\n[Forge] Integrated Personality detected. Synchronizing with neural stack...")
            
            try:
                # Sync the merged model to the shared forge directory
                # We use rsync if available, otherwise a simple cp
                subprocess.run(["rsync", "-a", "--delete", merged_model_src + "/", merged_model_dest + "/"], check=True)
                
                # Create the Modelfile pointing to the merged directory
                # This ensures the weights ARE the model and the format is SANE
                modelfile_content = f"""FROM {merged_model_dest}
TEMPLATE \"\"\"{{{{ if .System }}}}<|start_header_id|>system<|end_header_id|>

{{{{ .System }}}}<|eot_id|>{{{{ end }}}}{{{{ if .Prompt }}}}<|start_header_id|>user<|end_header_id|>

{{{{ .Prompt }}}}<|eot_id|>{{{{ end }}}}<|start_header_id|>assistant<|end_header_id|>

{{{{ .Response }}}}<|eot_id|>\"\"\"
PARAMETER stop <|start_header_id|>
PARAMETER stop <|end_header_id|>
PARAMETER stop <|eot_id|>
PARAMETER stop <|reserved_special_token_
"""
                with open(modelfile_path, "w") as f:
                    f.write(modelfile_content)
                
                # Register/Update the personalized model with Ollama
                result = subprocess.run(
                    ["ollama", "create", self.personalized_model, "-f", modelfile_path],
                    cwd=forge_dir,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    self.model = self.personalized_model
                    print(f"[Forge] Success: Integrated Personality Forge is ACTIVE.")
                else:
                    self.model = self.base_model
            except Exception:
                self.model = self.base_model
        else:
            # Check for legacy adapter if merged doesn't exist
            adapter_path = os.path.join(project_dir, "echo-lora-adapter")
            if os.path.exists(adapter_path):
                 print("\n[Forge] Legacy adapter found. Please rerun training to merge weights.")
            
            print(f"\n[Status] Using base model: {self.model}")

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

    def get_context(self):
        logs = self.db.get_recent_logs(limit=10)
        context = ""
        for role, content in logs:
            context += f"{role.capitalize()}: {content}\n"
        return context

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
            "prompt": extraction_prompt,
            "stream": False
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
        self.db.save_log("user", user_input)

        system_prompt = self.construct_system_prompt()
        context = self.get_context()
        full_prompt = f"{system_prompt}\n\nRecent History:\n{context}\nUser: {user_input}\nAssistant:"

        payload = {
            "model": self.model,
            "prompt": full_prompt,
            "stream": True
        }

        try:
            response = requests.post(OLLAMA_API_URL, json=payload, stream=True)
            response.raise_for_status()

            print(f"\nAssistant: ", end="", flush=True)
            full_response = ""
            for line in response.iter_lines():
                if line:
                    chunk = json.loads(line)
                    text = chunk.get("response", "")
                    print(text, end="", flush=True)
                    full_response += text
                    if chunk.get("done"):
                        break
            print("\n")
            
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
