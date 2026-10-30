{
  description = "Supabase workflow dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        git-credential-supabase-wf = pkgs.writeShellScriptBin "git-credential-supabase-wf" ''
          operation="''${1:-}"

          # Only provide credentials on lookup; never persist or erase them.
          if [ "$operation" != "get" ]; then
            exit 0
          fi

          host_match=
          protocol_match=
          while IFS= read -r line; do
            [ -z "$line" ] && break
            case "$line" in
              host=github.com) host_match=1 ;;
              protocol=https) protocol_match=1 ;;
            esac
          done

          if [ -n "$host_match" ] && [ -n "$protocol_match" ]; then
            token_file="''${HOME}/.config/secrets/gh_pat"
            if [ -r "$token_file" ]; then
              token="$(cat "$token_file")"
              if [ -n "$token" ]; then
                echo "protocol=https"
                echo "host=github.com"
                echo "username=x-access-token"
                echo "password=$token"
              fi
            fi
          fi
        '';

        supabase-cli = pkgs.stdenv.mkDerivation rec {
          pname = "supabase-cli";
          version = "2.122.0";

          src = pkgs.fetchurl {
            url = "https://github.com/supabase/cli/releases/download/v${version}/supabase_${version}_linux_amd64.tar.gz";
            sha256 = "0djikx8kh4xm0nxnxq3w2xb9fsxb1ka0k48fqrhp93dr8xl0dvar";
          };

          sourceRoot = ".";

          nativeBuildInputs = [ pkgs.patchelf pkgs.installShellFiles ];

          buildPhase = ''
            runHook preBuild
            patchelf \
              --set-interpreter "${pkgs.glibc}/lib64/ld-linux-x86-64.so.2" \
              supabase
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -Dm755 supabase $out/bin/supabase
            runHook postInstall
          '';

          # patchelf + strip corrupts this binary; skip the fixup phase.
          dontStrip = true;
          dontPatchELF = true;

          meta = with pkgs.lib; {
            description = "Supabase CLI";
            homepage = "https://github.com/supabase/cli";
            license = licenses.mit;
            mainProgram = "supabase";
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ supabase-cli git-credential-supabase-wf ];
        };
      });
}
