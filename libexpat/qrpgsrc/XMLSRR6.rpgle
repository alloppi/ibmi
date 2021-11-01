      *====================================================================*
      * Program name: XMLSRR6                                              *
      * Purpose.....: Bank Connection Test XML Creation                    *
      *                                                                    *
      * Date written: 2017/03/07                                           *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- ---------------------------- *
      * 2017/03/07 Alan       AC              New Development              *
      *====================================================================*
     H Debug(*Yes)
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
      *
     FPHBCIF01  IF   E           K Disk
     FPHBRSNF01 UF   E             Disk    Commit
      *
      * Standard D spec.
      /Copy Qcpysrc,PSCY01R
      /Copy QCpySrc,IFSIO_H
      /copy QCPYSRC,ERRNO_H
      *
      * Work fields
     D W1RtnCde        s                   Like(RtnCde)
     D W1PID           s                   Like(R_PID)
     D W1ConTestFile   s                   Like(R_ConTestFile)
     D W1RSn           s                   Like(BRSNRSN)
     D W1XMLDtl        s            500a
     D W1UID           s                    Like(BCIUID)
     D W1PW            s                    Like(BCIPW)
     D W1ECN           s                    Like(BCIECN)
     D W1ECPW          s                    LIKE(BCIECPW)
     D W1IfsData       s          32767c   ccsid(1200)
     D W1EncryData     s          32752a
     D W1PlainText     s          32752a
     D w1DataSize      s                   Like(I_DataSize)
     D flags           s             10U 0
     D mode            s             10U 0
     D ErrMsg          s            250A
     D fd              s             10I 0
      *
      * In / Out Parameters
     D P_GMIP          s             15a
     D R_RtnCde        s                   Like(RtnCde)
     D R_PID           s             17a
     D R_ConTestFile   s             50a
      *
      * Parameters for PSXX0JR
     D I_Action        s              1a
     D I_PlainText     s          32752a
     D I_EncryData     s          32752a
     D I_DataSize      S              5p 0
     D O_PlainText     s          32752a
     D O_EncryData     s          32752a
      *
      *****************************************************************
      * Mainline logic
      *****************************************************************
     C     *Entry        PList
     C                   Parm                    P_GMIP
     C                   Parm                    R_RtnCde
     C                   Parm                    R_PID
     C                   Parm                    R_ConTestFile
      *
      * Initial Process
     C                   ExSr      @InitRef
      *
      * Main Process
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @XMLDtlSet
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @FileUpd
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @IFSFileCrt
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   Eval      R_RtnCde    = *Zero
     C                   Eval      R_PID       = W1PID
     C                   Eval      R_ConTestFile = W1ConTestFile
     C                   EndIf
      *
     C     $End          Tag
     C                   If        W1RtnCde = *Zero
     C                   Commit
     C                   Else
     C                   Rolbk
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
     C                   Time                    RnTime
     C                   Eval      DsDtYY = RnDtYY
     C                   Eval      DsDtMM = RnDtMM
     C                   Eval      DsDtDD = RnDtDD
     C                   Eval      DsTmHM = RnTmHM
      *
     C                   Eval      BRSNUT  = DsYMDT
     C                   Eval      BRSNUP  = PgmId@
     C                   Eval      BRSNRSN = W1RSn
     C                   Update    PHBRSNFR                             99
     C                   If        *In99
     C                   Eval      W1RtnCde = 1
     C                   ExSr      @ClrDump
     C     '0001'        Dump
     C                   Goto      $XFileUpd
     C                   EndIf
     C
     C     $XFileUpd     Tag
     C                   EndSr
      *
      *===============================================================*
      * @IFSFileCrt - IFS File Creation
      *===============================================================*
     C     @IFSFileCrt   BegSr
      *
      * Setting of Connection Test File Name
     C                   Eval      W1ConTestFile = '/BNKHK/CONTEST' +
     C                                            %Trim(W1PID) + '.XML'
      *
      * Encrypt XML Data
     C                   Eval      W1IfsData = %ucs2(%trim(W1XMLDtl) + x'0d25')
     C                   Eval      W1PlainText = W1IfsData
     C                   If        %rem(%len(%trim(W1IfsData)): 16) <> 0
     C                   Eval      W1DataSize =
     C                             (%div(%len(%trim(W1IfsData)): 16) + 1) * 16
     C                   Else
     C                   Eval      W1DataSize =
     C                             %len(%trim(W1IfsData))
     C                   EndIf
     C                   Call      'ENCAPI2R'
     C                   Parm      'E'           I_Action
     C                   Parm      W1PlainText   I_PlainText
     C                   Parm      *Blank        I_EncryData
     C                   Parm      W1DataSize    I_DataSize
     C                   Parm                    RtnCde
     C                   Parm                    O_PlainText
     C                   Parm                    O_EncryData
     C                   If        RtnCde <> 0
     C                   Eval      W1RtnCde = 1
     C                   ExSr      @ClrDump
     C     '0003'        Dump
     C                   Goto      $XIFSFileCrt
     C                   Else
     C                   Eval      W1EncryData = O_EncryData
     C                   EndIf
      *
     C                   Eval      flags = O_CREAT + O_TRUNC + O_CCSID
     C                                   + O_WRONLY + O_TEXT_CREAT + O_TEXTDATA
     C                   Eval      mode =  S_IRUSR
      *
     C                   Eval      fd = open(%trim(W1ConTestFile)
     C                                  : flags
     C                                  : mode)
     C                   If        fd < 0
     C                   Eval      W1RtnCde = 1
     C                   Eval      ErrMsg = %str(strerror(errno))
     C                   ExSr      @ClrDump
     C     '0002'        Dump
     C                   Goto      $XIFSFileCrt
     C                   EndIf
      *
      * Write encrypted data to encrypted file
     C                   If        write(fd: %addr(W1EncryData)
     C                                     : I_DataSize) < 1
     C                   Eval      W1RtnCde = 1
     C                   Eval      ErrMsg = %str(strerror(errno))
     C                   ExSr      @ClrDump
     C     '0004'        Dump
     C                   CallP     close(fd)
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
     C                   Eval      R_RtnCde      = 1
     C                   Eval      R_PID         = *Blank
     C                   Eval      R_ConTestFile = *Blank
      *
     C                   Eval      W1RtnCde      = *Zero
     C                   Eval      W1PID         = *Blank
     C                   Eval      W1ConTestFile = *Blank
      *
     C                   Eval      W1RSn       = *Zero
     C                   Eval      W1XMLDtl    = *Blank
      *
     C                   Read      PHBRSNFR                             9999
     C                   If        *In99
     C                   Eval      W1RtnCde = 1
     C                   ExSr      @ClrDump
     C     '0005'        Dump
     C                   Goto      $XInitRef
     C                   EndIf
      *
      * Search referential file
     C     P_GMIP        Chain     PHBCIFR                            99
     C                   If        *In99
     C                   Eval      W1RtnCde = 1
     C                   ExSr      @ClrDump
     C     '0006'        Dump
     C                   Else
      *
     C                   Eval      W1EncryData = BCIUID
     C                   ExSr      @DcryInfo
     C   99              Goto      $XInitRef
     C                   Eval      W1UID   = W1PlainText
      *
     C                   Eval      W1EncryData = BCIPW
     C                   ExSr      @DcryInfo
     C   99              Goto      $XInitRef
     C                   Eval      W1PW    = W1PLainText
      *
     C                   Eval      W1EncryData = BCIECN
     C                   ExSr      @DcryInfo
     C   99              Goto      $XInitRef
     C                   Eval      W1ECN   = W1PlainText
      *
     C                   Eval      W1EncryData = BCIECPW
     C                   ExSr      @DcryInfo
     C   99              Goto      $XInitRef
     C                   Eval      W1ECPW  = W1PlainText
     C                   EndIf
      *
      * Configure Initial Setting for calculation item
     C                   If        W1RtnCde = *Zero
      * Request Seq Number
     C                   Select
     C                   When      BRSNRSN = *Zero
     C                             or BRSNRSN = 999
     C                   Eval      W1RSn = 1
     C                   When      BRSNRSN <> *Zero
     C                             and BRSNRSN <> 999
     C                   Eval      W1RSn = BRSNRSN + 1
     C                   EndSl
      * Package ID
     C                   Eval      W1PID = %char(%date(): *ISO0)  +
     C                                     %char(%time(): *ISO0)  +
     C                                     %editc(W1RSn: 'X')
     C                   EndIf
      *
     C     $XInitRef     Tag
     C                   EndSr
      *===============================================================*
      * @XMLDtlSet - XML Detail Setting
      *===============================================================*
     C     @XMLDtlSet    BegSr
      *
      /free
       w1XmlDtl =
         '<?xml version="1.0" encoding="UTF-8"?>'                             +
         '<BNKHKE2B>'                                                         +
            '<Head>'                                                          +
               '<PackageId>' + %trim(W1PID) + '</PackageId>'                  +
               '<CBSAcctNo>' + '00000000000000' + '</CBSAcctNo>'              +
               '<UserId>' + %trim(W1UID) + '</UserId>'                        +
               '<Password>' + %trim(W1PW) + '</Password>'                     +
               '<ECertName>' + %trim(W1ECN) + '</ECertName>'                  +
               '<ECertPwd>' + %trim(W1ECPW) + '</ECertPwd>'                   +
            '</Head>'                                                         +
            '<Tx>'                                                            +
               '<ConnectionCheckREQ/>'                                        +
            '</Tx>'                                                           +
         '</BNKHKE2B>'                                                        ;
      /end-free
      *
     C                   EndSr
      **************************************************************************
     C     @DcryInfo     BegSr
      **************************************************************************
      * I_DataSize must be multiple of 16, that is the block size of AES encryption
     C                   If        %rem(%len(%trim(W1EncryData)): 16) <> 0
     C                   Eval      W1DataSize =
     C                             (%div(%len(%trim(W1EncryData)): 16) + 1) * 16
     C                   Else
     C                   Eval      W1DataSize =
     C                             %len(%trim(W1EncryData))
     C                   EndIf
      *
     C                   Call      'ENCAPI2R'
     C                   Parm      'D'           I_Action
     C                   Parm      *Blank        I_PlainText
     C                   Parm      W1EncryData   I_EncryData
     C                   Parm      W1DataSize    I_DataSize
     C                   Parm                    RtnCde
     C                   Parm                    O_PlainText
     C                   Parm                    O_EncryData
     C                   If        RtnCde <> 0
     C                   Eval      *In99 = *On
     C                   Eval      W1RtnCde = 1
     C                   ExSr      @ClrDump
     C     '0007'        Dump
     C                   Else
     C                   Eval      w1PlainText = O_PlainText
     C                   EndIf
      *
     C                   EndSr

      **************************************************************************
      * Clear Dump for Variable
      **************************************************************************
     C     @ClrDump      BegSr

     C                   Eval      W1XMLDtl    = *Blank
     C                   Eval      W1UID       = *Blank
     C                   Eval      W1PW        = *Blank
     C                   Eval      W1ECN       = *Blank
     C                   Eval      W1ECPW      = *Blank
     C                   Eval      W1IfsData   = *Blank
     C                   Eval      W1PlainText = *Blank
     C                   Eval      I_PlainText = *Blank
     C                   Eval      O_PlainText = *Blank

     C                   EndSr

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QCPYSRC,ERRNO_H
