     H THREAD(*SERIALIZE) INDENT('.')
     F**********************************************************************
     F* Column Width and Word Wrap
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR08_03) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL)
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR08_03)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREXCEL) ACTGRP(AIR08_03)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRFUNC
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D  airWorkBook    S                   LIKE(HSSFWorkbook)
     D  airSheet       S                   LIKE(HSSFSheet)
     D  airRow         S                   LIKE(HSSFRow)
     D  airCell        S                   LIKE(HSSFCell)
     D  airStyleWrap   S                   LIKE(HSSFCellStyle)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         JNIEnv_P = getJNIEnv();
         airWorkbook = new_HSSFWorkbook();
         airSheet = AirExcel_getSheet(airWorkbook: 'Report');
         // Set Column Widths
         HSSFSheet_setColumnWidth(airSheet: 0: 6000);
         HSSFSheet_setColumnWidth(airSheet: 1: 2000);
         // Cell Style for Date Formatting
         airStyleWrap = HSSFWorkbook_createCellStyle(airWorkbook);
         HSSFCellStyle_setWrapText(airStyleWrap: *ON);
         // Create Cells
         airRow = AirExcel_getRow(airSheet:0);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Column Width and Wrap');
         airCell = AirExcel_getCell(airRow:1);
         AirExcel_setCellValueString(airCell:'Column Width and Wrap');
         airCell = AirExcel_getCell(airRow:2);
         AirExcel_setCellValueString(airCell:'Column C');
         // Word Wrapping
         airRow = AirExcel_getRow(airSheet:2);
         airCell = AirExcel_getCell(airRow:0);
         HSSFCell_setCellStyle(airCell: airStyleWrap);
         AirExcel_setCellValueString(airCell:
           'Here is a cell with a lot of text' +
           EBCDIC_LF + 'and a new line.');
         // Second Column without wrap
         airCell = AirExcel_getCell(airRow:1);
         AirExcel_setCellValueString(airCell:
           'Here is a another cell with a lot of text' +
           EBCDIC_LF + 'and a new line.');
         airCell = AirExcel_getCell(airRow:2);
         AirExcel_setCellValueString(airCell:'Column C');
         //*** Close the Spreadsheet and Reclaim Resources
         AirExcel_write(airWorkbook:
                       '/Public/Air08_03.xls');
         // Clean Up
         freeLocalRef(airCell);
         freeLocalRef(airRow);
         freeLocalRef(airSheet);
         freeLocalRef(airWorkbook);
         freeLocalRef(airStyleWrap);
         *inlr = *ON;
      /end-free
