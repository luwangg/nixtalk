      *Authentication service in COBOL using ØMQ. Error handling is 
      *omitted for brevity.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. authenticate.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 ws-bind-address              PIC X(100).

       01 ws-zmq-rep                   PIC 9(5) VALUE 4.
       01 ws-zmq                       POINTER.
       01 ws-socket                    POINTER.

       01 ws-request.
           02 ws-username              PIC X(12).
           02 ws-password              PIC X(20).
       01 ws-response                  PIC X(10).

       PROCEDURE DIVISION.
       para-entry.
           STRING 'tcp://0.0.0.0:1234' X'00' INTO ws-bind-address

           DISPLAY "LISTENING ON " ws-bind-address

           CALL "zmq_ctx_new" GIVING ws-zmq
           CALL "zmq_socket" USING VALUE ws-zmq
                                   VALUE ws-zmq-rep
                             GIVING ws-socket
           CALL "zmq_bind" USING VALUE ws-socket
                                 REFERENCE ws-bind-address

           PERFORM para-req-rep FOREVER

           EXIT PROGRAM
           .

       para-req-rep.
           CALL "zmq_recv"
               USING VALUE ws-socket
                     REFERENCE ws-request
                     VALUE LENGTH OF ws-request
                     VALUE 0

           IF ws-username IS EQUAL TO "arian" AND
              ws-password IS EQUAL TO "@r1aN" THEN
               MOVE 'OK' TO ws-response
           ELSE
               MOVE 'ERROR' TO ws-response
           END-IF

           DISPLAY ws-request
           DISPLAY ws-response

           CALL "zmq_send"
               USING VALUE ws-socket
                     REFERENCE ws-response
                     VALUE LENGTH OF ws-response
                     VALUE 0
           .
