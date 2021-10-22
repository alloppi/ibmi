     /*-                                                                            +
      * Copyright (c) 2004-2010 Scott C. Klement                                    +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +
      /if not defined(HSSF_H)

      /define OS400_JVM_12
      /copy QSYSINC/QRPGLESRC,JNI

      *-----------------------------------------------------------------
      *  jFileOutputStream = the Java FileOutputStream class
      *-----------------------------------------------------------------
     D jFileOutputStream...
     D                 S               O   CLASS(*JAVA
     D                                     :'java.io.FileOutputStream')

      *-----------------------------------------------------------------
      *  jOutputStream = the Java OutputStream class
      *-----------------------------------------------------------------
     D jOutputStream   S               O   CLASS(*JAVA
     D                                     :'java.io.OutputStream')

      *-----------------------------------------------------------------
      *  new String(byte[] chars)                                          f
      *  Constructor for Java String object
      *
      *  Routine from the Java Runtime Environment.
      *-----------------------------------------------------------------
     D new_String      PR                  like(jString)
     D                                     EXTPROC(*JAVA
     D                                     :'java.lang.String'
     D                                     :*CONSTRUCTOR)
     D create_from                 1024A   VARYING const


      *-----------------------------------------------------------------
      *  new FileOutputStream(String filename)
      *
      *  Constructor for Java FileOutputStream class which is used
      *  to write new stream files.
      *
      *  Routine from the Java Runtime Environment.
      *
      *  filename = the file to create (IFS format)
      *-----------------------------------------------------------------
     D new_FileOutputStream...
     D                 PR                  like(jFileOutputStream)
     D                                     EXTPROC(*JAVA
     D                                     :'java.io.FileOutputStream'
     D                                     :*CONSTRUCTOR)
     D filename                            like(jString)


      *-----------------------------------------------------------------
      * FileOutputStream_close():  Close a stream file that was opened
      *            for output.
      *-----------------------------------------------------------------
     D FileOutputStream_close...
     D                 pr                  EXTPROC(*JAVA
     D                                     :'java.io.FileOutputStream'
     D                                     :'close')


      ******************************************************************
      *  HSSF Data Types
      ******************************************************************
     D HSSF_WORKBOOK_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFWorkbook'
     D HSSF_SHEET_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFSheet'
     D HSSF_ROW_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFRow'
     D HSSF_CELL_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCell'
     D HSSF_FONT_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFont'
     D HSSF_CELLSTYLE_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFCellStyle'
     D HSSF_DATAFORMAT_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFDataFormat'
     D HSSF_HEADER_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFHeader'
     D HSSF_FOOTER_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFFooter'
     D HSSF_PATRIARCH_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFPatriarch'
     D HSSF_PICTURE_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFPicture'
     D HSSF_CLIENTANCHOR_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFClientAnchor'
     D HSSF_PRINTSETUP_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HSSFPrintSetup'

     D HSSFWorkbook    S               O   CLASS(*JAVA: HSSF_WORKBOOK_CLASS)
     D HSSFSheet       S               O   CLASS(*JAVA: HSSF_SHEET_CLASS)
     D HSSFRow         S               O   CLASS(*JAVA: HSSF_ROW_CLASS )
     D HSSFCell        S               O   CLASS(*JAVA: HSSF_CELL_CLASS )
     D HSSFFont        S               O   CLASS(*JAVA: HSSF_FONT_CLASS )
     D HSSFCellStyle   S               O   CLASS(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS )
     D HSSFDataFormat  S               O   CLASS(*JAVA
     D                                     : HSSF_DATAFORMAT_CLASS )
     D HSSFHeader      S               O   CLASS(*JAVA: HSSF_HEADER_CLASS )
     D HSSFFooter      S               O   CLASS(*JAVA: HSSF_FOOTER_CLASS )
     D HSSFPatriarch   S               O   CLASS(*JAVA
     D                                     : HSSF_PATRIARCH_CLASS )
     D HSSFPicture     S               O   CLASS(*JAVA: HSSF_PICTURE_CLASS )
     D HSSFClientAnchor...
     D                 S               O   CLASS(*JAVA
     D                                     : HSSF_CLIENTANCHOR_CLASS )
     D HSSFPrintSetup  s               O   class(*JAVA
     D                                     : HSSF_PRINTSETUP_CLASS )


      ******************************************************************
      *  XSSF Data Types
      ******************************************************************
     D XSSF_WORKBOOK_CLASS...
     D                 C                   'org.apache.poi.xssf.usermodel-
     D                                     .XSSFWorkbook'

     D XSSFWorkbook    S               O   CLASS(*JAVA: XSSF_WORKBOOK_CLASS)


      ******************************************************************
      *  Generic Spread Sheet (SS) Data Types
      ******************************************************************
     D WORKBOOK_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Workbook'
     D SHEET_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Sheet'
     D ROW_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Row'
     D CELL_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Cell'
     D FONT_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Font'
     D CELLSTYLE_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .CellStyle'
     D DATAFORMAT_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .DataFormat'
     D HEADER_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Header'
     D FOOTER_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Footer'
     D HEADERFOOTER_CLASS...
     D                 C                   'org.apache.poi.hssf.usermodel-
     D                                     .HeaderFooter'
     D DRAWING_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Drawing'
     D PICTURE_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .Picture'
     D CLIENTANCHOR_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .ClientAnchor'
     D PRINTSETUP_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .PrintSetup'
     D CREATIONHELPER_CLASS...
     D                 C                   'org.apache.poi.ss.usermodel-
     D                                     .CreationHelper'

     D SSWorkbook      S               O   CLASS(*JAVA: WORKBOOK_CLASS)
     D SSSheet         S               O   CLASS(*JAVA: SHEET_CLASS)
     D SSRow           S               O   CLASS(*JAVA: ROW_CLASS)
     D SSCell          S               O   CLASS(*JAVA: CELL_CLASS)
     D SSFont          S               O   CLASS(*JAVA: FONT_CLASS)
     D SSCellStyle     S               O   CLASS(*JAVA: CELLSTYLE_CLASS)
     D SSDataFormat    S               O   CLASS(*JAVA: DATAFORMAT_CLASS)
     D SSHeader        S               O   CLASS(*JAVA: HEADER_CLASS)
     D SSFooter        S               O   CLASS(*JAVA: FOOTER_CLASS)
     D SSDrawing       S               O   CLASS(*JAVA: DRAWING_CLASS)
     D SSPicture       S               O   CLASS(*JAVA: PICTURE_CLASS)
     D SSClientAnchor  S               O   CLASS(*JAVA: CLIENTANCHOR_CLASS)
     D SSPrintSetup    S               O   CLASS(*JAVA: PRINTSETUP_CLASS)
     D SSCreationHelper...
     D                 S               O   CLASS( *JAVA
     D                                          : CREATIONHELPER_CLASS )

     D REGION_CLASS...
     D                 c                   'org.apache.poi.ss.util.Region'
     D Region          S               O   CLASS(*JAVA: REGION_CLASS)

     D CELLRANGEADDRESS_CLASS...
     D                 c                   'org.apache.poi.ss.util-
     D                                     .CellRangeAddress'
     D CellRangeAddress...
     D                 S               O   CLASS(*JAVA
     D                                     : CELLRANGEADDRESS_CLASS)


      *-----------------------------------------------------------------
      *  ss_get_jni_env(): Get pointer to JNI Environment
      *
      *  (Routine from the HSSFR4 service program)
      *  Used by many of the other JNI routines.
      *
      *  returns the pointer, or *NULL upon error
      *-----------------------------------------------------------------
     D ss_get_jni_env...
     D                 PR              *   extproc('HSSF_GET_JNI_ENV')
     D hssf_get_jni_env...
     D                 PR              *


      *-----------------------------------------------------------------
      *  ss_freeLocalRef(Ref)
      *
      *  Utility routine in the HSSFR4 service program.
      *
      *  Normally, when you call Java constructors from within Java,
      *  the JVM knows when they are no longer needed, and cleans
      *  them up appropriately.   But, from within RPG, the JVM has
      *  no way to know this.
      *
      *  This utility routine will tell the JVM that you're done with
      *  an object, so that the cleanup routines will remove it.
      *
      *      Usage:
      *               callp  ss_freeLocalRef(ObjectName)
      *
      *      for example, if you create a String, use it to create
      *        an output stream, and then don't need the string anymore,
      *        you might do something like this:
      *
      *               eval   Blah = new_String('/path/to/myfile.txt')
      *               eval   File = new_FileOutputStream(Blah)
      *               callp  ss_freeLocalRef(Blah)
      *-----------------------------------------------------------------
     D ss_freeLocalRef...
     D                 PR                  ExtProc('HSSF_FREELOCALREF')
     D    peRef                            like(jobject)
     D hssf_freeLocalRef...
     D                 PR
     D    peRef                            like(jobject)


      *-----------------------------------------------------------------
      * ss_begin_object_group():  Start a new group of objects
      *    which will all be freed when hssf_end_object_group()
      *    gets called.
      *
      *  Utility routine in the HSSFR4 service program.
      *
      *   peCapacity = maximum number of objects that can be
      *        referenced within this object group.
      *
      *  NOTE: According to the 1.2 JNI Spec, you can create more
      *        objects in the new frame than peCapacity allows.  The
      *        peCapacity is the guarenteed number. When no object
      *        groups are used, 16 references are guarenteed, so if
      *        you specify 16 here, that would be comparable to a
      *        "default value".
      *
      * Returns 0 if successful, or -1 upon error
      *-----------------------------------------------------------------
     D SS_DFT_GROUP_CAPACITY...
     D                 C                   CONST(16)
     D ss_begin_object_group...
     D                 PR            10I 0 ExtProc('HSSF_BEGIN-
     D                                     _OBJECT_GROUP')
     D    peCapacity                 10I 0 value
     D HSSF_DFT_GROUP_CAPACITY...
     D                 C                   CONST(16)
     D hssf_begin_object_group...
     D                 PR            10I 0
     D    peCapacity                 10I 0 value


      *-----------------------------------------------------------------
      * ss_end_object_group():  Frees all Java objects that
      *   have been created since calling ss_begin_object_group()
      *
      *        peOldObj = (see below)
      *        peNewObj = Sometimes it's desirable to preserve one
      *            object by moving it from the current object group
      *            to the parent group.   These parameters allow you
      *            to make that move.
      *
      * Returns 0 if successful, or -1 upon error
      *-----------------------------------------------------------------
     D ss_end_object_group...
     D                 PR            10I 0 ExtProc('HSSF_END_OBJECT_GROUP')
     D   peOldObj                          like(jObject) const
     D                                     options(*nopass)
     D   peNewObj                          like(jObject)
     D                                     options(*nopass)
     D hssf_end_object_group...
     D                 PR            10I 0
     D   peOldObj                          like(jObject) const
     D                                     options(*nopass)
     D   peNewObj                          like(jObject)
     D                                     options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  new_HSSFWorkbook()
      *      Create a new HSSF (Binary Excel) workbook
      *  new_XSSFWorkbook()
      *      Create a new XSSF (OOXML Excel) workbook
      *
      *   Returns the new workbook object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D new_HSSFWorkbook...
     D                 PR              O   class(*java
     D                                     : HSSF_WORKBOOK_CLASS )
     D                                     ExtProc(*java
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     : *CONSTRUCTOR)
     D new_XSSFWorkbook...
     D                 PR              O   class(*java
     D                                     : XSSF_WORKBOOK_CLASS )
     D                                     ExtProc(*java
     D                                     : XSSF_WORKBOOK_CLASS
     D                                     : *CONSTRUCTOR)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  new_Region()
      *    Creates a new Region object, identifying a section of
      *    the spreadsheet
      *
      *    rowFrom = starting row number. (The rows are numbered from 0,
      *            so they're always one less than they appear in Excel)
      *    colFrom = starting column num. (The cols are numbered from 0,
      *            so col A = 0, Col B = 1, etc)
      *    rowTo   = ending row number
      *    colTo   = ending column number
      *
      *  returns new Region object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D new_Region...
     D                 PR                  like(Region)
     D                                     ExtProc(*JAVA: REGION_CLASS
     D                                     : *CONSTRUCTOR)
     D   rowFrom                           like(jint)   value
     D   colFrom                           like(jshort) value
     D   rowTo                             like(jint)   value
     D   colTo                             like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  new_CellRangeAddress()
      *    Creates a new CellRangeAddress object, identifying a range
      *    of cells on a spreadsheet
      *
      *    firstRow = starting row number
      *    lastRow  = ending row number
      *    firstCol = starting column number
      *    lastCol  = ending column number
      *
      *  returns new CellRangeAddress object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D new_CellRangeAddress...
     D                 PR                  like(CellRangeAddress)
     D                                     ExtProc(*JAVA
     D                                     : CELLRANGEADDRESS_CLASS
     D                                     : *CONSTRUCTOR)
     D   firstRow                          like(jint) value
     D   lastRow                           like(jint) value
     D   firstCol                          like(jint) value
     D   lastCol                           like(jint) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSWorkbook_write():  write workbook to output stream
      *
      *     output_stream = FileOutputStream object to write the
      *            workbook to.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HSSFWorkbook_write...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     :'write')
     D output_stream                       like(jOutputStream)
     D ssWorkbook_write...
     D                 PR                  EXTPROC(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     :'write')
     D output_stream                       like(jOutputStream)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  HSSFWorkbook_createSheet():
      *    create new sheet in a workbook
      *
      *    sheetname = name of sheet to create
      *
      *  Returns the HSSFSheet object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D HSSFWorkbook_createSheet...
     D                 PR                  like(HSSFSheet)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     : 'createSheet')
     D  sheetname                          like(jString)
     D ssWorkbook_createSheet...
     D                 PR                  like(SSSheet)
     D                                     EXTPROC(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     : 'createSheet')
     D  sheetname                          like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSWorkbook_createDataFormat():
      *   Create a dataformat object, which can be used to translate
      *   from string representations of Excel data formats to
      *   the internal representations required by the CellStyle object
      *
      *  Returns the SSDataFormat object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSWorkbook_createDataFormat...
     D                 PR                  like(SSDataFormat)
     D                                     EXTPROC(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     :'createDataFormat')
     D HSSFWorkbook_createDataFormat...
     D                 PR                  like(HSSFDataFormat)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     :'createDataFormat')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSWorkbook_createCellStyle():
      *    Creates a CellStyle object which can then be used
      *    to format the way text is displayed in one or more cells
      *
      *  Returns a new SSCellStyle object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSWorkbook_createCellStyle...
     D                 PR                  like(SSCellStyle)
     D                                     EXTPROC(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     :'createCellStyle')
     D HSSFWorkbook_createCellStyle...
     D                 PR                  like(HSSFCellStyle)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     :'createCellStyle')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSWorkbook_createFont():
      *     create a new SSFont object, which can be used to change
      *     the way text is displayed in an SSCellStyle object
      *
      *  Returns the SSFont object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSWorkbook_createFont...
     D                 PR                  like(SSFont)
     D                                     EXTPROC(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     :'createFont')
     D HSSFWorkbook_createFont...
     D                 PR                  like(HSSFFont)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     :'createFont')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSWorkbook_setSheetName():
      *     set the name of a sheet in the workbook
      *
      *     sheet = ordinal number that specifies the sheet to rename
      *      name = new name of sheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSWorkbook_setSheetName...
     D                 PR                  EXTPROC(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     :'setSheetName')
     D  sheet                              like(jint)    value
     D  name                               like(jString)
     D HSSFWorkbook_setSheetName...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     :'setSheetName')
     D  sheet                              like(jint)    value
     D  name                               like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSWorkbook_setRepeatingRowsAndColumns()
      *     mark a range of rows & columns to repeat on each page
      *     of a printed report.
      *
      *   sheetno = (input) ordinal number specifying the sheet
      *  startcol = (input) starting col number to repeat (or -1)
      *    endcol = (input) ending col number to repeat (or -1)
      *  startrow = (input) startng row number to repeat (or -1)
      *    endrow = (input) ending row number to repeat (or -1)
      *
      * When a row/column is set to -1, that value does not get
      * changed.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSWorkbook_setRepeatingRowsAndColumns...
     D                 PR                  EXTPROC(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     :'setRepeatingRowsAndColumns')
     D  sheetno                            like(jint) value
     D  startcol                           like(jint) value
     D  endcol                             like(jint) value
     D  startrow                           like(jint) value
     D  endrow                             like(jint) value
     D HSSFWorkbook_setRepeatingRowsAndColumns...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     :'setRepeatingRowsAndColumns')
     D  sheetno                            like(jint) value
     D  startcol                           like(jint) value
     D  endcol                             like(jint) value
     D  startrow                           like(jint) value
     D  endrow                             like(jint) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSSheet_createRow()
      *     Add a new row to an existing sheet.  This row can then
      *     be used to store cells.
      *
      *    row_number = the number of the row to create.  Rows are
      *         numbered starting at 0... so a row that shows up as
      *         Row 5 in Excel will be Row 4 here.
      *
      *  returns the new SSRow object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_createRow...
     D                 PR                  like(SSRow)
     D                                     EXTPROC(*JAVA: SHEET_CLASS
     D                                     :'createRow')
     D row_number                          like(jint) value
     D HSSFSheet_createRow...
     D                 PR                  like(HSSFRow)
     D                                     EXTPROC(*JAVA: HSSF_SHEET_CLASS
     D                                     :'createRow')
     D row_number                          like(jint) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  HSSFSheet_setColumnWidth():
      *     Set the width of a column in an HSSFSheet object
      *
      *   column = column number.  Columns are numbered starting with 0,
      *         so Excel Column A is 0, Col B is 1, etc.
      *    width = width of column in 1/256th of a character.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_setColumnWidth...
     D                 PR                  EXTPROC(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'setColumnWidth')
     D column                              like(jint) value
     D width                               like(jint) value
     D HSSFSheet_setColumnWidth...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'setColumnWidth')
     D column                              like(jint) value
     D width                               like(jint) value

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSSheet_addMergedRegion():
      *   Merges all of the cells in a Region of a Sheet
      *
      *    merge_region = Region object representing the cells to merge
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_addMergedRegion...
     D                 PR                  like(jint)
     D                                     EXTPROC(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'addMergedRegion')
     D   merge_region                      like(CellRangeAddress) const
     D HSSFSheet_addMergedRegion...
     D                 PR                  like(jint)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'addMergedRegion')
     D   merge_region                      like(Region)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSSheet_getHeader(): Retrieve the header from an SSSheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_getHeader...
     D                 PR                  like(SSHeader)
     D                                     EXTPROC(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'getHeader')
     D HSSFSheet_getHeader...
     D                 PR                  like(HSSFHeader)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'getHeader')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSSheet_getFooter(): Retrieve the footer from an SSSheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_getFooter...
     D                 PR                  like(SSFooter)
     D                                     EXTPROC(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'getFooter')
     D HSSFSheet_getFooter...
     D                 PR                  like(HSSFFooter)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'getFooter')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSRow_createCell()
      *   Create a new cell in a given HSSFRow
      *
      *   column_number = number of column within the row that the
      *        cell should be created as.   Columns are numbered from
      *        0, so column A is 0, col B is 1, etc.
      *
      * Returns a new Cell object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSRow_createCell...
     D                 PR                  like(SSCell)
     D                                     EXTPROC(*JAVA
     D                                     : ROW_CLASS
     D                                     : 'createCell')
     D column_number                       like(jint) value
     D HSSFRow_createCell...
     D                 PR                  like(HSSFCell)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_ROW_CLASS
     D                                     : 'createCell')
     D column_number                       like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSRow_setHeight()
      *   Set the height of a row.
      *
      *     height = new height in twips (1/20" of a point)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSRow_setHeight...
     D                 PR                  EXTPROC(*JAVA
     D                                     : ROW_CLASS
     D                                     : 'setHeight')
     D height                              like(jshort) value
     D HSSFRow_setHeight...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_ROW_CLASS
     D                                     : 'setHeight')
     D height                              like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSRow_setHeightInPoints()
      *   Set the height of a row
      *
      *     height = new height in points.  (can be fractional)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSRow_setHeightInPoints...
     D                 PR                  EXTPROC(*JAVA
     D                                     : ROW_CLASS
     D                                     : 'setHeightInPoints')
     D height                              like(jfloat) value
     D HSSFRow_setHeightInPoints...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_ROW_CLASS
     D                                     : 'setHeightInPoints')
     D height                              like(jfloat) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSCell_setCellType():
      *    Set the data type for a given cell
      *
      *    cell_type = type of cell.   See the CELL_TYPE_XXX constants
      *            below for possible values
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_setCellType...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'setCellType')
     D cell_type                           like(jint) value
     D HSSFCell_setCellType...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'setCellType')
     D cell_type                           like(jint) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSCell_setCellStyle():
      *     Associate a HSSFCellStyle object with a given Cell
      *     so that the cell will be displayed using the attributes
      *     of the Cell Style.
      *
      *   cell_style = cell style object to associate with this cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_setCellStyle...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'setCellStyle')
     D cell_style                          like(SSCellStyle)
     D HSSFCell_setCellStyle...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'setCellStyle')
     D cell_style                          like(HSSFCellStyle)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCell_setCellValue()
      *    Set the value of a cell.
      *    (use setCellValueStr() to set a string object, or
      *         setCellValueD() to set a double/numeric object)
      *
      *   cell_value = new value of cell.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_setCellValueStr...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'setCellValue')
     D cell_value                          like(jString) const
     D SSCell_setCellValueD...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'setCellValue')
     D cell_value                          like(jdouble) value
     D HSSFCell_setCellValueStr...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'setCellValue')
     D cell_value                          like(jString) const
     D HSSFCell_setCellValueD...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'setCellValue')
     D cell_value                          like(jdouble) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCell_setCellFormula()
      *    Set the formula to be placed in a cell
      *
      *   cell_formula = new formula for cell.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_setCellFormula...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'setCellFormula')
     D cell_formula                        like(jString)
     D HSSFCell_setCellFormula...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'setCellFormula')
     D cell_formula                        like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCellStyle_setFont()
      *    Associate a given SSFont object with a SSCellStyle object
      *
      *   font = SSFont object to associate with this cell style
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setFont...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setFont')
     D   font                              like(SSFont) const
     D HSSFCellStyle_setFont...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setFont')
     D   font                              like(HSSFFont) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCellStyle_setDataFormat():
      *   Set the data format of this cell (i.e. how numbers or dates
      *      or etc are formatted when displayed)
      *
      *   dataformat = internal numeric representation of data format.
      *       Use SSDataFormat object to get this internal rep.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setDataFormat...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setDataFormat')
     D   dataformat                        like(jshort) value
     D HSSFCellStyle_setDataFormat...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setDataFormat')
     D   dataformat                        like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSCellStyle_setAlignment()
      *     Choose how text is aligned for a given cell style
      *
      *   align = alignment of this cell style.  See the ALIGN_XXX
      *       constants below for possible values
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setAlignment...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setAlignment')
     D   align                             like(jshort) value
     D HSSFCellStyle_setAlignment...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setAlignment')
     D   align                             like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCellStyle_setBorderBottom()
      *    Set the type of border to be used at the bottom of cells
      *    that use this cell style
      *
      *  border = border style to use.   See the BORDER_XXX constants
      *      below for possible values
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setBorderBottom...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setBorderBottom')
     D   border                            like(jshort) value
     D HSSFCellStyle_setBorderBottom...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setBorderBottom')
     D   border                            like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCellStyle_setBorderTop()
      *    Set the type of border to be used at the top of cells
      *    that use this cell style
      *
      *  border = border style to use.   See the BORDER_XXX constants
      *      below for possible values
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setBorderTop...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setBorderTop')
     D   border                            like(jshort) value
     D HSSFCellStyle_setBorderTop...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setBorderTop')
     D   border                            like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCellStyle_setBorderLeft()
      *    Set the type of border to be used on the left of cells
      *    that use this cell style
      *
      *  border = border style to use.   See the BORDER_XXX constants
      *      below for possible values
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setBorderLeft...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setBorderLeft')
     D   border                            like(jshort) value
     D HSSFCellStyle_setBorderLeft...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setBorderLeft')
     D   border                            like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCellStyle_setBorderRight()
      *    Set the type of border to be used on the right of cells
      *    that use this cell style
      *
      *  border = border style to use.   See the BORDER_XXX constants
      *      below for possible values
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setBorderRight...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setBorderRight')
     D   border                            like(jshort) value
     D HSSFCellStyle_setBorderRight...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setBorderRight')
     D   border                            like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCellStyle_setWrapText()  Turn text wrapping on/off
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setWrapText...
     D                 PR                  EXTPROC(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setWrapText')
     D   wrapped                       N   value
     D HSSFCellStyle_setWrapText...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setWrapText')
     D   wrapped                       N   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSFont_setBoldweight()
      *      Set the boldweight ("boldness") of a font.
      *
      *   boldweight = bold weight to use.   See BOLDWEIGHT_XXX
      *       constants below for possible values
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFont_setBoldweight...
     D                 PR                  EXTPROC(*JAVA
     D                                     : FONT_CLASS
     D                                     : 'setBoldweight')
     D   boldweight                        like(jshort) value
     D HSSFFont_setBoldweight...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_FONT_CLASS
     D                                     : 'setBoldweight')
     D   boldweight                        like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSFont_setFontHeightInPoints()
      *      Set the height of a font
      *
      *       height = height of font (in points)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFont_setFontHeightInPoints...
     D                 PR                  EXTPROC(*JAVA
     D                                     : FONT_CLASS
     D                                     : 'setFontHeightInPoints')
     D   height                            like(jshort) value
     D HSSFFont_setFontHeightInPoints...
     D                 PR                  EXTPROC(*JAVA
     D                                     : HSSF_FONT_CLASS
     D                                     : 'setFontHeightInPoints')
     D   height                            like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSDataFormat_getFormat()
      *    look up the internal representation of a data format
      *
      *  format = format to look up.  (example: '#,##0.00')
      *
      *  returns the internal represenation of the format, for
      *      use in calling the SSCellStyle_setDataFormat() method
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSDataFormat_getFormat...
     D                 PR                  like(jshort)
     D                                     EXTPROC(*JAVA
     D                                     : DATAFORMAT_CLASS
     D                                     : 'getFormat')
     D   format                            like(jString)
     D HSSFDataFormat_getFormat...
     D                 PR                  like(jshort)
     D                                     EXTPROC(*JAVA
     D                                     : HSSF_DATAFORMAT_CLASS
     D                                     : 'getFormat')
     D   format                            like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFont_setFontName():  Set a font face by name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFont_setFontName...
     D                 PR                  extproc(*JAVA
     D                                     : FONT_CLASS
     D                                     : 'setFontName')
     D   name                              like(jString)
     D HSSFFont_setFontName...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FONT_CLASS
     D                                     : 'setFontName')
     D   name                              like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFont_setColor():  Set a font's color
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFont_setColor...
     D                 PR                  extproc(*JAVA
     D                                     : FONT_CLASS
     D                                     :'setColor')
     D   color                        5I 0 value
     D HSSFFont_setColor...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FONT_CLASS
     D                                     :'setColor')
     D   color                        5I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFont_setItalic(): Set italic on/off
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFont_setItalic...
     D                 PR                  extproc(*JAVA
     D                                     : FONT_CLASS
     D                                     :'setItalic')
     D   italic                       1N   value
     D HSSFFont_setItalic...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FONT_CLASS
     D                                     :'setItalic')
     D   italic                       1N   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFont_setStrikeout(): Set strikeout on/off
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFont_setStrikeout...
     D                 PR                  extproc(*JAVA
     D                                     : FONT_CLASS
     D                                     : 'setStrikeout')
     D   strikeout                    1N   value
     D HSSFFont_setStrikeout...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FONT_CLASS
     D                                     : 'setStrikeout')
     D   strikeout                    1N   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFont_setTypeOffset(): Set typeoffset (super/subscript)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFont_setTypeOffset...
     D                 PR                  extproc(*JAVA
     D                                     : FONT_CLASS
     D                                     : 'setTypeOffset')
     D   typeoffset                   5I 0 value
     D HSSFFont_setTypeOffset...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FONT_CLASS
     D                                     : 'setTypeOffset')
     D   typeoffset                   5I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFont_setUnderline(): Set underline style
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFont_setUnderline...
     D                 PR                  extproc(*JAVA
     D                                     : FONT_CLASS
     D                                     : 'setUnderline')
     D   underline                    1A   value
     D HSSFFont_setUnderline...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FONT_CLASS
     D                                     : 'setUnderline')
     D   underline                    1A   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeader_setLeft(): Set header string for left-hand side
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeader_setLeft...
     D                 PR                  extproc(*JAVA
     D                                     : HEADER_CLASS
     D                                     : 'setLeft')
     D   newLeft                           like(jString)
     D HSSFHeader_setLeft...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'setLeft')
     D   newLeft                           like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeader_setCenter(): Set header string to go in center
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeader_setCenter...
     D                 PR                  extproc(*JAVA
     D                                     : HEADER_CLASS
     D                                     : 'setCenter')
     D   newCenter                         like(jString)
     D HSSFHeader_setCenter...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'setCenter')
     D   newCenter                         like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeader_setRight(): Set header string to go on right-hand side
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeader_setRight...
     D                 PR                  extproc(*JAVA
     D                                     : HEADER_CLASS
     D                                     : 'setRight')
     D   newRight                          like(jString)
     D HSSFHeader_setRight...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'setRight')
     D   newRight                          like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeaderFooter_date(): Get special "current date" chars
      *                        to insert into header/footer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeaderFooter_date...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HEADERFOOTER_CLASS
     D                                     : 'date')
     D                                     like(jString)
     D HSSFHeader_date...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'date')
     D                                     like(jString)
     D HSSFFooter_date...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'date')
     D                                     like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeaderFooter_file(): Get special "current filename" chars
      *                        to insert into header/footer record
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeaderFooter_file...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HEADERFOOTER_CLASS
     D                                     : 'file')
     D                                     like(jString)
     D HSSFHeader_file...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'file')
     D                                     like(jString)
     D HSSFFooter_file...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'file')
     D                                     like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeaderFooter_numPages(): Get special "num of pages" chars
      *                            to insert into header/footer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeaderFooter_numPages...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HEADERFOOTER_CLASS
     D                                     : 'numPages')
     D                                     like(jString)
     D HSSFHeader_numPages...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'numPages')
     D                                     like(jString)
     D HSSFFooter_numPages...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'numPages')
     D                                     like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeaderFooter_page(): Get special "current page no" chars
      *                        to insert into header/footer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeaderFooter_page...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HEADERFOOTER_CLASS
     D                                     : 'page' )
     D                                     like(jString)
     D HSSFHeader_page...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'page')
     D                                     like(jString)
     D HSSFFooter_page...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'page')
     D                                     like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeaderFooter_sheetName(): Get special "current tab (sheet) name"
      *                             chars to insert into header/footer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeaderFooter_sheetName...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HEADERFOOTER_CLASS
     D                                     : 'tab' )
     D                                     like(jString)
     D HSSFHeader_sheetName...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'tab')
     D                                     like(jString)
     D HSSFFooter_sheetName...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'tab')
     D                                     like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeaderFooter_time(): Get special "current time" characters
      *                        to insert into header/footer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeaderFooter_time...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HEADERFOOTER_CLASS
     D                                     : 'time' )
     D                                     like(jString)
     D HSSFHeader_time...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'time')
     D                                     like(jString)
     D HSSFFooter_time...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'time')
     D                                     like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeaderFooter_font(): Get special chars that represent a font
      *                        in the header/footer of a document
      *
      *       font = (input) the new font to set
      *      style = (input) the fonts style to set
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeaderFooter_font...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HEADERFOOTER_CLASS
     D                                     : 'font')
     D                                     like(jString)
     D    font                             like(jString)
     D    style                            like(jString)
     D HSSFHeader_font...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'font')
     D                                     like(jString)
     D    font                             like(jString)
     D    style                            like(jString)
     D HSSFFooter_font...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'font')
     D                                     like(jString)
     D    font                             like(jString) const
     D    style                            like(jString) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSHeaderFooter_fontSize(): Get special chars that represent
      *                            size change in the header/footer
      *                            of a document
      *
      *       size = (input) new font size
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSHeaderFooter_fontSize...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HEADERFOOTER_CLASS
     D                                     : 'fontSize')
     D                                     like(jString)
     D    size                        5I 0 value
     D HSSFHeader_fontSize...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_HEADER_CLASS
     D                                     : 'fontSize')
     D                                     like(jString)
     D    size                        5I 0 value
     D HSSFFooter_fontSize...
     D                 PR                  static
     D                                     extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'fontSize')
     D                                     like(jString)
     D    size                        5I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFooter_setLeft(): Set header string for left-hand side
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFooter_setLeft...
     D                 PR                  extproc(*JAVA
     D                                     : FOOTER_CLASS
     D                                     : 'setLeft')
     D   newLeft                           like(jString)
     D HSSFFooter_setLeft...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'setLeft')
     D   newLeft                           like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFooter_setCenter(): Set header string to go in center
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFooter_setCenter...
     D                 PR                  extproc(*JAVA
     D                                     : FOOTER_CLASS
     D                                     : 'setCenter')
     D   newCenter                         like(jString)
     D HSSFFooter_setCenter...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'setCenter')
     D   newCenter                         like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSFooter_setRight(): Set header string to go on right-hand side
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSFooter_setRight...
     D                 PR                  extproc(*JAVA
     D                                     : FOOTER_CLASS
     D                                     : 'setRight')
     D   newRight                          like(jString)
     D HSSFFooter_setRight...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_FOOTER_CLASS
     D                                     : 'setRight')
     D   newRight                          like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HSSFWorkbook_getSheet(): Retrieve a sheet from a workbook
      *
      *     SheetName = (input) name of sheet to retrieve
      *
      * Returns the HSSFWorkbook object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSWorkbook_getSheet...
     D                 PR                  like(SSSheet)
     D                                     ExtProc(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     : 'getSheet')
     D  SheetName                          like(jString)
     D HSSFWorkbook_getSheet...
     D                 PR                  like(HSSFSheet)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_WORKBOOK_CLASS
     D                                     : 'getSheet')
     D  SheetName                          like(jString)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSWorkbook_getCreationHelper():
      *   Retrieves a Java object that helps create objects in the
      *   appropriate (HSSF or XSSF) class.
      *
      *  Returns the SSCreationHelper object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSWorkbook_getCreationHelper...
     D                 PR                  like(SSCreationHelper)
     D                                     EXTPROC(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     :'getCreationHelper')

     D SSCreationHelper_createClientAnchor...
     D                 PR                  like(SSClientAnchor)
     D                                     EXTPROC(*JAVA
     D                                     : CREATIONHELPER_CLASS
     D                                     :'createClientAnchor')

     D SSCreationHelper_createDataFormat...
     D                 PR                  like(SSDataFormat)
     D                                     EXTPROC(*JAVA
     D                                     : CREATIONHELPER_CLASS
     D                                     :'createDataFormat')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSSheet_getRow(): Retrieve an SSRow object from a sheet
      *
      *     RowNo = (input) Row number of the row to retrieve
      *
      * Returns the SSRow object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_getRow...
     D                 PR                  like(SSRow)
     D                                     ExtProc(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'getRow')
     D  RowNo                              like(jInt) value
     D HSSFSheet_getRow...
     D                 PR                  like(HSSFRow)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'getRow')
     D  RowNo                              like(jInt) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSRow_getCell():  Retrieve an SSCell object from an
      *                   existing SSRow object
      *
      *      ColNo = (input) Column number of cell to retrieve
      *
      * returns an SSCell object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSRow_getCell...
     D                 PR                  like(SSCell)
     D                                     ExtProc(*JAVA
     D                                     : ROW_CLASS
     D                                     : 'getCell')
     D  ColNo                              like(jint) value
     D HSSFRow_getCell...
     D                 PR                  like(HSSFCell)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_ROW_CLASS
     D                                     : 'getCell')
     D  ColNo                              like(jShort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCell_getCellType(): Determine the type of data in an
      *                       SSCell object.
      *
      * returns an integer that corresponds to a CELL_TYPE_xxx
      *        constant.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_getCellType...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'getCellType')
     D HSSFCell_getCellType...
     D                 PR                  like(jInt)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'getCellType')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCell_getCellFormula(): Retrieve the formula stored in an
      *                          SSCell object.
      *
      * returns a Java string containing the formula
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_getCellFormula...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'getCellFormula')
     D HSSFCell_getCellFormula...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'getCellFormula')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCell_getNumericCellValue(): Retrieve the number stored in an
      *                               SSCell object.
      *
      * returns the numeric value of the cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_getNumericCellValue...
     D                 PR                  like(jDouble)
     D                                     ExtProc(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'getNumericCellValue')
     D HSSFCell_getNumericCellValue...
     D                 PR                  like(jDouble)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'getNumericCellValue')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCell_getStringCellValue(): Retrieve the String stored in an
      *                              SSCell object.
      *
      * returns a Java string containing the value
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_getStringCellValue...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'getStringCellValue')
     D HSSFCell_getStringCellValue...
     D                 PR                  like(jString)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'getStringCellValue')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSCell_getCellStyle(): Retrieve the Cell Style associated
      *                        with an SSCell object.
      *
      * returns an SSCellStyle object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCell_getCellStyle...
     D                 PR                  like(SSCellStyle)
     D                                     ExtProc(*JAVA
     D                                     : CELL_CLASS
     D                                     : 'getCellStyle')
     D HSSFCell_getCellStyle...
     D                 PR                  like(HSSFCellStyle)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_CELL_CLASS
     D                                     : 'getCellStyle')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSSheet_createDrawingPatriarch():  Create a drawing patriach
      *    to draw pictures, et al, on a sheet.
      *
      *  The SSDrawing object acts as a sort of "container" for
      *  the shapes, pictures and other drawn objects.
      *
      *  returns the patriarch object.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_createDrawingPatriarch...
     D                 PR                  like(SSDrawing)
     D                                     ExtProc(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'createDrawingPatriarch')
     D HSSFSheet_createDrawingPatriarch...
     D                 PR                  like(HSSFPatriarch)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'createDrawingPatriarch')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * new_SSClientAnchor():  Create a new SSClientAnchor object
      *      used to anchor a picture to a place within a sheet
      *
      *     book = workbook object that anchor is for
      *             (used to determine HSSF vs XSSF)
      *      dx1 = the x coordinate within the first cell
      *      dy1 = the y coordinate within the first cell
      *      dx2 = the x coordinate within the second cell
      *      dy2 = the y coordinate within the second cell
      *     col1 = the column of the first cell
      *     row1 = the row of the first cell
      *     col2 = the column of the second cell
      *     row2 = the row of the second cell
      *
      *  returns the SSClientAnchor object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D new_SSClientAnchor...
     D                 PR                  like(SSClientAnchor)
     D   book                              like(SSWorkbook) const
     D   dx1                         10i 0 value
     D   dy1                         10i 0 value
     D   dx2                         10i 0 value
     D   dy2                         10i 0 value
     D   col1                        10i 0 value
     D   row1                        10i 0 value
     D   col2                        10i 0 value
     D   row2                        10i 0 value
     D new_HSSFClientAnchor...
     D                 PR                  like(HSSFClientAnchor)
     D                                     ExtProc(*JAVA
     D                                     : HSSF_CLIENTANCHOR_CLASS
     D                                     : *CONSTRUCTOR)
     D   dx1                         10i 0 value
     D   dy1                         10i 0 value
     D   dx2                         10i 0 value
     D   dy2                         10i 0 value
     D   col1                         5i 0 value
     D   row1                        10i 0 value
     D   col2                         5i 0 value
     D   row2                        10i 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSClientAnchor_setAnchorType(): Set the type of anchor
      *
      *     type = type of anchor.
      *
      *   values:
      *     SS_ANCHOR_MOVESIZE = moves & sizes with cells
      *     SS_ANCHOR_MOVE     = moves but doesn't size with cells
      *     SS_ANCHOR_FIXED    = doesn't move or size with cells.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSClientAnchor_setAnchorType...
     D                 PR                  ExtProc(*JAVA
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setAnchorType')
     D   type                        10i 0 value
     D HSSFClientAnchor_setAnchorType...
     D                 PR                  ExtProc(*JAVA
     D                                     : HSSF_CLIENTANCHOR_CLASS
     D                                     : 'setAnchorType')
     D   type                        10i 0 value

     D SS_ANCHOR_MOVESIZE...
     D                 C                   0
     D SS_ANCHOR_MOVE...
     D                 C                   2
     D SS_ANCHOR_FIXED...
     D                 C                   3
     D HSSF_ANCHOR_MOVESIZE...
     D                 C                   0
     D HSSF_ANCHOR_MOVE...
     D                 C                   2
     D HSSF_ANCHOR_FIXED...
     D                 C                   3


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSDrawing_createPicture(): Establish a picture by associating
      *      an anchor in a sheet with a picture that has already been
      *      loaded into the workbook.
      *
      *       anchor = anchor object that describes how this
      *                    picture is attached to the sheet
      * pictureIndex = index of picture loaded into Workbook
      *
      * returns the SSPicture object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSDrawing_createPicture...
     D                 PR                  like(SSPicture)
     D                                     extproc(*JAVA
     D                                     : DRAWING_CLASS
     D                                     : 'createPicture')
     D   anchor                            like(SSClientAnchor)
     D   pictureIndex                10i 0 value
     D HSSFPatriarch_createPicture...
     D                 PR                  like(HSSFPicture)
     D                                     extproc(*JAVA
     D                                     : HSSF_PATRIARCH_CLASS
     D                                     : 'createPicture')
     D   anchor                            like(HSSFClientAnchor)
     D   pictureIndex                10i 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSPicture_resetSize(): Reset picture to it's original size
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSPicture_resetSize...
     D                 PR                  extproc(*JAVA
     D                                     : PICTURE_CLASS
     D                                     : 'resize')
     D HSSFPicture_resetSize...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_PICTURE_CLASS
     D                                     : 'resize')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * BOLDWEIGHT_XXX constants for calling SSFont_setBoldweight()
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D BOLDWEIGHT_NORMAL...
     D                 C                   190
     D BOLDWEIGHT_BOLD...
     D                 C                   700

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CELL_TYPE_XXX constants for calling SSCell_setCellType()
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CELL_TYPE_NUMERIC...
     D                 C                   0
     D CELL_TYPE_STRING...
     D                 C                   1
     D CELL_TYPE_FORMULA...
     D                 C                   2
     D CELL_TYPE_BLANK...
     D                 C                   3
     D CELL_TYPE_BOOLEAN...
     D                 C                   4
     D CELL_TYPE_ERROR...
     D                 C                   5

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ALIGN_XXX constants for calling HSSFCellStyle_setAlignment()
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ALIGN_CENTER...
     D                 C                   2
     D ALIGN_CENTER_SELECTION...
     D                 C                   6
     D ALIGN_FILL...
     D                 C                   4
     D ALIGN_GENERAL...
     D                 C                   0
     D ALIGN_JUSTIFY...
     D                 C                   5
     D ALIGN_LEFT...
     D                 C                   1
     D ALIGN_RIGHT...
     D                 C                   3

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * BORDER_XXX constants for calling SSCellStyle_setBorderBottom()
      *                               or SSCellStyle_setBorderTop()
      *                               or SSCellStyle_setBorderLeft()
      *                               or SSCellStyle_setBorderRight()
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D BORDER_DASH_DOT...
     D                 C                   9
     D BORDER_DASH_DOT_DOT...
     D                 C                   11
     D BORDER_DASHED...
     D                 C                   3
     D BORDER_DOTTED...
     D                 C                   7
     D BORDER_DOUBLE...
     D                 C                   6
     D BORDER_HAIR...
     D                 C                   4
     D BORDER_MEDIUM...
     D                 C                   2
     D BORDER_MEDIUM_DASH_DOT...
     D                 C                   10
     D BORDER_MEDIUM_DASH_DOT_DOT...
     D                 C                   12
     D BORDER_MEDIUM_DASHED...
     D                 C                   8
     D BORDER_THIN...
     D                 C                   1
     D BORDER_NONE...
     D                 C                   0


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Set font color... COLOR_NORMAL is for fonts only
      *                   COLOR_AUTOMATIC is for fills only
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D COLOR_AQUA...
     D                 C                   49
     D COLOR_BLACK...
     D                 C                   8
     D COLOR_BLUE...
     D                 C                   12
     D COLOR_BLUE_GREY...
     D                 C                   54
     D COLOR_BRIGHT_GREEN...
     D                 C                   11
     D COLOR_BROWN...
     D                 C                   60
     D COLOR_CORAL...
     D                 C                   29
     D COLOR_CORNFLOWER_BLUE...
     D                 C                   24
     D COLOR_DARK_BLUE...
     D                 C                   18
     D COLOR_DARK_RED...
     D                 C                   16
     D COLOR_DARK_TEAL...
     D                 C                   56
     D COLOR_DARK_YELLOW...
     D                 C                   19
     D COLOR_DARK_GOLD...
     D                 C                   51
     D COLOR_DARK_GREEN...
     D                 C                   17
     D COLOR_GREY_25...
     D                 C                   22
     D COLOR_GREY_40...
     D                 C                   55
     D COLOR_GREY_50...
     D                 C                   23
     D COLOR_GREY_80...
     D                 C                   63
     D COLOR_INDIGO...
     D                 C                   62
     D COLOR_LAVENDER...
     D                 C                   46
     D COLOR_LEMON_CHIFFON...
     D                 C                   26
     D COLOR_LIGHT_BLUE...
     D                 C                   48
     D COLOR_LIGHT_CORNFLOWER_BLUE...
     D                 C                   31
     D COLOR_LIGHT_GREEN...
     D                 C                   42
     D COLOR_LIGHT_ORANGE...
     D                 C                   52
     D COLOR_LIGHT_TURQUOISE...
     D                 C                   27
     D COLOR_LIGHT_YELLOW...
     D                 C                   43
     D COLOR_LIME...
     D                 C                   50
     D COLOR_MAROON...
     D                 C                   25
     D COLOR_OLIVE_GREEN...
     D                 C                   59
     D COLOR_ORANGE...
     D                 C                   53
     D COLOR_ORCHID...
     D                 C                   28
     D COLOR_PALE_BLUE...
     D                 C                   44
     D COLOR_PINK...
     D                 C                   14
     D COLOR_PLUM...
     D                 C                   61
     D COLOR_RED...
     D                 C                   10
     D COLOR_ROSE...
     D                 C                   45
     D COLOR_ROYAL_BLUE...
     D                 C                   30
     D COLOR_SEA_GREEN...
     D                 C                   57
     D COLOR_SKY_BLUE...
     D                 C                   40
     D COLOR_TAN...
     D                 C                   47
     D COLOR_TEAL...
     D                 C                   21
     D COLOR_TURQUOISE...
     D                 C                   15
     D COLOR_VIOLET...
     D                 C                   20
     D COLOR_WHITE...
     D                 C                   9
     D COLOR_YELLOW...
     D                 C                   13
     D COLOR_NORMAL...
     D                 C                   32767
     D COLOR_AUTOMATIC...
     D                 C                   64


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * type offsets for superscript, subscript and normal
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_NONE...
     D                 C                   0
     D SS_SUPER...
     D                 C                   1
     D SS_SUB...
     D                 C                   2


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * underline styles
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D U_NONE...
     D                 C                   x'00'
     D U_SINGLE...
     D                 C                   x'01'
     D U_DOUBLE...
     D                 C                   x'02'
     D U_SINGLE_ACCOUNTING...
     D                 C                   x'21'
     D U_DOUBLE_ACCOUNTING...
     D                 C                   x'22'


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_NewSheet():  Shortcut routine for adding a new SSSheet
      *        to an existing SSWorkbook. (basically, this takes
      *        care of creating the Java String for you.)
      *
      *   peBook = Workbook to add sheet to
      *   peName = name of new Sheet.
      *
      * Returns the new SSSheet object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_NewSheet     PR                  like(SSSheet)
     D   peBook                            like(SSWorkbook)
     D   peName                    1024A   const varying
     D hssf_NewSheet   PR                  like(HSSFSheet)
     D   peBook                            like(HSSFWorkbook)
     D   peName                    1024A   const varying




      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_save(): Save Workbook to disk
      *
      *    peBook = workbook to add sheet to
      *    peFile = IFS path/filename to save workbook as
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_save         PR
     D   peBook                            like(SSWorkbook)
     D   peFilename                1024A   const varying
     D hssf_save       PR
     D   peBook                            like(HSSFWorkbook)
     D   peFilename                1024A   const varying


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_merge(): Merge cells on a sheet
      *
      *    peSheet = sheet containing cells to merge
      *  peRowFrom = row of upper-left corner of area to merge
      *  peColFrom = col of upper-left corner of area to merge
      *  peRowTo   = row of lower-right corner of area to merge
      *  peColTo   = col of lower-right corner of area to merge
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_merge        PR
     D   peSheet                           like(HSSFSheet)
     D   peRowFrom                         like(jint) value
     D   peColFrom                         like(jshort) value
     D   peRowTo                           like(jint) value
     D   peColTo                           like(jshort) value
     D hssf_merge      PR
     D   s                                 like(HSSFSheet)
     D   rf                                like(jint) value
     D   cf                                like(jshort) value
     D   rt                                like(jint) value
     D   ct                                like(jshort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_date2xls():
      *    service program utility to convert an RPG date to a
      *    number that can be formatted as a date in Excel
      *
      *    peDate = RPG date to convert
      *
      *  returns the date formatted for Excel
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_date2xls     PR                  like(jdouble)
     D   peDate                        D   value
     D hssf_date2xls   PR                  like(jdouble)
     D   peDate                        D   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_xls2date():
      *    service program utility to convert an Excel date to
      *    an RPG date field
      *
      *    peXls = Number used as a date in Excel
      *
      *  returns the RPG date
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_xls2date     PR              D
     D   peXls                             like(jdouble) value
     D hssf_xls2date   PR              D
     D   peXls                             like(jdouble) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_cellName(): Convert POI y,x coordinates into a cell name
      *     (example: 0,0 becomes A1, 110,24 becomes Y111)
      *
      *        peRow = row number (A=0, B=1, etc)
      *        peCol = column number
      *
      *  Returns the alphanumeric cellname
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_cellName     PR            10A   varying
     D  peRow                         5I 0 value
     D  peCol                         5I 0 value
     D hssf_cellName   PR            10A   varying
     D  r                             5I 0 value
     D  c                             5I 0 value
      /if defined(HSSF_CELLNAME_SHORTCUT)
     D cn              PR            10A   varying extproc('SS_CELLNAME')
     D  peRow                         5I 0 value
     D  peCol                         5I 0 value
      /endif


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_text(): Shortcut for inserting a new cell that contains
      *        a string value into a given row of a sheet
      *
      *    peRow = Row object that cell should be created in
      *    peCol = column number of new cell
      * peString = string to place in cell
      *  peStyle = cell style object to associate with cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_text         PR
     D   peRow                             like(SSRow)
     D   peCol                        5I 0 value
     D   peString                  1024A   varying const
     D   peStyle                           like(SSCellStyle)
     D hssf_text       PR
     D   peRow                             like(HSSFRow)
     D   peCol                        5I 0 value
     D   peString                  1024A   varying const
     D   peStyle                           like(HSSFCellStyle)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_num():  Shortcut for inserting a new cell that contains
      *        a numeric value into a given row of a sheet
      *
      *    peRow = Row object that cell should be created in
      *    peCol = column number of new cell
      * peNumber = numeric value to place in cell
      *  peStyle = cell style object to associate with cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_num          PR
     D   peRow                             like(SSRow)
     D   peCol                        5I 0 value
     D   peNumber                     8F   value
     D   peStyle                           like(SSCellStyle)
     D hssf_num        PR
     D   row                               like(HSSFRow)
     D   col                          5I 0 value
     D   num                          8F   value
     D   style                             like(HSSFCellStyle)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_date():  Shortcut for inserting a new cell that contains
      *        a date value into a given row of a sheet
      *
      *    This is just a wrapper around the ss_date2xls() and
      *    ss_num() routines.  (Dates in Excel are simply double
      *    precision floating point numbers)
      *
      *    peRow = Row object that cell should be created in
      *    peCol = column number of new cell
      * peNumber = numeric value to place in cell
      *  peStyle = cell style object to associate with cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_date         PR
     D   peRow                             like(SSRow)
     D   peCol                        5I 0 value
     D   peDate                        D   value
     D   peStyle                           like(SSCellStyle)
     D hssf_date       PR
     D   peRow                             like(HSSFRow)
     D   peCol                        5I 0 value
     D   peDate                        D   value
     D   peStyle                           like(HSSFCellStyle)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_formula(): Shortcut for inserting a new cell that contains
      *        a formula into a given row of a sheet
      *
      *     peRow = Row object that cell should be created in
      *     peCol = column number of new cell
      * peFormula = formula to place in cell
      *   peStyle = cell style object to associate with cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_formula      PR
     D   peRow                             like(SSRow)
     D   peCol                        5I 0 value
     D   peFormula                 1024A   varying const
     D   peStyle                           like(SSCellStyle)
     D hssf_formula    PR
     D   peRow                             like(HSSFRow)
     D   peCol                        5I 0 value
     D   peFormula                 1024A   varying const
     D   peStyle                           like(HSSFCellStyle)


      *-----------------------------------------------------------------
      * ss_createDataFormat():  Shortcut routine to create a data fmt
      *
      *        peBook = (input) workbook to create the format in
      *      peFormat = (input) string represending the data format
      *
      * returns the data format's index in the workbook
      *-----------------------------------------------------------------
     D ss_CreateDataFormat...
     D                 PR             5I 0
     D   peBook                            like(SSWorkbook) const
     D   peFormat                   100A   varying const
     D hssf_CreateDataFormat...
     D                 PR             5I 0
     D   peBook                            like(HSSFWorkbook) const
     D   peFormat                   100A   varying const


      *-----------------------------------------------------------------
      * ss_createFont():  Shortcut routine to create a font
      *
      *        peBook = (input) workbook to create the format in
      *        peName = (input/omit) name of font to create
      *   pePointSize = (input/omit) point size of font
      *        peBold = (input/omit) bold weight of font
      *   peUnderline = (input/omit) underline style
      *      peItalic = (input/omit) set italic on/off
      *   peStrikeout = (input/omit) set strikeout on/off
      *       peColor = (input/omit) set font color
      *  peTypeOffset = (input/omit) set super/sub script
      *
      * returns a new SSFont object
      *-----------------------------------------------------------------
     D ss_CreateFont...
     D                 PR                  like(SSFont)
     D   peBook                            like(SSWorkbook) const
     D   peName                     100A   varying const options(*omit)
     D   pePointSize                  5I 0 const options(*omit)
     D   peBold                       5I 0 const options(*omit)
     D   peUnderline                  1A   const options(*omit)
     D   peItalic                     1N   const options(*omit)
     D   peStrikeout                  1N   const options(*omit)
     D   peColor                      5I 0 const options(*omit)
     D   peTypeOffset                 5I 0 const options(*omit)
     D hssf_CreateFont...
     D                 PR                  like(HSSFFont)
     D   peBook                            like(HSSFWorkbook) const
     D   peName                     100A   varying const options(*omit)
     D   pePointSize                  5I 0 const options(*omit)
     D   peBold                       5I 0 const options(*omit)
     D   peUnderline                  1A   const options(*omit)
     D   peItalic                     1N   const options(*omit)
     D   peStrikeout                  1N   const options(*omit)
     D   peColor                      5I 0 const options(*omit)
     D   peTypeOffset                 5I 0 const options(*omit)


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_setLeft(): Set the left-hand portion of the
      *                      page header
      *
      *   sheet = (input) worksheet to set the left string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_setLeft...
     D                 PR
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D HSSF_header_setLeft...
     D                 PR
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_setCenter(): Set center portion of the
      *                        page header
      *
      *   sheet = (input) worksheet to set the center string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_setCenter...
     D                 PR
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D HSSF_header_setCenter...
     D                 PR
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_setRight(): Set right-hand portion of the
      *                       page header
      *
      *   sheet = (input) worksheet to set the right string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_setRight...
     D                 PR
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D HSSF_header_setRight...
     D                 PR
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_date(): Retrieve special characters that
      *                   indicate the current date in a
      *                   header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_date...
     D                 PR          1024A   varying
     D HSSF_header_date...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_file(): Retrieve special characters that
      *                   indicate the current filename in
      *                   a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_file...
     D                 PR          1024A   varying
     D HSSF_header_file...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_font(): Retrieve special characters that
      *                   indicate a font of a particular
      *                   name & style in a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_font...
     D                 PR          1024A   varying
     D    font                     1024A   varying const
     D    style                    1024A   varying const
     D HSSF_header_font...
     D                 PR          1024A   varying
     D    font                     1024A   varying const
     D    style                    1024A   varying const


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_fontSize(): Retrieve special characters
      *                       that set the font size in a
      *                       header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_fontSize...
     D                 PR          1024A   varying
     D    size                        5U 0 value
     D HSSF_header_fontSize...
     D                 PR          1024A   varying
     D    size                        5U 0 value


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_numPages(): Retrieve special characters
      *                       that insert the number of pages
      *                       in the doc into a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_numPages...
     D                 PR          1024A   varying
     D HSSF_header_numPages...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_page(): Retrieve special characters
      *                   that insert the current page
      *                   number into a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_page...
     D                 PR          1024A   varying
     D HSSF_header_page...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_sheetName(): Retrieve special characters
      *                        that insert the current sheet
      *                        name (or "tab name") into a
      *                        header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_sheetName...
     D                 PR          1024A   varying
     D HSSF_header_sheetName...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_time(): Retrieve special characters
      *                   that insert the current time
      *                   into a header string.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_header_time...
     D                 PR          1024A   varying
     D HSSF_header_time...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_setLeft(): Set the left-hand portion of the
      *                      page footer
      *
      *   sheet = (input) worksheet to set the left string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_setLeft...
     D                 PR
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D HSSF_footer_setLeft...
     D                 PR
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_setCenter(): Set the center portion of the
      *                        page footer
      *
      *   sheet = (input) worksheet to set the center string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_setCenter...
     D                 PR
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D HSSF_footer_setCenter...
     D                 PR
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_setRight(): Set the right-hand portion of the
      *                       page footer
      *
      *   sheet = (input) worksheet to set the right string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_setRight...
     D                 PR
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D HSSF_footer_setRight...
     D                 PR
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_date(): Retrieve special characters that
      *                   indicate the current date in a
      *                   header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_date...
     D                 PR          1024A   varying
     D HSSF_footer_date...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_file(): Retrieve special characters that
      *                   indicate the current filename in
      *                   a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_file...
     D                 PR          1024A   varying
     D HSSF_footer_file...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_font(): Retrieve special characters that
      *                   indicate a font of a particular
      *                   name & style in a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_font...
     D                 PR          1024A   varying
     D    font                     1024A   varying const
     D    style                    1024A   varying const
     D HSSF_footer_font...
     D                 PR          1024A   varying
     D    font                     1024A   varying const
     D    style                    1024A   varying const


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_fontSize(): Retrieve special characters
      *                       that set the font size in a
      *                       header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_fontSize...
     D                 PR          1024A   varying
     D    size                        5U 0 value
     D HSSF_footer_fontSize...
     D                 PR          1024A   varying
     D    size                        5U 0 value


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_numPages(): Retrieve special characters
      *                       that insert the number of pages
      *                       in the doc into a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_numPages...
     D                 PR          1024A   varying
     D HSSF_footer_numPages...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_page(): Retrieve special characters
      *                   that insert the current page
      *                   number into a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_page...
     D                 PR          1024A   varying
     D HSSF_footer_page...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_sheetName(): Retrieve special characters
      *                        that insert the current sheet
      *                        name (or "tab name") into a
      *                        header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_sheetName...
     D                 PR          1024A   varying
     D HSSF_footer_sheetName...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_time(): Retrieve special characters
      *                   that insert the current time
      *                   into a header string.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_footer_time...
     D                 PR          1024A   varying
     D HSSF_footer_time...
     D                 PR          1024A   varying


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_find_sheet(): Returns the index of a given sheet
      *
      *      workbook = (input) workbook object to search
      *         sheet = (input) sheet to get index of
      *
      * Returns the index number or -1 if sheet is not
      *         part of this workbook.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_find_sheet...
     D                 PR            10I 0
     D   workbook                          like(SSWorkbook) const
     D   sheet                             like(SSSheet) const
     D HSSF_find_sheet...
     D                 PR            10I 0
     D   workbook                          like(HSSFWorkbook) const
     D   sheet                             like(HSSFSheet) const


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_setRepeating():  set the repeating rows & columns
      *
      *      workbook = (input) workbook object to search
      *         sheet = (input) sheet to get index of
      *      startcol = (input) starting column to repeat
      *        endcol = (input) ending column to repeat
      *      startrow = (input) starting row to repeat
      *        endrow = (input) ending row to repeat
      *
      * NOTE: any of the above can be set to -1 to mean
      *       "no change"
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SS_setRepeating...
     D                 PR
     D   workbook                          like(SSWorkbook) const
     D   sheet                             like(SSSheet) const
     D   startcol                    10I 0 value
     D   endcol                      10I 0 value
     D   startrow                    10I 0 value
     D   endrow                      10I 0 value
     D HSSF_setRepeating...
     D                 PR
     D   workbook                          like(HSSFWorkbook) const
     D   sheet                             like(HSSFSheet) const
     D   startcol                    10I 0 value
     D   endcol                      10I 0 value
     D   startrow                    10I 0 value
     D   endrow                      10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_open():  Open an existing Workbook (HSSF or XSSF)
      *
      *     peFilename = IFS path/filename of workbook to open
      *
      *  Returns the Workbook object opened
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_open         PR                  like(SSWorkbook)
     D   peFilename                1024A   const varying
     D hssf_open       PR                  like(HSSFWorkbook)
     D   peFilename                1024A   const varying


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ss_getSheet(): Get the sheet object from a workbook
      *
      *        peBook = workbook to retrieve sheet from
      *   peSheetName = worksheet name to retrieve
      *
      * Returns the SSSheet object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_getSheet     PR                  like(SSSheet)
     D   peBook                            like(SSWorkbook) const
     D   peSheetName               1024A   varying const
     D hssf_getSheet   PR                  like(HSSFSheet)
     D   peBook                            like(HSSFWorkbook)
     D   peSheetName               1024A   varying const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  SSSheet_setAutobreaks():  Set whether page breaks are shown
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_setAutobreaks...
     D                 PR                  extproc(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'setAutobreaks')
     D   setting                      1N   value
     D HSSFSheet_setAutobreaks...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'setAutobreaks')
     D   setting                      1N   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSSheet_setGridsPrinted(): Set whether or not grids are
      *                            printed on this sheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_setGridsPrinted...
     D                 PR                  extproc(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'setGridsPrinted')
     D   setting                      1N   value
     D HSSFSheet_setGridsPrinted...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'setGridsPrinted')
     D   setting                      1N   value
     D


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSSheet_getPrintSetup(): Get the print setup object for a
      *        given Sheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSSheet_getPrintSetup...
     D                 PR                  like(SSPrintSetup)
     D                                     extproc(*JAVA
     D                                     : SHEET_CLASS
     D                                     : 'getPrintSetup')
     D HSSFSheet_getPrintSetup...
     D                 PR                  like(HSSFPrintSetup)
     D                                     extproc(*JAVA
     D                                     : HSSF_SHEET_CLASS
     D                                     : 'getPrintSetup')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSPrintSetup_setLandscape():
      *    Turn landscape orientation on or off
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSPrintSetup_setLandscape...
     D                 PR                  extproc(*JAVA
     D                                     : PRINTSETUP_CLASS
     D                                     : 'setLandscape')
     D   setting                      1N   value
     D HSSFPrintSetup_setLandscape...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_PRINTSETUP_CLASS
     D                                     : 'setLandscape')
     D   setting                      1N   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSPrintSetup_setFitHeight():
      *   Set the number of pages high to fit the sheet in
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSPrintSetup_setFitHeight...
     D                 PR                  extproc(*JAVA
     D                                     : PRINTSETUP_CLASS
     D                                     : 'setFitHeight')
     D    height                      5I 0 value
     D HSSFPrintSetup_setFitHeight...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_PRINTSETUP_CLASS
     D                                     : 'setFitHeight')
     D    height                      5I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSPrintSetup_setFitWidth():
      *   Set the number of pages wide to fit the sheet in
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSPrintSetup_setFitWidth...
     D                 PR                  extproc(*JAVA
     D                                     : PRINTSETUP_CLASS
     D                                     : 'setFitWidth')
     D    width                       5I 0 value
     D HSSFPrintSetup_setFitWidth...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_PRINTSETUP_CLASS
     D                                     : 'setFitWidth')
     D    width                       5I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSPrintSetup_setScale():
      *   Set the scale
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSPrintSetup_setScale...
     D                 PR                  extproc(*JAVA
     D                                     : PRINTSETUP_CLASS
     D                                     : 'setScale')
     D    scale                       5I 0 value
     D HSSFPrintSetup_setScale...
     D                 PR                  extproc(*JAVA
     D                                     : HSSF_PRINTSETUP_CLASS
     D                                     : 'setScale')
     D    scale                       5I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ss_xls2time():
      *    service program utility to convert an Excel time to
      *    an RPG time field
      *
      *    peXls = Number used as a time in Excel
      *
      *  returns the RPG date
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_xls2time     PR              T
     D   peXls                             like(jdouble) value
     D hssf_xls2time   PR              T
     D   peXls                             like(jdouble) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_time2xls():
      *    service program utility to convert an RPG time field
      *    to an Excel time
      *
      *    peTime = RPG time field to convert
      *
      *  returns the Excel time, which is a floating point number
      * (you have to apply a cell format to make it look like a time)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_time2xls     PR                  like(jdouble)
     D   peTime                        T   value
     D hssf_time2xls   PR                  like(jdouble)
     D   peTime                        T   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_xls2ts():
      *    service program utility to convert an Excel date/time value
      *    to an RPG timestamp field
      *
      *    peXls = Excel date/time value to convert
      *
      *  returns the RPG timestamp
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_xls2ts       PR              Z
     D   peXls                             like(jdouble) value
     D hssf_xls2ts     PR              Z
     D   peXls                             like(jdouble) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_ts2xls():
      *    service program utility to convert an RPG timestamp field
      *    to an Excel date/time value
      *
      *    peTS = RPG timestamp field to convert
      *
      *  returns the Excel date/time, which is a floating point number
      * (you have to apply a cell format to make it look like a TS)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_ts2xls       PR                  like(jdouble)
     D   peTS                          Z   value
     D hssf_ts2xls     PR                  like(jdouble)
     D   peTS                          Z   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_style():  shortcut for creating an SSCellStyle object
      *
      *       peBook = workbook to create style for
      *     peNumFmt = string representation of data format
      *       peBold = bold text? *ON=Yes, *OFF=No
      *   peCentered = text is centered? *ON=Yes, *OFF=No
      * peBottomLine = draw line at bottom of cell? *ON=Yes, *OFF=No
      *   peFontSize = (optional) size of font in points.  If not
      *             passed, or set to 0, Excel's default is used.
      *      peBoxed = (optional) draw thin lines around cell?
      *     peItalic = (optional) italicize the font
      *
      *  Returns a new SSCellStyle object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_style        PR                  like(SSCellStyle)
     D   peBook                            like(SSWorkbook)
     D   peNumFmt                  1024A   const varying
     D   peBold                       1N   value
     D   peCentered                   1N   value
     D   peBottomLine                 1N   value
     D   peFontSize                   5I 0 value options(*nopass)
     D   peBoxed                      1N   value options(*nopass)
     D   peItalic                     1n   value options(*nopass)
     D hssf_style      PR                  like(HSSFCellStyle)
     D   peBook                            like(HSSFWorkbook)
     D   peNumFmt                  1024A   const varying
     D   peBold                       1N   value
     D   peCentered                   1N   value
     D   peBottomLine                 1N   value
     D   peFontSize                   5I 0 value options(*nopass)
     D   peBoxed                      1N   value options(*nopass)
     D   peItalic                     1n   value options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ssCellStyle_setFillForegroundColor();
      *  Sets the foreground color of a fill pattern.
      *
      *   fgcolor = (input) index to color pallette entry
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D SSCellStyle_setFillForegroundColor...
     D                 PR                  ExtProc(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setFillForegroundColor')
     D   fgcolor                           like(jShort) value
     D HSSFCellStyle_setFillForegroundColor...
     D                 PR                  ExtProc(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setFillForegroundColor')
     D   fgcolor                           like(jShort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ssCellStyle_setFillBackgroundColor();
      *  Sets the background color of a fill pattern.
      *
      *   bgcolor = (input) index to color pallette entry
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ssCellStyle_setFillBackgroundColor...
     D                 PR                  ExtProc(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setFillBackgroundColor')
     D   bgcolor                           like(jShort) value
     D hssf_setFillBackgroundColor...
     D                 PR                  ExtProc(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setFillBackgroundColor')
     D   bgcolor                           like(jShort) value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ssCellStyle_setFillPattern();
      *  Determine the pattern of a fill
      *
      *   pattern = (input) pattern to set (see SS_PATTERN constants)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ssCellStyle_setFillPattern...
     D                 PR                  ExtProc(*JAVA
     D                                     : CELLSTYLE_CLASS
     D                                     : 'setFillPattern')
     D   pattern                           like(jShort) value
     D hssfCellStyle_setFillPattern...
     D                 PR                  ExtProc(*JAVA
     D                                     : HSSF_CELLSTYLE_CLASS
     D                                     : 'setFillPattern')
     D   pattern                           like(jShort) value


     D SS_PATTERN_NO_FILL...
     D                 C                   0
     D SS_PATTERN_SOLID_FOREGROUND...
     D                 C                   1
     D SS_PATTERN_FINE_DOTS...
     D                 C                   2
     D SS_PATTERN_ALT_BARS...
     D                 C                   3
     D SS_PATTERN_SPARSE_DOTS...
     D                 C                   4
     D SS_THICK_HORZ_BANDS...
     D                 C                   5
     D SS_THICK_VERT_BANDS...
     D                 C                   6
     D SS_THICK_BACKWARD_DIAG...
     D                 C                   7
     D SS_THICK_FORWARD_DIAG...
     D                 C                   8
     D SS_PATTERN_BIG_SPOTS...
     D                 C                   9
     D SS_PATTERN_BRICKS...
     D                 C                   10
     D SS_THIN_HORZ_BANDS...
     D                 C                   11
     D SS_THIN_VERT_BANDS...
     D                 C                   12
     D SS_THIN_BACKWARD_DIAG...
     D                 C                   13
     D SS_THIN_FORWARD_DIAG...
     D                 C                   14
     D SS_PATTERN_SQUARES...
     D                 C                   15
     D SS_PATTERN_DIAMONDS...
     D                 C                   16

     D HSSF_PATTERN_NO_FILL...
     D                 C                   0
     D HSSF_PATTERN_SOLID_FOREGROUND...
     D                 C                   1
     D HSSF_PATTERN_FINE_DOTS...
     D                 C                   2
     D HSSF_PATTERN_ALT_BARS...
     D                 C                   3
     D HSSF_PATTERN_SPARSE_DOTS...
     D                 C                   4
     D HSSF_THICK_HORZ_BANDS...
     D                 C                   5
     D HSSF_THICK_VERT_BANDS...
     D                 C                   6
     D HSSF_THICK_BACKWARD_DIAG...
     D                 C                   7
     D HSSF_THICK_FORWARD_DIAG...
     D                 C                   8
     D HSSF_PATTERN_BIG_SPOTS...
     D                 C                   9
     D HSSF_PATTERN_BRICKS...
     D                 C                   10
     D HSSF_THIN_HORZ_BANDS...
     D                 C                   11
     D HSSF_THIN_VERT_BANDS...
     D                 C                   12
     D HSSF_THIN_BACKWARD_DIAG...
     D                 C                   13
     D HSSF_THIN_FORWARD_DIAG...
     D                 C                   14
     D HSSF_PATTERN_SQUARES...
     D                 C                   15
     D HSSF_PATTERN_DIAMONDS...
     D                 C                   16


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ss_addPicture():  This loads a picture into the Excel
      *                   workbook file. (However, you still need
      *                   to use an anchor and drawing patriarch
      *                   to make the picture show on the screen.)
      *
      *    stmf = (input) IFS pathname to picture file
      *  format = (input) format of picture (one of the HSSF_PIC_xxx
      *                     constants, below)
      *
      *  Returns the index to the picture in the workbook
      *  or -1 upon failure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D ss_addPicture...
     D                 PR            10i 0
     D   book                              like(SSWorkbook) const
     D   stmf                      5000a   varying const options(*varsize)
     D   format                      10i 0 value
     D hssf_addPicture...
     D                 PR            10i 0
     D   book                              like(HSSFWorkbook) const
     D   stmf                      5000a   varying const options(*varsize)
     D   format                      10i 0 value


      *                 Extended Windows Metafile (EMF)
     D SS_PIC_EMF      C                   2
      *                 Windows Metafile (WMF)
     D SS_PIC_WMF      C                   3
      *                 Macintosh PICT format (PICT)
     D SS_PIC_PICT     C                   4
      *                 Joint Photo Experts Group (JPEG/JPG)
     D SS_PIC_JPEG     C                   5
      *                 Portable Network Graphics (PNG)
     D SS_PIC_PNG      C                   6
      *                 Device Independent Bitmap (DIB/BMP)
     D SS_PIC_DIB      C                   7

      *                 Extended Windows Metafile (EMF)
     D HSSF_PIC_EMF    C                   2
      *                 Windows Metafile (WMF)
     D HSSF_PIC_WMF    C                   3
      *                 Macintosh PICT format (PICT)
     D HSSF_PIC_PICT   C                   4
      *                 Joint Photo Experts Group (JPEG/JPG)
     D HSSF_PIC_JPEG   C                   5
      *                 Portable Network Graphics (PNG)
     D HSSF_PIC_PNG    C                   6
      *                 Device Independent Bitmap (DIB/BMP)
     D HSSF_PIC_DIB    C                   7

      /define HSSF_H
      /endif
