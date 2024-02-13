{
  description = "Flake for a Python CUDA 12 development shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  # inputs.nixpkgs-torch.url = "github:daniel-fahey/nixpkgs/torch";

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

      # pkgs-torch = import nixpkgs-torch {
      #   inherit system;
      #   config = {
      #     allowUnfree = true;
      #     cudaSupport = true;
      #   };
      # };

      # torchOverlay = final: prev: {
      #   pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      #     (python-final: python-prev: {
      #       torch = python-final.callPackage pkgs-torch.python311Packages.torch {};
      #     })
      #   ];
      # };

      pkgs = import nixpkgs {
        inherit system;
        # overlays = [ torchOverlay ];
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };

      # optimizedPython = pkgs.python311.override {
      #   enableOptimizations = true;
      #   reproducibleBuild = false;
      # };

      basicPkgs = with pkgs; [
        # optimizedPython
        python311
        poetry
        libGL
        glib
        stdenv.cc.cc.lib
        bashInteractive
        zlib # needed by numpy
        # ncurses5
        # binutils
        # # linuxPackages.nvidia_x11
        # xorg.libXi
        # xorg.libXmu
        # freeglut
        # xorg.libXext
        # xorg.libX11
        # xorg.libXv
        # xorg.libXrandr
        # libGLU
        # gcc12 # for nvcc
      ];

      cudaPkgs = with pkgs.cudaPackages_12_1; [
        # cudatoolkit
        # cuda_cudart
        # cuda_cupti
        # cuda_nvcc
        # cuda_nvrtc
        # cuda_nvtx
        # cudnn
        # libcublas
        # libcufft
        # libcurand
        # libcusparse
        # nccl
      ];

      pythonPkgs = with pkgs.python311Packages; [
        torch
        torchvision
        safetensors
        psutil
        einops
        transformers
        scipy
        numpy
        accelerate
        piexif
        xformers
      ];

      devShellPkgs = basicPkgs ++ cudaPkgs ++ pythonPkgs;

    in {
      
      devShell.${system} = pkgs.mkShell {
        
        hardeningDisable = ["all"];

        buildInputs = devShellPkgs;

        PATH = pkgs.lib.makeBinPath devShellPkgs;

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath devShellPkgs;

        # POETRY_VIRTUALENVS_IN_PROJECT = true;
        # POETRY_VIRTUALENVS_OPTIONS_NO_PIP = true;
        # POETRY_VIRTUALENVS_PATH = "{project-dir}/.venv";
        # POETRY_VIRTUALENVS_OPTIONS_SYSTEM_SITE_PACKAGES = true;

        # POETRY_VIRTUALENVS_PREFER_ACTIVE_PYTHON = true;

      };
    };
}
