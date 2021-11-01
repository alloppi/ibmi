      *====================================================================*
      * Program name: JSONEX1                                              *
      * Purpose.....: JSON and REST API Example with OAuth authentication  *
      *                                                                    *
      * Description : Get bank access token                                *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2021/07/23 Alan       AC              New Develop                  *
      *====================================================================*
      *
      *
     H DFTACTGRP(*NO) BNDDIR('LIBHTTP139/HTTPAPI')

      /copy LIBHTTP139/qrpglesrc,httpapi_h

     D rc              s             10I 0
     D msg             s             52A
     D URL             S            300A   varying
     D IFS             S            256A   varying
     D clientID        C                   'xxxxxxxx'
     D clientSecret    C                   'xxxxxxxx'

     c                   callp     http_debug(*ON
     c                               : '/home/alan/jsonex/http_debug1.txt')

     c                   eval      URL = 'https://developer-uat-bank.zatech.com'
     c                                 + '/oauth/token?grant_type'
     c                                 + '=client_credentials&client_id='
     c                                 + clientID
     c                                 + '&client_secret='
     c                                 + clientSecret

     c                   eval      IFS = '/home/alan/jsonex/token.json'

     c                   callp     http_stmf('GET': URL: IFS)

     c                   eval      *inlr = *on
