     **
     **  Program . . : CBX220O
     **  Description : Change Data Queue - POP
     **  Author  . . : Carsten Flensburg
     **  Published . : System iNetwork Programming Tips Newsletter
     **  Date  . . . : October 28, 2010
     **
     **
     **  Parameters:
     **    PxCmdNam_q  INPUT      Qualified command name
     **
     **    PxKeyPrm1   INPUT      Key parameter identifying the data queue
     **                           to retrieve attribute information about.
     **
     **    PxCmdStr    OUTPUT     The formatted command prompt string
     **                           returning the current attribute setting
     **                           of the specified data queue to the
     **                           command processor.
     **
     **
     **  Compile options:
     **    CrtRpgMod Module( CBX220O )
     **              DbgView( *LIST )
     **
     **    CrtPgm    Pgm( CBX220O )
     **              Module( CBX220O )
     **              ActGrp( *NEW )
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
     D  MsgDta                      256a

     **-- Global variables:
     D MsgTyps         s             10a   Dim( 4 )

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

     **-- Retrieve data queue description:
     D RtvDtqDsc       Pr                  ExtPgm( 'QMHQRDQD' )
     D  RcvVar                    32767a          Options( *VarSize )
     D  RcvVarLen                    10i 0 Const
     D  FmtNam                       10a   Const
     D  DtaQue_q                     20a   Const
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
     **-- Send program message:
     D SndPgmMsg       Pr                  ExtPgm( 'QMHSNDPM' )
     D  MsgId                         7a   Const
     D  MsgFil_q                     20a   Const
     D  MsgDta                      512a   Const  Options( *VarSize )
     D  MsgDtaLen                    10i 0 Const
     D  MsgTyp                       10a   Const
     D  CalStkEnt                    10a   Const  Options( *VarSize )
     D  CalStkCtr                    10i 0 Const
     D  MsgKey                        4a
     D  Error                       512a          Options( *VarSize )
     **
     D  CalStkEntLen                 10i 0 Const  Options( *NoPass )
     D  CalStkEntQlf                 20a   Const  Options( *NoPass )
     D  DspWait                      10i 0 Const  Options( *NoPass )
     **
     D  CalStkEntTyp                 20a   Const  Options( *NoPass )
     D  CcsId                        10i 0 Const  Options( *NoPass )

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
     D CBX220O         Pr
     D  PxCmdNam_q                   20a
     D  PxKeyPrm1                          LikeDs( ObjNam_q )
     D  PxCmdStr                  32674a   Varying
     **
     D CBX220O         Pi
     D  PxCmdNam_q                   20a
     D  PxKeyPrm1                          LikeDs( ObjNam_q )
     D  PxCmdStr                  32674a   Varying

      /Free

        Monitor;
          RtvDtqDsc( RDQD0100
                   : %Size( RDQD0100 )
                   : 'RDQD0100'
                   : PxKeyPrm1
                   );

        On-Error;
          MsgTyps(1) = '*DIAG';

          MovPgmMsg( *Blanks
                   : MsgTyps
                   : 1
                   : '*PGMBDY'
                   : 1
                   : ERRC0100
                   );

          SndEscMsg( 'CPF0011': '' );
        EndMon;

        ExSr  RtvDtqInf;


        *InLr = *On;
        Return;

        BegSr  RtvDtqInf;

          Select;
          When  RDQD0100.AutRcl = '0';
            PxCmdStr += '?<AUTRCL(*NO) ';

          When  RDQD0100.AutRcl = '1';
            PxCmdStr += '?<AUTRCL(*YES) ';

          Other;
            PxCmdStr += '?<AUTRCL(*SAME) ';
          EndSl;

          Select;
          When  RDQD0100.EnfDtqLck = '0';
            PxCmdStr += '?<ENFORCE(*NO) ';

          When  RDQD0100.EnfDtqLck = '1';
            PxCmdStr += '?<ENFORCE(*YES) ';

          Other;
            PxCmdStr += '?<ENFORCE(*SAME) ';
          EndSl;

        EndSr;

      /End-Free

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
