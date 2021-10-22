      * Sample RPG program: bill_cus
      * Purpose           : Reading encrypted data to a file
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
      * Description: This is a sample program to demonstrate use
      * of the Cryptographic Services APIs.  APIs demonstrated in
      * this program are:
      *      Create Algorithm Context
      *      Create Key Context
      *      Decrypt Data
      *      Destroy Key Context
      *      Destroy Algorithm Context
      *
      * Function: For each record in the Customer Data file (CUSDTA),
      * check the accounts receivable balance.  If there is a balance
      * decrypt the customers data and call bill_cus to create a bill.
      * The customer data is encrypted with a file key kept in the
      * Customer Processing Information file (CUSPI).
      *
      * Refer to the IBMÂ® i Information Center for a full
      * description of this scenario.
      *
      * Use the following command to compile this program:
      * CRTRPGMOD MODULE(MY_LIB/BILL_CUS) SRCFILE(MY_LIB/QRPGLESRC)
      *
     H nomain bnddir('QC2LE')

     Fcuspi     uf   e             disk    usropn
     Fcusdta    uf a e             disk    prefix(C) usropn

      * System includes
     D/Copy QSYSINC/QRPGLESRC,QUSEC
     D/Copy QSYSINC/QRPGLESRC,QC3CCI

      * Prototypes
     DBill_Cus         pr            10i 0 extproc('Bill_Cus')

     DCreate_Bill      pr            10i 0 extproc('Create_Bill')
     D cusDta                         1    const
     D balance                       10  2 value

     DCrtAlgCtx        pr                  extproc('Qc3CreateAlgorithmContext')
     D algD                           1    const
     D algFormat                      8    const
     D AESctx                         8
     D errCod                         1

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

     DDestroyKeyCtx    pr                  extproc('Qc3DestroyKeyContext')
     D keyTkn                         8    const
     D errCod                         1

     DDestroyAlgCtx    pr                  extproc('Qc3DestroyAlgorithmContext')
     D AESTkn                         8    const
     D errCod                         1

     DDecryptData      pr                  extproc('Qc3DecryptData')
     D encData                        1    const
     D encDataSize                   10i 0 const
     D algDesc                        1    const
     D algDescFmt                     8    const
     D keyDesc                        1    const
     D keyDescFmt                     8    const
     D csp                            1    const
     D cspDevNam                     10    const options(*omit)
     D clrDta                         1
     D clrLenPrv                     10i 0 const
     D clrLenRtn                     10i 0
     D errCod                         1

     DPrint            pr            10i 0 extproc('printf')
     D charString                     1    const options(*nopass)

     PBill_Cus         b                   export
     DBill_Cus         pi            10i 0

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
     C                   eval      QC3KS00 = 'CUSKEYFILEMY_LIB'
     C                   eval      QC3RL = 'CUSDTAKEK'
     C                   callp     CrtKeyCtx( QC3D040000 :keySize :'4'
     C                                       :keyType    :keyForm :*OMIT
     C                                       :*OMIT      :KEKctx  :QUSEC)
     C
      * Open CUSPI file
     C                   open(e)   cuspi
     C                   if        %error = '1'
     C                   callp     Print('Open of Customer Processing -
     C                                    Information File (CUSPI) failed')
     C                   return    error
     C                   endif
      * Read first (only) record to get encrypted file key
     C                   read(e)   cuspirec
     C                   if        %eof = '1'
     C                   callp     Print('Customer Processing Information -
     C                                    (CUSPI) record missing')
     C                   close     cuspi
     C                   return    error
     C                   endif
     C                   close     cuspi
      * Create a key context for the file key
     C                   eval      keySize = %size(KEY)
     C                   eval      keyFormat = '0'
     C                   eval      keyType = 22
     C                   eval      keyForm = '1'
     C                   callp     CrtKeyCtx( KEY     :keySize  :keyFormat
     C                                       :keyType :keyForm  :KEKctx
     C                                       :AESctx  :FKctx    :QUSEC)
      * Wipe out the encrypted file key value from program storage
     C                   eval      Key = *loval
      * Open CUSDTA
     C                   open(e)   cusdta
     C                   if        %error = '1'
     C                   callp     Print('Open of CUSDTA file failed')
     C                   close     cuspi
     C                   return    error
     C                   endif
      * Read each record of CUSDTA
     C                   read(e)   cusdtarec
     C                   dow       %eof <> '1'
      * If accounts receivable balance > 0, decrypt customer data and
      * create a bill
     C                   if        CARBAL > 0
      * Decrypt customer information
     C                   eval      QC3IV = CIV
     C                   eval      plainLen = %size(CCUSDTA)
     C                   eval      cipherLen = %size(ECUSDTA)
     C                   callp     DecryptData( CCUSDTA    :cipherLen
     C                                         :QC3D0200   :'ALGD0200'
     C                                         :FKctx      :'KEYD0100'
     C                                         :csp        :*OMIT
     C                                         :ECUSDTA    :plainLen
     C                                         :rtnLen     :QUSEC)
     C                   callp     Create_Bill( ECUSDTA :CARBAL)
     C                   endif
     C                   read(e)   cusdtarec
     C                   enddo
      * Cleanup
     C                   eval      ecusdta = *loval
     C                   callp     DestroyKeyCtx( FKctx  :QUSEC)
     C                   callp     DestroyKeyCtx( KEKctx :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx  :QUSEC)
     C                   close     cusdta
     C                   return    ok

     P                 e
