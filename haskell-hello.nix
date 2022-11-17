{ mkDerivation, amazonka, base, lens, lib }:
mkDerivation {
  pname = "try-haskell-hello-template";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ amazonka base lens ];
  license = lib.licenses.bsd2;
  mainProgram = "try-haskell-hello-template";
}
