     **
     **  Program . . : CBX165
     **  Description : Display Data Queue Description - CPP
     **  Author  . . : Carsten Flensburg
     **  Published . : System iNetwork Programming Tips Newsletter
     **  Date  . . . : November 16, 2006
     **
     **
     **  Programmer's notes:
     **
     **
     **  Compile options:
     **    CrtRpgMod  Module( CBX165 )
     **               DbgView( *LIST )
     **
     **    CrtPgm     Pgm( CBX165 )
     **               Module( CBX165 )
     **               ActGrp( *NEW )
     **
     **
     **-- Header specifications:  --------------------------------------------**
     H Option( *SrcStmt )

     **-- Api error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPro                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0 Inz
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      512a
     **-- Call stack entry id:
     D ToCalStkE       Ds                  Qualified
     D  ToCalStkCnt                  10i 0 Inz( 1 )
     D  ToCalStkEq                   20a   Inz( '*NONE     *NONE' )
     D  ToCalStkIdLen                10i 0 Inz( %Size( ToCalStkE.ToCalStkId ))
     D  ToCalStkId                   10a   Inz( '*PGMBDY' )

     **-- Global constants:
     D OFS_MSGDTA      c                   16
     D DTAQ_STD        c                   '0'
     D DTAQ_DDM        c                   '1'
     **-- UIM constants:
     D PNLGRP_Q        c                   'CBX165P   *LIBL     '
     D PNLGRP          c                   'CBX165P   '
     D SCP_AUT_RCL     c                   -1
     D RDS_OPT_YES     c                   'Y'
     D PRM_IFC_0       c                   0
     D CLO_NORM        c                   'M'
     D FNC_EXIT        c                   -4
     D FNC_CNL         c                   -8
     D KEY_F05         c                   5
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
     **
     D APP_PRTF        c                   'QPRINT    *LIBL'
     D ODP_SHR         c                   'N'
     D SPLF_NAM        c                   'PDSPDTAQ'
     D SPLF_USRDTA     c                   'DSPDTAQ'
     D EJECT_NO        c                   'N'
     **-- Global variables:
     D Idx             s             10i 0
     D SysDts          s               z

     **-- UIM variables:
     D UIM             Ds                  Qualified
     D  AppHdl                        8a
     D  FncRqs                       10i 0 Inz
     **-- UIM Panel header record:
     D HdrRcd          Ds                  Qualified  Inz
     D  SysDat                        7a
     D  SysTim                        6a
     D  TimZon                       10a
     D  DtaQ_Nam                     10a
     D  DtaQ_Lib                     10a
     D  DtaQ_Typ                      1a
     **-- UIM Detail record:
     D DtlRcd          Ds                  Qualified
     D  MsgLen                        5s 0
     D  Force                         1a
     D  Seq                           1a
     D  KeyLen                        3s 0
     D  IncSndId                      1a
     D  MaxEntNbr                    10s 0
     D  InlEntNbr                    10s 0
     D  CurEntNbr                    10s 0
     D  CurEntAlc                    10s 0
     D  MaxEntAlw                    10s 0
     D  AutRcl                        1a
     D  EnfDtqLck                     1a
     D  RmtDtaQ_Nam                  10a
     D  RmtDtaQ_Lib                  10a
     D  RmtLocNam                     8a
     D  RdbNam                       18a
     D  AppcDevD                     10a
     D  LclLocNam                     8a
     D  Mode                          8a
     D  RmtNetId                      8a
     D  TxtDsc                       50a
     D  RclDts                       26a

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
     D  EnfDtqLck                     1a
     D  NbrCurMsg                    10i 0
     D  NbrMsgAlc                    10i 0
     D  DtaQ_Nam                     10a
     D  DtaQ_Lib                     10a
     D  MaxMsgAlw                    10i 0
     D  InlNbrMsg                    10i 0
     D  DtaQ_Size                    10i 0
     D  RclDts                        8a
     **-- RDQD0200 format:
     D RDQD0200        Ds                  Qualified
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  AppcDevD                     10a
     D  Mode                          8a
     D  RmtLocNam                     8a
     D  LclLocNam                     8a
     D  RmtNetId                      8a
     D  RmtDtaQ_Nam                  10a
     D  RmtDtaQ_Lib                  10a
     D  DtaQ_Name                    10a
     D  DtaQ_Lib                     10a
     D  RdbNam                       18a

     **-- Retrieve data queue description:
     D RtvDtqDsc       Pr                  ExtPgm( 'QMHQRDQD' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                       10a   Const
     D  DtaQ_q                       20a   Const
     **-- Retrieve job information:
     D RtvJobInf       Pr                  ExtPgm( 'QUSRJOBI' )
     D  RcvVar                    32767a         Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                        8a   Const
     D  JobNamQ                      26a   Const
     D  JobIntId                     16a   Const
     D  Error                     32767a         Options( *NoPass: *VarSize )
     **-- Convert date & time:
     D CvtDtf          Pr                  ExtPgm( 'QWCCVTDT' )
     D  InpFmt                       10a   Const
     D  InpVar                       17a   Const  Options( *VarSize )
     D  OutFmt                       10a   Const  Options( *VarSize )
     D  OutVar                       17a   Const  Options( *VarSize )
     D  Error                     32767a          Options( *VarSize )
     D  InpTimZon                    10a   Const  Options( *NoPass )
     D  OutTimZon                    10a   Const  Options( *NoPass )
     D  TimZonInf                   111a          Options( *VarSize: *NoPass )
     D  TimZonInfLen                 10i 0 Const  Options( *NoPass )
     D  PrcInd                        1a   Const  Options( *NoPass )
     D  InpTimInd                     1a   Const  Options( *NoPass )
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
     **-- Move program messages:
     D MovPgmMsg       Pr                  ExtPgm( 'QMHMOVPM' )
     D  MsgKey                        4a   Const
     D  MsgTyps                      10a   Const  Options( *VarSize )  Dim( 4 )
     D  NbrMsgTyps                   10i 0 Const
     D  ToCalStkE                  4102a   Const  Options( *VarSize )
     D  ToCalStkCnt                  10i 0 Const
     D  Error                     32767a          Options( *VarSize )
     D  ToCalStkLen                  10i 0 Const  Options( *NoPass )
     D  ToCalStkEq                   20a   Const  Options( *NoPass )
     D  ToCalStkEdt                  10a   Const  Options( *NoPass )
     D  FrCalStkEad                    *   Const  Options( *NoPass )
     D  FrCalStkCnt                  10i 0 Const  Options( *NoPass )
     **-- Resend escape messages:
     D RsnEscMsg       Pr                  ExtPgm( 'QMHRSNEM' )
     D  MsgKey                        4a   Const
     D  Error                     32767a          Options( *VarSize )
     D  ToCalStkEnt                5120a   Const  Options( *VarSize )
     D  ToCalStkEntLn                10i 0 Const
     D  ToCalStkFmt                   8a   Const
     D  ToCalStkAdr                  16a   Const
     D  ToCalStkCnt                  10i 0 Const
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
     **-- Open print application:
     D OpnPrtApp       Pr                  ExtPgm( 'QUIOPNPA' )
     D  AppHdl                        8a
     D  PnlGrp_q                     20a   Const
     D  AppScp                       10i 0 Const
     D  ExtPrmIfc                    10i 0 Const
     D  PrtDevF_q                    20a   Const
     D  AltFilNam                    10a   Const
     D  ShrOpnDtaPth                  1a   Const
     D  UsrDta                       10a   Const
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
     **-- Print panel:
     D PrtPnl          Pr                  ExtPgm( 'QUIPRTP' )
     D  AppHdl                        8a   Const
     D  PrtPnlNam                    10a   Const
     D  EjtOpt                        1a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Put dialog variable:
     D PutDlgVar       Pr                  ExtPgm( 'QUIPUTV' )
     D  AppHdl                        8a   Const
     D  VarBuf                    32767a   Const  Options( *VarSize )
     D  VarBufLen                    10i 0 Const
     D  VarRcdNam                    10a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Close application:
     D CloApp          Pr                  ExtPgm( 'QUICLOA' )
     D  AppHdl                        8a   Const
     D  CloOpt                        1a   Const
     D  Error                     32767a          Options( *VarSize )

     **-- Get job type:
     D GetJobTyp       Pr             1a
     **-- Convert system timestamp:
     D CvtSysDts       Pr              z
     D  PxSysDts                      8a   Const
     **-- Send escape message:
     D SndEscMsg       Pr            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgF                       10a   Const
     D  PxMsgDta                    512a   Const  Varying
     **-- Send completion message:
     D SndCmpMsg       Pr            10i 0
     D  PxMsgDta                    512a   Const  Varying

     **-- Program entry:
     D CBX165          Pr
     D  PxDtaQ_q                     20a
     D  PxOutOpt                      3a
     **
     D CBX165          Pi
     D  PxDtaQ_q                     20a
     D  PxOutOpt                      3a

      /Free

        If  PxOutOpt = 'DSP'  And  GetJobTyp() = 'I';

          OpnDspApp( UIM.AppHdl
                   : PNLGRP_Q
                   : SCP_AUT_RCL
                   : PRM_IFC_0
                   : HLP_WDW
                   : ERRC0100
                   );
        Else;
          OpnPrtApp( UIM.AppHdl
                   : PNLGRP_Q
                   : SCP_AUT_RCL
                   : PRM_IFC_0
                   : APP_PRTF
                   : SPLF_NAM
                   : ODP_SHR
                   : SPLF_USRDTA
                   : ERRC0100
                   );
        EndIf;

        If  ERRC0100.BytAvl > *Zero;
          ExSr  EscApiErr;
        EndIf;

        ExSr  BldDtqDsp;
        ExSr  BldHdrRcd;

        If  PxOutOpt = 'DSP'  And  GetJobTyp() = 'I';
          ExSr  DspLst;
        Else;
          ExSr  WrtLst;
        EndIf;

        CloApp( UIM.AppHdl: CLO_NORM: ERRC0100 );

        *InLr = *On;
        Return;


        BegSr  BldDtqDsp;

          RtvDtqDsc( RDQD0100
                   : %Size( RDQD0100 )
                   : 'RDQD0100'
                   : PxDtaQ_q
                   );

          If  RDQD0100.Type = DTAQ_DDM;

            RtvDtqDsc( RDQD0200
                     : %Size( RDQD0200 )
                     : 'RDQD0200'
                     : PxDtaQ_q
                     );

          Else;
            Clear  RDQD0200;
          EndIf;

          ExSr  PutDtlRcd;

        EndSr;

        BegSr  PutDtlRcd;

          DtlRcd.MsgLen      = RDQD0100.MsgLen;
          DtlRcd.Force       = RDQD0100.FrcInd;
          DtlRcd.Seq         = RDQD0100.Seq;
          DtlRcd.KeyLen      = RDQD0100.KeyLen;
          DtlRcd.IncSndId    = RDQD0100.IncSndId;
          DtlRcd.MaxEntNbr   = RDQD0100.DtaQ_Size;
          DtlRcd.InlEntNbr   = RDQD0100.InlNbrMsg;
          DtlRcd.CurEntNbr   = RDQD0100.NbrCurMsg;
          DtlRcd.CurEntAlc   = RDQD0100.NbrMsgAlc;
          DtlRcd.MaxEntAlw   = RDQD0100.MaxMsgAlw;
          DtlRcd.AutRcl      = RDQD0100.AutRcl;
          DtlRcd.EnfDtqLck   = RDQD0100.EnfDtqLck;
          DtlRcd.RmtDtaQ_Nam = RDQD0200.RmtDtaQ_Nam;
          DtlRcd.RmtDtaQ_Lib = RDQD0200.RmtDtaQ_Lib;
          DtlRcd.RmtLocNam   = RDQD0200.RmtLocNam;
          DtlRcd.RdbNam      = RDQD0200.RdbNam;
          DtlRcd.AppcDevD    = RDQD0200.AppcDevD;
          DtlRcd.LclLocNam   = RDQD0200.LclLocNam;
          DtlRcd.Mode        = RDQD0200.Mode;
          DtlRcd.RmtNetId    = RDQD0200.RmtNetId;
          DtlRcd.TxtDsc      = RDQD0100.TxtDsc;

          If  RDQD0100.RclDts = *Allx'00'  Or  RDQD0100.RclDts = *Allx'40';
            DtlRcd.RclDts    = *Blanks;
          Else;
            DtlRcd.RclDts    = %Char( CvtSysDts( RDQD0100.RclDts ));
          EndIf;

          PutDlgVar( UIM.AppHdl: DtlRcd: %Size( DtlRcd ): 'DTLRCD': ERRC0100 );

        EndSr;

        BegSr  DspLst;

          DoU  UIM.FncRqs = FNC_EXIT  Or  UIM.FncRqs = FNC_CNL;

            DspPnl( UIM.AppHdl: UIM.FncRqs: PNLGRP: RDS_OPT_YES: ERRC0100 );

            Select;
            When  ERRC0100.BytAvl > *Zero;
              ExSr  EscApiErr;

            When  UIM.FncRqs = RTN_ENTER;
              Leave;

            When  UIM.FncRqs = KEY_F05;
              ExSr  BldDtqDsp;
            EndSl;

            ExSr  BldHdrRcd;
          EndDo;

        EndSr;

        BegSr  WrtLst;

          PrtPnl( UIM.AppHdl
                : 'PRTHDR'
                : EJECT_NO
                : ERRC0100
                );

          PrtPnl( UIM.AppHdl
                : 'PRTDTL'
                : EJECT_NO
                : ERRC0100
                );

          SndCmpMsg( 'List has been printed.' );

        EndSr;

        BegSr  BldHdrRcd;

          SysDts = %Timestamp();

          HdrRcd.SysDat = %Char( %Date( SysDts ): *CYMD0 );
          HdrRcd.SysTim = %Char( %Time( SysDts ): *HMS0 );
          HdrRcd.TimZon = '*SYS';

          HdrRcd.DtaQ_Nam = RDQD0100.DtaQ_Nam;
          HdrRcd.DtaQ_Lib = RDQD0100.DtaQ_Lib;
          HdrRcd.DtaQ_Typ = RDQD0100.Type;

          PutDlgVar( UIM.AppHdl: HdrRcd: %Size( HdrRcd ): 'HDRRCD': ERRC0100 );

        EndSr;

        BegSr  *PsSr;

          If  Not *InLr;
            *InLr = *On;

            MovPgmMsg( *Blanks
                     : '*DIAG'
                     : 1
                     : '*PGMBDY'
                     : 1
                     : ERRC0100
                     );

            RsnEscMsg( *Blanks
                     : ERRC0100
                     : ToCalStkE
                     : %Size( ToCalStkE )
                     : 'RSNM0100'
                     : '*'
                     : *Zero
                     );

            Return;
          EndIf;

        EndSr  '*CANCL';

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

     **-- Get job type:
     P GetJobTyp       B
     D                 Pi             1a

     D JOBI0400        Ds                  Qualified
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  JobNam                       10a
     D  UsrNam                       10a
     D  JobNbr                        6a
     D  JobIntId                     16a
     D  JobSts                       10a
     D  JobTyp                        1a
     D  JobSubTyp                     1a

      /Free

        RtvJobInf( JOBI0400
                 : %Size( JOBI0400 )
                 : 'JOBI0400'
                 : '*'
                 : *Blank
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          Return  *Blank;

        Else;
          Return  JOBI0400.JobTyp;
        EndIf;

      /End-Free

     P GetJobTyp       E
     **-- Convert system timestamp:
     P CvtSysDts       B                   Export
     D                 Pi              z
     D  PxSysDts                      8a   Const

     **-- Local constants:
     D MIC_SEC         c                   '1'
     **
     D TimZonInf       Ds                  Qualified
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  TimZonNam                    10a
     D                                1a
     D  CurDstInd                     1a
     D  CurUtcOfs                    10i 0
     D  CurZonNam                    50a
     D  CurAbvNam                    10a
     D  CurMsgId                      7a
     D  CurMsgF                      10a
     D  CurMsgFlib                   10a
     **
     D SysDts          Ds            20    Qualified
     D  Date                          8s 0
     D  Time                          6s 0
     D  Msec                          6s 0

      /Free

        CvtDtf( '*DTS'
              : PxSysDts
              : '*YYMD'
              : SysDts
              : ERRC0100
              : '*UTC'
              : '*UTC'
              : TimZonInf
              : %Size( TimZonInf )
              : MIC_SEC
              );

        If  ERRC0100.BytAvl > *Zero;
          Return  *LoVal;

        Else;
          Return  %Date( SysDts.Date: *ISO ) +
                  %Time( SysDts.Time: *HMS ) +
                  %Mseconds( SysDts.Msec );
        EndIf;

      /End-Free

     P CvtSysDts       E
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
     **-- Send completion message:
     P SndCmpMsg       B
     D                 Pi            10i 0
     D  PxMsgDta                    512a   Const  Varying
     **
     D MsgKey          s              4a

      /Free

        SndPgmMsg( 'CPF9897'
                 : 'QCPFMSG   *LIBL'
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : '*COMP'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          Return  -1;

        Else;
          Return  0;

        EndIf;

      /End-Free

     **
     P SndCmpMsg       E
