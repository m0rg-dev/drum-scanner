{ pkgs ? import <nixpkgs> {} }:

let
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz") { };

  rust_toolchain = fenix.toolchainOf {
    date = "2022-10-14";
  };
in pkgs.mkShell {
  buildInputs = [
    (rust_toolchain.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])

    pkgs.libiconv
    pkgs.pkgsCross.avr.buildPackages.gcc
    pkgs.avrdude
  ];

  shellHook = ''
    # Prevent the avr-gcc wrapper from picking up host GCC flags
    # like -iframework, which is problematic on Darwin
    unset NIX_CFLAGS_COMPILE_FOR_TARGET
  '';

  AVR_CPU_FREQUENCY_HZ="16000000";
}
