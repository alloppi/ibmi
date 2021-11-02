      *===============================================================*
      * Program name: SNDSMSR                                         *
      * Purpose.....: Sending Concatenated SMS(Request)               *
      * Web.........: http://www.scottklement.com/httpapi/            *
      *               HANDLE BIG-5, Chg in CONFIG_H for CCSID         *
      *               AS400 EBCDII 937                                *
      *               PC    ASCII  950  (DOS COMMAND, CHCP SHOWS 950  *
      * Setup SSL ..: need access auth for SSL                        *
      *               QIBM/USERDATA/ICSS/CERT/SERVER/DEFAULT.KDB      *
      *               And also see README in LIBHTTP/QRPGLESRC        *
      * Creation....:                                                 *
      * Create this Program with the following Commands:              *
      * - CrtRpgMod command (option 15 in PDM)                        *
      *   CrtPgm PGM(ObjLib/SNDSMSR) BNDDIR(ObjLib/HTTPAPI)           *
      *          ACTGRP(*CALLER) (Option C9 in PDM)                   *
      * - Don't forget to add host table address                      *
      * Desc........: Data Send out in HTTP protocol, get from        *
      *               Com Trace,                                      *
      *               GET /app/servlet/nGenSendSM?acc=                *
      *               xxxxxxx&pwd=xxxxxxxx&msisdn=0123                *
      *               4567&suffix=0&req_sms_status=y&m                *
      *               sg=%7C*                                         *
      * For Smartone: Eng - 306 Char (153 x 2 SMS message)            *
      *               Chi - 134 Double Char (67 x 2 SMS message)      *
      * Indicators:                                                   *
      *     99  -  *On : Fatal Error, Exit                            *
      * Modification:                                                 *
      * Date       Name       Pre  Ver  Mod#  Remarks                 *
      * ---------- ---------- --- ----- ----- ------------------------*
      * 2014/05/26 Alan       AC              New Developement        *
      *===============================================================*
      * Change H-Spec, remove record in CMPALLF
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H BndDir('LIBHTTP139/HTTPAPI')
     HDEBUG(*YES)
      *
     FPHSMSCF01 IF   E           K Disk
      /copy LIBHTTP139/QRPGLESRC,HTTPAPI_H
      * Prototype

     D cmd             pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D CEETREC         PR
     D  cel_rc_mod                   10I 0 options(*omit)
     D  user_rc                      10I 0 options(*omit)
      *
     D APP_ID          C                   CONST('SCK_HTTPAPI_EXAMPLE3')
     D rc              s             10I 0
     D msg             s             52A
     D URL             s            750A
     D result          s             26A
      * Input Parameter
     D P_ConTyp        S              1A
     D P_SMSCID        S                   Like(SMSCID)
     D P_Tel           s              8A
     D P_InMsg         s            320A
     D P_SendMode      S              1A
      * Output Parameter
     D R_RtnCde        S              2P 0
     D R_MsgID         s             11P 0
      * For IFS
     D readfile        PR            50A
     D   path                        26A

     D w1TmeStm        S               Z
     D w1TmeStmC       S             26A
     D w1FilNam        S             26A
      *
     Dw1Tail           S              5  0
     Dw1Cnt            S              5  0
     Dw1Position       S              5  0
      *
     D w1SndMsg        s            600A
     D w1InString      S            320A
     D w1with20        S                   Like(w1SndMsg)
     D W1SMSReturn     s             50A
      * For QCMD
     D w1Cmd           S            200A
     D w1CmdLen        S             15P 5
     D w1API           S             10A
      *
     D w1Tel           s              8A
     D w1SMSAcc        S             10A
     D w1SMSpwd        S             20A
      *
     D w1Pos           S              2P 0
     D w1Dig@Neg       C                   '-0123456789'
     D w1Digits        C                   '0123456789'
     D w1Index         S                   Like(w1Cnt)
     D w1IsNum         S              1A
     D w1MsgID         S             11A
      *
     C     *Entry        Plist
     C                   Parm                    P_ConTyp
     C                   Parm                    P_SMSCID
     C                   Parm                    P_InMsg
     C                   Parm                    P_Tel
     C                   Parm                    P_SendMode
      *
     C                   Parm                    R_RtnCde
     C                   Parm                    R_MsgID
      * turn on debug
     C**                 CallP     http_debug(*ON)
      *
     C                   ExSr      @Init
     C   99              Goto      $End
      *
      * Before you can use the https (http over SSL) stuff, you
      *  must call https_init() to initialize the SSL APIs.
      *
      * You can pass an application ID as the first parameter
      * if you want full control over the SSL configuration of
      * that application.  This application ID will match an
      * application definition in the digital certificate
      * manager.  For example:
      *
      *                  eval      rc = https_init( APP_ID )
      *
      * HTTPAPI will ask the digital certificate manager for an application
      * definition named 'SCK_HTTPAPI_EXAMPLE3'. If it finds it, it'll
      * use the SSL settings that you've defined for that application.
      *
      * If not, it'll return an HTTP_NOTREG error, and you can use the
      * http_dcm_reg() API from HTTPAPI to install a new application
      * definition (see the RegisterMe subroutine) or you can register
      * the application manually from the Digital Certificate Manager.
      *
      * If you want to use client certificates, or configure which
      * certificate authorities your program trusts, you should always
      * register an application ID, and configure the settings manually
      * in the Digital Certificate Manager.  (Most banks require this!)
      *
      * If you don't need/want to set up individual settings for the
      * application, you can pass *BLANKS for the application ID, and
      * HTTPAPI will use the default settings for a client application
      * in the *SYSTEM certificate store (as below)
      *
     c                   eval      rc = https_init(*BLANKS)

     c                   if        rc < 0
     c                   eval      msg = http_error(rc)
     c                   if        rc = HTTP_NOTREG
     c                   exsr      RegisterMe
     c                   return
     c                   else
     c                   dsply                   msg
     c                   return
     c                   endif
     c                   endif
      * HTTP_SetCCSIDs(remote:local), local = 0 means job/default
      * Set CCSID, Returns 0 if successful, -1 otherwise
      *
     C                   ExSr      @Sending
     C   99              Goto      $End
      *
     C                   If        R_RtnCde = 0
      * If w1MsgID = '12   ', R_MsgID = 00012
     C                   Eval      R_MsgId = %Dec(w1MsgID:11:0)
     C                   EndIf
      *
     C     $End          Tag
     c                   eval      *inlr = *on
     c                   return
      *========================*
      * @Init                  *
      *========================*
     C     @Init         BegSr
      *
     C                   Eval      R_RtnCde = 0
     C                   Eval      R_MsgID  = 0
      *
     C                   Eval      w1Tel  = P_Tel
      *
     C                   Eval      w1SMSAcc = 'xxxxxxx'
     C                   Eval      w1SMSpwd = 'xxxxxxx'
     C                   Eval      w1API = '/xxxxxxx'
      *
     C                   Select
     C                   When      P_ConTyp = '1'
     C     P_SMSCID      Chain     PHSMSCFR                           99
     C                   If        *In99 = *On
     C     '0002'        Dump
     C                   Eval      R_RtnCde = 1
     C                   Goto      $E_Init
     C                   ELse
     C                   Eval      w1InString = SMSCT
     C                   Endif
     C                   When      P_ConTyp = '2'
     C                   Eval      w1InString = P_InMsg
     C                   EndSl
      *
     C     $E_Init       Tag
     C                   EndSr
      *========================*
      * *Sending               *
      *========================*
     C     @Sending      BegSr
     C                   If        R_RtnCde = 0
     C                   ExSr      @SendExc
     C                   EndIf
     C                   EndSr
      *======================================*
      * *SendExc - Sending Execution Process *
      *======================================*
     C     @SendExc      BegSr
     C                   ExSr      @PrepFilNam
     C                   Eval      result = w1FilNam
      * Replace space with %20
     C                   ExSr      @HdlSpc
     C                   Eval      w1SndMsg = w1with20
      *
      * 我
      * ASCII                 A7 DA
      * File  EBCDIC          4F 5C
      * EBCDIC if CCSID 819   B5 FE
      *
      * Using SmartTone HTTP SMS Specification Req B001
      * detail see HTTPAPI_H
      * HTTP_setCCSIDs(Remote POST data CCSID : Local POST data CCSID:
      *                Remote Protocol data CCSID  : Local Protocol data CCSID)
      *   HTTP_ASCII = 950, HTTP_EBCDIC = 937,
     C                   Eval      rc = HTTP_setCCSIDs( 950 : 937 : 950 : 937)
     C                   Eval      URL = 'https://httpsmsproxy.smartone.com'
     C                                  + %TRIM(w1API)
     C                                  + '/servlet/nGenSendSM?'
     C                                  + 'acc=' + %Trim(w1SMSAcc)
     C                                  + '&pwd=' + %Trim(w1SMSpwd)
     C                                  + '&msisdn=' + %Trim(w1Tel)
     C                                  + '&suffix=0'
     C                                  + '&req_sms_status=y'
     C                                  + '&msg=' + %Trim(W1SndMsg)
     C* optional with parameter XML
     C**                                + '&[xmlResp=n]'
      *
     C* Retrieve an HTTP document: http_url_get(URL:FileName:Timeout:ModTime:ContentType)
     C* Detail in HTTPAPIR4
     C                   Eval      w1Cnt = 1
     C     $loop         Tag
     C                   eval      rc = http_url_get(
     C                                  URL :result :10)
      * If return error, try 3 times, wait 1 second each time
     C                   if        rc <> 1
     C                   eval      w1SMSReturn = readfile(result)
     C     '0003'        Dump
     C                   If        w1Cnt >= 3
      * Set msg value for debug purpose
     c                   eval      msg = http_error
     C                   Eval      *In99 = *On
     C     '0004'        Dump
     C                   Eval      R_RtnCde = 2
     C                   Goto      $E_SendExc
     C                   endif
      * Wait a second
     C                   Eval      w1Cmd   = 'DLYJOB DLY(1)'
     C                   Eval      w1CmdLen = %Len(%Trim(w1Cmd))
     C                   Call      'QCMDEXC'                            99
     C                   Parm                    w1Cmd
     C                   Parm                    w1CmdLen
     C                   Eval      w1Cnt = w1Cnt + 1
     c                   Goto      $Loop
     c                   endif
      * If Return Code EQ Initial Value, Checking for invalid returned value
     C                   If        R_RtnCde = 0
     C                   eval      w1SMSReturn = readfile(result)
      * Scan x'25' - LF
     C                   Eval      w1Pos = %scan(x'25': w1SMSReturn)
      * No LF or only LF return => Error
     C                   If        (w1Pos = 0 or w1Pos = 1)
     C                   Eval      R_RtnCde = 1
     C                   Eval      *In99 = *On
     C     '0005'        Dump
     C                   GoTo      $E_SendExc
     C                   EndIf
      * If any character is returned, it is an error
      * Check 1st char with '-0123456789'
     C                   Eval      w1IsNum = %Subst(w1SMSReturn:1:1)
      * Only '-' with LF return => error
     C                   If        (w1Pos = 2 and w1IsNum = '-')
     C                   Eval      R_RtnCde = 1
     C                   Eval      *In99 = *On
     C     '0006'        Dump
     C                   GoTo      $E_SendExc
     C                   EndIf
      * If not digits, => error
     C     w1Dig@Neg     Check     w1IsNum                              9999
     C                   If        *In99 = *On
     C     '0007'        Dump
     C                   Eval      R_RtnCde = 1
     C                   GoTo      $E_SendExc
     C                   EndIf
      * Check the rest char with  '0123456789'
     C                   If        w1Pos > 2
     C                   Eval      w1Cnt = w1Pos - 1
      * Start scan from 2nd poistion of w1SMSReturn
     C     2             Do        w1Cnt         w1Index
     C                   Eval      w1IsNum = %Subst(w1SMSReturn:w1Index:1)
      * Check '-' and 0 to 9, set on *In99 and set return code = 9
      * If w1IsNum contains value NOT in w1Dig@Neg, turn on 99
     C     w1Digits      Check     w1IsNum                              9999
     C                   If        *In99 = *On
     C     '0008'        Dump
     C                   Eval      R_RtnCde = 1
     C                   GoTo      $E_SendExc
     C                   EndIf
     C                   EndDo
     C                   Endif
      *
     C                   Endif
      *-1 - DB Maintenance
      * 1 - Missing Paramter
      * 2 - IP not allowed
      * 3 - invalid parameter value
      * 4 - send error (e.g. content exceeds SMS size. 306 for English, 134 for Big5 Chinese)
     C                   If        R_RtnCde = 0
     C                   Select
     C                   When        w1Pos = 2
     C                   If        '1' = %SubSt(w1SMSReturn:1:1)
     C                             or '2' = %SubSt(w1SMSReturn:1:1)
     C                             or '3' = %SubSt(w1SMSReturn:1:1)
     C                             or '4' = %SubSt(w1SMSReturn:1:1)
     C     '0010'        Dump
     C                   Eval      R_RtnCde = 1
     C                   EndIf
     C                   When        w1Pos = 3
     C                   If        '-1' = %SubSt(w1SMSReturn:1:2)
     C     '0011'        Dump
     C                   Eval      R_RtnCde = 1
     C                   EndIf
     C                   EndSl
     C                   EndIf
      * If the length before line feed > 11, it is defined as error
     C                   If        R_RtnCde = 0
     C                   If        ((w1Pos - 1) < 1)
     C                             or ((w1Pos - 1) > 11)
     C                   Eval      *In99 = *On
     C     '0009'        Dump
     C                   Eval      R_RtnCde = 1
     C                   EndIf
     C                   EndIf
      *
     C                   If        R_RtnCde = 0
     C                   Eval      w1MsgID  = %SubSt(w1SMSReturn:1:w1Pos-1)
     C                   EndIf
      *
     C     $E_SendExc    Tag
     C                   EndSr
      *===============================================*
      *    @HdlSpc ; Handle by replace space by '%20' *
      *===============================================*
     C     @HdlSpc       BegSr
     C                   Eval      w1with20    = %Trim(w1InString)
     C                   Eval      w1Tail  = %Len(%Trim(w1InString))
     C     $Loop_01      Tag
     C     ' '           Scan      w1with20      w1Position
     C                   If        w1Position = 0
     C                             or w1Position >= w1Tail
     C                   GoTo      $E_HdlSpc
     C                   EndIf
     C                   Eval      w1with20    = %subst(w1with20:1
     C                                                 :w1Position - 1)
     C                                        + '%20'
     C                                        + %subst(w1with20:w1Position+1
     C                                                 :w1Tail - w1Position)
      * As '%20' is inserted, shift tail 3 bytes
     C                   Eval      w1Tail = w1Tail + 2
     C                   GoTo      $Loop_01
      *
     C     $E_HdlSpc     Tag
     C                   Eval      w1InString = %Subst(w1with20:1:w1Tail)
     C                   EndSr
      *==============*
      *  @PrepFilNam *
      *==============*
     C     @PrepFilNam   BegSr
     C                   Time                    w1TmeStm
     C                   Move      w1TmeStm      w1TmeStmC
     C                   Eval      w1FilNam = '/sms/sms'
     C                                      + %Subst(w1TmeStmC:3:2)
     C                                      + %Subst(w1TmeStmC:6:2)
     C                                      + %Subst(w1TmeStmC:9:2)
     C                                      + %Subst(w1TmeStmC:12:2)
     C                                      + %Subst(w1TmeStmC:15:2)
     C                                      + %Subst(w1TmeStmC:18:2)
     C                                      + %Subst(w1TmeStmC:21:6)
     C                   EndSr
      *-------------------------------------------------------------
      * before we can do SSL, we must register ourself with the
      * AS/400's digital certificate manager.   This allows the
      * AS/400 admin to assign us certificates, tell us which
      * cert authorities to trust, etc.   This should only be
      * done the first time...
      *-------------------------------------------------------------
     CSR   RegisterMe    begsr

     c                   eval      rc=https_dcm_reg(APP_ID: *OFF)
     c                   if        rc < 0
     c                   eval      msg = http_error
     c                   dsply                   msg
     c                   leavesr
     c                   endif

     c                   eval      msg = 'This program has not yet been ' +
     c                             'registered with the'
     c     msg           dsply

     c                   eval      msg = 'Digital Certificate Manager.  I '+
     c                             'have registered it'
     c     msg           dsply

     c                   eval      msg = 'as '+ APP_ID + '.'
     c     msg           dsply

     c                   eval      msg = ' '
     c     msg           dsply

     c                   eval      msg = 'Please re-run this program'
     c     msg           dsply

     c                   eval      msg = ' '
     c     msg           dsply

     c                   eval      msg = 'press <ENTER> to continue'
     c                   dsply                   msg

      **
      ** Note that after registering, it's necessary to unload
      ** HTTPAPI from memory so that it is reactivated on the next
      ** call. You do that by ending the activation group with
      ** the CEETREC API.
      **
     c                   callp     CEETREC(*OMIT : *OMIT)

     csr                 endsr

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * This reads messaage from file
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P readfile        B
     D readfile        PI            50A
     D   path                        26A

      /copy QCpySrc,IFSIO_H
      *
     D fd              S             10I 0
     D flags           S             10U 0
     D rddata          S             50A
     D len             S             10I 0

     D LF              s              1A   inz(x'25')
     D CRLF            s              2A   inz(x'0d25')
     D wwPos           s              2P 0

      * Open IFS file with O_CCSID parameter and convert data to EBCDIC CCSID 37 automatically
     c                   eval      fd = open(%trim(path)
     c                                       :O_RDONLY + O_TEXTDATA + O_CCSID
     c                                       :S_IRUSR
     c                                       :37)
     c                   if        fd < 0
     c                   eval      msg = 'Open(): failed for reading'
     c                   dsply                   msg
     c                   else
     c                   eval      len = read(fd
     c                                       :%addr(rddata)
     c                                       :%size(rddata))
     c                   callp     close(fd)

     c                   eval      wwPos = %scan(CRLF: rddata)
     c                   if        wwPos > 0
     c                   eval      rddata = %subst(rddata: 1: wwPos-1)
     c                   endif

     c                   return                  rddata
     c                   endif
     P                 E
