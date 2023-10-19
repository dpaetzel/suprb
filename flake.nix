{
  description = "suprb";

  inputs = {
    nixpkgs.url = "github:dpaetzel/nixpkgs/dpaetzel/nixos-config";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python310;

        pkg = python.pkgs.buildPythonPackage rec {
          pname = "suprb";
          version = "dev";

          src = self;

          format = "pyproject";

          # Tests take a long time. Let's ignore them for now. (Uncomment to
          # enable tests.)
          # nativeBuildInputs = [ python.pkgs.pytestCheckHook ];

          # tqdm is required for some of the tests, it seems.
          buildInputs = with python.pkgs; [ setuptools tqdm ];

          propagatedBuildInputs = with python.pkgs; [
            numpy
            scikit-learn
            scipy
            setuptools
          ];

          pythonImportsCheck = [
            "suprb"
          ];

          meta = with pkgs.lib; {
            description = "Rule-set learning algorithm using metaheuristics";
            license = licenses.gpl3;
          };
        };
      in {
        packages.default = pkg;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs;
            # These are the requirements to be able to run
            # `examples/higdon_gramacy_lee.py`.
            [ (python.withPackages (ps: [ ps.matplotlib ps.mlflow pkg ])) ];
        };
      });
}
