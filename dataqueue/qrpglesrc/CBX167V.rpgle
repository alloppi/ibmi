     **
     **  Program . . : CBX167V
     **  Description : Display Data Queue Entries - VCP
     **  Author  . . : Carsten Flensburg
     **  Published . : System iNetwork Programming Tips Newsletter
     **  Date  . . . : January 18, 2007
     **
     **
     **  Program description:
     **    Validity checking program for data queue existence and
     **    requirements between parameters.
     **
     **
     **  Compile options:
     **    CrtRpgMod Module( CBX167V )
     **              DbgView( *LIST )
     **
     **    CrtPgm    Pgm( CBX167V )
     **              Module( CBX167V )
     **              ActGrp( QILE )
     **
     **
     **-- Control specification:  --------------------------------------------**
     H Option( *SrcStmt )

     **-- System information:
     D PgmSts         SDs                  Qualified
     D  PgmNam           *Proc
     D  CurJob                       10a   Overlay( PgmSts: 244 )
     D  UsrPrf                       10a   Overlay( PgmSts: 254 )
     D  JobNbr                        6a   Overlay( PgmSts: 264 )
     D  CurUsr                       10a   Overlay( PgmSts: 358 )
     **-- API error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPrv                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      512a

     **-- Retrieve object description:
     D RtvObjD         Pr                  ExtPgm( 'QUSROBJD' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                        8a   Const
     D  ObjNamQ                      20a   Const
     D  ObjTyp                       10a   Const
     D  Error                     32767a          Options( *VarSize )
     **-- Retrieve data queue description:
     D RtvDtqDsc       Pr                  ExtPgm( 'QMHQRDQD' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                       10a   Const
     D  DtaQ_q                       20a   Const
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

     **-- Check object existence:
     D ChkObj          Pr              n
     D  PxObjNam_q                   20a   Const
     D  PxObjTyp                     10a   Const
     **-- Verify data queue type:  -------------------------------------------**
     D VfyDtqTyp       Pr              n
     D  PxDtqNam_q                   20a   Const
     D  PxDtqTyp                     10a   Const
     **-- Get data queue sequence:  ------------------------------------------**
     D GetDtqSeq       Pr             1a
     D  PxDtqNam_q                   20a   Const

     **-- Send diagnostic message:
     D SndDiagMsg      Pr            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgDta                    512a   Const  Varying
     **-- Send escape message:
     D SndEscMsg       Pr            10i 0
     D  PxMsgId                       7a   Const
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
     D CBX167V         Pr
     D  PxDtaQ_q                           LikeDs( ObjNam_q )
     D  PxLstSeq                      1a
     D  PxSelect                           LikeDs( Select )
     **
     D CBX167V         Pi
     D  PxDtaQ_q                           LikeDs( ObjNam_q )
     D  PxLstSeq                      1a
     D  PxSelect                           LikeDs( Select )

      /Free

        Select;
        When  ChkObj( PxDtaQ_q: '*DTAQ' ) = *Off;

          SndDiagMsg( 'CPD0006'
                    : '0000Data queue '           +
                       %Trim( PxDtaQ_q.ObjNam )   +
                      ' in library '              +
                       %Trim( PxDtaQ_q.ObjLib )   +
                      ' not found.'
                    );

          SndEscMsg( 'CPF0002': '' );

        When  VfyDtqTyp( PxDtaQ_q: '*DDM' ) = *On;

          SndDiagMsg( 'CPD0006'
                    : '0000Data queues of type *DDM are not supported +
                       by this command.'
                    );

          SndEscMsg( 'CPF0002': '' );

        When  PxLstSeq = 'K'  And  GetDtqSeq( PxDtaQ_q ) <> 'K';

          SndDiagMsg( 'CPD0006'
                    : '0000SEQ(*BYKEY) only supported for keyed data queues.'
                    );

          SndEscMsg( 'CPF0002': '' );
        EndSl;

        *InLr = *On;
        Return;

      /End-Free

     **-- Check object existence:  -------------------------------------------**
     P ChkObj          B
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
           Return  *Off;

         Else;
           Return  *On;
         EndIf;

      /End-Free

     P ChkObj          E
     **-- Verify data queue type:  -------------------------------------------**
     P VfyDtqTyp       B
     D                 Pi              n
     D  PxDtqNam_q                   20a   Const
     D  PxDtqTyp                     10a   Const
     **
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
     **-- Local constants:
     D DTAQ_STD        c                   '0'
     D DTAQ_DDM        c                   '1'

      /Free

        RtvDtqDsc( RDQD0100
                 : %Size( RDQD0100 )
                 : 'RDQD0100'
                 : PxDtaQ_q
                 );

        Select;
        When  PxDtqTyp = '*STD'  And  RDQD0100.Type = DTAQ_STD;
          Return  *On;

        When  PxDtqTyp = '*DDM'  And  RDQD0100.Type = DTAQ_DDM;
          Return  *On;

        Other;
          Return  *Off;
        EndSl;

      /End-Free

     P VfyDtqTyp       E
     **-- Get data queue sequence:  ------------------------------------------**
     P GetDtqSeq       B
     D                 Pi             1a
     D  PxDtqNam_q                   20a   Const
     **
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

      /Free

        RtvDtqDsc( RDQD0100
                 : %Size( RDQD0100 )
                 : 'RDQD0100'
                 : PxDtaQ_q
                 );

        Return  RDQD0100.Seq;

      /End-Free

     P GetDtqSeq       E
     **-- Send diagnostic message:
     P SndDiagMsg      B
     D                 Pi            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgDta                    512a   Const  Varying
     **
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
     **
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
