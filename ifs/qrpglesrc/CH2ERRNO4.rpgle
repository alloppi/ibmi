      * CH2ERRNO2: Example of writing & reading data to a stream file
      *   with error handling.  (This is the same as CH2ERRNO except
      *   with write UTF-8)
      *  (From Chap 2)
      *
      * To compile:
      *   CRTBNDRPG CH2ERRNO2 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D*copy IFSeBOOK/QRPGLESRC,IFSIO_H
     D*copy IFSeBOOK/QRPGLESRC,ERRNO_H
     D/copy QCPYSRC,IFSIO_H
     D/copy QIFSSRC,ERRNO_H

     D fd              S             10I 0
     D postData        s          65535a   varying
     D wrdata          S          65535a   varying
     D rddata          S          65535a   varying
     D flag            S             10U 0
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

      /free
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

      /end-free
     C****************************************************************
     C* Example of writing data to a stream file
     C****************************************************************
     c                   eval      flag = O_WRONLY + O_CREAT + O_TRUNC

     c                   eval      mode =  S_IRUSR + S_IWUSR
     c                                   + S_IRGRP
     c                                   + S_IROTH

     c                   eval      fd = open('/home/cya012/ifs/ch2_test4.dat':
     c                                       flag: mode)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     die('open() for output: ' + ErrMsg)
     c                   endif

     C* Write some data
     c                   eval      wrdata = postdata
     c                   if        write(fd: %addr(wrdata)
     c                                     : %len(%trimr(wrdata))) < 1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     die('open(): ' + ErrMsg)
     c                   endif

     C* close the file
     c                   callp     close(fd)

     C****************************************************************
     C* Example of reading data from a stream file
     C****************************************************************
     c                   eval      flag = O_RDONLY

     c                   eval      fd = open('/home/cya012/ifs/ch2_test4.dat':
     c                                       flag)
     c                   if        fd < 0
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     die('open() for input: ' + ErrMsg)
     c                   endif

     c                   eval      len = read(fd: %addr(rddata):
     c                                            %size(rddata))
     c                   if        len < 1
     c                   eval      ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     die('read(): ' + ErrMsg)
     c                   endif

     c                   eval      Msg = 'Length read = ' +
     c                                    %trim(%editc(len:'M'))
     c     Msg           dsply
     c*                  dsply                   rddata

     c                   callp     close(fd)

     c                   eval      *inlr = *on
     c                   return

      *DEFINE ERRNO_LOAD_PROCEDURE
      *COPY IFSEBOOK/QRPGLESRC,ERRNO_H
      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QIFSSRC,ERRNO_H
