     H THREAD(*SERIALIZE) INDENT('.')
     F**********************************************************************
     F* Reading an Existing Spreadsheet
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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR09_02) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL)
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR09_02)
     F*     BNDSRVPGM(SVAIRJAVA SVAIREXCEL) ACTGRP(AIR09_02)
     D********************************************************************
     D/DEFINE OS400_JVM_12
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D displayString   S             52A
     D airBytes        S             52A
     D airInt          S                   like(jInt)
     D airDouble       S                   like(jDouble)
     D airWorkbook     S                   like(HSSFWorkbook)
     D airSheet        S                   like(HSSFSheet)
     D airRow          S                   like(HSSFRow)
     D airCell         S                   like(HSSFCell)
     D airString       S                   like(jString)
     D airNumberRows   S                   like(jInt)
     D airNumberCells  S                   like(jInt)
     D airLastRow      S                   like(jInt)
     D airRowNum       S                   like(jInt)
     D airCellNum      S                   like(jInt)
     D airRowIterator...
     D                 S                   like(Iterator)
     D airCellIterator...
     D                 S                   like(Iterator)
     C/EJECT
      /free
        CallP JavaServiceProgram();
        airWorkbook = AirExcel_getWorkbook('/Public/Air09_01.xls');
        airString = HSSFWorkbook_getSheetName(airWorkbook: 0);
        airSheet = HSSFWorkbook_getSheetAt(airWorkbook: 0);
        airNumberRows = HSSFSheet_getPhysicalNumberOfRows(airSheet);
        airLastRow = HSSFSheet_getLastRowNum(airSheet);
        displayString = 'Last Row Number: '
                      + %trim(%editc(airLastRow:'3'));
        DSPLY displayString;
        airRowIterator = HSSFSheet_rowIterator(airSheet);
        if airRowIterator = *NULL;
        else;
          dow Iterator_hasNext(airRowIterator);
            airRow = Iterator_next(airRowIterator);
            airRowNum = HSSFRow_getRowNum(airRow);
            airNumberCells = HSSFRow_getPhysicalNumberOfCells(airRow);
            displayString = '----- Row: '
                          + %trim(%editc(airRowNum:'3'))
                          + ' has '
                          + %trim(%editc(airNumberCells:'3'))
                          + ' Columns -----';
            DSPLY displayString;
            airCellIterator = HSSFRow_cellIterator(airRow);
            dow Iterator_hasNext(airCellIterator);
              airCell = Iterator_next(airCellIterator);
              airCellNum = HSSFCell_getCellNum(airCell);
              airInt = HSSFCell_getCellType(airCell);
              displayString = 'Cell ('
                       + %trim(%editc(airRowNum:'3'))
                       + ', '
                       + %trim(%editc(airCellNum:'3'))
                       + ')'
                       + ' - Type: '
                       + %trim(%editc(airInt:'3'));
              select;
              //--------------------------------------------------
              when airInt = POI_CELL_TYPE_BLANK;
                displayString = %trim(displayString)
                              + ', Blank';
                DSPLY displayString;
                airString = HSSFCell_getStringCellValue(airCell);
                airBytes = String_getBytes(airString);
                displayString = %trim(airBytes);
              //--------------------------------------------------
              when airInt = POI_CELL_TYPE_BOOLEAN;
                displayString = %trim(displayString)
                              + ', Boolean';
                DSPLY displayString;
                if HSSFCell_getBooleanCellValue(airCell);
                  displayString = 'True';
                else;
                  displayString = 'False';
                endif;
              //--------------------------------------------------
              when airInt = POI_CELL_TYPE_FORMULA;
                displayString = %trim(displayString)
                              + ', Formula';
                DSPLY displayString;
                airString = HSSFCell_getCellFormula(airCell);
                airBytes = String_getBytes(airString);
                displayString = 'Value: ' + %trim(airBytes);
              //--------------------------------------------------
              when airInt = POI_CELL_TYPE_NUMERIC;
                displayString = %trim(displayString)
                              + ', Numeric';
                DSPLY displayString;
                airDouble = HSSFCell_getNumericCellValue(airCell);
                airInt = airDouble;
                airBytes = %trim(%editc(airInt:'3'));
                displayString = 'Value: ' + %trim(airBytes);
              //--------------------------------------------------
              when airInt = POI_CELL_TYPE_STRING;
                displayString = %trim(displayString)
                              + ', String';
                DSPLY displayString;
                airString = HSSFCell_getStringCellValue(airCell);
                airBytes = String_getBytes(airString);
                displayString = 'Value: ' + %trim(airBytes);
              //--------------------------------------------------
              other;
                displayString = %trim(displayString)
                              + ', Unsupported';
              endsl;
              DSPLY displayString;
            enddo;
          enddo;
        endif;
        // Clean Up
        freeLocalRef(airSheet);
        freeLocalRef(airWorkbook);
        *inlr = *ON;
      /end-free
