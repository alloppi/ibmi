     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* HTML Email with Attachments
     F**********************************************************************
     F* ====================================================================
     F* ============== Advanced Integrated RPG by Tom Snyder ===============
     F* ====================================================================
     F* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     F* All rights reserved.
     F*
     F* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     F* Author URL:    http://www.2WolvesOut.com
     F**********************************************************************
     F*   HOW TO COMPILE:
     F*
     F*   (1. CREATE THE MODULE)
     F*   CRTRPGMOD MODULE(AIRLIB/AIR14_03) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR14_03)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREMAIL) ACTGRP(AIR14_03)
     D********************************************************************
     D                SDS
     D  QPGM                   1     10
     D  MSGTXT                91    170
     D  QUSER                254    263
     D  QDATE                276    281
     D  QTIME                282    287  0
     D  QCUSER               358    367
     D*
     D  airMessage     S                   like(MimeMessage)
     D  airMultipart   S                   like(MimeMultipart)
     D  recipients     S           1024A   dim(100)
     D  htmlString     S          65535A   varying
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREMAIL
     C/EJECT
      /free
         CallP JavaServiceProgram();
         airMessage = AirEmail_newMessage();
         AirEmail_setSubject(airMessage:'AS400 HTML With Attachment');
         recipients = *BLANKS;
         recipients(1) = 'TomSnyder@example.com';
         recipients(2) = 'ThomasSnyder@example.com';
         // Create the Multipart content
         airMultipart = new_MimeMultipart(new_string('related'));
         htmlString = '<h1>HTML</h1>'
                    + ' Email with Excel and PDF attachments';
         AirEmail_addHTML(airMultipart:htmlString);
         // Add an Excel Attachment
         AirEmail_addAttachment(airMultipart
                               :'/Public/Air09_01.xls'
                               :'application/vnd.ms-excel');
         // Add a PDF Attachment
         AirEmail_addAttachment(airMultipart
                               :'/Public/Air11_01.pdf'
                               :'application/pdf');
         // Add the Multipart content to the Message and send it.
         MimeMessage_setContent(airMessage: airMultipart);
         AirEmail_send(airMessage:recipients);
         freeLocalRef(airMessage);
         freeLocalRef(airMultipart);
         *inlr = *ON;
      /end-free
