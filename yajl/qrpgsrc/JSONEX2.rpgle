      *====================================================================*
      * Program name: JSONEX2                                              *
      * Purpose.....: JSON and REST API Example with OAuth authentication  *
      *                                                                    *
      * Description : Send Sample API to bank                              *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2021/07/23 Alan       AC              New Develop                  *
      *====================================================================*
      *
     H Debug(*Yes)
     H DftActGrp(*No) ActGrp(*Caller)
     H BndDir('LIBHTTP139/HTTPAPI':'QC2LE')

     D/Copy qcpysrc,ERRNO_H
     D/Copy qcpysrc,IFSIO_H
     D/Copy LIBHTTP139/qrpglesrc,httpapi_h

      * Parameters
     D P_ApiType       S              1a

     D fd              S             10I 0
     D rc              S             10I 0
     D wrdata          S           1024A
     D rddata          S            600A
     D rdsign          S                         like(rddata)
     D token           S            400A
     D sign            S            600A
     D w1Sign          S            600A
     D flags           S             10U 0
     D mode            S             10U 0
     D Len             S             10I 0
     D err             S             10I 0
     D tokenkey        S             20A
     D tokenStr        S             10I 0
     D tokenEnd        S             10I 0

     D w1URL           S            100A         varying                        URL Name
     D w1ReqHdr        S            400A                                        Request Header
     D w1ReqBody       S                         like(wrdata)                   Request Body
     D w1ReqHdrBody    S                         like(wrdata)                   Request Header+Body
     D w1ReqDtl        S           2048A                                        Request Post String
     D w1ErrMsg        S            100A                                        Error Message
      *
     D w1Cmd           S            500A                                        Command
      *
     D w1Domain        c                   const('https://-
     D                                     developer-uat-bank.zatech.com')
     D w1Path          c                   const('/home/alan/jsonex/')
      *
     D w1SndDtlF       S            100A   varying
     D w1RcvDtlF       S            100A   varying
      *
     D w1MchDate       s               D
     D w1MchTime       s               T
      *
     D w1ReqDate       s              8A
     D w1ReqTime       s              6A
      *
     D qcmdexc         PR                  ExtPgm('QCMDEXC')
     D   cmd                        500A   Options(*Varsize) Const
     D   cmdlen                      15P 5 Const
      *
      *****************************************************************
     c     *entry        plist
     c                   parm                    P_APIType

     c                   exsr      @GetToken

      * 2=order/orderList
      * 3=risk/resultNotice
      * 4=order/successResults
      * 5=confirm
      /free
       select;

         when P_APIType = '2';
           w1SndDtlF = w1Path + 'SndDtl2.json';
           w1RcvDtlF = w1Path + 'RcvDtl2.json';
           w1URL = w1Domain + '/instalpre/systemOutApi/order/orderList';
           w1ReqBody =
                   '{'
                 + '}';
           exsr @CrtHeadBody;

         when P_APIType = '3';
           w1SndDtlF = w1Path + 'SndDtl3.json';
           w1RcvDtlF = w1Path + 'RcvDtl3.json';
           w1URL = w1Domain + '/instalpre/systemOutApi/risk/resultNotice';
           w1ReqBody =
                   '{'
                 + '"businessNo":"1234567890",'
                 + '"orderNo":"1234567890",'
                 + '"maxApproveAmount":50000.0,'
                 + '"maxApproveRate":40.00,'
                 + '"minApproveRate":20.00'
                 + '}';
           exsr @CrtHeadBody;

         when P_APIType = '4';
           w1SndDtlF = w1Path + 'SndDtl4.json';
           w1RcvDtlF = w1Path + 'RcvDtl4.json';
           w1URL = w1Domain + '/instalpre/systemOutApi/order/successResults';
           w1ReqBody =
                   '{'
                 + '"orderNos":['
                 + '"1234567890"'
                 + ']'
                 + '}';
           exsr @CrtHeadBody;

         when P_APIType = '5';
           w1SndDtlF = w1Path + 'SndDtl5.json';
           w1RcvDtlF = w1Path + 'RcvDtl5.json';
           w1URL = w1Domain + '/instalpre/systemOutApi/order/confirm';
           w1ReqBody =
                   '{'
                 + '"action":"approveList",'
                 + '"orders":['
                 + '{'
                 + '"businessNo":"1234567890",'
                 + '"orderNo":"1234567890",'
                 + '"orderStatus":"Y"'
                 + '},'
                 + ']'
                 + '}';
           exsr @CrtHeadBody;

       endsl;
      /end-free

     c                   exsr      @CrtSign

     c*                  exsr      @VfySign

     c                   exsr      @SndReq

     c                   eval      *inlr = *on
     c                   return

      *===================================================================*
      * Initial Routine
      *===================================================================*
     c     *InzSr        BegSr
      *
     c                   Eval      w1MchDate = %date()
     c                   Eval      w1MchTime = %time()
      *
     c                   EndSr
      *
      *===================================================================*
      * Get access token
      *===================================================================*
     C     @GetToken     BegSr
      *
     c                   eval      flags = O_RDONLY+O_TEXTDATA
     c                   eval      mode = S_IRUSR

     c                   eval      fd = open('/home/alan/jsonex/token.json':
     c                                       flags: mode: 819)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     c                   eval      len = read(fd: %addr(rddata):
     c                                            %size(rddata))

     c                   eval      tokenkey = '"access_token":"'
     c                   eval      tokenstr = %scan(%trim(tokenkey): rddata)
     c                   if        tokenstr > 0
     c                   eval      tokenstr = tokenstr + %len(%trim(tokenkey))
     c                   Eval      tokenend = %scan('"': rddata: tokenstr+1)
     c                   endif
     c                   if        tokenstr > 0 and tokenend > 0
     c                   eval      token = %subst(rddata: tokenstr
     c                                                  : (tokenend-tokenstr))
     c                   else
     c                   eval      token = *Blank
     c                   endif

     c                   callp     close(fd)

     c                   endsr
      *===================================================================*
      * Create Header and body
      *===================================================================*
     C     @CrtHeadBody  BegSr

      /free
       w1ReqDate = %char(w1MchDate: *ISO0);
       w1ReqTime = %char(w1MchTime: *ISO0);

       // Request value of header + body
       w1ReqHdr  =
          '{'
           + '"businessId":"1234567890",'
           + '"reqTime":"' + w1ReqTime + '",'
           + '"reqDate":"' + w1ReqDate + '",'
           + '"msgVersion":"V1.0"'
        + '}';

       w1ReqHdrBody = %trim(w1ReqHdr) + %trim(w1ReqBody);

      /end-free
     c                   callp     unlink('/home/alan/jsonex/ReqHdrBody.txt')

     c                   eval      flags = O_WRONLY + O_CREAT + O_TRUNC
     c                                   + O_CCSID
     c                                   + O_TEXTDATA + O_TEXT_CREAT

     c                   eval      mode = S_IRUSR + S_IWUSR
     c                                  + S_IRGRP
     c                                  + S_IROTH

     c                   eval      fd=open('/home/alan/jsonex/ReqHdrBody.txt':
     c                                       flags: mode: 819: 0)
     c                   if        fd < 0
     c                   eval      w1ErrMsg = %str(strerror(errno))
     c                   callp     die('open() for output: ' + w1ErrMsg)
     c                   endif

      * Write some data
     c                   eval      wrdata = %trim(w1ReqHdrBody)
     c                   if        write(fd: %addr(wrdata)
     c                                     : %len(%trim(wrdata))) < 1
     c                   eval      w1ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     die('open(): ' + w1ErrMsg)
     c                   endif

     c                   callp     close(fd)

     c                   endsr

      *====================================================================*
      * Create Sign
      *====================================================================*
     C     @CrtSign      BegSr
      *
     c                   callp     unlink('/home/alan/jsonex/ReqHdrBody.hash')
     c                   callp     unlink('/home/alan/jsonex/ReqHdrBody.sign')
     c                   callp     unlink('/home/alan/jsonex/ReqHdrBody.vfg')
     c                   callp     unlink(
     c                             '/home/alan/jsonex/ReqHdrBody.sign.base64')

      /free
       w1Cmd =
          'touch -C 819 /home/alan/jsonex/ReqHdrBody.sign.base64';

      /end-free
      *
     C                   Eval      w1Cmd =
     C                               'strqsh cmd(''' + %trim(w1Cmd) + ''')'
     C                   Monitor
     C                   CallP     qcmdexc( w1Cmd: %len( %trim(w1Cmd) ) )
     C                   On-Error
     C     '0011'        Dump
     C                   EndMon
      *
      /free
       // Request value of header + body
       w1Cmd =
          'cat /home/alan/jsonex/ReqHdrBody.txt | '
        + 'tr -d "\n" | '
        + 'openssl dgst -sha256 | '
        + 'sed ''''s/^.*= //'''' | '
        + 'tr -d "\n -"| '
        + 'tr ''''a-z'''' ''''A-Z'''' | '
        + 'openssl dgst -sha256 -sign /home/alan/jsonex/prikey.pem | '
        + 'openssl base64 -A > /home/alan/jsonex/ReqHdrBody.sign.base64 ';

      /end-free
      *
     C                   Eval      w1Cmd =
     C                               'strqsh cmd(''' + %trim(w1Cmd) + ''')'
     C                   Monitor
     C                   CallP     qcmdexc( w1Cmd: %len( %trim(w1Cmd) ) )
     C                   On-Error
     C     '0012'        Dump
     C                   EndMon
      *
      * Read Signed Base64 file
     c                   eval      flags = O_RDONLY+O_TEXTDATA
     c                   eval      mode = S_IRUSR

     c                   eval      fd = open(
     c                              '/home/alan/jsonex/ReqHdrBody.sign.base64'
     c                              :flags: mode: 819)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     c                   eval      len = read(fd: %addr(rdsign):
     c                                            %size(rdsign))

     c                   eval      Sign = rdsign

     c                   callp     close(fd)

     c                   eval      w1Sign = '"' + %trim(Sign) + '"'

     C                   EndSr
      *
      *===================================================================*
      * Sending Request
      *===================================================================*
     C     @SndReq       BegSr
      *
      /free
       // {"header":"value","body":"value","sign":"value"}
         w1ReqDtl =
            '{'
          + '"sign":'   + %trim(w1Sign)    + ','
          + '"body":'   + %trim(w1ReqBody) + ','
          + '"header":' + %trim(w1ReqHdr)
          + '}';

      /end-free
     c                   callp     unlink(w1SndDtlF)
     c                   callp     unlink(w1RcvDtlF)

     c                   eval      flags = O_WRONLY + O_CREAT + O_TRUNC
     c                                   + O_CCSID
     c                                   + O_TEXTDATA + O_TEXT_CREAT

     c                   eval      mode = S_IRUSR + S_IWUSR
     c                                  + S_IRGRP
     c                                  + S_IROTH

     c                   eval      fd = open(w1SndDtlF
     c                                      :flags: mode: 819: 0)
     c                   if        fd < 0
     c                   eval      w1ErrMsg = %str(strerror(errno))
     c                   callp     die('open() for output: ' + w1ErrMsg)
     c                   endif

      * Write some data
     c                   if        write(fd: %addr(w1ReqDtl)
     c                                         : %len(%trim(w1ReqDtl)))<1
     c                   eval      w1ErrMsg = %str(strerror(errno))
     c                   callp     close(fd)
     c                   callp     die('open(): ' + w1ErrMsg)
     c                   endif

     c                   callp     close(fd)

      /free

       // Set http debug
       http_debug(*on: '/home/alan/jsonex/http_debug2.txt');

       // Set string that sent to remote site be ascii (819)
       // and translate to UTF-8 when sent over to remote site
       http_setOption('local-ccsid': '819') ;
       http_setOption('network-ccsid': '1208') ;

       // Set time-out in seconds
       http_setOption('timeout': '60') ;

       // Add Customised http header
       http_xproc( HTTP_POINT_ADDL_HEADER: %paddr(Req_Headers) );

       // Post request
       rc = http_req( 'POST'
                    : w1URL                              // URL to receive
                    : w1RcvDtlF                          // File to receive
                    : *Omit                              // String to receive
                    : w1SndDtlF                          // File to send
                    : *Omit                              // String to send
                    : 'application/json');               // Content Type

       // Error message can be found by w1ErrMsg
       // Returns  -1 for local-detected error
       //     0 for communications timed out
       //     1 for success
       // 2-999 for HTTP server provided error code
       if (rc <> 1) ;
         w1ErrMsg = http_error ;
         dump '0010' ;
         http_crash();
       endif ;

      /end-free

     C                   EndSr

      *
     P Req_Headers     B
     D Req_Headers     PI
     D   Header                    1024A   varying
      /free

         Header = 'authorization: Bearer ' + %trim(token) + x'0d25';

      /end-free
     P                 E
      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY QCPYSRC,ERRNO_H
