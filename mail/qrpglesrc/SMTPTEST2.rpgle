      * Sample of sending a multipart/alternative e-mail message
      *                                      Scott Klement 07/27/2006
      *                            upgraded to use SMTPR4  08/17/2006
      *
      * To compile:
      * -  Before compiling, change the "from" and "to" e-mail address
      *    info at the top of the source member!
      * -  Also make sure the SMTPR4 service porgram has been built,
      *    see the SMTPR4 member for instructions.
      *
      *    CRTBNDRPG PGM(SMTPTEST2) SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H BNDDIR('QC2LE':'SMTP') OPTION(*SRCSTMT:*NOSHOWCPY)
     H DFTACTGRP(*NO)

     D Text            s             78A   DIM(7) CTDATA PERRCD(1)
     D Html            s             78A   DIM(22) CTDATA PERRCD(1)

      /copy smtp_h
      /copy ifsio_h

     D tmpnam          PR              *   extproc('_C_IFS_tmpnam')
     D   string                      39A   options(*omit)
     D ReportError     PR

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
          subject  = 'Testing both alternatives';

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
          Boundary = '--=_ScottsBoundaryYeah';

          header =
           'From: ' + fromName + ' <' + fromAddr + '>' + CRLF
          +'To: '   + toName   + ' <' + toAddr   + '>' + CRLF
          +'Date: ' + SMTP_getTime() + CRLF
          +'Subject: ' + subject + CRLF
          +'MIME-Version: 1.0' + CRLF
          +'Content-Type: multipart/alternative;'
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
          //  Insert the headers for the HTML part
          // ------------------------------------------

          body =
           '--' + boundary + CRLF
          +'Content-type: text/html' + CRLF
          + CRLF;
          callp write(fd: %addr(body)+2: %len(body));

          // ------------------------------------------
          //  Copy the HTML part from the compile-time
          //  array to the IFS stream file
          // ------------------------------------------

          for x = 1 to %elem(html);
             body = %trimr(html(x)) + CRLF;
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

          //  SMTP_SetServer('smtp.example.com');

          SMTPSendMail( FileName
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

** ------------------ Text Part -----------------------
Dear Faithful,

For your convienience, I've sent you this message in both text and HTML
format.  You are currently reading the text version.

Thanks,
Scott
** ------------------ HTML Part -----------------------
<html>
<head>
<style type="text/css">
.normal {font-size: 14pt; font-family: Arial;}
.emphasis {font-style: italic;
           font-weight: bold;
           font-size: 14pt;
           font-family: Arial;}
</style>
</head>

<body>
<p class="emphasis">Dear Faithful,</p>

<p class="normal">For your convienience, I've sent you this message in both
text and HTML format.  You are currently reading the HTML version.</p>

<p class="normal">Thanks,<br />
Scott</p>

</body>
</html>
