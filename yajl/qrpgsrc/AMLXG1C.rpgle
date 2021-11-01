      *====================================================================*
      * Program name: AMLXG1R                                              *
      * Purpose.....: Anti Money Laundering                                *
      *               AML XG Create & Send XML Request                     *
      * Description :                                                      *
      * Remarks     : Use LIBHTTP139 to post request                       *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2020/07/23 Alan       AC              New Develop                  *
      *====================================================================*
     H Debug(*Yes)
     H DftActGrp(*No) BndDir('LIBHTTP139/HTTPAPI':'QC2LE')
     H Option(*NoDebugIO)
      *
     FAXGCFGF   IF   E             Disk
     FAXGREQF   IF   E             Disk

     D/Copy QCPYSRC,PSCY01R
     D/Copy QCPYSRC,IFSIO_H
     D/Copy QCPYSRC,ERRNO_H
     D/Copy LIBHTTP139/qrpglesrc,httpapi_h
     D/Copy QSYSINC/QRPGLESRC,QUSEC

      * Calling Parameter for AMLXG2R
     D I_RspFile       s             50a
     D O_RtnCde        S                   Like(RtnCde)
      *
      * Prototype for Delay
     D sleep           pr            10u 0 extproc('sleep')
     D   DelayInSec                  10u 0 value

      * Prototype for Send Program Message
     D SndPgmMsg       pr                  ExtPgm('QMHSNDPM')
     D   MessageID                    7a   const
     D   QualMsgF                    20a   const
     D   MsgData                     80a   const
     D   MsgDtaLen                   10i 0 const
     D   MsgType                     10a   const
     D   CallStkEnt                  10a   const
     D   CallStkCnt                  10i 0 const
     D   MessageKey                   4a
     D   ErrorCode                         LikeDS(QUSEC)
     D                                     options(*varsize)

     D MsgKey          s              4A
     D ErrCode         ds                  LikeDS(QUSEC)

     D fd              s             10I 0
     D rc              s             10I 0
     D crlf            c                   x'0D25'
     D cr              c                   x'0D'

     D w1XmlFile       s             50a   varying
     D w1XmlPath       s             50a   varying
     D w1DbgPath       s             50a   varying
     D w1RspFile       s             50a   varying

     D w1BlockID       s              3p 0 Inz(0)

     D w1Xml           s           8192a   varying
     D w1ContentType   s             50a   varying
     D w1SOAPAction    s            120a   varying
     D w1TimeOut       s              3p 0
     D httpmsg         s             80a   varying

     D w1TimStp        s             17A

     D w1URL           s            100a   varying
     D w1Rsp           s        3000000a   varying

     D w1FalsePosit    s              5a
     D w1BestName      s             20a
     D w1DspMsg        s             80a   varying
     D w1MsgInp        s              1a

      *====================================================================*
      * Main Logic
      *====================================================================*
      *
     c                   ExSr      @InitRef
     c   99              Goto      $ExitPgm
      *
     c                   Read      AXGREQFR                               96
     c                   DoW       Not *In96

      * Open XML header
     c                   ExSr      @OpenXML

      * Set XML content header
     c                   ExSr      @SetXmlHdr

      * Set XML content details
     c                   ExSr      @SetXmlDtl

      * Close XML file
     c                   ExSr      @ClsXML

      * Post the request
     c                   ExSr      @PostReq

      * Parsing response
     c                   ExSr      @ParseRsp
     c   99              Goto      $ExitPgm

     c                   Read      AXGREQFR                               96
     c                   If        Not *in96
     c                   CallP     sleep(2)
     c                   EndIf

     c                   EndDo

     c     $ExitPgm      Tag
     c                   Eval      *InLr = *On
     c                   return
      *
      *====================================================================*
      * Create XML file
      *====================================================================*
     c     @OpenXML      BegSr

      /free
        w1TimStp = %subst( %char(%timestamp(): *ISO0): 1: 17);

        // Create XML file for SOAP header content
        w1XmlFile = 'REQ' + w1TimStp + '.xml' ;
        w1XmlPath = '/home/alan/amlXG/' + w1XmlFile ;

        // Open File with UTF-8, translate from DBCS Chinese (1377) to UTF-8 Coding automatically
        fd = open(w1XmlPath
           : O_WRONLY + O_CREAT + O_TRUNC + O_CCSID + O_TEXTDATA + O_TEXT_CREAT
           : S_IRGRP + S_IWGRP + S_IRUSR + S_IWUSR + S_IROTH
           : 1208
           : 1377) ;
        if fd < 0 ;
          dump '0012' ;
          callp EscErrno(errno) ;
        endif ;

      /end-free

     c                   EndSr
      *
      *====================================================================*
      * Set XML Header Line
      *====================================================================*
     c     @SetXmlHdr    BegSr

      /free

        w1Xml =
          '<soapenv:Envelope xmlns:soapenv='                          +
          '"http://schemas.xmlsoap.org/soap/envelope/" '              +
          'xmlns:brid="https://bridgerinsight.lexisnexis.com/'        +
          'BridgerInsight.Web.Services.Interfaces.11.2">'             + crlf +
          ' <soapenv:Header/>'                                        + crlf +
          ' <soapenv:Body>'                                           + crlf +
          '  <brid:Search>'                                           + crlf +
          '   <brid:context>'                                         + crlf +
          '    <brid:ClientID>' + %trim(AXGCID)                       +
                 '</brid:ClientID>'                                   + crlf +
          '    <brid:Password>' + %trim(AXGPSW)                       +
                 '</brid:Password>'                                   + crlf +
          '    <brid:UserID>' + %trim(AXGUID)                         +
                 '</brid:UserID>'                                     + crlf +
          '    <brid:ClientReference>' + %trim(AXGCRF)                +
                 '</brid:ClientReference>'                            + crlf +
          '   </brid:context>'                                        + crlf +
          '   <brid:config>'                                          + crlf +
          '    <brid:AssignResultTo>'                                 + crlf +
          '     <brid:Division>' + %trim(AXGDIV)                      +
                  '</brid:Division>'                                  + crlf +
          '     <brid:EmailNotification>' + %trim(AXGEMLNTY)          +
                  '</brid:EmailNotification>'                         + crlf +
          '     <brid:RolesOrUsers>'                                  + crlf +
          '      <brid:string>' + %trim(AXGROLE)                      +
                   '</brid:string>'                                   + crlf +
          '     </brid:RolesOrUsers>'                                 + crlf +
          '     <brid:Type>' + %trim(AXGROLTYP)                       +
                  '</brid:Type>'                                      + crlf +
          '    </brid:AssignResultTo>'                                + crlf +
          '    <!--'                                                  + crlf +
          '    <brid:Watchlist>'                                      + crlf +
          '     <brid:AutomaticFalsePositiveRules>'                   + crlf +
          '      <brid:Countries>true</brid:Countries>'               + crlf +
          '      <brid:Gender>true</brid:Gender>'                     + crlf +
          '      <brid:DOB>true</brid:DOB>'                           + crlf +
          '     </brid:AutomaticFalsePositiveRules>'                  + crlf +
          '     <brid:FalseMatchSettings>'                            + crlf +
          '      <brid:Dob>true</brid:Dob>'                           + crlf +
          '      <brid:Gender>true</brid:Gender>'                     + crlf +
          '     </brid:FalseMatchSettings>'                           + crlf +
          '    </brid:Watchlist>'                                     + crlf +
          '    -->'                                                   + crlf +
          '    <brid:PredefinedSearchName>' + %trim(AXGPSN)           +
                 '</brid:PredefinedSearchName>'                       + crlf +
          '    <brid:WriteResultsToDatabase>' + %trim(AXGWRTD)        +
                 '</brid:WriteResultsToDatabase>'                     + crlf +
          '   </brid:config>'                                         + crlf ;

      /end-free

     c                   EndSr
      *
      *====================================================================*
      * Set XML searching details lines
      *====================================================================*
     c     @SetXmlDtl    BegSr

     c                   Eval      w1BlockID = 1

      /free

        w1Xml = w1Xml                                                 +
          '   <brid:input>'                                           + crlf +
          '   <brid:BlockID>' + %editc(w1BlockID:'X')                 +
               '</brid:BlockID>'                                      + crlf +
          '    <brid:Records>'                                        + crlf +
          '     <brid:InputRecord>'                                   + crlf +
          '      <brid:Entity>'                                       + crlf +
          '       <brid:AdditionalInfo>'                              + crlf +
          '        <brid:InputAdditionalInfo>'                        + crlf +
          '         <brid:Date>'                                      + crlf +
          '          <brid:Month>' + %editc(REQDOBMTH:'X')            +
                      '</brid:Month>'                                 + crlf +
          '          <brid:Year>' + %editc(REQDOBYR:'X')              +
                      '</brid:Year>'                                  + crlf +
          '         </brid:Date>'                                     + crlf +
          '         <brid:Type>' + %trim(REQAITYP)                    +
                     '</brid:Type>'                                   + crlf +
          '        </brid:InputAdditionalInfo>'                       + crlf +
          '       </brid:AdditionalInfo>'                             + crlf +
          '       <brid:Addresses>'                                   + crlf +
          '        <brid:InputAddress>'                               + crlf +
          '         <brid:Country>' + %trim(REQADRCTY)                +
                     '</brid:Country>'                                + crlf +
          '         <brid:Type>' + %trim(REQADRTYP)                   +
                     '</brid:Type>'                                   + crlf +
          '        </brid:InputAddress>'                              + crlf +
          '       </brid:Addresses>'                                  + crlf +
          '       <brid:EntityType>' + %trim(REQENTTYP)               +
                   '</brid:EntityType>'                               + crlf +
          '       <brid:Gender>' + %trim(REQGENDER)                   +
                   '</brid:Gender>'                                   + crlf +
          '       <brid:Name>'                                        + crlf +
          '        <brid:First>' + %trim(REQFSTNAM)                   +
                    '</brid:First>'                                   + crlf +
          '        <brid:Last>' + %trim(REQLASNAM)                    +
                    '</brid:Last>'                                    + crlf +
          '       </brid:Name>'                                       + crlf +
          '      </brid:Entity>'                                      + crlf +
          '     </brid:InputRecord>'                                  + crlf +
          '    </brid:Records>'                                       + crlf +
          '   </brid:input>'                                          + crlf ;
      /end-free

     c                   EndSr
      *
      *====================================================================*
      * Close XML file
      *====================================================================*
     c     @ClsXML       BegSr

      /free

        w1Xml = w1Xml                                                 +
          '  </brid:Search>'                                          + crlf +
          ' </soapenv:Body>'                                          + crlf +
          '</soapenv:Envelope>'                                       + crlf ;

        if write(fd: %addr(w1Xml)+2: %len(w1Xml)) < %len(w1Xml) ;
          dump '0013' ;
          callp EscErrno(errno) ;
        endif ;
        callp close(fd) ;

      /end-free

     c                   EndSr
      *
      *====================================================================*
      * Post Request
      *====================================================================*
     c     @PostReq      BegSr
      *
      /free

       // Note:  http_XmlStripCRLF(*ON/*OFF) controls whether or not
       //        the XML parser removes CR and LF characters from the
       //        Xml data that's passed to your 'Incoming' procedure.
       http_XmlStripCRLF(*ON) ;

       // Note:  http_debug(*ON/*OFF) can be used to turn debugging
       //      on and off.  When debugging is turned on, diagnostic
       //      info is written to an IFS file named
       //      /tmp/httpapi_debug.txt

       // Just turn off the debug, If case want to debug, just turn it on
       w1DbgPath = '/home/alan/amlXG/REQ' + w1TimStp + '.DBG';

       // Convert CCSID from 1377 (DBCS Chinese) to 1208 (UTF-8)
       // http_setCCSIDs(toCCSID: fromCCSID)
       http_setCCSIDs(1208 :1377) ;
       // http_debug(*On: w1DbgPath) ;
       http_debug(*Off: w1DbgPath) ;

       // Set string that sent to remote site be DBCS Chinese (1377)
       // and translate to UTF-8 when sent over to remote site
       http_setOption('local-ccsid': '1377') ;
       http_setOption('network-ccsid': '1208') ;
       http_setOption('file-ccsid': '1208') ;

       w1TimeOut = 30 ;
       http_setOption('timeout': %char(w1TimeOut)) ;

       // http_setOption('Accept-Encoding': 'gzip,deflate') ;
       // http_setOption('user-agent': 'Apache-HttpClient/4.5.5') ;

       w1SOAPAction = 'https://bridgerinsight.lexisnexis.com' +
                      '/BridgerInsight.Web.Services.Interfaces.11.2' +
                      '/ISearch/Search' ;
       http_setOption('SOAPAction': w1SOAPAction) ;

       w1URL = 'https://bridger.lexisnexis.com'+
               '/LN.WebServices/11.2/XGServices.svc/Search' ;
       w1ContentType = 'text/xml;charset=UTF-8' ;

       // Post request
       rc = http_req( 'POST': w1URL: *Omit: w1Rsp: *Omit: w1XML: w1ContentType);

       // Error handling
       if (rc <> 1) ;
          httpmsg = http_error ;
          ErrCode = *Allx'00';
          SndPgmMsg( 'CPF9897'
                   : 'QCPFMSG   *LIBL'
                   : httpmsg
                   : %len(httpmsg)
                   : '*DIAG'
                   : '*EXT'
                   : 0
                   : MsgKey
                   : ErrCode );
          dump 'HTTPMSG' ;
          callp EscErrno(errno) ;
       endif ;

       // Format response
       w1Rsp = %scanrpl('&lt;'  : '<' : w1Rsp) ;
       w1Rsp = %scanrpl('&gt;'  : '>' : w1Rsp) ;
       w1Rsp = %scanrpl('&amp;' : '&' : w1Rsp) ;
       w1Rsp = %scanrpl('&#xd;' : cr  : w1Rsp) ;
       w1Rsp = %scanrpl('&#xD;' : cr  : w1Rsp) ;
       w1Rsp = %scanrpl('&quot;': '"' : w1Rsp) ;
       w1Rsp = %scanrpl('&apos;': '''': w1Rsp) ;

       w1RspFile  = '/home/alan/amlXG/RSP' + w1TimStp + '.xml' ;
       fd = open(w1RspFile
           : O_WRONLY + O_CREAT + O_TRUNC + O_CCSID + O_TEXTDATA + O_TEXT_CREAT
           : S_IRGRP + S_IWGRP + S_IRUSR + S_IWUSR + S_IROTH
           : 1208
           : 1377) ;
       if fd < 0 ;
          dump '0014' ;
          callp EscErrno(errno) ;
       endif ;

       if write(fd: %addr(w1Rsp)+4: %len(w1Rsp))
         < %len(%trimr(w1Rsp)) ;
           dump '0015' ;
           callp EscErrno(errno) ;
       endif ;
       callp close(fd) ;

      /end-free

     c                   EndSr
      *
      *====================================================================*
      * Parse response
      *====================================================================*
     c     @ParseRsp     BegSr

      *
      /free
       w1BestName = *Blank;
       w1FalsePosit = *Blank;

       monitor;
           xml-into w1BestName %xml(w1Rsp: 'case=any ns=remove +
               path=Envelope/Body/SearchResponse/SearchResult/Records+
                   /ResultRecord/Watchlist/Matches/WLMatch/BestName') ;
       on-error 351;
       endmon;

       monitor;
           xml-into w1FalsePosit %xml(w1Rsp: 'case=any ns=remove +
               path=Envelope/Body/SearchResponse/SearchResult/Records+
                   /ResultRecord/Watchlist/Matches/WLMatch/AutoFalsePositive') ;
       on-error 351;
       endmon;

       w1DspMsg = 'Name:' + %trim(w1BestName)
                + ', AutoFalsePositive:' + w1FalsePosit ;
       ErrCode = *Allx'00';
       SndPgmMsg( 'CPF9897'
                : 'QCPFMSG   *LIBL'
                : w1DspMsg
                : %len(w1DspMsg)
                : '*NOTIFY'
                : '*EXT'
                : 0
                : MsgKey
                : ErrCode );
       // If user want to press 'Enter' to continue
       // dsply w1DspMsg '' w1MsgInp;
       //  if w1MsgInp='q';
       //      *Inlr = *On;
       //      return;
       //  EndIf;

      /end-free

     c                   EndSr
      *
      *====================================================================
      * Initial Reference
      *-===================================================================
     c     @InitRef      BegSr
      *
     c                   Read      AXGCFGFR                               97
     c                   If        *In97
     c                   Eval      *In99 = *On
     c     '0001'        Dump
     c                   Goto      $XInitRef
     c                   EndIf
      *
     c     $XInitRef     Tag
     c                   EndSr
      *
      /define ERRNO_LOAD_PROCEDURE
      /copy QCPYSRC,errno_h
