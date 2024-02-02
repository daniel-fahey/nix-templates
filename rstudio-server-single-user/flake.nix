{
  description = "A flake with a custom RStudio Server instance";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        user = builtins.getEnv "USER"; # Dynamically get your username
        home = builtins.getEnv "HOME"; # and your home directory

        # Define the packages to be included in both R and RStudio Server
        rPackages = with pkgs.rPackages; [ tidyverse janitor ];

        # Wrapped R with the specified packages
        wrappedR = pkgs.rWrapper.override { packages = rPackages; };

        # Wrapped RStudio Server with the same packages
        wrappedRStudioServer = pkgs.rstudioServerWrapper.override {
          packages = rPackages;
        };

        # Define database.conf
        databaseConfig = ''
          # Directory in which the sqlite database will be written
          directory=${home}/.local/share/rstudio-server/
        '';

        # Save database.conf in the Nix store
        databaseConfigFile = pkgs.writeText "database.conf" databaseConfig;

        # Define rserver.conf
        rServerConfig = ''
          server-working-dir=${home}/.local/share/rstudio-server
          www-address=127.0.0.1
          www-port=8686
          server-user=${user}
          auth-none=1
          secure-cookie-key-file=${home}/.local/share/rstudio-server/secure-cookie-key
          auth-revocation-list-dir=${home}/.local/share/rstudio-server/revocation-list-dir
          server-data-dir=${home}/.local/share/rstudio-server/data
          database-config-file=${databaseConfigFile}
        '';

        # Save rserver.conf in the Nix store
        rServerConfigFile = pkgs.writeText "rserver.conf" rServerConfig;

        # Create a script in the Nix store for starting RStudio Server
        rstudioStartScript = pkgs.writeShellScriptBin "start-rstudio-server" ''
          #!/usr/bin/env bash
          echo "Preparing RStudio Server..."
          mkdir -p ${home}/.local/share/rstudio-server/data
          mkdir -p ${home}/.local/share/rstudio-server/revocation-list-dir

          echo "Starting RStudio Server..."
          exec ${wrappedRStudioServer}/bin/rserver --config-file ${rServerConfigFile}
        '';

      in
      {
        # Define a devShell
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.bashInteractive ];
          buildInputs = [ wrappedR wrappedRStudioServer rstudioStartScript ];
          # Add any other necessary environment settings or dependencies
        };
      }
    );
}
