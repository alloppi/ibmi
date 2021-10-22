      * Sample RPG program: read_ifs
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
      * decrypt the customers data and call read_ifs to create a bill.
      * The customer data is encrypted with a file key kept in the
      * Customer Processing Information file (CUSPI).
      *
      * Refer to the IBMÂ® i Information Center for a full
      * description of this scenario.
      *
      * Use the following command to compile this program:
      * CRTRPGMOD MODULE(ALAN/read_ifs) SRCFILE(ALAN/QRPGLESRC)
      *
     H*nomain bnddir('QC2LE')
     H dftactgrp(*no) bnddir('QC2LE')

      * System includes
     D/Copy QSYSINC/QRPGLESRC,QUSEC
     D/Copy QSYSINC/QRPGLESRC,QC3CCI
     D/copy QCPYSRC,IFSIO_H
     D/copy ENCRYPT,ERRNO_H

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
     D inCusInfo       s             80
     D inCusNum        s              8  0
     D ECUSDTA         s             80

     D fd              S             10I 0
     D rddata          S             80A
     D e_rddata        S             80A
     D flags           S             10U 0
     D mode            S             10U 0
     D ErrMsg          S            250A
     D Msg             S             50A
     D Len             S             10I 0

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
     C
     c                   eval      flags = O_RDONLY

     c                   eval      fd = open('/home/cya012/ifs/ifs.ENC':
     c                                       flags)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     Print('open() for input: ' + ErrMsg)
     c                   endif

     c                   eval      len = read(fd: %addr(rddata):
     c                                            %size(rddata))
     c                   if        len < 1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     Print('read(): ' + ErrMsg)
     c                   endif

     c                   eval      Msg = 'Length read = ' +
     c                                    %trim(%editc(len:'M'))
     c     Msg           dsply
     c*                  dsply                   rddata

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

      * Decrypt customer information
     C                   eval      plainLen = %size(rddata)
     C                   eval      cipherLen = %size(e_rddata)
     C                   callp     DecryptData( rddata     :cipherLen
     C                                         :QC3D0200   :'ALGD0200'
     C                                         :FKctx      :'KEYD0100'
     C                                         :csp        :*OMIT
     C                                         :e_rddata   :plainLen
     C                                         :rtnLen     :QUSEC)

     c                   callp     close(fd)

      * Cleanup
     C                   eval      e_rddata = *loval
     C                   callp     DestroyKeyCtx( FKctx  :QUSEC)
     C                   callp     DestroyKeyCtx( KEKctx :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx  :QUSEC)

     c                   eval      *inlr = *on
     c                   return

      *DEFINE ERRNO_LOAD_PROCEDURE
      *COPY IFSEBOOK/QRPGLESRC,ERRNO_H
      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QIFSSRC,ERRNO_H
