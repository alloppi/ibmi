      *====================================================================*
      * Program name: SMSSUPR                                              *
      * Purpose.....: IT Support Request - Control Program                 *
      * Description.: If SMSSUPAVOF = 'Y',                                 *
      *                 If 7th parameter is pass in, used it as default    *
      *                 wave file, else use the SMSSUPAWAV                 *
      * Date written: 2015/07/23                                           *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre   Ver  Mod#  Remarks                     *
      * ---------- ---------- ---  ----- ----- --------------------------- *
      * 2015/07/23 Alan       AC               New Develop                 *
      *====================================================================*
     H Debug(*Yes) Option(*NoDebugIO)
     H DftActGrp(*No) ActGrp(*Caller) BndDir('QC2LE')
      *
     FSMSSUPFA  IF   E           K Disk
     FSMSSUPFC  IF A E           K Disk
      *
      * Standard D spec.
      /COPY QCPYSRC,PSCY01R
      *
      * Main Procedure Prototypes
     D Main            PR                  ExtPgm('SMSSUPR')
     D                               10A   Const
     D                              125A   Const
     D                               60A   Const
     D                                1A   Const Options(*nopass)
     D                                 D   Const Options(*nopass)
     D                                2P 0 Const Options(*nopass)
     D                               10A   Const Options(*nopass)
     D Main            PI
     D  P_JobNam                     10A   Const
     D  P_MsgTxt                    125A   Const
     D  P_MsgSbj                     60A   Const
     D  P_SmsSrv                      1A   Const Options(*nopass)
     D  P_JobDate                      D   Const Options(*nopass)
     D  P_NoOfSnd                     2P 0 Const Options(*nopass)
     D  P_WavFil                     10A   Const Options(*nopass)
      *
      * Parameters for SMSSUPR1
     D I_Party         S              7A
     D I_JobDate       S               D
     D I_NoOfSnd       S              2P 0
     D O_RtnCde        S                   Like(RtnCde)
     D O_SupStaff      S                   Like(SMSSUPASTF)
     D O_SupStfName    S              8A
      *
      * Parameters for SMSSUPR2
     D I_Staff         S                   Like(SMSSUPASTF)
     D O_StfName       S              8A
     D O_StfTel        S              8A
     D O_StfEmail      S             25A
      *
      * Parameters for SMSSUPR3
     D I_SmsSrv        S              1A
     D I_SmsMsg        S            320A
     D I_Tel           S              8A
     D O_MsgID         S             11P 0
      *
      * Parameters for CI0050C
     D O_SysName       S              8A
      *
      * Parameters for CI0006R
     D I_EmlFile       S            256A
     D I_RcvEmlAdr     S            256A
     D I_SndEmlAdr     S            255A
     D I_RcvName       S            256A
     D I_SndName       S             80A
     D I_EmlSbj        S            256A
     D I_EmlMsg        S           1024A
      *
      * Parameters for CI0064R
     D I_Wave          S                   Like(SMSSUPAWAV)
      *
     D I_Attach        DS
     D  W1NbrFiles             1      2B 0
     D  W1AttachFile                256A   Dim(30)
      *
      * Parameters for QCMDEXC
     D I_Cmd           S            200A
     D I_CmdLen        S             15P 5
      *
      * Prototype for Delay
     D Sleep           pr            10u 0 extproc('sleep')
     D   DelayInSec                  10u 0 value
      *
      * Work Variables
     D W1SmsSrv        S                   Like(P_SmsSrv)
     D W1JobDate       S                   Like(P_JobDate)
     D W1NoOfSnd       S                   Like(P_NoOfSnd)
     D W1WavFil        S                   Like(P_WavFil)
      *
     D W1SupStaff      S                   Like(O_SupStaff)
     D W1SupStfName    S                   Like(O_SupStfName)
     D W1Staff         S                   Like(SMSSUPASTF)
     D W1StfName       S                   Like(O_StfName)
     D W1StfTel        S                   Like(O_StfTel)
     D W1StfEmail      S                   Like(O_StfEmail)
     D W1MsgTxt        S                   Like(I_SmsMsg)
     D W1EmlFile       S                   Like(I_EmlFile)
     D W1SndEmlAdr     S                   Like(I_SndEmlAdr)
     D W1SndName       S                   Like(I_SndName)
     D W1EmlSbj        S                   Like(I_EmlSbj)
     D W1ErrMsg        S            125A
     D W1TimeStamp     S             20A
     D W1SentEmail     S              1A
     D W1SentSMS       S              1A
     D W1RetrySMS      S              1P 0
     D W1SentVoi       S              1A
     D W1RetryVoi      S              1P 0
      *
      *====================================================================*
      * Main Logic
      *====================================================================*
      * Initial Reference
     C                   ExSr      @InitRef
      *
      * Send Support Message to Staff
     C                   ExSr      @SendSupp
      *
      * End of Program
     C                   Eval      *InLr = *On
     C                   Return
      *
      *====================================================================*
      * @SendSupp - Send Support Message to Staff
      *====================================================================*
     C     @SendSupp     BegSr
      *
     C     P_JobNam      SetLL     SMSSUPFAR
     C                   DoU       *In96
     C     P_JobNam      ReadE     SMSSUPFAR                              96
     C                   If        Not *In96
      *
      * Skip Staff to Send Message
     C                   If        SMSSUPAEMF <> 'Y'
     C                             and SMSSUPASMF <> 'Y'
     C                             and SMSSUPAVOF <> 'Y'
     C                   Iter
     C                   EndIf
      *
      * Initialize Values
     C                   Eval      W1SupStaff   = *Blank
     C                   Eval      W1SupStfName = *Blank
      *
      * Get Supporting Staff
     C                   If        SMSSUPASUP <> *Blank
      *
      * Choose Different Program Logic to Select Supporting Staff
     C                   Select
     C                   When      SMSSUPASUP = 'CISD'
      *
     C                   Call      'SMSSUPR1'
     C                   Parm      SMSSUPASUP    I_Party
     C                   Parm      W1JobDate     I_JobDate
     C                   Parm      W1NoOfSnd     I_NoOfSnd
     C                   Parm                    O_RtnCde
     C                   Parm                    O_SupStaff
     C                   Parm                    O_SupStfName
      *
     C                   If        O_RtnCde     = 0
     C                   Eval      W1SupStaff   = O_SupStaff
     C                   Eval      W1SupStfName = O_SupStfName
     C                   Else
     C     '0001'        Dump
     C                   ExSr      @SndErrMsg
     C                   Iter
     C                   EndIf
      *
     C                   When      SMSSUPASUP = 'PROMISE'
     C                   EndSl
      *
     C                   EndIf
      *
      * Get Staff Phone No. / Email
     C                   If        SMSSUPASTF = 'CISD'
     C                             or SMSSUPASTF = 'PROMISE'
     C                   Eval      W1Staff = W1SupStaff
     C                   Else
     C                   Eval      W1Staff = SMSSUPASTF
     C                   EndIf
      *
     C                   Call      'SMSSUPR2'
     C                   Parm      W1Staff       I_Staff
     C                   Parm                    O_StfName
     C                   Parm                    O_StfTel
     C                   Parm                    O_StfEmail
     C                   Parm                    O_RtnCde
      *
     C                   If        O_RtnCde   = 0
     C                   Eval      W1StfName  = O_StfName
     C                   Eval      W1StfTel   = O_StfTel
     C                   Eval      W1StfEmail = O_StfEmail
     C                   Else
     C     '0002'        Dump
     C                   ExSr      @SndErrMsg
     C                   Iter
     C                   EndIf
      *
      * Format Message Subject and Text
     C                   If        W1SupStaff <> *Blank
     C                   Eval      W1MsgTxt = %Trim(P_MsgTxt)
     C                               + ' Please Call '
     C                               + %Trim(W1SupStfName)
     C                               + ' for Support!'
     C                   Else
     C                   Eval      W1MsgTxt = P_MsgTxt
     C                   EndIf
      *
      * Call Send Email Program
     C                   Eval      W1SentEmail = *Blank
     C                   If        SMSSUPAEMF = 'Y'
      *
      * Format Email File Details
     C                   Eval      W1EmlSbj = %Trim(P_MsgSbj)
      *
     C                   Eval      W1TimeStamp = %Char( %TimeStamp(): *ISO0)
     C                   Eval      W1EmlFile   = '/Email/Support'
     C                               + W1TimeStamp
     C                   Eval      W1SndEmlAdr = %Trim(O_SysName)
     C                                         + '@PROMISE.COM.HK'
     C                   Eval      W1SndName  = %Trim(O_SysName)
     C                   Eval      W1NbrFiles = 0
     C                   Eval      W1AttachFile(1) = '*NONE'
      *
     C                   Call      'CI0006R'
     C                   Parm      W1EmlFile     I_EmlFile
     C                   Parm      W1StfEmail    I_RcvEmlAdr
     C                   Parm      W1SndEmlAdr   I_SndEmlAdr
     C                   Parm      W1StfName     I_RcvName
     C                   Parm      W1SndName     I_SndName
     C                   Parm                    I_Attach
     C                   Parm      W1EmlSbj      I_EmlSbj
     C                   Parm      W1MsgTxt      I_EmlMsg
      *
     C                   Eval      W1SentEmail = 'Y'
     C                   EndIf
      *
      * Call Send SMS Program
     C                   Eval      W1SentSMS  = *Blank
     C                   Eval      W1RetrySMS = *Zero
     C                   If        SMSSUPASMF = 'Y'
      *
      * Delay 1 second and retry 3 Times if SMS cannot be sent
     C                   DoU       W1SentSMS = 'Y'
     C                             or W1RetrySMS = 3
     C                   Call      'SMSSUPR3'
      *
      * I_SmsSrv = 'P' (Production), I_SmsSrv = 'T' (Testing)
     C                   Parm      W1SmsSrv      I_SmsSrv
     C                   Parm      W1MsgTxt      I_SmsMsg
     C                   Parm      W1StfTel      I_Tel
     C                   Parm                    O_RtnCde
     C                   Parm                    O_MsgID
      *
     C                   If        O_RtnCde  = 0
     C                   Eval      W1SentSMS = 'Y'
     C                   Else
     C                   Eval      W1RetrySMS = W1RetrySMS + 1
     C                   CallP     Sleep(1)
     C                   EndIf
      *
     C                   EndDo
      *
     C                   If        W1SentSMS = *Blank
     C     '0003'        Dump
     C                   ExSr      @SndErrMsg
     C                   EndIf
      *
     C                   EndIf
      *
      * Send Voice Alert using Accessyou
     C                   Eval      W1MsgTxt = %Trim(W1MsgTxt)
     C                             + ' (by Accessyou)'
     C                   Eval      W1SentVoi  = *Blank
     C                   Eval      W1RetryVoi = *Zero
     C                   If        SMSSUPAVOF = 'Y'
      *
      * Delay 1 second and retry 3 Times if Voice Alert cannot be sent
     C                   DoU       W1SentVoi <> *Blank
     C                             or W1RetryVoi = 3
      * If not from input parameter, take file value for wave file
     C                   If        w1WavFil = *Blank
     C                   Eval      w1WavFil = SMSSUPAWAV
     C                   EndIf
      * if w1WavFil still blank, no need to send voice alert
     C                   If        w1WavFil = *Blank
     C                   Eval      W1SentVoi = 'N'
     C                   Leave
     C                   Else
     C                   Call      'CI0064R'
     C                   Parm      W1MsgTxt      I_SmsMsg
     C                   Parm      W1StfTel      I_Tel
     C                   Parm      w1WavFil      I_Wave
     C                   Parm                    O_RtnCde
      *
     C                   If        O_RtnCde  = 0
     C                   Eval      W1SentVoi = 'Y'
     C                   Else
     C                   Eval      W1RetryVoi = W1RetryVoi + 1
     C                   CallP     Sleep(1)
     C                   EndIf
     C                   EndIf
      *
     C                   EndDo
      *
     C                   If        W1SentVoi = *Blank
     C     '0006'        Dump
     C                   ExSr      @SndErrMsg
     C                   EndIf
      *
     C                   EndIf
      *
      * Write Message Sending Log Record
     C                   If        W1SentEmail = 'Y'
     C                             or W1SentSMS = 'Y'
     C                             or W1SentVoi = 'Y'
     C                   If        W1SentVoi = 'Y'
     C                   Eval      W1MsgTxt = %Trim(W1MsgTxt)
     C                             + ' ' + %Trim(w1WavFil)
     C                   EndIf
     C                   ExSr      @WrtLog
     C                   EndIf
      *
     C                   EndIf
     C                   EndDo
      *
     C                   EndSr
      *
      *====================================================================*
      * Write Message Sending Log Record
      *====================================================================*
     C     @WrtLog       BegSr
      *
     C                   Clear     *All          SMSSUPFCR
      *
     C                   Eval      SMSSUPCSDD = %Date()
     C                   Eval      SMSSUPCSDT = %TimeStamp()
     C                   Eval      SMSSUPCNAM = W1StfName
     C                   Eval      SMSSUPCJOB = P_JobNam
      *
     C                   If        SMSSUPAEMF = 'Y'
     C                   Eval      SMSSUPCEML = W1StfEmail
     C                   EndIf
     C                   If        SMSSUPASMF = 'Y'
     C                   Eval      SMSSUPCSMT = %SubSt(W1StfTel:1:2)
     C                                        + '****'
     C                                        + %SubSt(W1StfTel:7:1)
     C                                        + '*'
     C                   EndIf
     C                   Eval      SMSSUPCMSG = W1MsgTxt
      *
     C                   Write     SMSSUPFCR                            99
     C                   If        *In99
     C     '0004'        Dump
     C                   ExSr      @SndErrMsg
     C                   EndIf
      *
     C                   EndSr
      *
      *====================================================================*
      * Send Error Message to *SYSOPR
      *====================================================================*
     C     @SndErrMsg    BegSr
      *
      * Send messages (SNDMSG)
     C                   Eval      W1ErrMsg = 'SMSSUPR - Error ocurred-
     C                             , please check Error Dump!'
     C                   Eval      I_Cmd = 'SNDMSG MSG(''' + %Trim(W1ErrMsg)
     C                                   + ''') TOUSR(*SYSOPR)'
     C                   Eval      I_CmdLen = %Len(%Trim(I_Cmd))
     C                   Call      'QCMDEXC'                            99
     C                   Parm                    I_Cmd
     C                   Parm                    I_CmdLen
     C                   If        *In99
     C     '0005'        Dump
     C                   EndIf
      *
     C                   EndSr
      *
      *====================================================================*
      * Initial Reference
      *====================================================================*
     C     @InitRef      BegSr
      *
      * Get System Name
     C                   Call      'CI0050C'
     C                   Parm                    O_SysName
      *
     C                   EndSr
      *
      *========================*
      * *InzSr                 *
      *========================*
     C     *InzSr        BegSr
      *
      * Set Default to use Production SMS Service
     C                   If        %Parms >=4
     C                             and P_SmsSrv = 'T'
     C                   Eval      W1SmsSrv = P_SmsSrv
     C                   Else
     C                   Eval      W1SmsSrv = 'P'
     C                   EndIf
      *
      * Set Default Value
     C                   If        %Parms >= 5
     C                   Eval      W1JobDate = P_JobDate
     C                   Eval      W1NoOfSnd = P_NoOfSnd
     C                   Else
     C                   Eval      W1JobDate = ISOZeroDate
     C                   Eval      W1NoOfSnd = *Zero
     C                   EndIf
      * If pass in as parameter , set Default Value for Wave File Name
     C                   If        %Parms = 7
     C                   Eval      W1WavFil = P_WavFil
     C                   EndIf
      *
     C                   EndSr
      *
