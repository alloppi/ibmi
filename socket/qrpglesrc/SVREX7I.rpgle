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

     D SignIn          PR            10I 0
     D   sock                        10I 0 value
     D   userid                      10A

     D cli             S             10I 0
     D rc              S             10I 0
     D usrprf          S             10A
     D pgmname         S             21A

     D lower           C                   'abcdefghijklmnopqrstuvwxyz'
     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     c                   eval      *inlr = *on

     C*********************************************************
     C* Get socket descriptor from 'listener' program
     C*********************************************************
     c                   eval      cli = GetClient
     c                   if        cli < 0
     c                   callp     Die('Failure retrieving client socket '+
     c                              'descriptor.')
     c                   return
     c                   endif

     C*********************************************************
     C* Ask user to sign in, and set user profile.
     C*********************************************************
     c                   eval      rc = SignIn(cli: usrprf)
     c                   select
     c                   when      rc < 0
     c                   callp     Die('Client disconnected during sign-in')
     c                   callp     close(cli)
     c                   return
     c                   when      rc = 0
     c                   callp     Die('Authorization failure!')
     c                   callp     close(cli)
     c                   return
     c                   endsl

     C*********************************************************
     C*  Ask for the program to be called
     C*********************************************************
     c                   callp     WrLine(cli: '102 Please enter the ' +
     c                               'program you''d like to call')

     c                   if        RdLine(cli: %addr(pgmname): 21: *On) < 0
     c                   callp     Die('Error calling RdLine()')
     c                   callp     close(cli)
     c                   return
     c                   endif

     c     lower:upper   xlate     pgmname       pgmname

     C*********************************************************
     C* Call the program, passing the socket desc & profile
     C*   as the parameters.
     C*********************************************************
     c                   call(e)   PgmName
     c                   parm                    cli
     c                   parm                    usrprf

     c                   if        not %error
     c                   callp     WrLine(cli: '103 Call succeeded.')
     c                   else
     c                   callp     WrLine(cli: '902 Call failed.')
     c                   endif

     C*********************************************************
     C* End.
     C*********************************************************
     c                   callp     close(cli)
     c                   return


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Sign a user-id into the system
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SignIn          B
     D SignIn          PI            10I 0
     D   sock                        10I 0 value
     D   userid                      10A

     D passwd          S             10A
     D handle          S             12A

     c                   dou       userid <> *blanks

     c                   callp     WrLine(sock: '100 Please enter your ' +
     c                               'user-id now!')

     c                   if        RdLine(sock: %addr(userid): 10: *On) < 0
     c                   return    -1
     c                   endif

     c     lower:upper   xlate     userid        userid

     c                   callp     WrLine(sock: '101 Please enter your ' +
     c                               'password now!')

     c                   if        RdLine(sock: %addr(passwd): 10: *On) < 0
     c                   return    -1
     c                   endif

     c     lower:upper   xlate     passwd        passwd

     c                   callp     GetProfile(userid: passwd: handle: dsEC)
     c                   if        dsECBytesA > 0
     c                   callp     WrLine(sock: '900 Incorrect userid ' +
     c                               'or password! ('+%trim(dsECMsgID)+')')
     c                   eval      userid = *blanks
     c                   endif

     c                   enddo

     c                   callp     SetProfile(handle: dsEC)
     c                   if        dsECBytesA > 0
     c                   callp     WrLine(sock: '901 Unable to set ' +
     c                             'profile!  ('+%trim(dsECMsgID)+')')
     c                   return    0
     c                   endif

     c                   return    1
     P                 E


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

     c                   callp     SndDtaq('SVREX7DQ': 'SOCKTUT': jilen:
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
