      *====================================================================*
      * Program name: MMSSTSR                                              *
      * Purpose.....: Get MMS Sending Status                               *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2020/05/21 Alan       AC              New Development              *
      *====================================================================*
     H Debug(*Yes)
     H DFTACTGRP(*NO) BNDDIR('LIBHTTP139/HTTPAPI':'QC2LE')
     FPHMMSF    IF   E             Disk
      *
      * Must have library : LIBHTTP139 at top during compile
      *
      /copy LIBHTTP139/qrpglesrc,httpapi_h
      /copy qcpysrc,ifsio_h

     D CRLF            c                   x'0d25'

      * Calling parameter
     D R_RtnCde        S              2P 0
     D R_Status        S             10A

      * Working Parameter
     D w1PostData      s            200A   varying
     D w1rc            s             10I 0
     D w1TmeStm        S               Z
     D w1TmeStmC       S             26A
     D w1FileName      S            500A
     D w1ResultFile    S            100A
     D w1Result        S            200A
     D msg             s             50A
     D w1ContentType   S            512A
      *
      * File Descriptor
     D w1FD            S             10I 0
     D len             s             10i 0
      *
     D w1Size          s             10i 0
     D line            s            100a
     D data            s           2740A
      *
     D ReportError     PR
     D I_RSTID         S             40A
      *
      * HTTP Header (Respond), tools HTTP_HEADER, max 256A
      *
     C     *Entry        PList
     C                   Parm                    I_RSTID
     C                   Parm                    R_Status
     C                   Parm                    R_RtnCde
      *
      * Initial System
     C                   ExSr      @InzSys
      *
     C                   Read      PHMMSFR                                98
     C                   If        *In98
     C                   Eval      R_RtnCde = 1
     C                   Goto      $Exit
     C     '0001'        Dump
     C                   EndIf
      *
      * Sending Execution
     C                   ExSr      @ConnExePro
      *
     C     $Exit         Tag
     C                   Eval      *inlr = *on
      * ===================================================================
      * Connection Execution Process                                      *
      * ===================================================================
     C     @ConnExePro   BegSr
      *
      * Post MMS Message ID and Login info. in HTTP Header
     C                   Eval      w1ContentType = 'application/smil' + CRLF +
     C                               'msg_id: ' + %trim(I_RSTID) + CRLF +
     C                               'MM7_username: ' + %trim(MMSUSR) + CRLF +
     C                               'MM7_password: ' + %trim(MMSPASS)
      *
      *  Post nothing in HTTP body
     C                   Eval      w1PostData = *Blank
      *
     C                   Eval       w1rc = http_url_post(
     C                              %trim(MMSURL)
     C                              + '/mms_status'
     C                              : %addr(w1PostData) + 2
     C                              : %len(w1PostData)
     C                              : w1ResultFile
     C                              : HTTP_TIMEOUT
     C                              : HTTP_USERAGENT
     C                              : w1ContentType)
      *
     C                   if        w1rc <> 1
     C                   Eval      msg = http_error
     C                   Eval      R_RtnCde = 1
     C     '0002'        Dump
     C                   Endif
      *
     C                   Eval      w1fd = open(%trim(w1ResultFile)
     C                                    : O_RDONLY + O_TEXTDATA)
      * Read file
     C                   If        w1fd < 0
     C                   Eval      R_RtnCde = 1
     C     '0003'        Dump
     C                   EndIf
      *
     C                   CallP     read(w1fd: %addr(w1Result):
     C                                          %size(w1Result))
     C
     C                   If        %scan('Delivered': w1Result) > 0
     C                   Eval      R_Status = 'Delivered'
     C                   Else
     C                   If        %scan('NotFound': w1Result) > 0
     C                   Eval      R_Status = 'NotFound'
     C                   Else
     C                   If        %scan('Fail': w1Result) > 0
     C                   Eval      R_Status = 'Fail'
     C                   Else
     C                   If        %scan('Pending': w1Result) > 0
     C                   Eval      R_Status = 'Pending'
     C                   Endif
     C                   Endif
     C                   Endif
     C                   Endif
      *
     C                   CallP     close(w1fd)
      *
     C     $ConnExePro_E Tag
     C                   EndSr
      *
      * ===================================================================
      * Initial System (not in Spec)                                      =
      * ===================================================================
     C     @InzSys       BegSr
      *
     C                   Eval      R_Status = *Blank
     C                   Eval      R_RtnCde = 0
      *
      * Note:  http_debug(*ON/*OFF) can be used to turn debugging
      *        on and off.  When debugging is turned on, diagnostic
      *        info is written to an IFS file named
      *        /tmp/httpapi_debug.txt
      *
     C                   Time                    w1TmeStm
     C                   Move      w1TmeStm      w1TmeStmC
     C                   Eval      W1FileName  = '/mms/mms_rsp' +
     C                             %Subst(w1TmeStmC:3:2) +
     C                             %Subst(w1TmeStmC:6:2) +
     C                             %Subst(w1TmeStmC:9:2) +
     C                             %Subst(w1TmeStmC:12:2) +
     C                             %Subst(w1TmeStmC:15:2) +
     C                             %Subst(w1TmeStmC:18:2) +
     C                             %Subst(w1TmeStmC:21:6) + '.txt'
      *
07819C                   Eval      w1ResultFile = '/mms/mms_rst' +
07819C                             %Subst(w1TmeStmC:3:2) +
07819C                             %Subst(w1TmeStmC:6:2) +
07819C                             %Subst(w1TmeStmC:9:2) +
07819C                             %Subst(w1TmeStmC:12:2) +
07819C                             %Subst(w1TmeStmC:15:2) +
07819C                             %Subst(w1TmeStmC:18:2) +
07819C                             %Subst(w1TmeStmC:21:6) + '.txt'
      *
      * Just turn off the debug, if case want to debug, just turn it on
     C                   CallP     http_debug(*ON:w1FileName)
      *
     C     $E_InzSys     Tag
     C                   EndSr
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

