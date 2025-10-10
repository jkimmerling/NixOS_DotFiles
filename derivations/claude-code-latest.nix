{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs,
}:
stdenvNoCC.mkDerivation rec {
  pname = "claude-code";
  version = "2.0.9";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-DKad+i1krmEm6xq+aA8pSQ0pQK7ykExCkCuSQZw++Qw=";
  };

  nativeBuildInputs = [makeWrapper];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    pkgroot=$out/lib/node_modules/@anthropic-ai
    pkgdir=$pkgroot/claude-code
    mkdir -p "$pkgdir"

    # Unpack the published tarball; strip the leading package/ directory
    tar -xzf "$src" --strip-components=1 -C "$pkgdir"

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/claude \
      --add-flags "$pkgdir/cli.js" \
      --prefix NODE_PATH : "$out/lib/node_modules" \
      --prefix PATH : ${lib.makeBinPath [nodejs]}

    # Backwards compat: provide claude-code binary name as an alias.
    ln -s claude $out/bin/claude-code

    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code - AI coding assistant in your terminal";
    homepage = "https://github.com/anthropics/claude-code";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "claude-code";
  };
}
