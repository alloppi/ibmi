     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Fonts and Hyperlinks
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR11_03) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR11_03)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR11_03)
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
     D  airAnchor      S                   like(ITextAnchor)
     D  airFontHead    S                   like(ITextFont)
     D  airColorHead   S                   like(JavaColor)
     D  airFont        S                   like(ITextFont)
     D  airColor       S                   like(JavaColor)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         airFileName = '/Public/Air11_03.pdf';
         airDocument = AirPdf_newDocumentOutput(airFileName:'LETTER':*ON);
         //
         airColorHead = Air_getColorFromHex(COLOR_SEA_GREEN);
         airFontHead = new_ITextFont(ITEXT_FONT_HELVETICA: 22:
                                  ITEXT_FONT_BOLD);
         ITextFont_setColor(airFontHead: airColorHead);
         airColor = Air_getColorFromHex(COLOR_CORNFLOWER_BLUE);
         airFont = new_ITextFont(ITEXT_FONT_HELVETICA: 10:
                                  ITEXT_FONT_BOLD_ITALIC);
         ITextFont_setColor(airFont: airColor);
         //
         airParagraph = AirPdf_newParagraph('Fonts and Links':
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         airParagraph = AirPdf_newParagraph('Click ');
         //
         airAnchor = AirPdf_newAnchor('here': airFont);
         AirPdf_setAnchorReference(airAnchor: '#label');
         ITextParagraph_add(airParagraph: airAnchor);
         //
         airString = new_String(' to jump to the internal label.');
         ITextParagraph_add(airParagraph: airString);
         ITextDocument_add(airDocument: airParagraph);
         //
         airParagraph = AirPdf_newParagraph('Or click ');
         //
         airAnchor = AirPdf_newAnchor('here': airFont);
         airBytes = 'http://www.mcpressonline.com';
         AirPdf_setAnchorReference(airAnchor: airBytes);
         ITextParagraph_add(airParagraph: airAnchor);
         //
         airString = new_String(' to jump to the mcpressonline.com');
         ITextParagraph_add(airParagraph: airString);
         ITextDocument_add(airDocument: airParagraph);
         // Create a new page
         ITextDocument_newPage(airDocument);
         //
         airBytes = 'You are now at the internal label.';
         airAnchor = AirPdf_newAnchor(airBytes);
         AirPdf_setAnchorName(airAnchor: 'label');
         ITextDocument_add(airDocument: airAnchor);
         //
         ITextDocument_close(airDocument);
         // Clean Up
         freeLocalRef(airAnchor);
         freeLocalRef(airParagraph);
         freeLocalRef(airDocument);
         *inlr = *ON;
      /end-free
