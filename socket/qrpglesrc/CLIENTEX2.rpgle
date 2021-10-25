     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE') BNDDIR('SOCKTUT/SOCKUTIL')

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,errno_h
     D/copy socktut/qrpglesrc,sockutil_h

      *********************************************************
      * Definitions needed to make IFS API calls.  Note that
      * these should really be in a separate /copy file!
      *********************************************************
     D O_WRONLY        C                   2
     D O_CREAT         C                   8
     D O_TRUNC         C                   64
     D O_CODEPAGE      C                   8388608
     D open            PR            10I 0 ExtProc('open')
     D  filename                       *   value options(*string)
     D  openflags                    10I 0 value
     D  mode                         10U 0 value options(*nopass)
     D  codepage                     10U 0 value options(*nopass)
     D unlink          PR            10I 0 ExtProc('unlink')
     D   path                          *   Value options(*string)
     D write           PR            10I 0 ExtProc('write')
     D  handle                       10I 0 value
     D  buffer                         *   value
     D  bytes                        10U 0 value
      *********************************************************
      * end of IFS API call definitions
      *********************************************************

     D die             PR
     D   peMsg                      256A   const

     D cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   length                      15P 5 const

     D msg             S             50A
     D sock            S             10I 0
     D port            S              5U 0
     D addrlen         S             10I 0
     D ch              S              1A
     D host            s             32A
     D file            s             32A
     D addr            s             10U 0
     D p_Connto        S               *
     D RC              S             10I 0
     D RecBuf          S             50A
     D RecLen          S             10I 0
     D err             S             10I 0
     D fd              S             10I 0

     C*************************************************
     C* The user will supply a hostname and file
     C*  name as parameters to our program...
     C*************************************************
     c     *entry        plist
     c                   parm                    host
     c                   parm                    file

     c                   eval      *inlr = *on

     C*************************************************
     C* what port is the http service located on?
     C*************************************************
     c                   eval      p_servent = getservbyname('http':'tcp')
     c                   if        p_servent = *NULL
     c                   callp     die('Can''t find the HTTP service!')
     c                   return
     c                   endif

     c                   eval      port = s_port

     C*************************************************
     C* Get the 32-bit network IP address for the host
     C*  that was supplied by the user:
     C*************************************************
     c                   eval      addr = inet_addr(%trim(host))
     c                   if        addr = INADDR_NONE
     c                   eval      p_hostent = gethostbyname(%trim(host))
     c                   if        p_hostent = *NULL
     c                   callp     die('Unable to find that host!')
     c                   return
     c                   endif
     c                   eval      addr = h_addr
     c                   endif

     C*************************************************
     C* Create a socket
     C*************************************************
     c                   eval      sock = socket(AF_INET: SOCK_STREAM:
     c                                           IPPROTO_IP)
     c                   if        sock < 0
     c                   callp     die('socket(): ' + %str(strerror(errno)))
     c                   return
     c                   endif

     C*************************************************
     C* Create a socket address structure that
     C*   describes the host & port we wanted to
     C*   connect to
     C*************************************************
     c                   eval      addrlen = %size(sockaddr)
     c                   alloc     addrlen       p_connto

     c                   eval      p_sockaddr = p_connto
     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = addr
     c                   eval      sin_port = port
     c                   eval      sin_zero = *ALLx'00'

     C*************************************************
     C* Connect to the requested host
     C*************************************************
     C                   if        connect(sock: p_connto: addrlen) < 0
     c                   eval      err = errno
     c                   callp     close(sock)
     c                   callp     die('connect(): '+%str(strerror(err)))
     c                   return
     c                   endif

     C*************************************************
     C* Send a request for the file that we'd like
     C* the http server to send us.
     C*
     C* Then we send a blank line to tell it we're
     C* done sending requests, it can process them...
     C*************************************************
     c                   callp     WrLine(sock: 'GET http://' +
     c                               %trim(host) + %trim(file) +
     c                               ' HTTP/1.0')
     c                   callp     WrLine(sock: ' ')

     C*************************************************
     C* Get back the server's response codes
     C*
     C* The HTTP server will send it's responses one
     C* by one, then send a blank line to separate
     C* the server responses from the actual data.
     C*************************************************
     c                   dou       recbuf = *blanks
     C                   eval      rc = rdline(sock: %addr(recbuf):
     c                                         %size(recbuf): *On)
     c                   if        rc < 0
     c                   eval      err = errno
     c                   callp     close(sock)
     c                   callp     die('rdline(): '+%str(strerror(err)))
     c                   return
     c                   endif
     c                   enddo

     C*************************************************
     C* Open a temporary stream file to put our
     C*   web page data into:
     C*************************************************
     c                   eval      fd = open('/http_tempfile.txt':
     c                                  O_WRONLY+O_TRUNC+O_CREAT+O_CODEPAGE:
     c                                  511: 437)
     c                   if        fd < 0
     c                   eval      err = errno
     c                   callp     close(sock)
     c                   callp     Die('open(): '+%str(strerror(err)))
     c                   return
     c                   endif

     C*************************************************
     C* Write returned data to the stream file:
     C*************************************************
     c                   dou       rc < 1
     c                   eval      rc = recv(sock: %addr(recbuf):
     c                                         %size(recbuf): 0)
     c                   if        rc > 0
     c                   callp     write(fd: %addr(recbuf): rc)
     c                   endif
     c                   enddo

     C*************************************************
     C*  We're done receiving, do the following:
     C*       1) close the stream file & socket.
     C*       2) display the stream file
     C*       3) unlink (delete) the stream file
     C*       4) end program
     C*************************************************
     c                   callp     close(fd)
     c                   callp     close(sock)
     c                   callp     Cmd('DSPF STMF(''/http_tempfile.txt'')':
     c                                200)
     c                   callp     unlink('/http_tempfile.txt')

     c                   return


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
