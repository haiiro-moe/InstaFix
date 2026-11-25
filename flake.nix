# Nix flake for InstaFix.
#
# Outputs (x86_64-linux, aarch64-linux):
#   packages.default  statically linked `instafix` binary (buildGoModule)
#   apps.default      `nix run . -- -listen 127.0.0.1:3000`
#   devShells.default go, gopls, gotools for development
#
# Go version: go.mod asks for 1.23.2. buildGoModule uses nixpkgs' default `go`,
# which is newer than that, so the constraint is satisfied.
{
  description = "InstaFix - Instagram embed fixer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.buildGoModule {
          pname = "instafix";
          version = "0-unstable-${self.shortRev or self.dirtyShortRev or "dirty"}";
          src = self;

          # Recompute after changing go.mod/go.sum: set to `pkgs.lib.fakeHash`,
          # run `nix build`, and paste the hash Nix reports.
          vendorHash = "sha256-L/oR3v8/LBzxFMbD36OW7z8r35VEjzFaPEZgzhtB21s=";

          # Same as the Dockerfile: pure-Go net/user lookups and a static binary.
          # The module root is the main package, so no subPackages are needed.
          env.CGO_ENABLED = "0";
          tags = [
            "netgo"
            "osusergo"
          ];
          ldflags = [
            "-s"
            "-w"
          ];

          # The repo has no tests.
          doCheck = false;

          meta = {
            description = "Instagram embed fixer";
            license = pkgs.lib.licenses.mit;
            mainProgram = "instafix";
            platforms = systems;
          };
        };
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          meta.description = "Run the InstaFix server";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/instafix";
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gopls
            gotools
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
