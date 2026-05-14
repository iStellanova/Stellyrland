import torch
import os
import argparse
from datasets import load_dataset
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
    TrainingArguments,
    DataCollatorForLanguageModeling,
)
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from trl import SFTConfig, SFTTrainer
import numpy as np

class DataCollatorForCompletionOnlyLM(DataCollatorForLanguageModeling):
    """
    Manual implementation of Completion-Only Collator to bypass environment import issues.
    Masks all tokens before the response template.
    """
    def __init__(self, response_template, tokenizer, *args, **kwargs):
        super().__init__(tokenizer, *args, mlm=False, **kwargs)
        self.response_template = response_template
        self.tokenizer = tokenizer

    def torch_call(self, examples):
        batch = super().torch_call(examples)
        for i in range(len(examples)):
            response_token_ids = self.tokenizer.encode(self.response_template, add_special_tokens=False)
            
            # Find the response in the input_ids
            input_ids = batch["input_ids"][i].tolist()
            
            # Simple search for the response template tokens
            for j in range(len(input_ids) - len(response_token_ids) + 1):
                if input_ids[j:j+len(response_token_ids)] == response_token_ids:
                    # Found it! Mask everything before (and including) the end of the template
                    # We use -100 as the ignore index for PyTorch CrossEntropyLoss
                    batch["labels"][i, :j+len(response_token_ids)] = -100
                    break
        return batch

# Configuration
BASE_MODEL = "unsloth/llama-3-8b-instruct-bnb-4bit" 
DATASET_FILE = os.path.expanduser("~/projects/local-ai/training_data.jsonl")
OUTPUT_DIR = os.path.expanduser("~/projects/local-ai/echo-lora-adapter")

def train(max_steps=None):
    if not os.path.exists(DATASET_FILE):
        print(f"Error: Dataset {DATASET_FILE} not found. Run export_training_data.py first.")
        return

    print(f"--- Initializing Personality Forge (GPU: {torch.cuda.get_device_name(0)}) ---")

    # 1. Load Dataset
    dataset = load_dataset("json", data_files=DATASET_FILE, split="train")

    # 2. Quantization Config
    # We train in 4-bit to save VRAM, but we will merge into a 16-bit copy for the final export
    bnb_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=torch.bfloat16, 
        bnb_4bit_use_double_quant=True,
    )

    # 3. Load Model & Tokenizer
    print(f"Loading base model: {BASE_MODEL}")
    model = AutoModelForCausalLM.from_pretrained(
        BASE_MODEL,
        quantization_config=bnb_config,
        device_map="auto",
        trust_remote_code=True,
    )
    
    model.gradient_checkpointing_enable()
    model = prepare_model_for_kbit_training(model)

    tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)
    # Llama 3 special tokens
    if tokenizer.pad_token is None:
        tokenizer.pad_token = "<|reserved_special_token_250|>"
    tokenizer.padding_side = "right"

    # 4. LoRA Config
    lora_config = LoraConfig(
        r=16,
        lora_alpha=32,
        target_modules=["q_proj", "v_proj", "k_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
        lora_dropout=0.05,
        bias="none",
        task_type="CAUSAL_LM",
    )
    model = get_peft_model(model, lora_config)

    # 5. Training Arguments
    training_args = SFTConfig(
        output_dir="./tmp-lora",
        dataset_text_field="messages",
        max_length=2048,
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        learning_rate=1e-4,
        logging_steps=1,
        num_train_epochs=3,
        max_steps=max_steps if max_steps else -1,
        bf16=True, 
        optim="paged_adamw_32bit",
        save_strategy="no",
        report_to="none",
    )

    # 6. SFTTrainer with Completion-Only Masking
    response_template = "<|start_header_id|>assistant<|end_header_id|>\n\n"
    collator = DataCollatorForCompletionOnlyLM(response_template, tokenizer=tokenizer)

    trainer = SFTTrainer(
        model=model,
        train_dataset=dataset,
        data_collator=collator,
        args=training_args,
        processing_class=tokenizer,
    )

    print("--- Starting Personality Forge ---")
    trainer.train()

    # 7. Save Personality Adapter
    print(f"--- Training Complete. Saving personality adapter to {OUTPUT_DIR} ---")
    model.save_pretrained(OUTPUT_DIR)
    tokenizer.save_pretrained(OUTPUT_DIR)
    print(f"[Forge] SUCCESS! Personality adapter is ready.")
    
    # Cleanup
    import shutil
    if os.path.exists("./tmp-lora"):
        shutil.rmtree("./tmp-lora")
        
    print(f"\n[Forge] SUCCESS! Integrated Personality is now living in: {OUTPUT_DIR}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--steps", type=int, default=None, help="Maximum number of training steps (for testing)")
    args = parser.parse_args()
    
    train(max_steps=args.steps)
