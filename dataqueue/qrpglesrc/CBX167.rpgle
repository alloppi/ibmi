     **
     **  Program . . : CBX167
     **  Description : Display Data Queue Entries - CPP
     **  Author  . . : Carsten Flensburg
     **  Published . : System iNetwork Programming Tips Newsletter
     **  Date  . . . : January 18, 2007
     **
     **
     **  Compilation specification:
     **    CrtRpgMod  Module( CBX167 )
     **               DbgView( *NONE )
     **
     **    CrtPgm     Pgm( CBX167 )
     **               Module( CBX167 )
     **               ActGrp( *NEW )
     **
     **
     **
     **-- Header specifications:  --------------------------------------------**
     H Option( *SrcStmt )

     **-- System information:
     D PgmSts         SDs                  Qualified
     D  PgmNam           *Proc
     D  AppPfx                        6a   Overlay( PgmNam )

     **-- API error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPrv                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      128a

     **-- Global constants:
     D OFS_MSGDTA      c                   16
     D TYP_DTAQ        c                   '*'
     D SEQ_KEYED       c                   'K'
     D SEQ_Q_DFN       c                   'A'
     **-- UIM constants:
     D PNLGRP_Q        c                   'CBX167P   *LIBL     '
     D PNLGRP          c                   'CBX167P   '
     D SCP_AUT_RCL     c                   -1
     D RDS_OPT_INZ     c                   'N'
     D PRM_IFC_0       c                   0
     D CLO_NORM        c                   'M'
     D FNC_EXIT        c                   -4
     D FNC_CNL         c                   -8
     D KEY_F05         c                   5
     D KEY_F17         c                   17
     D KEY_F18         c                   18
     D RTN_ENTER       c                   500
     D INC_EXP         c                   'Y'
     D CPY_VAR         c                   'Y'
     D CPY_VAR_NO      c                   'N'
     D HLP_WDW         c                   'N'
     D POS_TOP         c                   'TOP'
     D POS_BOT         c                   'BOT'
     D LIST_COMP       c                   'ALL'
     D LIST_SAME       c                   'SAME'
     D EXIT_SAME       c                   '*SAME'
     D DSPA_SAME       c                   'SAME'
     D TRIM_SAME       c                   'S'

     **-- Global variables:
     D SysDts          s               z
     D KeyDtaVal       s             32a
     D Idx             s             10i 0
     D CmdStr          s           4096a   Varying

     **-- UIM variables:
     D UIM             Ds                  Qualified
     D  AppHdl                        8a
     D  LstHdl                        4a
     D  EntHdl                        4a
     D  FncRqs                       10i 0 Inz
     D  EntLocOpt                     4a
     D  LstPos                        4a
     **-- List attributes structure:
     D LstAtr          Ds                  Qualified
     D  LstCon                        4a
     D  ExtPgmVar                    10a
     D  DspPos                        4a
     D  AlwTrim                       1a

     **-- UIM Panel exit program record:
     D ExpRcd          Ds                  Qualified
     D  ExitPg                       20a   Inz( 'CBX167E   *LIBL' )
     D  ListPg                       20a   Inz( 'CBX167L   *LIBL' )
     **-- UIM Panel control record:
     D CtlRcd          Ds                  Qualified
     D  Action                        4a
     D  EntLocOpt                     4a
     **-- UIM List parameter record:
     D PrmRcd          Ds                  Qualified
     D  DtqNam                       10a
     D  DtqLib                       10a
     D  LstSeq                        1a
     D  NbrElm                        5i 0
     D  RelOpr                        2a
     D  KeyVal                      256a   Varying
     D  KeyLen                        3p 0
     D  AuxStg                        1a
     D  StgNam                       10a
     D  StgLib                       10a
     D  LstSts                        1a
     **-- UIM Panel header record:
     D HdrRcd          Ds                  Qualified  Inz
     D  SysDat                        7a
     D  SysTim                        6a
     D  TimZon                       10a
     D  DtqNam                       10a
     D  DtqLib                       10a
     D  DtqSeq                        1a
     D  CurEnt                       10i 0
     D  LstSeq                        1a
     **-- UIM List entry:
     D LstEnt          Ds                  Qualified
     D  Option                        5i 0
     D  EntId                        10i 0
     D  DtqEnt                      256a
     D  DtqKey                      256a
     D  SndInf                       36a
     D  EnqDat                        7a
     D  EnqTim                        6a
     D  EntLen                       10i 0
     D  KeyLen                       10i 0
     **
     D LstEntPos       Ds                  LikeDs( LstEnt )

     **-- RDQD0100 format:
     D RDQD0100        Ds                  Qualified
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  MsgLen                       10i 0
     D  KeyLen                       10i 0
     D  Seq                           1a
     D  IncSndId                      1a
     D  FrcInd                        1a
     D  TxtDsc                       50a
     D  Type                          1a
     D  AutRcl                        1a
     D                                1a
     D  NbrCurMsg                    10i 0
     D  NbrMsgAlc                    10i 0
     D  DtaQ_Nam                     10a
     D  DtaQ_Lib                     10a
     D  MaxMsgAlw                    10i 0
     D  InlNbrMsg                    10i 0
     D  DtaQ_Size                    10i 0

     **-- Send program message:
     D SndPgmMsg       Pr                  ExtPgm( 'QMHSNDPM' )
     D  MsgId                         7a   Const
     D  MsgFq                        20a   Const
     D  MsgDta                      128a   Const
     D  MsgDtaLen                    10i 0 Const
     D  MsgTyp                       10a   Const
     D  CalStkE                      10a   Const  Options( *VarSize )
     D  CalStkCtr                    10i 0 Const
     D  MsgKey                        4a
     D  Error                     32767a          Options( *VarSize )
     **-- Receive program message:
     D RcvPgmMsg       Pr                  ExtPgm( 'QMHRCVPM' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                       10a   Const
     D  CalStkE                     256a   Const  Options( *VarSize )
     D  CalStkCtr                    10i 0 Const
     D  MsgTyp                       10a   Const
     D  MsgKey                        4a   Const
     D  Wait                         10i 0 Const
     D  MsgAct                       10a   Const
     D  Error                     32767a          Options( *VarSize )
     D  CalStkElen                   10i 0 Const  Options( *NoPass )            call stack counter
     D  CalStkEq                     20a   Const  Options( *NoPass )            call stack counter
     D  CalStkEtyp                   20a   Const  Options( *NoPass )            call stack counter
     D  CcsId                        10i 0 Const  Options( *NoPass )            call stack counter
     **-- Retrieve data queue description:
     D RtvDtqDsc       Pr                  ExtPgm( 'QMHQRDQD' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                       10a   Const
     D  DtaQ_q                       20a   Const
     **-- Retrieve call stack:
     D RtvCalStk       Pr                  ExtPgm( 'QWVRCSTK' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  RcvInfFmt                     8a   Const
     D  JobId                        56a   Const
     D  JobIdFmt                      8a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Execute command:
     D ExcCmd          Pr                  ExtPgm( 'QCMDEXC' )
     D  CmdStr                     4096a   Const  Options( *VarSize )
     D  CmdLen                       15p 5 Const
     D  CmdIGC                        3a   Const  Options( *NoPass )

     **-- Open display application:
     D OpnDspApp       Pr                  ExtPgm( 'QUIOPNDA' )
     D  AppHdl                        8a
     D  PnlGrp_q                     20a   Const
     D  AppScp                       10i 0 Const
     D  ExtPrmIfc                    10i 0 Const
     D  FulScrHlp                     1a   Const
     D  Error                     32767a          Options( *VarSize )
     D  OpnDtaRcv                   128a          Options( *NoPass: *VarSize )
     D  OpnDtaRcvLen                 10i 0 Const  Options( *NoPass )
     D  OpnDtaRcvAvl                 10i 0        Options( *NoPass )
     **-- Display panel:
     D DspPnl          Pr                  ExtPgm( 'QUIDSPP' )
     D  AppHdl                        8a   Const
     D  FncRqs                       10i 0
     D  PnlNam                       10a   Const
     D  ReDspOpt                      1a   Const
     D  Error                     32767a          Options( *VarSize )
     D  UsrTsk                        1a   Const  Options( *NoPass )
     D  CalStkCnt                    10i 0 Const  Options( *NoPass )
     D  CalMsgQue                   256a   Const  Options( *NoPass: *VarSize )
     D  MsgKey                        4a   Const  Options( *NoPass )
     D  CsrPosOpt                     1a   Const  Options( *NoPass )
     D  FinLstEnt                     4a   Const  Options( *NoPass )
     D  ErrLstEnt                     4a   Const  Options( *NoPass )
     D  WaitTim                      10i 0 Const  Options( *NoPass )
     D  CalMsgQueLen                 10i 0 Const  Options( *NoPass )
     D  CalQlf                       20a   Const  Options( *NoPass )
     **-- Put dialog variable:
     D PutDlgVar       Pr                  ExtPgm( 'QUIPUTV' )
     D  AppHdl                        8a   Const
     D  VarBuf                    32767a   Const  Options( *VarSize )
     D  VarBufLen                    10i 0 Const
     D  VarRcdNam                    10a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Get dialog variable:
     D GetDlgVar       Pr                  ExtPgm( 'QUIGETV' )
     D  AppHdl                        8a   Const
     D  VarBuf                    32767a          Options( *VarSize )
     D  VarBufLen                    10i 0 Const
     D  VarRcdNam                    10a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Get list entry:
     D GetLstEnt       Pr                  ExtPgm( 'QUIGETLE' )
     D  AppHdl                        8a   Const
     D  VarBuf                    32767a   Const  Options( *VarSize )
     D  VarBufLen                    10i 0 Const
     D  VarRcdNam                    10a   Const
     D  LstNam                       10a   Const
     D  PosOpt                        4a   Const
     D  CpyOpt                        1a   Const
     D  SltCri                       20a   Const
     D  SltHdl                        4a   Const
     D  ExtOpt                        1a   Const
     D  LstEntHdl                     4a
     D  Error                     32767a          Options( *VarSize )
     **-- Retrieve list attributes:
     D RtvLstAtr       Pr                  ExtPgm( 'QUIRTVLA' )
     D  AppHdl                        8a   Const
     D  LstNam                       10a   Const
     D  AtrRcv                    32767a          Options( *VarSize )
     D  AtrRcvLen                    10i 0 Const
     D  Error                     32767a          Options( *VarSize )
     **-- Set list attributes:
     D SetLstAtr       Pr                  ExtPgm( 'QUISETLA' )
     D  AppHdl                        8a   Const
     D  LstNam                       10a   Const
     D  LstCon                        4a   Const
     D  ExtPgmVar                    10a   Const
     D  DspPos                        4a   Const
     D  AlwTrim                       1a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Delete list:
     D DltLst          Pr                  ExtPgm( 'QUIDLTL' )
     D  AppHdl                        8a   Const
     D  LstNam                       10a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Close application:
     D CloApp          Pr                  ExtPgm( 'QUICLOA' )
     D  AppHdl                        8a   Const
     D  CloOpt                        1a   Const
     D  Error                     32767a          Options( *VarSize )

     **-- Get invocation level:
     D GetInvLvl       Pr            10i 0
     **-- Create storage data queue:
     D CrtStgDtq       Pr
     D  PxDtqNam                     10a   Const  Varying  Options( *Trim )
     D  PxDtqLib                     10a   Const  Varying  Options( *Trim )
     D  PxMsgLen                     10a   Const  Varying  Options( *Trim )
     **-- Run command:
     D RunCmd          Pr            10i 0
     D  PxCmdStr                   4096a   Const  Varying
     **-- Send escape message:
     D SndEscMsg       Pr            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgF                       10a   Const
     D  PxMsgDta                    512a   Const  Varying

     **-- Entry parameters:
     D ObjNam_q        Ds
     D  ObjNam                       10a
     D  ObjLib                       10a
     **
     D Select          Ds
     D  NbrElm                        5i 0
     D  RelOpr                        2a
     D  KeyVal                      256a   Varying
     D  KeyLen                        3p 0
     **
     D CBX167          Pr
     D  PxDtaQ_q                           LikeDs( ObjNam_q )
     D  PxLstSeq                      1a
     D  PxSelect                           LikeDs( Select )
     **
     D CBX167          Pi
     D  PxDtaQ_q                           LikeDs( ObjNam_q )
     D  PxLstSeq                      1a
     D  PxSelect                           LikeDs( Select )

      /Free

        OpnDspApp( UIM.AppHdl
                 : PNLGRP_Q
                 : SCP_AUT_RCL
                 : PRM_IFC_0
                 : HLP_WDW
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          ExSr  EscApiErr;
        EndIf;

        ExSr  BldHdrRcd;
        ExSr  BldComRcd;
        ExSr  BldEntLst;

        DoU  UIM.FncRqs = FNC_EXIT  Or  UIM.FncRqs = FNC_CNL;

          DspPnl( UIM.AppHdl: UIM.FncRqs: PNLGRP: RDS_OPT_INZ: ERRC0100 );

          Select;
          When  ERRC0100.BytAvl > *Zero;
            ExSr  EscApiErr;

          When  UIM.FncRqs = RTN_ENTER;
            Leave;

          When  UIM.FncRqs = KEY_F17;
            ExSr  PosLstTop;

          When  UIM.FncRqs = KEY_F18;
            ExSr  PosLstBot;
          EndSl;

          GetDlgVar( UIM.AppHdl: CtlRcd: %Size( CtlRcd ): 'CTLRCD': ERRC0100 );

          If  UIM.FncRqs = KEY_F05  And  CtlRcd.EntLocOpt = 'NEXT';
            ExSr  GetLstPos;
            ExSr  DltUsrLst;
          EndIf;

          If  UIM.FncRqs = KEY_F05;
            ExSr  BldEntLst;
            ExSr  SetLstPos;
          EndIf;

          ExSr  BldHdrRcd;
        EndDo;

        CloApp( UIM.AppHdl: CLO_NORM: ERRC0100 );

        If  PrmRcd.AuxStg = 'Y';
          RunCmd( 'DLTDTAQ DTAQ(' + %Trim( PrmRcd.StgLib ) +
                              '/' + %Trim( PrmRcd.StgNam ) +
                              ')'
                );
        EndIf;

        *InLr = *On;
        Return;


        BegSr  BldEntLst;

          If  UIM.FncRqs = KEY_F05;
            CtlRcd.Action = 'F05';
          Else;
            CtlRcd.Action = 'LIST';
          EndIf;

          PutDlgVar( UIM.AppHdl: CtlRcd: %Size( CtlRcd ): 'CTLRCD': ERRC0100 );

          SetLstAtr( UIM.AppHdl
                   : 'DTLLST'
                   : 'TOP'
                   : 'LISTPG'
                   : DSPA_SAME
                   : TRIM_SAME
                   : ERRC0100
                   );

        EndSr;

        BegSr  GetLstPos;

          RtvLstAtr( UIM.AppHdl: 'DTLLST': LstAtr: %Size( LstAtr ): ERRC0100 );

          If  LstAtr.DspPos <> 'TOP';

            GetLstEnt( UIM.AppHdl
                     : LstEnt
                     : %Size( LstEnt )
                     : 'DTLRCD'
                     : 'DTLLST'
                     : 'HNDL'
                     : CPY_VAR
                     : *Blanks
                     : LstAtr.DspPos
                     : INC_EXP
                     : UIM.EntHdl
                     : ERRC0100
                     );

            LstEntPos = LstEnt;
          EndIf;

        EndSr;

        BegSr  SetLstPos;

          If  LstAtr.DspPos <> 'TOP';

            LstEnt = LstEntPos;

            PutDlgVar( UIM.AppHdl
                     : LstEnt
                     : %Size( LstEnt )
                     : 'DTLRCD'
                     : ERRC0100
                     );

            GetLstEnt( UIM.AppHdl
                     : LstEnt
                     : %Size( LstEnt )
                     : '*NONE'
                     : 'DTLLST'
                     : 'NSLT'
                     : CPY_VAR_NO
                     : 'GE        ENTID'
                     : LstAtr.DspPos
                     : INC_EXP
                     : UIM.EntHdl
                     : ERRC0100
                     );

            If  ERRC0100.BytAvl = *Zero;

              SetLstAtr( UIM.AppHdl
                       : 'DTLLST'
                       : LIST_SAME
                       : EXIT_SAME
                       : UIM.EntHdl
                       : TRIM_SAME
                       : ERRC0100
                       );

            EndIf;
          EndIf;

        EndSr;

        BegSr  BldHdrRcd;

          SysDts = %Timestamp();

          HdrRcd.SysDat = %Char( %Date( SysDts ): *CYMD0 );
          HdrRcd.SysTim = %Char( %Time( SysDts ): *HMS0 );
          HdrRcd.TimZon = '*SYS';

          RtvDtqDsc( RDQD0100
                   : %Size( RDQD0100 )
                   : 'RDQD0100'
                   : PxDtaQ_q
                   );

          HdrRcd.DtqNam = RDQD0100.DtaQ_Nam;
          HdrRcd.DtqLib = RDQD0100.DtaQ_Lib;
          HdrRcd.DtqSeq = RDQD0100.Seq;
          HdrRcd.CurEnt = RDQD0100.NbrCurMsg;

          If  PxLstSeq = TYP_DTAQ;
            HdrRcd.LstSeq = RDQD0100.Seq;
          Else;
            HdrRcd.LstSeq = PxLstSeq;
          EndIf;

          PutDlgVar( UIM.AppHdl: HdrRcd: %Size( HdrRcd ): 'HDRRCD': ERRC0100 );

        EndSr;

        BegSr  PosLstTop;

          SetLstAtr( UIM.AppHdl
                   : 'DTLLST'
                   : LIST_SAME
                   : EXIT_SAME
                   : POS_TOP
                   : TRIM_SAME
                   : ERRC0100
                   );

        EndSr;

        BegSr  PosLstBot;

          SetLstAtr( UIM.AppHdl
                   : 'DTLLST'
                   : LIST_SAME
                   : EXIT_SAME
                   : POS_BOT
                   : TRIM_SAME
                   : ERRC0100
                   );

        EndSr;

        BegSr  DltUsrLst;

          DltLst( UIM.AppHdl: 'DTLLST': ERRC0100 );

        EndSr;

        BegSr  BldComRcd;

          PrmRcd.DtqNam = RDQD0100.DtaQ_Nam;
          PrmRcd.DtqLib = RDQD0100.DtaQ_Lib;

          If  PxSelect.NbrElm = 3;
            PrmRcd.RelOpr = PxSelect.RelOpr;
            PrmRcd.KeyVal = PxSelect.KeyVal;
            PrmRcd.KeyLen = PxSelect.KeyLen;
          Else;
            PrmRcd.RelOpr = *Blanks;
            PrmRcd.KeyVal = *Blanks;
            PrmRcd.KeyLen = *Zero;
          EndIf;

          PrmRcd.NbrElm = PxSelect.NbrElm;

          If  PxLstSeq = TYP_DTAQ;

            If  RDQD0100.Seq = SEQ_KEYED;
              PrmRcd.LstSeq = SEQ_KEYED;
              PrmRcd.NbrElm = 3;
              PrmRcd.RelOpr = 'GE';
              PrmRcd.KeyVal = *Allx'00';
              PrmRcd.KeyLen = RDQD0100.KeyLen;

            Else;
              PrmRcd.LstSeq = SEQ_Q_DFN;
            EndIf;

          Else;
            PrmRcd.LstSeq = PxLstSeq;
          EndIf;

          If  RDQD0100.MsgLen <= %Size( LstEnt.DtqEnt );
            PrmRcd.AuxStg = 'N';
          Else;
            PrmRcd.AuxStg = 'Y';
            PrmRcd.StgLib = 'QTEMP';
            PrmRcd.StgNam = PgmSts.AppPfx +
                            %EditC( %Dec( GetInvLvl(): 4: 0 ): 'X' );
          EndIf;


          PutDlgVar( UIM.AppHdl: PrmRcd: %Size( PrmRcd ): 'PRMRCD': ERRC0100 );
          PutDlgVar( UIM.AppHdl: ExpRcd: %Size( ExpRcd ): 'EXPRCD': ERRC0100 );

          If  PrmRcd.AuxStg = 'Y';
            CrtStgDtq( PrmRcd.StgNam: PrmRcd.StgLib: %Char( RDQD0100.MsgLen ));
          EndIf;

        EndSr;

        BegSr  EscApiErr;

          If  ERRC0100.BytAvl < OFS_MSGDTA;
            ERRC0100.BytAvl = OFS_MSGDTA;
          EndIf;

          SndEscMsg( ERRC0100.MsgId
                   : 'QCPFMSG'
                   : %Subst( ERRC0100.MsgDta: 1: ERRC0100.BytAvl - OFS_MSGDTA )
                   );

        EndSr;

      /End-Free

     **-- Get invocation level:
     P GetInvLvl       B
     D                 Pi            10i 0
     **
     D CSTK0100        Ds                  Qualified
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  NbrStkE                      10i 0
     **
     D JobId           Ds                  Qualified
     D  JobNam                       10a   Inz( '*' )
     D  UsrNam                       10a
     D  JobNbr                        6a
     D  IntId                        16a
     D  Rsv                           2a   Inz( *Allx'00' )
     D  ThrInd                       10i 0 Inz( 1 )
     D  ThrId                         8a   Inz( *Allx'00' )
     **
     D CUR_INVLVL      c                   1

      /Free

        CallP  RtvCalStk( CSTK0100
                        : %Size( CSTK0100 )
                        : 'CSTK0100'
                        : JobId
                        : 'JIDF0100'
                        : ERRC0100
                        );

        If  ERRC0100.BytAvl > *Zero;
          Return  0;
        Else;
          Return  CSTK0100.NbrStkE - CUR_INVLVL;
        EndIf;

      /End-Free

     P GetInvLvl       E
     **-- Create storage data queue:
     P CrtStgDtq       B
     D                 Pi
     D  PxDtqNam                     10a   Const  Varying  Options( *Trim )
     D  PxDtqLib                     10a   Const  Varying  Options( *Trim )
     D  PxMsgLen                     10a   Const  Varying  Options( *Trim )

      /Free

        RunCmd( 'CRTDTAQ DTAQ(' + PxDtqLib   + '/' +
                                  PxDtqNam   + ')' +
                       ' TYPE(*STD)'               +
                       ' MAXLEN(' + PxMsgLen + ')' +
                       ' FORCE(*NO)'               +
                       ' SEQ(*KEYED)'              +
                       ' KEYLEN(10)'               +
                       ' SENDERID(*NO)'            +
                       ' SIZE(*MAX2GB 256)'        +
                       ' AUTORCL(*NO)'
              );

        Return;

      /End-Free

     P CrtStgDtq       E
     **-- Run command:
     P RunCmd          B
     D                 Pi            10i 0
     D  PxCmdStr                   4096a   Const  Varying

     **-- Message information structure:
     D RCVM0100        Ds                  Qualified
     D  BytPrv                       10i 0
     D  BytAvl                       10i 0
     D  MsgSev                       10i 0
     D  MsgId                         7a
     D  MsgTyp                        2a
     D  MsgKey                        4a

      /Free

        Monitor;
          ExcCmd( PxCmdStr: %Len( PxCmdStr ));

        On-Error;
          Return -1;
        EndMon;

        RcvPgmMsg( RCVM0100
                 : %Size( RCVM0100 )
                 : 'RCVM0100'
                 : '*'
                 : *Zero
                 : '*LAST'
                 : *Blanks
                 : *Zero
                 : '*REMOVE'
                 : ERRC0100
                 );

        Return *Zero;

      /End-Free

     P RunCmd          E
     **-- Send escape message:
     P SndEscMsg       B
     D                 Pi            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgF                       10a   Const
     D  PxMsgDta                    512a   Const  Varying
     **
     D MsgKey          s              4a

      /Free

        SndPgmMsg( PxMsgId
                 : PxMsgF + '*LIBL'
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : '*ESCAPE'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          Return  -1;

        Else;
          Return   0;
        EndIf;

      /End-Free

     P SndEscMsg       E
