     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE') BNDDIR('SOCKTUT/SOCKUTIL')

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,sockutil_h
     D/copy socktut/qrpglesrc,errno_h

     D translate       PR                  ExtPgm('QDCXLATE')
     D   length                       5P 0 const
     D   data                     32766A   options(*varsize)
     D   table                       10A   const

     D compmsg         PR
     D   peMsg                      256A   const

     D die             PR
     D   peMsg                      256A   const

     D sock            S             10I 0
     D err             S             10I 0
     D len             S             10I 0
     D bindto          S               *
     D addr            S             10U 0
     D buf             S            256A
     D buflen          S             10I 0
     D host            S            128A
     D user            S             10A
     D msg             S            150A
     D destlen         S             10I 0
     D destaddr        S               *

     c     *entry        plist
     c                   parm                    host
     c                   parm                    user
     c                   parm                    msg

     c                   eval      *inlr = *on

     C* Get the 32-bit network IP address for the host
     C*  that was supplied by the user:
     c                   eval      addr = inet_addr(%trim(host))
     c                   if        addr = INADDR_NONE
     c                   eval      p_hostent = gethostbyname(%trim(host))
     c                   if        p_hostent = *NULL
     c                   callp     die('Unable to find that host!')
     c                   return
     c                   endif
     c                   eval      addr = h_addr
     c                   endif

     C* Create a UDP socket:
     c                   eval      sock = socket(AF_INET: SOCK_DGRAM:
     c                                       IPPROTO_IP)
     c                   if        sock < 0
     c                   callp     die('socket(): '+%str(strerror(errno)))
     c                   return
     c                   endif

     C* Create a socket address struct with destination info
     C                   eval      destlen = %size(sockaddr_in)
     c                   alloc     destlen       destaddr
     c                   eval      p_sockaddr = destaddr

     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = addr
     c                   eval      sin_port = 4000
     c                   eval      sin_zero = *ALLx'00'

     C* Create a buffer with the userid & password and
     C*  translate it to ASCII
     c                   eval      buf = user
     c                   eval      %subst(buf:11) = msg
     c                   eval      buflen = %len(%trimr(buf))
     c                   callp     translate(buflen: buf: 'QTCPASC')

     C* Send the datagram
     c                   if        sendto(sock: %addr(buf): buflen: 0:
     c                               destaddr: destlen) < 0
     c                   eval      err = errno
     c                   callp     close(sock)
     c                   callp     die('sendto(): '+%str(strerror(err)))
     c                   return
     c                   endif

     C* Wait for an ack
     c                   eval      len = recvfrom(sock: %addr(buf): 256: 0:
     c                               destaddr: destlen)
     c                   if        len < 6
     c                   callp     close(sock)
     c                   callp     die('error receiving ack!')
     c                   return
     c                   endif

     C* Report status & end
     c                   callp     Translate(len: buf: 'QTCPEBC')
     c                   callp     compmsg('Message sent.  Server ' +
     c                              'responded with: ' + %subst(buf:1:len))

     c                   callp     close(sock)
     c                   return


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This sends a 'completion message', showing a successful
      *   termination to the program.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P compmsg         B
     D compmsg         PI
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
     c                               peMsg: wwMsgLen: '*COMP':
     c                               '*PGMBDY': 1: wwTheKey: dsEC)

     c                   return
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
