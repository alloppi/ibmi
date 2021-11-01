      *===================================================================*
      * Program name: GENLOGIN2R                                          *
      * Purpose.....: Return key base on given key label                  *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- ----------------------------*
      * 2018/03/16 Alan       AC              New develop                 *
      *===================================================================*
     HDEBUG(*YES)
      *
     FPHKEYF    IF   E           K DISK
      *
      * Passed In/Out Parameters
     D P_RecLabel      S             32A
     D R_Key           s             64A
     D R_IV            s             32A
     D R_RtnCde        s              2P 0
      *
      /COPY QCPYSRC,PSCY01R
      *
      * Parameters for PSXX1JR
     D I_Action        s              1a
     D I_PlainText     s          32752a
     D I_EncryData     s          32752a
     D I_DataSize      s              5p 0
     D O_PlainText     s          32752a
     D O_EncryData     s          32752a
      *
      * Working Variables
     DW1RtnCde         S                   Like(RtnCde)
     DW1Key            S                   Like(IDNKEY)
     DW1IV             S                   Like(IDNIV)
     Dw1EncryData      s                   Like(I_EncryData)
     Dw1DataSize       s                   Like(I_DataSize)
     Dw1PlainText      s                   Like(O_PlainText)
      *
      *==============================================================*
      * Mainline Logic
      *==============================================================*
      *
     C     *Entry        PLIST
     C                   Parm                    P_RecLabel
     C                   Parm                    R_Key
     C                   Parm                    R_IV
     C                   Parm                    R_RtnCde
      *
      * Main Process
     C                   Select
     C                   When      P_RecLabel = 'INTEGRATION_RMTLOGIN_AS400'
     C                   ExSr      @GetKey
     C                   Eval      R_Key    = W1Key
     C                   Eval      R_IV     = W1IV
     C                   Other
     C     '0001'        Dump
     C                   Eval      R_Key    = *Blank
     C                   Eval      R_IV     = *Blank
     C                   Eval      R_RtnCde = 1
     C                   EndSl
      * End of Program
     C                   Eval      *InLR = *On
     C                   Return
      *
      **************************************************************************
     C     @GetKey       BegSr
     C                   Eval      R_RtnCde = 0
      *
     C                   Read      PHKEYFR                                99
     C                   If        *In99
     C                   Eval      W1RtnCde = 1
     C     '0002'        Dump
     C                   Else
      *
      *
     C                   Eval      w1EncryData = IDNKEY
     C                   ExSr      @DcryInfo
     C   99              Goto      $EndGetKey
     C                   Eval      W1Key   = w1PlainText
      *
     C                   Eval      w1EncryData = IDNIV
     C                   ExSr      @DcryInfo
     C   99              Goto      $EndGetKey
     C                   Eval      W1IV    = w1PLainText
     C                   Endif
      *
      * Judge the development machine
      *
     C     $EndGetKey    Tag
     C                   EndSr
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
     C     '0004'        Dump
     C                   Else
     C                   Eval      w1PlainText = O_PlainText
     C                   EndIf
      *
     C                   EndSr
