      *====================================================================*
      * Program name: MMSTESTR                                             *
      * Purpose.....: Sending MMS (First tried)                            *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2019/11/18 Alan       AC              New Development              *
      *====================================================================*
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('HTTPAPI')

     D/copy qrpglesrc,httpapi_h

     D cmd             pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D rc              s             10I 0
     D msg             s             52A
     D CRLF            C                   CONST(x'0d25')
     D data            S           2048A
     D ContentType     S            512A

     c                   eval      *inlr = *on
     c                   callp     http_debug(*ON)

      /free
        data =
          '------=_Part_61_13039412.1400489653107' + CRLF +
          'Content-Type: application/smil' + CRLF +
          'Content-ID: <mms.smil>' + CRLF +
          'Content-Location: mms.smil' + CRLF + CRLF +
          '<smil>' + CRLF +
          '<head>' + CRLF +
          '<layout>' + CRLF +
          '<root-layout background-color="#FF0000"/>' + CRLF +
          '<region id="Text" top="50%" left="0" ' +
          'height="50%" width="100%" fit="scroll"/>' + CRLF +
          '</layout>' + CRLF +
          '</head>' + CRLF +
          '<body>' + CRLF +
          '<par dur="1300ms">' + CRLF +
          '<text src="text_0.txt" region="Text"/>' + CRLF +
          '</par>' + CRLF +
          '</body>' + CRLF +
          '</smil>' + CRLF +
          '------=_Part_61_13039412.1400489653107' + CRLF +
          'Content-Type: text/plain; charset=us-ascii; name=text_0.txt' + CRLF +
          'Content-Transfer-Encoding: 7bit' + CRLF +
          'Content-Disposition: attachment;FileName=text_0.txt;' +
          'Charset=us-ascii' + CRLF +
          'Content-ID: 0' + CRLF +
          'Content-Location: text_0.txt' + CRLF + CRLF +
          'Hello' + CRLF +
          '------=_Part_61_13039412.1400489653107--';

        ContentType =
          'multipart/related; boundary=' +
          '"----=_Part_61_13039412.1400489653107"' + CRLF +
          'From: +85261140169' + CRLF +
          'To: +85297218700' + CRLF +
          'Subject: MMS_Subject_Test' + CRLF +
          'X-Client-MMS-Id: bdffcc42-3dc2-11e6-ac61-9e71128cae77' + CRLF +
          'X-SS-Mms-DAPI-Username: system' + CRLF +
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
