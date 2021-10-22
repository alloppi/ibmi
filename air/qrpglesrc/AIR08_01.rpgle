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
     F* Fonts and Colors
     F**********************************************************************
     F*   HOW TO COMPILE:
     F*
     F*   (1. CREATE THE MODULE)
     F*   CRTRPGMOD MODULE(AIRLIB/AIR08_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL)
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR08_01)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREXCEL) ACTGRP(AIR08_01)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D  airWorkBook    S                   LIKE(HSSFWorkbook)
     D  airSheet       S                   LIKE(HSSFSheet)
     D  airRow         S                   LIKE(HSSFRow)
     D  airCell        S                   LIKE(HSSFCell)
     D  airFontHeight  S                   LIKE(jShort)
     D  airFontNorm    S                   LIKE(HSSFFont)
     D  airFontWhite   S                   LIKE(HSSFFont)
     D  airStyleNorm   S                   LIKE(HSSFCellStyle)
     D  airStyleBW     S                   LIKE(HSSFCellStyle)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         JNIEnv_P = getJNIEnv();
         airWorkbook = new_HSSFWorkbook();
         airSheet = AirExcel_getSheet(airWorkbook: 'Report');
         // Create Fonts
         airFontHeight = 8;
         // Normal Font
         airFontNorm = HSSFWorkbook_createFont(airWorkbook);
         HSSFFont_setFontHeightInPoints(airFontNorm: airFontHeight);
         // White, Bold Font
         airFontWhite = HSSFWorkbook_createFont(airWorkbook);
         HSSFFont_setFontHeightInPoints(airFontWhite: airFontHeight);
         HSSFFont_setBoldWeight(airFontWhite: POI_FONT_BOLD_BOLD);
         HSSFFont_setColor(airFontWhite: POI_WHITE);
         // Create Styles
         airStyleNorm = HSSFWorkbook_createCellStyle(airWorkbook);
         HSSFCellStyle_setFont(airStyleNorm: airFontNorm);
         HSSFCellStyle_setAlignment(airStyleNorm: POI_ALIGN_LEFT);
         //
         airStyleBW = HSSFWorkbook_createCellStyle(airWorkbook);
         HSSFCellStyle_setFont(airStyleBW: airFontWhite);
         HSSFCellStyle_setFillForegroundColor(airStyleBW:
                               POI_BLUE);
         HSSFCellStyle_setFillPattern(airStyleBW:
                               POI_SOLID_FOREGROUND);

         // Create Cells
         airRow = AirExcel_getRow(airSheet:0);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Color': airStyleBW);
         airCell = AirExcel_getCell(airRow:1);
         AirExcel_setCellValueString(airCell:'Code': airStyleBW);
         //
         airRow = AirExcel_getRow(airSheet:1);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Automatic': airStyleNorm);
         airCell = AirExcel_getCell(airRow:1);
         AirExcel_setCellValueNumeric(airCell:POI_AUTO: airStyleNorm);
         //
         airRow = AirExcel_getRow(airSheet:2);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Aqua':airStyleNorm);
         airCell = AirExcel_getCell(airRow:1);
         AirExcel_setCellValueNumeric(airCell:POI_AQUA:airStyleNorm);
         //
         airRow = AirExcel_getRow(airSheet:3);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Black':airStyleNorm);
         airCell = AirExcel_getCell(airRow:1);
         AirExcel_setCellValueNumeric(airCell:POI_BLACK:airStyleNorm);
         //*** Close the Spreadsheet and Reclaim Resources
         AirExcel_write(airWorkbook:
                       '/Public/Air08_01.xls');
         // Clean Up
         freeLocalRef(airCell);
         freeLocalRef(airRow);
         freeLocalRef(airSheet);
         freeLocalRef(airWorkbook);
         freeLocalRef(airStyleNorm);
         freeLocalRef(airStyleBW);
         *inlr = *ON;
      /end-free
