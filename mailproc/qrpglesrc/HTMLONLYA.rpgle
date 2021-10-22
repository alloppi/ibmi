      * Sample of sending a HTML-only (using MIME) e-mail message
      *                                      Scott Klement 07/27/2006
      *
      * To compile:
      *    Before compiling, change the "from" and "to" e-mail address
      *    info at the top of the source member!
      *
      *    CRTRPGMOD MODULE(QTEMP/HTMLONLYA) SRCFILE(ALAN/QMAILSRC) DBGVIEW(*LIST)
      *
      *    CRTPGM PGM(ALAN/HTMLONLYA) MODULE(QTEMP/HTMLONLYA) BNDSRVPGM(QTCP/QTMMSNDM)
      *
     H BNDDIR('QC2LE') OPTION(*SRCSTMT:*NOSHOWCPY)
     H DEBUG(*YES)

      /copy qmailsrc,ifsio_h
      /copy qmailsrc,sendmail_h

     D tmpnam          PR              *   extproc('_C_IFS_tmpnam')
     D   string                      39A   options(*omit)
     D ReportError     PR
     D MailDate        PR            31A

     D CRLF            c                   x'0d25'

     D filename        s             50A   varying
     D fd              s             10I 0
     D header          s           2000A   varying
     D body            s          32767A   varying
     D fromName        s            100A   varying
     D fromAddr        s            300A   varying
     D subject         s             80A   varying

     D toName          s            100A   varying
     D                                     dim(2)
     D toAddr          s            300A   varying
     D                                     dim(2)

     D recip           ds                  likeds(ADDTO0100)
     D                                     dim(2)
     D NullError       ds
     D   BytesProv                   10I 0 inz(0)
     D   BytesAvail                  10I 0 inz(0)
     D wait            s              1A

      /free
          fromName = 'Promise3';
          fromAddr = 'promise3@promise.com.hk';
          toName(2)= 'Alan Promise';
          toAddr(2)= 'cya012@promise.com.hk';
          toName(1)= 'Alan CISD';
          toAddr(1)= 'alan.yl@cisd.com.hk';
          // toName(3)= 'Alan Alloppi';
          // toAddr(3)= 'alloppi@gmail.com';
          subject  = 'Testing a html-only message';

          if (%scan('klement': fromAddr)>0
              or %scan('example': toAddr(1))>0);
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

          header =
           'From: ' + fromName + ' <' + fromAddr + '>' + CRLF
          +'To: '   + toName(1)+ ' <' + toAddr(1)+ '>'
          +','      + toName(2)+ ' <' + toAddr(2)+ '>'
          // +','      + toName(3)+ ' <' + toAddr(3)+ '>'
          + CRLF
          +'Date: ' + maildate() + CRLF
          +'Subject: ' + subject + CRLF
          +'MIME-Version: 1.0' + CRLF
          +'Content-Type: text/html; charset=big5' + CRLF
          + CRLF;


          // ------------------------------------------
          //  put the message text into a variable
          // ------------------------------------------

          body =
           '<html>' + CRLF
          +'<head>' + CRLF
          +'<style type="text/css">' + CRLF
          +'.red {font-size: 14pt; font-family: Arial; '
          +'color: #ff0000;}' +CRLF
          +'.normal {font-size: 14pt; font-family: Arial;}' + CRLF
          +'.emphasis {font-style: italic;' + CRLF
          +'           font-weight: bold;'  + CRLF
          +'           font-size: 14pt;'    + CRLF
          +'           font-family: Arial;}'+ CRLF
          +'</style>' + CRLF
          +'</head>'  + CRLF
          +'<body>'   + CRLF
          // +'<p class="normal">Dear Faithful,測試</p>' + CRLF
          +'<p class="normal">Dear Faithful,</p>' + CRLF
          + CRLF
          +'<p class="normal">This demonstrates a MIME message. In the '
          +'header, it' + CRLF
          +'identifies itself as MIME with the MIME-Version keyword. '
          +'It tells the mail ' + CRLF
          +'reader that it uses HTML for the text.</p>' + CRLF
          +CRLF
          +'<p class="normal">HTML provides capabilities that text-only '
          +'e-mail cannot.</p>' + CRLF
          +'<p class="emphasis">For example, I can provide emphasis!</p>'
          +CRLF
          +'<p class="red">I can even use color!</p>' + CRLF
          +CRLF
          +'<p class="normal">I still keep my message text wrapped at '
          +'78 characters,' + CRLF
          +'but due to the nature of HTML, it''ll all be stuck together '
          +'when it''s' + CRLF
          +'displayed.  I need to use HTML paragraph and line break tags '
          +'to make the' + CRLF
          +'formatting look nice.</p>' + CRLF
          +CRLF
          +'<p class="normal">Have a nice day.<br />' + CRLF
          +'<i>Scott Klement</i></p>' + CRLF
          +'</body>' + CRLF
          +'</html>' + CRLF;

          // ------------------------------------------
          //  write the data to the IFS file
          //  (since the file is in text mode, it'll
          //   automatically be translated to ASCII )
          // ------------------------------------------

          callp write(fd: %addr(header)+2: %len(header));
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
          recip(1).SmtpAddr   = toAddr(1);
          recip(1).AddrLen    = %len(toAddr(1));

          recip(2).NextOffset = %size(ADDTO0100);
          recip(2).AddrFormat = 'ADDR0100';
          recip(2).DistType   = ADDR_NORMAL;
          recip(2).Reserved   = 0;
          recip(2).SmtpAddr   = toAddr(2);
          recip(2).AddrLen    = %len(toAddr(2));

          // recip(3).NextOffset = %size(ADDTO0100);
          // recip(3).AddrFormat = 'ADDR0100';
          // recip(3).DistType   = ADDR_NORMAL;
          // recip(3).Reserved   = 0;
          // recip(3).SmtpAddr   = toAddr(3);
          // recip(3).AddrLen    = %len(toAddr(3));

          QtmmSendMail( FileName
                      : %len(FileName)
                      : fromAddr
                      : %len(fromAddr)
                      : recip
                      : %elem(recip)
                      : NullError );

          Dump 'QtmmSendMail';

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
