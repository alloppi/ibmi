     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('SOCKTUT/SOCKUTIL') BNDDIR('QC2LE')

      *** header files for calling service programs & APIs

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,sockutil_h
     D/copy socktut/qrpglesrc,errno_h
     D/copy socktut/qrpglesrc,jobinfo_h

      *** prototypes for external calls

     D Cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   length                      15P 5 const

      *** Prototypes for local subprocedures:

     D die             PR
     D   peMsg                      256A   const

     D NewListener     PR            10I 0
     D   pePort                       5U 0 value
     D   peError                    256A

     D KillEmAll       PR

      *** local variables & constants

     D MAXCLIENTS      C                   CONST(256)

     D svr             S             10I 0
     D cli             S             10I 0
     D msg             S            256A
     D err             S             10I 0
     D calen           S             10I 0
     D clientaddr      S               *
     D jilen           S              5P 0

     c                   eval      *inlr = *on

     C*************************************************
     C* Clean up any previous instances of the dtaq
     C*************************************************
     c                   callp(e)  Cmd('DLTDTAQ SOCKTUT/SVREX6DQ': 200)
     c                   callp(e)  Cmd('CRTDTAQ DTAQ(SOCKTUT/SVREX6DQ) ' +
     c                                        ' MAXLEN(80) TEXT(''Data ' +
     c                                        ' queue for SVREX6L'')': 200)
     c                   if        %error
     c                   callp     Die('Unable to create data queue!')
     c                   return
     c                   endif

     C*************************************************
     C* Start listening for connections on port 4000
     C*************************************************
     c                   eval      svr = NewListener(4000: msg)
     c                   if        svr < 0
     c                   callp     die(msg)
     c                   return
     c                   endif

     C*************************************************
     C* create a space to put client addr struct into
     C*************************************************
     c                   eval      calen = %size(sockaddr_in)
     c                   alloc     calen         clientaddr

     c                   dow       1 = 1

     C************************************
     C* Get a new server instance ready
     C************************************
     c                   callp(e)  Cmd('SBMJOB CMD(CALL PGM(SVREX6I))' +
     c                                       ' JOB(SERVERINST) ' +
     c                                       ' JOBQ(QSYSNOMAX) ' +
     c                                       ' JOBD(QDFTJOBD) ' +
     c                                       ' RTGDTA(QCMDB)': 200)
     c                   if        %error
     c                   callp     close(svr)
     c                   callp     KillEmAll
     c                   callp     Die('Unable to submit a new job to ' +
     c                             'process clients!')
     c                   return
     c                   endif

     C************************************
     C* Accept a new client conn
     C************************************
     c                   eval      cli = accept(svr: clientaddr: calen)
     c                   if        cli < 0
     c                   eval      err = errno
     c                   callp     close(svr)
     c                   callp     KillEmAll
     c                   callp     die('accept(): ' + %str(strerror(err)))
     c                   return
     c                   endif

     c                   if        calen <> %size(sockaddr_in)
     c                   callp     close(cli)
     c                   eval      calen = %size(sockaddr_in)
     c                   iter
     c                   endif

     C************************************
     C* get the internal job id of a
     C*  server instance to handle client
     C************************************
     c                   eval      jilen = %size(dsJobInfo)
     c                   callp     RcvDtaQ('SVREX6DQ': 'SOCKTUT': jilen:
     c                                     dsJobInfo: 60)
     c                   if        jilen < 80
     c                   callp     close(cli)
     c                   callp     KillEmAll
     c                   callp     close(svr)
     c                   callp     die('No response from server instance!')
     c                   return
     c                   endif

     C************************************
     C* Pass descriptor to svr instance
     C************************************
     c                   if        givedescriptor(cli: %addr(InternalID))<0
     c                   eval      err = errno
     c                   callp     close(cli)
     c                   callp     KillEmAll
     c                   callp     close(svr)
     c                   callp     Die('givedescriptor(): ' +
     c                                 %str(strerror(err)))
     c                   Return
     c                   endif

     c                   callp     close(cli)
     c                   enddo


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This ends any server instances that have been started, but
      *   have not been connected with clients.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P KillEmAll       B
     D KillEmAll       PI
     c                   dou       jilen < 80

     c                   eval      jilen = %size(dsJobInfo)
     c                   callp     RcvDtaQ('SVREX6DQ': 'SOCKTUT': jilen:
     c                                     dsJobInfo: 1)

     c                   if        jilen >= 80

     c                   callp(E)  Cmd('ENDJOB JOB(' + %trim(JobNbr) +
     c                                  '/' + %trim(JobUser) + '/' +
     c                                  %trim(jobName) + ') OPTION(*IMMED)'+
     c                                  ' LOGLMT(0)': 200)

     C                   endif

     c                   enddo
     P                 E


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
     c                   if        listen(sock: MAXCLIENTS) < 0
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
