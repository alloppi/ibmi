     **
     **  Program . . : CBX220
     **  Description : Change Data Queue - CPP
     **  Author  . . : Carsten Flensburg
     **  Published . : System iNetwork Programming Tips Newsletter
     **  Date  . . . : October 28, 2010
     **
     **
     **
     **  Compile options:
     **    CrtRpgMod Module( CBX220 )
     **              DbgView( *LIST )
     **
     **    CrtPgm    Pgm( CBX220 )
     **              Module( CBX220 )
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

     **-- Global constants:
     D OFS_MSGDTA      c                   16
     **
     D PARM_SAME       c                   '*'
     **
     D AUT_RCL         c                   100
     D ENF_DTQ_LCK     c                   200

     **-- API change request:
     D RqsChg          Ds                  Qualified
     D  NbrVarRcd                    10i 0 Inz( 0 )
     D  VarLenRcd                          LikeDs( VarLenRcd )  Dim( 2 )
     **
     D VarLenRcd       Ds                  Qualified
     D  ChgKey                       10i 0
     D  ValLen                       10i 0
     D  NewVal                        1a

     **-- Change data queue:
     D ChgDtaQ         Pr                  ExtPgm( 'QMHQCDQ' )
     D  DtaQue_q                     20a   Const
     D  RqsChg                    32767a   Const
     D  Error                     32767a          Options( *VarSize )
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
     D  CalStkEntLen                 10i 0 Const  Options( *NoPass )
     D  CalStkEntQlf                 20a   Const  Options( *NoPass )
     D  DspWait                      10i 0 Const  Options( *NoPass )
     D  CalStkEntTyp                 20a   Const  Options( *NoPass )
     D  CcsId                        10i 0 Const  Options( *NoPass )

     **-- Send completion message:
     D SndCmpMsg       Pr            10i 0
     D  PxMsgDta                    512a   Const  Varying
     **-- Send escape message:
     D SndEscMsg       Pr            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgF                       10a   Const
     D  PxMsgDta                    512a   Const  Varying

     **-- Entry parameters:
     D ObjNam_q        Ds                  Qualified
     D  ObjNam                       10a
     D  ObjLib                       10a
     **
     D CBX220          Pr
     D  PxDtaQue_q                         LikeDs( ObjNam_q )
     D  PxAutRcl                      1a
     D  PxEnfLck                      1a
     **
     D CBX220          Pi
     D  PxDtaQue_q                         LikeDs( ObjNam_q )
     D  PxAutRcl                      1a
     D  PxEnfLck                      1a

      /Free

        *InLr = *On;

        If  PxAutRcl = PARM_SAME  And  PxEnfLck = PARM_SAME;

          Return;
        EndIf;

        If  PxAutRcl <> PARM_SAME;
          RqsChg.NbrVarRcd += 1;
          RqsChg.VarLenRcd(RqsChg.NbrVarRcd).ChgKey = AUT_RCL;
          RqsChg.VarLenRcd(RqsChg.NbrVarRcd).ValLen = %Size( VarLenRcd.NewVal );
          RqsChg.VarLenRcd(RqsChg.NbrVarRcd).NewVal = PxAutRcl;
        EndIf;

        If  PxEnfLck <> PARM_SAME;
          RqsChg.NbrVarRcd += 1;
          RqsChg.VarLenRcd(RqsChg.NbrVarRcd).ChgKey = ENF_DTQ_LCK;
          RqsChg.VarLenRcd(RqsChg.NbrVarRcd).ValLen = %Size( VarLenRcd.NewVal );
          RqsChg.VarLenRcd(RqsChg.NbrVarRcd).NewVal = PxEnfLck;
        EndIf;

        ChgDtaQ( PxDtaQue_q
               : RqsChg
               : ERRC0100
               );

        If  ERRC0100.BytAvl > *Zero;

          If  ERRC0100.BytAvl < OFS_MSGDTA;
            ERRC0100.BytAvl = OFS_MSGDTA;
          EndIf;

          SndEscMsg( ERRC0100.MsgId
                   : 'QCPFMSG'
                   : %Subst( ERRC0100.MsgDta
                           : 1
                           : ERRC0100.BytAvl - OFS_MSGDTA
                           )
                   );
        Else;
          SndCmpMsg( 'Data queue ' + %Trim( PxDtaQue_q.ObjNam ) + ' ' +
                     'in library ' + %Trim( PxDtaQue_q.ObjLib ) + ' changed.'
                   );
        EndIf;

        Return;


      /End-Free

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

     P SndCmpMsg       E
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
