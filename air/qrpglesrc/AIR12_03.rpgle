     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Creating Barcodes
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR12_03) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR12_03)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR12_03)
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
     D  airOutFile     S                   like(FileOutputStream)
     D  airDocument    S                   like(ITextDocument)
     D  airParagraph   S                   like(ITextParagraph)
     D  airPhrase      S                   like(ITextPhrase)
     D  airRectangle   S                   like(ITextRectangle)
     D  airFontHead    S                   like(ITextFont)
     D  airNewLine     S                   like(ITextChunk)
     D  airImage       S                   like(ITextImage)
     D  airBarcode     S                   like(ITextBarcodeEAN)
     D  airBarSUPP5    S                   like(ITextBarcodeEAN)
     D  airBarCodeTotal...
     D                 S                   like(ITextBarcodeEANSUPP)
     D  airWriter      S                   like(PdfWriter)
     D  airContentByte...
     D                 S                   like(PdfContentByte)
     D  i              S              3S 0
     C/EJECT
      /free
         CallP JavaServiceProgram();
         //
         airString = new_String(EBCDIC_CR + EBCDIC_LF);
         airNewLine = new_ITextChunk(airString);
         airFileName = '/Public/Air12_03.pdf';
         airImageName = '/Public/mantis.png';
         // airDocument = AirPdf_newDocumentOutput(airFileName:'LETTER');
         airString = new_String(%trim('LETTER'));
         monitor;
           airRectangle = PageSize_getRectangle(airString);
           airDocument = new_ITextDocumentFromRectangle(airRectangle);
         on-error;
           airDocument = *NULL;
         endmon;
         airString = new_String(%trim(airFileName));
         monitor;
           airOutFile = new_FileOutputStream(airString);
           // HERE is where you get the PdfWriter
           airWriter = AirPdf_setPdfWriter(airDocument: airOutFile);
           ITextDocument_open(airDocument);
           airContentByte = PdfWriter_getDirectContent(airWriter);
         on-error;
           airDocument = *NULL;
         endmon;
         //
         airFontHead = new_ITextFont(ITEXT_FONT_HELVETICA: 15:
                                  ITEXT_FONT_BOLD);
         //--------------------------------------------------------------
         //-------- EAN-13 NO GUARDS AND IN COLOR -----------------------
         //--------------------------------------------------------------
         airBytes = 'EAN-13 Barcode (No Guards): 0112358132134';
         airParagraph = AirPdf_newParagraph(airBytes:
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         airBytes = 'Green Barcode with Blue Text';
         airParagraph = AirPdf_newParagraph(airBytes:
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         ITextDocument_add(airDocument: airNewLine);
         //
         airBarcode = new_ITextBarcodeEAN();
         AirPdf_setBarcodeEANCode(airBarcode: '0112358132134': *OFF);
         // HERE is where you use the contentByte from the PdfWriter
         airImage = AirPdf_getBarcodeImage(airBarCode:
                                           airContentByte:
                                           COLOR_SEA_GREEN:
                                           COLOR_CORNFLOWER_BLUE);
         ITextDocument_add(airDocument: airImage);
         //--------------------------------------------------------------
         //-------- EAN-13 WITH GUARDS AND SUPP5 ------------------------
         //--------------------------------------------------------------
         airBytes = 'EAN-13 Barcode (With Guards): 0112358132134';
         airParagraph = AirPdf_newParagraph(airBytes:
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         airBytes = 'With Supplemental 5: 65777';
         airParagraph = AirPdf_newParagraph(airBytes:
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         ITextDocument_add(airDocument: airNewLine);
         //
         airBarcode = new_ITextBarcodeEAN();
         AirPdf_setBarcodeEANCode(airBarcode: '0112358132134': *ON);
         airBarSUPP5 = new_ITextBarcodeEAN();
         ITextBarcodeEAN_setCodeType(airBarSUPP5: ITEXT_BARCODE_SUPP5);
         AirPdf_setBarcodeEANCode(airBarSUPP5: '65777': *ON);
         ITextBarcodeEAN_setBaseLine(airBarSUPP5: -2);
         airBarCodeTotal = new_ITextBarcodeEANSUPP(airBarcode:
                                                   airBarSUPP5);
         airImage = AirPdf_getBarcodeImage(airBarCodeTotal:
                                           airContentByte);
         ITextDocument_add(airDocument: airImage);
         //--------------------------------------------------------------
         //----------------- UPC-A BARCODE ------------------------------
         //--------------------------------------------------------------
         airBytes = 'UPC-A Barcode: 123456789012';
         airParagraph = AirPdf_newParagraph(airBytes:
                                            airFontHead);
         ITextDocument_add(airDocument: airParagraph);
         //
         ITextDocument_add(airDocument: airNewLine);
         //
         airBarcode = new_ITextBarcodeEAN();
         AirPdf_setBarcodeEANCode(airBarcode: '123456789012');
         ITextBarcodeEAN_setCodeType(airBarCode: ITEXT_BARCODE_UPCA);
         airImage = AirPdf_getBarcodeImage(airBarCode:
                                           airContentByte);
         ITextDocument_add(airDocument: airImage);
         //--------------------------------------------------------------
         ITextDocument_close(airDocument);
         // Clean Up
         freeLocalRef(airNewLine);
         freeLocalRef(airString);
         freeLocalRef(airFontHead);
         freeLocalRef(airImage);
         freeLocalRef(airParagraph);
         freeLocalRef(airDocument);
         freeLocalRef(airPhrase);
         freeLocalRef(airRectangle);
         freeLocalRef(airOutFile);
         freeLocalRef(airBarCode);
         freeLocalRef(airBarSUPP5);
         freeLocalRef(airBarCodeTotal);
         freeLocalRef(airWriter);
         freeLocalRef(airContentByte);
         *inlr = *ON;
      /end-free
