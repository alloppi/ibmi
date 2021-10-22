      * Purpose : Encrypt & Decrypt data -- Success for long data
      *
      * CRTRPGMOD DECRYPTDTA
      * CRTPGM PGM(lib/DECRYPTDTA) BNDSRVPGM(QC3DTAEN QC3PRNG)
      *
      * Encrypt Data (OPM, QC3ENCDT; ILE, Qc3EncryptData) API
      * Service Program Name: QC3DTAEN

      * Decrypt Data (OPM, QC3DECDT; ILE, Qc3DecryptData) API
      * Service Program Name: QC3DTADE

     H DEBUG  OPTION(*SRCSTMT:*NODEBUGIO)
     H DFTACTGRP(*NO)

      */copy qsysinc/qrpglesrc.QC3CCI
     D*******************************************************************
     D*Data definitions
     D*******************************************************************
     D*ALGD0200 algorithm description structure
     DQC3D0200         DS
     D*                                             Qc3 Format ALGD0200
     D QC3BCA                  1      4B 0
     D*                                             Block Cipher Alg
     D QC3BL                   5      8B 0
     D*                                             Block Length
     D QC3MODE                 9      9
     D*                                             Mode
     D QC3PO                  10     10
     D*                                             Pad Option
     D QC3PC                  11     11
     D*                                             Pad Character
     D QC3ERVED               12     12
     D*                                             Reserved
     D QC3MACL                13     16B 0
     D*                                             MAC Length
     D QC3EKS                 17     20B 0
     D*                                             Effective Key Size
     D QC3IV                  21     52
     D*                                             Init Vector
     D*ALGD0300 algorithm description structure
     DQC3D0300         DS
     D*                                             Qc3 Format ALGD0300
     D QC3SCA                  1      4B 0
     D*                                             Stream Cipher Alg
     D*ALGD0400 algorithm description structure
     DQC3D0400         DS
     D*                                             Qc3 Format ALGD0400
     D QC3PKA                  1      4B 0
     D*                                             Public Key Alg
     D QC3PKABF                5      5
     D*                                             PKA Block Format
     D QC3ERVED00              6      8
     D*                                             Reserved
     D QC3SHA                  9     12B 0
     D*                                             Signing Hash Alg
     D*ALGD0500 algorithm description structure
     DQC3D0500         DS
     D*                                             Qc3 Format ALGD0500
     D QC3HA                   1      4B 0
     D*                                             Hash Alg
     D*DATA0200 array data format structure
     DQC3A0200         DS
     D*                                             Qc3 Format DATA0200
     D QC3DP                   1     16*
     D*                                             Data Ptr
     D QC3DL                  17     20B 0
     D*                                             Data Len
     D QC3ERVED01             21     32
     D*                                             Reserved
     D*KEYD0200 key description format structure
     DQC3D020000       DS
     D*                                             Qc3 Format KEYD0200
     D QC3KT                   1      4B 0
     D*                                             Key Type
     D QC3KSL                  5      8B 0
     D*                                             Key String Len
     D QC3KF                   9      9
     D*                                             Key Format
     D QC3ERVED02             10     12             inz(x'000000')
     D*                                             Reserved
     D*QC3KS                  13     13
     D*
     D*                                variable length
     D*******************************************************************

      * API error structure
     D APIERR          DS
     D  ERRPRV                       10I 0 INZ(272)
     D  ERRLEN                       10I 0
     D  EXCPID                        7A
     D  RSRVD2                        1A
     D  EXCPDT                      256A
     D
      * Encrypt Data (OPM, QC3ENCDT; ILE, Qc3EncryptData) API protects
      * data privacy by scrambling clear data into an unintelligible form.
     D Qc3EncryptData  Pr                  ExtProc('Qc3EncryptData')
     D*Qc3EncryptData  Pr                  ExtPgm('QC3ENCDT')
     D clrDta                     32767a
     D clrDtaLen                     10I 0
     D clrDtaFmt                      8
     D algorithm                           like(QC3D0200)
     D algorithmFmt                   8
     D key                                 like(KeyC)
     D keyFmt                         8
     D srvProvider                    1
     D deviceName                    10
     D encryptedData              32767a
     D encryptedBufL                 10I 0
     D encryptedRtnL                 10I 0
     D errcde                              like(APIERR)

      * Decrypt Data (OPM, QC3DECDT; ILE, Qc3DecryptData) API restore
      * encrypted data to a clear (intelligible) form.
     D Qc3DecryptData  Pr                  ExtProc('Qc3DecryptData')
     D*Qc3DecryptData  Pr                  ExtPgm('QC3DECDT')
     D encryptedData              32767a
     D encryptedDtaL                 10I 0
     D algorithm                           like(QC3D0200)
     D algorithmFmt                   8
     D key                                 like(keyC)
     D keyFmt                         8
     D srvProvider                    1
     D deviceName                    10
     D clrDta                     32767a
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

     D PostData        S          32767a   varying
     D clrDta          S          32767a
     D clrDtaLen       S             10I 0
     D clrDtaFmt       S              8    inz('DATA0100')
     D algorithm       S                   like(QC3D0200)
     D algorithmFmt    S              8    inz('ALGD0200')
     D key             S                   like(KeyC)
     D keyFmt          S              8    inz('KEYD0200')
     D srvProvider     S              1    inz('1')
     D deviceName      S             10    inz(*blanks)
     D encryptedData   S          32767a
     D encryptedDtaL   S             10I 0
     D encryptedBufL   S             10I 0
     D encryptedRtnL   S             10I 0
     D clrDtaBufL      S             10I 0
     D clrDtaRtnL      S             10I 0

     D KeyString       S            256
     D KeyC            S            256

     D CBS_ACCT        C                   '01255068505101'
     D USER_ID         C                   'GG01'
     D ECERT_NM        C                   'GG01'
     D ECERT_PW        C                   'Password#1'
     D ACCT_NO         C                   '01287502982474'
     D NEW_PW          C                   '123456789'

     D packageid       s             17a
     D debitAcctNo     s             14a
     D debitCur        s              3a
     D noOfRecord      s              2  0
     D i               s                   Like(noOfRecord)
     D c_noOfRecord    s              2a   varying
     D c_dbtAmt        s             15a   varying
     D debitAmt        s             15a   varying
     D paymentCur      s              3a

     D curdate         s               D
     D curtime         s               T

     d bene            ds                  qualified
     d   array                             dim(50)
     d   dbtAmt                      16a   overlay(array) varying
     d   actNo                       14a   overlay(array:*next) varying
     d   name                        70a   overlay(array:*next) varying
     d   cusRef                      15a   overlay(array:*next) varying inz
     d   valDat                      10a   overlay(array:*next) varying inz

     C*                  Eval      clrDta = 'This is a test.'
      /free
       curdate = %date();
       curtime = %time();

       packageid = %char(curdate:*ISO0) + %char(curtime:*ISO0) + '001';

       debitAcctNo    = '01287502982474';
       debitCur       = 'HKD';
       noOfRecord     = 1;
       c_noOfRecord   = %trim(%editc(noOfRecord: '4'));
       bene.dbtAmt(1) = '0.01';
       bene.actNo(1)  = '01287502978125';
       bene.name(1)   = 'ABC TRAVEL';
       bene.cusRef(1) = 'CUSREF';
       bene.valDat(1) = '2017/01/23';

       postData =
         '<?xml version="1.0" encoding="utf-8" ?>'                            +
         '<BOCHKE2B>'                                                         +
            '<Head>'                                                          +
               '<PackageId>' + packageid + '</PackageId>'                     +
               '<CBSAcctNo>' + CBS_ACCT + '</CBSAcctNo>'                      +
               '<UserId>' + USER_ID + '</UserId>'                             +
               '<Password>' + NEW_PW + '</Password>'                          +
               '<ECertName>' + ECERT_NM + '</ECertName>'                      +
               '<ECertPwd>' + ECERT_PW + '</ECertPwd>'                        +
            '</Head>'                                                         +
            '<Tx>'                                                            +
               '<TransferREQ>'                                                +
                  '<DebitAcctNo>' + debitAcctNo + '</DebitAcctNo>'            +
                  '<DebitCur>' + debitCur + '</DebitCur>'                     +
                  '<Requests noOfRecord="' + c_noOfRecord + '">'              ;

                     for i = 1 to noOfRecord;
                     postData = postData +
                     '<Record>'                                               +
                        '<InternalTrans>'                                     +
                           '<DebitAmt>' + bene.dbtAmt(i) + '</DebitAmt>'      +
                           '<BeneAcctNo>' + bene.actNo(i) + '</BeneAcctNo>'   +
                           '<BeneAcctName>' + bene.name(i) + '</BeneAcctName>'+
                           '<PaymentCur>' + debitCur + '</PaymentCur>'        +
                           '<CustRef>' + bene.cusRef(i) + '</CustRef>'        +
                           '<ValueDate>'+%trim(bene.valDat(i))+'</ValueDate>' +
                        '</InternalTrans>'                                    +
                     '</Record>'                                              ;
                     endfor;

                  postData = postData +
                  '</Requests>'                                               +
               '</TransferREQ>'                                               +
            '</Tx>'                                                           +
         '</BOCHKE2B>'                                                        ;

      /end-free
     C                   Eval      clrDta = PostData
     C                   Eval      clrDtaLen = %len(%trim(clrDta))
     C                   Eval      encryptedBufL = %size(encryptedData)
     C* Block cipher algorithm
      * 20 DES
      * 21 Triple DES
      * 22 AES
     C                   Eval      QC3BCA = 20
      * Block length
      *  8  DES
      *  8  Triple DES
      * 16  AES
     C                   Eval      QC3BL  = 8
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
     C                   Reset                   encryptedData
     C                   Eval      encryptedBufL = %len(encryptedData)

     C*                  Eval      algorithm = %addr(QC3D0200)
     C                   Eval      algorithm = QC3D0200
      * Key Type            KeyFormat  KeyLength
      * 20 DES                     0          8(7 bits used,rightmost setbit
      * 21 Triple DES              0    8,16,24(7 bits used,rigt setbit
      * 22 AES                     0   16,24,32
      * 30 RC4-compatible          0    1<->256
      * 50 RSA public              1
      * 51 RSA private             1
     C                   Eval      QC3KT = 20

      * Key Format
     C                   Eval      QC3KF = '0'
      * Key String
     C                   Eval      KeyString = '12345678'
     C*                  Eval      PrnDtaLen = 8
     C*                  callP     Qc3GenPRNs(
     C*                               PrnDta        :
     C*                               PrnDtaLen     :
     C*                               PrnType       :
     C*                               PrnParity     :
     C*                               APIERR
     C*                            )
     C*                  ExSr      ChkErrCde
     C*                  Eval      KeyString = %SubSt(PrnDta :
     C*                                                1 : PrnDtaLen)
      * Key Length
     C                   Eval      QC3KSL = %len(%trim(KeyString))
     C                   Eval      KeyC = QC3D020000 + %trim(KeyString)
     C*                  Eval      Key  = %addr(KeyC)
     C                   Eval      Key  = KeyC


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
     C                   ExSr      ChkErrCde

     C                   Reset                   clrDta
     C                   Eval      encryptedDtaL = encryptedRtnL
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
     C                   ExSr      ChkErrCde
     C                   dump

     C                   Eval      *InLr = *On

     C     ChkErrCde     BegSr
     C                   If        ERRLEN > 0
     C     EXCPID        DSPLY
     C                   EndIf
     C                   EndSr

