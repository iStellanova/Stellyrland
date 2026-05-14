import torch
import os
import argparse
from datasets import load_dataset
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
    TrainingArguments,
)
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from trl import SFTConfig, SFTTrainer

# Configuration
BASE_MODEL = "unsloth/llama-3-8b-bnb-4bit" # We use the 4bit version to keep the download small, but we will merge it.
DATASET_FILE = os.path.expanduser("~/projects/local-ai/training_data.jsonl")
OUTPUT_DIR = os.path.expanduser("~/projects/local-ai/echo-merged")

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
    tokenizer.pad_token = tokenizer.eos_token
    tokenizer.padding_side = "right"
    
    if tokenizer.chat_template is None:
        tokenizer.chat_template = "{% for message in messages %}{{'<|start_header_id|>' + message['role'] + '<|end_header_id|>\n\n' + message['content'] | trim + '<|eot_id|>'}}{% endfor %}{% if add_generation_prompt %}{{ '<|start_header_id|>assistant<|end_header_id|>\n\n' }}{% endif %}"

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
        num_train_epochs=1,
        max_steps=max_steps if max_steps else -1,
        bf16=True, 
        optim="paged_adamw_32bit",
        save_strategy="no",
        report_to="none",
    )

    # 6. SFTTrainer
    trainer = SFTTrainer(
        model=model,
        train_dataset=dataset,
        args=training_args,
        processing_class=tokenizer,
    )

    print("--- Starting Personality Forge ---")
    trainer.train()

    # 7. Step 1: Save the raw adapter (The "Soul")
    print("--- Training Complete. Saving personality adapter ---")
    temp_lora_dir = "./tmp-lora"
    model.save_pretrained(temp_lora_dir)
    
    # 8. Step 2: The "Clean Bake" (Neural Integration)
    print("--- Re-initializing neural stack for high-fidelity integration ---")
    # Clear VRAM for the 16-bit reload
    del model
    del trainer
    import gc
    gc.collect()
    torch.cuda.empty_cache()

    # Load high-fidelity base model (unquantized)
    # We use unsloth/llama-3-8b which is the 16-bit version
    print("Loading high-fidelity base model (Bfloat16)...")
    base_model_hf = "unsloth/llama-3-8b"
    model_16bit = AutoModelForCausalLM.from_pretrained(
        base_model_hf,
        torch_dtype=torch.bfloat16,
        device_map="auto",
        trust_remote_code=True
    )
    
    # Apply the trained adapter to the high-fidelity base
    print("Applying personality adapter to neural weights...")
    from peft import PeftModel
    model = PeftModel.from_pretrained(model_16bit, temp_lora_dir)
    
    # Merge physically
    print("Merging... (This ensures the personality IS the model)")
    model = model.merge_and_unload()
    
    # Save the final integrated model
    model.save_pretrained(OUTPUT_DIR)
    tokenizer.save_pretrained(OUTPUT_DIR)
    
    # Cleanup
    import shutil
    if os.path.exists(temp_lora_dir):
        shutil.rmtree(temp_lora_dir)
        
    print(f"\n[Forge] SUCCESS! Integrated Personality is now living in: {OUTPUT_DIR}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--steps", type=int, default=None, help="Maximum number of training steps (for testing)")
    args = parser.parse_args()
    
    train(max_steps=args.steps)
