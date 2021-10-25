     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE') BNDDIR('SOCKTUT/SOCKUTIL')

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,sockutil_h
     D/copy socktut/qrpglesrc,errno_h

     D Cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   length                      15P 5 const

     D translate       PR                  ExtPgm('QDCXLATE')
     D   length                       5P 0 const
     D   data                     32766A   options(*varsize)
     D   table                       10A   const

     D die             PR
     D   peMsg                      256A   const

     D sock            S             10I 0
     D err             S             10I 0
     D bindto          S               *
     D len             S             10I 0
     D dtalen          S             10I 0
     D msgfrom         S               *
     D fromlen         S             10I 0
     D timeout         S               *
     D tolen           S             10I 0
     D readset         S                   like(fdset)
     D excpset         S                   like(fdset)
     D user            S             10A
     D msg             S            150A
     D buf             S            256A
     D rc              S             10I 0

     c                   eval      *inlr = *on

     c                   eval      fromlen = %size(sockaddr_in)
     c                   alloc     fromlen       msgfrom

     c                   eval      tolen = %size(timeval)
     c                   alloc     tolen         timeout

     c                   eval      p_timeval = timeout
     c                   eval      tv_sec = 25
     c                   eval      tv_usec = 0

     c                   eval      sock = socket(AF_INET: SOCK_DGRAM:
     c                                         IPPROTO_IP)
     c                   if        sock < 0
     c                   callp     die('socket(): '+%str(strerror(errno)))
     c                   return
     c                   endif

     c                   eval      len = %size(sockaddr_in)
     c                   alloc     len           bindto

     c                   eval      p_sockaddr = bindto
     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = INADDR_ANY
     c                   eval      sin_port = 4000
     c                   eval      sin_zero = *ALLx'00'

     c                   if        bind(sock: bindto: len) < 0
     c                   eval      err = errno
     c                   callp     close(sock)
     c                   callp     die('bind(): '+%str(strerror(err)))
     c                   return
     c                   endif

     c                   dow        1 = 1

     C* Use select to determine when data is found
     c                   callp     fd_zero(readset)
     c                   callp     fd_zero(excpset)
     c                   callp     fd_set(sock: readset)
     c                   callp     fd_set(sock: excpset)

     c                   eval      rc = select(sock+1: %addr(readset):
     c                                *NULL: %addr(excpset): timeout)

     C* If shutdown is requested, end program.
     c                   shtdn                                        99
     c                   if        *in99 = *on
     c                   callp     close(sock)
     c                   return
     c                   endif

     C* If select timed out, go back to select()...
     c                   if        rc  = 0
     c                   iter
     c                   endif

     C* Receive a datagram:
     c                   eval      dtalen = recvfrom(sock: %addr(buf):
     c                                %size(buf): 0: msgfrom: fromlen)

     C* Check for errors
     c                   if        dtalen < 0
     c                   eval      err = errno
     c                   callp     close(sock)
     c                   callp     die('recvfrom(): '+%str(strerror(err)))
     c                   return
     c                   endif

     C* Skip any invalid messages
     c                   if        dtalen < 11
     c                   iter
     c                   endif

     C* Skip any messages from invalid addresses
     c                   if        fromlen <> %size(sockaddr_in)
     c                   eval      fromlen = %size(sockaddr_in)
     c                   iter
     c                   endif

     C* Translate to EBCDIC
     c                   callp     Translate(dtalen: buf: 'QTCPEBC')

     c* send message to user
     c                   eval      user = %subst(buf:1: 10)
     c                   eval      dtalen = dtalen - 10
     c                   eval      msg = %subst(buf:11:dtalen)

     c                   callp(e)  Cmd('SNDMSG MSG(''' + %trimr(msg) +
     c                                ''') TOUSR(' + %trim(user) + ')': 200)

     c* make an acknowledgement
     c                   if        %error
     c                   eval      buf = 'failed'
     c                   eval      dtalen = 6
     c                   else
     c                   eval      buf = 'success'
     c                   eval      dtalen = 7
     c                   endif

     c* convert acknowledgement to ASCII
     c                   callp     Translate(dtalen: buf: 'QTCPASC')

     c* send acknowledgement to ASCII
     c                   if        sendto(sock: %addr(buf): dtalen: 0:
     c                                   msgfrom: fromlen) < 0
     c                   eval      err = errno
     c                   callp     close(sock)
     c                   callp     die('sendto(): '+%str(strerror(err)))
     c                   return
     c                   endif

     c                   enddo


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
