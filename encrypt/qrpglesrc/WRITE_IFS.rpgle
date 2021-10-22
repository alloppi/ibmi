      * Sample RPG program: write_ifs
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
      * CRTRPGMOD MODULE(ALAN/WRITE_IFS) SRCFILE(ALAN/QRPGLESRC)
      *
     H*nomain bnddir('QC2LE')
     H dftactgrp(*no) bnddir('QC2LE')

      * System includes
     D/Copy QSYSINC/QRPGLESRC,QUSEC
     D/Copy QSYSINC/QRPGLESRC,QC3CCI
     D/copy QCPYSRC,IFSIO_H
     D/copy ENCRYPT,ERRNO_H

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
     D clrData                      100    const
     D clrDataSize                   10i 0 const
     D clrDataFmt                     8    const
     D algDesc                        1    const
     D algDescFmt                     8    const
     D keyDesc                        1    const
     D keyDescFmt                     8    const
     D csp                            1    const
     D cspDevNam                     10    const options(*omit)
     D EncDta                       100
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

     DDecryptData      pr                  extproc('Qc3DecryptData')
     D encData                      100    const
     D encDataSize                   10i 0 const
     D algDesc                        1    const
     D algDescFmt                     8    const
     D keyDesc                        1    const
     D keyDescFmt                     8    const
     D csp                            1    const
     D cspDevNam                     10    const options(*omit)
     D clrDta                       100
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

     D fd              S             10I 0
     D wrdata          S             24A
     D rddata          S             80
     D e_rddata        S             80
     D p_rddata        S             80
     D i_rddata        S             80
     D flags           S             10U 0
     D mode            S             10U 0
     D ErrMsg          S            250A
     D Msg             S             50A
     D Len             S             10I 0

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

     c                   eval      rddata = 'TEST'

      * Create a key context for the file key
     C                   eval      keySize = %size(KEY)
     C                   eval      keyFormat = '0'
     C                   eval      keyType = 22
     C                   eval      keyForm = '1'
     C                   callp     CrtKeyCtx( KEY     :keySize  :keyFormat
     C                                       :keyType :keyForm  :KEKctx
     C                                       :AESctx  :FKctx    :QUSEC)

     c                   eval      flags = O_WRONLY + O_CREAT + O_TRUNC

     c                   eval      mode =  S_IRUSR + S_IWUSR
     c                                   + S_IRGRP
     c                                   + S_IROTH

     c                   eval      fd = open('/home/CYA012/ifs/ifs.ENC':
     c                                       flags: mode)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     Print('open() for output: ' + ErrMsg)
     c                   endif

      * Generate an initialization Vector for the customer
     C                   callp     GenPRN( QC3IV :16 :'0' :'0' :QUSEC)

      * Encrypt customer information
     C                   eval      plainLen = %size(rddata)
     C                   eval      cipherLen = %size(e_rddata)
     C                   callp     EncryptData( rddata  :plainLen
     C                                         :'DATA0100' :QC3D0200
     C                                         :'ALGD0200' :FKctx
     C                                         :'KEYD0100' :csp
     C                                         :*OMIT      :e_rddata
     C                                         :cipherLen  :rtnLen
     C                                         :QUSEC)

     c                   if        write(fd: %addr(e_rddata): %size(e_rddata))<1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     Print('open(): ' + ErrMsg)
     c                   endif

      * Open encrypted file
     c                   eval      flags = O_RDONLY

     c                   eval      fd = open('/home/cya012/ifs/ifs.ENC':
     c                                       flags)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     Print('open() for input: ' + ErrMsg)
     c                   endif

     c                   eval      len = read(fd: %addr(i_rddata):
     c                                            %size(i_rddata))
     c                   if        len < 1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     Print('read(): ' + ErrMsg)
     c                   endif

     c                   eval      Msg = 'Length read = ' +
     c                                    %trim(%editc(len:'M'))
     c*    Msg           dsply
     c*                  dsply                   rddata

      * Decrypt customer information
     C                   eval      plainLen = %size(p_rddata)
     C                   eval      cipherLen = %size(i_rddata)
     C                   callp     DecryptData(i_rddata    :cipherLen
     C                                         :QC3D0200   :'ALGD0200'
     C                                         :FKctx      :'KEYD0100'
     C                                         :csp        :*OMIT
     C                                         :p_rddata   :plainLen
     C                                         :rtnLen     :QUSEC)

     c                   callp     close(fd)

      * Cleanup
     C                   eval      rddata = *loval
     C                   eval      e_rddata = *loval
     C                   eval      i_rddata = *loval
     C                   eval      p_rddata = *loval
     C                   callp     DestroyKeyCtx( FKctx   :QUSEC)
     C                   callp     DestroyKeyCtx( KEKctx  :QUSEC)
     C                   callp     DestroyAlgCtx( AESctx  :QUSEC)

     C                   eval      *inlr = *on
     c                   return

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY ENCRYPT,ERRNO_H
