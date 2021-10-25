     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE')

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,gskssl_h
     D/copy socktut/qrpglesrc,errno_h

     D Cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   length                      15P 5 const

     D die             PR
     D   peMsg                      256A   const

     D Translate       PR                  ExtPgm('QDCXLATE')
     D    peLength                    5P 0 const
     D    peBuffer                32766A   options(*varsize)
     D    peTable                    10A   const

     D RdLine          PR            10I 0
     D   peSock                      10I 0 value
     D   peLine                        *   value
     D   peLength                    10I 0 value
     D   peXLate                      1A   const options(*nopass)
     D   peLF                         1A   const options(*nopass)
     D   peCR                         1A   const options(*nopass)

     D WrLine          PR            10I 0
     D  peSock                       10I 0 value
     D  peLine                      256A   const
     D  peLength                     10I 0 value options(*nopass)
     D  peXLate                       1A   const options(*nopass)
     D  peEOL1                        1A   const options(*nopass)
     D  peEOL2                        1A   const options(*nopass)

     D len             S             10I 0
     D rc              S             10I 0
     D bindto          S               *
     D connfrom        S               *
     D port            S              5U 0
     D lsock           S             10I 0
     D csock           S             10I 0
     D line            S             80A
     D err             S             10I 0
     D clientip        S             17A
     D ssl_env         S                   like(gsk_handle)
     D sslh            S                   like(gsk_handle)
     d APP_ID          C                   const('SCK_SOCKTUT_SSLSERVER')

     c                   eval      *inlr = *on

     c                   exsr      MakeListener

     c                   dow       1 = 1
     c                   exsr      AcceptConn
     c                   exsr      TalkToClient
     c                   callp     gsk_secure_soc_close(sslh)
     c                   callp     close(csock)
     c                   enddo


     C*===============================================================
     C* This subroutine sets up a socket to listen for connections
     C*===============================================================
     CSR   MakeListener  begsr
     C*------------------------
     C* Make a new SSL enviornment
     c                   eval      rc = gsk_environment_open(ssl_env)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_env_open: ' + %editc(rc:'P'))
     c                   return
     c                   endif

     C* tell OS/400 which application ID we use:
     c                   eval      rc = gsk_attribute_set_buffer(
     c                              ssl_env: GSK_OS400_APPLICATION_ID:
     c                              %trimr(APP_ID): 0)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_buf(app-id): ' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     c/if defined(REQUIRE_CLIENT_AUTH)

     C* tell GSKit that we're a server that requires client auth:
     c                   eval      rc = gsk_attribute_set_enum(ssl_env:
     c                               GSK_SESSION_TYPE:
     c                               GSK_SERVER_SESSION_WITH_CL_AUTH)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_enum(session_type): ' +
     c                                %editc(rc:'P'))
     c                   endif

     C* This tells the GSKit to validate any certificates we receive,
     C*  and that a certificate is required:
     c                   eval      rc = gsk_attribute_set_enum(ssl_env:
     c                               GSK_CLIENT_AUTH_TYPE:
     c                               GSK_OS400_CLIENT_AUTH_REQUIRED)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_enum(auth_type): ' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     c/else

     C* tell GSKit that we're a normal server:
     c                   eval      rc = gsk_attribute_set_enum(ssl_env:
     c                               GSK_SESSION_TYPE:
     c                               GSK_SERVER_SESSION)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_enum(session_type): ' +
     c                                %editc(rc:'P'))
     c                   endif

     C* This tells the GSKit to validate any certificates we receive,
     C*  but that its okay for the client to not sent a cert:
     c                   eval      rc = gsk_attribute_set_enum(ssl_env:
     c                               GSK_CLIENT_AUTH_TYPE:
     c                               GSK_CLIENT_AUTH_FULL)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_enum(auth_type): ' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     c/endif


     C* Initialize the SSL environment.  After this, secure sessions
     C*   can be created!
     c                   eval      rc = gsk_environment_init(ssl_env)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_environment_init(): ' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     C** Normally, you'd look the port up in the service table with
     C**  the getservbyname command.   However, since this is a 'test'
     C**  protocol -- not an internet standard -- we'll just pick a
     C**  port number.   Port 4000 is often used for MUDs... should be
     C**  free...
     c                   eval      port = 4000

     C* Allocate some space for some socket addresses
     c                   eval      len = %size(sockaddr_in)
     c                   alloc     len           bindto
     c                   alloc     len           connfrom

     C* make a new socket
     c                   eval      lsock = socket(AF_INET: SOCK_STREAM:
     c                                            IPPROTO_IP)
     c                   if        lsock < 0
     c                   callp     die('socket(): ' + %str(strerror(errno)))
     c                   return
     c                   endif

     C* bind the socket to port 4000, of any IP address
     c                   eval      p_sockaddr = bindto
     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = INADDR_ANY
     c                   eval      sin_port = port
     c                   eval      sin_zero = *ALLx'00'

     c                   if        bind(lsock: bindto: len) < 0
     c                   eval      err = errno
     c                   callp     close(lsock)
     c                   callp     die('bind(): ' + %str(strerror(err)))
     c                   return
     c                   endif

     C* Indicate that we want to listen for connections
     c                   if        listen(lsock: 5) < 0
     c                   eval      err = errno
     c                   callp     close(lsock)
     c                   callp     die('listen(): ' + %str(strerror(err)))
     c                   return
     c                   endif
     C*------------------------
     CSR                 endsr


     C*===============================================================
     C* This subroutine accepts a new socket connection
     C*===============================================================
     CSR   AcceptConn    begsr
     C*------------------------
     c                   dou       len = %size(sockaddr_in)

     C* Accept the next connection.
     c                   eval      len = %size(sockaddr_in)
     c                   eval      csock = accept(lsock: connfrom: len)
     c                   if        csock < 0
     c                   eval      err = errno
     c                   callp     close(lsock)
     c                   callp     die('accept(): ' + %str(strerror(err)))
     c                   return
     c                   endif

     C* If socket length is not 16, then the client isn't sending the
     C*  same address family as we are using...  that scares me, so
     C*  we'll kick that guy off.
     c                   if        len <> %size(sockaddr_in)
     c                   callp     close(csock)
     c                   endif

     c                   enddo

     C* create a secure socket handle
     c                   eval      rc = gsk_secure_soc_open(ssl_env: sslh)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_secure_soc_open():' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     C* tell GSKit which socket to use SSL with
     c                   eval      rc = gsk_attribute_set_numeric_value(
     c                              sslh: GSK_FD: csock)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_num(fd):' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     C* Start SSL handshake:
     c                   eval      rc = gsk_secure_soc_init(SSLh)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_secure_soc_init(): ' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     c                   eval      p_sockaddr = connfrom
     c                   eval      clientip = %str(inet_ntoa(sin_addr))
     C*------------------------
     CSR                 endsr


     C*===============================================================
     C*  This does a quick little conversation with the connecting
     c*  client.   That oughta teach em.
     C*===============================================================
     CSR   TalkToClient  begsr
     C*------------------------
     c                   callp      WrLine(csock: 'Connection from ' +
     c                                   %trim(clientip))

     c                   callp      WrLine(csock: 'Please enter your name' +
     c                                   ' now!')

     c                   if         RdLine(csock: %addr(line): 80: *On) < 0
     c                   leavesr
     c                   endif

     c                   callp      WrLine(csock: 'Hello ' + %trim(line))
     c                   callp      WrLine(csock: 'Goodbye ' + %trim(line))

     c                   callp     Cmd('DLYJOB DLY(1)': 200)
     C*------------------------
     CSR                 endsr


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This ends this program abnormally, and sends back an escape.
      *   message explaining the failure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P die             B
     D die             PI
     D   peMsg                      256A   const

     D SndPgmMsg       PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                32766A   options(*varsize)

     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(256)
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D wwMsgLen        S             10I 0
     D wwTheKey        S              4A

     c                   eval      wwMsgLen = %len(%trimr(peMsg))
     c                   if        wwMsgLen<1
     c                   return
     c                   endif

     c                   callp     SndPgmMsg('CPF9897': 'QCPFMSG   *LIBL':
     c                               peMsg: wwMsgLen: '*ESCAPE':
     c                               '*PGMBDY': 1: wwTheKey: dsEC)

     c                   return
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * RdLine(): This reads one "line" of text data from a socket.
      *
      *   peSock = socket to read from
      *   peLine = a pointer to a variable to put the line of text into
      *   peLength = max possible length of data to stuff into peLine
      *   peXLate = (default: *OFF) Set to *ON to translate ASCII -> EBCDIC
      *   peLF (default: x'0A') = line feed character.
      *   peCR (default: x'0D') = carriage return character.
      *
      *  returns length of data read, or -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P RdLine          B                   Export
     D RdLine          PI            10I 0
     D   peSock                      10I 0 value
     D   peLine                        *   value
     D   peLength                    10I 0 value
     D   peXLate                      1A   const options(*nopass)
     D   peLF                         1A   const options(*nopass)
     D   peCR                         1A   const options(*nopass)

     D wwBuf           S          32766A   based(peLine)
     D wwLen           S             10I 0
     D RC              S             10I 0
     D CH              S              1A
     D wwXLate         S              1A
     D wwLF            S              1A
     D wwCR            S              1A
     D wwRec           S             10I 0

     c                   if        %parms > 3
     c                   eval      wwXLate = peXLate
     c                   else
     c                   eval      wwXLate = *OFF
     c                   endif

     c                   if        %parms > 4
     c                   eval      wwLF = peLF
     c                   else
     c                   eval      wwLF = x'0A'
     c                   endif

     c                   if        %parms > 5
     c                   eval      wwCR = peCR
     c                   else
     c                   eval      wwCR = x'0D'
     c                   endif

     c                   eval      %subst(wwBuf:1:peLength) = *blanks

     c                   dow       1 = 1

     c                   eval      rc = gsk_secure_soc_read(sslh: %addr(ch):
     c                                                      1: wwRec)
     c                   if        rc <> GSK_OK
     c                   if        wwLen > 0
     c                   leave
     c                   else
     c                   return    -1
     c                   endif
     c                   endif

     c                   if        ch = wwLF
     c                   leave
     c                   endif

     c                   if        ch <> wwCR
     c                   eval      wwLen = wwLen + 1
     c                   eval      %subst(wwBuf:wwLen:1) = ch
     c                   endif

     c                   if        wwLen = peLength
     c                   leave
     c                   endif

     c                   enddo

     c                   if        wwXLate=*ON  and wwLen>0
     c                   callp     Translate(wwLen: wwBuf: 'QTCPEBC')
     c                   endif

     c                   return    wwLen
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  WrLine() -- Write a line of text to a socket:
      *
      *      peSock = socket descriptor to write to
      *      peLine = line of text to write to
      *    peLength = length of line to write (before adding CRLF)
      *            you can pass -1 to have this routine calculate
      *            the length for you (which is the default!)
      *     peXlate = Pass '*ON' to have the routine translate
      *            this data to ASCII (which is the default) or *OFF
      *            to send it as-is.
      *      peEOL1 = First character to send at end-of-line
      *            (default is x'0D')
      *      peEOL2 = Second character to send at end-of-line
      *            (default is x'0A' if neither EOL1 or EOL2 is
      *            passed, or to not send a second char is EOL1
      *            is passed by itself)
      *
      * Returns length of data sent (including end of line chars)
      *    returns a short count if it couldnt send everything
      *    (if you're using a non-blocking socket) or -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P WrLine          B                   Export
     D WrLine          PI            10I 0
     D  peSock                       10I 0 value
     D  peLine                      256A   const
     D  peLength                     10I 0 value options(*nopass)
     D  peXLate                       1A   const options(*nopass)
     D  peEOL1                        1A   const options(*nopass)
     D  peEOL2                        1A   const options(*nopass)

     D wwLine          S            256A
     D wwLen           S             10I 0
     D wwXlate         S              1A
     D wwEOL           S              2A
     D wwEOLlen        S             10I 0
     D rc              S             10I 0
     D wwSent          S             10I 0

     C*******************************************
     C* Allow this procedure to figure out the
     C*  length automatically if not passed,
     C*  or if -1 is passed.
     C*******************************************
     c                   if        %parms > 2 and peLength <> -1
     c                   eval      wwLen = peLength
     c                   else
     c                   eval      wwLen = %len(%trim(peLine))
     c                   endif

     C*******************************************
     C* Default 'translate' to *ON.  Usually
     C*  you want to type the data to send
     C*  in EBCDIC, so this makes more sense:
     C*******************************************
     c                   if        %parms > 3
     c                   eval      wwXLate = peXLate
     c                   else
     c                   eval      wwXLate = *On
     c                   endif

     C*******************************************
     C* End-Of-Line chars:
     C*   1) If caller passed only one, set
     C*         that one with length = 1
     C*   2) If caller passed two, then use
     C*         them both with length = 2
     C*   3) If caller didn't pass either,
     C*         use both CR & LF with length = 2
     C*******************************************
     c                   eval      wwEOL = *blanks
     c                   eval      wwEOLlen = 0

     c                   if        %parms > 4
     c                   eval      %subst(wwEOL:1:1) = peEOL1
     c                   eval      wwEOLLen = 1
     c                   endif

     c                   if        %parms > 5
     c                   eval      %subst(wwEOL:2:1) = peEOL2
     c                   eval      wwEOLLen = 2
     c                   endif

     c                   if        wwEOLLen = 0
     c                   eval      wwEOL = x'0D0A'
     c                   eval      wwEOLLen = 2
     c                   endif

     C*******************************************
     C* Do translation if required:
     C*******************************************
     c                   eval      wwLine = peLine
     c                   if        wwXLate = *On and wwLen > 0
     c                   callp     Translate(wwLen: wwLine: 'QTCPASC')
     c                   endif

     C*******************************************
     C* Send the data, followed by the end-of-line:
     C* and return the length of data sent:
     C*******************************************
     c                   if        wwLen > 0
     c                   eval      rc = gsk_secure_soc_write(sslh:
     c                                    %addr(wwLine): wwLen: wwSent)
     c                   if        rc <> GSK_OK
     c                   return    rc
     c                   endif
     c                   endif

     c                   eval      rc = gsk_secure_soc_write(sslh:
     c                                    %addr(wwEOL): wwEOLLen: wwSent)
     c                   if        rc <> GSK_OK
     c                   return    rc
     c                   endif

     c                   return    (wwSent + wwLen)
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy socktut/qrpglesrc,errno_h
