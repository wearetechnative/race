{
  description = "Terraform Utils for TF Standard Base" ;

  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      nixosModules.default = import ./module.nix self;

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          race = pkgs.callPackage ./package.nix {};
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.race);

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              shellspec
            ];

            shellHook = ''
              echo "RACE development shell"
              echo "Run 'shellspec' to execute tests"
            '';
          };
        });
    };
}
