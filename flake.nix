{
  description = "passback";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        name = "passback";
        version = "0.1.0";

        pkgs = import nixpkgs { inherit system; };

        buildInputs = with pkgs; [
          odin
        ];
      in
      with pkgs;
      {
        packages.default = stdenv.mkDerivation {
          name = name;
          src = ./.;
          buildInputs = buildInputs;
          buildPhase = ''
            odin build . -o:speed -define="VERSION=${version}" --collection:lib=lib -out:${name}
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp ${name} $out/bin
          '';
        };

        devShells.default = mkShell {
          buildInputs = buildInputs;
        };
      }
    );
}
