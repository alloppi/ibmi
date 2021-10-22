      * Sample RPG program: setup_cus
      * Purpose           : Setting up keys
      *
      * http://www.ibm.com/support/knowledgecenter/ssw_ibm_i_72/apis/qc3SetupCusILERPG.htm
      *
      * COPYRIGHT 5722-SS1 (c) IBM Corp 2006
      *
      * This material contains programming source code for your
      * consideration.  These examples have not been thoroughly
      * tested under all conditions.  IBM, therefore, cannot
      * guarantee or imply reliability, serviceability, or function
      * of these programs.  All programs contained herein are
      * provided to you "AS IS".  THE IMPLIED WARRANTIES OF
      * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
      * EXPRESSLY DISCLAIMED.  IBM provides no program services for
      * these programs and files.
      *
      * Description: This is a sample program to demonstrate use
      * of the Cryptographic Services APIs.  APIs demonstrated in
      * this program are:
      *      Create Keystore
      *      Generate Key Record
      *      Create Key Context
      *      Create Algorithm Context
      *      Generate Symmetric Key
      *      Destroy Key Context
      *      Destroy Algorithm Context
      *
      * Function:
      *  Create CUSDTA file for storing customer information
      *  Create CUSPI file for storing info needed to process CUSDTA file.
      *  Create keystore file, CUSKEYFILE.
      *  Create a KEK in CUSKEYFILE with label CUSDTAKEK.
      *  Generate a key encrypted under CUSDTAKEK and store in CUSPI.
      *
      * Refer to the i5/OSÂ® Information Center for a full
      * description of this scenario.
      *
      * Use the following command to compile this program:
      * CRTRPGMOD MODULE(ALAN/SETUP_CUS) SRCFILE(ALAN/QRPGLESRC)
      *
     H dftactgrp(*no) bnddir('QC2LE')

     Fcuspi     uf a e             disk    usropn

      * System includes
     D/Copy QSYSINC/QRPGLESRC,QUSEC
     D/Copy QSYSINC/QRPGLESRC,QC3CCI

      * Prototypes
     DCrtKeyStore      pr                  extproc('Qc3CreateKeyStore')
     D FileName                      20    const                                Qualified key store file name (lib+file)
     D KeyID                         10i 0 const                                Master key ID
     D PublicAuth                    10    const                                Public authority
     D Description                   50    const                                Text description
     D errCod                         1                                         Error code

      * Key type
      *   INPUT; BINARY(4)
      *   The type of key.
      *   Following are the valid values.
      *   1 MD5
      *   An MD5 key is used for HMAC (hash message authentication code) operations. The minimum length for an MD5 HMAC
      *   key is 16 bytes. A key longer than 16 bytes does not significantly increase the function strength unless the
      *   randomness of the key is considered weak. A key longer than 64 bytes will be hashed before it is used.
      *   2 SHA-1
      *   An SHA-1 key is used for HMAC (hash message authentication code) operations. The minimum length for an SHA-1 H
      *   MAC key is 20 bytes. A key longer than 20 bytes does not significantly increase the function strength unless t
      *   he randomness of the key is considered weak. A key longer than 64 bytes will be hashed before it is used.
      *   3 SHA-256
      *   An SHA-256 key is used for HMAC (hash message authentication code) operations. The minimum length for an SHA-2
      *   56 HMAC key is 32 bytes. A key longer than 32 bytes does not significantly increase the function strength unle
      *   ss the randomness of the key is considered weak. A key longer than 64 bytes will be hashed before it is used.
      *   4 SHA-384
      *   An SHA-384 key is used for HMAC (hash message authentication code) operations. The minimum length for an SHA-3
      *   84 HMAC key is 48 bytes. A key longer than 48 bytes does not significantly increase the function strength unle
      *   ss the randomness of the key is considered weak. A key longer than 128 bytes will be hashed before it is used.
      *   5 SHA-512
      *   An SHA-512 key is used for HMAC (hash message authentication code) operations. The minimum length for an SHA-5
      *   12 HMAC key is 64 bytes. A key longer than 64 bytes does not significantly increase the function strength unle
      *   ss the randomness of the key is considered weak. A key longer than 128 bytes will be hashed before it is used.
      *   20 DES
      *   Only 7 bits of each byte are used as the actual key. The rightmost bit of each byte will be set to odd parity
      *   because some cryptographic service providers require that a DES key have odd parity in every byte.
      *   The key size parameter must specify 8.
      *   21 Triple DES
      *   Only 7 bits of each byte are used as the actual key. The rightmost bit of each byte will be set to odd parity
      *   because some cryptographic service providers require that a DES key have odd parity in every byte.
      *   The key size can be 8, 16, or 24. Triple DES operates on an encryption block by doing a DES encrypt, followed
      *   by a DES decrypt, and then another DES encrypt. Therefore, it actually uses three 8-byte DES keys. If the key
      *   is 24 bytes in length, the first 8 bytes are used for key 1, the second 8 bytes for key 2, and the third 8 byt
      *   es for key 3. If the key is 16 bytes in length, the first 8 bytes are used for key 1 and key 3, and the second
      *   8 bytes for key 2. If the key is only 8 bytes in length, it will be used for all 3 keys (essentially making th
      *   e operation equivalent to a single DES operation).
      *   22 AES
      *   The key size can be 16, 24, or 32.
      *   23 RC2
      *   The key size can be 1 - 128.
      *   30 RC4-compatible
      *   The key size can be 1 - 256. Because of the nature of the RC4-compatible operation, using the same key for mor
      *   e than one message will severely compromise security.
      *   50 RSA
      *   The key size specifies the modulus length in bits and must be an even number in the range 512 - 4096. Both the
      *   RSA public and private key parts are stored in the key record.
      *
     DGenKeyRcd        pr                  extproc('Qc3GenKeyRecord')
     D FileName                      20    const                                Qualified keystore file name
     D RecordLabel                   32    const                                Record label
     D KeyType                       10i 0 const                                Key type
     D KeySize                       10i 0 const                                Key size
     D KeyExp                        10i 0 const                                Public key exponent
     D DisFnc                        10i 0 const                                Disallowed function
     D csp                            1    const                                Cryptographic service provider
     D cspDevNam                     10    const options(*omit)                 Cryptographic device name
     D errCod                         1                                         Error code

     DGenSymKey        pr                  extproc('Qc3GenSymmetricKey')
     D keyType                       10i 0 const                                Key type
     D keySize                       10i 0 const                                Key size
     D keyFormat                      1    const                                Key format
     D keyForm                        1    const                                Key form
     D KEKKey                         1    const                                Key-encrypting key
     D KEKAlg                         8    const                                Key-encrypting algorithm
     D csp                            1    const                                Cryptographic service provider
     D cspDevNam                     10    const options(*omit)                 Cryptographic device name
     D KeyString                      1                                         Key string
     D KeyStringLen                  10i 0 const                                Length of area provided for key string
     D KeyLenRtn                     10i 0                                      Length of key string returned
     D errCod                         1                                         Error code

     DCrtAlgCtx        pr                  extproc('Qc3CreateAlgorithmContext')
     D algD                           1    const
     D algFormat                      8    const
     D AESctx                         8
     D errCod                         1

     DCrtKeyCtx        pr                  extproc('Qc3CreateKeyContext')
     D key                            1    const                                Key string
     D keySize                       10i 0 const                                Length of key string
     D keyFormat                      1    const                                Key format
     D keyType                       10i 0 const                                Key type
     D keyForm                        1    const                                Key form
     D keyEncKey                      8    const options(*omit)                 Key-encrypting key
     D keyEncAlg                      8    const options(*omit)                 Key-encrypting algorithm
     D keyTkn                         8                                         Key context token
     D errCod                         1                                         Error code

     DDestroyKeyCtx    pr                  extproc('Qc3DestroyKeyContext')
     D keyTkn                         8    const
     D errCod                         1

     DDestroyAlgCtx    pr                  extproc('Qc3DestroyAlgorithmContext')
     D AESTkn                         8    const
     D errCod                         1

     DPrint            pr            10i 0 extproc('printf')
     D charString                     1    const options(*nopass)

     DSystem           pr            10i 0 extproc('system')
     D Cmd                             *   value options(*string)

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
     D keyType         s             10i 0
     D keyLen          s             10i 0
     D keyFormat       s              1
     D keyForm         s              1
     D inCusInfo       s             80
     D inCusNum        s              8  0
     D ECUSDTA         s             80

     C                   eval      QUSBPRV = 0
      * Create file CUSDTA; used for storing customer information
     C*                  callp     system('CRTPF ALAN/CUSDTA AUT(*EXCLUDE)')
     C                   callp     system('CRTPF FILE(ALAN/CUSDTA) SRCFILE(ENCR-
     C                             YPT) AUT(*EXCLUDE)')

      * Create file CUSPI, used for processing file CUSDTA
     C*                  callp     system('CRTPF ALAN/CUSPI AUT(*EXCLUDE)')
     C                   callp     system('CRTPF FILE(ALAN/CUSPI) SRCFILE(ENCR-
     C                             YPT) AUT(*EXCLUDE)')

      * Create keystore file, CUSKEYFILE, and generate a key record
      * with label CUSDTAKEK.
     C                   eval      QC3D040000 = *loval
     C                   eval      QC3KS00 = 'CUSKEYFILEALAN'
     C                   callp     CrtKeyStore( QC3KS00    :3
     C                                         :'*EXCLUDE'
     C                                         :'Keystore for CUSDTA,CUSPI'
     C                                         :QUSEC)

      * Generate AES key record CUSDTAKEK
     C                   eval      QC3RL = 'CUSDTAKEK'
     C                   callp     GenKeyRcd( QC3KS00     :QC3RL
     C                                       :22          :16
     C                                       :0           :0
     C                                       :'0'         :*OMIT
     C                                       :QUSEC)

      * Create a key context for CUSDTAKEK
     C                   eval      keySize = %size(QC3D040000)
     C                   eval      keyType = 22
     C                   eval      keyForm = '0'
     C                   callp     CrtKeyCtx( QC3D040000 :keySize :'4'
     C                                       :keyType    :keyForm :*OMIT
     C                                       :*OMIT      :KEKctx  :QUSEC)

      * Create an AES algorithm context CUSDTAKEK
     C                   eval      QC3D0200 = *loval
     C                   eval      QC3BCA = keyType
     C                   eval      QC3BL = 16
     C                   eval      QC3MODE = '1'
     C                   eval      QC3PO = '0'
     C                   callp     CrtAlgCtx( QC3D0200 :'ALGD0200'
     C                                       :AESctx   :QUSEC)
     C

      * Generate a file key encrypted under CUSDTAKEK
     C                   callp     GenSymKey( keyType     :16
     C                                       :'0'         :'1'
     C                                       :KEKctx      :AESctx
     C                                       :'0'         :*OMIT
     C                                       :KEY         :16
     C                                       :keyLen      :QUSEC)

      * Write record with encrypted key file key to CUSPI
     C                   eval      LASTCUS = 0

      * Open CUSPI
     C                   open(e)   cuspi
     C                   if        %error = '1'
     C                   callp     Print('Open of CUSPI file failed')
     C                   close     cuspi
     C*                  return    error
     C                   endif
     C                   write(e)  cuspirec
     C                   if        %error = '1'
     C                   callp     Print('Error occurred writing -
     C                                   record to CUSPI file')
     C                   endif

      * Cleanup
     C                   eval      KEY = *loval
     C                   callp     DestroyKeyCtx( KEKctx  :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx  :QUSEC)
     C                   close     cuspi
     C                   eval      *inlr = *on
