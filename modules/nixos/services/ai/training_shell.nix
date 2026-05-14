{ pkgs ? import <nixpkgs> { 
    config.allowUnfree = true; 
    config.rocmSupport = true;
  } 
}:

let
  python = pkgs.python313;
  pythonEnv = python.withPackages (ps: with ps; [
    torch
    bitsandbytes
    transformers
    accelerate
    peft
    datasets
    trl
    psycopg2
    rich
  ]);

in
pkgs.mkShell {
  name = "echo-training-env-native";
  
  buildInputs = [
    pythonEnv
    pkgs.git
    pkgs.git-lfs
    pkgs.hwdata
    pkgs.rocmPackages.clr
  ];

  shellHook = ''
    # ROCm Environment Variables for RX 7900 XTX (Navi 31)
    export HSA_OVERRIDE_GFX_VERSION=11.0.0
    export PYTORCH_ROCM_ARCH=gfx1100
    export HIP_VISIBLE_DEVICES="0"
    
    # BitsAndBytes ROCm configuration
    export BNB_CUDA_VERSION=0
    export BNB_ROCM_VERSION=61
    
    # Pathing for ROCm libraries
    export LD_LIBRARY_PATH="${pkgs.rocmPackages.clr}/lib:${pkgs.rocmPackages.hipblas}/lib:${pkgs.rocmPackages.rocblas}/lib:$LD_LIBRARY_PATH"
    
    echo "--- Echo Training Environment (NATIVE ROCm MODE) ---"
    echo "GPU: AMD Radeon RX 7900 XTX (GFX1100)"
    echo "Stack: Python 3.13 | Torch (ROCm) | BitsAndBytes (ROCm)"
    
    echo -n "Checking Stack: "
    python -c 'import torch; import bitsandbytes; print(f"Torch {torch.__version__} | BNB {bitsandbytes.__version__} | GPU: {torch.cuda.get_device_name(0)}")' 2>/dev/null || echo "FAIL (Check logs)"
  '';
}
