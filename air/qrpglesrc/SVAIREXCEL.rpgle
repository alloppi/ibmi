     H NOMAIN THREAD(*SERIALIZE) OPTION(*NODEBUGIO: *SRCSTMT: *NOSHOWCPY)
     D**********************************************************************
     D* POI Excel Service Program
     D**********************************************************************
     D* ====================================================================
     D* ============== Advanced Integrated RPG by Tom Snyder ===============
     D* ====================================================================
     D* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     D* All rights reserved.
     D*
     D* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     D* Author URL:    http://www.2WolvesOut.com
     D*
     D* Source code/material located at http://www.mc-store.com/5105.html
     D* On the books page, click the reviews, errata, downloads icon to go
     D* to the books forum.  This source code may not be hosted on any
     D* other site without my express, prior, written permission.
     D*
     D* I disclaim any and all responsibility for any loss, damage or
     D* destruction of data or any other property which may arise using
     D* this code. I will in no case be liable for any monetary damages
     D* arising from such loss, damage or destruction.
     D*
     D* This code is intended for educational purposes, which includes
     D* minimal exception handling to focus on the topic being discussed.
     D* You may want to implement additional exception handling to prepare
     D* for a production environment.
     D*
     D* Happy Coding!
     D**********************************************************************
     D* Utility routines for working with HSSF to create Excel
     D* spreadsheets from ILE RPG.
     D* Official POI Website:
     D*   http://poi.apache.org/
     D**********************************************************************
     D*   HOW TO COMPILE:
     D*
     D*   (1. CREATE THE MODULE)
     D*   CRTRPGMOD MODULE(AIRLIB/SVAIREXCEL) SRCFILE(AIRLIB/AIRSRC) +
     D*             DBGVIEW(*ALL) INDENT('.')
     D*
     D*   (2. CREATE THE SERVICE PROGRAM)
     D*   CRTSRVPGM SRVPGM(AIRLIB/SVAIREXCEL) EXPORT(*ALL)
     D*   BNDSRVPGM(SVAIRJAVA) ACTGRP(SVAIREXCEL)
     D**********************************************************************
     D*** PROTOTYPES ***
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIREXCEL
     D**********************************************************************
     D*  AirExcel_getWorkbook(): Gets a HSSFWorkbook object.
     D**********************************************************************
     P AirExcel_getWorkbook...
     P                 B                   EXPORT
     D AirExcel_getWorkbook...
     D                 PI                  like(HSSFWorkbook)
     D  argFileName                1024A   const varying
     D                                     options(*noPass: *omit)
     D svString        s                   like(jString)
     D svInFile        s                   like(FileInputStream)
     D svPOIFS         s                   like(POIFSFileSystem)
     D svWorkBook      s                   like(HSSFWorkbook)
     D                                     inz(*NULL)
      /free
        if %parms < 1;
          svString = *NULL;
        else;
          if argFileName = *BLANKS;
            svString = *NULL;
          else;
            svString = new_String(argFilename);
          endif;
        endif;
        if svString = *NULL;
          // No Input Name specified; New Spreadsheet
          svWorkBook = new_HSSFWorkbook();
        else;
          // Input Name specified; Open Existing Spreadsheet
          svInFile = new_FileInputStream(svString);
          svPOIFS  = new_POIFSFileSystem(svInFile);
          svWorkBook = new_HSSFWorkbookFromPOIFS(svPOIFS);
          if (svInFile = *NULL);
          else;
            FileInputStream_close(svInFile);
          endif;
        endif;
        freeLocalRef(svPOIFS);
        freeLocalRef(svInFile);
        freeLocalRef(svString);
        return svWorkBook;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirExcel_open(): Opens an existing HSSFWorkbook object.
     D**********************************************************************
     P AirExcel_open...
     P                 B                   EXPORT
     D AirExcel_open...
     D                 PI                  like(HSSFWorkbook)
     D  argFileName                1024A   const varying
     D svString        s                   like(jString)
     D svInFile        s                   like(FileInputStream)
     D svPOIFS         s                   like(POIFSFileSystem)
     D svWorkBook      s                   like(HSSFWorkbook)
      /free
        svString = new_String(argFilename);
        svInFile = new_FileInputStream(svString);
        svPOIFS  = new_POIFSFileSystem(svInFile);
        svWorkBook = new_HSSFWorkbookFromPOIFS(svPOIFS);
        if (svInFile = *NULL);
        else;
          FileInputStream_close(svInFile);
        endif;
        freeLocalRef(svPOIFS);
        freeLocalRef(svInFile);
        freeLocalRef(svString);
        return svWorkBook;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirExcel_getSheet(): Retrieves the HSSFSheet
     D*                       with the specified name.
     D**********************************************************************
     P AirExcel_getSheet...
     P                 B                   EXPORT
     D AirExcel_getSheet...
     D                 PI                  like(HSSFSheet)
     D  argWorkBook                        like(HSSFWorkbook)
     D  argSheetName               1024A   varying const
     D svString        S                   like(jString)
     D svSheet         S                   like(HSSFSheet)
     D                                     inz(*NULL)
      /free
         svString = new_String(argSheetName);
         svSheet = HSSFWorkbook_getSheet(argWorkbook: svString);
         if svSheet = *NULL;
           svSheet = HSSFWorkbook_createSheet(argWorkbook: svString);
         else;
         endif;
         freeLocalRef(svString);
         return svSheet;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirExcel_getRow(): Retrieves the HSSFRow
     D*                       with the specified index.
     D**********************************************************************
     P AirExcel_getRow...
     P                 B                   EXPORT
     D AirExcel_getRow...
     D                 PI                  like(HSSFRow)
     D  argSheet                           like(HSSFSheet)
     D  argIndex                           like(jInt) value
     D svRow           S                   like(HSSFRow)
     D                                     inz(*NULL)
      /free
         svRow = HSSFSheet_getRow(argSheet: argIndex);
         if svRow = *NULL;
           svRow = HSSFSheet_createRow(argSheet: argIndex);
         else;
         endif;
         return svRow;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirExcel_getCell(): Retrieves the HSSFCell from the Row
     D*                       with the specified index.
     D**********************************************************************
     P AirExcel_getCell...
     P                 B                   EXPORT
     D AirExcel_getCell...
     D                 PI                  like(HSSFCell)
     D  argRow                             like(HSSFRow)
     D  argIndex                           like(jInt) value
     D svCell          S                   like(HSSFCell)
     D                                     inz(*NULL)
      /free
         svCell = HSSFRow_getCell(argRow: argIndex);
         if (svCell = *NULL);
           svCell = HSSFRow_createCell(argRow: argIndex);
         else;
         endif;
         return svCell;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirExcel_setCellValueString(): Sets the Cell Value to a String.
     D**********************************************************************
     P AirExcel_setCellValueString...
     P                 B                   EXPORT
     D AirExcel_setCellValueString...
     D                 PI
     D  argCell                            like(HSSFCell)
     D  argBytes                  65535A   varying const
     D  argStyle                           like(HSSFCellStyle)
     D                                     options(*nopass)
     D svRichString    s                   like(HSSFRichTextString)
      /free
         svRichString = new_HSSFRichTextString(new_String(argBytes));
         HSSFCell_setCellValueRichString(argCell: svRichString);
         if %parms > 2;
           HSSFCell_setCellStyle(argCell: argStyle);
         else;
         endif;
         freeLocalRef(svRichString);
         return;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirExcel_setCellValueNumeric() Sets the Cell Value.
     D**********************************************************************
     P AirExcel_setCellValueNumeric...
     P                 B                   EXPORT
     D AirExcel_setCellValueNumeric...
     D                 PI
     D  argCell                            like(HSSFCell)
     D  argNumber                          like(jDouble) value
     D  argStyle                           like(HSSFCellStyle)
     D                                     options(*nopass)
      /free
         HSSFCell_setCellValueNumeric(argCell: argNumber);
         if %parms > 2;
           HSSFCell_setCellStyle(argCell: argStyle);
         else;
         endif;
         return;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirExcel_write(): Saves the Spreadsheet.
     D**********************************************************************
     P AirExcel_write...
     P                 B                   EXPORT
     D AirExcel_write...
     D                 PI
     D   argWorkBook                       like(HSSFWorkbook)
     D   argFileName               1024A   const varying

     D svString        s                   like(jString)
     D svOutFile       s                   like(FileOutputStream)
      /free
         svString = new_String(argFileName);
         svOutFile = new_FileOutputStream(svString);
         HSSFWorkbook_write(argWorkBook: svOutFile);
         FileOutputStream_close(svOutFile);
         freeLocalRef(svOutFile);
         freeLocalRef(svString);
       return;
      /end-free
     P                 E
     D**********************************************************************
     D*  AirExcel_setHeader(): Sets the Header for the HSSFSheet
     D**********************************************************************
     P AirExcel_setHeader...
     P                 B                   EXPORT
     D AirExcel_setHeader...
     D                 PI
     D  argSheet                           like(HSSFSheet) const
     D  argBytes                   1024A   const varying options(*varsize)
     D  argAlignment                       like(jShort)  options(*noPass:*omit)
     D svHeader        S                   like(HSSFHeader)
     D svString        S                   like(jString)
     D svAlignment     S                   like(jShort)
      /free
         // Default Alignment: Center
         if %parms < 3;
           svAlignment = POI_ALIGN_CENTER;
         else;
           svAlignment = argAlignment;
         endif;
         svString = new_String(argBytes);
         svHeader = HSSFSheet_getHeader(argSheet);
         select;
           when svAlignment = POI_ALIGN_LEFT;
             HSSFHeader_setLeft(svHeader: svString);
           when svAlignment = POI_ALIGN_RIGHT;
             HSSFHeader_setRight(svHeader: svString);
           other;
             HSSFHeader_setCenter(svHeader: svString);
         endsl;
         freelocalref(svString);
         freelocalref(svHeader);
       return;
      /end-free
     P                 E
      **********************************************************************
      *  AirExcel_setFooter(): Sets the Header for the HSSFSheet
      **********************************************************************
     P AirExcel_setFooter...
     P                 B                   EXPORT
     D AirExcel_setFooter...
     D                 PI
     D  argSheet                           like(HSSFSheet) const
     D  argBytes                   1024A   const varying options(*varsize)
     D  argAlignment                       like(jShort)  options(*noPass:*omit)
     D svFooter        S                   like(HSSFFooter)
     D svString        S                   like(jString)
     D svAlignment     S                   like(jShort)
      /free
         // Default Alignment: Center
         if %parms < 3;
           svAlignment = POI_ALIGN_CENTER;
         else;
           svAlignment = argAlignment;
         endif;
         svString = new_String(argBytes);
         svFooter = HSSFSheet_getFooter(argSheet);
         select;
           when svAlignment = POI_ALIGN_LEFT;
             HSSFFooter_setLeft(svFooter: svString);
           when svAlignment = POI_ALIGN_RIGHT;
             HSSFFooter_setRight(svFooter: svString);
           other;
             HSSFFooter_setCenter(svFooter: svString);
         endsl;
         freelocalref(svString);
         freelocalref(svFooter);
       return;
      /end-free
     P                 E
      **********************************************************************
      *  AirExcel_newCellStyleFromFormat
      **********************************************************************
     P AirExcel_setCellStyleDataFormat...
     P                 B                   EXPORT
     D AirExcel_setCellStyleDataFormat...
     D                 PI
     D  argCellStyle                       like(HSSFCellStyle)
     D  argBytes                    512A   const varying options(*varsize)
     D svString        S                   like(jString)
      /free
       svString = new_String(%trim(argBytes));
       HSSFCellStyle_setDataFormat(argCellStyle:
           HSSFDataFormat_getBuiltinFormat(svString));
       return;
      /end-free
     P                 E
