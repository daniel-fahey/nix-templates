{
  description = "A flake with devShell for Vertex AI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        overlay = final: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              google-cloud-aiplatform = python-final.callPackage ./vertex.nix {};
            })
          ];
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };

        pythonPkgs = with pkgs.python311Packages; [
          langchain
          chromadb
          google-cloud-bigquery
          google-cloud-aiplatform
          numexpr # langchain's LLMMathChain requires the numexpr package
        ];

        commandLinePkgs = with pkgs; [
          google-cloud-sdk
        ];

      in {
        devShells.default = pkgs.mkShell {

          buildInputs = commandLinePkgs ++ pythonPkgs;

        };
      }
    );
}
