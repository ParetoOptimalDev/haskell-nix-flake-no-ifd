{
  description = "A Hello World in Haskell with a dependency and a devShell";
  inputs = {
    nixpkgs.url = "nixpkgs";
    amazonka = {
      url = https://github.com/brendanhay/amazonka/archive/006563901b94ee586453855ebd73ad69442f9235.tar.gz;
      flake = false;
    };
  };
  outputs = { self, nixpkgs, amazonka }:
    let
      ghcVersion = "ghc925";
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });
    in
      {
        overlay = (final: prev: {
          
          haskell-hello = let prevHpkgs = prev.pkgs.haskell.packages.${ghcVersion};
                              finalHpkgs = prev.pkgs.haskell.packages.${ghcVersion}.override {
                                overrides = hself: hsuper: {
                                  persistent-mongoDB = hdontCheck (hmarkUnbroken (prevHpkgs.persistent-mongoDB));
                                  amazonka-sso = hdontCheck (hself.callCabal2nix "amazonka-sso" "${self.inputs.amazonka}/lib/services/amazonka-sso" {  });
                                  amazonka-core = hdontCheck (hself.callCabal2nix "amazonka-core" "${self.inputs.amazonka}/lib/amazonka-core" {});
                                  amazonka = hdontCheck (hself.callCabal2nix "amazonka" "${self.inputs.amazonka}/lib/amazonka" { });
                                  amazonka-sts = hdontCheck (hself.callCabal2nix "amazonka-sts" "${self.inputs.amazonka}/lib/services/amazonka-sts" {  });
                                  amazonka-cloudwatch = hdontCheck (hself.callCabal2nix "amazonka-cloudwatch" "${self.inputs.amazonka}/lib/services/amazonka-cloudwatch" {  });
                                };
                              };
                              hmarkUnbroken = prev.pkgs.haskell.lib.markUnbroken;
                              hdontCheck = prev.pkgs.haskell.lib.dontCheck;
                          in
                            finalHpkgs.callPackage ./haskell-hello.nix {};
        });
        packages = forAllSystems (system: {
          haskell-hello = nixpkgsFor.${system}.haskell-hello;
        });
        defaultPackage = forAllSystems (system: self.packages.${system}.haskell-hello);
        checks = self.packages;
        devShell = forAllSystems (system: let haskellPackages = nixpkgsFor.${system}.pkgs.haskell.packages.${ghcVersion};
                                          in haskellPackages.shellFor {
                                            doCheck = false;
                                            packages = p: [self.packages.${system}.haskell-hello];
                                            withHoogle = false;
                                            buildInputs = with haskellPackages; [
                                              cabal-install
                                            ];
                                            # Change the prompt to show that you are in a devShell
                                            shellHook = "export PS1='\\e[1;34mdev > \\e[0m'";
                                          });
      };
}
