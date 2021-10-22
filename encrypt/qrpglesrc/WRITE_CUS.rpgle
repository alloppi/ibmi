      * Sample RPG program: write_cus
      * Example in ILE RPG: Writing encrypted data to a file
      *
      * http://www.ibm.com/support/knowledgecenter/ssw_ibm_i_72/apis/qc3WriteCusILERPG.htm
      *
      * COPYRIGHT 5722-SS1, 5761-SS1 (c) IBM Corp 2004, 2008
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
      *
      * Description: This is a sample program to demonstrate use
      * of the Cryptographic Services APIs.  APIs demonstrated in
      * this program are:
      *      Create Algorithm Context
      *      Create Key Context
      *      Generate Pseudorandom Numbers
      *      Encrypt Data
      *      Destroy Key Context
      *      Destroy Algorithm Context
      *
      * Function: Get customer information, encrypt it, and write it
      * to the Customer Data file (CUSDTA).  The file key is kept
      * in the Customer Processing Information file (CUSPI).
      *
      * Refer to the i5/OSÂ® Information Center for a full
      * description of this scenario.
      *
      * Use the following command to compile this program:
      * CRTRPGMOD MODULE(ALAN/WRITE_CUS) SRCFILE(ALAN/QRPGLESRC)
      *
     H*nomain bnddir('QC2LE')
     H dftactgrp(*no) bnddir('QC2LE')

     Fcuspi     uf   e             disk    usropn
     Fcusdta    uf a e             disk    prefix(C) usropn

      * System includes
     D/Copy QSYSINC/QRPGLESRC,QUSEC
     D/Copy QSYSINC/QRPGLESRC,QC3CCI

      * Prototypes
     D*Write_Cus        pr            10i 0 extproc('Write_Cus')

     D Get_Customer_Info...
     D                 pr                  extproc('Get_Customer_Info')
     D inCusInfo                      1
     D inCusNbr                       8  0

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

      * Encrypt customer information
     DEncryptData      pr                  extproc('Qc3EncryptData')
     D clrData                        1    const
     D clrDataSize                   10i 0 const
     D clrDataFmt                     8    const
     D algDesc                        1    const
     D algDescFmt                     8    const
     D keyDesc                        1    const
     D keyDescFmt                     8    const
     D csp                            1    const
     D cspDevNam                     10    const options(*omit)
     D EncDta                         1
     D DtaLenPrv                     10i 0 const
     D DtaLenRtn                     10i 0
     D errCod                         1

      * Generate an initialization Vector for the customer
     DGenPRN           pr                  extproc('Qc3GenPRNs')
     D PRNData                        1
     D PRNDataLen                    10i 0 const
     D PRNType                        1    const
     D PRNParity                      1    const
     D errCod                         1

     DPrint            pr            10i 0 extproc('printf')
     D charString                     1    const options(*nopass)

     P*Write_Cus        b                   export
     D*Write_Cus        pi            10i 0

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
     D inCusInfo       s             80
     D inCusNum        s              8  0
     D ECUSDTA         s             80

     C                   eval      rtn = ok
     C                   eval      QUSBPRV = 0

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

      * Open CUSPI file
     C                   open(e)   cuspi
     C                   if        %error = '1'
     C                   callp     Print('Open of Customer Processing -
     C                                    Information File (CUSPI) failed')
     C*                  return    error
     C                   endif

      * Read first (only) record to get encrypted file key
     C                   read(e)   cuspirec
     C                   if        %eof = '1'
     C                   callp     Print('Customer Processing Information -
     C                                    (CUSPI) record missing')
     C                   close     cuspi
     C*                  return    error
     C                   endif

      * Create a key context for the file key
     C                   eval      keySize = %size(KEY)
     C                   eval      keyFormat = '0'
     C                   eval      keyType = 22
     C                   eval      keyForm = '1'
     C                   callp     CrtKeyCtx( KEY     :keySize  :keyFormat
     C                                       :keyType :keyForm  :KEKctx
     C                                       :AESctx  :FKctx    :QUSEC)

      * Open CUSDTA
     C                   open(e)   cusdta
     C                   if        %error = '1'
     C                   callp     Print('Open of CUSDTA file failed')
     C                   close     cuspi
     C*                  return    error
     C                   endif
      * Get customer information and customer number
     C                   callp     Get_Customer_Info(inCusInfo :inCusNum)
     C                   read      CUSDTAREC

      * Repeat loop until no more customers to add/update
     C                   dow       inCusNum <> 99999999

      * Generate an initialization Vector for the customer
     C                   callp     GenPRN( QC3IV :16 :'0' :'0' :QUSEC)

      * Encrypt customer information
     C                   eval      plainLen = %size(CCUSDTA)
     C                   eval      cipherLen = %size(CCUSDTA)
     C                   callp     EncryptData( inCusInfo  :plainLen
     C                                         :'DATA0100' :QC3D0200
     C                                         :'ALGD0200' :FKctx
     C                                         :'KEYD0100' :csp
     C                                         :*OMIT      :ECUSDTA
     C                                         :cipherLen  :rtnLen
     C                                         :QUSEC)

      * Write customer data to file CUSDTA
     C                   if        inCusNum = 0
     C                   eval      LASTCUS += 1
     C                   eval      CCUSNUM = LASTCUS
     C                   eval      CARBAL = 10
     C                   eval      CCUSDTA = ECUSDTA
     C                   eval      CIV = QC3IV
     C                   write(e)  cusdtarec
     C                   if        %error = '1'
     C                   callp     Print('Error occurred writing -
     C                                   record to CUSDTA file')
     C                   eval      inCusNum = 99999999
     C*                  eval      rtn = error
     C                   endif
     C                   else

      * Read existing customer
     C     inCusNum      chain(e)  cusdtarec
     C                   if        %error = '1'
     C                   callp     Print('Error occurred reading -
     C                                   record in CUSDTA file')
     C                   eval      inCusNum = 99999999
     C*                  eval      rtn = error
     C                   endif
     C                   eval      CIV = QC3IV
     C                   eval      CCUSDTA = ECUSDTA
     C                   update(e) cusdtarec
     C                   if        %error = '1'
     C                   callp     Print('Error occurred updating -
     C                                   record in CUSDTA file')
     C                   eval      inCusNum = 99999999
     C*                  eval      rtn = error
     C                   endif
     C                   endif
     C                   if        rtn = ok
     C                   callp     Get_Customer_Info(inCusInfo :inCusNum)
     C                   endif
     C                   enddo
     C                   update(e) cuspirec
     C                   if        %error = '1'
     C                   callp     Print('Error occurred updating -
     C                                   record in CUSPI file')
     C                   endif

      * Cleanup
     C                   eval      inCusInfo = *loval
     C                   callp     DestroyKeyCtx( FKctx   :QUSEC)
     C                   callp     DestroyKeyCtx( KEKctx  :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx  :QUSEC)
     C                   close     cusdta
     C                   close     cuspi
     C*                  return    rtn

     C                   eval      *inlr = *on
