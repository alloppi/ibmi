     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Setting the Metadata
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR10_02) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR10_02)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR10_02)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIRPDF
     D  airDocument    S                   LIKE(ITextDocument)
     D  airParagraph   S                   LIKE(ITextParagraph)
     D  airMessage     S           1024A   VARYING
     D  airFileName    S           1024A   VARYING
     C/EJECT
      /free
         CallP JavaServiceProgram();
         JNIEnv_P = getJNIEnv();
         airFileName = '/Public/Air10_02.pdf';
         airDocument = AirPdf_newDocumentOutput(%trim(airFileName):'LETTER');
         airMessage = 'Look at Properties to see Metadata!';
         airParagraph = AirPdf_newParagraph(airMessage);
         ITextDocument_add(airDocument: airParagraph);
         AirPdf_addTitle(airDocument: 'RPG Metadata Example');
         AirPdf_addSubject(airDocument: 'Modifying Metadata');
         AirPdf_addKeywords(airDocument: 'iText, Metadata, RPG');
         AirPdf_addCreator(airDocument: 'My RPG Application');
         AirPdf_addAuthor(airDocument: 'Tom Snyder');
         ITextDocument_addCreationDate(airDocument);
         ITextDocument_close(airDocument);
         // Clean Up
         freeLocalRef(airDocument);
         *inlr = *ON;
      /end-free
