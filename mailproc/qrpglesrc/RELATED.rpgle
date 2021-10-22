      * Sample of sending a multipart/related e-mail message
      * (An HtML message with an image -- my logo -- embedded in it.)
      *                                      Scott Klement 07/27/2006
      *
      * To compile:
      *    Before compiling, change the "from" and "to" e-mail address
      *    info at the top of the source member!
      *
      *    CRTRPGMOD MODULE(QTEMP/RELATED) +
      *              SRCFILE(xxx/QRPGLESRC) +
      *              DBGVIEW(*LIST)
      *
      *    CRTPGM PGM(mylib/RELATED) +
      *           MODULE(QTEMP/RELATED) +
      *           BNDSRVPGM(QTCP/QTMMSNDM)
      *
      *
     H BNDDIR('QC2LE') OPTION(*SRCSTMT:*NOSHOWCPY)

     D Html            s             78A   DIM(9) CTDATA PERRCD(1)
     D Logo            s             78A   DIM(35) CTDATA PERRCD(1)

      /copy ifsio_h
      /copy sendmail_h

     D tmpnam          PR              *   extproc('_C_IFS_tmpnam')
     D   string                      39A   options(*omit)
     D ReportError     PR
     D MailDate        PR            31A

     D CRLF            c                   x'0d25'

     D filename        s             50A   varying
     D fd              s             10I 0
     D header          s           2000A   varying
     D body            s            500A   varying
     D boundary        s             78A   varying
     D fromName        s            100A   varying
     D fromAddr        s            300A   varying
     D toName          s            100A   varying
     D toAddr          s            300A   varying
     D subject         s             80A   varying
     D x               s             10I 0

     D recip           ds                  likeds(ADDTO0100)
     D                                     dim(1)
     D NullError       ds
     D   BytesProv                   10I 0 inz(0)
     D   BytesAvail                  10I 0 inz(0)
     D wait            s              1A

      /free
          fromName = 'Scott Klement';
          fromAddr = 'sklement@iseriesnetwork.com';
          toName   = 'Faithful Reader';
          toAddr   = 'freader@example.com';
          subject  = 'Testing HTML with a picture';

          if (%scan('klement': fromAddr)>0
              or %scan('example': toAddr)>0);
               dsply ('PLEASE FIX E-MAIL ADDRESSES!');
               dsply ('THEN RUN THIS PROGRAM AGAIN.') ' ' wait;
               return;
          endif;

          // ------------------------------------------
          // create a temporary file in the IFS.
          // mark that file as ccsid 819 (ISO 8859-1 ASCII)
          // ------------------------------------------

          filename = %str(tmpnam(*omit));
          unlink(filename);

          fd = open( filename
                   : O_CREAT+O_EXCL+O_WRONLY+O_CCSID
                   : M_RDWR
                   : 819 );
          if (fd = -1);
             ReportError();
          endif;

          // ------------------------------------------
          // close file & reopen in text mode so that
          // data will be automatically translated
          // ------------------------------------------

          callp close(fd);
          fd = open( filename : O_WRONLY + O_TEXTDATA );
          if (fd = -1);
             ReportError();
          endif;

          // ------------------------------------------
          //  build an e-mail header in a variable
          // ------------------------------------------
          Boundary = '--=_ScottsNiftyBoundary';

          header =
           'From: ' + fromName + ' <' + fromAddr + '>' + CRLF
          +'To: '   + toName   + ' <' + toAddr   + '>' + CRLF
          +'Date: ' + maildate() + CRLF
          +'Subject: ' + subject + CRLF
          +'MIME-Version: 1.0' + CRLF
          +'Content-Type: multipart/related;'
          +   ' boundary="' + Boundary + '"' + CRLF
          + CRLF
          + 'Your mail reader doesn''t support MIME!' + CRLF
          + CRLF;

          callp write(fd: %addr(header)+2: %len(header));

          // ------------------------------------------
          //  Insert the headers for the HTML part
          // ------------------------------------------

          body =
           '--' + boundary + CRLF
          +'Content-type: text/html' + CRLF
          + CRLF;
          callp write(fd: %addr(body)+2: %len(body));

          // ------------------------------------------
          //  Copy the text part from the compile-time
          //  array to the IFS stream file
          // ------------------------------------------

          for x = 1 to %elem(html);
             body = %trimr(html(x)) + CRLF;
             callp write(fd: %addr(body)+2: %len(body));
          endfor;

          // ------------------------------------------
          //  Insert the headers for the HTML part
          // ------------------------------------------

          body =
           '--' + boundary + CRLF
          +'Content-Type: image/gif; name="sklogo.gif"' + CRLF
          +'Content-Transfer-Encoding: base64' + CRLF
          +'Content-ID: <sklogo.gif@iseriesnetwork.com>' + CRLF
          +'Content-Disposition: inline; filename="sklogo.gif"' + CRLF
          + CRLF;
          callp write(fd: %addr(body)+2: %len(body));


          // ------------------------------------------
          //  Copy the logo part from the compile-time
          //  array to the IFS stream file
          // ------------------------------------------

          for x = 1 to %elem(logo);
             body = %trimr(logo(x)) + CRLF;
             callp write(fd: %addr(body)+2: %len(body));
          endfor;

          // ------------------------------------------
          //  Finish the message & close the file
          // ------------------------------------------
          body = CRLF + '--' + boundary + '--' + CRLF;
          callp write(fd: %addr(body)+2: %len(body));
          callp close(fd);

          // ------------------------------------------
          //  Use the QtmmSendMail() API to send the
          //  IFS file via SMTP
          // ------------------------------------------

          recip(1).NextOffset = %size(ADDTO0100);
          recip(1).AddrFormat = 'ADDR0100';
          recip(1).DistType   = ADDR_NORMAL;
          recip(1).Reserved   = 0;
          recip(1).SmtpAddr   = toAddr;
          recip(1).AddrLen    = %len(toAddr);

          QtmmSendMail( FileName
                      : %len(FileName)
                      : fromAddr
                      : %len(fromAddr)
                      : recip
                      : %elem(recip)
                      : NullError );

          *inlr = *on;
      /end-free


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


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  MailDate():  Returns the current date, formatted for use
      *               in an e-mail message.
      *
      *     For example:  'Sat, 23 Oct 2004 14:42:06 -0500'
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P MailDate        B
     D MailDate        PI            31A

     D CEELOCT         PR                  opdesc
     D   Lilian                      10I 0
     D   Seconds                      8F
     D   Gregorian                   23A
     D   fc                          12A   options(*omit)

     D CEEUTCO         PR                  opdesc
     D   Hours                       10I 0
     D   Minutes                     10I 0
     D   Seconds                      8F
     D   fc                          12A   options(*omit)

     D CEEDATM         PR                  opdesc
     D   input_secs                   8F   const
     D   date_format                 80A   const options(*varsize)
     D   char_date                   80A   options(*varsize)
     D   feedback                    12A   options(*omit)

     D rfc2822         c                   'Www, DD Mmm YYYY HH:MI:SS'
     D junk1           s              8F
     D junk2           s             10I 0
     D junk3           s             23A
     D hours           s             10I 0
     D mins            s             10I 0
     D tz_hours        s              2P 0
     D tz_mins         s              2P 0
     D tz              s              5A   varying
     D CurTime         s              8F
     D Temp            s             25A

      /free

         //
         //  Calculate the Timezone in format '+0000', for example
         //    CST should show up as '-0600'
         //

         CEEUTCO(hours: mins: junk1: *omit);
         tz_hours = %abs(hours);
         tz_mins = mins;

         if (hours < 0);
            tz = '-';
         else;
            tz = '+';
         endif;

         tz += %editc(tz_hours:'X') + %editc(tz_mins:'X');

         //
         //  Get the current time and convert it to the format
         //    specified for e-mail in RFC 2822
         //

         CEELOCT(junk2: CurTime: junk3: *omit);
         CEEDATM(CurTime: rfc2822: Temp: *omit);

         return Temp + ' ' + tz;

      /end-free
     P                 E

** ------------------ HTML Part -----------------------
<html>
<body bgcolor="#ffffff" text="#000000">
<b>Hey, this is a really silly e-mail message.<br>
<br>
<img alt="" src="cid:sklogo.gif@iseriesnetwork.com"
 height="54" width="44"><i>Scott Klement</i><br>
</b>
</body>
</html>
** ---------------- Base64 Encoded Logo ---------------
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
