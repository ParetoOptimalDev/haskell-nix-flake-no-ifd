{
  description = "A Hello World in Haskell with a dependency and a devShell";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });
    in
    {
      overlay = (final: prev: {
        haskell-hello = final.haskellPackages.callPackage ./haskell-hello.nix {  };
      });
      packages = forAllSystems (system: {
         haskell-hello = nixpkgsFor.${system}.haskell-hello;
      });
      defaultPackage = forAllSystems (system: self.packages.${system}.haskell-hello);
      checks = self.packages;
      devShell = forAllSystems (system: let haskellPackages = nixpkgsFor.${system}.haskellPackages;
        in haskellPackages.shellFor {
          packages = p: [self.packages.${system}.haskell-hello];
          withHoogle = true;
          buildInputs = with haskellPackages; [
            haskell-language-server
            ghcid
            cabal-install
          ];
        # Change the prompt to show that you are in a devShell
        shellHook = "export PS1='\\e[1;34mdev > \\e[0m'";
        });
  };
}
