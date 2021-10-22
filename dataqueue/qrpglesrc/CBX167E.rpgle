     **
     **  Program . . : CBX167E
     **  Description : Display Data Queue Entries - UIM Exit Program
     **  Author  . . : Carsten Flensburg
     **  Published . : System iNetwork Programming Tips Newsletter
     **  Date  . . . : January 18, 2007
     **
     **
     **
     **  Compile options:
     **    CrtRpgMod  Module( CBX167E )
     **               DbgView( *LIST )
     **
     **    CrtPgm     Pgm( CBX167E )
     **               Module( CBX167E )
     **               ActGrp( *CALLER )
     **
     **
     **-- Control specification:  --------------------------------------------**
     H Option( *SrcStmt )  BndDir( 'QC2LE' )

     **-- API error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPrv                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      512a

     **-- Global constants:
     D QTE             c                   ''''
     D NULL            c                   ''
     D NO_ENT          c                   x'00000000'
     D NO_WAIT         c                   0
     **-- Global variables:
     D StrOfs          s             10i 0
     D StrLen          s             10i 0
     D StrDta          s             64a   Varying
     D HexDta          s            128a
     D EntDta          s          65535a

     **-- UIM constants:
     D PNLGRP2         c                   'CBX167P2  '
     D RDS_OPT_INZ     c                   'N'
     D POS_BOT         c                   'BOT'
     D LIST_COMP       c                   'ALL'
     D EXIT_SAME       c                   '*SAME'
     D TRIM_SAME       c                   'S'
     D INC_EXP         c                   'Y'
     D CPY_VAR         c                   'Y'
     D CPY_VAR_NO      c                   'N'
     **-- UIM variables:
     D UIM             Ds                  Qualified
     D  LstHdl                        4a
     D  EntHdl                        4a
     D  EntLocOpt                     4a
     D  FncRqs                       10i 0 Inz
     **-- UIM constants:
     D APP_PRTF        c                   'QPRINT    *LIBL'
     D ODP_SHR         c                   'N'
     D SPLF_NAM        c                   'PLSTJOBS'
     D SPLF_USRDTA     c                   'WRKJOBS'
     D EJECT_NO        c                   'N'
     D CLO_NRM         c                   'M'
     D RES_OK          c                   0
     D RES_ERR         c                   1

     **-- UIM API return structures:
     **-- Cursor record:
     D CsrRcd          Ds                  Qualified
     D  CsrEid                        4a
     D  CsrVar                       10a
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
     **-- UIM Panel header record:
     D HdrRcd2         Ds                  Qualified  Inz
     D  DspTyp                        1a
     D  EntId                        10i 0
     D  EntLen                       10i 0
     D  KeyLen                       10i 0
     **-- UIM List entry 2:
     D LstEnt2         Ds                  Qualified
     D  ChrOfs                        5i 0
     D  HexOfs                        5i 0
     D  ChrDta                       66a
     D  HexDta                       66a

     **-- UIM exit program interfaces:
     **-- Parm interface:
     D UimExit         Ds            70    Qualified
     D  StcLvl                       10i 0
     D                                8a
     D  TypCall                      10i 0
     D  AppHdl                        8a
     **-- Action list option/Pull-down field choice - call (type 3/9):
     D Type3           Ds                  Qualified
     D  StcLvl                       10i 0
     D                                8a
     D  TypCall                      10i 0
     D  AppHdl                        8a
     D  PnlNam                       10a
     D  LstNam                       10a
     D  LstEntHdl                     4a
     D  OptNbr                       10i 0
     D  FncQlf                       10i 0
     D  PdwFldNam                    10a

     **-- Add list entry:
     D AddLstEnt       Pr                  ExtPgm( 'QUIADDLE' )
     D  AppHdl                        8a   Const
     D  VarBuf                    32767a   Const  Options( *VarSize )
     D  VarBufLen                    10i 0 Const
     D  VarRcdNam                    10a   Const
     D  LstNam                       10a   Const
     D  EntLocOpt                     4a   Const
     D  LstEntHdl                     4a
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
     **-- Delete list:
     D DltLst          Pr                  ExtPgm( 'QUIDLTL' )
     D  AppHdl                        8a   Const
     D  LstNam                       10a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Get dialog variable:
     D GetDlgVar       Pr                  ExtPgm( 'QUIGETV' )
     D  AppHdl                        8a   Const
     D  VarBuf                    32767a          Options( *VarSize )
     D  VarBufLen                    10i 0 Const
     D  VarRcdNam                    10a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Put dialog variable:
     D PutDlgVar       Pr                  ExtPgm( 'QUIPUTV' )
     D  AppHdl                        8a   Const
     D  VarBuf                    32767a   Const  Options( *VarSize )
     D  VarBufLen                    10i 0 Const
     D  VarRcdNam                    10a   Const
     D  Error                     32767a          Options( *VarSize )
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

     **-- Receive data queue entry:
     D RcvDtaQe        Pr                  ExtPgm( 'QRCVDTAQ' )
     D  DtqNam                       10a   Const
     D  DtqLib                       10a   Const
     D  DtaLen                        5p 0
     D  Dta                       32767a          Options( *VarSize )
     D  Wait                          5p 0 Const
     D  KeyOrder                      2a   Const  Options( *NoPass )
     D  KeyLen                        3p 0 Const  Options( *NoPass )
     D  Key                         256a   Const  Options( *VarSize: *NoPass )
     D  SndInLg                       3p 0 Const  Options( *NoPass)
     D  SndInfo                      44a          Options( *VarSize: *Nopass )
     D  RmvMsg                       10a   Const  Options( *Nopass )
     D  DtaRcvLen                     5p 0 Const  Options( *Nopass )
     D  Error                     32767a          Options( *VarSize: *Nopass )
     **-- Convert hex to character:
     D cvthc           Pr                  ExtProc( 'cvthc' )
     D  RcvHex                         *   Value
     D  SrcChr                         *   Value
     D  RcvLen                       10i 0 Value

     **-- Convert character to hex nibbles:
     D CvtToHex        Pr           512a   Varying
     D  PxHexStr                    256a   Varying  Const
     **-- Append nibble 2:
     D AppNib2         Pr           128a   Varying
     D  PxHexStr                    128a   Varying  Const
     **-- Get storage entry:
     D GetStgEnt       Pr         65535a   Varying
     D  PxStgKey                    256a   Const  Varying

     **-- Entry parameters:
     D CBX167E         Pr
     D  PxUimExit                          LikeDs( UimExit )
     **
     D CBX167E         Pi
     D  PxUimExit                          LikeDs( UimExit )

      /Free

          Select;
          When  PxUimExit.TypCall = 3;
            Type3 = PxUimExit;

            Select;
            When  Type3.OptNbr = 5;
              ExSr  DspEntDta;

            When  Type3.OptNbr = 6;
              ExSr  DspEntKey;
            EndSl;
          EndSl;

        Return;


        BegSr  DspEntDta;

          GetDlgVar( Type3.AppHdl
                   : PrmRcd
                   : %Size( PrmRcd )
                   : 'PRMRCD'
                   : ERRC0100
                   );

          GetLstEnt( Type3.AppHdl
                   : LstEnt
                   : %Size( LstEnt )
                   : 'DTLRCD'
                   : Type3.LstNam
                   : 'HNDL'
                   : 'Y'
                   : *Blanks
                   : Type3.LstEntHdl
                   : 'N'
                   : UIM.EntHdl
                   : ERRC0100
                   );

          HdrRcd2.DspTyp = 'E';
          HdrRcd2.EntId  = LstEnt.EntId;
          HdrRcd2.EntLen = LstEnt.EntLen;
          HdrRcd2.KeyLen = LstEnt.KeyLen;

          PutDlgVar( Type3.AppHdl
                   : HdrRcd2
                   : %Size( HdrRcd2 )
                   : 'HDRRCD2'
                   : ERRC0100
                   );

          If  PrmRcd.AuxStg = 'Y';
            EntDta = GetStgEnt( %EditC( LstEnt.EntId: 'X' ));
          Else;
            EntDta = LstEnt.DtqEnt;
          EndIf;

          ExSr  BldEntLst;

          DspPnl( Type3.AppHdl: UIM.FncRqs: PNLGRP2: RDS_OPT_INZ: ERRC0100 );

          DltLst( Type3.AppHdl: 'DTALST': ERRC0100 );

        EndSr;

        BegSr  BldEntLst;

          UIM.EntLocOpt = 'FRST';

          StrOfs = 1;
          StrLen = %Size( LstEnt2.ChrDta ) - 2;

          DoU  StrOfs > HdrRcd2.EntLen;

            LstEnt2.ChrOfs = StrOfs;
            LstEnt2.HexOfs = StrOfs;

            If  StrLen > (LstEnt.EntLen - StrOfs) + 1;
              StrLen = (LstEnt.EntLen - StrOfs) + 1;
            EndIf;

            StrDta = %Subst( EntDta: StrOfs: StrLen );
            HexDta = AppNib2( CvtToHex( StrDta ));

            ExSr  PutLstEnts;

            StrOfs += StrLen;
          EndDo;

        EndSr;

        BegSr  DspEntKey;

          GetLstEnt( Type3.AppHdl
                   : LstEnt
                   : %Size( LstEnt )
                   : 'DTLRCD'
                   : Type3.LstNam
                   : 'HNDL'
                   : 'Y'
                   : *Blanks
                   : Type3.LstEntHdl
                   : 'N'
                   : UIM.EntHdl
                   : ERRC0100
                   );

          HdrRcd2.DspTyp = 'K';
          HdrRcd2.EntId  = LstEnt.EntId;
          HdrRcd2.EntLen = LstEnt.EntLen;
          HdrRcd2.KeyLen = LstEnt.KeyLen;

          PutDlgVar( Type3.AppHdl
                   : HdrRcd2
                   : %Size( HdrRcd2 )
                   : 'HDRRCD2'
                   : ERRC0100
                   );

          ExSr  BldKeyLst;

          DspPnl( Type3.AppHdl: UIM.FncRqs: PNLGRP2: RDS_OPT_INZ: ERRC0100 );

          DltLst( Type3.AppHdl: 'DTALST': ERRC0100 );

        EndSr;

        BegSr  BldKeyLst;

          UIM.EntLocOpt = 'FRST';

          StrOfs = 1;
          StrLen = %Size( LstEnt2.ChrDta ) - 2;

          DoU  StrOfs > HdrRcd2.KeyLen;

            LstEnt2.ChrOfs = StrOfs;
            LstEnt2.HexOfs = StrOfs;

            If  StrLen > (LstEnt.KeyLen - StrOfs) + 1;
              StrLen = (LstEnt.KeyLen - StrOfs) + 1;
            EndIf;

            StrDta = %Subst( LstEnt.DtqKey: StrOfs: StrLen );
            HexDta = AppNib2( CvtToHex( StrDta ));

            ExSr  PutLstEnts;

            StrOfs += StrLen;
          EndDo;

        EndSr;

        BegSr  PutLstEnts;

          LstEnt2.ChrDta = QTE + StrDta + QTE;
          LstEnt2.HexDta = QTE + %TrimR( %Subst( HexDta: 1: 64 )) + QTE;

          AddLstEnt( Type3.AppHdl
                   : LstEnt2
                   : %Size( LstEnt2 )
                   : 'DTARCD'
                   : 'DTALST'
                   : UIM.EntLocOpt
                   : UIM.LstHdl
                   : ERRC0100
                   );

          UIM.EntLocOpt = 'NEXT';

          If  %Subst( HexDta: 65 ) > *Blanks;

            LstEnt2.ChrOfs = *Zero;
            LstEnt2.HexOfs = *Zero;
            LstEnt2.ChrDta = *Blanks;
            LstEnt2.HexDta = QTE + %TrimR( %Subst( HexDta: 65 )) + QTE;

            AddLstEnt( Type3.AppHdl
                     : LstEnt2
                     : %Size( LstEnt2 )
                     : 'DTARCD'
                     : 'DTALST'
                     : UIM.EntLocOpt
                     : UIM.LstHdl
                     : ERRC0100
                     );

          EndIf;

        EndSr;

      /End-Free

     **-- Convert character to hex nibbles:
     P CvtToHex        B
     D                 Pi           512a   Varying
     D  PxChrStr                    256a   Varying  Const

     **-- Local declarations
     D ChrStr          s            256a
     D HexStr          s            512a

      /Free

        ChrStr = PxChrStr;

        cvthc( %Addr( HexStr ): %Addr( ChrStr ): %Len( PxChrStr ) * 2 );

        Return  %Subst( HexStr: 1: %Int( %Len( PxChrStr ) * 2 ));

      /End-Free

     P CvtToHex        E
     **-- Append nibble 2:
     P AppNib2         B
     D                 Pi           128a   Varying
     D  PxHexStr                    128a   Varying  Const

     **-- Local declarations:
     D ChrSiz          c                   64
     **
     D CvtStr          Ds                  Qualified
     D  Str1                          2a   Dim( ChrSiz )
     D   Sub1                         1a   Overlay( Str1: 1 )
     D   Sub2                         1a   Overlay( Str1: 2 )
     **
     D Str1            Ds                  Qualified
     D   Sub1                         1a   Dim( ChrSiz )
     **
     D Str2            Ds                  Qualified
     D   Sub2                         1a   Dim( ChrSiz )

      /Free

        CvtStr = PxHexStr;

        Str1.Sub1 = CvtStr.Sub1;
        Str2.Sub2 = CvtStr.Sub2;

        Return  Str1 + Str2;

      /End-Free

     P AppNib2         E
     **-- Get storage entry:
     P GetStgEnt       B
     D                 Pi         65535a   Varying
     D  PxStgKey                    256a   Const  Varying

     D DtaLen          s              5p 0
     D DtaRcv          s          65535a
     D SndInfo         s             36a

      /Free

        RcvDtaQe( PrmRcd.StgNam
                : PrmRcd.StgLib
                : DtaLen
                : DtaRcv
                : NO_WAIT
                : 'EQ'
                : %Len( PxStgKey )
                : PxStgKey
                : *Zero
                : SndInfo
                : '*NO'
                : %Size( DtaRcv )
                : ERRC0100
                );

        Return  %Subst( DtaRcv: 1: DtaLen );

      /End-Free

     P GetStgEnt       E
