     H THREAD(*SERIALIZE)
     F**********************************************************************
     F* Creating a New PDF - Hello World
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR10_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR10_01)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRPDF) ACTGRP(AIR10_01)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIRPDF
     D  airDocument    S                   LIKE(ITextDocument)
     D  airParagraph   S                   LIKE(ITextParagraph)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         airDocument = AirPdf_newDocumentOutput(
                              '/Public/AIR10_01.pdf');
         airParagraph = AirPdf_newParagraph('Hello World!');
         ITextDocument_add(airDocument: airParagraph);
         ITextDocument_close(airDocument);
         // Clean Up
         freeLocalRef(airDocument);
         *inlr = *ON;
      /end-free
