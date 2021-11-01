      *===================================================================*
      * Program name: XMLSRR5                                             *
      * Purpose.....: Bank Transfer Reply Update                          *
      *                                                                   *
      * Date written: 2017/03/02                                          *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2017/03/02 Alan        AC             New Development             *
      *===================================================================*
     H DEBUG(*YES)
     FPHBTRF01  IF   E           K Disk
     FPHATF06   UF   E           K Disk    Commit
     FPHHBTF03  UF   E           K Disk    Commit
      *
      * Standard D spec.
      /Copy Qcpysrc,PSCY01R
      *
      * Parameters
     D P_PID           S             17a
     D R_RtnCde        S                   Like(RtnCde)
     D R_TfrAlertF     S              1a
     D R_BOAlertF      S              1a
     D R_BOAlertCusRf  S                   Like(HBTCR)
      *
      * Working Variables
     D W1RtnCde        S                   Like(RtnCde)
     D W1TfrAlertF     S              1A
     D W1BOAlertF      S              1A
     D W1BOAlertCusR   S                   Like(HBTCR)
     D W1RecExtF       S              1A
     D W1RootElemStr   S              1A
     D W1RootElemEnd   S              1A
     D W1HdrElem       S              1A
     D W1RecElem       S              1A
     D W1RecCnt        S              2P 0
     D W1DebitAcctNo   S                   Like(HBTRDAN)
     D W1DebitCur      S                   Like(HBTRDC)
     D W1TxStatus      S                   Like(ATBRTS)
     D W1ErrorCode     S                   Like(ATBREC)
     D W1ErrorDtl      S                   Like(ATBRED)
     D W1TxRefNo       S                   Like(ATBRTRN)
     D W1TxDate        S             10A
     D W1TxTime        S              8A
     D W1RecStatus     S                   Like(ATBRRS)
     D W1RecErrCode    S                   Like(ATBRREC)
     D W1RecErrDesc    S                   Like(ATBRRED)
     D W1DebitAmt      S             16A
     D w1TfrBenBankNo  S                   Like(HBTRBBN)
     D W1TfrRmtAcctNo  S                   Like(HBTRBAN)
     D W1TfrRmtAcctNa  S                   Like(HBTRBANM)
     D W1PayCur        S                   Like(HBTRPC)
     D w1TfrChrAcctNo  S                   Like(HBTRCAN)
     D w1TfrChrCur     S                   Like(HBTRCCU)
     D W1CustRef       S                   Like(HBTRCR)
     D W1ValueDate     S             10a
     D*W1PayCur        S                   Like(HBTRPC)
      *
      *****************************************************************
      * Mainline logic
      *****************************************************************
     C     *Entry        Plist
     C                   Parm                    P_PID
     C                   Parm                    R_RtnCde
     C                   Parm                    R_TfrAlertF
     C                   Parm                    R_BOAlertF
     C                   Parm                    R_BOAlertCusRf
      *
      * Initial Reference
     C                   ExSr      @InitRef
      *
      * Main Process
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @TfrRstSet
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @XMLConsJudge
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @FileUpd
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @AlertJudge
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   Eval      R_RtnCde       = *Zero
     C                   Eval      R_TfrAlertF    = W1TfrAlertF
     C                   Eval      R_BOAlertF     = W1BOAlertF
     C                   Eval      R_BOAlertCusRf = W1BOAlertCusR
     C                   EndIf
      *
     C                   Eval      *InLr = *On
     C                   Return
      *
      *===============================================================*
      * @TfrRstSet - Transfer Result Setting
      *===============================================================*
     C     @TfrRstSet    BegSr
      *
     C     P_PID         SetLL     PHBTRFR
     C     P_PID         ReadE     PHBTRFR                                96
     C                   DoW       Not *In96
     C                             and W1RtnCde = *Zero
     C                   If        W1RtnCde = *Zero
     C                   Eval      W1RecExtF = '1'
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @HdrInfoSet
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @DtlInfoSet
     C                   EndIf
      *
     C     P_PID         ReadE     PHBTRFR                                96
     C                   EndDo
      *
     C                   EndSr
      *===============================================================*
      * @HdrInfoSet - Header Information Setting
      *===============================================================*
     C     @HdrInfoSet   BegSr
      *
     C                   If        %trim(BTREN)  = 'BNKHKB2E'
     C                   Eval      W1RootElemStr = '1'
     C                   EndIf
     C                   If        %trim(BTREN)  = '/BNKHKB2E'
     C                   Eval      W1RootElemEnd = '1'
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'Head'
     C                   Eval      W1HdrElem = '1'
     C                   EndIf
     C                   If        %trim(BTREN)  = '/Head'
     C                   Eval      W1HdrElem = *Blank
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'Record'
     C                   Eval      W1RecElem = '1'
     C                   Eval      W1RecCnt  = W1RecCnt + 1
     C                   EndIf
     C                   If        %trim(BTREN)  = '/Record'
     C                   Eval      W1RecElem = *Blank
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'DebitAcctNo'
     C                   Eval      W1DebitAcctNo = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'DebitCur'
     C                   Eval      W1DebitCur    = %trim(BTREV)
     C                   EndIf
      *
     C                   If        W1HdrElem = '1'
      *
     C                   If        %trim(BTREN)  = 'PackageId'
     C                   If        P_PID <> %trim(BTREV)
     C                   Eval      W1RtnCde = 1
     C     '0001'        Dump
     C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'TxStatus'
     C                   Eval      W1TxStatus    = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'ErrorCode'
     C                   Eval      W1ErrorCode   = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'ErrorDesc'
     C                   Eval      W1ErrorDtl    = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'TxRefNo'
     C                   Eval      W1TxRefNo     = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'TxDate'
     C                   Eval      W1TxDate      = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'TxTime'
     C                   Eval      W1TxTime      = %trim(BTREV)
     C                   EndIf
      *
     C                   EndIf
      *
     C                   EndSr
      *===============================================================*
      * @DtlInfoSet - Detail Information Setting
      *===============================================================*
     C     @DtlInfoSet   BegSr
      *
     C                   If        W1RecElem = '1'
      *
     C                   If        %trim(BTREN)  = 'RecordStatus'
     C                   If        BTREV = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0002'        Dump
     C                   Else
     C                   Eval      W1RecStatus   = %trim(BTREV)
     C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'RecordErrorCode'
     C                   Eval      W1RecErrCode  = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'RecordErrorDesc'
     C                   Eval      W1RecErrDesc  = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'DebitAmt'
     C                   Eval      W1DebitAmt    = %trim(BTREV)
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'BeneBankCode'
     C                   If        BTREV         = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0016'        Dump
     C                   Else
     C                   Eval       w1TfrBenBankNo = %trim(BTREV)
     C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'BeneAcctNo'
     C                   If        BTREV         = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0003'        Dump
     C                   Else
     C                   Eval      W1TfrRmtAcctNo  = %trim(BTREV)
     C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'BeneAcctName'
     C                   If        BTREV         = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0004'        Dump
     C                   Else
     C                   Eval      W1TfrRmtAcctNa = %trim(BTREV)
      * Change &amp -> &; but not &apos -> ';
     C                   Eval      W1TfrRmtAcctNa =
     C                               %ScanRpl('&amp;': '&': W1TfrRmtAcctNa)
     C                   EndIf
     C                   EndIf
      *
07377C                   If        %trim(BTREN)  = 'BeneName'
07377C                   If        BTREV         = *Blank
07377C                   Eval      W1RtnCde = 1
07377C     '0017'        Dump
07377C                   Else
07377C                   Eval      W1TfrRmtAcctNa = %trim(BTREV)
      * Change &amp -> &; but not &apos -> ';
07377C                   Eval      W1TfrRmtAcctNa =
07377C                               %ScanRpl('&amp;': '&': W1TfrRmtAcctNa)
07377C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'PaymentCur'
     C                   If        %trim(BTREV) <> 'HKD'
     C                   Eval      W1RtnCde = 1
     C     '0005'        Dump
     C                   Else
     C                   Eval      W1PayCur     = %trim(BTREV)
     C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'ChargeAcctNo'
     C                   If        BTREV         = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0018'        Dump
     C                   Else
     C                   Eval       w1TfrChrAcctNo = %trim(BTREV)
     C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'ChargeCur'
     C                   If        BTREV         = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0018'        Dump
     C                   Else
     C                   Eval       w1TfrChrCur    = %trim(BTREV)
     C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'CustRef'
     C                   If        BTREV         = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0006'        Dump
     C                   Else
     C                   Eval      W1CustRef     = %trim(BTREV)
     C                   EndIf
     C                   EndIf
      *
     C                   If        %trim(BTREN)  = 'ValueDate'
     C                   Eval      W1ValueDate   = %trim(BTREV)
     C                   EndIf
      *
     C                   EndIf
      *
     C                   EndSr
      *===============================================================*
      * @XMLConsJudge - XML Consistency Judgement
      *===============================================================*
     C     @XMLConsJudge BegSr
      *
     C                   If        W1RecExtF = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0007'        Dump
     C                   EndIf
      *
     C                   If        W1RootElemStr = *Blank
     C                             or W1RootElemEnd = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0008'        Dump
     C                   EndIf
      *
     C                   If        W1RecCnt > 1
     C                   Eval      W1RtnCde = 1
     C     '0009'        Dump
     C                   EndIf
      *
     C                   EndSr
      *===============================================================*
      * @FileUpd - File Update
      *===============================================================*
     C     @FileUpd      BegSr
      *
     C     P_PID         Chain     PHATFR                             9696
     C                   If        *In96
     C                   Eval      W1RtnCde = 1
     C     '0010'        Dump
     C                   Goto      $XFileUpd
     C                   Else
      *
     C                   If        W1TxStatus = 'S'
     C                   If        W1DebitAmt = *Blank
     C                   Eval      W1RtnCde = 1
     C     '0015'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
      *
     C                   If        ATBTDA       <> %dec(W1DebitAmt: 15: 2)
     C                             or ATBTCR    <>  W1CustRef
     C                             or (ATERPITM = '1'
     C                                 and (ATBTBAN   <>  W1TfrRmtAcctNo
     C                                      or ATBTBANM  <>  W1TfrRmtAcctNa))
     C                             or (ATERPITM <> '1'
     C                                 and ATBTFBAN  <>  W1TfrRmtAcctNo)
     C                   Eval      W1RtnCde = 1
     C     '0011'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
     C                   EndIf
     C                   EndIf
      *
     C                   If        W1TxTime = *Blank
     C                   Eval      W1TxTime = '00:00:00'
     C                   EndIf
     C                   If        W1TxDate = *Blank
     C                   Eval      W1TxDate = '0001-01-01'
     C                   EndIf
     C                   If        W1ValueDate = *Blank
     C                   Eval      W1ValueDate = '0001-01-01'
     C                   EndIf
      *
     C                   Eval      ATUT    = DsYMDT
     C                   Eval      ATUP    = PgmId@
     C                   Time                    ATLUT
     C                   Eval      ATBRTS  = W1TxStatus
     C                   Eval      ATBREC  = W1ErrorCode
     C                   Eval      ATBRED  = W1ErrorDtl
     C                   Eval      ATBRTRN = W1TxRefNo
     C                   Eval      ATBRTD  = %Date(%xlate('/':'-':W1TxDate))
     C                   Eval      ATBRTT  =
     C                             %Dec(%Subst(W1TxTime:1:2):2:0) * 10000 +
     C                             %Dec(%Subst(W1TxTime:4:2):2:0) * 100   +
     C                             %Dec(%Subst(W1TxTime:7:2):2:0)
     C                   Eval      ATBRRS  = W1RecStatus
     C                   Eval      ATBRREC = W1RecErrCode
     C                   Eval      ATBRRED = W1RecErrDesc
     C                   Eval      ATBRRVD = %Date(%xlate('/':'-':W1ValueDate))
     C                   Update    PHATFR                               99
     C                   If        *In99
     C                   Eval      W1RtnCde = 1
     C     '0012'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
      *
     C     P_PID         Chain     PHHBTFR                            9696
     C                   If        *In96
     C                   Eval      W1RtnCde = 1
     C     '0013'        Dump
     C                   Goto      $XFileUpd
     C                   Else
      *
     C                   If        W1DebitAmt = *Blank
     C                   Eval      W1DebitAmt = *All'0'
     C                   EndIf
      *
     C                   Eval      HBTUT   = ATUT
     C                   Eval      HBTUP   = ATUP
     C                   Eval      HBTRTS  = ATBRTS
     C                   Eval      HBTREC  = ATBREC
     C                   Eval      HBTRED  = ATBRED
     C                   Eval      HBTRTRN = ATBRTRN
     C                   Eval      HBTRTD  = ATBRTD
     C                   Eval      HBTRTT  = ATBRTT
     C                   Eval      HBTRRS  = ATBRRS
     C                   Eval      HBTRREC = ATBRREC
     C                   Eval      HBTRRED = ATBRRED
     C                   Eval      HBTRDAN = W1DebitAcctNo
     C                   Eval      HBTRDC  = W1DebitCur
     C                   Eval      HBTRDA  = %dec(W1DebitAmt: 15: 2)
     C                   Eval      HBTRBAN = W1TfrRmtAcctNo
     C                   Eval      HBTRBBN = w1TfrBenBankNo
     C                   Eval      HBTRBANM= W1TfrRmtAcctNa
     C                   Eval      HBTRPC  = W1PayCur
     C                   Eval      HBTRCAN = w1TfrChrAcctNo
     C                   Eval      HBTRCCU = w1TfrChrCur
     C                   Eval      HBTRCR  = W1CustRef
     C                   Eval      HBTRRVD = ATBRRVD
     C                   Update    PHHBTFR                              99
     C                   If        *In99
     C                   Eval      W1RtnCde = 1
     C     '0014'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
      *
     C                   EndIf
      *
     C     $XFileUpd     Tag
     C                   If        W1RtnCde = 1
     C                   Rolbk
     C                   Else
     C                   Commit
     C                   EndIf
      *
     C                   EndSr
      *===============================================================*
      * @AlertJudge - Alert Judgement
      *===============================================================*
     C     @AlertJudge   BegSr
      *
     C                   If        W1TxStatus <> 'S'
     C                   If        W1ErrorCode = 'EP0021'
     C                   Eval      W1BOAlertF = '1'
     C                   Eval      W1BOAlertCusR = HBTCR
     C                   Else
     C                   Eval      W1TfrAlertF = '1'
     C                   EndIf
     C                   EndIf
      *
     C                   EndSr
      *===============================================================*
      * @InitRef - Initial Reference
      *===============================================================*
     C     @InitRef      BegSr
      *
     C                   Eval      R_RtnCde        = 1
     C                   Eval      R_TfrAlertF     = *Blank
     C                   Eval      R_BOAlertF      = *BLank
     C                   Eval      R_BOAlertCusRf  = *Blank
      *
     C                   Eval      W1RtnCde        = *Zero
     C                   Eval      W1TfrAlertF     = *Blank
     C                   Eval      W1BOAlertF      = *BLank
     C                   Eval      W1BOAlertCusR   = *Blank
     C                   Eval      W1RecExtF       = *Blank
     C                   Eval      W1RootElemStr   = *Blank
     C                   Eval      W1RootElemEnd   = *Blank
     C                   Eval      W1HdrElem       = *BLank
     C                   Eval      W1RecElem       = *Blank
     C                   Eval      W1RecCnt        = *Zero
     C                   Eval      W1DebitAcctNo   = *Blank
     C                   Eval      W1DebitCur      = *BLank
     C                   Eval      W1TxStatus      = *Blank
     C                   Eval      W1ErrorCode     = *Blank
     C                   Eval      W1ErrorDtl      = *Blank
     C                   Eval      W1TxRefNo       = *Blank
     C                   Eval      W1TxDate        = *BLank
     C                   Eval      W1TxTime        = *Blank
     C                   Eval      W1RecStatus     = *Blank
     C                   Eval      W1RecErrCode    = *Blank
     C                   Eval      W1RecErrDesc    = *Blank
     C                   Eval      W1DebitAmt      = *Blank
     C                   Eval      w1TfrBenBankNo  = *Blank
     C                   Eval      W1TfrRmtAcctNo  = *BLank
     C                   Eval      W1TfrRmtAcctNa  = *Blank
     C                   Eval      W1PayCur        = *Blank
     C                   Eval      w1TfrChrAcctNo  = *Blank
     C                   Eval      w1TfrChrCur     = *Blank
     C                   Eval      W1CustRef       = *Blank
     C                   Eval      W1ValueDate     = *Blank
      *
     C                   EndSr
      *====================================================================*
      * *INZSR                                                             *
      *====================================================================*
     C     *INZSR        BegSr
      *
     C                   Time                    RnTime
     C                   Eval      DsDtYY = RnDtYY
     C                   Eval      DsDtMM = RnDtMM
     C                   Eval      DsDtDD = RnDtDD
     C                   Eval      DsTmHM = RnTmHM
      *
     C                   EndSr
