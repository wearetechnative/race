{ stdenv
, lib
, fetchFromGitHub
, bash
, pkgs
, makeWrapper
}:
stdenv.mkDerivation rec {

  pname = "race";
  version = "0.1.0";

  src = ./.;

  buildInputs = with pkgs; [
      bash
    ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin

    cp race *.sh *.py $out/bin/

#    wrapProgram $out/bin/ --prefix PATH : ${lib.makeBinPath buildInputs }
#
#    cp ecsconnect.sh $out/bin/ecsconnect.sh
#    wrapProgram $out/bin/ecsconnect.sh --prefix PATH : ${lib.makeBinPath buildInputs }
#
#    cp ec2ls.sh $out/bin/ec2ls.sh
#    wrapProgram $out/bin/ec2ls.sh --prefix PATH : ${lib.makeBinPath buildInputs }
#
#    cp profsel.sh $out/bin/profsel.sh
#    wrapProgram $out/bin/profsel.sh --prefix PATH : ${lib.makeBinPath buildInputs }
#
#    cp profselcli.sh $out/bin/profselcli.sh
#    wrapProgram $out/bin/profselcli.sh --prefix PATH : ${lib.makeBinPath buildInputs }
#
#    cp aws_config2browserext.sh $out/bin/aws_config2browserext.sh
#    wrapProgram $out/bin/aws_config2browserext.sh --prefix PATH : ${lib.makeBinPath buildInputs }
  '';
}
