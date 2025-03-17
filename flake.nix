{
  description = "SystemVerilog development environment with Neovim and Icarus Verilog";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            neovim
            icarus-verilog
            verilator
            gtkwave
            (pkgs.python3.withPackages (ps: with ps; [ pyverilog ]))
          ];

          shellHook = ''
            echo "SystemVerilog development environment loaded."
          '';
        };
      });
}
