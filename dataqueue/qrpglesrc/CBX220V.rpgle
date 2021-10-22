     **
     **  Program . . : CBX220V
     **  Description : Change Data Queue - VCP
     **  Author  . . : Carsten Flensburg
     **  Published . : System iNetwork Programming Tips Newsletter
     **  Date  . . . : October 28, 2010
     **
     **
     **
     **  Program description:
     **    This program checks the existence of the specified data queue.
     **
     **
     **  Compile options:
     **    CrtRpgMod Module( CBX220V )
     **              DbgView( *LIST )
     **
     **    CrtPgm    Pgm( CBX220V )
     **              Module( CBX220V )
     **              ActGrp( *NEW )
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
     D OFS_MSGDTA      c                   16

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
     D  Error                      1024a          Options( *VarSize )
     **-- Retrieve object description:
     D RtvObjD         Pr                  ExtPgm( 'QUSROBJD' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                        8a   Const
     D  ObjNamQ                      20a   Const
     D  ObjTyp                       10a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Retrieve message description:
     D RtvMsgD         Pr                  ExtPgm( 'QMHRTVM' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                       10a   Const
     D  MsgId                         7a   Const
     D  MsgF_q                       20a   Const
     D  MsgDta                      512a   Const  Options( *VarSize )
     D  MsgDtaLen                    10i 0 Const
     D  RplSubVal                    10a   Const
     D  RtnFmtChr                    10a   Const
     D  Error                     32767a          Options( *VarSize )
     D  RtvOpt                       10a   Const  Options( *NoPass )
     D  CvtCcsId                     10i 0 Const  Options( *NoPass )
     D  DtaCcsId                     10i 0 Const  Options( *NoPass )
     **-- Retrieve product information:
     D RtvPrdInf       Pr                  ExtPgm( 'QSZRTVPR' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                        8a   Const
     D  PrdInf                       27a   Const
     D  Error                     32767a          Options( *VarSize )

     **-- Get system release level:
     D GetRlsLvl       Pr             6a
     **-- Check object existence:
     D ChkObj          Pr              n
     D  PxObjNam_q                   20a   Const
     D  PxObjTyp                     10a   Const
     **-- Retrieve message:
     D RtvMsg          Pr          4096a   Varying
     D  PxMsgId                       7a   Const
     D  PxMsgDta                    512a   Const  Varying
     **-- Send diagnostic message:
     D SndDiagMsg      Pr            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgDta                    512a   Const  Varying
     **-- Send escape message:
     D SndEscMsg       Pr            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgDta                    512a   Const  Varying

     **-- Entry parameters:
     D ObjNam_q        Ds                  Qualified
     D  ObjNam                       10a
     D  ObjLib                       10a
     **
     D CBX220V         Pr
     D  PxDtaQue_q                         LikeDs( ObjNam_q )
     D  PxAutRcl                      1a
     D  PxEnfLck                      1a
     **
     D CBX220V         Pi
     D  PxDtaQue_q                         LikeDs( ObjNam_q )
     D  PxAutRcl                      1a
     D  PxEnfLck                      1a

      /Free

        If  GetRlsLvl() < 'V6R1M0';
          SndDiagMsg( 'CPD0006'
                    : '0000' +
                      'Release V6R1M0 is required to run this command.'
                    );

          SndEscMsg( 'CPF0002': '' );
        EndIf;

        If  ChkObj( PxDtaQue_q: '*DTAQ' ) = *Off;

          SndEscMsg( 'CPF0002': '' );
        EndIf;

        *InLr = *On;
        Return;


      /End-Free

     **-- Get system release level:
     P GetRlsLvl       B
     D                 Pi             6a

     **-- Product information:
     D PRDR0100        Ds                  Qualified
     D  BytPrv                       10i 0
     D  BytRtn                       10i 0
     D                               10i 0
     D  PrdId                         7a
     D  Release                       6a
     D  PrdOpt                        4a
     D  LodId                         4a
     D  LodTyp                       10a
     D  SymLodStt                    10a
     D  LodErrInd                    10a
     D  LodStt                        2a
     D  SupFlg                        1a
     D  RegTyp                        2a
     D  RegVal                       14a
     D                                2a
     D  OfsAddInf                    10i 0
     D  PriLodId                      4a
     D  MinTrgRel                     6a
     D  MinVrmBas                     6a
     D  RqmBasOpt                     1a
     D  Level                         3a

      /Free

        RtvPrdInf( PRDR0100
                 : %Size( PRDR0100 )
                 : 'PRDR0100'
                 : '*OPSYS *CUR  0000*CODE    '
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          PRDR0100.Release = *Blanks;
        EndIf;

        Return  PRDR0100.Release;

      /End-Free

     P GetRlsLvl       E
     **-- Check object existence:
     P ChkObj          B                   Export
     D                 Pi              n
     D  PxObjNam_q                   20a   Const
     D  PxObjTyp                     10a   Const
     **
     D OBJD0100        Ds                  Qualified
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  ObjNam                       10a
     D  ObjLib                       10a
     D  ObjTyp                       10a

      /Free

        RtvObjD( OBJD0100
               : %Size( OBJD0100 )
               : 'OBJD0100'
               : PxObjNam_q
               : PxObjTyp
               : ERRC0100
               );

        If  ERRC0100.BytAvl > *Zero;

          If  ERRC0100.BytAvl < OFS_MSGDTA;
            ERRC0100.BytAvl  = *Zero;
          Else;
            ERRC0100.BytAvl -= OFS_MSGDTA;
          EndIf;

          SndDiagMsg( 'CPD0006'
                    : '0000'                      +
                      RtvMsg( ERRC0100.MsgId
                            : %Subst( ERRC0100.MsgDta: 1: ERRC0100.BytAvl )
                            )
                    );

          Return  *Off;

        Else;
          Return  *On;
        EndIf;

      /End-Free

     P ChkObj          E
     **-- Retrieve message:
     P RtvMsg          B
     D                 Pi          4096a   Varying
     D  PxMsgId                       7a   Const
     D  PxMsgDta                    512a   Const  Varying

     **-- Local variables:
     D RTVM0100        Ds                  Qualified
     D  BytRtn                       10i 0
     D  BytAvl                       10i 0
     D  RtnMsgLen                    10i 0
     D  RtnMsgAvl                    10i 0
     D  RtnHlpLen                    10i 0
     D  RtnHlpAvl                    10i 0
     D  Msg                        4096a
     **
     D NULL            c                   ''
     D RPL_SUB_VAL     c                   '*YES'
     D NOT_FMT_CTL     c                   '*NO'

      /Free

        RtvMsgD( RTVM0100
               : %Size( RTVM0100 )
               : 'RTVM0100'
               : PxMsgId
               : 'QCPFMSG   *LIBL'
               : PxMsgDta
               : %Len( PxMsgDta )
               : RPL_SUB_VAL
               : NOT_FMT_CTL
               : ERRC0100
               );

        Select;
        When  ERRC0100.BytAvl > *Zero;
          Return  NULL;

        When  %Subst( RTVM0100.Msg: 1: RTVM0100.RtnMsgLen ) = PxMsgId;
          Return  %Subst( RTVM0100.Msg
                        : RTVM0100.RtnMsgLen + 1
                        : RTVM0100.RtnHlpLen
                        );

        Other;
          Return  %Subst( RTVM0100.Msg: 1: RTVM0100.RtnMsgLen );
        EndSl;

      /End-Free

     P RtvMsg          E
     **-- Send diagnostic message:
     P SndDiagMsg      B
     D                 Pi            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgDta                    512a   Const  Varying

     **-- Local variables:
     D MsgKey          s              4a

      /Free

        SndPgmMsg( PxMsgId
                 : 'QCPFMSG   *LIBL'
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : '*DIAG'
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

     P SndDiagMsg      E
     **-- Send escape message:
     P SndEscMsg       B
     D                 Pi            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgDta                    512a   Const  Varying

     **-- Local variables:
     D MsgKey          s              4a

      /Free

        SndPgmMsg( PxMsgId
                 : 'QCPFMSG   *LIBL'
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
