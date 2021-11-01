      *===================================================================*
      * Program name: XMLSRR3                                             *
      * Purpose.....: Transfer Request XML Sending                        *
      *                                                                   *
      * Date written: 2017/02/28                                          *
      *                                                                   *
      * Description : The program would pass the Transfer Request         *
      *               XML file to the gateway Machine                     *
      *               using the Bank API                                  *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2017/02/28 Alan       AC              New Developement            *
      *===================================================================*
     H DEBUG(*YES)
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H BNDDIR('HTTPAPI')
      *
      * Standard D spec.
      /Copy QCpysrc,httpapi_h
      /Copy QCpySrc,PSCY01R
      /Copy QCpySrc,IFSIO_H
      /Copy QCpySrc,ERRNO_H
      *
      * Constant
     D CONTENT_TYPE    C                   'application/xml; charset=utf-8'
      *
      * Work fields
     D W1RtnCde        S                   Like(RtnCde)
     D W1RpyFile       S                   Like(R_RpyFile)
     D W1URL           S             50a
     D W1ReqFile       S                   Like(P_ReqFile)
     D W1ReqData       S          32752a
     D W1PostData      S          32752a   varying
     D w1EncryData     s          32752a
     D w1DataSize      s              5p 0
     D rc              S             10i 0
07427D httpmsg         S             80A
      *
      * Parameters
     D P_ReqType       S              2a
     D P_PID           S             17a
     D P_ReqFile       S             50a
     D P_GMIP          S             15a
     D R_RtnCde        S                   Like(RtnCde)
     D R_RpyFile       s             50a
      *
     D flags           S             10U 0
     D mode            S             10U 0
     D Len             S             10I 0
     D fd              S             10I 0
     D pos             S              5p 0
      *
      * Parameters for PSXX0JR
     D I_Action        s              1a
     D I_PlainText     s          32752a
     D I_EncryData     s          32752a
     D I_DataSize      s              5p 0
     D O_RtnCde        s                   Like(RtnCde)
     D O_PlainText     s          32752a
     D O_EncryData     s          32752a
      *
      *****************************************************************
      * Mainline logic
      *****************************************************************
     C     *Entry        Plist
     C                   Parm                    P_ReqType
     C                   Parm                    P_PID
     C                   Parm                    P_ReqFile
     C                   Parm                    P_GMIP
     C                   Parm                    R_RtnCde
     C                   Parm                    R_RpyFile
      *
      * Initial Process
     C                   Eval      R_RtnCde = 1
     C                   Eval      R_RpyFile = *Blank
      *
     C                   Eval      W1RtnCde = *Zero
     C                   Eval      W1RpyFile = *Blank
      *
      * Main Process
     C                   If        W1RtnCde = *Zero
     C                   Eval      W1ReqFile = P_ReqFile
     C                   Eval      flags = O_RDONLY
     C                   Eval      fd = open(%trim(W1ReqFile) :
     C                                       flags)
     C                   If        fd < 0
     C                   ExSr      @ClrDump
     C     '0001'        Dump
     C                   Eval      W1RtnCde = 1
     C                   EndIf
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   Eval      len = read(fd: %addr(W1ReqData):
     C                                            %size(W1ReqData))
     C                   If        len < 1
     C                   ExSr      @ClrDump
     C     '0002'        Dump
     C                   Eval      W1RtnCde = 1
     C                   Callp     close(fd)
     C                   EndIf
     C                   callp     close(fd)
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
      * Decrypt Data
     C                   Eval      w1EncryData = W1ReqData
     C                   If        %rem(%len(%trim(W1ReqData)): 16) <> 0
     C                   Eval      w1DataSize =
     C                             (%div(%len(%trim(W1ReqData)): 16) + 1) * 16
     C                   Else
     C                   Eval      w1DataSize =
     C                             %len(%trim(W1ReqData))
     C                   EndIf
      *
     C                   Call      'ENCAPI2R'
     C                   Parm      'D'           I_Action
     C                   Parm      *Blank        I_PlainText
     C                   Parm      w1EncryData   I_EncryData
     C                   Parm      w1DataSize    I_DataSize
     C                   Parm                    O_RtnCde
     C                   Parm                    O_PlainText
     C                   Parm                    O_EncryData
     C                   If        O_RtnCde <> 0
     C                   ExSr      @ClrDump
     C     '0004'        Dump
     C                   Eval      W1RtnCde = 1
     C                   Else
     C                   Eval      W1PostData = O_PlainText
     C                   Eval      pos = %scan(x'0d25': W1PostData)
     C                   Eval      W1PostData = %subst(W1PostData:1:pos-1)
     C                   EndIf
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   ExSr      @BnkReqSnd
     C                   EndIf
      *
     C                   If        W1RtnCde = *Zero
     C                   Eval      R_RtnCde = *Zero
     C                   Eval      R_RpyFile = W1RpyFile
     C                   EndIf
      *
     C     $EndMain      Tag
     C                   Eval      *InLr = *On
     C                   Return
      *
      *===============================================================*
      * @BnkReqSnd - Bank Request Sending
      *===============================================================*
     C     @BnkReqSnd    BegSr
      *
      * Setting of Reply File Name
     C                   Select
     C                   When      P_ReqType = '01'
     C                   Eval      W1RpyFile = '/BnkHK/TRFREQRLY' +
     C                                         %Trim(P_PID) + '.XML'
     C                   When      P_ReqType = '02'
     C                   Eval      W1RpyFile = '/BnkHK/TRFENQRLY' +
     C                                         %Trim(P_PID) + '.XML'
     C                   When      P_ReqType = '03'
     C                   Eval      W1RpyFile = '/BnkHK/PWCHGRLY' +
     C                                         %Trim(P_PID) + '.XML'
     C                   When      P_ReqType = '04'
     C                   Eval      W1RpyFile = '/BnkHK/CONTESTRLY' +
     C                                         %Trim(P_PID) + '.XML'
06634C                   When      P_ReqType = '05'
06634C                   Eval      W1RpyFile = '/BnkHK/BALENQRLY' +
06634C                                         %Trim(P_PID) + '.XML'
     C                   EndSl
      *
      * Setting of URL Name
     C                   Eval      W1URL = 'https://' + %Trim(P_GMIP) +
     C                                     '/fts/FtsE2bGateway.do'
      *
      * Calling API to send Bank Request
     C                   Exsr      @SndXMLReq
      *
     C                   EndSr
      *
      *===============================================================*
      * @SndXmlReq - Send XML Request
      *===============================================================*
     C     @SndXmlReq    BegSr
      *
      * CCSID 1208 = UTF-8
     C                   Callp     http_setCCSIDs(1208: 0)
      *
      * content-type must specify 'application/xml; charset=utf-8'
     C                   Eval      rc = http_url_post(
     C                                  W1URL
     C                                : %addr(W1PostData) + 2
     C                                : %len(W1PostData)
     C                                : W1RpyFile
     C                                : HTTP_TIMEOUT
     C                                : HTTP_USERAGENT
     C                                : CONTENT_TYPE)
      *
     C                   if        rc <> 1
07427C                   Eval      httpmsg = http_error
     C                   ExSr      @ClrDump
     C     '0003'        Dump
     C                   Eval      W1RtnCde = 1
     C                   EndIf
      *
     C     $XSndXmlReq   Tag
     C                   EndSr
      *
      **************************************************************************
      * Clear Dump for Variable
      **************************************************************************
     C     @ClrDump      BegSr

     C                   Eval      O_PlainText = *Blank
     C                   Eval      W1PostData  = *Blank

     C                   EndSr

      /define ERRNO_LOAD_PROCEDURE
      /copy QCPYSRC,errno_h
