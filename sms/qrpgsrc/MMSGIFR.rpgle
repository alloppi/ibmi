      *====================================================================*
      * Program name: MMSR                                                 *
      * Purpose.....: Sending MMS                                          *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2019/11/18 Alan       AC              New Development              *
      *====================================================================*
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('HTTPAPI':'QC2LE':'BASE64')

     D/copy qrpglesrc,httpapi_h
     D/copy qcpysrc,base64_h
     D/copy qcpysrc,ifsio_h

     D cmd             pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D ReportError     PR

     D rc              s             10I 0
     D msg             s             52A
     D CRLF            C                   CONST(x'0d25')
     D data            S          65535A
     D imagedata       S          65535A
     D ContentType     S            512A

     D tempAttach      s             50A   varying
     D att             s             10I 0
     D fd              s             10I 0
     D encData         s          65535A
     D encLen          s             10i 0
     D len             s             10i 0

     c                   eval      *inlr = *on
     c                   callp     http_debug(*ON)

      /free
        tempAttach = '/home/cya012/test.gif';
        att = open( tempAttach: O_RDONLY );
          if (att = -1);
             ReportError();
          endif;

          dow '1';
             len = read(att: %addr(imagedata): %size(imagedata));
             if (len < 1);
                leave;
             endif;

             enclen = base64_encode( %addr(imagedata)
                                   : len
                                   : %addr(encdata)
                                   : %size(encdata)-2 );

             // encdata = imagedata;
             // enclen  = len;
             %subst(encdata:enclen+1) = CRLF;
             %subst(encdata:enclen+2) =
               '------=_Part_61_13039412.1400489653107--';
          enddo;

          callp close(att);

        data =
          '------=_Part_61_13039412.1400489653107' + CRLF +
          'Content-Type: application/smil' + CRLF +
          'Content-ID: <mms.smil>' + CRLF +
          'Content-Location: mms.smil' + CRLF + CRLF +
          '<smil>' + CRLF +
          '<head>' + CRLF +
          '<layout>' + CRLF +
          '<root-layout background-color="#FF0000"/>' + CRLF +
          '<region id="Image" top="0" left="0" ' +
          'height="100%" width="100%" fit="fill"/>' + CRLF +
          '</layout>' + CRLF +
          '</head>' + CRLF +
          '<body>' + CRLF +
          '<par dur="13000ms">' + CRLF +
          '<img src="image_0.gif" region="Image"/>' + CRLF +
          '</par>' + CRLF +
          '</body>' + CRLF +
          '</smil>' + CRLF +
          '------=_Part_61_13039412.1400489653107' + CRLF +
          'Content-Type: image/gif' + CRLF +
          'Content-ID: <image_0.gif>' + CRLF +
          'Content-Transfer-Encoding: base64' + CRLF +
          'Content-Location: image_0.gif' + CRLF + CRLF +
          encdata;

        ContentType =
          'multipart/related; boundary=' +
          '"----=_Part_61_13039412.1400489653107"' + CRLF +
          'From: +85261140169' + CRLF +
          'To: +85297218700' + CRLF +
          'Subject: MMS_GIF_Test' + CRLF +
          'X-Client-MMS-Id: bdffcc42-3dc2-11e6-ac61-9e71128cae77' + CRLF +
          'X-SS-Mms-DAPI-Username: Promise' + CRLF +
          'X-SS-Mms-DAPI-Password: xxxxxxxx';

        rc = http_url_post(
            'https://mmsproxytest-nc.smartone.com/submit_mms'
           : %addr(data)
           : %len(%trimr(data))
           : '/tmp/mms.txt'
           : HTTP_TIMEOUT
           : HTTP_USERAGENT
           : ContentType);
      /end-free
     c
     c                   if        rc <> 1
     c                   eval      msg = http_error
     c                   dsply                   msg
     c                   return
     c                   endif

      ** This should be the XML data that UPS returns to us:
     c                   callp     cmd('DSPF ''/tmp/mms.txt''': 200)
     c                   return
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ReportError():  Send an escape message explaining any errors
      *                 that occurred.
      *
      *  This function requires binding directory QC2LE in order
      *  to access the __errno() function.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ReportError     B
     D ReportError     PI

     D get_errno       PR              *   ExtProc('__errno')
     D ptrToErrno      s               *
     D errno           s             10I 0 based(ptrToErrno)

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                      1A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                 8192A   options(*varsize)

     D ErrorCode       DS                  qualified
     D  BytesProv              1      4I 0 inz(0)
     D  BytesAvail             5      8I 0 inz(0)

     D MsgKey          S              4A
     D MsgID           s              7A

      /free

         ptrToErrno = get_errno();
         MsgID = 'CPE' + %char(errno);

         QMHSNDPM( MsgID
                 : 'QCPFMSG   *LIBL'
                 : ' '
                 : 0
                 : '*ESCAPE'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ErrorCode         );

      /end-free
     P                 E


