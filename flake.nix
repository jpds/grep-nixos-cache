{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk {};
      in rec {
        defaultPackage = naersk'.buildPackage {
          src = ./.;

          env.YRX_REGENERATE_MODULES_RS = "false";

          nativeBuildInputs = with pkgs; [ rustPlatform.bindgenHook pkg-config ];
          buildInputs = with pkgs; [ openssl ];
        };

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ rustc rustfmt cargo rustPlatform.bindgenHook pkg-config ];
          buildInputs = with pkgs; [ openssl ];
        };
      }
    );
}
