{
  description = "sengi";

  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          packages = {
            sengi =
              let
                pname = "sengi";
                version = "1.1.6";
                name = "${pname}-${version}";
                src = builtins.fetchurl {
                  url = "https://github.com/NicolasConstant/sengi/releases/download/${version}/Sengi-${version}-linux.AppImage";
                  sha256 = "sha256:1sdisfrkxaz8vjq0c1b9qp4139daqs1g2wjzbrqk2i9s2am9hn3q";
                  name = "${name}.AppImage";
                };
                appimageContents = pkgs.appimageTools.extractType2 {
                  inherit name src;
                };
              in
              pkgs.appimageTools.wrapType2 {
                inherit name src;

                extraInstallCommands = ''
                  mkdir -p $out/share
                  mkdir -p $out/share/${pname}
                  mkdir -p $out/share/applications

                  mv $out/bin/${name} $out/bin/${pname}

                  cp -a ${appimageContents}/{locales,resources} $out/share/${pname}
                  cp -a ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
                  cp -a ${appimageContents}/usr/share/icons $out/share

                  substituteInPlace $out/share/applications/${pname}.desktop \
                    --replace 'Exec=AppRun' 'Exec=${pname}'
                '';

                meta = with pkgs.lib; {
                  homepage = "https://nicolasconstant.github.io/sengi/";
                  description = "A Mastodon and Pleroma desktop focused client.";
                  longDescription = ''
                    Sengi is a Mastodon and Pleroma desktop focused client. It takes inspiration from the old Tweetdeck client, the new Tweetdeck webapp and Mastodon UI.

                    It is strongly focused on the following points:

                    o Heavily oriented on multi-accounts usage
                    o Desktop based interactions (right click, left click, etc)
                    o One column at a time display (leave it on the side of your screen, and keep an eye on it while doing your other stuff)
                  '';
                  license = licenses.agpl3;
                };
              };
            default = self.packages.${system}.sengi;
          };
        }
      );
}
