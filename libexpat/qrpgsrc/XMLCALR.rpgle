      *====================================================================*
      * Program name: XMLCALR                                              *
      * Purpose.....: CISCO Web Dialer - Make Call and End Call            *
      * Description :                                                      *
      *  - Calls SOAP Web service w/HTTPAPI.                               *
      *  - the SOAP Web is designed to the CISCO Web Dialer Web service    *
      *   To Compile (requires V5R1 or above):                             *
      *     CRTBNDRPG PGM(&PgmID) SRCFILE(*CURLIB/QRPGSRC)                 *
      *   Input Parameter:                                                 *
      *               Function  ('1'-Make Call, '2'-End Call)   P_Fn       *
      *               User_ID in PABX                           P_User     *
      *               Password for User_ID                      P_PW       *
      *               Phone # to make                           P_Phone    *
      *   Return Parameter:                                                *
      *               Response Code                             R_RespCode *
      *                                                                    *
      *  Resp Code  Description                                            *
      *  ---------  ---------------------------------------------------    *
      *  0          Success                                                *
      *  1          Call failure error                                     *
      *  2          Authentication error                                   *
      *  3          No authentication proxy rights                         *
      *  4          Directory error                                        *
      *  5          No device is configured for the user, or missing       *
      *              parameters exist in the request.                      *
      *  6          Service temporarily unavailable                        *
      *  7          Destination cannot be reached.                         *
      *  8          Service error                                          *
      *  9          Service overloaded                                     *
      *                                                                    *
      * Indicators:                                                        *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2016/01/11 Alan                       New Development              *
      *====================================================================*
     H Debug(*Yes)
     H DFTACTGRP(*NO) BNDDIR('HTTPAPI':'QC2LE')

     D XMLCALR         PR                  ExtPgm('XMLCALR')
     D   P_Fn                         1A   const
     D   P_User                       5A   const
     D   P_Pw                        10A   const
     D   P_Phone                     20A   const
     D   R_RespCode                   1A
     D XMLCALR         PI
     D   P_Fn                         1A   const
     D   P_User                       5A   const
     D   P_Pw                        10A   const
     D   P_Phone                     20A   const
     D   R_RespCode                   1A

      /copy QCPYSRC,httpapi_h

     D Incoming        PR
     D   RespDesc                    30A
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D w1SOAP          s          32767A   varying
     D w1SOAPHeader    s           1024A   varying
     D w1SOAPFooter    s           1024A   varying
     D w1SOAPOpr       s           1024A   varying
     D w1rc            s             10I 0
     D w2rc            s             10I 0
     D w1RespDesc      S             30A
     D a1Desc          S             30A   DIM(10) CTDATA PERRCD(1)
     D w1Index         S              1P 0
     D w1TmeStm        S               Z
     D w1TmeStmC       S             26A
     D w1FileName      S            500A

      * Initial System
     C                   ExSr      @InzSys
      * Initial Setting
     C                   Eval      R_RespCode = *Blank
      * Sending Execution
     C                   ExSr      @ConnExePro
      *
     C                   Eval      *inlr = *on
      *
      * ===================================================================
      * Connection Execution Process                                      *
      * ===================================================================
     C     @ConnExePro   BegSr
      *
     C                   Select
      * Make Call
     C                   when      P_Fn = '1'
     C                   Eval      w1SOAP = %trim(w1SOAPHeader)
     C                             +'  <urn:makeCallSoap soapenv:encodingStyle='
     C                             +'      '
     C                             +'"http://schemas.xmlsoap.org/soap/encoding/'
     C                             +'">'
     C                             +'    <cred xsi:type="urn:Credential">'
     C                             +'     '
     C                             +'<userID xsi:type="xsd:string">'
     C                             + %Trim(P_User) + '</userID>'
     C                             +'      <password xsi:type="xsd:string">'
     C                             + %Trim(P_PW)+'</password>'
     C                             +'    </cred>'
     C                             +'    <dest xsi:type="xsd:string">8029'
     C                             + %Trim(P_Phone) + '</dest>'
     C                             +'    <prof xsi:type="urn:UserProfile">'
     C                             +'      <user xsi:type="xsd:string">'
     C                             + %Trim(P_User) + '</user>'
     C                             +'      <deviceName xsi:type="xsd:string">'
     C                             + %Trim(P_User)+'</deviceName>'
     C                             +'      '
     C                             +'<lineNumber xsi:type="xsd:string">'
     C                             +'1</lineNumber>'
     C                             +'      '
     C                             +'<supportEM xsi:type="xsd:boolean">'
     C                             +'true</supportEM>'
     C                             +'      '
     C                             +'<locale xsi:type="xsd:string">'
     C                             +'English_United_States</locale>'
     C                             +'    </prof>'
     C                             +'  </urn:makeCallSoap>'
     C                             + %trim(w1SOAPFooter)
      *
     C                   ExSr      @Common
      * End Call
     C                   when      P_Fn = '2'
     C                   Eval      w1SOAP = %trim(w1SOAPHeader)
     C                             +'  <urn:endCallSoap soapenv:encodingStyle='
     C                             +'      '
     C                             +'"http://schemas.xmlsoap.org/soap'
     C                             +'/encoding/">'
     C                             +'    <cred xsi:type="urn:Credential">'
     C                             +'      '
     C                             +'<userID xsi:type="xsd:string">'
     C                             + %Trim(P_User) + '</userID>'
     C                             +'      <password xsi:type="xsd:string">'
     C                             + %Trim(P_PW)+'</password>'
     C                             +'    </cred>'
     C                             +'    <prof xsi:type="urn:UserProfile">'
     C                             +'      <user xsi:type="xsd:string">'
     C                             + %Trim(P_User) + '</user>'
     C                             +'      <deviceName xsi:type="xsd:string">'
     C                             + %Trim(P_User)+'</deviceName>'
     C                             +'      '
     C                             +'<lineNumber xsi:type="xsd:string">'
     C                             +'1</lineNumber>'
     C                             +'      '
     C                             +'<supportEM xsi:type="xsd:boolean">'
     C                             +'true</supportEM>'
     C                             +'      '
     C                             +'<locale xsi:type="xsd:string">'
     C                             +'English_United_States</locale>'
     C                             +'    </prof>'
     C                             +'  </urn:endCallSoap>'
     C                             + %trim(w1SOAPFooter)
     C
     C                   ExSr      @Common
      *
     C                   EndSl
      *
     C                   EndSr

      * ===================================================================
      * Common coding                                                     =
      * ===================================================================
     C     @Common       BegSr
     C                   Eval       w1rc = http_url_post_xml(
     C                              'https://PABX.CISCO/webdialer/services'
     C                              + '/WebdialerSoapService'
     C                              : %addr(w1SOAP) + 2
     C                              : %len(w1SOAP)
     C                              : *NULL
     C                              : %paddr(Incoming)
     C                              : %addr(w1RespDesc)
     C                              : HTTP_TIMEOUT
     C                              : HTTP_USERAGENT
     C                              : 'text/xml'
     C                              : 'https://PABX.CISCO/webdialer/services'
     C                              + '/WebdialerSoapService')
      *
     C                   if        (w1rc <> 1)
     C     '0001'        Dump
     C                   Eval      R_RespCode = '1'
     C                   else
     C                   Eval      w1Index = %Lookup(w1RespDesc:a1Desc)
     C                   If        w1Index > 0
     C                   Eval      R_RespCode = %char(w1Index - 1)
     C                   Else
     C     '0002'        Dump
     C                   Eval      R_RespCode = '1'
     C                   Endif
     C                   Endif
      *
     C                   EndSr
      * ===================================================================
      * Initial System (not in Spec)                                      =
      * ===================================================================
     C     @InzSys       BegSr
      *
      * Note:  http_XmlStripCRLF(*ON/*OFF) controls whether or not
      *        the XML parser removes CR and LF characters from the
      *        Xml data that's passed to your 'Incoming' procedure.
     C                   CallP     http_XmlStripCRLF(*ON)
      *
     C                   Eval      w1SOAPHeader = '<soapenv:Envelope'
     C                             +'    '
     C                             +'xmlns:xsi="http://www.w3.org'
     C                             +'/2001/XMLSchema-instance"'
     C                             +'    '
     C                             +'xmlns:xsd="http://www.w3.org'
     C                             +'/2001/XMLSchema"'
     C                             +'    '
     C                             +'xmlns:soapenv="http://schemas.xmlsoap.org'
     C                             +'/soap/envelope/"'
     C                             +'     xmlns:urn="urn:WebdialerSoap">'
     C                             +'<soapenv:Header/>'
     C                             +'<soapenv:Body>'
      *
     C                   Eval      w1SOAPFooter = '</soapenv:Body>'
     C                             +'</soapenv:Envelope>'
      * Note:  http_debug(*ON/*OFF) can be used to turn debugging
      *        on and off.  When debugging is turned on, diagnostic
      *        info is written to an IFS file named
      *        /tmp/httpapi_debug.txt
     C                   Time                    w1TmeStm
     C                   Move      w1TmeStm      w1TmeStmC
     C                   Eval      W1FileName  = %Subst(w1TmeStmC:3:2) +
     C                             %Subst(w1TmeStmC:6:2) +
     C                             %Subst(w1TmeStmC:9:2) +
     C                             %Subst(w1TmeStmC:12:2) +
     C                             %Subst(w1TmeStmC:15:2) +
     C                             %Subst(w1TmeStmC:18:2) +
     C                             %Subst(w1TmeStmC:21:6)
      * Just turn off the debug, if case want to debug, just turn it on
     C                   CallP     http_debug(*OFF:w1FileName)
      *
     C                   EndSr
      *==================================================================*
      * Phototype Incoming                                               *
      *==================================================================*
     P Incoming        B
     D Incoming        PI
     D   RespDesc                    30A
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
      *
     C                   If        (name = 'responseDescription')
     C                   Eval      RespDesc = %trim(value)
     C                   If        (RespDesc = *Blank)
     C                   Eval      RespDesc = 'Call Failure Error'
     C                   EndIf
     C                   EndIf
      *
     P                 E
** CTDATA a1Desc
Success
Call Failure Error
User Authentication Error
No Authentication Proxy Rights
Directory Error
Missing parameters in the requ
Service Temporarily Unavailabl
Destination not reachable
Service Error
Service Overloaded
