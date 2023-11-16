{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
    bash-prompt-prefix = "(nix develop)";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };

      cudaPkgs = pkgs.cudaPackages_12_1;

      basicTools = with pkgs; [
        python3
        poetry
        stdenv.cc.cc.lib
      ];

      cudaTools = with cudaPkgs; [
        cuda_cudart
        cuda_cupti
        cuda_nvcc
        cuda_nvrtc
        cuda_nvtx
        cudnn
        libcublas
        libcufft
        libcurand
        libcusparse
        nccl
      ];

      devShellTools = basicTools ++ cudaTools;

    in {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = devShellTools;

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath devShellTools;

        shellHook = ''        
          if ! poetry run python -c "import torch" >/dev/null 2>&1; then
            echo "'torch' not found in the poetry environment. Running 'poetry install'..."
            poetry install
          fi
          echo "Activating poetry environment..."
          poetry run python -c 'import torch; assert torch.cuda.is_available(), "CUDA is not available"; x = torch.rand(10, device="cuda"); print(x)'
          poetry shell
        '';
      };
    };
}
