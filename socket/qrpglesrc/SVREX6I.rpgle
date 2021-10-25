     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('SOCKTUT/SOCKUTIL') BNDDIR('QC2LE')

      *** header files for calling service programs & APIs

     D/copy socktut/qrpglesrc,socket_h
     D/copy socktut/qrpglesrc,sockutil_h
     D/copy socktut/qrpglesrc,errno_h
     D/copy socktut/qrpglesrc,jobinfo_h

      *** Prototypes for local subprocedures:

     D die             PR
     D   peMsg                      256A   const

     D GetClient       PR            10I 0

     D cli             S             10I 0
     D name            S             80A

     c                   eval      *inlr = *on

     c                   eval      cli = GetClient
     c                   if        cli < 0
     c                   callp     Die('Failure retrieving client socket '+
     c                              'descriptor.')
     c                   return
     c                   endif

     c                   callp     WrLine(cli: 'Please enter your ' +
     c                               'name now!')

     c                   if        RdLine(cli: %addr(name): 80: *On) < 0
     c                   callp     close(cli)
     c                   callp     Die('RdLine() failed!')
     c                   return
     c                   endif

     c                   callp     WrLine(cli: 'Hello ' + %trim(name) + '!')
     c                   callp     WrLine(cli: 'Goodbye ' +%trim(name)+ '!')

     c                   callp     close(cli)
     c                   return


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Get the new client from the listener application
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P GetClient       B
     D GetClient       PI            10I 0

     D jilen           S              5P 0
     D sock            S             10I 0

     c                   callp     RtvJobInf(dsJobI0100: %size(dsJobI0100):
     c                               'JOBI0100': '*': *BLANKS: dsEC)
     c                   if        dsECBytesA > 0
     c                   return    -1
     c                   endif

     c                   eval      JobName = JobI_JobName
     c                   eval      JobUser = JobI_UserID
     c                   eval      JobNbr = JobI_JobNbr
     c                   eval      InternalID = JobI_IntJob

     c                   eval      jilen = %size(dsJobInfo)

     c                   callp     SndDtaq('SVREX6DQ': 'SOCKTUT': jilen:
     c                                dsJobInfo)

     c                   eval      sock = TakeDescriptor(*NULL)
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
