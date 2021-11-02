      *===============================================================*
      * Program name: SMSSTSR                                         *
      * Purpose.....: Sending Concatenated SMS(Status Checking)       *
      * Web Ref.....: http://www.scottklement.com/httpapi/            *
      *               HANDLE BIG-5, Chg in CONFIG_H for CCSID         *
      *               AS400 EBCDII 937                                *
      *               PC    ASCII  950  (DOS COMMAND, CHCP SHOWS 950  *
      * Setup SSL ..: need access auth for SSL                        *
      *               QIBM/USERDATA/ICSS/CERT/SERVER/DEFAULT.KDB      *
      *               And also see README in LIBHTTP/QRPGLESRC        *
      * Creation....:                                                 *
      * Create this Program with the following Commands:              *
      * - CrtRpgMod command                                           *
      *   CrtPgm PGM(ObjLib/SMSSTSR) BNDDIR(HTTPAPI) ACTGRP(*CALLER)  *
      *                                                               *
      * Desc........: Data Send out in HTTP protocol, get from        *
      *               Com Trace,                                      *
      *               GET /app/servlet/nGenSendSM?acc=                *
      *               xxxxxxx&pwd=xxxxxxxx&msisdn=xxxx                *
      *               xxxx&suffix=0&req_sms_status=y&m                *
      *               sg=%7C*                                         *
      * Indicators:                                                   *
      *     99  -  *On : Fatal Error, Exit                            *
      * Modification:                                                 *
      * Date       Name       Pre  Ver  Mod#  Remarks                 *
      * ---------- ---------- --- ----- ----- ------------------------*
      * 2014/05/26 Alan       AC              New Development         *
      *===============================================================*
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H BndDir('LIBHTTP139/HTTPAPI')
     HDEBUG(*YES)
      *
       /include LIBHTTP139/QRPGLESRC,HTTPAPI_H
      *
     D CEETREC         PR
     D  cel_rc_mod                   10I 0 options(*omit)
     D  user_rc                      10I 0 options(*omit)
      *
     D APP_ID          C                   CONST('SCK_HTTPAPI_EXAMPLE3')
     D rc              s             10I 0
     D msg             s             52A
     D URL             s            500A
     D result          s             34A
      *
      * Input Parameter
     D P_MsgID         S             11P 0
     D P_SendMode      S              1A
      *
      * Output Parameter
     D R_RtnCde        S              2P 0
     D R_MsgSts        S             10A
     D R_ChkTme        S             10A
      *
      * For IFS
     D readfile        PR            50A
     D   path                        34A

     D w1TmeStm        S               Z
     D w1TmeStmC       S             26A
     D w1FilNam        S             34A
      *
     Dw1Cnt            S              5  0
      *
     Dw1Cmd            S            200A
     Dw1CmdLen         S             15P 5
      *
     D w1API           S             10A
     D w1SMSAcc        S             10A
     D w1SMSpwd        S             20A
     D w1SMSReturn     S             50A
      *
     D w1Pos           S              2P 0
     D w1Dig@Neg       C                   '-0123456789'
     D w1Digits        C                   '0123456789'
     D w1Index         S                   Like(w1Cnt)
     D w1IsNum         S              1A
     D w1MsgID         S             11A
      *
     C     *Entry        Plist
     C                   Parm                    P_MsgID
     C                   Parm                    P_SendMode
      *
     C                   Parm                    R_RtnCde
     C                   Parm                    R_MsgSts
     C                   Parm                    R_ChkTme
      * turn on debug
     C**                 CallP     http_debug(*ON :'/home/alan/smssts'
      *
     C                   ExSr      @Init
     C   99              Goto      $End

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
      * definition named 'SCK_98006143EXAMPLE3'. If it finds it, it'll
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
     C                   If        R_RtnCde =  0
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
      *
      * HTTP_SetCCSIDs(remote:local), local = 0 means job/default
      * Set CCSID, Returns 0 if successful, -1 otherwise
      *
     C                   ExSr      @Sending
     C                   Endif
      *
     C     $End          Tag
      *
     c                   eval      *inlr = *on
     C                   return
      *========================*
      * *Sending               *
      *========================*
     C     @Sending      BegSr
     C                   ExSr      @SendExc
     C                   EndSr
      *======================================*
      * *SendExc - Sending Execution Process *
      *======================================*
     C     @SendExc      BegSr
     C                   ExSr      @PrepFilNam
     C                   Eval      result = w1FilNam
      *
     C                   Eval      w1MsgID = %EditC(P_MsgID:'3')
      * Setting for URL
      * Using SmartTone HTTP SMS Specification Req B003
      *
      * detail see HTTPAPI_H
      * HTTP_setCCSIDs(Remote POST data CCSID : Local POST data CCSID:
      *                Remote Protocol data CCSID  : Local Protocol data CCSID)
      *   HTTP_ASCII = 950, HTTP_EBCDIC = 937,
     C                   Eval      rc = HTTP_setCCSIDs( 950 : 937 : 950 : 937)
     C                   Eval      URL = 'https://httpsmsproxy.smartone.com'
     C                                  + %TRIM(w1API)
     C                                  + '/servlet/nGetmsgStatus?'
     C                                  + 'acc=' + %Trim(w1SMSAcc)
     C                                  + '&pwd=' + %Trim(w1SMSpwd)
     C                                  + '&msgId=' + %Trim(w1MsgID)
     C* optional with parameter XML
     C**                                + '[&xmlResp=n]'
     C
      * If connection error found, retry up to 3 times in every sec.
     C                   Eval      w1Cnt = 1
     C     $loop         Tag
      *
     C                   eval      rc = http_url_get(
     C                                  URL :result :10)
     C                   If        rc <> 1
     C                   Eval      w1SMSReturn  = readfile(result)
      *-1 - DB Maintenance
      * 1 - Missing Paramter
      * 2 - IP not allowed
      * 3 - invalid msgId or message is archived
     C     '0001'        Dump
     C                   If        w1Cnt >= 3
     C                   eval      msg = http_error
     C     '0002'        Dump
      * Set Return Code with 2 (Connection Error) as an error.
     C                   Eval      R_RtnCde = 2
     C                   Eval      *In99 = *On
     c                   Goto      $E_SendExc
     c                   endif
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
     C                   eval      w1SMSReturn  = readfile(result)
      * Scan x'25' - LF
     C                   Eval      w1Pos = %scan(x'25': w1SMSReturn)
      *
     C                   If        w1Pos = 0 or w1Pos = 1
     C                   Eval      R_RtnCde = 1
     C                   Eval      *In99 = *On
     C     '0003'        Dump
     C                   GoTo      $E_SendExc
     C                   EndIf
      * If any numeric is returned, it is an error
      * Check 1st char with '-0123456789'
     C                   Eval      w1IsNum = %Subst(w1SMSReturn:1:1)
      * Only '-' with LF return => error
     C                   If        (w1Pos = 2 and w1IsNum = '-')
     C                   Eval      R_RtnCde = 1
     C                   Eval      *In99 = *On
     C     '0004'        Dump
     c                   Goto      $E_SendExc
     C                   EndIf
      * If digits found, => error
     C     w1Dig@Neg     Check     w1IsNum                                90
     C                   If        *In90 = *Off
     C                   Eval      *In99 = *On
     C     '0005'        Dump
     C                   Eval      R_RtnCde = 1
     c                   Goto      $E_SendExc
     C                   EndIf
      *
     C                   If        R_RtnCde = 0
      * Check the rest char with  '0123456789'
     C                   If        w1Pos > 2
     C                   Eval      w1Cnt = w1Pos - 1
     C     2             Do        w1Cnt         w1Index
     C                   Eval      w1IsNum = %Subst(w1SMSReturn:w1Index:1)
      * Check 0 to 9, if not found, set on *In90
      * Handl -1, 0 .1, 2...
      * If w1IsNum contains value NOT in w1Digits, turn on 90
     C     W1Digits      Check     w1IsNum                                90
      * ie In90 *off => error
     C                   If        *In90 = *Off
     C                   Eval      *In99 = *On
     C     '0006'        Dump
     C                   Eval      R_RtnCde = 1
     C                   Leave
     C                   EndIf
     C                   EndDo
     C                   EndIf
     C                   EndIf
      *
     C                   EndIf
      *
     C                   If        R_RtnCde = 0
      * If the length before line feed > 10, it is defined as error
     C                   If        ((w1Pos - 1) < 1)
     C                             or ((w1Pos - 1) > 10)
     C                   Eval      *In99 = *On
     C     '0007'        Dump
     C                   Eval      R_RtnCde = 1
     C                   EndIf
     C                   EndIf
      *
     C                   If        R_RtnCde = 0
      * Message Status (char(10)): SENT, DELIVRD, EXPIRED, DELETED,...
     C                   Eval      R_MsgSts = %SubSt(w1SMSReturn:1:w1Pos-1)
      * Status Timestamp format: YYMMDDHHMI
     C                   Eval      R_ChkTme = %Subst(w1SMSReturn:w1Pos+1:10)
     C                   EndIf
      *
     C     $E_SendExc    Tag
     C                   EndSr
      *
      *=============*
      * @PrepFilNam *
      *=============*
     C     @PrepFilNam   BegSr
      *
     C/EXEC SQL
     C+ SET :w1TmeStm = CURRENT_TIMESTAMP
     C/END-EXEC
      *
     C                   Move      w1TmeStm      w1TmeStmC
     C                   Eval      w1FilNam = '/sms/get_sts/sms'
     C                                      + %Subst(w1TmeStmC:3:2)
     C                                      + %Subst(w1TmeStmC:6:2)
     C                                      + %Subst(w1TmeStmC:9:2)
     C                                      + %Subst(w1TmeStmC:12:2)
     C                                      + %Subst(w1TmeStmC:15:2)
     C                                      + %Subst(w1TmeStmC:18:2)
     C                                      + %Subst(w1TmeStmC:21:6)
     C                   EndSr
      *========================*
      * @Init                  *
      *========================*
     C     @Init         BegSr
      *
     C                   Eval      R_RtnCde = 0
     C                   Eval      R_MsgSts = *Blank
     C                   Eval      R_ChkTme = *Blank
      *
      * Setting for defined values
      *
     C                   Eval      w1SMSAcc = 'xxxxxxx'
     C                   Eval      w1SMSpwd = 'xxxxxxx'
     C                   Eval      w1API = '/appprod'
      *
     C     $E_init       Tag
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
     D   path                        34A

      /include QCpySrc,IFSIO_H
      *
     D fd              S             10I 0
     D flags           S             10U 0
     D*rddata          S             10A
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
