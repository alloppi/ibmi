      *  Basic Example of using the SMTPR4 service program to send
      *  an e-mail message
      *                               Scott Klement, August 17, 2006
      *
      *  To Compile:
      *      - Make sure you've built the SMTPR4 service program.
      *        (see the SMTPR4 member for details)
      *      - Make sure the SMTP_H member is in a QRPGLESRC file
      *        in your library list.
      *
      *      - CRTBNDRPG SMTPTEST1 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) OPTION(*SRCSTMT) BNDDIR('SMTP')

      /copy qmailsrc,smtp_h

     D CRLF            C                   X'0d25'
     D FAIL            C                   const(*OFF)

     D wholemsg        s          32767A   varying

     D hsmtp           s                   like(SMTP_HANDLE)
     D ErrMsg          s             80A
      /free

          *inlr = *on;
          hsmtp = SMTP_new('smtp.promise.com.hk');

          if ( SMTP_connect(hsmtp) = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          if ( SMTP_from(hsmtp: 'promise3@promise.com.hk') = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          if ( SMTP_recip(hsmtp: 'cya012@promise.com.hk') = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          wholemsg = 'From: Promise3 <promise3@promise.com.hk>' + CRLF
                   + 'To: Alan Chan <cya012@promise.com.hk>' + CRLF
                   + 'X-Cool-Header: Headers start with X- ' + CRLF
                   + 'Subject: Say Hello from Promise3' + CRLF
                   + CRLF
                   + 'Hello there.  Nice day for frolicking in the'
                   + CRLF
                   + 'beautiful Hawaiian sun.' + CRLF
                   + '(Actually, they have the same sun we do.)' + CRLF
                   + CRLF
                   + 'Sincerely,' + CRLF
                   + '-- Promise3';

          if ( SMTP_data_var( hsmtp : wholemsg ) = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          SMTP_quit(hsmtp);
          SMTP_free(hsmtp);
          return;

      /end-free
