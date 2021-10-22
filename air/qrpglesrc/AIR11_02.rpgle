     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Creating Tables
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR11_02) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR11_02)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR11_02)
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
     D  airFontHead    S                   like(ITextFont)
     D  airNewLine     S                   like(ITextChunk)
     D  airTable       S                   like(PdfPTable)
     D  airCell        S                   like(PdfPCell)
     D  i              S              3S 0
     C/EJECT
      /free
         CallP JavaServiceProgram();
         //
         airString = new_String(EBCDIC_CR + EBCDIC_LF);
         airNewLine = new_ITextChunk(airString);
         airFileName = '/Public/Air11_02.pdf';
         airDocument = AirPdf_newDocumentOutput(airFileName:'LETTER');
         airString = new_String(%trim(airFileName));
         //
         airFontHead = new_ITextFont(ITEXT_FONT_HELVETICA: 15:
                                  ITEXT_FONT_BOLD);
         //--------------------------------------------------------------
         airParagraph = AirPdf_newParagraph('Pdf Tables':
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         ITextDocument_add(airDocument: airNewLine);
         //
         airParagraph = AirPdf_newParagraph('Favorites');
         airTable = new_PdfPTable(4);
         airCell = new_PdfPCellFromPhrase(airParagraph);
         PdfPCell_setColSpan(airCell: 4);
         PdfPTable_addCell(airTable: airCell);
         AirPdf_addTableStringCell(airTable: 'Piggy Bank');
         AirPdf_addTableStringCell(airTable: 'Butterfly');
         AirPdf_addTableStringCell(airTable: 'Mario');
         AirPdf_addTableStringCell(airTable: 'Purple');
         AirPdf_addTableStringCell(airTable: 'Bakugan');
         AirPdf_addTableStringCell(airTable: 'Puppy');
         AirPdf_addTableStringCell(airTable: 'Princess');
         AirPdf_addTableStringCell(airTable: 'Pizza');
         ITextDocument_add(airDocument: airTable);
         //--------------------------------------------------------------
         ITextDocument_close(airDocument);
         // Clean Up
         freeLocalRef(airNewLine);
         freeLocalRef(airString);
         freeLocalRef(airFontHead);
         freeLocalRef(airParagraph);
         freeLocalRef(airDocument);
         freeLocalRef(airTable);
         freeLocalRef(airCell);
         *inlr = *ON;
      /end-free
