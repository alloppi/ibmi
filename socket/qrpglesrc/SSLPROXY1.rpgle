     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('SOCKTUT/SOCKUTIL') BNDDIR('QC2LE')

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,gskssl_h
     D/copy socktut/qrpglesrc,sockutil_h
     D/copy socktut/qrpglesrc,errno_h

     D die             PR
     D   peMsg                      256A   const

     D NewListener     PR            10I 0
     D   pePort                       5U 0 value
     D   peError                    256A

     D s1              S             10I 0
     D s2              S             10I 0
     D s1c             S             10I 0
     D s2c             S             10I 0
     D port1           S             15P 5
     D port2           S             15P 5
     D len             S             10I 0
     D connfrom        S               *
     D read_set        S                   like(fdset)
     D excp_set        S                   like(fdset)
     D errmsg          S            256A
     D max             S             10I 0
     D ssl_env         S                   like(gsk_handle)
     D sslh            S                   like(gsk_handle)
     D buf             S           1024A
     D bytes           S             10I 0
     D rc              S             10I 0
     D connto          S               *
     d APP_ID          C                   const('SCK_HTTPAPI_EXAMPLES')

     c                   eval      *inlr = *on

     C     *entry        plist
     c                   parm                    port1
     c                   parm                    port2

     c                   if        %parms < 2
     c                   callp     die('This program requires two port ' +
     c                             'numbers as parameters!')
     c                   return
     c                   endif

     C*************************************************
     C* Listen on the server-side port
     C*************************************************
     c                   eval      s1 = NewListener(port1: errmsg)
     c                   if        s1 < 0
     c                   callp     die(errmsg)
     c                   return
     c                   endif


     C*************************************************
     C* Get a client on first port, then stop
     C*   listening for more connections
     C*************************************************
     c                   eval      len = %size(sockaddr_in)
     c                   eval      s1c = accept(s1: connfrom: len)
     c                   if        s1c < 0
     c                   eval      errmsg = %str(strerror(errno))
     c                   callp     close(s1)
     c                   callp     die(errmsg)
     c                   return
     c                   endif
     c                   callp     close(s1)

     C*************************************************
     C* Make a connection back to the client-side port
     C*************************************************
     c                   eval      s2c = socket(AF_INET: SOCK_STREAM: 0)

     c                   eval      len = %size(sockaddr_in)
     c                   alloc     len           connto
     c                   eval      p_sockaddr = connto

     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = INADDR_LOOPBACK
     c                   eval      sin_port = port2
     c                   eval      sin_zero = *ALLx'00'

     c                   eval      rc = connect(s2c: connto: len)
     c                   if        rc < 0
     c                   eval      errmsg = %str(strerror(errno))
     c                   callp     close(s1c)
     c                   callp     close(s2c)
     c                   callp     die(errmsg)
     c                   return
     c                   endif

     C*************************************************
     C* Do SSL-negotiation on server-side port
     C*************************************************
     C* create a secure socket handle
     c                   eval      rc = gsk_secure_soc_open(ssl_env: sslh)
     c                   if        rc <> GSK_OK
     c                   callp     close(s1c)
     c                   callp     die('gsk_secure_soc_open():' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     C* tell GSKit which socket to use SSL with
     c                   eval      rc = gsk_attribute_set_numeric_value(
     c                              sslh: GSK_FD: s1c)
     c                   if        rc <> GSK_OK
     c                   callp     close(s1c)
     c                   callp     die('gsk_attr_set_num(fd):' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     C* Start SSL handshake:
     c                   eval      rc = gsk_secure_soc_init(SSLh)
     c                   if        rc <> GSK_OK
     c                   callp     close(s1c)
     c                   callp     die('gsk_secure_soc_init(): ' +
     c                                %editc(rc:'P'))
     c                   return
     c                   endif

     C*************************************************
     C* check which descriptor is higher
     C*************************************************
     c                   eval      max = s1c
     c                   if        s2c > max
     c                   eval      max = s2c
     c                   endif

     C*************************************************
     C*  Main loop:
     C*    1) create a descriptor set containing the
     C*        "socket 1 client" descriptor and the
     C*        "socket 2 client" descriptor
     C*
     C*    2) Wait until data appears on either the
     C*        "s1c" socket or the "s2c" socket.
     C*
     C*    3) If data is found on s1c, copy it to
     C*         s2c.
     C*
     C*    4) If data is found on s2c, copy it to
     C*         s1c.
     C*
     C*    5) If any errors occur, close the sockets
     C*         and end the proxy.
     C*************************************************
     c                   dow       1 = 1

     c                   callp     FD_ZERO(read_set)
     c                   callp     FD_SET(s1c: read_set)
     c                   callp     FD_SET(s2c: read_set)
     c                   eval      excp_set = read_set

     c                   if        select(max+1: %addr(read_set): *NULL:
     c                                %addr(excp_set): *NULL) < 0
     c                   leave
     c                   endif

     c                   if        FD_ISSET(s1c: excp_set)
     c                               or FD_ISSET(s2c: excp_set)
     c                   leave
     c                   endif

     c                   if        FD_ISSET(s1c: read_set)
     c                   eval      rc = gsk_secure_soc_read(sslh: %addr(buf):
     c                                     1024: bytes)
     c                   if        rc <> GSK_OK
     c                   leave
     c                   endif
     c                   if        send(s2c: %addr(buf): bytes: 0) < bytes
     c                   leave
     c                   endif
     c                   endif

     c                   if        FD_ISSET(s2c: read_set)
     c                   eval      rc = recv(s2c: %addr(buf): 1024: 0)
     c                   if        rc < 0
     c                   leave
     c                   endif
     c                   if        gsk_secure_soc_write(sslh: %addr(buf):
     c                                rc: bytes) <> GSK_OK
     c                   leave
     c                   endif
     c                   if        bytes < rc
     c                   leave
     c                   endif
     c                   endif

     c                   enddo

     c                   callp     close(s1c)
     c                   callp     close(s2c)
     c                   return




      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Create a new TCP socket that's listening to a port
      *
      *       parms:
      *         pePort = port to listen to
      *        peError = Error message (returned)
      *
      *    returns: socket descriptor upon success, or -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P NewListener     B
     D NewListener     PI            10I 0
     D   pePort                       5U 0 value
     D   peError                    256A

     D sock            S             10I 0
     D len             S             10I 0
     D bindto          S               *
     D on              S             10I 0 inz(1)
     D linglen         S             10I 0
     D ling            S               *

     C* Make a new SSL enviornment
     c                   eval      rc = gsk_environment_open(ssl_env)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_env_open: ' + %editc(rc:'P'))
     c                   return    -1
     c                   endif

     C* tell OS/400 which application ID we use:
     c                   eval      rc = gsk_attribute_set_buffer(
     c                              ssl_env: GSK_OS400_APPLICATION_ID:
     c                              %trimr(APP_ID): 0)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_buf(app-id): ' +
     c                                %editc(rc:'P'))
     c                   return    -1
     c                   endif

     C* tell GSKit that we're a server app:
     c                   eval      rc = gsk_attribute_set_enum(ssl_env:
     c                               GSK_SESSION_TYPE:
     c                               GSK_SERVER_SESSION_WITH_CL_AUTH)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_enum(session_type): ' +
     c                                %editc(rc:'P'))
     c                   return    -1
     c                   endif

     C* This tells the GSKit to validate any certificates we receive,
     C*  but that its okay for the client to not sent a cert:
     c                   eval      rc = gsk_attribute_set_enum(ssl_env:
     c                               GSK_CLIENT_AUTH_TYPE:
     c                               GSK_OS400_CLIENT_AUTH_REQUIRED)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_attr_set_enum(auth_type): ' +
     c                                %editc(rc:'P'))
     c                   return    -1
     c                   endif

     C* Initialize the SSL environment.  After this, secure sessions
     C*   can be created!
     c                   eval      rc = gsk_environment_init(ssl_env)
     c                   if        rc <> GSK_OK
     c                   callp     die('gsk_environment_init(): ' +
     c                                %editc(rc:'P'))
     c                   return    -1
     c                   endif

     C*** Create a socket
     c                   eval      sock = socket(AF_INET:SOCK_STREAM:
     c                                           IPPROTO_IP)
     c                   if        sock < 0
     c                   eval      peError = %str(strerror(errno))
     c                   return    -1
     c                   endif

     C*** Tell socket that we want to be able to re-use the server
     C***  port without waiting for the MSL timeout:
     c                   callp     setsockopt(sock: SOL_SOCKET:
     c                                SO_REUSEADDR: %addr(on): %size(on))

     C*** create space for a linger structure
     c                   eval      linglen = %size(linger)
     c                   alloc     linglen       ling
     c                   eval      p_linger = ling

     C*** tell socket to only linger for 2 minutes, then discard:
     c                   eval      l_onoff = 1
     c                   eval      l_linger = 120
     c                   callp     setsockopt(sock: SOL_SOCKET: SO_LINGER:
     c                                ling: linglen)

     C*** free up resources used by linger structure
     c                   dealloc(E)              ling

     C*** Create a sockaddr_in structure
     c                   eval      len = %size(sockaddr_in)
     c                   alloc     len           bindto
     c                   eval      p_sockaddr = bindto

     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = INADDR_ANY
     c                   eval      sin_port = pePort
     c                   eval      sin_zero = *ALLx'00'

     C*** Bind socket to port
     c                   if        bind(sock: bindto: len) < 0
     c                   eval      peError = %str(strerror(errno))
     c                   callp     close(sock)
     c                   dealloc(E)              bindto
     c                   return    -1
     c                   endif

     C*** Listen for a connection
     c                   if        listen(sock: 1) < 0
     c                   eval      peError = %str(strerror(errno))
     c                   callp     close(sock)
     c                   dealloc(E)              bindto
     c                   return    -1
     c                   endif

     C*** Return newly set-up socket:
     c                   dealloc(E)              bindto
     c                   return    sock
     P                 E

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

      /define ERRNO_LOAD_PROCEDURE
      /copy socktut/qrpglesrc,errno_h
