      /if not defined(SPAIREXCEL)
     D**********************************************************************
     D* POI Excel Prototypes
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
     D* Official POI Website:
     D*   http://poi.apache.org/
     D**********************************************************************
     D* THE CRTSQLRPGI COMMAND DOES NOT ALLOW A COPY INSIDE OF A COPY
     D* IT WILL GIVE YOU A NEST COPY NOT ALLOWED ERROR
     D* BUT IT WORKS JUST FINE FOR CRTRPGMOD.........
     D* SO, YOU HAVE TO PUT THIS INTO EVERY PROGRAM THAT USES IT.
     D*/copy QSYSINC/QRPGLESRC,JNI
     D**********************************************************************
     D*  POI Objects
     D**********************************************************************
     D*  org.apache.poi.hssf.usermodel.* (Not all, but most)
     D**********************************************************************
     D HSSFCell        S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell')
     D HSSFCellStyle   S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle')
     D HSSFComment     S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFComment')
     D HSSFDataFormat  S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat')
     D HSSFDateUtil    S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataUtil')
     D HSSFFont        S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont')
     D HSSFFooter      S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFooter')
     D HSSFHeader      S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFHeader')
     D HSSFName        S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFName')
     D HSSFPalette     S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFPalette')
     D HSSFPatriarch   S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFPatriarch')
     D HSSFPicture     S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFPicture')
     D HSSFPrintSetup  S               O   class(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFPrintSetup')
     D HSSFRichTextString...
     D                 S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRichTextString')
     D HSSFRow         S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow')
     D HSSFSheet       S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet')
     D HSSFTextbox     S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFTextbox')
     D HSSFWorkbook    S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook')
     D POIFSFilesystem...
     D                 S               O   CLASS(*JAVA
     D                                     :'org.apache.poi.poifs-
     D                                     .filesystem.POIFSFileSystem')
     D**********************************************************************
     D* CONSTRUCTORS
     D**********************************************************************
     D* HSSFWorkBook Default Constructor
     D new_HSSFWorkbook...
     D                 PR                  like(HSSFWorkbook)
     D                                     ExtProc(*JAVA:
     D                                     'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook':
     D                                     *CONSTRUCTOR)
     D* HSSFWorkBook Constructor using a POIFSFileSystem Object
     D new_HSSFWorkbookFromPOIFS...
     D                 PR                  like(HSSFWorkbook)
     D                                     ExtProc(*JAVA:
     D                                     'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook':
     D                                     *CONSTRUCTOR)
     D  argFileSystem                      like(POIFSFileSystem)
     D*
     D new_HSSFRichTextString...
     D                 pr                  like(HSSFRichTextString)
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRichTextString':
     D                                     *CONSTRUCTOR)
     D  argString                          like(jString) const
     D*
     D new_POIFSFileSystem...
     D                 pr                  like(POIFSFileSystem)
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.poifs-
     D                                     .filesystem.POIFSFileSystem':
     D                                     *CONSTRUCTOR)
     D  argStream                          like(InputStream)
     D**********************************************************************
     D* POI METHODS
     D**********************************************************************
     D HSSFWorkbook_write...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'write')
     D  argStream                          like(OutputStream)
     D HSSFWorkbook_createSheet...
     D                 PR                  like(HSSFSheet)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createSheet')
     D  argSheetName                       like(jString)
     D HSSFWorkbook_createDataFormat...
     D                 PR                  like(HSSFDataFormat)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createDataFormat')
     D HSSFWorkbook_createCellStyle...
     D                 PR                  like(HSSFCellStyle)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createCellStyle')
     D HSSFWorkbook_createFont...
     D                 PR                  like(HSSFFont)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'createFont')
     D HSSFWorkbook_setSheetName...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D                                     :'setSheetName')
     D  argIndex                           like(jint)    value
     D  argSheetName                       like(jString)
     D HSSFSheet_createRow...
     D                 PR                  like(HSSFRow)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'createRow')
     D  argRow                             like(jint) value
     D HSSFSheet_setColumnWidth...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'setColumnWidth')
     D  argColumn                          like(jshort) value
     D  argWidth                           like(jshort) value
     D*
     D HSSFSheet_setPrintGridLines...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'setPrintGridlines')
     D  argSetting                    1N   value
     D*
     D HSSFSheet_setZoom...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'setZoom')
     D  argNumerator...
     D                                     like(jInt) value
     D  argDenominator...
     D                                     like(jInt) value
     D*
     D HSSFSheet_getHeader...
     D                 PR                  like(HSSFHeader)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'getHeader')
     D HSSFSheet_getFooter...
     D                 PR                  like(HSSFFooter)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'getFooter')
     D HSSFSheet_getPrintSetup...
     D                 PR                  like(HSSFPrintSetup)
     D                                     extproc(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D                                     :'getPrintSetup')
     D HSSFRow_createCell...
     D                 PR                  like(HSSFCell)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow'
     D                                     :'createCell')
     D  argColumn                          like(jshort) value
     D HSSFRow_setHeight...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow'
     D                                     :'setHeight')
     D  argHeight                          like(jshort) value
     D HSSFRow_setHeightInPoints...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow'
     D                                     :'setHeightInPoints')
     D  argHeightPts                       like(jfloat) value
     D HSSFCell_setCellType...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellType')
     D  argCellType                        like(jint) value
     D HSSFCell_setCellStyle...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellStyle')
     D  argCellStyle                       like(HSSFCellStyle)
     D**********************************************************************
     D* setCellValueString is Deprecated, use RichTextString instead.
     D**********************************************************************
     D HSSFCell_setCellValueString...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D  argValue                           like(jString)
     D*
     D HSSFCell_setCellValueRichString...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D  argValue                           like(HSSFRichTextString)
     D HSSFCell_setCellValueNumeric...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D  argValue                           like(jdouble) value
     D HSSFCell_setCellValueDate...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellValue')
     D  argDate                            like(JavaDate)
     D HSSFCell_setCellFormula...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D                                     :'setCellFormula')
     D  argValue                           like(jString) const
     D HSSFCellStyle_setFont...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setFont')
     D  argFont                            like(HSSFFont)
     D HSSFCellStyle_setDataFormat...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setDataFormat')
     D  argFormat                          like(jshort) value
     D HSSFCellStyle_setAlignment...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setAlignment')
     D  argAlignment                       like(jshort) value
     D HSSFCellStyle_setBorderBottom...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setBorderBottom')
     D  argBorder                          like(jshort) value
     D HSSFCellStyle_setBorderTop...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setBorderTop')
     D  argBorder                          like(jshort) value
     D HSSFCellStyle_setBorderLeft...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setBorderLeft')
     D  argBorder                          like(jshort) value
     D HSSFCellStyle_setBorderRight...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setBorderRight')
     D  argBorder                          like(jshort) value
     D HSSFCellStyle_setWrapText...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D                                     :'setWrapText')
     D  argBoolean                    1N   value
     D HSSFDataFormat_getFormat...
     D                 PR                  like(jshort)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat'
     D                                     :'getFormat')
     D  argFormat                          like(jString)
     D HSSFDataFormat_getBuiltinFormat...
     D                 PR                  like(jshort)
     D                                     EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat'
     D                                     :'getBuiltinFormat')
     D                                     static
     D  argFormat                          like(jString)
     D HSSFFont_setBoldweight...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont'
     D                                     :'setBoldweight')
     D  argWeight                          like(jshort) value
     D HSSFFont_setColor...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFont'
     D                                     :'setColor')
     D  argColor                      5I 0 value
     D HSSFFont_setFontHeightInPoints...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont'
     D                                     :'setFontHeightInPoints')
     D  argHeightPts                       like(jshort) value
     D HSSFFont_setFontName...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFont'
     D                                     :'setFontName')
     D  argFont                            like(jString)
     D HSSFFont_setItalic...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFont'
     D                                     :'setItalic')
     D  argBoolean                    1N   value
     D HSSFFont_setStrikeout...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFont'
     D                                     :'setStrikeout')
     D  argBoolean                    1N   value
     D HSSFFont_setTypeOffset...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFont'
     D                                     :'setTypeOffset')
     D  argTypeOffset                 5I 0 value
     D HSSFFont_setUnderline...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFont'
     D                                     :'setUnderline')
     D  argBoolean                    1N   value
     D HSSFHeader_setCenter...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'setCenter')
     D  argString                          like(jString)
     D HSSFHeader_setLeft...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'setLeft')
     D  argString                          like(jString)
     D HSSFHeader_setRight...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'setRight')
     D  argString                          like(jString)
     D HSSFHeader_date...
     D                 PR                  like(jString)
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'date')
     D                                     static
     D HSSFHeader_file...
     D                 PR                  like(jString)
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'file')
     D                                     static
     D HSSFHeader_font...
     D                 PR                  like(jString)
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'font')
     D                                     static
     D    argFont                          like(jString)
     D    argStyle                         like(jString)
     D HSSFHeader_fontSize...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'fontSize')
     D                                     like(jString)
     D    argSize                     5I 0 value
     D HSSFHeader_numPages...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'numPages')
     D                                     like(jString)
     D HSSFHeader_page...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'page')
     D                                     like(jString)
     D HSSFHeader_tab...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'tab')
     D                                     like(jString)
     D HSSFHeader_time...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFHeader'
     D                                     :'time')
     D                                     like(jString)
     D HSSFFooter_setCenter...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'setCenter')
     D   argString                         like(jString)
     D HSSFFooter_setLeft...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'setLeft')
     D   argString                         like(jString)
     D HSSFFooter_setRight...
     D                 PR                  extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'setRight')
     D   argString                         like(jString)
     D HSSFFooter_date...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'date')
     D                                     like(jString)
     D HSSFFooter_file...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'file')
     D                                     like(jString)
     D HSSFFooter_numPages...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'numPages')
     D                                     like(jString)
     D HSSFFooter_page...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'page')
     D                                     like(jString)
     D HSSFFooter_tab...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'tab')
     D                                     like(jString)
     D HSSFFooter_time...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'time')
     D                                     like(jString)
     D HSSFFooter_font...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'font')
     D                                     like(jString)
     D  argFont                            like(jString)
     D  argStyle                           like(jString)
     D HSSFFooter_fontSize...
     D                 PR                  static
     D                                     extproc(*JAVA:
     D                                     'org.apache.poi.hssf.-
     D                                     usermodel.HSSFFooter'
     D                                     :'fontSize')
     D                                     like(jString)
     D  argSize                       5I 0 value
     D HSSFPrintSetup_setLandscape...
     D                 PR                  extproc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFPrintSetup'
     D                                     :'setLandscape')
     D   argSetting                   1N   value
     D HSSFWorkbook_getSheet...
     D                 PR                  like(HSSFSheet)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFWorkbook'
     D                                     :'getSheet')
     D  argSheetName                       like(jString)
     D HSSFWorkbook_getSheetAt...
     D                 PR                  like(HSSFSheet)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFWorkbook'
     D                                     :'getSheetAt')
     D  argIndex                           like(jInt) value
     D HSSFWorkbook_getSheetName...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFWorkbook'
     D                                     :'getSheetName')
     D  argIndex                           like(jInt) value
     D HSSFSheet_getLastRowNum...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFSheet'
     D                                     :'getLastRowNum')
     D HSSFSheet_getPhysicalNumberOfRows...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFSheet'
     D                                     :'getPhysicalNumberOfRows')
     D HSSFSheet_getRow...
     D                 PR                  like(HSSFRow)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFSheet'
     D                                     :'getRow')
     D  argRow                             like(jInt) value
     D HSSFSheet_rowIterator...
     D                 PR                  like(Iterator)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFSheet'
     D                                     :'rowIterator')
     D HSSFRow_getCell...
     D                 PR                  like(HSSFCell)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFRow'
     D                                     :'getCell')
     D  argColumn                          like(jShort) value
     D HSSFRow_getPhysicalNumberOfCells...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFRow'
     D                                     :'getPhysicalNumberOfCells')
     D HSSFRow_getRowNum...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFRow'
     D                                     :'getRowNum')
     D HSSFRow_cellIterator...
     D                 PR                  like(Iterator)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFRow'
     D                                     :'cellIterator')
     D HSSFCell_getCellNum...
     D                 PR                  like(jShort)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFCell'
     D                                     :'getCellNum')
     D HSSFCell_getCellType...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFCell'
     D                                     :'getCellType')
     D HSSFCell_getCellFormula...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFCell'
     D                                     :'getCellFormula')
     D HSSFCell_getNumericCellValue...
     D                 PR                  like(jDouble)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFCell'
     D                                     :'getNumericCellValue')
     D HSSFCell_getStringCellValue...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFCell'
     D                                     :'getStringCellValue')
     D HSSFCell_getCellStyle...
     D                 PR                  like(HSSFCellStyle)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFCell'
     D                                     :'getCellStyle')
     D HSSFCell_getRichStringCell...
     D                 PR                  like(HSSFRichTextString)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFCell'
     D                                     :'getRichStringCellValue')
     D HSSFRichTextString_getString...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFRichTextString'
     D                                     :'getString')
     D HSSFCell_getBooleanCellValue...
     D                 PR             1N
     D                                     ExtProc(*JAVA
     D                                     :'org.apache.poi.hssf-
     D                                     .usermodel.HSSFCell'
     D                                     :'getBooleanCellValue')
     D HSSFCellStyle_setFillBackgroundColor...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.-
     D                                     usermodel.HSSFCellStyle'
     D                                     :'setFillBackgroundColor')
     D  argColor                           like(jShort) value
     D HSSFCellStyle_setFillForegroundColor...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.-
     D                                     usermodel.HSSFCellStyle'
     D                                     :'setFillForegroundColor')
     D  argColor                           like(jShort) value
     D HSSFCellStyle_setFillPattern...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'org.apache.poi.hssf.-
     D                                     usermodel.HSSFCellStyle'
     D                                     :'setFillPattern')
     D  argPattern                         like(jShort) value
     D**********************************************************************
     D* CONSTANTS
     D* MOST OF THESE CAN BE FOUND IN THE POI JAVADOCS
     D* http://poi.apache.org/apidocs
     D**********************************************************************
     D* org.apache.poi.hssf.usermodel.HSSFCell Constant Field Values
     D**********************************************************************
     D POI_CELL_TYPE_BLANK...
     D                 C                   3
     D POI_CELL_TYPE_BOOLEAN...
     D                 C                   4
     D POI_CELL_TYPE_ERROR...
     D                 C                   5
     D POI_CELL_TYPE_FORMULA...
     D                 C                   2
     D POI_CELL_TYPE_NUMERIC...
     D                 C                   0
     D POI_CELL_TYPE_STRING...
     D                 C                   1
     D**********************************************************************
     D* org.apache.poi.hssf.usermodel.HSSFCellStyle Constant Field Values
     D**********************************************************************
     D POI_ALIGN_CENTER...
     D                 C                   2
     D POI_ALIGN_CENTER_SELECTION...
     D                 C                   6
     D POI_ALIGN_FILL...
     D                 C                   4
     D POI_ALIGN_GENERAL...
     D                 C                   0
     D POI_ALIGN_JUSTIFY...
     D                 C                   5
     D POI_ALIGN_LEFT...
     D                 C                   1
     D POI_ALIGN_RIGHT...
     D                 C                   3
     D POI_ALT_BARS...
     D                 C                   3
     D POI_BIG_SPOTS...
     D                 C                   9
     D POI_BORDER_DASH_DOT...
     D                 C                   9
     D POI_BORDER_DASH_DOT_DOT...
     D                 C                   11
     D POI_BORDER_DASHED...
     D                 C                   3
     D POI_BORDER_DOTTED...
     D                 C                   7
     D POI_BORDER_DOUBLE...
     D                 C                   6
     D POI_BORDER_HAIR...
     D                 C                   4
     D POI_BORDER_MEDIUM...
     D                 C                   2
     D POI_BORDER_MEDIUM_DASH_DOT...
     D                 C                   10
     D POI_BORDER_MEDIUM_DASH_DOT_DOT...
     D                 C                   12
     D POI_BORDER_MEDIUM_DASHED...
     D                 C                   8
     D POI_BORDER_NONE...
     D                 C                   0
     D POI_BORDER_SLANTED_DASH_DOT...
     D                 C                   13
     D POI_BORDER_THICK...
     D                 C                   5
     D POI_BORDER_THIN...
     D                 C                   1
     D POI_BRICKS...
     D                 C                   10
     D POI_DIAMONDS...
     D                 C                   16
     D POI_FINE_DOTS...
     D                 C                   2
     D POI_LEAST_DOTS...
     D                 C                   18
     D POI_LESS_DOTS...
     D                 C                   17
     D POI_NO_FILL...
     D                 C                   0
     D POI_SOLID_FOREGROUND...
     D                 C                   1
     D POI_SPARSE_DOTS...
     D                 C                   4
     D POI_SQUARES...
     D                 C                   15
     D POI_THICK_BACKWARD_DIAG...
     D                 C                   7
     D POI_THICK_FORWARD_DIAG...
     D                 C                   8
     D POI_THICK_HORZ_BANDS...
     D                 C                   5
     D POI_THICK_VERT_BANDS...
     D                 C                   6
     D POI_THIN_BACKWARD_DIAG...
     D                 C                   13
     D POI_THIN_FORWARD_DIAG...
     D                 C                   14
     D POI_THIN_HORZ_BANDS...
     D                 C                   11
     D POI_THIN_VERT_BANDS...
     D                 C                   12
     D POI_VERTICAL_BOTTOM...
     D                 C                   2
     D POI_VERTICAL_CENTER...
     D                 C                   1
     D POI_VERTICAL_JUSTIFY...
     D                 C                   3
     D POI_VERTICAL_TOP...
     D                 C                   0
     D**********************************************************************
     D* org.apache.poi.hssf.util.HSSFColor Constant Field Values
     D**********************************************************************
     D* INDEXES INTO THE EXCEL STANDARD COLOR PALETTE
     D POI_AUTO...
     D                 C                   64
     D POI_AQUA...
     D                 C                   49
     D POI_BLACK...
     D                 C                   8
     D POI_BLUE...
     D                 C                   12
     D POI_BLUE_2...
     D                 C                   39
     D POI_BLUE_CORN...
     D                 C                   24
     D POI_BLUE_GREY...
     D                 C                   54
     D POI_BLUE_LIGHT...
     D                 C                   48
     D POI_BLUE_DARK...
     D                 C                   18
     D POI_BLUE_PALE...
     D                 C                   44
     D POI_BLUE_ROYAL...
     D                 C                   30
     D POI_BLUE_SKY...
     D                 C                   40
     D POI_BROWN...
     D                 C                   60
     D POI_CORAL...
     D                 C                   29
     D POI_GOLD...
     D                 C                   51
     D POI_GREEN...
     D                 C                   17
     D POI_GREEN_BRIGHT...
     D                 C                   35
     D POI_GREEN_DARK...
     D                 C                   58
     D POI_GREEN_LIGHT...
     D                 C                   42
     D POI_GREEN_OLIVE...
     D                 C                   59
     D POI_GREEN_SEA...
     D                 C                   57
     D POI_GREY_25...
     D                 C                   22
     D POI_GREY_40...
     D                 C                   55
     D POI_GREY_50...
     D                 C                   23
     D POI_GREY_80...
     D                 C                   63
     D POI_INDIGO...
     D                 C                   62
     D POI_LAVENDER...
     D                 C                   46
     D POI_LEMON...
     D                 C                   26
     D POI_LIME...
     D                 C                   50
     D POI_MAROON...
     D                 C                   25
     D POI_ORANGE...
     D                 C                   53
     D POI_ORANGE_LIGHT...
     D                 C                   52
     D POI_ORCHID...
     D                 C                   28
     D POI_PINK...
     D                 C                   14
     D POI_PLUM...
     D                 C                   61
     D POI_RED...
     D                 C                   10
     D POI_RED_DARK...
     D                 C                   16
     D POI_ROSE...
     D                 C                   45
     D POI_TAN...
     D                 C                   47
     D POI_TEAL...
     D                 C                   21
     D POI_TEAL2...
     D                 C                   38
     D POI_TEAL_DARK...
     D                 C                   56
     D POI_TURQUOISE...
     D                 C                   15
     D POI_TURQUOISE2...
     D                 C                   35
     D POI_TURQUOISE_LIGHT...
     D                 C                   41
     D POI_VIOLET...
     D                 C                   20
     D POI_VIOLET2...
     D                 C                   36
     D POI_YELLOW...
     D                 C                   13
     D POI_YELLOW2...
     D                 C                   34
     D POI_YELLOW_DARK...
     D                 C                   19
     D POI_YELLOW_LIGHT...
     D                 C                   43
     D POI_WHITE...
     D                 C                   9
     D**********************************************************************
     D* org.apache.poi.hssf.usermodel.Font Constant Field Values
     D**********************************************************************
     D POI_FONT_ANSI...
     D                 C                   0
     D POI_FONT_BOLD_BOLD...
     D                 C                   700
     D POI_FONT_BOLD_NORMAL...
     D                 C                   400
     D POI_FONT_COLOR_NORMAL...
     D                 C                   32767
     D POI_FONT_COLOR_RED...
     D                 C                   10
     D POI_FONT_DEFAULT_CHARSET...
     D                 C                   1
     D POI_FONT_ARIAL...
     D                 C                   'Arial'
     D POI_FONT_SS_NONE...
     D                 C                   0
     D POI_FONT_SS_SUB...
     D                 C                   2
     D POI_FONT_SS_SUPER...
     D                 C                   1
     D POI_FONT_SYMBOL_CHARSET...
     D                 C                   2
     D POI_FONT_U_DOUBLE...
     D                 C                   2
     D POI_FONT_U_DOUBLE_ACCOUNTING...
     D                 C                   34
     D POI_FONT_U_NONE...
     D                 C                   0
     D POI_FONT_U_SINGLE...
     D                 C                   1
     D POI_FONT_U_SINGLE_ACCOUNTING...
     D                 C                   33
     D**********************************************************************
     D* org.apache.poi.hssf.usermodel.HSSFFontFormatting Constant Field Values
     D**********************************************************************
     D POI_SS_NONE...
     D                 C                   0
     D POI_SS_SUB...
     D                 C                   2
     D POI_SS_SUPER...
     D                 C                   1
     D POI_U_DOUBLE...
     D                 C                   2
     D POI_U_DOUBLE_ACCOUNTING...
     D                 C                   34
     D POI_U_NONE...
     D                 C                   0
     D POI_U_SINGLE...
     D                 C                   1
     D POI_U_SINGLE_ACCOUNTING...
     D                 C                   33
     D**********************************************************************
     D* org.apache.poi.hssf.usermodel.HSSFHyperLink Constant Field Values
     D**********************************************************************
     D POI_LINK_DOCUMENT...
     D                 C                   2
     D POI_LINK_EMAIL...
     D                 C                   3
     D POI_LINK_FILE...
     D                 C                   4
     D POI_LINK_URL...
     D                 C                   1
     D**********************************************************************
     D* org.apache.poi.hssf.usermodel.HSSFPrintSetup Constant Field Values
     D**********************************************************************
     D POI_LETTER_PAPERSIZE...
     D                 C                   1
     D POI_LEGAL_PAPERSIZE...
     D                 C                   5
     D POI_EXECUTIVE_PAPERSIZE...
     D                 C                   7
     D POI_A4_PAPERSIZE...
     D                 C                   9
     D POI_A5_PAPERSIZE...
     D                 C                   11
     D POI_ENVELOPE_10_PAPERSIZE...
     D                 C                   20
     D POI_ENVELOPE_DL_PAPERSIZE...
     D                 C                   27
     D POI_ENVELOPE_CS_PAPERSIZE...
     D                 C                   28
     D POI_ENVELOPE_MONARCH_PAPERSIZE...
     D                 C                   37
     D**********************************************************************
     D* Internal Prototype Wrappers
     D* These are customized RPG code wrappers.
     D* These procedures do more than just provide the interface.
     D* Additional objectives include:
     D* - Providing RPG style arguments for easy implementation
     D* - Validation and Exception Handling
     D* - Assigning default values to reduce code complexity
     D**********************************************************************
     D AirExcel_open...
     D                 PR                  like(HSSFWorkbook)
     D  argFileName                1024A   const varying
     D AirExcel_getWorkbook...
     D                 PR                  like(HSSFWorkbook)
     D   argFileName               1024A   const varying
     D                                     options(*noPass: *omit)
     D AirExcel_write...
     D                 PR
     D   argWorkBook                       like(HSSFWorkbook)
     D   argFileName               1024A   const varying
     D AirExcel_getSheet...
     D                 PR                  like(HSSFSheet)
     D   argWorkBook                       like(HSSFWorkbook)
     D   argSheetName              1024A   varying const
     D AirExcel_getRow...
     D                 PR                  like(HSSFRow)
     D  argSheet                           like(HSSFSheet)
     D  argIndex                           like(jInt) value
     D AirExcel_getCell...
     D                 PR                  like(HSSFCell)
     D  argRow                             like(HSSFRow)
     D  argIndex                           like(jInt) value
     D AirExcel_setCellValueString...
     D                 PR
     D  argCell                            like(HSSFCell)
     D  argBytes                  65535A   varying const
     D  argStyle                           like(HSSFCellStyle)
     D                                     options(*nopass)
     D AirExcel_setCellValueNumeric...
     D                 PR
     D  argCell                            like(HSSFCell)
     D  argNumber                          like(jDouble) value
     D  argStyle                           like(HSSFCellStyle)
     D                                     options(*nopass)
     D AirExcel_setCellStyleDataFormat...
     D                 PR
     D  argCellStyle                       like(HSSFCellStyle)
     D  argBytes                    512A   const varying options(*varsize)
     D AirExcel_setHeader...
     D                 PR
     D  argSheet                           like(HSSFSheet) const
     D  argBytes                   1024A   const varying options(*varsize)
     D  argAlignment                       like(jShort) options(*noPass: *omit)
     D AirExcel_setFooter...
     D                 PR
     D  argSheet                           like(HSSFSheet) const
     D  argBytes                   1024A   const varying options(*varsize)
     D  argAlignment                       like(jShort) options(*noPass: *omit)
     D**********************************************************************
      /define SPAIREXCEL
      /endif
