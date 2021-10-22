     H THREAD(*SERIALIZE) INDENT('.')
     F**********************************************************************
     F* Excel Chart
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR09_03) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL)
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR09_03)
     F*     BNDSRVPGM(SVAIRJAVA SVAIRJDBC) ACTGRP(AIR09_03)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D  airWorkbook    S                   LIKE(HSSFWorkBook)
     D  airSheet       S                   LIKE(HSSFSheet)
     D  airRow         S                   LIKE(HSSFRow)
     D  airCell        S                   LIKE(HSSFCell)
     D  inFileName     S           2000A
     D  outFileName    S           2000A
     D  jvString       S                   LIKE(jString)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         inFileName = '/Public/'
                    + 'Air09_03_Template.xlt';
         outFileName = '/Public/'
                     + 'Air09_03.xls';
         airWorkbook = AirExcel_open(%TRIM(inFileName));
         airSheet = AirExcel_getSheet(airWorkbook: 'Data');
         // Decrease by 20
         airRow = AirExcel_getRow(airSheet:3);
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellValueNumeric(airCell: 1.29);
         // Increase by 20
         airRow = AirExcel_getRow(airSheet:4);
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellValueNumeric(airCell: 39.48);
         //*** Close the Spreadsheet and Reclaim Resources
         AirExcel_write(airWorkbook: %TRIM(outFileName));
         // Clean Up
         freeLocalRef(jvString);
         freeLocalRef(airCell);
         freeLocalRef(airRow);
         freeLocalRef(airSheet);
         freeLocalRef(airWorkbook);
         *inlr = *ON;
      /end-free
