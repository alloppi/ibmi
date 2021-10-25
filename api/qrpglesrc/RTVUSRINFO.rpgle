      ******************************************************************\
      * Author   : Alan Chan
      * Ref      : Login Script to track QSECOFR
      * Date     : 2013/03/18
      ******************************************************************\
      /If Defined (*CRTBNDRPG)
     H debug option(*srcstmt : *nodebugio)
     H DftActGrp(*No)
      /EndIf

      *-------------------
      * C O P Y B O O K S
      *-------------------
      * IBM Code for retrieving User Information
      /copy QSysInc/Qrpglesrc,QuseC
      /COPY QSYSINC/QRPGLESRC,QSYRUSRI

      * Send Program Message
     D SndPgmMsg       PR                  Extpgm('QMHSNDPM')
     D MsgId                          7a   Const
     D MsgQueue                      20a   Const
     D MsgDta                       256a   Const
     D MsgDtaLen                     10i 0 Const
     D MsgType                       10a   Const
     D CallStkEnt                    10a   Const
     D CallStkCnt                    10i 0 Const
     D MessageKey                     4a
     D ErrorCode                    256a

      * Get User Information for API Format - 0200
     D GetUsr0200      PR                  ExtPgm('QSYRUSRI')
     D   RcvVar                            Likeds(QSYI0200)
     D   RcvVarLen                   10i 0 const
     D   Format                       8    const
     D   UserPrf                     10    const
     D   Error                             Likeds(QUSEC)

      * Get User Information for API Format - 0300
     D GetUsr0300      PR                  ExtPgm('QSYRUSRI')
     D   RcvVar                            Likeds(QSYI0300)
     D   RcvVarLen                   10i 0 const
     D   Format                       8    const
     D   UserPrf                     10    const
     D   Error                             Likeds(QUSEC)

      *---------------------------------------------------------------------------------------
      * Data Structure Definitions
      *---------------------------------------------------------------------------------------
     D                SDS
     D  Program          *PROC
     D  Device               244    253
     D  UsrPrf               254    263

     D GetUsrInf       PR

      /Free
       If (UsrPrf <> *blanks);
          GetUsrInf(); // Get User Information
          // You have all the user information in QSYI0200 and QSYI0200
          // Data Strectures, which can be used for any process.
       EndIf;

       *INLR = *ON;

      /End-Free

      *---------------------------------------------------------------------------------------
      * Procedures
      *---------------------------------------------------------------------------------------
    PP GetUsrInf       B

    DD GetUsrInf       PI

      /Free

           // Get User Information
           QUSBPRV = 0; // Bytes provided in QUSEC error parm
           callp GetUsr0200(QSYI0200:%Size(QSYI0200):
                           'USRI0200':UsrPrf:QUSEC);

           QUSBPRV = 0;
           callp GetUsr0300(QSYI0300:%Size(QSYI0300):
                           'USRI0300':UsrPrf:QUSEC);

      /End-Free

    PP GetUsrInf       E
