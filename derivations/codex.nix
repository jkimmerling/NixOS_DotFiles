{
  lib,
  rust-bin,
  makeRustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}: let
  rustPlatform = makeRustPlatform {
    cargo = rust-bin.nightly."2025-09-01".default;
    rustc = rust-bin.nightly."2025-09-01".default;
  };
in
  rustPlatform.buildRustPackage rec {
    pname = "codex";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "openai";
      repo = "codex";
      rev = "main"; # You can pin to a specific commit later
      hash = "sha256-BspG0ZC3mLg1s6pxFjVFf9CPgcXM46jir0uAuvbiQs4=";
    };

    cargoHash = "sha256-Qp5zezXjVdOp8OylLgUZRLc0HQlgII6nOZodnOrok6U=";

    nativeBuildInputs = [pkg-config];

    buildInputs =
      [openssl]
      ++ lib.optionals stdenv.isDarwin [
        darwin.apple_sdk.frameworks.Security
        darwin.apple_sdk.frameworks.SystemConfiguration
      ];

    # The actual rust code is in the codex-rs subdirectory
    sourceRoot = "source/codex-rs";

    # Disable tests since they require git and fail in the build environment
    doCheck = false;

    meta = with lib; {
      description = "A lightweight coding agent that runs in your terminal";
      homepage = "https://github.com/openai/codex";
      license = licenses.asl20;
      maintainers = [];
    };
  }
