     H THREAD(*SERIALIZE) INDENT('.')
     F**********************************************************************
     F* Formulas
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR09_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL)
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR09_01)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREXCEL) ACTGRP(AIR09_01)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D  airWorkBook    S                   LIKE(HSSFWorkbook)
     D  airSheet       S                   LIKE(HSSFSheet)
     D  airRow         S                   LIKE(HSSFRow)
     D  airCell        S                   LIKE(HSSFCell)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         airWorkbook = new_HSSFWorkbook();
         airSheet = AirExcel_getSheet(airWorkbook: 'Report');
         // Create Cells
         airRow = AirExcel_getRow(airSheet:0);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Formulas');
         // Assign Numeric Values
         airRow = AirExcel_getRow(airSheet:2);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Addition:');
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellValueNumeric(airCell: -812);
         //
         airRow = AirExcel_getRow(airSheet:3);
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellValueNumeric(airCell: 1114);
         //
         airRow = AirExcel_getRow(airSheet:4);
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellValueNumeric(airCell: -621);
         //
         airRow = AirExcel_getRow(airSheet:5);
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellValueNumeric(airCell: 128);
         // Create Sum Formula
         airRow = AirExcel_getRow(airSheet:6);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Total:');
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellFormula(airCell:
                                 new_String('SUM(B3:B6)'));
         airCell = AirExcel_getCell(airRow:2);
         HSSFCell_setCellFormula(airCell:
                  new_String('IF(B7<0;"Negative";"Positive")'));
         // Create Max Formula
         airRow = AirExcel_getRow(airSheet:8);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Max:');
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellFormula(airCell:
                                 new_String('MAX(B3:B6)'));
         airCell = AirExcel_getCell(airRow:2);
         HSSFCell_setCellFormula(airCell:
                  new_String('IF(B9<0;"Negative";"Positive")'));
         //*** Close the Spreadsheet and Reclaim Resources
         AirExcel_write(airWorkbook:
                       '/Public/Air09_01.xls');
         // Clean Up
         freeLocalRef(airCell);
         freeLocalRef(airRow);
         freeLocalRef(airSheet);
         freeLocalRef(airWorkbook);
         *inlr = *ON;
      /end-free
