let
  pkgs = import <nixpkgs> {};
  azuremlpkgs = import ./.;
  python = pkgs.python39;
  pythonPackages = python.pkgs;
in

with pkgs;

mkShell {
  name = "pip-env";
  buildInputs = with pythonPackages; [
    # Python requirements (enough to get a virtualenv going).
    pandas
    matplotlib
    scikit-learn
    numpy
    pyspark
    ipykernel
    jupyterlab
    pytest
    setuptools
    wheel
    venvShellHook

    libffi
    openssl
    gcc

    spark
    unzip
  ];
  venvDir = "venv37";
  src = null;
  postVenv = ''
    unset SOURCE_DATE_EPOCH
    ./scripts/install_local_packages.sh
  '';
  postShellHook = ''
    # Allow the use of wheels.
    unset SOURCE_DATE_EPOCH
    PYTHONPATH=$PWD/$venvDir/${python.sitePackages}:$PYTHONPATH
  '';
}