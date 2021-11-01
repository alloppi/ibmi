      *===================================================================*
      * Program name: XMLSRR2                                             *
      * Purpose.....: Bank Transfer XML Creation                          *
      *                                                                   *
      * Date written: 2017/02/27                                          *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2017/02/27 Alan       AC              New Developmment            *
      *===================================================================*
     H DEBUG(*YES)
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
      *
     FPHBTMF01  IF   E           K Disk
     FPHCMF03   IF   E           K Disk
     FPHATF01   UF   E           K Disk    Commit Rename(PHATFR:PHATFR01)
     FPHCNTF01  UF   E           K Disk    Commit
     FPHHBTF01  IF A E           K Disk    Commit
      *
      * Standard D spec.
     D/Copy QCpySrc,PSCY01R
     D/Copy QCpySrc,IFSIO_H
     D/Copy QCPYSRC,ERRNO_H
      *
      * Work fields
     D W1RtnCde        S                   Like(RtnCde)
     D*W1DAN           S                   Like(HBTDAN)
     D W1PID           S                   Like(O_PID)
     D W1ReqFile       S             50a
     D W1NoRecordF     S                   Like(R_NoRecordF)
     D W1MaxAlertF     S                   Like(R_MaxAlertF)
     D W1ERPITfrM      S                   Like(R_ERPITfrM)
     D W1UpdChkF       S              1A
     D W1SN            S                   Like(ATSN)
     D W1PI            S                   Like(ATPI)
     D W1LUT           S                   Like(ATLUT)
     D W1BnkDbAccNo    S                   Like(HBTDAN)
     D W1BnkTfrRAccNo  S                   Like(HBTBAN)
     D W1ChgAccNo      S                   Like(HBTCAN)
     D W1ChgCur        S                   Like(HBTCCU)
     D W1XmlHdr        S                   Like(O_XmlHdr)
     D W1XmlDtl        S            800a
     D W1XmlPost       S           1100a
     D W1BTDA          S             17a
     D W1BTBANM        S            +30    Like(ATBTBANM)
     D W1BTRVD         S             10a
     d W1IfsData       s          32767c   ccsid(1200)
     d W1EncryData     s          32752a
     d W1PlainText     s          32752a
     d w1DataSize      S              5p 0
     D w1TfrAmt        S             12p 2
      *
      * In/Out Parameters
     D P_GMIP          S             15A
     D R_RtnCde        S                   Like(RtnCde)
     D R_PID           S             17A
     D R_ReqFile       S             50A
     D R_NoRecordF     S              1A
     D R_MaxAlertF     S              1A
     D R_ERPITfrM      S              1A
      *
     D flags           S             10U 0
     D mode            S             10U 0
     D Len             S             10I 0
     D fd              S             10I 0
      *
      * Parameters for PSXX76C
     D O_InProd        S              1A
      *
      * Parameters for PS0282R
     D I_GMIP          S                   Like(P_GMIP)
     D O_PID           S                   Like(R_PID)
     D O_XmlHdr        S            300a
      *
      * Parameters for PSXX0JR
     D I_Action        S              1a
     D I_PlainText     S          32752a
     D I_EncryData     S          32752a
     D I_DataSize      S              5p 0
     D O_PlainText     S          32752a
     D O_EncryData     S          32752a
      *
      * Key Fields
     D K_BKN           S                   Like(ATBKN)
     D K_MDLF          S                   Like(ATMDLF)
     D K_BTCF          S                   Like(ATBTCF)
     D K_BTRVD         S                   Like(ATBTRVD)
     D K_CR            S                   Like(HBTCR)
     D K_RRS           S                   Like(HBTRRS)
     D K_MN            S                   Like(CMMN)
      *
      *****************************************************************
      * Mainline logic
      *****************************************************************
     C     *Entry        Plist
     C                   Parm                    P_GMIP
     C                   Parm                    R_RtnCde
     C                   Parm                    R_PID
     C                   Parm                    R_ReqFile
     C                   Parm                    R_NoRecordF
     C                   Parm                    R_MaxAlertF
     C                   Parm                    R_ERPITfrM
      *
      * Initial Process
     C                   ExSr      @InitRef
      *
      * Main Process
     C                   If        W1RtnCde = *Zero
     C                   Call      'XMLSRR1'
     C                   Parm      P_GMIP        I_GMIP
     C                   Parm                    RtnCde
     C                   Parm                    O_PID
     C                   Parm                    O_XmlHdr
     C                   If        RtnCde = *Zero
     C                   Eval      W1PID    = O_PID
     C                   Eval      W1XmlHdr = O_XmlHdr
     C                   Else
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0001'        Dump
     C                   EndIf
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @XmlDtlSet
     C                   ExSr      @FileUpd
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @IFSFileCrt
     C                   EndIf
      *
      * Result control of Update Judgement
     C                   If        W1UpdChkF <> *Blank
     C                   If        W1RtnCde = *Zero
     C                   Commit
     C                   Else
     C                   RolBk
     C                   EndIf
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                             or W1RtnCde = 1
     C                   Eval      R_RtnCde    = *Zero
     C                   Eval      R_PID       = W1PID
     C                   Eval      R_ReqFile   = W1ReqFile
     C                   Eval      R_NoRecordF = W1NoRecordF
     C                   Eval      R_MaxAlertF = W1MaxAlertF
     C                   Eval      R_ERPITfrM  = W1ERPITfrM
     C                   EndIf
      *
     C                   Eval      *InLr = *On
     C                   Return
      *
      *===============================================================*
      * @FileUpd - File Update
      *===============================================================*
     C     @FileUpd      BegSr
      *
     C                   Eval      W1UpdChkF = '1'
      *
      * Update PHCNTF
     C                   If        ATBKN = 003
     C                             or ATBKN = 004
     C                             or ATBKN = 024
     C     '01'          Chain     PHCNTFR                            9999
07379C                   If        *In99
07379C                   Eval      W1RtnCde = 2
07379C                   ExSr      @ClrDump
07379C     '0013'        Dump
07379C                   Goto      $XFileUpd
07379C                   EndIf
07379 *
07379C                   Eval      CNTUT   = DsYMDT
07379C                   Eval      CNTUP   = PgmId@
07379C                   Eval      w1TfrAmt = %Int(ATAM) / 100
07379C                   If        ATBKN = CNTBN1
07379C                   Eval      CNTBB1  = CNTBB1 + w1TfrAmt
07379C                   EndIf
07379C                   If        ATBKN = CNTBN2
07379C                   Eval      CNTBB2  = CNTBB2 + w1TfrAmt
07379C                   EndIf
07379C                   Eval      CNTBB4  = CNTBB4 - w1TfrAmt
07379C                   If        ATBKN = CNTBN7
07379C                   Eval      CNTBB7  = CNTBB7 + w1TfrAmt
07379C                   EndIf
07379 *
07379C                   Update    PHCNTFR                              99
07379C                   If        *In99
07379C                   Eval      W1RtnCde = 2
07379C                   ExSr      @ClrDump
07379C     '0014'        Dump
07379C                   Goto      $XFileUpd
07379C                   EndIf
07379C                   EndIf
07379 *
      * Update PHATF
     C     W1SN          Chain     PHATFR01                           9999
     C                   If        *In99
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0002'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
      *
     C                   If        ATPI <> W1PI
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0003'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
      *
     C                   If        ATLUT <> W1LUT
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0004'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
      *
     C                   Eval      ATUT    = DsYMDT
     C                   Eval      ATUP    = PgmId@
     C                   Time                    ATLUT
     C                   Eval      ATBTCF  = '1'
     C                   Time                    ATBTCT
     C                   Eval      ATBTPID = W1PID
      *
     C                   Update    PHATFR01                             99
     C                   If        *In99
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0005'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
      *
      * Write PHHBTF
     C                   Clear                   PHHBTFR
     C                   Eval      HBTRT  = DsYMDT
     C                   Eval      HBTRP  = PgmId@
     C                   Eval      HBTUT  = DsYMDT
     C                   Eval      HBTUP  = PgmId@
     C                   Eval      HBTMN    = ATMN
07379C                   Eval      HBTERPITM= ATERPITM
     C                   Move      RnDt          HBTREQD
     C                   Move      RnTm          HBTREQT
     C                   Eval      HBTPID   = W1PID
07379C                   Eval      HBTDAN   = W1BnkDbAccNo
     C                   Eval      HBTDCU   = 'HKD'
     C                   Eval      HBTDA    = ATBTDA
07379C                   Eval      HBTBAN   = W1BnkTfrRAccNo
07379C                   Eval      HBTBBN   = ATBTBBN
     C                   Eval      HBTBANM  = ATBTBANM
     C                   Eval      HBTPCU   = 'HKD'
07379C                   Eval      HBTCAN   = W1ChgAccNo
07379C                   Eval      HBTCCU   = W1ChgCur
     C                   Eval      HBTCR    = ATBTCR
     C                   Eval      HBTREQVD = ATBTRVD
      *
     C                   Write     PHHBTFR                              99
     C                   If        *In99
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0006'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
      *
     C     $XFileUpd     Tag
     C                   EndSr
      *===============================================================*
      * @IFSFileCrt - IFS File Creation
      *===============================================================*
     C     @IFSFileCrt   BegSr
      *
      * Setting of Request File Name
     C                   Eval      W1ReqFile = '/BnkHK/TRFREQ' +
     C                                          %Trim(W1PID) + '.XML'
      *
      * Encrypt XML Data
     C                   Eval      W1IfsData = %ucs2(%trim(W1XmlPost) + x'0d25')
     C                   Eval      w1PlainText = W1IfsData
     C                   If        %rem(%len(%trim(W1IfsData)): 16) <> 0
     C                   Eval      w1DataSize =
     C                             (%div(%len(%trim(W1IfsData)): 16) + 1) * 16
     C                   Else
     C                   Eval      w1DataSize =
     C                             %len(%trim(W1IfsData))
     C                   EndIf
      *
     C                   Call      'ENCAPI2R'
     C                   Parm      'E'           I_Action
     C                   Parm      w1PlainText   I_PlainText
     C                   Parm      *Blank        I_EncryData
     C                   Parm      w1DataSize    I_DataSize
     C                   Parm                    RtnCde
     C                   Parm                    O_PlainText
     C                   Parm                    O_EncryData
     C                   If        RtnCde <> 0
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0007'        Dump
     C                   Goto      $XIFSFileCrt
     C                   Else
     C                   Eval      W1EncryData = O_EncryData
     C                   EndIf
      *
     C                   Eval      flags = O_CREAT + O_TRUNC + O_CCSID
     C                                   + O_WRONLY + O_TEXT_CREAT + O_TEXTDATA
     C                   Eval      mode =  S_IRUSR
      *
     C                   Eval      fd = open(%trim(W1ReqFile) :
     C                                       flags: mode)
     C                   If        fd < 0
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0008'        Dump
     C                   Goto      $XIFSFileCrt
     C                   EndIf
      *
      * Write encrypted data to encrypted file
     C                   If        write(fd: %addr(W1EncryData)
     C                                     : w1DataSize) < 1
     C                   CallP     close(fd)
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0009'        Dump
     C                   Goto      $XIFSFileCrt
     C                   EndIf
      *
      * Close the file
     C                   CallP     close(fd)
      *
     C     $XIFSFileCrt  Tag
     C                   EndSr
      *===============================================================*
      * @InitRef - Inital Reference
      *===============================================================*
     C     @InitRef      BegSr
      *
     C                   Eval      R_RtnCde    = 1
     C                   Eval      R_PID       = *Blank
     C                   Eval      R_ReqFile   = *Blank
     C                   Eval      R_NoRecordF = *Blank
     C                   Eval      R_MaxAlertF = *Blank
07379C                   Eval      R_ERPITfrM  = *Blank
      *
     C                   Eval      W1RtnCde    = *Zero
     C                   Eval      W1PID       = *Blank
     C                   Eval      W1ReqFile   = *Blank
     C                   Eval      W1NoRecordF = *Blank
     C                   Eval      W1MaxAlertF = *Blank
07379C                   Eval      W1ERPITfrM  = *Blank
      *
     C                   Eval      W1UpdChkF   = *Blank
      *
      * Search referential file
07379C                   Read      PHBTMFR                                97
07379C                   If        *In97
07379C                   Eval      W1RtnCde = 2
07379C                   ExSr      @ClrDump
07379C     '0012'        Dump
07379C                   EndIf
07379 *
07379C                   If        W1RtnCde = *Zero
07379C                   Select
07379C                   When      BTMBTM = '1'
07379C     *Loval        SetLL     PHATFR01
07379C                   Read(n)   PHATFR01                               96
07379C                   DoW       Not *In96
07379C                   If        ATERPITM = '1'
07379C                             and ATMDLF = *Blank
07379C                             and ATBTRVD = %Date(RnDt)
07379C                             and ATBTCF = *Blank
07379C                   Leave
07379C                   EndIf
07379C                   Read(n)   PHATFR01                               96
07379C                   EndDo
07379C                   If        *In96
07379C                   Eval      W1RtnCde    = 1
07379C                   Eval      W1NoRecordF = '1'
07379C                   EndIf
07379 *
07379C                   When      BTMBTM = '2'
07379C     *Loval        SetLL     PHATFR01
07379C                   Read(n)   PHATFR01                               96
07379C                   DoW       Not *In96
07379C                   If        ATERPITM = '2'
07379C                             and ATMDLF = *Blank
07379C                             and ATBTRVD = %Date(RnDt)
07379C                             and ATBTCF = *Blank
07379C                   Leave
07379C                   EndIf
07379C                   Read(n)   PHATFR01                               96
07379C                   EndDo
07379C                   If        *In96
07379C                   Eval      W1RtnCde    = 1
07379C                   Eval      W1NoRecordF = '1'
07379C                   EndIf
07379 *
07379C                   When      BTMBTM = '3'
07379C     *Loval        SetLL     PHATFR01
07379C                   Read(n)   PHATFR01                               96
07379C                   DoW       Not *In96
07379C                   If        ATMDLF = *Blank
07379C                             and ATBTRVD = %Date(RnDt)
07379C                             and ATBTCF = *Blank
07379C                   Leave
07379C                   EndIf
07379C                   Read(n)   PHATFR01                               96
07379C                   EndDo
07379C                   If        *In96
07379C                   Eval      W1RtnCde    = 1
07379C                   Eval      W1NoRecordF = '1'
07379C                   EndIf
07379C                   EndSl
07379 *
07379C                   If        W1RtnCde = *Zero
07379C                   If        ATBTDA > 600000
07379C                   Eval      W1RtnCde    = 1
07379C                   Eval      W1MaxAlertF = '1'
07379C                   EndIf
07379C                   EndIf
07379 *
07379C                   If        W1RtnCde = *Zero
07379C                   Eval      W1ERPITfrM = ATERPITM
07379C                   EndIf
07379 *
07379C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   Eval      K_MN = %Int(%SubSt(ATPI:1:7))
     C     KCMF03        Chain     PHCMFR                             97
     C                   If        *In97
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0010'        Dump
     C                   EndIf
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   Eval      K_CR  = ATBTCR
     C                   Eval      K_RRS = 'S'
     C     KHBTF01       Chain     PHHBTFR                            97
     C                   If        Not *In97
     C                   Eval      W1RtnCde = 2
     C                   ExSr      @ClrDump
     C     '0011'        Dump
     C                   EndIf
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   Eval      W1SN = ATSN
     C                   Eval      W1PI = ATPI
     C                   Eval      W1LUT = ATLUT
      *
      * Set Production Debit Account
07379C                   If        O_InProd = 'Y'
07379C                   If        ATERPITM = '1'
07379C                   Eval      W1BnkDbAccNo = '012699XXXXXXXX'
07379C                   Else
07379C                   Eval      W1BnkDbAccNo = '012699XXXXXXXX'
07379C                   EndIf
      * Set UAT Debit Account
07379C                   Else
07379C                   If        ATERPITM = '1'
07379C                   Eval      W1BnkDbAccNo = '012875XXXXXXXX'
07379C                   Else
07379C                   Eval      W1BnkDbAccNo = '012875XXXXXXXX'
07379C                   EndIf
07379C                   EndIf
      *
07379C                   If        ATERPITM = '1'
07379C                   Eval      W1BnkTfrRAccNo = ATBTBAN
07379C                   Else
07379C                   Eval      W1BnkTfrRAccNo = ATBTFBAN
07379C                   EndIf
07379 * Set Production Debit Account
07379C                   If        O_InProd = 'Y'
07379C                   If        ATERPITM = '1'
07379C                   Eval      W1ChgAccNo = *Blank
07379C                   Else
07379C                   Eval      W1ChgAccNo = '012699XXXXXXXX'
07379C                   EndIf
07379 * Set UAT Debit Account
07379C                   Else
07379C                   If        ATERPITM = '1'
07379C                   Eval      W1ChgAccNo = '012875XXXXXXXX'
07379C                   Else
07379C                   Eval      W1ChgAccNo = '012875XXXXXXXX'
07379C                   EndIf
07379C                   EndIf
07379C                   If        ATERPITM = '1'
07379C                   Eval      W1ChgCur = *Blank
07379C                   Else
07379C                   Eval      W1ChgCur = 'HKD'
07379C                   EndIf
     C                   EndIf
      *
     C                   EndSr
      *===============================================================*
      * @XmlDtlSet
      *===============================================================*
     C     @XmlDtlSet    BegSr
      *
      * Reformat data
     C                   Eval      W1BTDA  = %Char(ATBTDA)
     C                   Eval      W1BTRVD = %Char(ATBTRVD)
     C                   Eval      W1BTRVD = %xlate('-':'/':W1BTRVD)
     C                   Eval      w1BTBANM = ATBTBANM
      * Change & -> &amp; but not ' -> &apos;
     C                   Eval      w1BTBANM = %ScanRpl('&': '&amp;': w1BTBANM)
      *
07379C                   If        ATERPITM = '1'
      /free
07379  //W1XmlDtl =
07379  //   '<Tx>'                                                             +
07379  //      '<TransferREQ>'                                                 +
07379  //         '<DebitAcctNo>' + w1DAN + '</DebitAcctNo>'                   +
07379  //         '<DebitCur>' + 'HKD' + '</DebitCur>'                         +
07379  //         '<Requests noOfRecord="1">'                                  +
07379  //            '<Record>'                                                +
07379  //               '<InternalTrans>'                                      +
07379  //                  '<DebitAmt>' + %trim(W1BTDA) + '</DebitAmt>'        +
07379  //              '<BeneAcctNo>' + %trim(ATBTBAN) + '</BeneAcctNo>  '     +
07379  //                '<BeneAcctName>' + %trim(w1BTBANM) + '</BeneAcctName>'+
07379  //                  '<PaymentCur>' + 'HKD' + '</PaymentCur>'            +
07379  //                  '<CustRef>' + %trim(ATBTCR) + '</CustRef>'          +
07379  //                  '<ValueDate>'+ %trim(W1BTRVD) +'</ValueDate>'       +
07379  //               '</InternalTrans>'                                     +
07379  //            '</Record>'                                               +
07379  //         '</Requests>'                                                +
07379  //      '</TransferREQ>'                                                +
07379  //   '</Tx>'                                                            +
07379  //'</BnkHKE2B>'                                                         ;
       // 07379 *Start
       W1XmlDtl =
          '<Tx>'                                                               +
             '<TransferREQ>'                                                   +
                '<DebitAcctNo>' + %trim(W1BnkDbAccNo) + '</DebitAcctNo>'       +
                '<DebitCur>' + 'HKD' + '</DebitCur>'                           +
                '<Requests noOfRecord="1">'                                    +
                   '<Record>'                                                  +
                      '<InternalTrans>'                                        +
                         '<DebitAmt>' + %trim(W1BTDA) + '</DebitAmt>'          +
                         '<BeneAcctNo>' + %trim(W1BnkTfrRAccNo)                +
                         '</BeneAcctNo>'                                       +
                         '<BeneAcctName>' + %trim(w1BTBANM) + '</BeneAcctName>'+
                         '<PaymentCur>' + 'HKD' + '</PaymentCur>'              +
                         '<CustRef>' + %trim(ATBTCR) + '</CustRef>'            +
                         '<ValueDate>'+ %trim(W1BTRVD) +'</ValueDate>'         +
                      '</InternalTrans>'                                       +
                   '</Record>'                                                 +
                '</Requests>'                                                  +
             '</TransferREQ>'                                                  +
          '</Tx>'                                                              +
       '</BnkHKE2B>'                                                           ;
      // 07379 *End
      /end-free
07379C                   Else
07379 * Start
      /free
       W1XmlDtl =
          '<Tx>'                                                               +
             '<TransferREQ>'                                                   +
                '<DebitAcctNo>' + %trim(W1BnkDbAccNo) + '</DebitAcctNo>'       +
                '<DebitCur>' + 'HKD' + '</DebitCur>'                           +
                '<Requests noOfRecord="1">'                                    +
                   '<Record>'                                                  +
                      '<FasterPayment>'                                        +
                         '<DebitAmt>' + %trim(W1BTDA) + '</DebitAmt>'          +
                         '<BeneBankCode>' + %trim(ATBTBBN) + '</BeneBankCode>' +
                         '<BeneAcctNo>' + %trim(W1BnkTfrRAccNo)                +
                         '</BeneAcctNo>'                                       +
                         '<BeneName>' + %trim(w1BTBANM) + '</BeneName>'        +
                         '<PaymentCur>' + 'HKD' + '</PaymentCur>'              +
                         '<ChargeAcctNo>' + %trim(W1ChgAccNo)                  +
                         '</ChargeAcctNo>'                                     +
                         '<ChargeCur>' + %trim(W1ChgCur) + '</ChargeCur>'      +
                         '<CustRef>' + %trim(ATBTCR) + '</CustRef>'            +
                         '<ValueDate>'+ %trim(W1BTRVD) +'</ValueDate>'         +
                      '</FasterPayment>'                                       +
                   '</Record>'                                                 +
                '</Requests>'                                                  +
             '</TransferREQ>'                                                  +
          '</Tx>'                                                              +
       '</BnkHKE2B>'                                                           ;
      /end-free
07379 * End
07379C                   EndIf
      *
     C                   Eval      w1XmlPost = %trim(W1XmlHdr) + %trim(W1XmlDtl)
      *
     C                   EndSr
      *
      *===============================================================*
      * *InzSr
      *===============================================================*
     C     *InzSr        BegSr
      *
     C                   Time                    RnTime
     C                   Eval      DsDtYY = RnDtYY
     C                   Eval      DsDtMM = RnDtMM
     C                   Eval      DsDtDD = RnDtDD
     C                   Eval      DsTmHM = RnTmHM
      *
     C     KATF04        KList
     C                   KFld                    K_BKN
     C                   KFld                    K_MDLF
     C                   KFld                    K_BTCF
     C                   KFld                    K_BTRVD
      *
     C     KHBTF01       KList
     C                   KFld                    K_CR
     C                   KFld                    K_RRS
      *
     C     KCMF03        KList
     C                   KFld                    K_MN
      *
     C                   EndSr
      *
      **************************************************************************
      * Clear Dump for Variable
      **************************************************************************
     C     @ClrDump      BegSr

     C                   Eval      W1XmlHdr    = *Blank
     C                   Eval      O_XmlHdr    = *Blank
     C                   Eval      W1XmlPost   = *Blank
     C                   Eval      W1XmlDtl    = *Blank
     C                   Eval      W1IfsData   = *Blank
     C                   Eval      w1PlainText = *Blank
     C                   Eval      I_PlainText = *Blank

     C                   EndSr

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QCPYSRC,ERRNO_H
