export PATH=$coreutils/bin:$openjdk/bin
cp $src LoginService.java
javac -cp $jzmq/share/java/zmq.jar LoginService.java
jar cfe LoginService.jar LoginService LoginService.class
mkdir $out
cp LoginService.jar $out
cat <<EOF >> $out/login-service
#!/{pkgs.bash}
$jre/bin/java -Djava.library.path="$jzmq/lib" -cp "$jzmq/share/java/zmq.jar:$out/LoginService.jar"  LoginService
EOF
chmod +x $out/login-service
