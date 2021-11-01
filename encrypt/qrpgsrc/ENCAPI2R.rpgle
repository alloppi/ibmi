      *=========================================================================================*
      * Program name: ENCAPI2R                                                                  *
      * Purpose.....: Encrypt / Decrypt data for ERPI                                           *
      *                                                                                         *
      * Spec........:                                                                           *
      * Date written: 2017/02/24                                                                *
      *                                                                                         *
      * Reference sample program:                                                               *
      * http://www.ibm.com/support/knowledgecenter/ssw_ibm_i_72/apis/qc3WriteCusILERPG.htm      *
      *                                                                                         *
      * COPYRIGHT 5722-SS1, 5761-SS1 (c) IBM Corp 2004, 2008                                    *
      *                                                                                         *
      * This material contains programming source code for your                                 *
      * consideration.  These examples have not been thoroughly                                 *
      * tested under all conditions.  IBM, therefore, cannot                                    *
      * guarantee or imply reliability, serviceability, or function                             *
      * of these programs.  All programs contained herein are                                   *
      * provided to you "AS IS".  THE IMPLIED WARRANTIES OF                                     *
      * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE                                *
      * EXPRESSLY DISCLAIMED.  IBM provides no program services for                             *
      * these programs and files.                                                               *
      *                                                                                         *
      * Description: This is a sample program to demonstrate use                                *
      * of the Cryptographic Services APIs.  APIs demonstrated in                               *
      * this program are:                                                                       *
      *      Create Algorithm Context                                                           *
      *      Create Key Context                                                                 *
      *      Generate Pseudorandom Numbers                                                      *
      *      Encrypt Data                                                                       *
      *      Destroy Key Context                                                                *
      *      Destroy Algorithm Context                                                          *
      *                                                                                         *
      * Refer to the i5/OS Information Center for a full                                        *
      * description of this scenario.                                                           *
      *                                                                                         *
      * Use the following command to compile this program:                                      *
      * CRTRPGMOD MODULE(*LIBL/ENCAPI2R) SRCFILE(*LIBL/QRPGSRC)                                 *
      *                                                                                         *
      * Modification:                                                                           *
      * Date       Name       Pre  Ver  Mod#  Remarks                                           *
      * ---------- ---------- --- ----- ----- ------------------------------------------------- *
      * 2017/02/24 Alan       AC              New develop                                       *
      *=========================================================================================*
     H Debug(*Yes)
     H dftactgrp(*no) bnddir('QC2LE') actgrp(*caller)

     FENCKEYF   if   e             disk    usropn

      * System includes
     D/Copy QSYSINC/QRPGLESRC,QUSEC
     D/Copy QSYSINC/QRPGLESRC,QC3CCI
     D/copy QCPYSRC,IFSIO_H
     D/copy QCPYSRC,ERRNO_H

      * Entry Parameter
     D RtnCde          S              2p 0
     D P_Action        S              1a
     D P_PlainText     S          32752a
     D P_EncryData     S          32752a
     D P_DataSize      S              5p 0
     D R_PlainText     S          32752a
     D R_EncryData     S          32752a

      * Parameter for PSXX76C
     D O_InProd        S              1A

      * Create an AES algorithm context for the key-encrypting key (KEK)
     DCrtAlgCtx        pr                  extproc('Qc3CreateAlgorithmContext')
     D algD                           1    const                                Algorithm descriptio
     D algFormat                      8    const                                Algori desc format
     D AESctx                         8                                         Algori context token
     D errCod                         1                                         Error Code

      * Create a key context for the key-encrypting key (KEK)
     DCrtKeyCtx        pr                  extproc('Qc3CreateKeyContext')
     D key                            1    const                                Key String
     D keySize                       10i 0 const                                Length of Key String
     D keyFormat                      1    const                                Key Format
     D keyType                       10i 0 const                                Key Type
     D keyForm                        1    const                                Key Form
     D keyEncKey                      8    const options(*omit)                 Key-encrypting Key
     D keyEncAlg                      8    const options(*omit)                 Key-encrypt algorith
     D keyTkn                         8                                         Key Context Token
     D errCod                         1                                         Error Code

      * Cleanup key-encrypting key (KEK)
     DDestroyKeyCtx    pr                  extproc('Qc3DestroyKeyContext')
     D keyTkn                         8    const                                Key Context Token
     D errCod                         1                                         Error Code

      * Cleanup key-encrypting key (KEK)
     DDestroyAlgCtx    pr                  extproc('Qc3DestroyAlgorithmContext')
     D AESTkn                         8    const                                Algori Context Token
     D errCod                         1                                         Error Code

      * Encrypt data
     DEncryptData      pr                  extproc('Qc3EncryptData')
     D clrData                    32752a   const                                Clear Data
     D clrDataSize                   10i 0 const                                Length of Clear Data
     D clrDataFmt                     8    const                                Clear data format
     D algDesc                        1    const                                Algorithm Desc
     D algDescFmt                     8    const                                Algorithm Desc Forma
     D keyDesc                        1    const                                Key Description
     D keyDescFmt                     8    const                                Key Desc Format Name
     D csp                            1    const                                Cryptographic Servic
     D cspDevNam                     10    const options(*omit)                 Cryptographic Device
     D EncDta                     32752a                                        Encrypted Data
     D DtaLenPrv                     10i 0 const                                Len of Encrypt Data
     D DtaLenRtn                     10i 0                                      Len of encrypt Retur
     D errCod                         1                                         Error Code

      * Decrypt data
     DDecryptData      pr                  extproc('Qc3DecryptData')
     D encData                    32752a   const                                Encrypted Data
     D encDataSize                   10i 0 const                                Len of Encrypt Data
     D algDesc                        1    const                                Algorithm Desc
     D algDescFmt                     8    const                                Algori Desc Format
     D keyDesc                        1    const                                Key Description
     D keyDescFmt                     8    const                                Key Desc Format Name
     D csp                            1    const                                Cryptographic Servic
     D cspDevNam                     10    const options(*omit)                 Cryptographic Device
     D clrDta                     32752a                                        Clear Data
     D clrLenPrv                     10i 0 const                                Len of Clear Data
     D clrLenRtn                     10i 0                                      Len Clear Data Rtn
     D errCod                         1                                         Error Code

      * Local variable
     D csp             s              1    inz('0')
     D error           s             10i 0 inz(-1)
     D ok              s             10i 0 inz(0)
     D rtn             s             10i 0
     D rtnLen          s             10i 0
     D plainLen        s             10i 0
     D cipherLen       s             10i 0
     D kekTkn          s              8
     D AESctx          s              8
     D KEKctx          s              8
     D FKctx           s              8
     D keySize         s             10i 0
     D keyType         s             10i 0
     D keyFormat       s              1
     D keyForm         s              1

     D encryDta        S          32752a
     D plainTxt        S          32752a

      *****************************************************************
      * Mainline logic
      *****************************************************************
     C     *Entry        Plist
     C                   Parm                    P_Action
     C                   Parm                    P_PlainText
     C                   Parm                    P_EncryData
     C                   Parm                    P_DataSize
     C                   Parm                    RtnCde
     C                   Parm                    R_PlainText
     C                   Parm                    R_EncryData

      * Initialize return parameter
     C                   eval      RtnCde = 0
     C                   eval      R_PlainText = *blank
     C                   eval      R_EncryData = *blank

     C                   eval      encryDta = *loval
     C                   eval      plainTxt = *loval
     C                   eval      rtn = ok
     C                   eval      QUSBPRV = 0

      * Create an AES algorithm context for the key-encrypting key (KEK)
     C                   eval      QC3D0200 = *loval
     C                   eval      keyType = 22
     C                   eval      QC3BCA = keyType
     C                   eval      QC3BL = 16
     C                   eval      QC3MODE = '1'
     C                   eval      QC3PO = '0'
     C                   monitor
     C                   callp     CrtAlgCtx( QC3D0200                          Algorithm descriptio
     C                                       :'ALGD0200'                        AES Algori desc form
     C                                       :AESctx                            Algori context token
     C                                       :QUSEC)                            Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   ExSr      @ClrDump
     C     '0001'        Dump
     C                   eval      rtnCde = 1
     C                   goto      $end
     C                   endif
     C                   endmon

      * Create a key context for the key-encrypting key (KEK)
     C                   eval      keySize = %size(QC3D040000)
     C                   eval      keyFormat = '0'
     C                   eval      keyForm = '0'
     C                   eval      QC3D040000 = *loval
     C                   eval      QC3KS00 = 'PHENCSTRF *LIBL     '
     C                   eval      QC3RL = 'ENCDTAKEK'
     C                   monitor
     C                   callp     CrtKeyCtx( QC3D040000                        Key String
     C                                       :keySize                           Length of Key String
     C                                       :'4'                               4=Keystore label
     C                                       :keyType                           22=AES
     C                                       :keyForm                           0=Clear
     C                                       :*OMIT                             Key-encrypting Key
     C                                       :*OMIT                             Key-encrypt Algorith
     C                                       :KEKctx                            Key context token
     C                                       :QUSEC)                            Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   callp     DestroyAlgCtx( AESctx :QUSEC)
     C                   ExSr      @ClrDump
     C     '0002'        Dump
     C                   eval      rtnCde = 1
     C                   goto      $end
     C                   endif
     C                   endmon

      * Open encrypted key file
     C                   open(e)   ENCKEYF
     C                   if        %error = '1'
     C                   ExSr      @ClrDump
     C     '0003'        Dump
     C                   eval      RtnCde = 1
     C                   goto      $end
     C                   endif

      * Read first (only) record to get encrypted file key
     C                   read(e)   ENCKEYFR
     C                   if        %eof = '1'
     C                   ExSr      @ClrDump
     C     '0004'        Dump
     C                   eval      RtnCde = 1
     C                   close     ENCKEYF
     C                   goto      $end
     C                   endif

      * Create a key context for the file key
     C                   eval      keySize = %size(KEY)
     C                   eval      keyFormat = '0'
     C                   eval      keyForm = '1'
     C                   monitor
     C                   callp     CrtKeyCtx( KEY                               Key String
     C                                       :keySize                           Length of Key String
     C                                       :keyFormat                         0=Binary String
     C                                       :keyType                           22=AES
     C                                       :keyForm                           1=Encry with KEK
     C                                       :KEKctx                            Key-encrypting Key
     C                                       :AESctx                            Key-encrypt Algorith
     C                                       :FKctx                             Key context token
     C                                       :QUSEC)                            Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   callp     DestroyKeyCtx( KEKctx :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx :QUSEC)
     C                   ExSr      @ClrDump
     C     '0005'        Dump
     C                   eval      rtnCde = 1
     C                   goto      $end
     C                   endif
     C                   endmon
      *
     * Encrypt data process
     C                   if        P_Action  = 'E'
     C                   eval      plainTxt  = %subst(P_PlainText:1:P_DataSize)
     C                   eval      plainLen  = P_DataSize
     C                   eval      cipherLen = P_DataSize
     C                   monitor
     C                   callp     EncryptData( plainTxt                        Clear Data
     C                                         :plainLen                        Length of Clear Data
     C                                         :'DATA0100'                      Clear data to encry
     C                                         :QC3D0200                        Algorithm Desc
     C                                         :'ALGD0200'                      for AES
     C                                         :FKctx                           Key Description
     C                                         :'KEYD0100'                      Key Context Token
     C                                         :csp                             Cryptographic Servic
     C                                         :*OMIT                           Cryptographic Device
     C                                         :encryDta                        Encrypted Data
     C                                         :cipherLen                       Len of Encrypt Data
     C                                         :rtnLen                          Len of encrypt Retur
     C                                         :QUSEC)                          Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   callp     DestroyKeyCtx( FKctx  :QUSEC)
     C                   callp     DestroyKeyCtx( KEKctx :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx :QUSEC)
     C                   ExSr      @ClrDump
     C     '0006'        Dump
     C                   eval      rtnCde = 1
     C                   goto      $end
     C                   endif
     C                   endmon

     C                   eval      R_EncryData = %subst(encryDta:1:P_DataSize)
     C                   endif

     * Decrypt data process
     C                   if        P_Action = 'D'

     C                   eval      encryDta  = %subst(P_EncryData:1:P_DataSize)
     C                   eval      cipherLen = P_DataSize
     C                   eval      plainLen  = P_DataSize
     C                   monitor
     C                   callp     DecryptData(encryDta                         Encrypted Data
     C                                         :cipherLen                       Len of Encrypt Data
     C                                         :QC3D0200                        Algorithm Desc
     C                                         :'ALGD0200'                      for ASE
     C                                         :FKctx                           Key Description
     C                                         :'KEYD0100'                      Key Context Token
     C                                         :csp                             Cryptographic Servic
     C                                         :*OMIT                           Cryptographic Device
     C                                         :plainTxt                        Clear Data
     C                                         :plainLen                        Len of Clear Data
     C                                         :rtnLen                          Len Clear Data Rtn
     C                                         :QUSEC)                          Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   callp     DestroyKeyCtx( FKctx  :QUSEC)
     C                   callp     DestroyKeyCtx( KEKctx :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx :QUSEC)
     C                   ExSr      @ClrDump
     C     '0007'        Dump
     C                   eval      rtnCde = 1
     C                   goto      $end
     C                   endif
     C                   endmon

     C                   eval      R_PlainText = %subst(plainTxt:1:P_DataSize)
     C                   endif

      * Cleanup
     C                   callp     DestroyKeyCtx( FKctx  :QUSEC)
     C                   callp     DestroyKeyCtx( KEKctx :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx :QUSEC)

     C     $end          tag
     C                   eval      encryDta = *loval
     C                   eval      plainTxt = *loval

     C                   eval      *inlr = *on
     C                   return

      **************************************************************************
      * Clear Dump for Variable
      **************************************************************************
     C     @ClrDump      BegSr

     C                   Eval      P_PlainText = *Blank
     C                   Eval      R_PlainText = *Blank
     C                   Eval      PlainTxt    = *Blank

     C                   EndSr

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QCPYSRC,ERRNO_H
