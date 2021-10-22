     H THREAD(*SERIALIZE) INDENT('.')
     F**********************************************************************
     F* Header and Footers
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR08_05) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL)
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR08_05)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREXCEL) ACTGRP(AIR08_05)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRFUNC
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D                SDS
     D  QPGM                   1     10
     D  QUSER                254    263
     D  QDATE                276    281
     D  QTIME                282    287  0
     D  QCUSER               358    367
     D*
     D  airAlign       S                   like(jShort)
     D  airDateBytes   S            256A   varying
     D  airPageBytes   S            256A   varying
     D  airNumPageBytes...
     D                 S            256A   varying
     D  airString      S                   like(jString)
     D  airDate        S                   like(JavaDate)
     D  airWorkBook    S                   like(HSSFWorkbook)
     D  airSheet       S                   like(HSSFSheet)
     D  airRow         S                   like(HSSFRow)
     D  airCell        S                   like(HSSFCell)
     D  airStyleDate   S                   like(HSSFCellStyle)
     C/EJECT
      /free
         CallP JavaServiceProgram();
         JNIEnv_P = getJNIEnv();
         airWorkbook = new_HSSFWorkbook();
         airSheet = AirExcel_getSheet(airWorkbook: 'Report');
         // Set Column Widths
         HSSFSheet_setColumnWidth(airSheet: 0: 4000);
         HSSFSheet_setColumnWidth(airSheet: 1: 4000);
         // Cell Style for Date Formatting
         airDate = new_Date();
         airStyleDate = HSSFWorkbook_createCellStyle(airWorkbook);
         AirExcel_setCellStyleDataFormat(airStyleDate:'m/d/yy h:mm');
         airDateBytes = Air_getDateBytes(airDate:
                               DATE_FORMAT_SHORT:
                               DATE_FORMAT_SHORT);
         // Create Headers
         airAlign = POI_ALIGN_LEFT;
         AirExcel_setHeader(airSheet:
                            %trim(QPGM) + ' - Headers and Footers':
                            airAlign);
         airAlign = POI_ALIGN_RIGHT;
         AirExcel_setHeader(airSheet:
                           'Created on ' + airDateBytes:
                            airAlign);
         // Create Footers
         airAlign = POI_ALIGN_LEFT;
         AirExcel_setFooter(airSheet:
                           'User: ' + %trim(QCUSER):
                            airAlign);
         airAlign = POI_ALIGN_RIGHT;
         airString = HSSFFooter_page();
         airPageBytes = String_getBytes(airString);
         airString = HSSFFooter_numPages();
         airNumPageBytes = String_getBytes(airString);
         AirExcel_setFooter(airSheet:
                           'Page ' + %trim(airPageBytes) +
                           ' of '  + %trim(airNumPageBytes):
                            airAlign);
         // Create Cells
         airRow = AirExcel_getRow(airSheet:0);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Headers and Footers');
         // Date
         airRow = AirExcel_getRow(airSheet:2);
         airCell = AirExcel_getCell(airRow:0);
         AirExcel_setCellValueString(airCell:'Date:');
         airCell = AirExcel_getCell(airRow:1);
         HSSFCell_setCellValueDate(airCell: airDate);
         HSSFCell_setCellStyle(airCell: airStyleDate);
         //*** Close the Spreadsheet and Reclaim Resources
         AirExcel_write(airWorkbook:
                       '/Public/Air08_05.xls');
         // Clean Up
         freeLocalRef(airCell);
         freeLocalRef(airRow);
         freeLocalRef(airSheet);
         freeLocalRef(airWorkbook);
         freeLocalRef(airStyleDate);
         *inlr = *ON;
      /end-free
