{
  description = "mcp-language-server development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        go =
          if pkgs ? go_1_24 then
            pkgs.go_1_24
          else
            pkgs.go;

        clangTools =
          if pkgs ? llvmPackages_16 then
            pkgs.llvmPackages_16.clang-tools
          else if pkgs ? llvmPackages then
            pkgs.llvmPackages.clang-tools
          else
            pkgs.clang-tools;

        toolchainMode = if pkgs ? go_1_24 then "local" else "auto";
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            go
            pkgs.gopls
            pkgs.just
            pkgs.git
            pkgs.findutils
          ];

          shellHook = ''
            export GOTOOLCHAIN="${toolchainMode}"
          '';
        };

        devShells.integration = pkgs.mkShell {
          packages = [
            go
            pkgs.gopls
            pkgs.just
            pkgs.git
            pkgs.findutils

            # For running integration tests locally
            pkgs.bear
            pkgs.gnumake
            clangTools

            pkgs.rust-analyzer

            pkgs.nodejs
            pkgs.nodePackages.pyright
            pkgs.nodePackages.typescript
            pkgs.nodePackages."typescript-language-server"
          ];

          shellHook = ''
            export GOTOOLCHAIN="${toolchainMode}"
          '';
        };
      }
    );
}
