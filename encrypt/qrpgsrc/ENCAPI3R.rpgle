      *===================================================================*
      * Program name: ENCAPI3R                                            *
      * Purpose.....: Set up ENCBCIF (Run 1st Time Only                   *
      *                                                                   *
      * Date written: 2017/03/06                                          *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- ----------------------------*
      * 2017/03/06 Alan       AC              New develop                 *
      *===================================================================*
     FENCBCIF01  IF A E           K Disk    Commit
     FENCAPI3D   CF   E             WorkStn InfDs(Infds)
      *
      /COPY QCPYSRC,PSCY01R
      *
      * Working Variable
     D w1CBSAN         S                   Like(BCICBSAN)
     D w1UID           S                   Like(BCIUID)
     D w1PW            S                   Like(BCIPW)
     D w1ECN           S                   Like(BCIECN)
     D w1ECPW          S                   LIKE(BCIECPW)
     D w1ErrCode       S              3a
      *
     D wcCBSAN         S                   Like(D1CBSAN)
     D wcUID           S                   Like(D1UID)
     D wcPW            S                   Like(D1PW)
     D wcECN           S                   Like(D1ECN)
     D wcECPW          S                   LIKE(D1ECPW)
      *
      * Parameters for ENCAPI2R
     D I_Action        s              1a
     D I_PlainText     s          32752a
     D I_EncryData     s          32752a
     D I_DataSize      s              5p 0
     D O_RtnCde        s                   Like(RtnCde)
     D O_PlainText     s          32752a
     D O_EncryData     s          32752a
      *
      *==============================================================*
      * Mainline Logic
      *==============================================================*
      * Display screen 01 until F05
     C                   DoU       BCI = F05
      * Retreive user message
      /Copy Qcpysrc,PSCY02R
     C                   Time                    RnTime
     C                   Eval      HdDate = RnDt
      *
      * Write function BCI format
     C                   Write     FT001
     C                   ExFmt     DP001
     C                   Eval      HDMSGID = *Blanks
     C                   Eval      HDMSG = *Blanks
     C                   Eval      *In41 = *Off
     C                   Eval      *In42 = *Off
     C                   Eval      *In43 = *Off
     C                   Eval      *In44 = *Off
     C                   Eval      *In45 = *Off
     C                   Eval      *In46 = *Off
     C                   Eval      *In61 = *Off
      *
     C                   Select
      *
      * Exit
     C                   When      BCI = F05
     C                   Leave
      *
      * Refresh input
     C                   When      BCI = F10
     C                   Eval      D1GMIP  = *Blank
     C                   Eval      D1CBSAN = *Blank
     C                   Eval      D1UID   = *Blank
     C                   Eval      D1PW    = *Blank
     C                   Eval      D1ECN   = *Blank
     C                   Eval      D1ECPW  = *Blank
      *
      * Process screen 01
     C                   When      BCI = F01
     C                   ExSr      @ValidScn
     C                   If        Not *In61
      *
     C                   ExSr      @Encrypt
     C  N99              ExSr      @FileUpd
     C  N99              ExSr      @CheckData
     C                   If        Not *In99
     C                   Commit
     C                   Else
     C                   Rolbk
     C                   EndIf
      *
     C                   Leave
     C                   EndIf
      *
     C                   When      BCI = F12
     C                   ExSr      @ValidScn
      *
     C                   EndSl
      *
     C                   EndDo
      *
      * End of Program
     C     $End          Tag
     C                   Eval      *InLr = *On
     C                   Return
      *
      *==============================================================*
      * Validate screen 01                                           *
      *==============================================================*
     C     @ValidScn     Begsr
     C                   Eval      *In61 = *Off
      *
      * Checking of Gateway Machine
     C                   If        D1GMIP = *Blank
     C                   Eval      MSGID = 'UME0001'
     C                   Eval      *In41 = *On
     C                   Eval      *In61 = *On
     C                   Goto      $ValidScn
     C                   EndIf
      *
      * Duplicate Record
     C     D1GMIP        Chain     ENCBCIFR                           96
     C                   If        Not *In96
     C                   Eval      MSGID = 'UME0001'
     C                   Eval      *In41 = *On
     C                   Eval      *In61 = *On
     C                   Goto      $ValidScn
     C                   EndIf
      *
      * CBS Account No.
     C                   If        D1CBSAN = *Blank
     C                   Eval      MSGID = 'UME0001'
     C                   Eval      *In42 = *On
     C                   Eval      *In61 = *On
     C                   Goto      $ValidScn
     C                   EndIf
      *
      * Checking of User Name
     C                   If        D1UID = *Blank
     C                   Eval      MSGID = 'UME0001'
     C                   Eval      *In43 = *On
     C                   Eval      *In61 = *On
     C                   Goto      $ValidScn
     C                   EndIf
      *
      * Checking of Password
     C                   If        D1PW = *Blank
     C                   Eval      MSGID = 'UME0001'
     C                   Eval      *In44 = *On
     C                   Eval      *In61 = *On
     C                   Goto      $ValidScn
     C                   EndIf
      *
      * Checking of E-Cert Name
     C                   If        D1ECN = *Blank
     C                   Eval      MSGID = 'UME0001'
     C                   Eval      *In45 = *On
     C                   Eval      *In61 = *On
     C                   Goto      $ValidScn
     C                   EndIf
      *
      * Checking of E-Cert Password
     C                   If        D1ECPW = *Blank
     C                   Eval      MSGID = 'UME0001'
     C                   Eval      *In46 = *On
     C                   Eval      *In61 = *On
     C                   Goto      $ValidScn
     C                   EndIf
      *
     C     Cursor        Div       256           CPlin
     C                   Mvr                     CPcol
      *
     C     $ValidScn     Tag
     C                   Endsr
      *
      *==============================================================*
      * Perform Encryption
      *==============================================================*
     C     @Encrypt      Begsr
      *
      * CBS Account No.
     C                   Eval      I_PlainText = D1CBSAN
     C                   ExSr      @EncryData
     C   99              Goto      $Encrypt
     C                   Eval      w1CBSAN = %subst(O_EncryData: 1: I_DataSize)
      *
      * User ID
     C                   Eval      I_PlainText = D1UID
     C                   ExSr      @EncryData
     C   99              Goto      $Encrypt
     C                   Eval      w1UID   = %subst(O_EncryData: 1: I_DataSize)
      *
      * Password
     C                   Eval      I_PlainText = D1PW
     C                   ExSr      @EncryData
     C   99              Goto      $Encrypt
     C                   Eval      w1PW    = %subst(O_EncryData: 1: I_DataSize)
      *
      * E-Cert Name
     C                   Eval      I_PlainText = D1ECN
     C                   ExSr      @EncryData
     C   99              Goto      $Encrypt
     C                   Eval      w1ECN   = %subst(O_EncryData: 1: I_DataSize)
      *
      * E-Cert Password
     C                   Eval      I_PlainText = D1ECPW
     C                   ExSr      @EncryData
     C   99              Goto      $Encrypt
     C                   Eval      w1ECPW  = %subst(O_EncryData: 1: I_DataSize)
      *
     C     $Encrypt      Tag
     C                   If        *In99
     C                   Eval      W1ErrCode = '051'
     C                   ExSr      @ErrorPopUp
     C                   EndIf
      *
     C                   Endsr
      *
      *==============================================================*
      * File Update
      *==============================================================*
     C     @FileUpd      Begsr
      *
     C                   Time                    RnTime
     C                   Eval      DsDtYY   = RnDtYY
     C                   Eval      DsDtMM   = RnDtMM
     C                   Eval      DsDtDD   = RnDtDD
     C                   Eval      DsTmHM   = RnTmHM
      *
     C                   Eval      BCIRT    = DsYMDT
     C                   Eval      BCIRP    = PgmId@
     C                   Eval      BCIUT    = DsYMDT
     C                   Eval      BCIUP    = PgmId@
      *
     C                   Eval      BCIGMIP  = D1GMIP
     C                   Eval      BCICBSAN = w1CBSAN
     C                   Eval      BCIUID   = w1UID
     C                   Eval      BCIPW    = w1PW
     C                   Eval      BCIECN   = w1ECN
     C                   Eval      BCIECPW  = w1ECPW
      *
     C                   Write     ENCBCIFR                             99
     C                   If        *In99
     C                   Eval      W1ErrCode = '001'
     C                   ExSr      @ErrorPopUp
     C                   EndIf
      *
     C                   EndSr
      *
      *==============================================================*
      * Checking Encryption Data
      *==============================================================*
     C     @CheckData    Begsr
      *
      * Checking for Decryption
     C     D1GMIP        Chain     ENCBCIFR                           99
     C   99              Goto      $Decrypt
      *
     C                   Eval      I_EncryData = BCICBSAN
     C                   ExSr      @DecryData
     C   99              Goto      $Decrypt
     C                   Eval      wcCBSAN = %subst(O_PlainText: 1: I_DataSize)
      *
     C                   Eval      I_EncryData = BCIUID
     C                   ExSr      @DecryData
     C   99              Goto      $Decrypt
     C                   Eval      wcUID   = %subst(O_PlainText: 1: I_DataSize)
      *
     C                   Eval      I_EncryData = BCIPW
     C                   ExSr      @DecryData
     C   99              Goto      $Decrypt
     C                   Eval      wcPW    = %subst(O_PlainText: 1: I_DataSize)
      *
     C                   Eval      I_EncryData = BCIECN
     C                   ExSr      @DecryData
     C   99              Goto      $Decrypt
     C                   Eval      wcECN   = %subst(O_PlainText: 1: I_DataSize)
      *
     C                   Eval      I_EncryData = BCIECPW
     C                   ExSr      @DecryData
     C   99              Goto      $Decrypt
     C                   Eval      wcECPW  = %subst(O_PlainText: 1: I_DataSize)
      *
     C                   If        D1CBSAN   <> wcCBSAN
     C                             or D1UID  <> wcUID
     C                             or D1PW   <> wcPW
     C                             or D1ECN  <> wcECN
     C                             or D1ECPW <> wcECPW
     C                   Eval      *In99 = *On
     C                   Goto      $Decrypt
     C                   EndIf
      *
     C     $Decrypt      Tag
     C                   If        *In99
     C                   Eval      W1ErrCode = '051'
     C                   ExSr      @ErrorPopUp
     C                   EndIf
      *
     C                   EndSr
      *
      *===================================================================*
      * @EncryData - Encrypt Data
      *===================================================================*
     C     @EncryData    BegSr
     C                   Eval      I_Action = 'E'
     C                   If        %rem(%len(%trim(I_PlainText)): 16) <> 0
     C                   Eval      I_DataSize =
     C                             (%div(%len(%trim(I_PlainText)): 16) + 1) * 16
     C                   Else
     C                   Eval      I_DataSize =
     C                             %len(%trim(I_PlainText))
     C                   EndIf
     C                   Call      'ENCAPI2R'
     C                   Parm                    I_Action
     C                   Parm                    I_PlainText
     C                   Parm      *Blank        I_EncryData
     C                   Parm                    I_DataSize
     C                   Parm                    O_RtnCde
     C                   Parm                    O_PlainText
     C                   Parm                    O_EncryData
     C                   If        O_RtnCde <> 0
     C                   Eval      *In99 = *On
     C                   EndIf
      *
     C                   EndSr
      *
      *===================================================================*
      * @DecryData - Decrypt Data
      *===================================================================*
     C     @DecryData    BegSr
     C                   Eval      I_Action = 'D'
     C                   If        %rem(%len(%trim(I_EncryData)): 16) <> 0
     C                   Eval      I_DataSize =
     C                             (%div(%len(%trim(I_EncryData)): 16) + 1) * 16
     C                   Else
     C                   Eval      I_DataSize =
     C                             %len(%trim(I_EncryData))
     C                   EndIf
     C                   Call      'ENCAPI2R'
     C                   Parm                    I_Action
     C                   Parm      *Blank        I_PlainText
     C                   Parm                    I_EncryData
     C                   Parm                    I_DataSize
     C                   Parm                    RtnCde
     C                   Parm                    O_PlainText
     C                   Parm                    O_EncryData
     C                   If        O_RtnCde <> 0
     C                   Eval      *In99 = *On
     C                   EndIf
      *
     C                   EndSr
      *
      *===================================================================*
      * @ErrorPopUp - Error message pop up                                *
      *===================================================================*
     C     @ErrorPopUp   BegSr
      *
     C                   Call      'PS0021R'
     C                   Parm                    W1ErrCode
      *
     C                   EndSr
      *
      *===================================================================*
      * *InzSr                                                            *
      *===================================================================*
     C     *InzSr        BegSr
      *
      * Retrieve *LDA
     C     *Dtaara       Define    *Lda          Lda
     C                   In        Lda
     C                   Eval      HDBC = BrhCde
      *
     C                   Time                    RnTime
     C                   Eval      DsDtYY = RnDtYY
     C                   Eval      DsDtMM = RnDtMM
     C                   Eval      DsDtDD = RnDtDD
     C                   Eval      DsTmHM = RnTmHM
      *
     C                   Eval      HDDATE = RnDt
      *
     C                   Eval      PgmId = PgmId@
03374 *
     C                   EndSr
