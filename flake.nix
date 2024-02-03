{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-unstable";
    };
    attic = {
      url = "github:Pythoner6/attic/watch-exec";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, attic, ... }: flake-parts.lib.mkFlake {inherit inputs;} {
    systems = ["x86_64-linux" "aarch64-linux"];
    perSystem = { pkgs, system, ... }: {
      packages.default = pkgs.dockerTools.buildLayeredImage {
        name = "nix-builder";
        contents = [
          pkgs.nix
          pkgs.bash
          pkgs.coreutils
          pkgs.cacert
          pkgs.git
          pkgs.gnugrep
          pkgs.curlFull
          pkgs.jq
          attic.packages.${system}.attic
          ./files
        ];
        config = {
          Volumes = { "/tmp" = {}; "/var/tmp" = {}; };
          Cmd = [ "/bin/bash" ];
          Env = [ "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
      devShells.push = pkgs.mkShell {
        buildInputs = [ pkgs.skopeo ];
      };
    };
  };
}
