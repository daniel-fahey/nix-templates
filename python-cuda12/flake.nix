{
  description = "Flake for a Python CUDA 12 development shell";
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

      basicTools = with pkgs; [
        python3
        poetry
      ];

      gpuPackages = with pkgs.python3Packages; [
        torch
      ];

      devShellTools = basicTools ++ gpuPackages;

    in {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = devShellTools;

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath devShellTools;

        POETRY_VIRTUALENVS_IN_PROJECT = "true";
        POETRY_VIRTUALENVS_PATH = "{project-dir}/.venv";

        POETRY_VIRTUALENVS_PREFER_ACTIVE_PYTHON = "true";

      };
    };
}
