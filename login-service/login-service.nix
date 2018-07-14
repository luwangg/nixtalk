{ jzmq, openjdk , stdenv}:
stdenv.mkDerivation {
  name = "ing-login-service";
  src = ./.;
  buildPhase = ''
  javac LoginService.java
  jar cfe LoginService.jar LoginService LoginService.class
  '';
  installPhase = ''
  mkdir "$out"
  install LoginService.jar "$out"
  
  cat <<EOF >> run.sh
    java -Djava.library.path="${jzmq}/lib" -cp "${jzmq}/share/java/zmq.jar:$out/LoginService.jar" LoginService
  EOF

  install run.sh "$out"
  '';
  buildInputs = [ jzmq openjdk ];
}


