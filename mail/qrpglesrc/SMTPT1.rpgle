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

      /copy SMTPUTIL,smtp_h

     D CRLF            C                   X'0d25'
     D FAIL            C                   const(*OFF)

     D authuser        s            256A   varying
     D authpass        s            256A   varying
     D wholemsg        s          32767A   varying

     D hsmtp           s                   like(SMTP_HANDLE)
     D ErrMsg          s             80A
      /free

          *inlr = *on;
          hsmtp = SMTP_new('202.134.63.144');

          if ( SMTP_connect(hsmtp) = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          authuser = 'smtpauth@promise.com.hk';
          authpass = 'Abc1234d';
          if ( SMTP_auth(hsmtp: authuser: authpass) = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          if ( SMTP_from(hsmtp: 'promise9@promise.com.hk') = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          if ( SMTP_recip(hsmtp: 'cya012@promise.com.hk') = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          wholemsg = 'From: Promise9 <promise9@promise.com.hk>' + CRLF
                   + 'To: Alan Chan <cya012@promise.com.hk>' + CRLF
                   + 'Subject: smtp utility testing' + CRLF
                   + CRLF
                   + 'Hello Alan.  Testing for smtp utility' + CRLF
                   + 'Sincerely,' + CRLF
                   + '  Alan Chan';

          if ( SMTP_data_var( hsmtp : wholemsg ) = FAIL );
             ErrMsg = SMTP_error();
             // FIXME: Display error to user
          endif;

          SMTP_quit(hsmtp);
          SMTP_free(hsmtp);
          return;

      /end-free
