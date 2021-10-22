     H DFTACTGRP(*NO) BNDDIR('SMTP')

      /copy qmailsrc,smtp_h

     D msg             s             78A   dim(12) CTDATA
     D hsmtp           s                   like(SMTP_HANDLE)
      /free

        // FIXME: This program doesn't do any error checking!
        //        see SMTPTEST1 for an example of how errors
        //        should be checked.

        msg(4) = %trimr(msg(4)) + ' ' + SMTP_getTime();

        hsmtp = SMTP_new();
        SMTP_connect(hsmtp);
        SMTP_from (hsmtp: 'sklement@iseriesnetwork.com');
        SMTP_recip(hsmtp: 'freader@example.com');
        SMTP_data_ary(hsmtp: msg: %elem(msg));
        SMTP_free(hsmtp);

        *inlr = *on;
      /end-free
**
From: Scott Klement <sklement@iseriesnetwork.com>
To: Faithful Reader <freader@example.com>
Subject: Testing the CTDATA approach
Date:

Hello Reader,

I think that this is a pretty easy way to key a nice e-mail
message into an RPG program, and then send it.  Don't you?

Thanks,
Scott
