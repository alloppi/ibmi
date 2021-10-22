      * Purpose : Encryption and Decryption
      *
     H dftactgrp(*no)
      *******************************************************************
      *Data definitions
      *******************************************************************
      *ALGD0200 algorithm description structure
     DQC3D0200         DS
      *                                             Qc3 Format ALGD0200
     D QC3BCA                  1      4B 0
      *                                             Block Cipher Alg
     D QC3BL                   5      8B 0
      *                                             Block Length
     D QC3MODE                 9      9
      *                                             Mode
     D QC3PO                  10     10
      *                                             Pad Option
     D QC3PC                  11     11
      *                                             Pad Character
     D QC3ERVED               12     12
      *                                             Reserved
     D QC3MACL                13     16B 0
      *                                             MAC Length
     D QC3EKS                 17     20B 0
      *                                             Effective Key Size
     D QC3IV                  21     52
      *                                             Init Vector
      *ALGD0300 algorithm description structure
     DQC3D0300         DS
      *                                             Qc3 Format ALGD0300
     D QC3SCA                  1      4B 0
      *                                             Stream Cipher Alg
      *ALGD0400 algorithm description structure
     DQC3D0400         DS
      *                                             Qc3 Format ALGD0400
     D QC3PKA                  1      4B 0
      *                                             Public Key Alg
     D QC3PKABF                5      5
      *                                             PKA Block Format
     D QC3ERVED00              6      8
      *                                             Reserved
     D QC3SHA                  9     12B 0
      *                                             Signing Hash Alg
      *ALGD0500 algorithm description structure
     DQC3D0500         DS
      *                                             Qc3 Format ALGD0500
     D QC3HA                   1      4B 0
      *                                             Hash Alg
      *DATA0200 array data format structure
     DQC3A0200         DS
      *                                             Qc3 Format DATA0200
     D QC3DP                   1     16*
      *                                             Data Ptr
     D QC3DL                  17     20B 0
      *                                             Data Len
     D QC3ERVED01             21     32
      *                                             Reserved
      *KEYD0200 key description format structure
     DQC3D020000       DS
      *                                             Qc3 Format KEYD0200
     D QC3KT                   1      4B 0
      *                                             Key Type
     D QC3KSL                  5      8B 0
      *                                             Key String Len
     D QC3KF                   9      9
      *                                             Key Format
     D QC3ERVED02             10     12             inz(x'000000')
      *                                             Reserved
      *QC3KS                  13     13
      *
      *                                variable length
      *******************************************************************

      * API error structure
     D APIERR          DS
     D  ERRPRV                       10I 0 INZ(272)
     D  ERRLEN                       10I 0
     D  EXCPID                        7A
     D  RSRVD2                        1A
     D  EXCPDT                      256A
     D
      *Encrypt Data (OPM, QC3ENCDT; ILE, Qc3EncryptData) API protects
      *data privacy by scrambling clear data into an unintelligible form.
      *Qc3EncryptData  Pr                  ExtProc('Qc3EncryptData')
     D Qc3EncryptData  Pr                  ExtPgm('QC3ENCDT')
     D clrDta                       100a
     D clrDtaLen                     10I 0
     D clrDtaFmt                      8
     D algorithm                           like(QC3D0200)
     D algorithmFmt                   8
     D key                                 like(KeyC)
     D keyFmt                         8
     D srvProvider                    1
     D deviceName                    10
     D encryptedData                100a
     D encryptedBufL                 10I 0
     D encryptedRtnL                 10I 0
     D errcde                              like(APIERR)

      * Decrypt Data (OPM, QC3DECDT; ILE, Qc3DecryptData) API restores
      * encrypted data to a clear (intelligible) form.
      *Qc3DecryptData  Pr                  ExtProc('Qc3DecryptData')
     D Qc3DecryptData  Pr                  ExtPgm('QC3DECDT')
     D encryptedData                100a
     D encryptedDtaL                 10I 0
     D algorithm                           like(QC3D0200)
     D algorithmFmt                   8
     D key                                 like(keyC)
     D keyFmt                         8
     D srvProvider                    1
     D deviceName                    10
     D clrDta                       100a
     D clrDtaBufL                    10I 0
     D clrDtaRtnL                    10I 0
     D errcde                              like(APIERR)

     DQc3GenPRNs       Pr                  ExtPRoc('Qc3GenPRNs')
     D PrnDta                       512
     D PrnDtaLen                     10I 0
     D PrnType                        1
     D PrnParity                      1
     D errcde                              like(APIERR)

     D PrnDta          S            512
     D PrnDtaLen       S             10I 0
     D PrnType         S              1    inz('1')
     D PrnParity       S              1    inz('1')

     D clrDta          S            100a
     D clrDtaLen       S             10I 0
     D clrDtaFmt       S              8    inz('DATA0100')
     D algorithm       S                   like(QC3D0200)
     D algorithmFmt    S              8    inz('ALGD0200')
     D key             S                   like(KeyC)
     D keyFmt          S              8    inz('KEYD0200')
     D srvProvider     S              1    inz('1')
     D deviceName      S             10    inz(*blanks)
     D encryptedData   S            100a
     D encryptedDtaL   S             10I 0
     D encryptedBufL   S             10I 0
     D encryptedRtnL   S             10I 0
     D clrDtaBufL      S             10I 0
     D clrDtaRtnL      S             10I 0

     D KeyString       S            256
     D KeyC            S            256
     D PACTION         S              1
     D pclrDta         S            100a
     D pencdta         S            100a
     D pKeyString      S            256

     C                   Eval      pClrDta = 'TEST'
     C                   Eval      pAction = 'E'
     C                   Eval      pKeyString = 'SECRET'
     C* Block cipher algorithm
      * 20 DES
      * 21 Triple DES
      * 22 AES
     C                   Eval      QC3BCA = 22
      *Block length
      *  8  DES
      *  8  Triple DES
      * 16  AES
     C                   Eval      QC3BL  = 16
      *Mode
      * 0 ECB
      * 1 CBC
      * 2 OFB. Not valid with AES.
      * 3 CFB 1-bit. Not valid with AES.
      * 4 CFB 8-bit. Not valid with AES.
      * 5 CFB 64-bit. Not valid with AES
     C                   Eval      QC3MODE = '1'
      * Pad Option
      * 0 No padding is performed.
      * 1 Use the character specified in the pad character field for padding
      * 2 The pad counter is used as the pad character.
     C                   Eval      QC3PO   = '1'

      * Pad Character
     C                   Eval      QC3PC   = X'00'
      * Reserved
     C                   Eval      QC3ERVED = X'00'
      * MAC Length
      * This field is not used on an encrypt operation and must be set to
      * null(binary 0s).
     C                   Eval      QC3MACL  = X'00000000'
      * Effective key size
      * This field must be set to 0.
     C                   Eval      QC3EKS   = 0
      * Initialization vector
      * The initialization vector (IV). An IV is not used for mode ECB,
      * and must be set to NULL (binary 0s).
     C                   Eval      QC3IV = *AllX'00'
     C***                Reset                   encryptedData
     C****               Eval      encryptedBufL = %len(encryptedData)

     C*                  Eval      algorithm = %addr(QC3D0200)
     C                   Eval      algorithm = QC3D0200
      * Key Type            KeyFormat  KeyLength
      * 20 DES                     0          8(7 bits used,rightmost setbit
      * 21 Triple DES              0    8,16,24(7 bits used,rightmost setbit
      * 22 AES                     0   16,24,32
      * 30 RC4-compatible          0    1<->256
      * 50 RSA public              1
      * 51 RSA private             1
     C                   Eval      QC3KT = 22

      * Key Format
     C                   Eval      QC3KF = '0'
      * Key String
     C                   Eval      KeyString = pKeyString
      * Key Length
     C                   Eval      QC3KSL = %len(%trim(KeyString))
     C                   Eval      KeyC = QC3D020000 + %trim(KeyString)
     C                   Eval      Key  = KeyC


      * Encrypt
     C                   Select
     C                   When      pAction = 'E'
     C                   Eval      clrDta = pClrDta
     C                   Eval      clrDtaLen = %len(%trim(clrDta))
     C                   Eval      EncryptedData = *blanks
     C                   Eval      encryptedBufL = %size(encryptedData)
     C                   callP     Qc3EncryptData(
     C                                clrDta        :
     C                                clrDtaLen     :
     C                                clrDtaFmt     :
     C                                algorithm     :
     C                                algorithmFmt  :
     C                                key           :
     C                                keyFmt        :
     C                                srvProvider   :
     C                                deviceName    :
     C                                encryptedData :
     C                                encryptedBufL :
     C                                encryptedRtnL :
     C                                APIERR
     C                             )
     C****               ExSr      ChkErrCde
     C                   Eval      pEncDta = EncryptedData
      *
      * Decrypt
     C                   Eval      pAction = 'D'
     C                   When      pAction = 'D'
     C****               Eval      EncryptedData = %Trim(pEncDta)
     C                   Eval      EncryptedData = pEncDta
     C                   Eval      EncryptedDtaL = %len(%trim(EncryptedData))
     c                   If        EncryptedDtaL <> 16
     C                   Eval      EncryptedDtaL = 32
     C                   Endif
     C                   Eval      clrDta = *blanks
     C                   Eval      clrDtaBufL = %size(clrDta)
     C                   callP     Qc3DecryptData(
     C                                encryptedData :
     C                                encryptedDtaL :
     C                                algorithm     :
     C                                algorithmFmt  :
     C                                key           :
     C                                keyFmt        :
     C                                srvProvider   :
     C                                deviceName    :
     C                                clrDta        :
     C                                clrDtaBufL    :
     C                                clrDtaRtnL    :
     C                                APIERR
     C                             )
     C****               ExSr      ChkErrCde
     C                   Eval      pclrDta = ClrDta

     C                   Other
     C                   Eval      *InLr = *On
     C                   Endsl

     C                   Return
     **********************************************************************
