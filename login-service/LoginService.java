import org.zeromq.ZMQ;
import java.nio.charset.StandardCharsets;
public class LoginService {
  public static void main(String[]args) {
    ZMQ.Socket sock = ZMQ.context(1).socket(ZMQ.REQ);
    sock.connect("tcp://127.0.0.1:1234");
    byte[] msg = "arian       @r1aN".getBytes(StandardCharsets.UTF_8);
    sock.send(msg, 0, 0);
    byte[] resp = sock.recv(0);
    String s = new String(resp, StandardCharsets.UTF_8);
    System.out.println(s);
  }
}
