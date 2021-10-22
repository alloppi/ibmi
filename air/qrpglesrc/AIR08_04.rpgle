     H THREAD(*SERIALIZE) INDENT('.')
     F**********************************************************************
     F* Print Setup and Sheet Settings
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR08_04) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL)
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR08_04)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREXCEL) ACTGRP(AIR08_04)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D  airDate        S                   LIKE(JavaDate)
     D  airWorkBook    S                   LIKE(HSSFWorkbook)
     D  airSheet       S                   LIKE(HSSFSheet)
     D  airRow         S                   LIKE(HSSFRow)
     D  airCell        S                   LIKE(HSSFCell)
     D  airStyleDate   S                   LIKE(HSSFCellStyle)
     D  airPrintSetup  S                   LIKE(HSSFPrintSetup)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         JNIEnv_P = getJNIEnv();
         airWorkbook = new_HSSFWorkbook();
         airSheet = AirExcel_getSheet(airWorkbook: 'Report');
         // Set Column Widths
         HSSFSheet_setColumnWidth(airSheet: 0: 4000);
         HSSFSheet_setColumnWidth(airSheet: 1: 4000);
         // Print Gridlines
         HSSFSheet_setPrintGridlines(airSheet: *ON);
         // Zoom in to 200%
         HSSFSheet_setZoom(airSheet: 2: 1);
         // Set to Landscape
         airPrintSetup = HSSFSheet_getPrintSetup(airSheet);
         HSSFPrintSetup_setLandscape(airPrintSetup: *ON);
         // Cell Style for Date Formatting
         airDate = new_Date();
         airStyleDate = HSSFWorkbook_createCellStyle(airWorkbook);
         AirExcel_setCellStyleDataFormat(airStyleDate:'m/d/yy h:mm');
         // Create Cells
         airRow = AirExcel_getRow(airSheet:0);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Page Orientation');
         // Date
         airRow = AirExcel_getRow(airSheet:2);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Date:');
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellValueDate(airCell: airDate);
         HSSFCell_setCellStyle(airCell: airStyleDate);
         //*** Close the Spreadsheet and Reclaim Resources
         AirExcel_write(airWorkbook:
                       '/Public/Air08_04.xls');
         // Clean Up
         freeLocalRef(airCell);
         freeLocalRef(airRow);
         freeLocalRef(airSheet);
         freeLocalRef(airWorkbook);
         freeLocalRef(airStyleDate);
         *inlr = *ON;
      /end-free
