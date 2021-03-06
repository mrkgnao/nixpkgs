{ lib
, buildPythonPackage
, pythonOlder
, isPy35
, isPy36
, fetchPypi
, hypothesis
, pytestcache
, pytestcov
, pytestflakes
, pytestpep8
, pytest
, glibcLocales
, mock ? null
, pathlib ? null
}:

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "natsort";
  version = "5.1.0";

  buildInputs = [
    hypothesis
    pytestcache
    pytestcov
    pytestflakes
    pytestpep8
    pytest
    glibcLocales
  ]
  # pathlib was made part of standard library in 3.5:
  ++ (lib.optionals (pythonOlder "3.4") [ pathlib ])
  # based on testing-requirements.txt:
  ++ (lib.optionals (pythonOlder "3.3") [ mock ]);

  src = fetchPypi {
    inherit pname version;
    sha256 = "5db0fd17c9f8ef3d54962a6e46159ce4807c630f0931169cd15ce54f2ac395b9";
  };

  # do not run checks on nix_run_setup.py
  patches = lib.singleton ./setup.patch
         ++ lib.optional (isPy35 || isPy36) ./python-3.6.3-test-failures.patch;

  # testing based on project's tox.ini
  checkPhase = ''
    pytest --doctest-modules natsort
    pytest --flakes --pep8 --cov natsort --cov-report term-missing
  '';

  meta = {
    description = "Natural sorting for python";
    homepage = https://github.com/SethMMorton/natsort;
    license = lib.licenses.mit;
  };
}
