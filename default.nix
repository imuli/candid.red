{ pkgs ? import <nixpkgs> {} }:

let
  generator = import ./generator { inherit pkgs; };
  website = import ./content { inherit generator; };
in rec {
  inherit generator;
  inherit website;
}
