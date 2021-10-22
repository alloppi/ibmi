     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Simple Email
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR13_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR13_01)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREMAIL) ACTGRP(AIR13_01)
     D********************************************************************
     D                SDS
     D  QPGM                   1     10
     D  MSGTXT                91    170
     D  QUSER                254    263
     D  QDATE                276    281
     D  QTIME                282    287  0
     D  QCUSER               358    367
     D*
     D  msg            S                   like(MimeMessage)
     D  recipients     S           1024A   dim(100)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREMAIL
     C/EJECT
      /free
         CallP JavaServiceProgram();
         msg = AirEmail_newMessage('TomSnyder'
                                  :'mcpr3$$');
         AirEmail_setSubject(msg:'AS400 Email');
         AirEmail_setText(msg:'Hello World! '
                            + 'This is an Email from the 400!');
         recipients = *BLANKS;
         recipients(1) = 'TomSnyder@example.com';
         recipients(2) = 'ThomasSnyder@example.com';
         AirEmail_send(msg:recipients);
         freeLocalRef(msg);
         *inlr = *ON;
      /end-free
