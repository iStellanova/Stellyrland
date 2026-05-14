#!/usr/bin/env python3
import json
import os
from database_manager import DatabaseManager

# We use the full path to ensure the systemd timer can find it
OUTPUT_DIR = os.path.expanduser("~/projects/local-ai")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "training_data.jsonl")

def export_to_chatml():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    db = DatabaseManager()
    # We pull the last 2000 entries to get a good dataset for a burst
    logs = db.get_recent_logs(limit=2000) 
    facts = db.get_all_facts()
    
    # System prompt grounded in identity facts
    fact_str = "\n".join([f"- {k}: {v}" for k, v in facts])
    system_prompt = f"You are Echo, a local autonomous companion. You are helpful, concise, and proactive.\n\nKnown Facts:\n{fact_str}"
    
    dataset = []
    
    # Identify pairs of (user, assistant)
    for i in range(len(logs) - 1):
        role_a, content_a = logs[i]
        role_b, content_b = logs[i+1]
        
        if role_a == 'user' and role_b == 'assistant':
            entry = {
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": content_a},
                    {"role": "assistant", "content": content_b}
                ]
            }
            dataset.append(entry)
            
    with open(OUTPUT_FILE, 'w') as f:
        for entry in dataset:
            f.write(json.dumps(entry) + '\n')
            
    print(f"Exported {len(dataset)} training pairs to {OUTPUT_FILE}")
    db.close()

if __name__ == "__main__":
    export_to_chatml()
