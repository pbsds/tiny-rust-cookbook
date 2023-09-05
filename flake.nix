{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

  inputs.katex.url = "https://github.com/KaTeX/KaTeX/releases/download/v0.15.1/katex.tar.gz";
  inputs.katex.flake = false;

  outputs = { nixpkgs, katex, ... } @ inputs:
  let

    forSystems = systems: f: nixpkgs.lib.genAttrs systems (system: f rec {
      inherit system;
      pkgs = nixpkgs.legacyPackages.${system};
      lib  = nixpkgs.legacyPackages.${system}.lib;
    });
    forAllSystems = forSystems [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mkInputs = pkgs: with pkgs; [
      gnumake
      pandoc
      haskellPackages.pandoc-crossref
      (texlive.combine {
        inherit (texlive)
          scheme-small
          atkinson
          fontaxes
      ;})
    ];

  in {
    inherit inputs;

    packages = forAllSystems ({ pkgs, ... }: rec {
      default = pdf;

      pdf = pkgs.runCommand "cookbook-pdf" {
        nativeBuildInputs = mkInputs pkgs;
      } ''
        cp -a ${./.}/* .
        make cookbook_rust.pdf
        mkdir $out
        cp -a cookbook_rust.pdf $out
      '';

      html = pkgs.runCommand "cookbook-html" {
        nativeBuildInputs = mkInputs pkgs;
      } ''
        cp -a ${./.}/* .
        substituteInPlace Makefile --replace \
            " --katex --standalone --self-contained" \
            " --katex=${inputs.katex}/ --standalone --self-contained"
        make cookbook_rust.html
        mkdir $out
        cp -a cookbook_rust.html $out/index.html
      '';

    });

    devShells = forAllSystems ({ pkgs, ... }: {
      default = pkgs.mkShellNoCC {
        packages = [ pkgs.entr ] ++ mkInputs pkgs;
      };
    });

  };
}
