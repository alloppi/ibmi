     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('SOCKTUT/SOCKUTIL') BNDDIR('QC2LE')

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,errno_h
     D/copy socktut/qrpglesrc,sockutil_h

     D Cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   length                      15P 5 const

     D die             PR
     D   peMsg                      256A   const

     D len             S             10I 0
     D bindto          S               *
     D connfrom        S               *
     D port            S              5U 0
     D lsock           S             10I 0
     D csock           S             10I 0
     D line            S             80A
     D err             S             10I 0
     D clientip        S             17A

     c                   eval      *inlr = *on

     c                   exsr      MakeListener

     c                   dow       1 = 1
     c                   exsr      AcceptConn
     c                   exsr      TalkToClient
     c                   callp     close(csock)
     c                   enddo


     C*===============================================================
     C* This subroutine sets up a socket to listen for connections
     C*===============================================================
     CSR   MakeListener  begsr
     C*------------------------
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

      /define ERRNO_LOAD_PROCEDURE
      /copy socktut/qrpglesrc,errno_h
