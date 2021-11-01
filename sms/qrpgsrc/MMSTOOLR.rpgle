      *====================================================================*
      * Program name: MMSTOOLR                                             *
      * Purpose.....: Sending MMS Tool                                     *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2019/11/18 Alan       AC              New Development              *
      *====================================================================*
     H Debug(*Yes)
     H DFTACTGRP(*NO) BNDDIR('LIBHTTP139/HTTPAPI':'QC2LE':'BASE64')
     FPHMMSF    IF   E             Disk
      *
      * Must have library : LIBHTTP139 at top during compile
      *
      ** /copy QCPYSRC,httpapi_h
      /copy LIBHTTP139/qrpglesrc,httpapi_h
      /copy qcpysrc,base64_h
      /copy qcpysrc,Iconv_h
      /copy qcpysrc,ifsio_h

     D w1PostData      s         600000A   varying
     D w1MIMEHdr       S             90A
     D w1ContentType   S            512A
     D w1rc            s             10I 0
     D w1TmeStm        S               Z
     D w1TmeStmC       S             26A
     D w1FileName      S            500A
07819D w1FileNameR     S                   Like(w1FileName)
     D CRLF            c                   x'0d25'
     D msg             s             50A
     D w1File          S             50A   varying
     D att             s             10I 0
     D w1data          S         600000A
     D W1Pos           S              5  0
     D w1ToBase64      S           1000A
      *
      * File Descriptor
     D w1FD            S             10I 0
      *
      * For base64
     D encData         s                   like(w1data)
     D encLen          s             10i 0
     D len             s             10i 0
      *
     D w1Size          s             10i 0
      *
     D ReportError     PR
      *
     D readline        pr            10i 0
     D   fd                          10i 0 value
     D   text                          *   value
     D   maxlen                      10i 0 value
      *
     D P_CONTYP        S              1A
     D P_MMSCID        S              7A
     D P_FromStr       S             50A
     D P_ToStr         S             50A
     D P_Tel           S              8A
     D P_Language      S              1A
     D P_SubEng        S             90A                                        Subject ENG
     D P_SubUT8        S             90A                                        Subject UTF8
     D P_SubBG5        S             90A                                        Subject BIG5
     D P_File          S             40A
     D P_ContF         S             40A                                        Content File
     D P_BMTN          S              8A
     D R_RtnCde        S              2P 0
     D R_Result        S             50A
     D R_RspMsgID      S             40A
     D R_Content       s           1000A
      *
     D w1SmilF         S            100A
     D w1MMSType       S            100A
     D w1Subject       S            100A
     D w1Len           S             10i 0
      *
      * HTTP Header (Respond), tools HTTP_HEADER, max 256A
     D w1GetHeader     S            256A
      * Base 64
      *
     D I_Len           s             10u 0
     D O_Len           s             10u 0
     D O_Buffer        s           2000A
     D I_Input         s               *
     D O_output        s               *
     D O_Base64        S           2000A
     D w1encodelen     s             10u 0
      *
      * Parameters for PSXX76C
     D IsProd          S              1A
      *
     D w1Tel           S                   like(P_Tel)
     d source          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d target          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d toEBC           ds                  likeds(iconv_t)
     d toUTF           ds                  likeds(iconv_t)
      *
     C     *Entry        PList
     C                   Parm                    P_CONTYP
     C                   Parm                    P_MMSCID
     C                   Parm                    P_FromStr
     C                   Parm                    P_ToStr
     C                   Parm                    P_Tel
     C                   Parm                    P_Language
     C                   Parm                    P_SubEng                       Subject ENG
     C                   Parm                    P_SubUT8                       Subject UTF8
     C                   Parm                    P_SubBG5                       Subject BIG5
     C                   Parm                    P_File
     C                   Parm                    P_ContF                        Content
     C                   Parm                    P_BMTN
     C                   Parm                    R_RtnCde
     C                   Parm                    R_Result
     C                   Parm                    R_RspMsgID
     C                   Parm                    R_Content
      *
      * Initial System
     C                   ExSr      @InzSys
     C                   If        R_RtnCde <> 0
     C                   Goto      $Exit
     C                   EndIf
      *
     C                   Read      PHMMSFR                                98
      * Sending Execution
     C                   ExSr      @ConnExePro
      *
     C     $Exit         Tag
     C                   Eval      *inlr = *on
      *
      * ===================================================================
      * Connection Execution Process                                      *
      * ===================================================================
     C     @ConnExePro   BegSr
      *
      * Prepare http header, the file should be in x'0d25' instead of x'0A'
      *  CPYFRMSTMF FROMSTMF('/home/alan/mms/mms.txt') TOMBR('/QSYS.LIB/QTEMP.LIB/
      *  SAVE.FILE/SAVE.MBR') MBROPT(*REPLACE)
      *  CPYTOSTMF FROMMBR('/QSYS.LIB/QTEMP.LIB/SAVE.FILE/SAVE.MBR') TOSTMF('/home
      *  /alan/mms/mms.txt.crlf') STMFCCSID(*PCASCII)
      * or try
      *  CPYTOIMPF FROMFILE(QTEMP/SAVE) TOSTMF('/home/alan/mms/mms.txt.crlf')
      *   RCDDLM(*CRLF) STRDLM(*NONE)
      *
      * Language '1' - Chinese Big 5,  '2' - English, '3' - Chinese UTF8
     C                   Select
      *
      * Big-5
     C                   When      P_Language = '1'
     C                   Eval      w1MIMEHdr = 'multipart/related;'
     C                                + ' charset=big5;'
     C                                + ' boundary="----=_Part_61_130394'
     C                                + '12.1400489653107"'
      *
      * Convert the DB2 data to base64
     C                   Eval      w1ToBase64 = P_SubBG5
     C                   ExSr      @937ToUTF8B64
      *
      * Subject is in utf-8 even in Big5 content
     C                   Eval      w1Subject = 'Subject:=?utf-8?B?'
     C                             +  %subst(O_base64:1:w1encodelen)
     C                             + '?='
      * English
     C                   When      P_Language = '2'
     C                   Eval      w1MIMEHdr = 'multipart/related;'
     C                                + ' charset=us-ascii;'
     C                                + ' boundary="----=_Part_61_130394'
     C                                + '12.1400489653107"'
     C                   Eval      w1Subject = 'Subject: '
     C                                   + %Trim(P_SubEng)
      * UTF8
     C                   When      P_Language = '3'
     C                   Eval      w1MIMEHdr = 'multipart/related;'
     C                                + ' charset=utf-8;'
     C                                + ' boundary="----=_Part_61_130394'
     C                                + '12.1400489653107"'
      *
      *  Read from IFS-1208 UTF-8 format, convert to Base64, remove the first 5 control char
     C                   Eval      w1Data = *Blank
     C                   Eval      encdata = *Blank
     C                   eval      w1File = %TrimR('/mms/http_hdr_utf8.Subject')
     C                   ExSr      @ReadToBase64
     C                   Eval      w1Len = %Len(%Trim(encdata))
     C                   Eval      encdata = %subst(encdata:5:w1Len-5+1)
     C                   Eval      w1Subject = 'Subject:=?utf-8?B?'
     C                             +  %TrimR(encdata)
     C                             + '?='
      *
     C                   EndSl
      *
      * Read in smil file, and put it to the end of w1PostData
     C                   Eval      w1Data = *Blank
     C                   Eval      w1File = %TrimR(w1SmilF)
     C                   ExSr      @ReadIFS
     C                   Eval      w1PostData = %TrimR(w1PostData)
     C                             + %TrimR(w1data)
      *
      * Read in mp4 content type ONLY
     C                   Eval      w1Data = *Blank
     C                   Eval      w1File = %TrimR(w1MMSType)
     C                   ExSr      @ReadIFS
     C                   Eval      w1PostData = %TrimR(w1PostData)
     C                             + %TrimR(w1data)
      *
      * Read in Video and convert to Base64
     C                   Eval      w1Data = *Blank
     C                   Eval      encdata = *Blank
     C                   eval      w1File = %TrimR(P_File)
     C                   ExSr      @ReadToBase64
      *
      * Check return data size is GT field size that can hold
     C                   Eval      w1Size =  %size(w1data)
     C                   If        enclen  > w1Size
     C                   Eval      msg = 'w1Size =  %size(w1data)'
     C     '0001'        Dump
     C                   Goto      $ConnExePro_E
     C                   Endif
      *
      * Concatenate them all
     C                   Eval      w1PostData = %TrimR(w1PostData)
     C                             + CRLF
     C                             + CRLF + %TrimR(encdata)
     C                             + CRLF
      *
      * Read in text content type and data together
     C                   If        P_ContF <> *Blank
     C                   Eval      w1Data = *Blank
      * Language '1' - Chinese Big 5,  '2' - English, '3' - Chinese UTF8
      * File CCSID should be in 1252
     C                   Select
      * Big-5
     C                   When      P_Language = '1'
      * use utf8 header
     C                   Eval      w1File =
     C                              '/mms/mms.ct_utf8.header'
      * English
     C                   When      P_Language = '2'
     C                   Eval      w1File =
     C                              '/mms/mms.ct_engl.header'
     C                   When      P_Language = '3'
     C                   Eval      w1File =
     C                              '/mms/mms.ct_utf8.header'
     C                   EndSl
      * Read in IFS Text part Header
     C                   ExSr      @ReadIFS
     C                   Eval      w1PostData = %TrimR(w1PostData)
     C                             + %TrimR(w1data)
      *
      * All Content from IFS
     C                   Select
      * Big-5
     C                   When      P_Language = '1'
     C                   If        P_ContF <> *Blank
      * read from IFS text and replace Brach Telphone
     C                   Eval      w1File = %TrimR(P_ContF)
     C                   ExSr      @ReadIFSB5
      *
      * Return Big5 Content for log file
     C                   Eval      R_Content = w1data
      * Remove the CRLF in P_content before return to caller
      * the function %scanrpl show warning in SEU, but it is ok in Compiler
     C                   Eval      R_Content = %scanrpl(CRLF:' ': R_Content)
      * Convert the Big5 data to UTF8 then base64
     C                   Eval      w1ToBase64 = w1data
     C                   ExSr      @937ToUTF8B64
     C                   Eval      w1PostData = %TrimR(w1PostData)
     C                             +  %subst(O_base64:1:w1encodelen)
     C                   EndIf
     C
      * English
     C                   When      P_Language = '2'
      *                  Not done yet
      * UTF8
     C                   When      P_Language = '3'
      *                  Not done yet
     C                   EndSl
      * Add Ending
     C                   Eval      w1PostData = %TrimR(w1PostData)
     C                             + CRLF
     C                             + '------=_Part_61_13039412.1400489653107--'
     C                   Endif
      *
      * now us DB2, no CRLF at the end
     C                   Eval      w1ContentType = %Trim(w1MIMEHdr) + CRLF
     C                                           + %Trim(P_FromStr) + CRLF
     C                                           + %Trim(P_ToStr)
     C                                           + w1Tel + CRLF
     C                                           + %Trim(w1Subject)  +CRLF
     C                                           + %Trim(MMSID)      + CRLF
     C                                           + 'X-SS-Mms-DAPI-Username: '
     C                                           + %Trim(MMSUSR)     + CRLF
     C                                           + 'X-SS-Mms-DAPI-Password: '
     C                                           + %Trim(MMSPASS)
      *
      * http_setCCSIDs(toCCSID: fromCCSID)
      * Convert CCSID from 937 (Big-5) to 1208 (UTF-8)
     C                   If        P_Language = '1'
     C                   Callp     http_setCCSIDs(1208: 937)
     C                   EndIf
      *
     C                   Eval       w1rc = http_url_post(
     C                              %trim(MMSURL)
     C                              + '/submit_mms'
     C                              : %addr(w1PostData: *Data)
     C                              : %len(w1PostData)
07819C                              : %Trim(W1FileNameR)
     C                              : HTTP_TIMEOUT
     C                              : HTTP_USERAGENT
     C                              : w1ContentType)
     C                   Eval       w1GetHeader  =
     C                               http_header('X-SS-Mms-Message-Id')
     C                   Eval       R_RspMsgID  = %subst(w1GetHeader:1:40)
      *
     C                   Eval      msg = http_error
     C                   if        (w1rc <> 202)
     C                   Eval      R_RtnCde = 1
     C                   Endif
      *
     C     $ConnExePro_E Tag
     C                   If        msg <> *Blank
     C                   Eval      R_Result =    msg
     C                   Endif
      *
     C                   EndSr
      *
      * ===================================================================
      * Initial System (not in Spec)                                      =
      * ===================================================================
     C     @InzSys       BegSr
      *
      * Note:  http_debug(*ON/*OFF) can be used to turn debugging
      *        on and off.  When debugging is turned on, diagnostic
      *        info is written to an IFS file named
      *        /tmp/httpapi_debug.txt
     C                   Time                    w1TmeStm
     C                   Move      w1TmeStm      w1TmeStmC
     C                   Eval      W1FileName  = '/mms/mms' +
     C                             %Subst(w1TmeStmC:3:2) +
     C                             %Subst(w1TmeStmC:6:2) +
     C                             %Subst(w1TmeStmC:9:2) +
     C                             %Subst(w1TmeStmC:12:2) +
     C                             %Subst(w1TmeStmC:15:2) +
     C                             %Subst(w1TmeStmC:18:2) +
     C                             %Subst(w1TmeStmC:21:6) + '.txt'
      *
07819C                   Eval      W1FileNameR = '/mms/mms' +
07819C                             %Subst(w1TmeStmC:3:2) +
07819C                             %Subst(w1TmeStmC:6:2) +
07819C                             %Subst(w1TmeStmC:9:2) +
07819C                             %Subst(w1TmeStmC:12:2) +
07819C                             %Subst(w1TmeStmC:15:2) +
07819C                             %Subst(w1TmeStmC:18:2) +
07819C                             %Subst(w1TmeStmC:21:6) + '.dum'
      *
      * Just turn off the debug, if case want to debug, just turn it on
     C                   CallP     http_debug(*ON:w1FileName)
      *
     C                   Eval      w1Pos = %Scan('.':P_File:1)
     C                   If        w1Pos = 0
     C     '0003'        DUMP
     C                   Eval      R_RtnCde = 1
     C                   Else
     C                   Eval      w1Pos = w1Pos + 1
      * The smil should be in 1252 so as to have auto x'0D0A' at the end of line
     C                   Select
     C                   When      %Subst(P_File:w1Pos:3) = 'jpg'
     C                             or %Subst(P_File:w1Pos:3) = 'png'
     C                             or %Subst(P_File:w1Pos:3) = 'gif'
     C                   Eval      w1SmilF = '/mms/mms_pic.smil'
     C                   Eval      w1MMSType   = '/mms/mime_pic.header'
     C                   When      %Subst(P_File:w1Pos:3) = 'mp4'
     C                   Eval      w1SmilF  = '/mms/mms_mp4.smil'
     C                   Eval      w1MMSType = '/mms/mime_mp4.header'
     C                   Other
     C                   Eval      w1SmilF  = *Blank
     C                   Eval      w1MMSType = *Blank
     C                   EndSl
     C                   Endif
      * Setting for UAT Handling
     C                   Call      'PSXX76C'
     C                   Parm      *Blank        IsProd
     C                   If        IsProd = *Blank
     C                   Eval      *In99 = *On
     C     '0012'        Dump
     C                   Eval      R_RtnCde = 1
     C                   Goto      $E_InzSys
     C                   EndIf
      *
     C                   Eval      w1Tel  = P_Tel
      *
     C     $E_InzSys     Tag
     C                   EndSr
      * ===================================================================
      * ReadIFS                                                           =
      * ===================================================================
     C     @ReadIFS      BegSr
      * IFS stored in ASCII code, when read to RPG, automatically translated to EBCDIC
      * when adding CR should be x'0D' and LF should be x'25'
      * Open in Read Only and text mode, so that data will be automatically translated
     C                   Eval      w1FD = open( w1File: O_RDONLY + O_TEXTDATA)
      * Open, Read Error
     C                   if        w1FD = -1
     C                   Callp     ReportError
     C                   endif

      * Read file w1File with pointer 'w1FD' and store in w1data
     C                   Eval      w1Data = *Blank
     C                   Eval      len = read(w1FD: %addr(w1data):%size(w1data))
      * No data read in
     C                   If        len < 1
     C                   Goto      $CloseIFS
     C                   endif
      * Close File
     C     $CloseIFS     Tag
     C                   CallP     close(w1FD)
     C                   EndSr
      * ===================================================================
      * ReadIFSB5                                                         =
      * ===================================================================
     C     @ReadIFSB5    BegSr
      * IFS stored in ASCII code, when read to RPG, automatically translated to EBCDIC
      * when adding CR should be x'0D' and LF should be x'25'
      * Open in Read Only and text mode, so that data will be automatically translated
     C                   Eval      w1FD = open( w1File: O_RDONLY + O_TEXTDATA
     C                                   + O_CCSID
     C                                   : S_IRGRP: 937)
      * Open, Read Error
     C                   if        w1FD = -1
     C                   Callp     ReportError
     C                   endif

      * Read file w1File with pointer 'w1FD' and store in w1data
     C                   Eval      w1Data = *Blank
     C                   Eval      len = read(w1FD: %addr(w1data):%size(w1data))
      * No data read in
     C                   If        len < 1
     C                   Goto      $CloseIFSB5
     C                   endif
      * Close File
     C     $CloseIFSB5   Tag
     C                   CallP     close(w1FD)
     C                   EndSr
      * ===================================================================
      * Read DB2 937 Convert to UTF8 (1208) then to base64                *
      * ===================================================================
     C     @937ToUTF8B64 BegSr
     C                   Eval      O_Base64  = *blank
     C                   Eval      O_buffer = *blank
     C                   Eval      O_Len = 0
     C                   Eval      source = *ALLx'00'
     C                   Eval      target = *ALLx'00'
     C                   Eval      toUTF  = *ALLx'00'
      *
      *     // -----------------------------------------------
      *     //   find the appropriate translation 'table'
      *     //   for converting the job's CCSID to UTF-8
      *     //
      *     //  Note: 0 is a special value that means
      *     //        "job CCSID".  Better to use that than
      *     //        to hard-code 37.
      *     // -----------------------------------------------
      *
     C                   Eval      source.CCSID = 937
     C                   Eval      target.CCSID = 1208
     C                   Eval      toUTF = QtqIconvOpen( target: source )

     C                   if        (toUTF.return_value = -1)
                                // handle error...
     C                   Eval      R_RtnCde = 1
     C                   endif
      *
      *     // -----------------------------------------------
      *     //   Translate data.
      *     //
            //   the iconv() API will increment/decrement
            //   the pointers and lengths, so make sure you
            //   do not use the original pointers...
            // -----------------------------------------------

     C                   Eval      I_input  = %addr(w1ToBase64)
     C                   Eval      I_Len      = %len(%trimr(w1ToBase64))
     C                   Eval      O_output = %addr(O_Buffer)
     C                   Eval      O_Len   = %size(O_Buffer)
      *
     C                   CallP     iconv( toUTF
     C                             : i_input
     C                             : I_Len
     C                             : O_output
     C                             : O_Len)
      *     // -----------------------------------------------
      *     //  if needed, you can calculate the length of
      *     //  the decoded data by subtracting the amount
      *     //  of space left in the buffer from the total
      *     //  buffer size.
      *     //
      *     //  At this point, 'O_Buffer' should contain
      *     //  the UTF data.
      *     // -----------------------------------------------
      *
      * The space left in the buffer in lenght = O_Len
     C                   Eval        O_Len = %size(O_Buffer) - O_Len
      *
     C                   Eval        w1encodelen = base64_encode(%addr(O_Buffer)
     C                               : O_Len
     C                               : %addr(O_Base64)
     C                               : %size(O_Base64) )
      *
      *     // -----------------------------------------------
      *     //  you can call iconv() many more times if you
      *     //  want, using the same 'toUTF' table for
      *     //  translation.
      *     //   - -
      *     //  when you are completely done, call iconv_close()
      *     //  to free up memory.
      *     // -----------------------------------------------
      *
     C                   Callp     iconv_close(toUTF)
     C                   EndSr
      * ===================================================================
      * Read IFS File and convert to Base64                               *
      * ===================================================================
     C     @ReadToBase64 BegSr
      * Open in read only, but NOT text mode
     C                   Eval      att = open( w1File: O_RDONLY)
      * Open, Read Error
     C                   if        att = -1
     C                   Callp     ReportError
     C                   endif

      * Read file w1File with pointer 'att' and store in w1data
     C                   Eval      len = read(att: %addr(w1data): %size(w1data))
      * No data read in
     C                   If        len < 1
     C     '0004'        Dump
     C                   Goto      $CloseFile
     C                   endif
      * Get the Length of encdata
     C                   Eval      enclen = base64_encode( %addr(w1data)
     C                             : len
     C                             : %addr(encdata)
     C                             : %size(encdata)-2 )
     C
      * Close File
     C     $CloseFile    Tag
     C                   CallP     close(att)
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

      *========================*
      * Prototype              *
      *========================*
     P readline        B
     D readline        PI            10i 0
     D   fd                          10i 0 value
     D   text                          *   value
     D   maxlen                      10i 0 value

     D rdbuf           S           1024a   static
     D rdpos           S             10i 0 static
     D rdlen           S             10i 0 static

     D p_retstr        S               *
     D RetStr          S          32766a   based(p_retstr)
     D len             S             10i 0

     c                   eval      len = 0
     c                   eval      p_retstr = text
     c                   eval      %subst(RetStr:1:MaxLen) = *blanks

     c                   dow       1 = 1

      * Load the buffer
     c                   if        rdpos>=rdlen
     c                   eval      rdpos = 0
     c                   eval      rdlen=read(fd:%addr(rdbuf):%size(rdbuf))

     c                   if        rdlen < 1
     c                   return    -1
     c                   endif
     c                   endif

      * Is this the end of the line?
     c                   eval      rdpos = rdpos + 1
     c                   if        %subst(rdbuf:rdpos:1) = x'25'
     c                   return    len
     c                   endif

      * Otherwise, add it to the text string.
     c                   if        %subst(rdbuf:rdpos:1) <> x'0d'
     c                               and len<>maxlen
     c                   eval      len = len + 1
     c                   eval      %subst(retstr:len:1) =
     c                               %subst(rdbuf:rdpos:1)
     c                   endif

     c                   enddo

     c                   return    len
     P                 E
