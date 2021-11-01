      *===================================================================*
      * Program name: XMLSRR1                                             *
      * Purpose.....: Get Bank XML Header                                 *
      *                                                                   *
      * Date written: 2017/02/24                                          *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2017/02/24 Alan       AC              New Developement            *
      *===================================================================*
     HDEBUG(*YES)
     FPHBCIF01  IF   E           K DISK
      *
      /COPY QCPYSRC,PSCY01R
      *
      * Passed In/Out Parameters
     DP_GatewayIP      S                   Like(BCIGMIP)
     DR_RtnCde         S                   Like(RtnCde)
     DR_PackageID      S             17A
     DR_XMLHeader      S            300A
      *
      * Parameter for PSXX76C
     D O_IsProd        s              1a
      *
      * Parameters for PSXX0JR
     D I_Action        s              1a
     D I_PlainText     s          32752a
     D I_EncryData     s          32752a
     D I_DataSize      s              5p 0
     D O_PlainText     s          32752a
     D O_EncryData     s          32752a
      *
      * Working Variables
     DW1RtnCde         S                   Like(RtnCde)
     DW1RSeqNo         S                   Like(BRSNRSN)
     DW1PackageID      S                   Like(R_PackageID)
     DW1XMLHeader      S                   Like(R_XMLHeader)
     DW1CBSAN          S                   Like(BCICBSAN)
     DW1UID            S                   Like(BCIUID)
     DW1PW             S                   Like(BCIPW)
     DW1ECN            S                   Like(BCIECN)
     DW1ECPW           S                   LIKE(BCIECPW)
     Dw1EncryData      s                   Like(I_EncryData)
     Dw1DataSize       s                   Like(I_DataSize)
     Dw1PlainText      s                   Like(O_PlainText)
      *
     C     *Entry        PList
     C                   Parm                    P_GatewayIP
     C                   Parm                    R_RtnCde
     C                   Parm                    R_PackageID
     C                   Parm                    R_XMLHeader
      *
      * Initial Process
     C                   ExSr      @InitRef
      *
      * Main Process
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @XMLHdrSet
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   Eval      R_RtnCde = *Zero
     C                   Eval      R_PackageID = W1PackageID
     C                   Eval      R_XMLHeader = W1XMLHeader
     C                   EndIf
      *
      * End of Program
     C     $END          Tag
     C                   If        W1RtnCde = *Zero
     C                   Commit
     C                   Else
     C                   Rolbk
     C                   EndIf
      * End of Program
     C                   Eval      *InLR = *On
     C                   Return
      *
      **************************************************************************
     C     @InitRef      BegSr
      **************************************************************************
     C                   Eval      R_RtnCde = 1
     C                   Eval      R_PackageID = *Blank
     C                   Eval      R_XMLHeader = *Blank
      *
     C                   Eval      W1RtnCde = *Zero
     C                   Eval      W1RSeqNo = *Zero
     C                   Eval      W1PackageID = *Blank
     C                   Eval      W1XMLHeader = *Blank
      *
     C     P_GatewayIP   Chain     PHBCIFR                            99
     C                   If        *In99
     C                   Eval      W1RtnCde = 1
     C                   ExSr      @ClrDump
     C     '0002'        Dump
     C                   Else
      *
     C                   Eval      w1EncryData = BCICBSAN
     C                   ExSr      @DcryInfo
     C   99              Goto      $InitRef
     C                   Eval      W1CBSAN = w1PlainText
      *
     C                   Eval      w1EncryData = BCIUID
     C                   ExSr      @DcryInfo
     C   99              Goto      $InitRef
     C                   Eval      W1UID   = w1PlainText
      *
     C                   Eval      w1EncryData = BCIPW
     C                   ExSr      @DcryInfo
     C   99              Goto      $InitRef
     C                   Eval      W1PW    = w1PLainText
      *
     C                   Eval      w1EncryData = BCIECN
     C                   ExSr      @DcryInfo
     C   99              Goto      $InitRef
     C                   Eval      W1ECN   = w1PlainText
      *
     C                   Eval      w1EncryData = BCIECPW
     C                   ExSr      @DcryInfo
     C   99              Goto      $InitRef
     C                   Eval      W1ECPW  = w1PlainText
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
      * Request Seq Number
     C                   If        BRSNRSN = *Zero
     C                             or BRSNRSN = 999
     C                   Eval      W1RSeqNo = 1
     C                   EndIf
     C                   If        BRSNRSN <> *Zero
     C                             and BRSNRSN <> 999
     C                   Eval      W1RSeqNo = BRSNRSN + 1
     C                   EndIf
      * Package ID
     C                   Eval      W1PackageID =
     C                                 %char(%date(): *ISO0)
     C                               + %char(%time(): *ISO0)
     C                               + %editc(W1RSeqNo: 'X')
     C                   EndIf
      *
     C     $InitRef      Tag
     C                   EndSr
      *
      **************************************************************************
     C     @XMLHdrSet    BegSr
      **************************************************************************
      /free
       W1XMLHeader =
         '<?xml version="1.0" encoding="UTF-8"?>'                             +
         '<BNKHKE2B>'                                                         +
            '<Head>'                                                          +
               '<PackageId>' + %Trim(W1PackageID) + '</PackageId>'            +
               '<CBSAcctNo>' + %Trim(W1CBSAN) + '</CBSAcctNo>'                +
               '<UserId>' + %Trim(W1UID) + '</UserId>'                        +
               '<Password>' + %Trim(W1PW) + '</Password>'                     +
               '<ECertName>' + %trim(W1ECN) + '</ECertName>'                  +
               '<ECertPwd>' + %Trim(W1ECPW) + '</ECertPwd>'                   +
            '</Head>';
      /end-free
      *
     C                   EndSr
      *
      **************************************************************************
     C     @DcryInfo     BegSr
      **************************************************************************
      * I_DataSize must be multiple of 16, that is the block size of AES encryption
     C                   If        %rem(%len(%trim(w1EncryData)): 16) <> 0
     C                   Eval      w1DataSize =
     C                             (%div(%len(%trim(w1EncryData)): 16) + 1) * 16
     C                   Else
     C                   Eval      w1DataSize =
     C                             %len(%trim(w1EncryData))
     C                   EndIf
      *
     C                   Call      'ENCAPI2R'
     C                   Parm      'D'           I_Action
     C                   Parm      *Blank        I_PlainText
     C                   Parm      w1EncryData   I_EncryData
     C                   Parm      w1DataSize    I_DataSize
     C                   Parm                    RtnCde
     C                   Parm                    O_PlainText
     C                   Parm                    O_EncryData
     C                   If        RtnCde <> 0
     C                   Eval      *In99 = *On
     C                   Eval      W1RtnCde = 1
     C                   ExSr      @ClrDump
     C     '0005'        Dump
     C                   Else
     C                   Eval      w1PlainText = O_PlainText
     C                   EndIf
      *
     C                   EndSr
      **************************************************************************
      * Clear Dump for Variable
      **************************************************************************
     C     @ClrDump      BegSr

     C                   Eval      W1CBSAN     = *Blank
     C                   Eval      W1UID       = *Blank
     C                   Eval      W1PW        = *Blank
     C                   Eval      W1ECN       = *Blank
     C                   Eval      W1ECPW      = *Blank
     C                   Eval      w1PlainText = *Blank
     C                   Eval      O_PlainText = *Blank
     C                   Eval      W1XMLHeader = *Blank

     C                   EndSr

