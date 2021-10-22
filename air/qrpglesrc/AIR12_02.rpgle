     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Images with Word Wrap
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR12_02) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR12_02)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR13_02)
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
     D  airPhrase      S                   like(ITextPhrase)
     D  airFontHead    S                   like(ITextFont)
     D  airNewLine     S                   like(ITextChunk)
     D  airImage       S                   like(ITextImage)
     D  airAlignment   S                   like(jInt)
     D  i              S              3S 0
     C/EJECT
      /free
         CallP JavaServiceProgram();
         airFileName = '/Public/Air12_02.pdf';
         airImageName = '/Public/mantis.png';
         airDocument = AirPdf_newDocumentOutput(airFileName:'LETTER');
         airString = new_String(EBCDIC_CR + EBCDIC_LF);
         airNewLine = new_ITextChunk(airString);
         //
         airFontHead = new_ITextFont(ITEXT_FONT_HELVETICA: 15:
                                  ITEXT_FONT_BOLD);
         //
         airBytes = 'Praying Mantis with Word Wrap';
         airParagraph = AirPdf_newParagraph(airBytes:
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         ITextDocument_add(airDocument: airNewLine);
         //
         airBytes = 'RPG, iText, PDFs, Java, ';
         airPhrase = AirPdf_newPhrase(airBytes);
         airImage = AirPdf_getImage(airImageName);
         airAlignment = %bitor(ITEXT_IMAGE_ALIGN_LEFT: ITEXT_IMAGE_TEXTWRAP);
         ITextImage_setAlignment(airImage: airAlignment);
         ITextImage_scalePercent(airImage: 75);
         ITextDocument_add(airDocument: airImage);
         // Do is not allowed in free-format; use For instead.
         for i=0 to 51;
           ITextDocument_add(airDocument: airPhrase);
         endfor;
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
