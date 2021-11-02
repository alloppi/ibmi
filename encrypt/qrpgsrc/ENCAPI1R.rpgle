      *=========================================================================================*
      * Program name: ENCAPI1R                                                                  *
      * Purpose.....: Set up Encryption keys (Run 1st Time Only)                                *
      *                                                                                         *
      * Spec........:                                                                           *
      * Date written: 2017/02/24                                                                *
      *                                                                                         *
      * Reference sample program:                                                               *
      * http://www.ibm.com/support/knowledgecenter/ssw_ibm_i_72/apis/qc3SetupCusILERPG.htm      *
      *                                                                                         *
      * COPYRIGHT 5722-SS1 (c) IBM Corp 2006                                                    *
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
      *      Create Keystore                                                                    *
      *      Generate Key Record                                                                *
      *      Create Key Context                                                                 *
      *      Create Algorithm Context                                                           *
      *      Generate Symmetric Key                                                             *
      *      Destroy Key Context                                                                *
      *      Destroy Algorithm Context                                                          *
      *                                                                                         *
      * Function:                                                                               *
      *  Create ENCKEYF file for storing encryption key info                                    *
      *  Create keystore file, ENCKEYFILE.                                                      *
      *  Create a KEK in ENCKEYFILE with label ENCDTAKEK.                                       *
      *  Generate a key encrypted under ENCDTAKEK and store in ENCKEYF file                     *
      *                                                                                         *
      * Refer to the i5/OS Information Center for a full                                        *
      * description of this scenario.                                                           *
      *                                                                                         *
      * Use the following command to compile this program:                                      *
      * CRTRPGMOD MODULE(*LIBL/ENCAPI1R) SRCFILE(*LIBL/QRPGSRC)                                 *
      *                                                                                         *
      *                                                                                         *
      * Modification:                                                                           *
      * Date       Name       Pre  Ver  Mod#  Remarks                                           *
      * ---------- ---------- --- ----- ----- ------------------------------------------------- *
      * 2017/02/24 Alan       AC              New develop                                       *
      *=========================================================================================*
     H dftactgrp(*no) bnddir('QC2LE')

     FENCKEYF   if a e             disk    usropn

     D/Copy QSYSINC/QRPGLESRC,QUSEC
     D/Copy QSYSINC/QRPGLESRC,QC3CCI

      * Program Information
     D                SDS
     D @PGM                    1     10
     D @PARMS                 37     39  0
     D @JOB                  244    253
     D @USER                 254    263
     D @JOB#                 264    269  0

      * Prototypes
     DCrtKeyStore      pr                  extproc('Qc3CreateKeyStore')
     D FileName                      20    const                                Qualified key store
     D KeyID                         10i 0 const                                Master key ID
     D PublicAuth                    10    const                                Public authority
     D Description                   50    const                                Text description
     D errCod                         1                                         Error code

      * Key type
      *   INPUT; BINARY(4)
      *   The type of key.
      *   Following are the valid values.
      *   1 MD5
      *   An MD5 key is used for HMAC (hash message authentication code) operations. The minimum len
      *   key is 16 bytes. A key longer than 16 bytes does not significantly increase the function s
      *   randomness of the key is considered weak. A key longer than 64 bytes will be hashed before
      *   2 SHA-1
      *   An SHA-1 key is used for HMAC (hash message authentication code) operations. The minimum l
      *   MAC key is 20 bytes. A key longer than 20 bytes does not significantly increase the functi
      *   he randomness of the key is considered weak. A key longer than 64 bytes will be hashed bef
      *   3 SHA-256
      *   An SHA-256 key is used for HMAC (hash message authentication code) operations. The minimum
      *   56 HMAC key is 32 bytes. A key longer than 32 bytes does not significantly increase the fu
      *   ss the randomness of the key is considered weak. A key longer than 64 bytes will be hashed
      *   4 SHA-384
      *   An SHA-384 key is used for HMAC (hash message authentication code) operations. The minimum
      *   84 HMAC key is 48 bytes. A key longer than 48 bytes does not significantly increase the fu
      *   ss the randomness of the key is considered weak. A key longer than 128 bytes will be hashe
      *   5 SHA-512
      *   An SHA-512 key is used for HMAC (hash message authentication code) operations. The minimum
      *   12 HMAC key is 64 bytes. A key longer than 64 bytes does not significantly increase the fu
      *   ss the randomness of the key is considered weak. A key longer than 128 bytes will be hashe
      *   20 DES
      *   Only 7 bits of each byte are used as the actual key. The rightmost bit of each byte will b
      *   because some cryptographic service providers require that a DES key have odd parity in eve
      *   The key size parameter must specify 8.
      *   21 Triple DES
      *   Only 7 bits of each byte are used as the actual key. The rightmost bit of each byte will b
      *   because some cryptographic service providers require that a DES key have odd parity in eve
      *   The key size can be 8, 16, or 24. Triple DES operates on an encryption block by doing a DE
      *   by a DES decrypt, and then another DES encrypt. Therefore, it actually uses three 8-byte D
      *   is 24 bytes in length, the first 8 bytes are used for key 1, the second 8 bytes for key 2,
      *   es for key 3. If the key is 16 bytes in length, the first 8 bytes are used for key 1 and k
      *   8 bytes for key 2. If the key is only 8 bytes in length, it will be used for all 3 keys (e
      *   e operation equivalent to a single DES operation).
      *   22 AES
      *   The key size can be 16, 24, or 32.
      *   23 RC2
      *   The key size can be 1 - 128.
      *   30 RC4-compatible
      *   The key size can be 1 - 256. Because of the nature of the RC4-compatible operation, using
      *   e than one message will severely company security.
      *   50 RSA
      *   The key size specifies the modulus length in bits and must be an even number in the range
      *   RSA public and private key parts are stored in the key record.
      *
     DGenKeyRcd        pr                  extproc('Qc3GenKeyRecord')
     D FileName                      20    const                                Qualified keystore f
     D RecordLabel                   32    const                                Record label
     D KeyType                       10i 0 const                                Key type
     D KeySize                       10i 0 const                                Key size
     D KeyExp                        10i 0 const                                Public key exponent
     D DisFnc                        10i 0 const                                Disallowed function
     D csp                            1    const                                Cryptographic servic
     D cspDevNam                     10    const options(*omit)                 Cryptographic device
     D errCod                         1                                         Error code

     DGenSymKey        pr                  extproc('Qc3GenSymmetricKey')
     D keyType                       10i 0 const                                Key type
     D keySize                       10i 0 const                                Key size
     D keyFormat                      1    const                                Key format
     D keyForm                        1    const                                Key form
     D KEKKey                         1    const                                Key-encrypting key
     D KEKAlg                         8    const                                Key-encrypting algor
     D csp                            1    const                                Cryptographic servic
     D cspDevNam                     10    const options(*omit)                 Cryptographic device
     D KeyString                      1                                         Key string
     D KeyStringLen                  10i 0 const                                Length of area provi
     D KeyLenRtn                     10i 0                                      Length of key string
     D errCod                         1                                         Error code

     DCrtAlgCtx        pr                  extproc('Qc3CreateAlgorithmContext')
     D algD                           1    const                                Algorithm descriptio
     D algFormat                      8    const                                Algor desc format
     D AESctx                         8                                         Algor context token
     D errCod                         1                                         Error code

     DCrtKeyCtx        pr                  extproc('Qc3CreateKeyContext')
     D key                            1    const                                Key string
     D keyLen                        10i 0 const                                Length of key string
     D keyFormat                      1    const                                Key format
     D keyType                       10i 0 const                                Key type
     D keyForm                        1    const                                Key form
     D keyEncKey                      8    const options(*omit)                 Key-encrypting key
     D keyEncAlg                      8    const options(*omit)                 Key-encrypting algor
     D keyTkn                         8                                         Key context token
     D errCod                         1                                         Error code

     DDestroyKeyCtx    pr                  extproc('Qc3DestroyKeyContext')
     D keyTkn                         8    const                                Key context token
     D errCod                         1                                         Error Code

     DDestroyAlgCtx    pr                  extproc('Qc3DestroyAlgorithmContext')
     D AESTkn                         8    const                                Algor context token
     D errCod                         1                                         Error Code

      * Input Parameter
     D P_Lib           s             10a

      * Local variable
     D csp             s              1    inz('0')
     D error           s             10i 0 inz(-1)
     D ok              s             10i 0 inz(0)
     D rtnLen          s             10i 0
     D plainLen        s             10i 0
     D cipherLen       s             10i 0
     D kekTkn          s              8
     D AESctx          s              8
     D AESkctx         s              8
     D KEKctx          s              8
     D FKctx           s              8
     D keySize         s             10i 0
     D keyLen          s             10i 0
     D keyType         s             10i 0
     D keyLenRtn       s             10i 0
     D keyFormat       s              1
     D keyForm         s              1
     D errmsg          s             50a

      * Parameters for QCMDEXC
     D I_Cmd           S            200A
     D I_CmdLen        S             15P 5
      *
      ***********************************************************
      * Main Logic
      ***********************************************************
     C     *Entry        PList
     C                   Parm                    P_Lib

     C                   eval      QUSBPRV = 0
     C                   eval      QC3D040000 = *loval
     C                   eval      QC3KS00 = 'PHENCSTRF ' + P_Lib

      * Create keystore file, PHENCSTRF, and generate a key record with label ENCDTAKEK.
      *
     C                   monitor
     C                   callp     CrtKeyStore( QC3KS00
     C                                         :3                               Master key 3
     C                                         :'*EXCLUDE'
     C                                         :'Keystore file for ENC'
     C                                         :QUSEC)
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   eval      errmsg = 'Error execute in CrtKeyStore API'
     C                   goto      $end
     C                   endif
     C                   endmon

      * Generate AES key record ENCDTAKEK
     C                   eval      keyType = 22                                 AES
     C                   eval      keySize = 16                                 Key Size for AES
     C                   eval      QC3RL = 'ENCDTAKEK'

     C                   monitor
     C                   callp     GenKeyRcd( QC3KS00
     C                                       :QC3RL
     C                                       :keyType                           AES
     C                                       :KeySize                           16 bytes
     C                                       :0                                 0 for AES
     C                                       :0                                 No function disallow
     C                                       :'0'                               Any CSP
     C                                       :*OMIT
     C                                       :QUSEC)                            Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   eval      errmsg = 'Error execute in GenKeyRcd API'
     C                   goto      $end
     C                   endif
     C                   endmon

      * Create a key context for ENCDTAKEK
     C                   eval      keyLen  = %size(QC3D040000)
     C                   eval      keyForm = '0'

     C                   monitor
     C                   callp     CrtKeyCtx( QC3D040000                        Key String
     C                                       :keyLen                            Key Len of Key Str
     C                                       :'4'                               4 = Keystore label
     C                                       :keyType                           22 = AES
     C                                       :keyForm                           0 = Clear
     C                                       :*OMIT                             Key-encrypting key
     C                                       :*OMIT                             Key-encrypt algor
     C                                       :KEKctx                            Key context token
     C                                       :QUSEC)                            Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   eval      errmsg = 'Error execute in CrtKeyCtx API'
     C                   goto      $end
     C                   endif
     C                   endmon

      * Create an AES algorithm context ENCDTAKEK
     C                   eval      QC3D0200 = *loval
     C                   eval      QC3BCA = keyType
     C                   eval      QC3BL = KeySize                              Block Length for AES
     C                   eval      QC3MODE = '1'
     C                   eval      QC3PO = '0'

     C                   monitor
     C                   callp     CrtAlgCtx( QC3D0200                          Algorithm descriptio
     C                                       :'ALGD0200'                        for AES
     C                                       :AESctx                            Algor context token
     C                                       :QUSEC)                            Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   eval      errmsg = 'Error execute in CrtAlgCtx API'
     C                   goto      $end
     C                   endif
     C                   endmon

      * Generate a file key encrypted under ENCDTAKEK
     C                   monitor
     C                   callp     GenSymKey( KeyType                           AES
     C                                       :KeySize                           16=Key Size for AES
     C                                       :'0'                               0=Binary String Key
     C                                       :'1'                               1=Encrypted Key Form
     C                                       :KEKctx                            Key-encrypting key
     C                                       :AESctx                            Key-encrypt algori
     C                                       :'0'                               Any CSP
     C                                       :*OMIT                             Cryptographic device
     C                                       :KEY                               Key String
     C                                       :KeySize                           Length of Key String
     C                                       :keyLenRtn                         Len of Key Str Retur
     C                                       :QUSEC)                            Error Code
     C                   on-error
     C                   if        QUSBAVL > 0
     C                   eval      errmsg = 'Error execute in GenSymKey API'
     C                   goto      $end
     C                   endif
     C                   endmon

      * Open ENCKEYF
     C                   open(e)   ENCKEYF
     C                   if        %error = '1'
     C                   eval      errmsg = 'Error to open file ENCKEYF'
     C                   close     ENCKEYF
     C                   goto      $end
     C                   endif

     C                   write(e)  ENCKEYFR
     C                   if        %error = '1'
     C                   eval      errmsg = 'Error to write record in ENCKEYF'
     C                   goto      $end
     C                   endif

      * Cleanup
     C     $end          Tag
     C                   eval      KEY = *loval
     C                   callp     DestroyKeyCtx( KEKctx: QUSEC)
     C                   callp     DestroyAlgCtx( AESctx: QUSEC)
     C                   close     ENCKEYF

     C                   if        errmsg <> *blank
     C                   Eval      I_Cmd = 'SNDBRKMSG MSG('''
     C                                   + %trim(errmsg) + ''') '
     C                                   + 'TOMSGQ(' + %trim(@JOB) +')'
     C                   Eval      I_CmdLen = %len(%trim(I_Cmd))
     C                   call      'QCMDEXC'
     C                   parm                    I_Cmd
     C                   parm                    I_CmdLen
     C                   endif

     C                   eval      *inlr = *on
