      * Sample of sending a message with a base64 encoded attachment
      * It does this by first creating a CSV file from a PF, then
      * base64 encoding that PF and attaching it to the message.
      *                                      Scott Klement 07/27/2006
      *
      * Before compiling:
      *   -- This requires the BASE64 open source utility from
      *       http://www.scottklement.com/base64.
      *   -- make sure base64 utility has been compiled.
      *   -- Change the "from" and "to" e-mail addresses at
      *       the top of the calc specs, below!
      *   -- Change the name of the file you want to attach
      *       at the top of the calc specs, below!
      *
      * To Compile:
      *    CRTRPGMOD MODULE(QTEMP/ATTACH) +
      *              SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
      *    CRTPGM PGM(mylib/ATTACH) +
      *           MODULE(QTEMP/ATTACH) BNDSRVPGM(QTCP/QTMMSNDM)
      *
     H BNDDIR('QC2LE':'BASE64') OPTION(*SRCSTMT:*NOSHOWCPY)

     D Text            s             53A   DIM(9) CTDATA PERRCD(1)
     D asciitext       s             53A   varying

      /copy qmailsrc,ifsio_h
      /copy qmailsrc,sendmail_h
      /copy qbase64src,base64_h

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D   cmd                      32702A   const options(*varsize)
     D   len                         15P 5 const

     D tmpnam          PR              *   extproc('_C_IFS_tmpnam')
     D   string                      39A   options(*omit)

     D QDCXLATE        PR                  ExtPgm('QDCXLATE')
     D   convertlen                   5P 0 const
     D   convertdata              32702A   options(*varsize)
     D   table                       10A   const

     D ReportError     PR
     D MailDate        PR            31A

     D CRLF            c                   x'0d25'

     D fromName        s            100A   varying
     D fromAddr        s            300A   varying
     D toName          s            100A   varying
     D toAddr          s            300A   varying
     D subject         s             80A   varying
     D attFile         s             21A   varying
     D attName         s             50A   varying

     D filename        s             50A   varying
     D tempAttach      s             50A   varying
     D att             s             10I 0
     D fd              s             10I 0
     D header          s           2000A   varying
     D body            s            500A   varying
     D cmd             s            500A   varying
     D boundary        s             78A   varying
     D x               s             10I 0
     D data            s             54A
     D encData         s             74A
     D encLen          s             10i 0
     D len             s             10i 0

     D recip           ds                  likeds(ADDTO0100)
     D                                     dim(1)
     D NullError       ds
     D   BytesProv                   10I 0 inz(0)
     D   BytesAvail                  10I 0 inz(0)
     D wait            s              1A

      /free
          fromName = 'Promise9';
          fromAddr = 'Promise9@promise.com.hk';
          toName   = 'Alan Chan';
          toAddr   = 'cya012@promise.com.hk';
          subject  = 'Testing sending a CSV file';
          attFile  = '*LIBL/PHPBNB01F';
          attname  = 'PHPBNB01.CSV';

          // if (%scan('mise': fromAddr)>0
          //     or %scan('a012': toAddr)>0);
          //     dsply ('PLEASE FIX E-MAIL ADDRESSES!');
          //     dsply ('THEN RUN THIS PROGRAM AGAIN.') ' ' wait;
          //     return;
          // endif;

          // ------------------------------------------
          //  Convert the PF to a format that PCs like
          //  a Comma Separated Values (CSV) file
          // ------------------------------------------

          tempAttach = %str(tmpnam(*omit));
          unlink(tempAttach);

          cmd = 'CPYTOIMPF FROMFILE(' + attFile + ') '
              +           'TOSTMF(''' + tempAttach +''') '
              +           'MBROPT(*REPLACE) '
              +           'STMFCODPAG(*PCASCII) '
              +           'RCDDLM(*CRLF)';

          QCMDEXC( cmd : %len(cmd));


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
          +'Content-Type: multipart/mixed;'
          +   ' boundary="' + Boundary + '"' + CRLF
          + CRLF
          + 'Your mail reader doesn''t support MIME!' + CRLF
          + CRLF;

          callp write(fd: %addr(header)+2: %len(header));

          // ------------------------------------------
          //  Insert the headers for the text part
          // ------------------------------------------

          body =
           '--' + boundary + CRLF
          +'Content-type: text/plain' + CRLF
          + CRLF;
          callp write(fd: %addr(body)+2: %len(body));

          // ------------------------------------------
          //  Copy the text part from the compile-time
          //  array to the IFS stream file
          // ------------------------------------------

          for x = 1 to %elem(text);
             body = %trimr(text(x)) + CRLF;
             callp write(fd: %addr(body)+2: %len(body));
          endfor;

          // ------------------------------------------
          //  Insert the headers for the text part
          // ------------------------------------------

          body =
           '--' + boundary + CRLF
          +'Content-type: text/plain; charset=big5' + CRLF
          +'Content-Transfer-Encoding: base64' + CRLF
          + CRLF;
          callp write(fd: %addr(body)+2: %len(body));

          // ------------------------------------------
          //  Copy the text part from the compile-time
          //  array to the IFS stream file
          // ------------------------------------------

          for x = 1 to %elem(text);
             callp QDCXLATE( %len(text(x))
                           : text(x)
                           : 'QTCPASC' );
             body = %trimr(asciitext) + CRLF;
             enclen = base64_encode( %addr(body)
                                   : %len(body)
                                   : %addr(encdata)
                                   : %size(encdata)-2 );

             %subst(encdata:enclen+1) = CRLF;
             callp write(fd: %addr(encdata): enclen+2);
          endfor;

          // ------------------------------------------
          //  Insert the headers for the CSV file
          // ------------------------------------------

          Boundary = '--=_ScottsNiftyBoundary';

          body =
           '--' + boundary + CRLF
          +'Content-Type: text/csv; name="' + attname + '"' + CRLF
          +'Content-Transfer-Encoding: base64' + CRLF
          +'Content-Disposition: attachment;'
          +    ' filename="' + attname + '"' + CRLF
          + CRLF;
          callp write(fd: %addr(body)+2: %len(body));


          // ------------------------------------------
          //  Read the attachment file, and base64
          //  encode it.  Write the results to the
          //  e-mail message.
          // ------------------------------------------

          att = open( tempAttach: O_RDONLY );
          if (att = -1);
             ReportError();
          endif;
          unlink(tempAttach);

          dow '1';
             len = read(att: %addr(data): %size(data));
             if (len < 1);
                leave;
             endif;

             enclen = base64_encode( %addr(data)
                                   : len
                                   : %addr(encdata)
                                   : %size(encdata)-2 );

             %subst(encdata:enclen+1) = CRLF;
             callp write(fd: %addr(encdata): enclen+2);
          enddo;

          callp close(att);

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

** ------------------ Text Part --------------------
Hi there,

The purpose of this message is to send you the
attached file.  You can open it in Excel or any
other program that understands CSV files.

Good luck!


