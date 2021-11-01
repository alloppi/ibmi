      *=========================================================================================*
      * Program name: SNDRCVMSG                                                                 *
      * Purpose.....: Sample program to send break message to work station                      *
      *               and receive user reply message                                            *
      *                                                                                         *
      * Date written: 2018/07/04                                                                *
      *                                                                                         *
      * Description : 1. Send message to workstation message queue                              *
      *               2. Wait a certain period to allow user to reply message                   *
      *               3. Receive reply message                                                  *
      *                                                                                         *
      * Modification:                                                                           *
      * Date       Name       Pre  Ver  Mod#  Remarks                                           *
      * ---------- ---------- --- ----- ----- ------------------------------------------------- *
      * 2018/07/04 Alan       AC              New Development                                   *
      *---------------------------------------------------------------------------------------- *
      //* SndRcvMsg - Send break message to User or WorkStation and Receive Reply               *
      //*                                                                                       *
      //* Parameter       ATR      I/O       Description                                        *
      //* ----------      ---      ---       -----------                                        *
      //* TextToSend      494a     I         Text message to send to User / Work Station        *
      //* MsgRcvQ          10a     I         Send to User Profile / Work Station                *
      //* TimeWait         10i0    I         Time wait in seconds allow user to repsonse        *
      //* MsgReply          1a       O       Single character message reply                     *
      //*---------------------------------------------------------------------------------------*
     H DftActGrp(*No) ActGrp(*New) BndDir('QC2LE')
     H Debug(*yes)

     D w1Reply         s              1
     D w1OprWS         s             10    Dim(2)
     D w1Idx           s              2p 0

      /free
        w1OprWS(1) = 'TS0499A   ';
        w1OprWS(2) = 'TS0499B   ';

        for w1Idx = 1 to 2;
          w1Reply = SndRcvMsg ('Send message via QEZSNDMG to ' + w1OprWS(w1Idx)
                  : w1OprWS(w1Idx): 5);
          if w1Reply = 'y';
            return;
          endif;
        endfor;
        dump 'NoResponse';

        return;
        *Inlr = *On;
      /end-free

     p SndRcvMsg...
     p                 b
     d SndRcvMsg...
     d                 pi             1a
     d TextToSend                   494a   const
     d MsgRcvQ                       10    const
     d TimeWait                      10u 0 const

      * -- variables & constants:
     D MsgReply        s              1a
     D MsgQueue        s             20a

      * Type definition for the RCVM0100 format

     D MsgInfo         DS                  qualified
     D  BytesRtn                     10I 0
     D  BytesAvail                   10I 0
     D  Severity                     10I 0
     D  MsgID                         7A
     D  Type                          2A
     D  Key                           4A
     D                                7A
     D  CCSID_st                     10I 0
     D  CCSID                        10I 0
     D  DataLen                      10I 0
     D  DataAvail                    10I 0
     D  Data                       1024A

      *-- Api error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPro                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0 Inz
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      128a

      *-- Wait for user response
     D Sleep           Pr            10u 0 ExtProc('sleep')
     D  seconds                      10u 0 value                                Delay time in second

      *-- Send message:
     D SndMsg          Pr                  ExtPgm('QEZSNDMG')
     D  MsgTyp                       10a   const                                Message type
     D  DlvMod                       10a   const                                Delivery mode
     D  MsgTxt                      494a   const  options(*varsize)             Message text
     D  MsgTxtLen                    10i 0 const                                Length of message
     D  MsgRcv                       10a   const  options(*varsize) Dim(299)    Usrprf/Wrkstn array
     D  MsgRcvNbr                    10i 0 const                                No. UsrPrf or WrkStn
     D  MsgSntInd                    10i 0                                      Msg sent indicator
     D  FncRqs                       10i 0                                      Function requested
     D  Error                     32767a          options(*varsize)             Error data structure
     D  ShwSndMsgDsp                  1a   const  options(*nopass)              Display Y/N
     D  MsgQueNam                    20a   const  options(*nopass)              Message queue
     D  NamTypInd                     4a   const  options(*nopass)              Message Key
     D  CcsId                        10i 0 const  options(*nopass)              CCSID

     D rcvPgmMsg       Pr                  ExtPgm('QMHRCVM')
     D  MsgInfo                   32766A   options(*varsize)                    Message info
     D  pm_Length                    10i 0                                      Length of Msg Info
     D  pm_Format                     8a                                        Format
     D  pm_MQname                    20a                                        Qualified MSQ
     D  pm_MType                     10a                                        Message type
     D  pm_Mkey                       4a                                        Message key
     D  pm_Wait                      10i 0                                      Wait time
     D  pm_Action                    10a                                        Action
     D  pm_Error                  32767a          options( *varsize )           Error data structure
      *
      * Program message parameters
      *
     D Rm_MQname       S             20a
     D Rm_Length       S             10i 0
     D Rm_MType        S             10a
     D Rm_MKey         S              4a   Inz(*Blanks)
     D Rm_CSEntry      S             10a
     D Rm_Counter      S             10i 0
     D Rm_Format       S              8a   Inz('RCVM0100')
     D Rm_Wait         S             10i 0
     D Rm_Action       S             10a   Inz('*REMOVE')
     D Rm_Sleep        S             10u 0

     D sm_MsgTyp       S             10a                                        Message type
     D sm_DlvMod       S             10a                                        Delivery mode
     D sm_MsgTxt       S            494a                                        Message text
     D sm_MsgTxtLen    S             10i 0                                      Length of message
     D sm_MsgRcv       S             10a                                        Usrprf/Wrkstn array
     D sm_MsgRcvNbr    S             10i 0                                      No. UsrPrf or WrkStn
     D sm_MsgSntInd    S             10i 0                                      Msg sent indicator
     D sm_FncRqs       S             10i 0                                      Function requested
     D sm_ShwSndMsg    S              1a                                        Display Y/N
     D sm_MsgQNam      S             20a                                        Message queue
     D sm_MsgKey       S              4a                                        Message Key
     D sm_CcsId        S             10i 0                                      CCSID

      /Free

        Rm_Sleep     = TimeWait;                          // Wait response in seconds

        sm_MsgTyp    = '*INQ';                            // Message type
        sm_DlvMod    = '*BREAK';                          // Delivery mode
        sm_MsgTxt    = TextToSend;                        // Message text
        sm_MsgTxtLen = %len(%trim(sm_MsgTxt));            // Length of message
        sm_MsgRcv    = MsgRcvQ;                           // Usrprf/Wrkstn array
        sm_MsgRcvNbr = %div(%len(%trim(sm_MsgRcv)) : 10); // No. UsrPrf or WrkStn

        if %rem(%len(%trim(sm_MsgRcv)) : 10) > 0;
          sm_MsgRcvNbr = sm_MsgRcvNbr + 1;
        endif;

        sm_MsgSntInd = 0;                                 // Msg sent indicator
        sm_FncRqs    = 0;                                 // Function requested
        sm_ShwSndMsg = 'N';                               // Error data structure
        sm_MsgQNam   = *blanks;                           // Display Y/N
        sm_MsgKey    = '*DSP';                            // Message queue

        SndMsg ( sm_MsgTyp
               : sm_DlvMod
               : sm_msgTxt
               : sm_msgTxtLen
               : sm_msgRcv
               : sm_msgRcvNbr
               : sm_MsgSntInd
               : sm_FncRqs
               : ERRC0100
               : sm_shwSndMsg
               : sm_MsgQNam
               : sm_msgKey
              );

        sleep(Rm_Sleep)          ;          // Wait response in seconds

        ERRC0100.bytPro  = 16    ;          // set error code DS not to use exceptions
        CLEAR msgInfo            ;          // clear return data structure
        Rm_length = %len(MsgInfo);          // message length
        Rm_MQName = *blanks      ;          // message queue
        Rm_MQName = MsgRcvQ      ;          // Message queue to receive
        %subst(Rm_MQName:11)  = '*LIBL';    // qualifier
        Rm_Mtype = '*RPY'        ;          // reply from inquiry message
        Rm_Wait  = 0             ;          // Wait time

        RcvPgmMsg ( MsgInfo
                  : Rm_Length
                  : Rm_format
                  : Rm_MQname
                  : Rm_Mtype
                  : Rm_Mkey
                  : Rm_Wait
                  : Rm_Action
                  : ERRC0100
                ) ;

        if MsgInfo.DataLen < 1;
           msgReply = *blank;
        else;
           msgReply = MsgInfo.Data;
        endif;

        msgReply = %subst(msgInfo.Data:1:1);
        msgReply = %xlate('Y':'y':msgReply);

        return msgReply;

      /end-free
     P                 e
