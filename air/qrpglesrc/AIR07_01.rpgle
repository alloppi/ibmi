     H THREAD(*SERIALIZE) INDENT('.')
     F* ====================================================================
     F* ============== Advanced Integrated RPG by Tom Snyder ===============
     F* ====================================================================
     F* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     F* All rights reserved.
     F*
     F* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     F* Author URL:    http://www.2WolvesOut.com
     F**********************************************************************
     F* Creating a New Spreadsheet
     F**********************************************************************
     F*   HOW TO COMPILE:
     F*
     F*   (1. CREATE THE MODULE)
     F*   CRTRPGMOD MODULE(AIRLIB/AIR07_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL)
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR07_01)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREXCEL) ACTGRP(AIR07_01)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D  airWorkbook    S                   LIKE(HSSFWorkbook)
     D  airSheet       S                   LIKE(HSSFSheet)
     D  airRow         S                   LIKE(HSSFRow)
     D  airCell        S                   LIKE(HSSFCell)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         JNIEnv_P = getJNIEnv();
         airWorkbook = new_HSSFWorkbook();
         airSheet = AirExcel_getSheet(airWorkbook: 'Report');
         airRow = AirExcel_getRow(airSheet:1);
         airCell = AirExcel_getCell(airRow:1);
         AirExcel_setCellValueString(airCell:'Hello World');
         //*** Close the Spreadsheet and Reclaim Resources
         AirExcel_write(airWorkbook:
                       '/Public/Air07_01.xls');
         // Clean Up
         freeLocalRef(airCell);
         freeLocalRef(airRow);
         freeLocalRef(airSheet);
         freeLocalRef(airWorkbook);
         *inlr = *ON;
      /end-free
