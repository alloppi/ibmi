      * Sample RPG program: ENCRYPT2
      * Example in ILE RPG: Writing and Reading encrypted data to a file
      * http://www.ibm.com/support/knowledgecenter/ssw_ibm_i_72/apis/qc3WriteCusILERPG.htm
      * http://www.code400.com/forum/forum/tips-techniques-tools-announcements/tips-for-the-iseries-as400/1917-encrypt-d
      * ecrypt-revisited

     H BNDDIR('QC2LE')
     H DFTACTGRP(*NO)
     H OPTION(*NODEBUGIO:*SRCSTMT)

      * System includes
     D/Copy QSYSINC/QRPGLESRC,QUSEC
     D/Copy QSYSINC/QRPGLESRC,QC3CCI
     D/copy QCPYSRC,IFSIO_H
     D/copy ENCRYPT,ERRNO_H

      *------------------------------------------------
      **  E N T R Y   P A R M S                      **
      *------------------------------------------------

     d encrypt2        pr
     d  inmode                        1a
     d  invalue                   32767a
     d  inkey                     32767a
     d  outvalue                  32767a

     d encrypt2        pi
     d  inmode                        1a
     d  invalue                   32767a
     d  inkey                     32767a
     d  outvalue                  32767a

     d workmode        s              1a
     d workinvalue     s          32767a
     d workinkey       s          32767a
     d workoutvalue    s          32767a




      * Create an AES algorithm context for the key-encrypting key (KEK)
     DCrtAlgCtx        pr                  extproc('Qc3CreateAlgorithmContext')
     D algD                           1    const
     D algFormat                      8    const
     D AESctx                         8
     D errCod                         1

      * Create a key context for the key-encrypting key (KEK)
     DCrtKeyCtx        pr                  extproc('Qc3CreateKeyContext')
     D key                            1    const
     D keySize                       10i 0 const
     D keyFormat                      1    const
     D keyType                       10i 0 const
     D keyForm                        1    const
     D keyEncKey                      8    const options(*omit)
     D keyEncAlg                      8    const options(*omit)
     D keyTkn                         8
     D errCod                         1

      * Cleanup key-encrypting key (KEK)
     DDestroyKeyCtx    pr                  extproc('Qc3DestroyKeyContext')
     D keyTkn                         8    const
     D errCod                         1

      * Cleanup key-encrypting key (KEK)
     DDestroyAlgCtx    pr                  extproc('Qc3DestroyAlgorithmContext')
     D AESTkn                         8    const
     D errCod                         1

      *------------------------------------------------
      **  E N C R Y P T   D A T A                    **
      *------------------------------------------------
     D Qc3EncryptData  PR                  ExtProc('Qc3EncryptData')
     D  szClearData               65535A   OPTIONS(*VARSIZE)
     D  nLenClearData                10I 0 Const
     D  clearDataFmt                  8A   Const

     D  AlgoDescript                 64A   Const OPTIONS(*VARSIZE)
     D  szAlgoFormat                  8A   Const

     D  KeyDescriptor               512A   Const OPTIONS(*VARSIZE)
     D  szKeyFormat                   8A   Const

      ** 0=Best choice, 1=Software, 2=Hardware
     D  CryptoService                 1A   Const
      **  Hardware Cryptography device name or *BLANKS
     D  CryptoDevName                10A   Const

     D  szEncryptedData...
     D                            65535A   OPTIONS(*VARSIZE)
     D  nEncryptedDataVarLen...
     D                               10I 0 Const
     D  nEncryptedDataRtnLen...
     D                               10I 0
     D  api_ErrorDS                        LikeDS(API_ErrorDS_T)
     D                                     OPTIONS(*VARSIZE)

      *------------------------------------------------
      **  D E C R Y P T   D A T A                    **
      *------------------------------------------------
     D Qc3DecryptData  PR                  ExtProc('Qc3DecryptData')
     D  szEncData                 65535A   OPTIONS(*VARSIZE)
     D  nLenEncData                  10I 0 Const

     D  AlgoDescript                 64A   Const OPTIONS(*VARSIZE)
     D  szAlgoFormat                  8A   Const

     D  KeyDescriptor               512A   Const OPTIONS(*VARSIZE)
     D  szKeyFormat                   8A   Const

      ** 0=Best choice, 1=Software, 2=Hardware
     D  CryptoService                 1A   Const
      **  Hardware Cryptography device name or *BLANKS
     D  CryptoDevName                10A   Const

     D  szClearData               65535A   OPTIONS(*VARSIZE)
     D  nClearVarLen                 10I 0 Const
     D  nRtnClearLen                 10I 0
     D  api_ErrorDS                        LikeDS(API_ErrorDS_T)
     D                                     OPTIONS(*VARSIZE)
      *------------------------------------------------
      **  Message Digest/Hash
      *------------------------------------------------
     D Qc3CalcHash     PR                  ExtProc('Qc3CalculateHash')
     D  szClearData               65535A   OPTIONS(*VARSIZE)
     D  nLenClearData                10I 0 Const
     D  clearDataFmt                  8A   Const

     D  AlgoDescr                    64A   Const OPTIONS(*VARSIZE)
     D  szAlgoFormat                  8A   Const

      ** 0=Best choice, 1=Software, 2=Hardware
     D  CryptoService                 1A   Const
      **  Hardware Cryptography device name or *BLANKS
     D  CryptoDevName                10A   Const

     D  rtnHash                      64A   OPTIONS(*VARSIZE)
     D  api_ErrorDS                        LikeDS(API_ErrorDS_T)
     D                                     OPTIONS(*VARSIZE)
      *------------------------------------------------
      **  Cryptography API Algorithm ALGD0300 Structure
      *------------------------------------------------
     D ALGD0300_T      DS                  Qualified
     D                                     BASED(DS_TEMPL)
      **  Stream algorithm: 30 = RC4
     D  Algorithm                    10I 0

     D Qc3CreateAlgorithmContext...
     D                 PR                  ExtProc('Qc3CreateAlgorithmContext')
     D  AlgoDescription...
     D                               64A   Const OPTIONS(*VARSIZE)
     D  szAlgoFormat                  8A   Const
     D  contextToken                  8A
     D  api_ErrorDS                        LikeDS(API_ErrorDS_T)
     D                                     OPTIONS(*VARSIZE)
      **  Encryption Data Structures
     D KEYD0100_T      DS                  Qualified
     D                                     BASED(DS_TEMPL)
     D  keyContext                    8A

     D KEYD0200_T      DS                  Qualified
     D                                     BASED(DS_TEMPL)
     D  type                         10I 0
     D  length                       10I 0
     D  format                        1A
     D  value                       256A
      /IF DEFINED(*V5R1M0)
     D API_ErrorDS_T   DS                  Qualified
     D  dsLen                        10I 0 Inz
     D  rtnLen                       10I 0 Inz
     D  cpfMsgID                      7A
     D  apiResv1                      1A   Inz(X'00')
     D  apiExcDta1                   64A
      /ENDIF

      **  New IBM API Error DS
     D XT_api_ErrorEx  DS                  Inz
     D  XT_apiKey                    10I 0
     D  XT_apiDSLen                  10I 0
     D  XT_apiRtnLenEx...
     D                               10I 0
     D  XT_apiMsgIDEx                 7A
     D  XT_apiResvdEx                 1A
     D  XT_apiCCSID                  10I 0
     D  XT_apiOffExc                 10I 0
     D  XT_apiExcLen                 10I 0
     D  XT_apiExcData                64A

     D Qc3DestroyAlgorithmContext...
     D                 PR                  ExtProc('Qc3DestroyAlgorithmContext')
     D  ContextToken                  8A   Const
     D  api_ErrorDS                        LikeDS(API_ErrorDS_T)
     D                                     OPTIONS(*VARSIZE)

     ** API Error Data structure
     D QUSEC_EX        DS                  Qualified
     D                                     Based(TEMPLATE_T)
     D  charKey                      10I 0
     D  nErrorDSLen                  10I 0
     D  nRtnLen                      10I 0
     D  msgid                         7A
     D  Reserved                      1A
     D  CCSID                        10I 0
     D  OffsetExcp                   10I 0
     D  excpLen                      10I 0
     D  excpData                    128A

     D ALGO_DES        C                   Const(20)
     D ALGO_TDES       C                   Const(21)
     D ALGO_AES        C                   Const(22)
     D ALGO_RC4        C                   Const(30)
     D ALGO_RSA_PUB    C                   Const(50)
     D ALGO_RSA_PRIV   C                   Const(51)

     D ANY_CRYPTO_SRV  C                   Const('0')
     D SWF_CRYPTO_SRV  C                   Const('1')
     D HWD_CRYPTO_SRV  C                   Const('2')
     D CRYPTO_SRV      S             10A   Inz(*BLANKS)

      **  Cipher API data structures.
     D myAlgo          DS                  LikeDS(ALGD0300_T)
     D myKey           DS                  LikeDS(KEYD0200_T)
     D apiError        DS                  LikeDS(qusec_ex)

      **  The clear text (data to be encrypted)

      **  The length of the data returned by the APIs
     D nRtnLen         S             10I 0
      **  The encrypted data variable
     D encData         S          65535A

     DPrint            pr            10i 0 extproc('printf')
     D charString                     1    const options(*nopass)

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
     D key             s             16
     D keySize         s             10i 0
     D keyType         s             10i 0
     D keyFormat       s              1
     D keyForm         s              1

     D fd              S             10I 0
     D postData        s          65535a   varying
     D flags           S             10U 0
     D mode            S             10U 0
     D ErrMsg          S            250A
     D Msg             S             50A
     D Len             S             10I 0

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

      * Create an AES algorithm context for the key-encrypting key (KEK)
     C                   eval      QC3D0200 = *loval
     C                   eval      QC3BCA = 22
     C                   eval      QC3BL = 16
     C                   eval      QC3MODE = '1'
     C                   eval      QC3PO = '0'
     C                   callp     CrtAlgCtx( QC3D0200 :'ALGD0200'
     C                                       :AESctx   :QUSEC)

      * Create a key context for the key-encrypting key (KEK)
     C                   eval      keySize = %size(QC3D040000)
     C                   eval      keyFormat = '0'
     C                   eval      keyType = 22
     C                   eval      keyForm = '0'
     C                   eval      QC3D040000 = *loval
     C                   eval      QC3KS00 = 'CUSKEYFILEALAN'
     C                   eval      QC3RL = 'CUSDTAKEK'
     C                   callp     CrtKeyCtx( QC3D040000 :keySize :'4'
     C                                       :keyType    :keyForm :*OMIT
     C                                       :*OMIT      :KEKctx  :QUSEC)

      * Create a key context for the file key
     C                   eval      keySize = %size(KEY)
     C                   eval      keyFormat = '0'
     C                   eval      keyType = 22
     C                   eval      keyForm = '1'
     C                   callp     CrtKeyCtx( KEY     :keySize  :keyFormat
     C                                       :keyType :keyForm  :KEKctx
     C                                       :AESctx  :FKctx    :QUSEC)

      /free
        workinvalue  = invalue;
        workinkey    = inkey;
        workoutvalue = outvalue;


        myAlgo.Algorithm = ALGO_RC4;

        myKey.type   = ALGO_RC4;
        myKey.length = %Len(%TrimR(workinkey));
        myKey.Format = '0';
        myKey.value  = %TrimR(workinkey);
        apiError = *ALLX'00';
        apiError.nErrorDSLen=%size(apiError);



        select;
        when  inmode = 'E';

       curdate = %date();
       curtime = %time();

       packageid = %char(curdate:*ISO0) + %char(curtime:*ISO0) + '001';

       debitAcctNo   = '01287502982474';
       debitCur      = 'HKD';
       noOfRecord    = 1;
       c_noOfRecord  = %trim(%editc(noOfRecord: '4'));
       bene.dbtAmt(1) = '0.01';
       bene.actNo(1)  = '01287502978125';
       bene.name(1)   = 'ABC TRAVEL';
       bene.cusRef(1) = 'CUSREF';
       bene.valDat(1) = '2016/01/17';

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

        workinvalue  = postdata;

        Qc3EncryptData(workinvalue:%len(%TrimR(workinvalue)):'DATA0100':
                          QC3D0200 : 'ALGD0200' :
                          FKctx    : 'KEYD0100' :
                          ANY_CRYPTO_SRV       : CRYPTO_SRV :
                          encData :  %size(encData) : nRtnLen  :
                          apiError );
        outvalue = encData;
        apiError = *ALLX'00';
        apiError.nErrorDSLen=%size(apiError);

      /end-free

     C****************************************************************
     C* Example of writing data to a stream file
     C****************************************************************
     c                   eval      flags = O_WRONLY + O_CREAT + O_TRUNC

     c                   eval      mode =  S_IRUSR + S_IWUSR
     c                                   + S_IRGRP
     c                                   + S_IROTH

     c                   eval      fd = open('/home/cya012/ifs/ifs.ENC':
     c                                       flags: mode)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     die('open() for output: ' + ErrMsg)
     c                   endif

     C* Write encryption data
     c                   if        write(fd: %addr(outvalue): %size(outvalue))<1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     Print('open(): ' + ErrMsg)
     c                   endif

     C* close the file
     c                   callp     close(fd)

      /free
        when  inmode = 'D';
      /end-free
      * Open encrypted file
     c                   eval      flags = O_RDONLY

     c                   eval      fd = open('/home/cya012/ifs/ifs.ENC':
     c                                       flags)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     Print('open() for input: ' + ErrMsg)
     c                   endif

     c                   eval      len = read(fd: %addr(workinvalue):
     c                                            %size(workinvalue))
     c                   if        len < 1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     Print('read(): ' + ErrMsg)
     c                   endif

     c                   eval      inmode = 'D'


      /free
        Qc3DecryptData(workinvalue :  %len(%TrimR(workinvalue)) :
                          QC3D0200 : 'ALGD0200' :
                          FKctx    : 'KEYD0100' :
                          ANY_CRYPTO_SRV        : CRYPTO_SRV :
                          outvalue :  %size(outvalue) : nRtnLen :
                          apiError );


        endsl;

       *inlr = *on;
      /end-free

      * Cleanup
     C                   callp     DestroyKeyCtx( FKctx   :QUSEC)
     C                   callp     DestroyKeyCtx( KEKctx  :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx  :QUSEC)

     C                   eval      *inlr = *on
     c                   return

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY ENCRYPT,ERRNO_H

