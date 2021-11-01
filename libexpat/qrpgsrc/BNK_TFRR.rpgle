      *====================================================================*
      * Program name: BNK_TFRR                                             *
      * Purpose.....: Interactive Internal Transfer Request for Bank       *
      *               (TransferREQ)                                        *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- ---------------------------- *
      * 2016/10/04 Alan       AC              New development              *
      *====================================================================*
      *
     H DFTACTGRP(*NO) BNDDIR('HTTPAPI')
     H ACTGRP('HTTPAPI')
     H DECEDIT('0.')
     H DEBUG(*YES)

     FBNK_TFRS  CF   E             WORKSTN SFILE(TFRENQREC: EQN)
     F                                     SFILE(TFRERRREC: TEN)
     F                                     SFILE(TFRSUCREC: TSN)
     F                                     SFILE(TODACTREC: ASN)
     F                                     SFILE(ACTSTMREC: SSN)
     F                                     SFILE(ACTBALREC: ABN)
     F                                     SFILE(TODTXREC: TTN)
     F                                     indds(dsIndic)
     FBNK_TFRF  IF A E             Disk    UsrOpn
     FPHBCIF01  IF   E           K Disk

      /copy qcpysrc,httpapi_h
      /copy qcpysrc,ifsio_h
      /Copy Qcpysrc,PSCY01R

     D StartOfElement  PR
     D   UserData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D EndOfElement    PR
     D   UserData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D cmd             pr                  extpgm('QCMDEXC')
     D  command                     200a   const
     D  length                       15p 5 const

     D CBS_ACCT        C                   '01234567890123'
     D USER_ID         C                   'XXXX'
     D ECERT_NM        C                   'XXXX'
     D ECERT_PW        C                   'Password'
     D ACCT_NO         C                   '01234567890123'
     D NEW_PW          C                   '123456789'
      *TIMEOUT         C                   30
      *AGENT           C                   'Mozilla/4.0 (compatible; MSIE 8.0; -
      *                                    Windows NT 5.1; Trident/4.0)'
     D CONTENT_TYPE    C                   'application/xml; charset=utf-8'

     D packageid       s             17a
     D debitAcctNo     s             14a
     D debitCur        s              3a
     D noOfRecord      s              2  0
     D i               s                   Like(noOfRecord)
     D c_noOfRecord    s              2a   varying
     D c_dbtAmt        s             15a   varying
     D debitAmt        s             15a   varying
     D paymentCur      s              3a

     D rc              s             10i 0
     D postData        s          65535a   varying

     d filePathReq     s             50a   varying
     d filePathRly     s             50a   varying
     d filePathRlyErr  s             50a   varying
     d fd              s             10i 0
     d fileData        s          10000c   ccsid(1200)
     d cmdLine         s            200a   varying

     D curdate         s               D
     D curtime         s               T
     D AcctUpdTim      s             20a

     D WkDBTAMT        s                   Like(TFDBTAMT)
     D EQN             s              4  0
     D TEN             s              4  0
     D TSN             s              4  0
     D ASN             s              4  0
     D SSN             s              4  0
     D ABN             s              4  0
     D TTN             s              4  0

     d error_desc      s            100a   varying
     d error_no        s             10I 0

     D dsIndic         ds
     D   TfrKey               01     01N
     D   GenKey               02     02N
     D   TfrEnqKey            03     03N
     D   TodayActKey          04     04N
     D   AcctStmtKey          05     05N
     D   AcctBalKey           06     06N
     D   ToDayTxKey           07     07N
     D   RawKey               06     06N
     D   TreeKey              07     07N
     D   PathKey              08     08N
     D   FileKey              09     09N
     D   ExitKey              12     12N
     D   Clear_Sfl            50     50N
     D   Empty_Sfl            51     51N

     d bene            ds                  qualified
     d   array                             dim(50)
     d   dbtAmt                      16a   overlay(array) varying
     d   actNo                       14a   overlay(array:*next) varying
     d   name                        70a   overlay(array:*next) varying
     d   cusRef                      15a   overlay(array:*next) varying inz
     d   valDat                      10a   overlay(array:*next) varying inz

     d act             s             10I 0
     d activity        ds                  qualified
     d   array                             dim(100)
     d   TxRefNo                     10a   overlay(array)
     d   OperID                       6a   overlay(array:*next)
     d   TxStatus                    34a   overlay(array:*next)
     d   CompleteDate                10a   overlay(array:*next)
     d   DebitAmt                    17a   overlay(array:*next)
     d   BeneAcctNo                  14a   overlay(array:*next)
     d   BeneAcctName                20a   overlay(array:*next)
     d   PaymentCur                   3a   overlay(array:*next)
     d   CustRef                     15a   overlay(array:*next)
     d   EquvAmt                     17a   overlay(array:*next)
     d   ValueDate                   10a   overlay(array:*next)

     d error           ds                  qualified
     d   array                             dim(100)
     d   RecStat                      1a   overlay(array)
     d   RecErrC                      6a   overlay(array:*next)
     d   RecErrD                     70a   overlay(array:*next)

     d success         ds                  qualified
     d   array                             dim(100)
     d   RecStat                      1a   overlay(array)
     d   DebitAmt                    17a   overlay(array:*next)
     d   BeneAcct                    20a   overlay(array:*next)
     d   BeneName                    20a   overlay(array:*next)
     d   PayCur                       3a   overlay(array:*next)
     d   CustRef                     15a   overlay(array:*next)
     d   ValueDate                   10a   overlay(array:*next)

     d todayAct        ds                  qualified
     d   array                             dim(5000)
     d   Seq                         16a   overlay(array)
     d   Cur                          3a   overlay(array:*next)
     d   Time                         5a   overlay(array:*next)
     d   TxRef                        8a   overlay(array:*next)
     d   Amt                          8  2 overlay(array:*next)
     d   Parti                       20    overlay(array:*next)
     d   Dtl                          8    overlay(array:*next)

     d acctStmt        ds                  qualified
     d   array                             dim(5000)
     d   SeqNo                       16a   overlay(array)
     d   TxDate                      10a   overlay(array:*next)
     d   TxAmt                        8  2 overlay(array:*next)
     d   Partic                      28a   overlay(array:*next)
     d   TxDtl                       10a   overlay(array:*next)

     d acctbal         ds                  qualified
     d   array                             dim(10)
     d   Typ                          9a   overlay(array)
     d   Cur                          3a   overlay(array:*next)
     d   AcctBal                     17A   overlay(array:*next)
     d   HoldBal                     17A   overlay(array:*next)
     d   FloatBal                    17A   overlay(array:*next)
     d   AvailBal                    17A   overlay(array:*next)
     d   DDBal                       17A   overlay(array:*next)

     d todayTx         ds                  qualified
     d   array                             dim(5000)
     d   TxRefNo                     10a   overlay(array)
     d   TxType                       3a   overlay(array:*next)
     d   TxDate                      10a   overlay(array:*next)
     d   TxTime2                      5a   overlay(array:*next)
     d   Partic                      14a   overlay(array:*next)
     d   TxStatus                    34a   overlay(array:*next)
     d   ValueDate                   10a   overlay(array:*next)
     d   RecUser                      6a   overlay(array:*next)

     D w1CBSAN         S                   Like(BCICBSAN)
     D w1UID           S                   Like(BCIUID)
     D w1PW            S                   Like(BCIPW)
     D w1ECN           S                   Like(BCIECN)
     D w1ECPW          S                   LIKE(BCIECPW)
     D w1EncryData     s                   Like(I_EncryData)
     D w1DataSize      s                   Like(I_DataSize)
     D w1PlainText     s                   Like(O_PlainText)

      * Parameters for PSXX0JR
     D I_Action        s              1a
     D I_PlainText     s          32752a
     D I_EncryData     s          32752a
     D I_DataSize      s              5p 0
     D O_PlainText     s          32752a
     D O_EncryData     s          32752a
      *
      * Main Logic
     C                   ExSr      @InitRef

 1b  C                   DoU       ExitKey
     C                   Exfmt     SrAcctNo
     C                   Eval      error_desc = *Blank
     C                   Eval      ScMsg = *Blank
     C                   Eval      act = 0
     C                   Eval      bene = *Blank
     C                   Eval      error = *Blank
     C                   Eval      success = *Blank
      *
 2b  C                   If        ExitKey
 1v  C                   Leave
 2e  C                   Endif
      *
     C                   ExSr      @GetBCIF
 GO  C   99              Goto      $EndPgm
      *
 2b  C                   Select
 2x  C                   When      TfrKey
     C                   ExSr      @Transfer
 2x  C                   When      TodayActKey
     C                   ExSr      @TodayAct
 2x  C                   When      GenKey
     C                   ExSr      @UpdFile
 2x  C                   When      TfrEnqKey
     C                   ExSr      @Enquiry
 2x  C                   When      AcctStmtKey
     C                   ExSr      @AcctStmt
 2x  C                   When      AcctBalKey
     C                   ExSr      @AcctBal
 2x  C                   When      TodayTxKey
     C                   ExSr      @TodayTx
 2x  C                   When      ExitKey
 1v  C                   Leave
 2e  C                   Endsl
 1e  C                   Enddo
      *
      * End of Program
     C     $EndPgm       Tag
     C                   Eval      *InLr = *On
     C                   Return
      ***********************************************************
      * @InitRef - Initial Reference
      ***********************************************************
     C     @InitRef      BegSr
      *
     C                   Time                    RnTime
     C                   Eval      SCFMACCT  = '01287512345678'
     C                   Eval      SCTOACCT1 = '01287512345679'
     C                   Eval      SCTOACCT2 = '01287512345670'
     C                   Eval      SCNOTFR   = 5
     C                   Eval      SCSTRAMT  = 101
     C                   Eval      SCINC     = 5
     C                   Eval      SCVALDAT  = 0
     C                   Eval      SCMSG     = *Blank
     C                   Eval      SCGMIP    = '172.18.100.101'
     C                   Eval      SCPKGID   = *Blank
     C                   Eval      SCTXDATE  = *Blank
     C                   Eval      SCENQCUR  = 'HKD'
     C                   Eval      SCUATDAT  = '2034/01/17'
      *
     C                   EndSr
      *
      ***********************************************************
      * @GetBCIF - Get BNK Credential Information File
      ***********************************************************
     C     @GetBCIF      BegSr
      *
     C     SCGMIP        Chain     PHBCIFR                            99
 1b  C                   If        *In99
     C     '0001'        Dump
 1x  C                   Else
      *
     C                   Eval      w1EncryData = BCICBSAN
     C                   ExSr      @DcryInfo
 GO  C   99              Goto      $GetBCIF
     C                   Eval      w1CBSAN = w1PlainText
      *
     C                   Eval      w1EncryData = BCIUID
     C                   ExSr      @DcryInfo
 GO  C   99              Goto      $GetBCIF
     C                   Eval      w1UID   = w1PlainText
      *
     C                   Eval      w1EncryData = BCIPW
     C                   ExSr      @DcryInfo
 GO  C   99              Goto      $GetBCIF
     C                   Eval      w1PW    = w1PLainText
      *
     C                   Eval      w1EncryData = BCIECN
     C                   ExSr      @DcryInfo
 GO  C   99              Goto      $GetBCIF
     C                   Eval      w1ECN   = w1PlainText
      *
     C                   Eval      w1EncryData = BCIECPW
     C                   ExSr      @DcryInfo
 GO  C   99              Goto      $GetBCIF
     C                   Eval      w1ECPW  = w1PlainText
 1e  C                   Endif
      *
     C     $GetBCIF      Tag
     C                   EndSr
      *
      **************************************************************************
     C     @DcryInfo     BegSr
      **************************************************************************
      * I_DataSize must be multiple of 16, that is the block size of AES encryption
 1b  C                   If        %rem(%len(%trim(w1EncryData)): 16) <> 0
     C                   Eval      w1DataSize =
     C                             (%div(%len(%trim(w1EncryData)): 16) + 1) * 16
 1x  C                   Else
     C                   Eval      w1DataSize =
     C                             %len(%trim(w1EncryData))
 1e  C                   Endif
      *
     C                   Call      'PSXX0JR'
     C                   Parm      'D'           I_Action
     C                   Parm      *Blank        I_PlainText
     C                   Parm      w1EncryData   I_EncryData
     C                   Parm      w1DataSize    I_DataSize
     C                   Parm                    RtnCde
     C                   Parm                    O_PlainText
     C                   Parm                    O_EncryData
 1b  C                   If        RtnCde <> 0
     C                   Eval      *In99 = *On
     C     '0002'        Dump
 1x  C                   Else
     C                   Eval      w1PlainText = O_PlainText
 1e  C                   Endif
      *
     C                   EndSr
      ***********************************************************
      * @UpdFile - Update File
      ***********************************************************
     C     @UpdFile      BegSr
      /free
       cmd('CLRPFM BNK_TFRF': 200);
      /end-free
     C                   Eval      WkDBTAMT   = SCSTRAMT
     C                   Eval      TFCUSREF   = *Blank
 1b  C                   If        SCVALDAT  <> 0
     C                   Eval      TFVALDATE  = %date(SCVALDAT)
 1x  C                   Else
     C                   Eval      TFVALDATE  = D'0001-01-01'
 1e  C                   Endif
      *
     C                   Open      BNK_TFRF
 1b  C     1             Do        SCNOTFR       i
     C                   Eval      TFDBTAMT   = WkDBTAMT
 2b  C                   if        %Rem(i: 2) = 1
     C                   Eval      TFBENACTNO = SCTOACCT1
 2x  C                   Else
 3b  C                   If        SCTOACCT2 <> *Blank
     C                   Eval      TFBENACTNO = SCTOACCT2
 3x  C                   Else
     C                   Eval      TFBENACTNO = SCTOACCT1
 3e  C                   Endif
 2e  C                   Endif
 2b  C                   Select
 2x  C                   When      TFBENACTNO = '01287502978125'
     C                   Eval      TFBENACTNM = 'ABC TRAVEL'
 2x  C                   When      TFBENACTNO = '01287502982487'
     C                   Eval      TFBENACTNM = 'DONALDO COMPANY'
 2x  C                   Other
      *                  Eval      TFBENACTNM = 'PROMISE'
     C                   Eval      TFBENACTNM = *Blank
 2e  C                   Endsl
     C                   Eval      TFCUSREF   = 'CUSTREF' + %char(i)
     C                   Write     BNK_TFRFR
     C                   Eval      WkDBTAMT   = WkDBTAMT + SCINC
 1e  C                   Enddo
     C                   Close     BNK_TFRF
      *
     C                   Eval      SCMsg = 'Transfer Data is generated'
     C                                   + ' in File BNK_TFRF, you can edit'
     C                                   + ' before Transfer'
      *
     C                   EndSr
      ***********************************************************
      * @Transfer - Transfer Process
      ***********************************************************
     C     @Transfer     BegSr
      * User open File and insert into array
     C                   Eval      i = 0
     C                   Open      BNK_TFRF
 1b  C                   DoU       *In96
     C                   Read      BNK_TFRFR                              96
 2b  C                   If        Not *In96
 3b  C                   If        TFDBTAMT <> 0
     C                             and TFBENACTNO <> *Blank
     C                             and i < 50
      *
     C                   Eval      i = i + 1
     C                   Eval      bene.dbtAmt(i) = %trim(%editc(TFDBTAMT:'4'))
     C                   Eval      bene.actNo(i)  = %trim(TFBENACTNO)
     C                   Eval      bene.name(i)   = %trim(TFBENACTNM)
     C                   Eval      bene.cusRef(i) = %trim(TFCUSREF)
 4b  C                   If        TFVALDATE <> D'0001-01-01'
     C                   Eval      bene.valDat(i) =
     C                               %trim(%xlate('-':'/':%char(TFVALDATE)))
 4x  C                   Else
     C                   Eval      bene.valDat(i) = *blank
 4e  C                   Endif
      *
 3e  C                   Endif
 2e  C                   Endif
 1e  C                   Enddo
      *
      * Close Branch IP Address File to prevent file lock
     C                   Close     BNK_TFRF
     C                   Eval      noOfRecord = i

      /free
 1b    if noOfRecord > 0;

          // log file to the IFS in /BNKHK/BNK_TFR_debug.txt
          http_debug(*on: '/BNKHK/BNK_TFR_debug.txt');
          *inlr = *on;

          curdate = %date();
          curtime = %time();

          packageid     = %char(curdate:*ISO0) + %char(curtime:*ISO0) + '001';
          debitAcctNo   = SCFMACCT;
          debitCur      = 'HKD';
          c_noOfRecord  = %trim(%editc(noOfRecord: '4'));

          postData =
          '<?xml version="1.0" encoding="utf-8" ?>'                            +
          '<BNKHKE2B>'                                                         +
          '<Head>'                                                          +
          '<PackageId>' + packageid + '</PackageId>'                     +
          '<CBSAcctNo>' + %Trim(w1CBSAN) + '</CBSAcctNo>'                +
          '<UserId>' + %Trim(w1UID) + '</UserId>'                        +
          '<Password>' + %Trim(w1PW) + '</Password>'                     +
          '<ECertName>' + %trim(w1ECN) + '</ECertName>'                  +
          '<ECertPwd>' + %Trim(w1ECPW) + '</ECertPwd>'                   +
          '</Head>'                                                         +
          '<Tx>'                                                            +
          '<TransferREQ>'                                                +
          '<DebitAcctNo>' + debitAcctNo + '</DebitAcctNo>'            +
          '<DebitCur>' + debitCur + '</DebitCur>'                     +
          '<Requests noOfRecord="' + c_noOfRecord + '">'              ;

 2b       for i = 1 to noOfRecord;
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
 2e       endfor;

          postData = postData +
          '</Requests>'                                               +
          '</TransferREQ>'                                               +
          '</Tx>'                                                           +
          '</BNKHKE2B>'                                                        ;

          // write request xml to ifs
          //*********************************************************************
          //      Mode Flags.
          //         basically, the mode parm of open(), creat(), chmod(),etc
          //         uses 9 least significant bits to determine the
          //         file's mode. (peoples access rights to the file)
          //
          //           user:       owner    group    other
          //           access:     R W X    R W X    R W X
          //           bit:        8 7 6    5 4 3    2 1 0
          //
          // (This is accomplished by adding the flags below to get the mode)
          //*********************************************************************
          //      filePathReq = '/BNKHK/TransferREQ' + Packageid + '.xml';
          //      fd = open(filePathReq
          //              : O_CREAT + O_TRUNC + O_CCSID + O_WRONLY
          //                   + O_TEXT_CREAT + O_TEXTDATA
          //              : S_IRWXU + S_IRWXG + S_IRWXO
          //              : 1208
          //              : 1200);
          //      if (fd < 0);
          //         scMsg= 'Error occured when open XML request to ifs';
          //         // dsply errMsg;
          //         http_comp(scMsg);
          //         dump 'BNK_TFR: Write XML request';
          //         // *inlr = *on;
          //         // return;
          //      endif;
          //      fileData = %ucs2(postData + x'0d25');
          //      callp write(fd: %addr(fileData): %len(%trimr(fileData))*2);
          //      callp close(fd);

          // CCSID 1208 = UTF-8
          HTTP_setCCSIDs(1208: 0);

          // write response xml to ifs
          filePathRly = '/BNKHK/TransferRLY' + Packageid + '.xml';

          // content-type must specify 'application/xml; charset=utf-8'
       rc = http_url_post('https://' + %trim(SCGMIP) + '/fts/FtsE2bGateway.do'
          : %addr(postData) + 2
          : %len(postData)
          : filePathRly
          : HTTP_TIMEOUT
          : HTTP_USERAGENT
          : CONTENT_TYPE);

 2b       if (rc <> 1);
             error_desc = http_error();
             // FIXME: REPORT ERROR TO USER
             // dsply scmsg;
             http_comp(scMsg);
             // rename response xml file
             filePathRlyErr = '/BNKHK/errTransferRLY' + Packageid + '.xml';
 3b          if rename(filePathRly: filePathRlyErr) < 0;
                error_desc = 'BNK_TFR: Error in rename XML file';
                http_comp(error_desc);
 3e          endif;
             scMsg = error_desc;
             scPkgId  = *Blank;
             scTxDate = *Blank;
             dump error_desc;
 LV          leaveSr;
             // *inlr = *on;
             // return;
 2e       endif;

          // ----------------------------------------------
          //  Parse xml document that save to a separate file in the IFS.
          // ----------------------------------------------
 2b       if (http_parse_xml_stmf( filePathRly
             : HTTP_XML_CALC
             : %paddr(StartOfElement)
             : %paddr(EndOfElement)
             : *null )
             < 0 );
             error_desc = http_error();
 2e       endif;

          // if error.RecStat(1) <> *blank;
 2b       if error_desc <> *blank;
             clear_sfl = *on;
             write TFRERRCTL;
             clear_sfl = *off;
             empty_sfl = *on;

 3b          for TEN = 1 to act;
                scRecStat = error.RecStat(TEN);
                scRecErrC = error.RecErrC(TEN);
                scRecErrD = error.RecErrD(TEN);
                write TFRERRREC;
                empty_sfl = *off;
 3e          endfor;

             // write SFLFTR;
             // exfmt TFRERRCTL;

 3b          DoU Not (RawKey or TreeKey or PathKey or FileKey);
                write SFLFTR;
                exfmt TFRERRCTL;
 4b             if RawKey;
                   cmdLine = 'DSPF '''+ filePathRly + '''';
                   cmd(cmdLine: 200);
 4e             endif;
 4b             if TreeKey;
                   cmdLine = 'XML_XPATH '''+ filePathRly + '''';
                   cmd(cmdLine: 200);
 4e             endif;
 4b             if PathKey;
                   cmdLine = 'XML_XPATH ''' + filePathRly + '''';
                   cmd(cmdLine: 200);
 4e             endif;
 4b             if FileKey;
                   cmdLine = 'XML_FILE ''' + filePathRly + '''';
                   cmd(cmdLine: 200);
 4e             endif;
 3e          enddo;

 2e       endif;

 2b       if success.RecStat(1) <> *blank;
             clear_sfl = *on;
             write TFRSUCCTL;
             clear_sfl = *off;
             empty_sfl = *on;

 3b          for TSN = 1 to act;
                scRecStat  = success.RecStat(TSN);
                scDebitAmt = %dec(success.DebitAmt(TSN):5:2);
                scBeneAcct = success.BeneAcct(TSN);
                scBeneName = success.BeneName(TSN);
                scPayCur   = success.PayCur(TSN);
                scCustRef  = success.CustRef(TSN);
                scValueDat = success.ValueDate(TSN);
                write TFRSUCREC;
                empty_sfl = *off;
 3e          endfor;

             // write SFLFTR;
             // exfmt TFRSUCCTL;

 3b          DoU Not (RawKey or TreeKey or PathKey or FileKey);
                write SFLFTR;
                exfmt TFRSUCCTL;

 4b             if RawKey;
                   cmdLine = 'DSPF ''' + filePathRly + '''';
                   cmd(cmdLine: 200);
 4e             endif;
 4b             if TreeKey;
                   cmdLine = 'XML_CHAR1 ''' + filePathRly + '''';
                   cmd(cmdLine: 200);
 4e             endif;
 4b             if PathKey;
                   cmdLine = 'XML_XPATH ''' + filePathRly + '''';
                   cmd(cmdLine: 200);
 4e             endif;
 4b             if FileKey;
                   cmdLine = 'XML_FILE ''' + filePathRly + '''';
                   cmd(cmdLine: 200);
 4e             endif;

 3e          enddo;

 2e       endif;

          // Error content in xml response
 2b       if error_desc <> *blank;
             // dsply scMsg;
             http_comp(error_desc);
             // rename response xml file
             filePathRlyErr = '/BNKHK/errTransferRLY' + Packageid + '.xml';
 3b          if rename(filePathRly: filePathRlyErr) < 0;
                error_desc = 'BNK_TFR: Error in rename XML file';
                http_comp(error_desc);
 3e          endif;
 2e       endif;

          // if error_desc <> *blank;
          //   cmdLine = 'DSPF '''+ filePathRlyErr + '''';
          // else;
          //   cmdLine = 'DSPF '''+ filePathRly + '''';
          // endif;
          // cmd(cmdLine: 200);

          // delete temp files, we're done
          // unlink(filePathReq);
          // unlink(filePathRly);

          https_cleanup();
          // *inlr = *on;
          // return;

          scPkgId  = packageid;
          scMsg    = *Blank;

 1e    endif;
      /end-free

     C                   EndSr
      ***********************************************************
      * @Enquiry - Transfer Enquiry
      ***********************************************************
     C     @Enquiry      BegSr
      /free
       // log file to the IFS in /tmp/httpapi_debug.txt
      /if defined(DEBUGGING)
       http_debug(*off);
      /endif
       *inlr = *on;

       curdate = %date();
       curtime = %time();

       clear activity;
       act = 0;

       packageid = %char(curdate:*ISO0) + %char(curtime:*ISO0) + '001';

       postData =
       '<?xml version="1.0" encoding="utf-8" ?>'                    +
       '<BNKHKE2B>'                                                 +
       '<Head>'                                                  +
       '<PackageId>' + packageId + '</PackageId>'             +
       '<CBSAcctNo>' + %Trim(w1CBSAN) + '</CBSAcctNo>'        +
       '<UserId>' + %Trim(w1UID) + '</UserId>'                +
       '<Password>' + %Trim(w1PW) + '</Password>'             +
       '<ECertName>' + %trim(w1ECN) + '</ECertName>'          +
       '<ECertPwd>' + %Trim(w1ECPW) + '</ECertPwd>'           +
       '</Head>'                                                 +
       '<Tx>'                                                    +
       '<TransferEnquiryREQ>'                                 +
       '<EnqPackageId>' + scPkgId + '</EnqPackageId>'      +
       '<TxDate>' + scTxDate  + '</TxDate>'                +
       '</TransferEnquiryREQ>'                                +
       '</Tx>'                                                   +
       '</BNKHKE2B>'                                                ;

       // write request xml to ifs
       //      filePathReq = '/BNKHK/TransferEnquiryREQ' + Packageid + '.xml';
       //      unlink(filePathReq);
       //      fd = open(filePathReq
       //              : O_CREAT + O_TRUNC + O_CCSID + O_WRONLY
       //                   + O_TEXT_CREAT + O_TEXTDATA
       //              : S_IRWXU + S_IRWXG + S_IRWXO
       //              : 1208
       //              : 1200);
       //      if (fd < 0);
       //         scmsg = 'Error occured when open XML request to ifs';
       //         *inlr = *on;
       //         return;
       //      endif;
       //
       //      fileData = %ucs2(postData + x'0d25');
       //      callp write(fd: %addr(fileData): %len(%trimr(fileData))*2);
       //      callp close(fd);

       // CCSID 1208 = UTF-8
       HTTP_setCCSIDs(1208: 0);

       // write response xml to ifs
       filePathRly = '/BNKHK/TransferEnquiryRLY' + Packageid + '.xml';

       // content-type must specify 'application/xml; charset=utf-8'
       rc = http_url_post('https://' + %trim(SCGMIP) + '/fts/FtsE2bGateway.do'
       : %addr(postData) + 2
       : %len(postData)
       : filePathRly
       : HTTP_TIMEOUT
       : HTTP_USERAGENT
       : CONTENT_TYPE);

 1b    if (rc <> 1);
          unlink(filePathRly);
          scmsg = http_error();
 1e    endif;

       // ----------------------------------------------
       //  Parse xml document that save to a separate file in the IFS.
       // ----------------------------------------------
 1b    if (http_parse_xml_stmf( filePathRly
          : HTTP_XML_CALC
          : %paddr(StartOfElement)
          : %paddr(EndOfElement)
          : *null ) < 0 );
          error_desc = http_error();
 1e    endif;

 1b    if error_desc <> *blank;
          scmsg = error_desc;
          dump error_desc;
          // *inlr = *on;
          // return;
 LV       leaveSr;
 1e    endif;

       clear_sfl = *on;
       write TFRENQCTL;
       clear_sfl = *off;
       empty_sfl = *on;

 1b    for EQN = 1 to act;
          scTxRefNo  = activity.TxRefNo(EQN);
          scTxStatus = activity.TxStatus(EQN);
          scCompDate = activity.CompleteDate(EQN);
          scDebitAmt = %dec(activity.DebitAmt(EQN):5:2);
          scBeneAcct = activity.BeneAcctNo(EQN);
          scBeneName = activity.BeneAcctName(EQN);
          scCustRef  = activity.CustRef(EQN);
          scValueDat = activity.ValueDate(EQN);
          write TFRENQREC;
          empty_sfl = *off;
 1e    endfor;

       // write SFLFTR;
       // exfmt ENQCTL;

       // dsply ('Press <ENTER> to see xml response') ' ' wait;
       // cmdLine = 'DSPF '''+ filePathRly + '''';
       // cmd(cmdLine: 200);

 1b    dou Not (RawKey or TreeKey or PathKey or FileKey);
          write SFLFTR;
          exfmt TFRENQCTL;

 2b       if RawKey;
             cmdLine = 'DSPF '''+ filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if TreeKey;
             cmdLine = 'XML_CHAR1 ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if PathKey;
             cmdLine = 'XML_XPATH ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if FileKey;
             cmdLine = 'XML_FILE ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;

 1e    enddo;

      /end-free
     C                   EndSr

      ***********************************************************
      * @TodayAct - Today Activity Enquiry
      ***********************************************************
     C     @TodayAct     BegSr

      /free
       // log file to the IFS in /tmp/httpapi_debug.txt
      /if defined(DEBUGGING)
       http_debug(*on);
      /endif
       *inlr = *on;

       curdate = %date();
       curtime = %time();

       debitAcctNo = ScFmAcct;

       clear todayAct;
       act = 0;

       packageid = %char(curdate:*ISO0) + %char(curtime:*ISO0) + '001';

       postData =
       '<?xml version="1.0" encoding="utf-8" ?>'                    +
       '<BNKHKE2B>'                                                 +
       '<Head>'                                                  +
       '<PackageId>' + packageId + '</PackageId>'             +
       '<CBSAcctNo>' + %Trim(w1CBSAN) + '</CBSAcctNo>'        +
       '<UserId>' + %Trim(w1UID) + '</UserId>'                +
       '<Password>' + %Trim(w1PW) + '</Password>'             +
       '<ECertName>' + %trim(w1ECN) + '</ECertName>'          +
       '<ECertPwd>' + %Trim(w1ECPW) + '</ECertPwd>'           +
       '</Head>'                                                 +
       '<Tx>'                                                    +
       '<TodayActivityREQ>'                                   +
       '<AcctNo>' + SCENQACCT + '</AcctNo>'                +
       '</TodayActivityREQ>'                                  +
       '</Tx>'                                                   +
       '</BNKHKE2B>'                                                ;

       // write request xml to ifs
       //      filePathReq = '/BNKHK/TodayActivityREQ' + Packageid + '.xml';
       //      unlink(filePathReq);
       //      fd = open(filePathReq
       //              : O_CREAT + O_TRUNC + O_CCSID + O_WRONLY
       //                   + O_TEXT_CREAT + O_TEXTDATA
       //              : S_IRWXU + S_IRWXG + S_IRWXO
       //              : 1208
       //              : 1200);
       //      if (fd < 0);
       //         scmsg = 'Error occured when open XML request to ifs';
       //         *inlr = *on;
       //         return;
       //      endif;
       //
       //      fileData = %ucs2(postData + x'0d25');
       //      callp write(fd: %addr(fileData): %len(%trimr(fileData))*2);
       //      callp close(fd);

       // CCSID 1208 = UTF-8
       HTTP_setCCSIDs(1208: 0);

       // write response xml to ifs
       filePathRly = '/BNKHK/TodayActivityRLY' + Packageid + '.xml';

       // content-type must specify 'application/xml; charset=utf-8'
       rc = http_url_post('https://' + %trim(SCGMIP) + '/fts/FtsE2bGateway.do'
       : %addr(postData) + 2
       : %len(postData)
       : filePathRly
       : HTTP_TIMEOUT
       : HTTP_USERAGENT
       : CONTENT_TYPE);

 1b    if (rc <> 1);
          unlink(filePathRly);
          scmsg = http_error();
 1e    endif;

       // ----------------------------------------------
       //  Parse xml document that save to a separate file in the IFS.
       // ----------------------------------------------
 1b    if (http_parse_xml_stmf( filePathRly
          : HTTP_XML_CALC
          : %paddr(StartOfElement)
          : %paddr(EndOfElement)
          : *null ) < 0 );
          error_desc = http_error();
 1e    endif;

 1b    if error_desc <> *blank;
          scmsg = error_desc;
          dump error_desc;
          // *inlr = *on;
          // return;
 LV       leaveSr;
 1e    endif;

       clear_sfl = *on;
       write TODACTCTL;
       clear_sfl = *off;
       empty_sfl = *on;

       scUpdTim = AcctUpdTim;

 1b    for ASN = 1 to act;
          scSeq   = todayAct.Seq(ASN);
          scCur   = todayAct.Cur(ASN);
          scTime  = todayAct.Time(ASN);
          scTxRef = todayAct.TxRef(ASN);
          scAmt   = todayAct.Amt(ASN);
          scParti = todayAct.Parti(ASN);
          scDtl   = todayAct.Dtl(ASN);
          write TODACTREC;
          empty_sfl = *off;
 1e    endfor;

       // write SFLFTR;
       // exfmt TODACTCTL;

       // dsply ('Press <ENTER> to see xml response') ' ' wait;
       // cmdLine = 'DSPF '''+ filePathRly + '''';
       // cmd(cmdLine: 200);

 1b    dou Not (RawKey or TreeKey or PathKey or FileKey);
          write SFLFTR;
          exfmt TODACTCTL;

 2b       if RawKey;
             cmdLine = 'DSPF '''+ filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if TreeKey;
             cmdLine = 'XML_CHAR1 ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if PathKey;
             cmdLine = 'XML_XPATH ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if FileKey;
             cmdLine = 'XML_FILE ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;

 1e    enddo;

      /end-free
     C                   EndSr

      ***********************************************************
      * @AcctStmt - Account Statement Enquiry
      ***********************************************************
     C     @AcctStmt     BegSr

      /free
       // log file to the IFS in /tmp/httpapi_debug.txt
      /if defined(DEBUGGING)
       http_debug(*on);
      /endif
       *inlr = *on;

       curdate = %date();
       curtime = %time();

       clear AcctStmt;
       act = 0;

       packageid = %char(curdate:*ISO0) + %char(curtime:*ISO0) + '001';

       postData =
       '<?xml version="1.0" encoding="utf-8" ?>'                    +
       '<BNKHKE2B>'                                                 +
       '<Head>'                                                  +
       '<PackageId>' + packageId + '</PackageId>'             +
       '<CBSAcctNo>' + %Trim(w1CBSAN) + '</CBSAcctNo>'        +
       '<UserId>' + %Trim(w1UID) + '</UserId>'                +
       '<Password>' + %Trim(w1PW) + '</Password>'             +
       '<ECertName>' + %trim(w1ECN) + '</ECertName>'          +
       '<ECertPwd>' + %Trim(w1ECPW) + '</ECertPwd>'           +
       '</Head>'                                                 +
       '<Tx>'                                                    +
       '<AcctStatementREQ>'                                   +
       '<AcctNo>' + SCENQACCT + '</AcctNo>'                +
       '<Cur>' + scEnqCur + '</Cur>'                       +
       '<Date>' + scUatdat + '</Date>'                     +
       '</AcctStatementREQ>'                                  +
       '</Tx>'                                                   +
       '</BNKHKE2B>'                                                ;

       // write request xml to ifs
       //      filePathReq = '/BNKHK/AcctStatementReq' + Packageid + '.xml';
       //      unlink(filePathReq);
       //      fd = open(filePathReq
       //              : O_CREAT + O_TRUNC + O_CCSID + O_WRONLY
       //                   + O_TEXT_CREAT + O_TEXTDATA
       //              : S_IRWXU + S_IRWXG + S_IRWXO
       //              : 1208
       //              : 1200);
       //      if (fd < 0);
       //         scmsg = 'Error occured when open XML request to ifs';
       //         *inlr = *on;
       //         return;
       //      endif;
       //
       //      fileData = %ucs2(postData + x'0d25');
       //      callp write(fd: %addr(fileData): %len(%trimr(fileData))*2);
       //      callp close(fd);

       // CCSID 1208 = UTF-8
       HTTP_setCCSIDs(1208: 0);

       // write response xml to ifs
       filePathRly = '/BNKHK/AcctStatementRLY' + Packageid + '.xml';

       // content-type must specify 'application/xml; charset=utf-8'
       rc = http_url_post('https://' + %trim(SCGMIP) + '/fts/FtsE2bGateway.do'
       : %addr(postData) + 2
       : %len(postData)
       : filePathRly
       : HTTP_TIMEOUT
       : HTTP_USERAGENT
       : CONTENT_TYPE);

 1b    if (rc <> 1);
          unlink(filePathRly);
          scmsg = http_error();
 1e    endif;

       // ----------------------------------------------
       //  Parse xml document that save to a separate file in the IFS.
       // ----------------------------------------------
 1b    if (http_parse_xml_stmf( filePathRly
          : HTTP_XML_CALC
          : %paddr(StartOfElement)
          : %paddr(EndOfElement)
          : *null ) < 0 );
          error_desc = http_error();
 1e    endif;

 1b    if error_desc <> *blank;
          scmsg = error_desc;
          dump error_desc;
          // *inlr = *on;
          // return;
 LV       leaveSr;
 1e    endif;

       clear_sfl = *on;
       write ACTSTMCTL;
       clear_sfl = *off;
       empty_sfl = *on;

       scUpdTim = AcctUpdTim;
       scPkgid = packageId;

 1b    for SSN = 1 to act;
          scSeqNo  = acctstmt.SeqNo(SSN);
          scTxDate = acctstmt.TxDate(SSN);
          scTxAmt  = acctstmt.TxAmt(SSN);
          scPartic = acctstmt.Partic(SSN);
          scTxDtl  = acctstmt.TxDtl(SSN);
          write ACTSTMREC;
          empty_sfl = *off;
 1e    endfor;

       // write SFLFTR;
       // exfmt ACTSTMCTL;

       // dsply ('Press <ENTER> to see xml response') ' ' wait;
       // cmdLine = 'DSPF '''+ filePathRly + '''';
       // cmd(cmdLine: 200);

 1b    dou Not (RawKey or TreeKey or PathKey or FileKey);
          write SFLFTR;
          exfmt ACTSTMCTL;

 2b       if RawKey;
             cmdLine = 'DSPF '''+ filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if TreeKey;
             cmdLine = 'XML_CHAR1 ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if PathKey;
             cmdLine = 'XML_XPATH ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if FileKey;
             cmdLine = 'XML_FILE ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;

 1e    enddo;

      /end-free
     C                   EndSr

      ***********************************************************
      * @AcctBal - Account Balance Enquiry
      ***********************************************************
     C     @AcctBal      BegSr

      /free
       // log file to the IFS in /tmp/httpapi_debug.txt
      /if defined(DEBUGGING)
       http_debug(*on);
      /endif
       *inlr = *on;

       curdate = %date();
       curtime = %time();

       clear AcctBal;
       act = 0;

       packageid = %char(curdate:*ISO0) + %char(curtime:*ISO0) + '001';

       postData =
       '<?xml version="1.0" encoding="utf-8" ?>'                    +
       '<BNKHKE2B>'                                                 +
       '<Head>'                                                  +
       '<PackageId>' + packageId + '</PackageId>'             +
       '<CBSAcctNo>' + %Trim(w1CBSAN) + '</CBSAcctNo>'        +
       '<UserId>' + %Trim(w1UID) + '</UserId>'                +
       '<Password>' + %Trim(w1PW) + '</Password>'             +
       '<ECertName>' + %trim(w1ECN) + '</ECertName>'          +
       '<ECertPwd>' + %Trim(w1ECPW) + '</ECertPwd>'           +
       '</Head>'                                                 +
       '<Tx>'                                                    +
       '<AcctBalanceREQ>'                                     +
       '<AcctNo>' + SCENQACCT + '</AcctNo>'                +
       '</AcctBalanceREQ>'                                    +
       '</Tx>'                                                   +
       '</BNKHKE2B>'                                                ;

       // write request xml to ifs
       //      filePathReq = '/BNKHK/AcctBalanceREQ' + Packageid + '.xml';
       //      unlink(filePathReq);
       //      fd = open(filePathReq
       //              : O_CREAT + O_TRUNC + O_CCSID + O_WRONLY
       //                   + O_TEXT_CREAT + O_TEXTDATA
       //              : S_IRWXU + S_IRWXG + S_IRWXO
       //              : 1208
       //              : 1200);
       //      if (fd < 0);
       //         scmsg = 'Error occured when open XML request to ifs';
       //         *inlr = *on;
       //         return;
       //      endif;
       //
       //      fileData = %ucs2(postData + x'0d25');
       //      callp write(fd: %addr(fileData): %len(%trimr(fileData))*2);
       //      callp close(fd);

       // CCSID 1208 = UTF-8
       HTTP_setCCSIDs(1208: 0);

       // write response xml to ifs
       filePathRly = '/BNKHK/AcctBalanceRLY' + Packageid + '.xml';

       // content-type must specify 'application/xml; charset=utf-8'
       rc = http_url_post('https://' + %trim(SCGMIP) + '/fts/FtsE2bGateway.do'
       : %addr(postData) + 2
       : %len(postData)
       : filePathRly
       : HTTP_TIMEOUT
       : HTTP_USERAGENT
       : CONTENT_TYPE);

 1b    if (rc <> 1);
          unlink(filePathRly);
          scmsg = http_error();
 1e    endif;

       // ----------------------------------------------
       //  Parse xml document that save to a separate file in the IFS.
       // ----------------------------------------------
 1b    if (http_parse_xml_stmf( filePathRly
          : HTTP_XML_CALC
          : %paddr(StartOfElement)
          : %paddr(EndOfElement)
          : *null ) < 0 );
          error_desc = http_error();
 1e    endif;

 1b    if error_desc <> *blank;
          scmsg = error_desc;
          dump error_desc;
          // *inlr = *on;
          // return;
 LV       leaveSr;
 1e    endif;

       clear_sfl = *on;
       write ACTBALCTL;
       clear_sfl = *off;
       empty_sfl = *on;

       scPkgid = packageId;
       scUpdTim = AcctUpdTim;

 1b    for ABN = 1 to act;
          scTyp = acctBal.Typ(ABN);
          scCur = acctBal.Cur(ABN);
          scAcctBal = acctBal.AcctBal(ABN);
          scHoldBal = acctBal.HoldBal(ABN);
          scAvailBal = acctBal.AvailBal(ABN);
          write ACTBALREC;
          empty_sfl = *off;
 1e    endfor;

       // write SFLFTR;
       // exfmt ACTBALCTL;

       // dsply ('Press <ENTER> to see xml response') ' ' wait;
       // cmdLine = 'DSPF '''+ filePathRly + '''';
       // cmd(cmdLine: 200);

 1b    dou Not (RawKey or TreeKey or PathKey or FileKey);
          write SFLFTR;
          exfmt ACTBALCTL;

 2b       if RawKey;
             cmdLine = 'DSPF '''+ filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if TreeKey;
             cmdLine = 'XML_CHAR1 ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if PathKey;
             cmdLine = 'XML_XPATH ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if FileKey;
             cmdLine = 'XML_FILE ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;

 1e    enddo;

      /end-free
     C                   EndSr

      ***********************************************************
      * @TodayTx - Today Transaction Enquiry
      ***********************************************************
     C     @TodayTx      BegSr

      /free
       // log file to the IFS in /tmp/httpapi_debug.txt
      /if defined(DEBUGGING)
       http_debug(*on);
      /endif
       *inlr = *on;

       curdate = %date();
       curtime = %time();

       clear TodayTx;
       act = 0;

       packageid = %char(curdate:*ISO0) + %char(curtime:*ISO0) + '001';

       postData =
       '<?xml version="1.0" encoding="utf-8" ?>'                    +
       '<BNKHKE2B>'                                                 +
       '<Head>'                                                  +
       '<PackageId>' + packageId + '</PackageId>'             +
       '<CBSAcctNo>' + %Trim(w1CBSAN) + '</CBSAcctNo>'        +
       '<UserId>' + %Trim(w1UID) + '</UserId>'                +
       '<Password>' + %Trim(w1PW) + '</Password>'             +
       '<ECertName>' + %trim(w1ECN) + '</ECertName>'          +
       '<ECertPwd>' + %Trim(w1ECPW) + '</ECertPwd>'           +
       '</Head>'                                                 +
       '<Tx>'                                                    +
       '<TodayTxREQ>'                                         +
       '<TxStartRef>' + scEnqTxRef + '</TxStartRef>'       +
       '</TodayTxREQ>'                                        +
       '</Tx>'                                                   +
       '</BNKHKE2B>'                                                ;

       // write request xml to ifs
       //      filePathReq = '/BNKHK/TodayTxREQ' + Packageid + '.xml';
       //      unlink(filePathReq);
       //      fd = open(filePathReq
       //              : O_CREAT + O_TRUNC + O_CCSID + O_WRONLY
       //                   + O_TEXT_CREAT + O_TEXTDATA
       //              : S_IRWXU + S_IRWXG + S_IRWXO
       //              : 1208
       //              : 1200);
       //      if (fd < 0);
       //         scmsg = 'Error occured when open XML request to ifs';
       //         *inlr = *on;
       //         return;
       //      endif;
       //
       //      fileData = %ucs2(postData + x'0d25');
       //      callp write(fd: %addr(fileData): %len(%trimr(fileData))*2);
       //      callp close(fd);

       // CCSID 1208 = UTF-8
       HTTP_setCCSIDs(1208: 0);

       // write response xml to ifs
       filePathRly = '/BNKHK/TodayTxRLY' + Packageid + '.xml';

       // content-type must specify 'application/xml; charset=utf-8'
       rc = http_url_post('https://' + %trim(SCGMIP) + '/fts/FtsE2bGateway.do'
       : %addr(postData) + 2
       : %len(postData)
       : filePathRly
       : HTTP_TIMEOUT
       : HTTP_USERAGENT
       : CONTENT_TYPE);

 1b    if (rc <> 1);
          unlink(filePathRly);
          scmsg = http_error();
 1e    endif;

       // ----------------------------------------------
       //  Parse xml document that save to a separate file in the IFS.
       // ----------------------------------------------
 1b    if (http_parse_xml_stmf( filePathRly
          : HTTP_XML_CALC
          : %paddr(StartOfElement)
          : %paddr(EndOfElement)
          : *null ) < 0 );
          error_desc = http_error();
 1e    endif;

 1b    if error_desc <> *blank;
          scmsg = error_desc;
          dump error_desc;
          // *inlr = *on;
          // return;
 LV       leaveSr;
 1e    endif;

       clear_sfl = *on;
       write TODTXCTL;
       clear_sfl = *off;
       empty_sfl = *on;

       scUpdTim = AcctUpdTim;

 1b    for TTN = 1 to act;
          scTxRefNo  = todayTx.TxRefNo(TTN);
          scTxType   = todayTx.TxType(TTN);
          scTxDate   = todayTx.TxDate(TTN);
          scTxTime2  = todayTx.TxTime2(TTN);
          scTxStatus = todayTx.TxStatus(TTN);
          scValueDat = todayTx.ValueDate(TTN);
          // scRecUser  = todayTx.RecUser(TTN);
          write TODTXREC;
          empty_sfl = *off;
 1e    endfor;

       // write SFLFTR;
       // exfmt TODTXCTL;

       // dsply ('Press <ENTER> to see xml response') ' ' wait;
       // cmdLine = 'DSPF '''+ filePathRly + '''';
       // cmd(cmdLine: 200);

 1b    dou Not (RawKey or TreeKey or PathKey or FileKey);
          write SFLFTR;
          exfmt TODTXCTL;

 2b       if RawKey;
             cmdLine = 'DSPF '''+ filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if TreeKey;
             cmdLine = 'XML_CHAR1 ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if PathKey;
             cmdLine = 'XML_XPATH ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;
 2b       if FileKey;
             cmdLine = 'XML_FILE ''' + filePathRly + '''';
             cmd(cmdLine: 200);
 2e       endif;

 1e    enddo;

      /end-free
     C                   EndSr

     P StartOfElement  B
     D StartOfElement  PI
     D   UserData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
      /free

 1b    select;
          // receive from BNK Transfer Response
 1x    when path = '/BNKHKB2E/Tx/TransferRLY+
          /Requests/Record/InternalTrans';
 2b       select;
 2x       when name = 'RecordStatus';
             act = act + 1;
 2e       endsl;

          // receive from BNK Transfer Enquiry Response
 1x    when path = '/BNKHKB2E/Tx/TransferEnquiryRLY+
          /Requests/Record/InternalTrans';
 2b       select;
 2x       when name = 'TxRefNo';
             act = act + 1;
 2e       endsl;

          // receive from BNK Today Activity Response
 1x    when path = '/BNKHKB2E/Tx/TodayActivityRLY/Result/Record';
 2b       select;
 2x       when name = 'SeqNo';
             act = act + 1;
 2e       endsl;

          // receive from BNK Account Statement Response
 1x    when path = '/BNKHKB2E/Tx/AcctStatementRLY/Result/Record';
 2b       select;
 2x       when name = 'SeqNo';
             act = act + 1;
 2e       endsl;

          // receive account balance enquiry
 1x    when path = '/BNKHKB2E/Tx/AcctBalanceRLY/AcctInfo+
          /MTCSavingAcct/Result/Record'
          and name = 'Cur';
          act = act + 1;
 1x    when path = '/BNKHKB2E/Tx/AcctBalanceRLY/AcctInfo'
          and (name = 'SavingAcct' or name = 'CurrentAcct');
          act = act + 1;

          // receive from BNK Today Transaction Response
 1x    when path = '/BNKHKB2E/Tx/TodayTxRLY/Result/Record';
 2b       select;
 2x       when name = 'TxRefNo';
             act = act + 1;
 2e       endsl;

 1e    endsl;

      /end-free
     P                 E


     P EndOfElement    B
     D EndOfElement    PI
     D   UserData                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
      /free

 1b    select;

          // receive error decription from BNK Transfer Response
 1x    when path = '/BNKHKB2E/Head';
 2b       select;
 2x       when name = 'ErrorCode';
             error_desc = 'Package ID:' + packageid + ';' + value;
             scErrCode = value;
 2x       when name = 'ErrorDesc';
             error_desc = error_desc + '-' + %trim(value);
             scErrDesc = value;
 2x       when name = 'TxRefNo';
             scTxRefNo = value;
 2x       when name = 'TxStatus';
             scHdrStat = value;
 2x       when name = 'TxDate';
             scTxDate = value;
 2x       when name = 'TxTime';
             scTxTime = value;
 2e       endsl;

          // receive transfer response
 1x    when path = '/BNKHKB2E/Tx/TransferRLY';
 2b       select;
 2x       when name = 'DebitAcctNo';
             scDebtAcct = value;
 2x       when name = 'DebitCur';
             scDebtCur = value;
 2e       endsl;

          // receive internal transfer error response
 1x    when path = '/BNKHKB2E/Tx/TransferRLY+
          /Requests/Record/InternalTrans';
 2b       select;
 2x       when name = 'RecordStatus' and value <> 'S';
             error.recStat(act) = value;
 2x       when name = 'RecordStatus' and value = 'S';
             success.recStat(act) = value;
 2x       when name = 'RecordErrorCode';
             error.recErrC(act) = value;
 2x       when name = 'RecordErrorDesc';
             error.recErrD(act) = value;
 2x       when name = 'DebitAmt';
             success.DebitAmt(act) = value;
 2x       when name = 'BeneAcctNo';
             success.BeneAcct(act) = value;
 2x       when name = 'BeneAcctName';
             success.BeneName(act) = value;
 2x       when name = 'PaymentCur';
             success.PayCur(act) = value;
 2x       when name = 'CustRef';
             success.CustRef(act) = value;
 2x       when name = 'ValueDate';
             success.ValueDate(act) = value;
 2e       endsl;

          // receive transaction enquiry
 1x    when path = '/BNKHKB2E/Tx/TransferEnquiryRLY';
 2b       select;
 2x       when name = 'DebitAcctNo';
             scDebtAcct = value;
 2x       when name = 'DebitCur';
             scDebtCur = value;
 2x       when name = 'DebitAcctName';
             scDbAcctNm = value;
 2x       when name = 'LastUpdateTime';
             scUpdTim = value;
 2e       endsl;

          // receive internal transfer transaction enquiry
 1x    when path = '/BNKHKB2E/Tx/TransferEnquiryRLY+
          /Requests/Record/InternalTrans';
 2b       select;
 2x       when name = 'TxRefNo';
             Activity.TxRefNo(act) = value;
 2x       when name = 'OperID';
             Activity.OperID(act) = value;
 2x       when name = 'TxStatus';
             Activity.TxStatus(act) = value;
 2x       when name = 'CompleteDate';
             Activity.CompleteDate(act) = value;
 2x       when name = 'DebitAmt';
             Activity.DebitAmt(act) = value;
 2x       when name = 'BeneAcctNo';
             Activity.BeneAcctNo(act) = value;
 2x       when name = 'BeneAcctName';
             Activity.BeneAcctName(act) = value;
 2x       when name = 'PaymentCur';
             Activity.PaymentCur(act) = value;
 2x       when name = 'CustRef';
             Activity.CustRef(act) = value;
 2x       when name = 'EquvAmt';
             Activity.EquvAmt(act) = value;
 2x       when name = 'ValueDate';
             Activity.ValueDate(act) = value;
 2e       endsl;

          // receive today activity
 1x    when path = '/BNKHKB2E/Tx/TodayActivityRLY/Result/Record';
 2b       select;
 2x       when name = 'SeqNo';
             todayAct.Seq(act) = value;
 2x       when name = 'Cur';
             todayAct.Cur(act) = value;
 2x       when name = 'Time';
             todayAct.Time(act) = value;
 2x       when name = 'TxRefNo';
             todayAct.TxRef(act) = value;
 2x       when name = 'Amount';
             todayAct.Amt(act) = %dec(value: 8: 2);
 2x       when name = 'Particulars';
             todayAct.Parti(act) = value;
 2x       when name = 'TxDetail';
             todayAct.Dtl(act) = value;
 2e       endsl;

 1x    when path = '/BNKHKB2E/Tx/TodayActivityRLY';
 2b       select;
 2x       when name = 'LastUpdateTime';
             AcctUpdTim = value;
 2e       endsl;

          // receive account statement
 1x    when path = '/BNKHKB2E/Tx/AcctStatementRLY/Result/Record';
 2b       select;
 2x       when name = 'SeqNo';
             acctStmt.SeqNo(act) = value;
 2x       when name = 'TxDate';
             acctStmt.TxDate(act) = value;
 2x       when name = 'Amount';
             acctStmt.TxAmt(act) = %dec(value: 8: 2);
 2x       when name = 'TxDetail';
             acctStmt.TxDtl(act) = value;
 2e       endsl;

 1x    when path = '/BNKHKB2E/Tx/AcctStatementRLY/Result/Record+
          /Particulars';
 2b       select;
 2x       when name = 'Particular';
             acctStmt.Partic(act) = value;
 2e       endsl;

 1x    when path = '/BNKHKB2E/Tx/AcctStatementRLY';
 2b       select;
 2x       when name = 'LastUpdateTime';
             AcctUpdTim = value;
 2e       endsl;

          // receive account balance
 1x    when path = '/BNKHKB2E/Tx/AcctBalanceRLY/AcctInfo/SavingAcct';
          acctbal.Typ(act) = 'Saving';
 2b       select;
 2x       when name = 'Cur';
             acctbal.Cur(act) = value;
 2x       when name = 'AcctBalance';
             acctbal.AcctBal(act) = value;
 2x       when name = 'HoldBalance';
             acctbal.HoldBal(act) = value;
 2x       when name = 'FloatBalance';
             acctbal.FloatBal(act) = value;
 2x       when name = 'AvailBalance';
             acctbal.AvailBal(act) = value;
 2e       endsl;

 1x    when path = '/BNKHKB2E/Tx/AcctBalanceRLY/AcctInfo/CurrentAcct';
          acctbal.Typ(act) = 'Current';
 2b       select;
 2x       when name = 'Cur';
             acctbal.Cur(act) = value;
 2x       when name = 'HoldBalance';
             acctbal.HoldBal(act) = value;
 2x       when name = 'FloatBalance';
             acctbal.FloatBal(act) = value;
 2x       when name = 'AvailBalance';
             acctbal.AvailBal(act) = value;
 2e       endsl;

 1x    when path =
          '/BNKHKB2E/Tx/AcctBalanceRLY/AcctInfo/MTCSavingAcct/Result/Record';
          acctbal.Typ(act) = 'MTCSaving';
 2b       select;
 2x       when name = 'Cur';
             acctbal.Cur(act) = value;
 2x       when name = 'AcctBalance';
             acctbal.AcctBal(act) = value;
 2x       when name = 'HoldBalance';
             acctbal.HoldBal(act) = value;
 2x       when name = 'DDBalance';
             acctbal.DDBal(act) = value;
 2x       when name = 'AvailBalance';
             acctbal.AvailBal(act) = value;
 2e       endsl;

 1x    when path = '/BNKHKB2E/Tx/AcctBalanceRLY';
 2b       select;
 2x       when name = 'LastUpdateTime';
             AcctUpdTim = value;
 2e       endsl;

          // receive today transaction enquiry
 1x    when path = '/BNKHKB2E/Tx/TodayTxRLY/Result/Record';
 2b       select;
 2x       when name = 'TxRefNo';
             TodayTx.TxRefNo(act) = value;
 2x       when name = 'TxType';
             TodayTx.TxType(act) = value;
 2x       when name = 'TxDate';
             TodayTx.TxDate(act) = value;
 2x       when name = 'TxTime';
             TodayTx.TxTime2(act) = value;
 2x       when name = 'TxStatus';
             TodayTx.TxStatus(act) = value;
 2x       when name = 'TxValueDate';
             TodayTx.ValueDate(act) = value;
 2x       when name = 'RecUserID';
             TodayTx.RecUser(act) = value;
 2e       endsl;

 1e    endsl;

      /end-free
     P                 E
      ***********************************************************
