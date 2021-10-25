     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('SOCKTUT/SOCKUTIL') BNDDIR('QC2LE')

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,sockutil_h
     D/copy socktut/qrpglesrc,errno_h

     D die             PR
     D   peMsg                      256A   const

     D NewListener     PR            10I 0
     D   pePort                       5U 0 value
     D   peError                    256A

     D copysock        PR            10I 0
     D  fromsock                     10I 0 value
     D  tosock                       10I 0 value

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
     C* Listen on both ports given
     C*************************************************
     c                   eval      s1 = NewListener(port1: errmsg)
     c                   if        s1 < 0
     c                   callp     die(errmsg)
     c                   return
     c                   endif

     c                   eval      s2 = NewListener(port2: errmsg)
     c                   if        s2 < 0
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
     c                   callp     close(s2)
     c                   callp     die(errmsg)
     c                   return
     c                   endif
     c                   callp     close(s1)

     C*************************************************
     C* Get a client on second port, then stop
     C*   listening for more connections
     C*************************************************
     c                   eval      len = %size(sockaddr_in)
     c                   eval      s2c = accept(s2: connfrom: len)
     c                   if        s2c < 0
     c                   eval      errmsg = %str(strerror(errno))
     c                   callp     close(s1c)
     c                   callp     close(s2)
     c                   callp     die(errmsg)
     c                   return
     c                   endif
     c                   callp     close(s2)

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
     c                   if        copysock(s1c: s2c) < 0
     c                   leave
     c                   endif
     c                   endif

     c                   if        FD_ISSET(s2c: read_set)
     c                   if        copysock(s2c: s1c) < 0
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
      *  This copies data from one socket to another.
      *    parms:
      *         fromsock = socket to copy data from
      *         tosock = socket to copy data to
      *
      *    returns:  length of data copied, or -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P copysock        B
     D copysock        PI            10I 0
     D  fromsock                     10I 0 value
     D  tosock                       10I 0 value
     D buf             S           1024A
     D rc              S             10I 0
     c                   eval      rc = recv(fromsock: %addr(buf): 1024: 0)
     c                   if        rc < 0
     c                   return    -1
     c                   endif
     c                   if        send(tosock: %addr(buf): rc: 0) < rc
     c                   return    -1
     c                   endif
     c                   return    rc
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
