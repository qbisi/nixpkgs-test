{
  description = "A basic flake to test nixpkgs";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixpkgs.url = "github:qbisi/nixpkgs/mpicheck";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                mpi = prev.mpich;
                # blas = prev.blas.override { isILP64 = true; };
                # lapack = prev.lapack.override { isILP64 = true; };
                # scotch = prev.scotch.override { isILP64 = true; };
              })
            ];
            config = { };
          };

          formatter = pkgs.nixfmt-rfc-style;

          packages = {
            inherit (pkgs) mumps mumps_par petsc;
          };
        };
    };
}
