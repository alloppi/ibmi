      *------------------------------------------------
      * Purpose: Encrypt & Decrypt data -- Success
      *------------------------------------------------

     H BNDDIR('QC2LE')
     H DFTACTGRP(*NO)
     H OPTION(*NODEBUGIO:*SRCSTMT)

      *------------------------------------------------
      **  E N T R Y   P A R M S                      **
      *------------------------------------------------

     d encrypt         pr
     d  inmode                        1a
     d  invalue                   32767a
     d  inkey                     32767a
     d  outvalue                  32767a

     d encrypt         pi
     d  inmode                        1a
     d  invalue                   32767a
     d  inkey                     32767a
     d  outvalue                  32767a

     d workmode        s              1a
     d workinvalue     s          32767a
     d workinkey       s          32767a
     d workoutvalue    s          32767a




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
     D encData         S            500A

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

        Qc3EncryptData(workinvalue:%len(%TrimR(workinvalue)):'DATA0100':
                          myAlgo  : 'ALGD0300' :
                          myKey   : 'KEYD0200' :
                          ANY_CRYPTO_SRV       : CRYPTO_SRV :
                          encData :  %size(encData) : nRtnLen  :
                          apiError );
        outvalue = encData;
        apiError = *ALLX'00';
        apiError.nErrorDSLen=%size(apiError);



        when  inmode = 'D';
        Qc3DecryptData(workinvalue :  %len(%TrimR(workinvalue)) :
                          myAlgo   : 'ALGD0300' :
                          myKey    : 'KEYD0200' :
                          ANY_CRYPTO_SRV        :     CRYPTO_SRV :
                          outvalue :  %size(outvalue) : nRtnLen :
                          apiError );


        endsl;

       *inlr = *on;
      /end-free


