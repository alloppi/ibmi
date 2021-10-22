     **
     **  Program . . : CBX167L
     **  Description : Display Data Queue Entries - UIM List Exit Program
     **  Author  . . : Carsten Flensburg
     **  Published . : System iNetwork Programming Tips Newsletter
     **  Date  . . . : January 18, 2007
     **
     **
     **
     **  Compile options:
     **    CrtRpgMod  Module( CBX167L )
     **               DbgView( *LIST )
     **
     **    CrtPgm     Pgm( CBX167L )
     **               Module( CBX167L )
     **               ActGrp( *CALLER )
     **
     **
     **-- Header specifications:  --------------------------------------------**
     H Option( *SrcStmt )

     **-- API error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPrv                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      128a

     **-- Global constants:
     D ALC_MAXBYT      c                   16776704
     D OFS_MSGDTA      c                   16
     D MIN_NBR_ENT     c                   34
     D DTAQ_STD        c                   '0'
     D DTAQ_DDM        c                   '1'
     D SEQ_KEY         c                   'K'
     D QUE_ORDER       c                   'A'
     **-- Global variables:
     D Idx             s             10i 0
     D RcvStgAlc       s             10i 0 Inz( *Zero )
     D RtnEntNbr       s             10i 0
     D CurEntNbr       s             10i 0
     D MsgEnqDts       s             19a   Inz( *All'0' )
     D DtqKey          s            256a   Varying
     D DtqMsg          s          65535a   Varying

     **-- UIM constants:
     D LIST_TOP        c                   'TOP'
     D LIST_BOT        c                   'BOT'
     D LIST_COMP       c                   'ALL'
     D LIST_SAME       c                   'SAME'
     D EXIT_SAME       c                   '*SAME'
     D TRIM_SAME       c                   'S'
     D POS_TOP         c                   'TOP'
     D POS_BOT         c                   'BOT'
     D POS_SAME        c                   'SAME'
     **-- UIM variables:
     D UIM             Ds                  Qualified
     D  AppHdl                        8a
     D  LstHdl                        4a
     D  EntHdl                        4a
     D  FncRqs                       10i 0
     D  EntLocOpt                     4a
     D  LstPos                        4a
     D  LstCnt                        4a

     **-- UIM exit program interfaces:
     **-- Incomplete list:
     D Type6           Ds                  Qualified
     D  StcLvl                       10i 0
     D                                8a
     D  TypCall                      10i 0
     D  AppHdl                        8a
     D                               10a
     D  LstNam                       10a
     D  IncLstDir                    10i 0
     D  NbrEntRqd                    10i 0

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
     **-- RDMQ0200 format:
     D RDQM0200        Ds                  Qualified  Based( pRDQM0200 )
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  MsgRtn                       10i 0
     D  MsgAvl                       10i 0
     D  KeyLenRtn                    10i 0
     D  KeyLenAvl                    10i 0
     D  TxtLenRtn                    10i 0
     D  TxtLenAvl                    10i 0
     D                                8a
     D  OfsMsgEnt                    10i 0
     D  DtqLibNam                    10a
     D  DtqEnts                   10240a
     **-- Entry format:
     D DtqEnt          Ds                  Qualified  Based( pDtqEnt )
     D  OfsNxtEnt                    10i 0
     D  MsgEnqTod                     8a
     D  MsgEnqLen                    10i 0
     D  MsgEnt                    65519a
     **-- RDQS0100 selection format:
     D RDQS0100        Ds                  Qualified
     D  SelTyp                        1a
     D                                3a
     D  MsgBytRtv                    10i 0
     **-- RDQS0200 selection format:
     D RDQS0200        Ds                  Qualified
     D  SelTyp                        1a   Inz( *Blank )
     D  KeySchOrd                     2a
     D                                1a
     D  MsgBytRtv                    10i 0
     D  KeyBytRtv                    10i 0
     D  KeyLen                       10i 0
     D  KeyVal                      256a
     **-- Sender information:              Qualified
     D SndInf          Ds
     D  BytRtn                        7p 0
     D  BytAvl                        7p 0
     D  JobNam                       10a
     D  UsrPrf                       10a
     D  JobNbr                        6a
     D  CurUsr                       10a

     **-- Convert date & time:
     D CvtDtf          Pr                  ExtPgm( 'QWCCVTDT' )
     D  InpFmt                       10a   Const
     D  InpVar                       17a   Const  Options( *VarSize )
     D  OutFmt                       10a   Const
     D  OutVar                       17a          Options( *VarSize )
     D  Error                        10i 0 Const
     **-- Retrieve data queue description:
     D RtvDtqDsc       Pr                  ExtPgm( 'QMHQRDQD' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                       10a   Const
     D  DtaQ_q                       20a   Const
     **-- Retrieve data queue message:
     D RtvDtqMsg       Pr                  ExtPgm( 'QMHRDQM' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                       10a   Const
     D  DtgQq                        20a   Const
     D  MsgSel                       10a   Const
     D  MsgSelLen                    10i 0 Const
     D  MsgSelFmt                     8a   Const
     D  Error                     32767a          Options( *NoPass: *VarSize)
     **-- Clear data queue:
     D ClrDtaQ         Pr                  ExtPgm( 'QCLRDTAQ' )
     D  DtqNam                       10a   Const
     D  DtqLib                       10a   Const
     D  KeyOrder                      2a   Const  Options( *NoPass )
     D  KeyLen                        3p 0 Const  Options( *NoPass )
     D  Key                         256a   Const  Options( *VarSize: *NoPass )
     D  Error                     32767a          Options( *VarSize: *Nopass )
     **-- Send data queue entry:
     D SndDtaQe        Pr                  ExtPgm( 'QSNDDTAQ' )
     D  DtqNam                       10a   Const
     D  DtqLib                       10a   Const
     D  DtaLen                        5p 0 Const
     D  Dta                       32767a   Const  Options( *VarSize )
     D  KeyLen                        3p 0 Const  Options( *NoPass )
     D  Key                         256a   Const  Options( *VarSize: *NoPass )
     D  AscRqs                       10a   Const  Options( *NoPass )
     D  JrnDta                       10a   Const  Options( *NoPass )

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
     **-- Register activation group exit:
     D CEE4RAGE        Pr                    ExtProc( 'CEE4RAGE' )
     D  procedure                      *     ProcPtr  Const
     D  fb                           12a     Options( *Omit )

     **-- Terminate activation group exit:
     D TrmActGrp       Pr
     D  ActGrpMrk                    10u 0
     D  Reason                       10u 0
     D  Gen_RC                       10u 0
     D  Usr_RC                       10u 0
     **-- Put storage entry:
     D PutStgEnt       Pr
     D  PxStgEnt                  65535a   Const  Varying
     D  PxStgKey                    256a   Const  Varying

     D CBX167L         Pr
     D  PxType6                            LikeDs( Type6 )
     **
     D CBX167L         Pi
     D  PxType6                            LikeDs( Type6 )

      /Free

        GetDlgVar( PxType6.AppHdl
                 : CtlRcd
                 : %Size( CtlRcd )
                 : 'CTLRCD'
                 : ERRC0100
                 );

        If  CtlRcd.Action = 'LIST'  Or  CtlRcd.Action = 'F05';
          ExSr  BldEntLst;
        EndIf;

        ExSr  PrcEntLst;

        CtlRcd.EntLocOpt = UIM.EntLocOpt;
        CtlRcd.Action = *Blanks;

        PutDlgVar( PxType6.AppHdl
                 : CtlRcd
                 : %Size( CtlRcd )
                 : 'CTLRCD'
                 : ERRC0100
                 );

        Return;


        BegSr  BldEntLst;

          PrmRcd.LstSts = 'C';

          If  PrmRcd.AuxStg = 'Y';
            ClrDtaQ( PrmRcd.StgNam: PrmRcd.StgLib );
          EndIf;

          UIM.EntLocOpt = 'FRST';

          If  RcvStgAlc = *Zero;
            RcvStgAlc = 65535;
            pRDQM0200 = %Alloc( RcvStgAlc );
            RDQM0200.BytAvl = *Zero;
          EndIf;

          DoU  RDQM0200.BytAvl <= RcvStgAlc  Or  ERRC0100.BytAvl > *Zero;

            If  RDQM0200.BytAvl > RcvStgAlc;

              If  RDQM0200.BytAvl > ALC_MAXBYT;
                RDQM0200.BytAvl = ALC_MAXBYT;
                PrmRcd.LstSts = 'I';
              EndIf;

              RcvStgAlc  = RDQM0200.BytAvl;
              pRDQM0200  = %ReAlloc( pRDQM0200: RcvStgAlc );
            EndIf;

            If  PrmRcd.LstSeq = SEQ_KEY  And  PrmRcd.NbrElm = 3;
              ExSr  RtvKeyDtq;
            Else;
              ExSr  RtvSeqDtq;
            EndIf;
          EndDo;

          If  ERRC0100.BytAvl > *Zero  Or  RDQM0200.MsgRtn = *Zero;
            RDQM0200.MsgRtn = -1;
          Else;

            pDtqEnt  =  %Addr( RDQM0200 ) + RDQM0200.OfsMsgEnt;
          EndIf;

          RtnEntNbr = *Zero;

        EndSr;

        BegSr  RtvKeyDtq;

          If  RDQD0100.IncSndId = 'Y';
            RDQS0200.MsgBytRtv = RDQD0100.MsgLen + %Size( SndInf );
          Else;
            RDQS0200.MsgBytRtv = RDQD0100.MsgLen;
          EndIf;

          RDQS0200.KeyBytRtv = RDQD0100.KeyLen;
          RDQS0200.SelTyp    = PrmRcd.LstSeq;
          RDQS0200.KeySchOrd = PrmRcd.RelOpr;
          RDQS0200.KeyVal    = PrmRcd.KeyVal;

          If  PrmRcd.KeyLen = *Zero;
            RDQS0200.KeyLen = RDQD0100.KeyLen;
          Else;
            RDQS0200.KeyLen = PrmRcd.KeyLen;
          EndIf;

          RtvDtqMsg( RDQM0200
                   : RcvStgAlc
                   : 'RDQM0200'
                   : PrmRcd.DtqNam + PrmRcd.DtqLib
                   : RDQS0200
                   : %Size( RDQS0200 )
                   : 'RDQS0200'
                   : ERRC0100
                   );

        EndSr;

        BegSr  RtvSeqDtq;

          If  RDQD0100.IncSndId = 'Y';
            RDQS0100.MsgBytRtv = RDQD0100.MsgLen + %Size( SndInf );
          Else;
            RDQS0100.MsgBytRtv = RDQD0100.MsgLen;
          EndIf;

          RDQS0100.SelTyp = PrmRcd.LstSeq;

          RtvDtqMsg( RDQM0200
                   : RcvStgAlc
                   : 'RDQM0200'
                   : PrmRcd.DtqNam + PrmRcd.DtqLib
                   : RDQS0100
                   : %Size( RDQS0100 )
                   : 'RDQS0100'
                   : ERRC0100
                   );

        EndSr;

        BegSr  PrcEntLst;

          If  RDQM0200.MsgRtn > *Zero;
            CurEntNbr = *Zero;

            DoW  RDQM0200.MsgRtn > RtnEntNbr;

              RtnEntNbr += 1;

              ExSr  PrcQueEnt;

              If  RtnEntNbr < RDQM0200.MsgRtn;
                pDtqEnt  =  %Addr( RDQM0200 ) + DtqEnt.OfsNxtEnt;
              EndIf;

              If  CurEntNbr >= MIN_NBR_ENT  And
                  CurEntNbr >= PxType6.NbrEntRqd;

                Leave;
              EndIf;
            EndDo;
          EndIf;

          Select;
          When  RDQM0200.MsgRtn = -1;
            UIM.LstCnt = LIST_COMP;

          When  RDQM0200.MsgRtn <= RtnEntNbr;
            UIM.LstCnt = LIST_COMP;

          Other;
            UIM.LstCnt = LIST_TOP;
          EndSl;

          SetLstAtr( PxType6.AppHdl
                   : 'DTLLST'
                   : UIM.LstCnt
                   : EXIT_SAME
                   : POS_SAME
                   : TRIM_SAME
                   : ERRC0100
                   );

        EndSr;

        BegSr  PrcQueEnt;

          CvtDtf( '*DTS': DtqEnt.MsgEnqTod: '*YMD': MsgEnqDts: 0 );

          DtqKey = %Subst( DtqEnt.MsgEnt: 1: RDQM0200.KeyLenRtn );

          If  RDQD0100.IncSndId = 'Y';
            SndInf = %Subst( DtqEnt.MsgEnt
                           : RDQM0200.KeyLenRtn + 1
                           : %Size( SndInf )
                           );

            DtqMsg = %Subst( DtqEnt.MsgEnt
                           : RDQM0200.KeyLenRtn + %Size( SndInf ) + 1
                           : DtqEnt.MsgEnqLen - %Size( SndInf )
                           );

          Else;
            SndInf = '*NONE';

            DtqMsg = %Subst( DtqEnt.MsgEnt
                           : RDQM0200.KeyLenRtn + 1
                           : DtqEnt.MsgEnqLen
                           );
          EndIf;

          ExSr  PutLstEnt;

        EndSr;

        BegSr  PutLstEnt;

          CurEntNbr += 1;

          LstEnt.Option = *Zero;
          LstEnt.EntId  = RtnEntNbr;

          LstEnt.SndInf = SndInf;
          LstEnt.EnqDat = %Subst( MsgEnqDts: 1: 7 );
          LstEnt.EnqTim = %Subst( MsgEnqDts: 8: 6 );
          LstEnt.EntLen = %Len( DtqMsg );
          LstEnt.KeyLen = %Len( DtqKey );

          LstEnt.DtqEnt = DtqMsg;
          LstEnt.DtqKey = DtqKey;

          If  RDQM0200.KeyLenRtn = *Zero  And  RDQM0200.KeyLenAvl > *Zero;
            LstEnt.DtqKey = '*IGNORED';
          EndIf;

          If  PrmRcd.AuxStg = 'Y';
            PutStgEnt( DtqMsg: %EditC( LstEnt.EntId: 'X' ));
          EndIf;

          AddLstEnt( PxType6.AppHdl
                   : LstEnt
                   : %Size( LstEnt )
                   : 'DTLRCD'
                   : 'DTLLST'
                   : UIM.EntLocOpt
                   : UIM.LstHdl
                   : ERRC0100
                   );

          UIM.EntLocOpt = 'NEXT';

        EndSr;

        BegSr  *InzSr;

          CEE4RAGE( %Paddr( TrmActGrp ): *Omit );

          GetDlgVar( PxType6.AppHdl
                   : PrmRcd
                   : %Size( PrmRcd )
                   : 'PRMRCD'
                   : ERRC0100
                   );

          RtvDtqDsc( RDQD0100
                   : %Size( RDQD0100 )
                   : 'RDQD0100'
                   : PrmRcd.DtqNam + PrmRcd.DtqLib
                   );

        EndSr;

      /End-Free

     **-- Terminate activation group exit:
     P TrmActGrp       B
     D                 Pi
     D  ActGrpMrk                    10u 0
     D  Reason                       10u 0
     D  Gen_RC                       10u 0
     D  Usr_RC                       10u 0

      /Free

        If  pRDQM0200 <> *Null;
          DeAlloc  pRDQM0200;
        EndIf;

        *InLr = *On;

        Return;

      /End-Free

     P TrmActGrp       E
     **-- Put storage entry:
     P PutStgEnt       B
     D                 Pi
     D  PxStgEnt                  65535a   Const  Varying
     D  PxStgKey                    256a   Const  Varying

      /Free

        SndDtaQe( PrmRcd.StgNam
                : PrmRcd.StgLib
                : %Len( PxStgEnt )
                : PxStgEnt
                : %Len( PxStgKey )
                : PxStgKey
                );

        Return;

      /End-Free

     P PutStgEnt       E
