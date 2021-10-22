     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Fonts and Colors
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR11_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR11_01)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR11_01)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIRPDF
     D  airBytes       S           1024A   varying
     D  airFileName    S           1024A   varying
     D  airString      S                   like(jString)
     D  airDocument    S                   like(ITextDocument)
     D  airParagraph   S                   like(ITextParagraph)
     D  airFontGreen   S                   like(ITextFont)
     D  airColorGreen  S                   like(JavaColor)
     D  airFontBlue    S                   like(ITextFont)
     D  airColorBlue   S                   like(JavaColor)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         airFileName = '/Public/Air11_01.pdf';
         airDocument = AirPdf_newDocumentOutput(airFileName:'LETTER':*ON);
         //
         airColorGreen = Air_getColorFromHex(COLOR_SEA_GREEN);
         airFontGreen = new_ITextFont(ITEXT_FONT_HELVETICA: 22:
                                  ITEXT_FONT_BOLD);
         ITextFont_setColor(airFontGreen: airColorGreen);
         airColorBlue = Air_getColorFromHex(COLOR_CORNFLOWER_BLUE);
         airFontBlue = new_ITextFont(ITEXT_FONT_HELVETICA: 16:
                                  ITEXT_FONT_BOLD_ITALIC);
         ITextFont_setColor(airFontBlue: airColorBlue);
         //
         airParagraph = AirPdf_newParagraph(
                        'COLOR_SEA_GREEN, Helvetica, Bold, 22':
                        airFontGreen);
         ITextDocument_add(airDocument: airParagraph);
         //
         airParagraph = AirPdf_newParagraph(
                        'COLOR_CORNFLOWER_BLUE, Helvetica, Bold/Italic, 16':
                        airFontBlue);
         ITextDocument_add(airDocument: airParagraph);
         //
         ITextDocument_close(airDocument);
         // Clean Up
         freeLocalRef(airParagraph);
         freeLocalRef(airDocument);
         freeLocalRef(airFontGreen);
         freeLocalRef(airFontBlue);
         freeLocalRef(airColorGreen);
         freeLocalRef(airColorBlue);
         *inlr = *ON;
      /end-free
