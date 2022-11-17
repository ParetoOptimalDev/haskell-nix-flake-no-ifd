{ mkDerivation, aeson, base, cassava, conduit, containers
, cryptonite, esqueleto, exceptions, JuicyPixels, lens, lib
, mongoDB, persistent, persistent-postgresql, postgresql-simple
, QuickCheck, servant, servant-server, servant-swagger
, servant-swagger-ui, stm, text, time, uuid
}:
mkDerivation {
  pname = "try-haskell-hello-template";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base cassava conduit containers cryptonite esqueleto
    exceptions JuicyPixels lens mongoDB persistent
    persistent-postgresql postgresql-simple QuickCheck servant
    servant-server servant-swagger servant-swagger-ui stm text time
    uuid
  ];
  license = lib.licenses.bsd2;
  mainProgram = "try-haskell-hello-template";
}
