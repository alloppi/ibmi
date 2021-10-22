     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Pdf Lists
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR11_04) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR11_04)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR11_04)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRFUNC
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIRPDF
     D  airFileName    S           1024A   varying
     D  airString      S                   like(jString)
     D  airDocument    S                   like(ITextDocument)
     D  airParagraph   S                   like(ITextParagraph)
     D  airList        S                   like(ITextList)
     D  airFontHead    S                   like(ITextFont)
     D  airNewLine     S                   like(ITextChunk)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         airFileName = '/Public/Air11_04.pdf';
         airDocument = AirPdf_newDocumentOutput(airFileName:'LETTER');
         airString = new_String(EBCDIC_CR + EBCDIC_LF);
         airNewLine = new_ITextChunk(airString);
         //
         airFontHead = new_ITextFont(ITEXT_FONT_HELVETICA: 15:
                                  ITEXT_FONT_BOLD);
         //
         airParagraph = AirPdf_newParagraph('Unordered List':
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         airList = new_ITextList(ITEXT_LIST_UNORDERED);
         airString = new_String('iSeries');
         ITextList_add(airList: airString);
         airString = new_String('AS/400');
         ITextList_add(airList: airString);
         airString = new_String('IBM i');
         ITextList_add(airList: airString);
         ITextDocument_add(airDocument: airList);
         //
         ITextDocument_add(airDocument: airNewLine);
         //
         airParagraph = AirPdf_newParagraph('Ordered List':
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         airList = new_ITextList(ITEXT_LIST_ORDERED);
         airString = new_String('Personal Communications');
         ITextList_add(airList: airString);
         airString = new_String('Client Access');
         ITextList_add(airList: airString);
         airString = new_String('iSeries Access');
         ITextList_add(airList: airString);
         ITextDocument_add(airDocument: airList);
         //
         ITextDocument_close(airDocument);
         // Clean Up
         freeLocalRef(airNewLine);
         freeLocalRef(airFontHead);
         freeLocalRef(airList);
         freeLocalRef(airParagraph);
         freeLocalRef(airDocument);
         *inlr = *ON;
      /end-free
