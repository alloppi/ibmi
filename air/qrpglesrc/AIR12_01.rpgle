     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Images with Borders
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR12_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR12_01)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR12_01)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRFUNC
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIRPDF
     D  airFileName    S           1024A   varying
     D  airImageName   S           1024A   varying
     D  airBytes       S           1024A   varying
     D  airString      S                   like(jString)
     D  airDocument    S                   like(ITextDocument)
     D  airParagraph   S                   like(ITextParagraph)
     D  airFontHead    S                   like(ITextFont)
     D  airNewLine     S                   like(ITextChunk)
     D  airImage       S                   like(ITextImage)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         airFileName = '/Public/Air12_01.pdf';
         airImageName = '/Public/mantis.png';
         airDocument = AirPdf_newDocumentOutput(airFileName:'LETTER');
         airString = new_String(EBCDIC_CR + EBCDIC_LF);
         airNewLine = new_ITextChunk(airString);
         //
         airFontHead = new_ITextFont(ITEXT_FONT_HELVETICA: 15:
                                  ITEXT_FONT_BOLD);
         //
         airBytes = 'Praying Mantis with Border';
         airParagraph = AirPdf_newParagraph(airBytes:
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         ITextDocument_add(airDocument: airNewLine);
         //
         airImage = AirPdf_getImage(airImageName);
         ITextImage_setAlignment(airImage: ITEXT_IMAGE_ALIGN_MIDDLE);
         ITextImage_setBorder(airImage: ITEXT_IMAGE_BOX);
         AirPdf_setImageBorderColor(airImage: COLOR_INDIGO);
         ITextImage_setBorderWidth(airImage: 7);
         ITextDocument_add(airDocument: airImage);
         //
         ITextDocument_close(airDocument);
         // Clean Up
         freeLocalRef(airNewLine);
         freeLocalRef(airFontHead);
         freeLocalRef(airImage);
         freeLocalRef(airParagraph);
         freeLocalRef(airDocument);
         *inlr = *ON;
      /end-free
