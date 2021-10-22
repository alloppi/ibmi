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
      * Utility routines for working with HSSF to create Excel
      * spreadsheets from ILE RPG.
      *
      *  Licensed program requirements to compile:
      *   - ILE RPG Compiler (57xx-WDS, opt 31)
      *   - IBM Developer Kit for Java (57xx-JV1, *base)
      *   - One of the Java Developer Kit 5.0 or higher (57xx-JV1, opt 7+)
      *   - System Openness Includes (57xx-SS1, opt 13)
      *   - QShell (57xx-SS1, opt 30) not required, but highly recommended
      *
      *  Licensed program requirements at run-time:
      *   - One of the Java Developer Kits (57xx-JV1 opt 5,6,7, or 8)
      *   - Apache POI version 3.5 or higher (in CLASSPATH)
      *
      *  To use the XLSX (New Excel in XML format) support
      *  some additional JAR files are required.  (listed below)
      *
      *  This service program was tested with the following JAR files.
      *  Newer versions of these JAR files may also work, but these
      *  are the versions I tested it with:
      *
      *  FROM APACHE POI 3.6:
      *   - poi-3.6-20091214.jar
      *   - poi-contrib-3.6-20091214.jar
      *   - poi-examples-3.6-20091214.jar
      *   - poi-ooxml-3.6-20091214.jar
      *   - poi-ooxml-schemas-3.6-20091214.jar
      *   - poi-scratchpad-3.6-20091214.jar
      *
      *  FROM DOM4J 1.6.1 **:
      *   - dom4j-1.6.1.jar
      *
      *  FROM XMLBEANS 2.5.0 **:
      *   - jsr173_1.0_api.jar
      *   - xbean.jar
      *
      *  ** = extra JAR files required for XSSF (Office XML) format.
      *
      *  To compile:
      *   - verify that HSSF_H and IFSIO_H members have been uploaded
      *      to a QRPGLESRC file in your *LIBL
      *   - verify that the HSSFR4.bnd file has been uploaded with
      *      member name HSSFR4 to a QSRVSRC source file in your *LIBL
      *
      *>     CRTRPGMOD MODULE(HSSFR4) SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *
      *>     CRTSRVPGM SRVPGM(HSSFR4) ACTGRP(HSSFR4) -
      *>               EXPORT(*SRCFILE) SRCFILE(QSRVSRC) -
      *>               TEXT('Utilties for creating Excel spreadsheets')
      *
      *    Binding directory:
      *      - these need to be run the first time only
      *> ign:  CRTBNDDIR BNDDIR(HSSF)
      *> ign:  ADDBNDDIRE BNDDIR(HSSF) OBJ((HSSFR4 *SRVPGM))
      *

     H NOMAIN OPTION(*NODEBUGIO: *SRCSTMT)
     H THREAD(*SERIALIZE)
     H BNDDIR('QC2LE')

     D start_jvm       PR              *
     D attach_jvm      PR              *
     D jni_checkError  PR             1N
     D asc             PR            80a   varying
     D  str                          80a   varying const options(*varsize)
     D  slash                         1n   const options(*nopass)
     D ReportError     PR
     D   msg                        200a   varying const

     D String_getBytes...
     D                 pr          1024A   varying
     D                                     extproc(*JAVA:
     D                                     'java.lang.String':
     D                                     'getBytes')

      /define OS400_JVM_12
      /define JNI_COPY_ARRAY_FUNCTIONS
      /copy qsysinc/qrpglesrc,jni

      /copy POI36,hssf_h
      /copy POI36,ifsio_h


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
     P ss_NewSheet     B                   EXPORT
     D ss_NewSheet     PI                  like(SSSheet)
     D   peBook                            like(SSWorkbook)
     D   peName                    1024A   const varying

     D myName          s                   like(jString)
     D mySheet         s                   like(SSSheet)
      /free
         myName = new_String(peName);
         mySheet = ssWorkbook_createSheet(peBook: myName);
         hssf_freeLocalRef(myName);
         return mySheet;
      /end-free
     P                 E

     P hssf_NewSheet   B                   EXPORT
     D hssf_NewSheet   PI                  like(HSSFSheet)
     D   peBook                            like(HSSFWorkbook)
     D   peName                    1024A   const varying
     c                   return    ss_NewSheet(peBook: peName)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_save(): Save Workbook to disk
      *
      *    peBook = workbook to add sheet to
      *    peFile = IFS path/filename to save workbook as
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_save         B                   EXPORT
     D ss_save         PI
     D   peBook                            like(SSWorkbook)
     D   peFilename                1024A   const varying

     D myStr           s                   like(jString)
     D myFile          s                   like(jFileOutputStream)
      /free
         myStr = new_String(%trimr(peFilename));
         myFile = new_FileOutputStream(myStr);
         ssWorkbook_write(peBook: myFile);
         FileOutputStream_close(myFile);
         hssf_freeLocalRef(myFile);
         hssf_freeLocalRef(myStr);
      /end-free
     P                 E

     P hssf_save       B                   EXPORT
     D hssf_save       PI
     D   peBook                            like(HSSFWorkbook)
     D   peFilename                1024A   const varying
     c                   callp     ss_save(peBook: peFilename)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_merge(): Merge cells on a sheet
      *
      *    peSheet = sheet containing cells to merge
      *  peRowFrom = row of upper-left corner of area to merge
      *  peColFrom = col of upper-left corner of area to merge
      *  peRowTo   = row of lower-right corner of area to merge
      *  peColTo   = col of lower-right corner of area to merge
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_merge        B                   EXPORT
     D ss_merge        PI
     D   peSheet                           like(HSSFSheet)
     D   peRowFrom                         like(jint) value
     D   peColFrom                         like(jshort) value
     D   peRowTo                           like(jint) value
     D   peColTo                           like(jshort) value

     D myRegion        s                   like(CellRangeAddress)

      /free
         myRegion = new_CellRangeAddress( peRowFrom
                                        : peRowTo
                                        : peColFrom
                                        : peColTo);
         SSSheet_addMergedRegion(peSheet: myRegion);
         hssf_freeLocalRef(myRegion);
      /end-free
     P                 E

     P hssf_merge      B                   EXPORT
     D hssf_merge      PI
     D   s                                 like(HSSFSheet)
     D   rf                                like(jint) value
     D   cf                                like(jshort) value
     D   rt                                like(jint) value
     D   ct                                like(jshort) value
     c                   callp     ss_merge(s: rf: cf: rt: ct)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_text(): Shortcut for inserting a new cell that contains
      *        a string value into a given row of a sheet
      *
      *    peRow = Row object that cell should be created in
      *    peCol = column number of new cell
      * peString = string to place in cell
      *  peStyle = cell style object to associate with cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_text         B                   EXPORT
     D ss_text         PI
     D   peRow                             like(SSRow)
     D   peCol                        5I 0 value
     D   peString                  1024A   varying const
     D   peStyle                           like(SSCellStyle)

     D myStr           s                   like(jString)
     D myCell          s                   like(SSCell)

      /free
         myCell = SSRow_createCell(peRow: peCol);
         SSCell_setCellType(myCell: CELL_TYPE_STRING);
         myStr = new_String(peString);
         SSCell_setCellValueStr(myCell: myStr);
         SSCell_setCellStyle(myCell: peStyle);
         ss_freeLocalRef(myStr);
         ss_freeLocalRef(myCell);
      /end-free
     P                 E

     P hssf_text       B                   EXPORT
     D hssf_text       PI
     D   r                                 like(HSSFRow)
     D   c                            5I 0 value
     D   str                       1024A   varying const
     D   sty                               like(HSSFCellStyle)
     c                   callp     ss_text(r: c: str: sty)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_num():  Shortcut for inserting a new cell that contains
      *        a numeric value into a given row of a sheet
      *
      *    peRow = Row object that cell should be created in
      *    peCol = column number of new cell
      * peNumber = numeric value to place in cell
      *  peStyle = cell style object to associate with cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_num          B                   EXPORT
     D ss_num          PI
     D   peRow                             like(SSRow)
     D   peCol                        5I 0 value
     D   peNumber                     8F   value
     D   peStyle                           like(SSCellStyle)

     D myCell          s                   like(SSCell)

      /free
         myCell = SSRow_createCell(peRow: peCol);
         SSCell_setCellType(myCell: CELL_TYPE_NUMERIC);
         SSCell_setCellValueD(myCell: peNumber);
         SSCell_setCellStyle(myCell: peStyle);
         hssf_freeLocalRef(myCell);
      /end-free
     P                 E

     P hssf_num        B                   EXPORT
     D hssf_num        PI
     D   r                                 like(HSSFRow)
     D   c                            5I 0 value
     D   n                            8F   value
     D   s                                 like(HSSFCellStyle)
     c                   callp     ss_num(r: c: n: s)
     P                 e


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
     P ss_date         B                   EXPORT
     D ss_date         PI
     D   peRow                             like(SSRow)
     D   peCol                        5I 0 value
     D   peDate                        D   value
     D   peStyle                           like(SSCellStyle)

     D myDate          s                   like(jDouble)

      /free
         myDate = ss_date2xls(peDate);
         ss_num(peRow: peCol: myDate: peStyle);
      /end-free
     P                 E

     P hssf_date       B                   EXPORT
     D hssf_date       PI
     D   r                                 like(HSSFRow)
     D   c                            5I 0 value
     D   d                             D   value
     D   s                                 like(HSSFCellStyle)
     c                   callp     ss_date(r: c: d: s)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_date2xls():
      *    service program utility to convert an RPG date to a
      *    number that can be formatted as a date in Excel
      *
      *    peDate = RPG date to convert
      *
      *  returns the date formatted for Excel
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_date2xls     B                   EXPORT
     D ss_date2xls     PI                  like(jdouble)
     D   peDate                        D   value

     D myStrDate       s               d   inz(d'1900-01-01')
     D myDays          s                   like(jdouble)

      ** Dates in Excel are simply double-precision floating point
      ** numbers that represent the number of days since Jan 1, 1900
      ** with a few quirks:
      **     1)  Jan 1st 1900 is considered day #1, not 0.
      **     2)  1900 is counted as a leap year (despite that it wasn't)
      **     3)  Any fraction is considered a time of day.  For example,
      **              1.5 would be noon on Jan 1st, 1900.
      **

      /free

         myDays = %diff(peDate: myStrDate: *DAYS) + 1;

         // Excel incorrectly thinks that 1900-02-29 is
         //  a valid date.

         if (peDate > d'1900-02-28');
              myDays = myDays + 1;
         endif;

         return myDays;
      /end-free
     P                 E

     P hssf_date2xls   B                   EXPORT
     D hssf_date2xls   PI                  like(jdouble)
     D   peDate                        D   value
     c                   return    ss_date2xls(peDate)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_xls2date():
      *    service program utility to convert an Excel date to
      *    an RPG date field
      *
      *    peXls = Number used as a date in Excel
      *
      *  returns the RPG date
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_xls2date     B                   EXPORT
     D ss_xls2date     PI              D
     D   peXls                             like(jdouble) value

     D wwStrDate       s               d   inz(d'1900-01-01')
     D wwDate          s               d

      **
      ** See ss_date2xls for comments on how the Excel date format works
      **
      /free

         wwDate = wwStrDate + %days(%int(peXls) - 1);

         // Excel incorrectly thinks that 1900-02-29 is
         //  a valid date.

         if (wwDate > d'1900-02-28');
              wwDate = wwDate - %days(1);
         endif;

         return wwDate;
      /end-free
     P                 E

     P hssf_xls2date   B                   EXPORT
     D hssf_xls2date   PI              D
     D   peXls                             like(jdouble) value
     c                   return    ss_xls2date(peXls)
     p                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ss_xls2time():
      *    service program utility to convert an Excel time to
      *    an RPG time field
      *
      *    peXls = Number used as a time in Excel
      *
      *  returns the RPG date
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_xls2time     B                   EXPORT
     D ss_xls2time     PI              T
     D   peXls                             like(jdouble) value

     D wwFract         s              8F
     D wwSecs          s             10I 0
     D wwTime          s               T
     D SECSPERDAY      c                   86400

      **
      ** See ss_date2xls for comments on how the Excel date/time
      ** format works.
      **
      /free
         wwFract = peXls - %int(peXls);
         wwSecs  = %inth(SECSPERDAY * wwFract);
         wwTime  = t'00.00.00' + %seconds(wwSecs);
         return wwTime;
      /end-free
     P                 E

     P hssf_xls2time   B                   EXPORT
     D hssf_xls2time   PI              T
     D   peXls                             like(jdouble) value
     c                   return    ss_xls2time(peXls)
     P                 E


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
     P ss_time2xls     B                   EXPORT
     D ss_time2xls     PI                  like(jdouble)
     D   peTime                        T   value

     D wwFract         s                   like(jdouble)
     D wwSecs          s             10I 0
     D SECSPERDAY      c                   86400

      **
      ** See ss_date2xls for comments on how the Excel date/time
      ** format works.
      **
      /free
         wwSecs  = %diff(peTime: t'00.00.00': *SECONDS);
         wwFract = wwSecs / SECSPERDAY;
         return wwFract;
      /end-free
     P                 E

     P hssf_time2xls   B                   EXPORT
     D hssf_time2xls   PI                  like(jdouble)
     D   peTime                        T   value
     c                   return    hssf_time2xls(peTime)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_xls2ts():
      *    service program utility to convert an Excel date/time value
      *    to an RPG timestamp field
      *
      *    peXls = Excel date/time value to convert
      *
      *  returns the RPG timestamp
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_xls2ts       B                   EXPORT
     D ss_xls2ts       PI              Z
     D   peXls                             like(jdouble) value
     D wwDate          s               D
     D wwTime          s               T
     D wwTs            s               Z
      **
      ** See ss_date2xls for comments on how the Excel date/time
      ** format works.
      **
      /free
          wwDate = hssf_xls2date(peXls);
          wwTime = hssf_xls2time(peXls);
          wwTs   = wwDate + wwTime;
          return wwTs;
      /end-free
     P                 E

     P hssf_xls2ts     B                   EXPORT
     D hssf_xls2ts     PI              Z
     D   peXls                             like(jdouble) value
     c                   return    ss_xls2ts(peXls)
     P                 E


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
     P ss_ts2xls       B                   EXPORT
     D ss_ts2xls       PI                  like(jdouble)
     D   peTS                          Z   value
     D wwDate          s                   like(jdouble)
     D wwTime          s                   like(jdouble)
      **
      ** See hssf_date2xls for comments on how the Excel date/time
      ** format works.
      **
      /free
          wwTime = hssf_time2xls(%time(peTS));
          wwDate = hssf_date2xls(%date(peTS));
          return wwDate + wwTime;
      /end-free
     P                 E

     P hssf_ts2xls     B                   EXPORT
     D hssf_ts2xls     PI                  like(jdouble)
     D   peTS                          Z   value
     c                   return    ss_ts2xls(peTS)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_formula(): Shortcut for inserting a new cell that contains
      *        a formula into a given row of a sheet
      *
      *     peRow = Row object that cell should be created in
      *     peCol = column number of new cell
      * peFormula = formula to place in cell
      *   peStyle = cell style object to associate with cell
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_formula      B                   EXPORT
     D ss_formula      PI
     D   peRow                             like(SSRow)
     D   peCol                        5I 0 value
     D   peFormula                 1024A   varying const
     D   peStyle                           like(SSCellStyle)

     D wwStr           s                   like(jString)
     D wwCell          s                   like(SSCell)

      /free
         wwCell = SSRow_createCell(peRow: peCol);
         SSCell_setCellType(wwCell: CELL_TYPE_FORMULA);
         wwStr = new_String(peFormula);
         SSCell_setCellFormula(wwCell: wwStr);
         SSCell_setCellStyle(wwCell: peStyle);
         ss_freeLocalRef(wwStr);
         ss_freeLocalRef(wwCell);
      /end-free
     P                 E

     P hssf_formula    B                   EXPORT
     D hssf_formula    PI
     D   r                                 like(HSSFRow)
     D   c                            5I 0 value
     D   f                         1024A   varying const
     D   s                                 like(HSSFCellStyle)
     c                   callp     ss_formula(r: c: f: s)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_cellName(): Convert POI y,x coordinates into a cell name
      *     (example: 0,0 becomes A1, 110,24 becomes Y111)
      *
      *        peRow = row number (A=0, B=1, etc)
      *        peCol = column number
      *
      *  Returns the alphanumeric cellname
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_cellName     B                   EXPORT
     D ss_cellName     PI            10A   varying
     D  peRow                         5I 0 value
     D  peCol                         5I 0 value

     D dsAlphabet      ds                  qualified static
     D   whole                       26A   inz('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     D   letter                       1A   dim(26) overlay(whole)

     D wwRem           s              5I 0
     D wwCN            s             10A   varying

      /free

         peRow+=1;
         peCol+=1;

         wwCN = '';
         dou peCol = 0;
            wwRem = %rem(peCol: 26);
            peCol = %div(peCol: 26);
            if (wwRem = 0);
                wwRem = 26;
                peCol -= 1;
            endif;
            wwCN = dsAlphabet.letter(wwRem) + wwCN;
         enddo;

         wwCN = wwCN + %char(peRow);
         return wwCN;

      /end-free
     P                 E

     P hssf_cellName   B                   EXPORT
     D hssf_cellName   PI            10A   varying
     D  r                             5I 0 value
     D  c                             5I 0 value
     c                   return    ss_cellName(r: c)
     P                 E


      *-----------------------------------------------------------------
      *  hssf_get_jni_env():
      *
      *  Service program utility to get a pointer to the JNI environment
      *  you'll need this pointer in order to call many of the JNI
      *  routines.
      *
      *  returns the pointer, or *NULL upon error
      *-----------------------------------------------------------------
     P hssf_get_jni_env...
     P                 B                   EXPORT
     D hssf_get_jni_env...
     D                 PI              *

     D wwEnv           s               *

      /free
        wwEnv = attach_jvm();
        if (wwEnv = *NULL);
           wwEnv = start_jvm();
        endif;

        return wwEnv;
      /end-free
     P                 E


      *-----------------------------------------------------------------
      *  hssf_freeLocalRef(Ref)
      *
      *  Service program utility to free a local reference.
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
      *               callp  freeLocalRef(ObjectName)
      *
      *      for example, if you create a String, use it to create
      *        an output stream, and then don't need the string anymore,
      *        you might do something like this:
      *
      *               eval   Blah = new_String('/path/to/myfile.txt')
      *               eval   File = new_FileOutputStream(Blah)
      *               callp  freeLocalRef(Blah)
      *-----------------------------------------------------------------
     P hssf_freeLocalRef...
     P                 B                   EXPORT
     D hssf_freeLocalRef...
     D                 PI
     D    peRef                            like(jobject)
     D wwEnv           s               *   static inz(*null)

      /free

          if (wwEnv = *NULL);
              wwEnv = hssf_get_jni_env();
          endif;

          JNIENV_P = wwEnv;
          DeleteLocalRef(wwEnv: peRef);

      /end-free
     P                 E


      *-----------------------------------------------------------------
      * hssf_begin_object_group():  Start a new group of objects
      *    which will all be freed when hssf_end_object_group()
      *    gets called.
      *
      *   peCapacity = maximum number of objects that can be
      *        referenced within this object group.
      *
      *  NOTE: According to the 1.2 JNI Spec, you can create more
      *        objects in the new frame than peCapacity allows.  The
      *        peCapacity is the guarenteed number.   When no object
      *        groups are used, 16 references are guarenteed, so if
      *        you specify 16 here, that would be comparable to a
      *        "default value".
      *
      * Returns 0 if successful, or -1 upon error
      *-----------------------------------------------------------------
     P hssf_begin_object_group...
     P                 B                   EXPORT
     D hssf_begin_object_group...
     D                 PI            10I 0
     D    peCapacity                 10I 0 value

     D wwEnv           s               *
     D wwRC            s             10I 0

      /free

       wwEnv = hssf_get_jni_env();
       if (wwEnv = *NULL);
           return -1;
       endif;

       JNIENV_P = wwEnv;

       if  ( PushLocalFrame (wwEnv: peCapacity) <> JNI_OK );
           return -1;
       else;
           return 0;
       endif;

      /end-free
     P                 E


      *-----------------------------------------------------------------
      * hssf_end_object_group():  Frees all Java objects that
      *    have been created since calling hssf_begin_object_group()
      *
      *        peOldObj = (see below)
      *        peNewObj = Sometimes it's desirable to preserve one
      *            object by moving it from the current object group
      *            to the parent group.   These parameters allow you
      *            to make that move.
      *
      * Returns 0 if successful, or -1 upon error
      *-----------------------------------------------------------------
     P hssf_end_object_group...
     P                 B                   EXPORT
     D hssf_end_object_group...
     D                 PI            10I 0
     D   peOldObj                          like(jObject) const
     D                                     options(*nopass)
     D   peNewObj                          like(jObject)
     D                                     options(*nopass)

     D wwOld           s                   like(jObject) inz(*NULL)
     D wwNew           s                   like(jObject)

      /free

          JNIENV_p = hssf_get_jni_env();
          if (JNIENV_p = *NULL);
              return -1;
          endif;

          if %parms >= 2;
              wwOld = peOldObj;
          endif;

          wwNew = PopLocalFrame (JNIENV_p: wwOld);

          if %parms >= 2;
              peNewObj = wwNew;
          endif;

          return 0;

      /end-free
     P                 E


      *-----------------------------------------------------------------
      * ss_createDataFormat():  Shortcut routine to create a data fmt
      *
      *        peBook = (input) workbook to create the format in
      *      peFormat = (input) string represending the data format
      *
      * returns the data format's index in the workbook
      *-----------------------------------------------------------------
     P ss_CreateDataFormat...
     P                 B                   EXPORT
     D ss_CreateDataFormat...
     D                 PI             5I 0
     D   peBook                            like(SSWorkbook) const
     D   peFormat                   100A   varying const

     D retval          s              5I 0
     D df              s                   like(SSDataFormat)
     D TempStr         s                   like(jString)
      /free
         df = SSWorkbook_createDataFormat(peBook);
         TempStr = new_String(peFormat);
         retval = SSDataFormat_getFormat(df: TempStr);
         ss_freelocalref(TempStr);
         ss_freelocalref(df);
         return retval;
      /end-free
     P                 E

     P hssf_CreateDataFormat...
     P                 B                   EXPORT
     D hssf_CreateDataFormat...
     D                 PI             5I 0
     D   peBook                            like(HSSFWorkbook) const
     D   peFormat                   100A   varying const
     c                   return    ss_CreateDataFormat(peBook: peFormat)
     P                 E


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
     P ss_CreateFont...
     P                 B                   EXPORT
     D ss_CreateFont...
     D                 PI                  like(SSFont)
     D   peBook                            like(SSWorkbook) const
     D   peName                     100A   varying const options(*omit)
     D   pePointSize                  5I 0 const options(*omit)
     D   peBold                       5I 0 const options(*omit)
     D   peUnderline                  1A   const options(*omit)
     D   peItalic                     1N   const options(*omit)
     D   peStrikeout                  1N   const options(*omit)
     D   peColor                      5I 0 const options(*omit)
     D   peTypeOffset                 5I 0 const options(*omit)

     D TempStr         s                   like(jString)
     D f               s                   like(HSSFFont)
      /free

         f = SSWorkbook_createFont(peBook);

         if (%addr(peName) <> *NULL);
            TempStr = new_String(peName);
            SSFont_setFontName(f: TempStr);
            ss_freelocalref(TempStr);
         endif;

         if (%addr(pePointSize) <> *NULL);
             SSFont_setFontHeightInPoints(f: pePointSize);
         endif;

         if (%addr(peBold) <> *NULL);
             SSFont_setBoldweight(f: peBold);
         endif;

         if (%addr(peUnderline) <> *NULL);
             SSFont_setUnderline(f: peUnderLine);
         endif;

         if (%addr(peItalic) <> *NULL);
             SSFont_setItalic(f: peItalic);
         endif;

         if (%addr(peStrikeout) <> *NULL);
             SSFont_setStrikeout(f: peStrikeout);
         endif;

         if (%addr(peColor) <> *NULL);
             SSFont_setColor(f: peColor);
         endif;

         if (%addr(peTypeOffset) <> *NULL);
             SSFont_setTypeOffset(f: peTypeOffset);
         endif;

         return f;

      /end-free
     P                 E

     P hssf_CreateFont...
     P                 B                   EXPORT
     D hssf_CreateFont...
     D                 PI                  like(HSSFFont)
     D   a                                 like(HSSFWorkbook) const
     D   b                          100A   varying const options(*omit)
     D   c                            5I 0 const options(*omit)
     D   d                            5I 0 const options(*omit)
     D   e                            1A   const options(*omit)
     D   f                            1N   const options(*omit)
     D   g                            1N   const options(*omit)
     D   h                            5I 0 const options(*omit)
     D   i                            5I 0 const options(*omit)
      /free
        return ss_createFont(a: b: c: d: e: f: g: h: i);
      /end-free
     P                 E


      *-----------------------------------------------------------------
      *  start_jvm():   Start the Java Virtual Machine (JVM)
      *
      *  NOTE: Originally, this called JNI routines to start a new JVM,
      *        but that meant that a classpath and other options needed
      *        to be set manually in the JNI invocation.
      *
      *        I decided that it would be better to reduce the complexity
      *        and let RPG start the JVM, so I merely create & destroy
      *        a string here so that RPG will automatically start the
      *        JVM for me.
      *
      *  returns a pointer to the JNI environment
      *          or *NULL upon failure.
      *-----------------------------------------------------------------
     P start_jvm       B
     D start_jvm       PI              *

     D SndPgmMsg       PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                     80A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                32767A   options(*varsize)

     D my_Mode         C                   const(438)
     D my_tmpnam       PR              *   extproc('_C_IFS_tmpnam')
     D   string                      39A   options(*omit)

     D ErrorNull       ds
     D   BytesProv                   10I 0 inz(0)
     D   BytesAvail                  10I 0 inz(0)

     D fd              s             10I 0
     D filename        s               *
     D key             s              4A
     D wwStr           s                   like(jString)

      /free

         // ---------------------------------------------------------
         // The JVM can encounter I/O errors if there aren't at least
         // 3 descriptors open. This code makes sure that there are
         // at least 3.
         // ---------------------------------------------------------

         fd = open('/dev/null': O_RDWR);
         if (fd = -1);
             filename = my_tmpnam(*omit);
             fd = open(filename: O_RDWR+O_CREAT: my_Mode);
             unlink(filename);
         endif;

         dow ( fd < 2 );
            if (fd = -1);
                SndPgmMsg( 'CPF9897'
                         : 'QCPFMSG   *LIBL'
                         : 'Unable to open three descriptors!'
                         : 80
                         : '*ESCAPE'
                         : '*PGMBDY'
                         : 1
                         : Key
                         : ErrorNull );
                return *NULL;
            endif;
            fd = dup(fd);
         enddo;


         // ---------------------------------------------------------
         //  Create a string -- this'll trigger RPG to create
         //  the JVM for us.
         // ---------------------------------------------------------

         wwStr = new_String('Temp String');

         // ---------------------------------------------------------
         //   Get the JNI environment for the newly creaed JVM,
         //   and use it to free up the string.
         // ---------------------------------------------------------

         JNIENV_P = attach_jvm();
         DeleteLocalRef(JNIENV_P: wwStr);

         return JNIENV_P;
      /end-free
     P                 E


      *-----------------------------------------------------------------
      * attach_jvm():  Attach to JVM if it's running
      *
      * Returns a pointer to the JNI environment, or *NULL upon error
      *-----------------------------------------------------------------
     P attach_jvm      B
     D attach_jvm      PI              *

     D dsAtt           ds                  likeds(JavaVMAttachArgs)
     D wwJVM           s                   like(JavaVM_p) dim(1)
     D wwJVMc          s                   like(jSize)
     D wwEnv           s               *   inz(*null)
     D wwRC            s             10I 0
      /free

        monitor;
           wwRC = JNI_GetCreatedJavaVMs(wwJVM: 1: wwJVMc);

           if (wwRC <> JNI_OK  or  wwJVMc = 0);
               return *NULL;
           endif;

           JavaVM_P = wwJVM(1);
           dsAtt = *ALLx'00';
           dsAtt.version = JNI_VERSION_1_2;

           wwRC = AttachCurrentThread (wwJVM(1): wwEnv: %addr(dsAtt));
           if (wwRC <> JNI_OK);
               wwEnv = *NULL;
           endif;

        on-error;
           wwEnv = *NULL;
        endmon;

        return wwEnv;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_setLeft(): Wrapper around the Java routine
      *                      for SSHeader_setLeft()
      *
      *     hdr = (input) header to set the left string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_setLeft...
     P                 B                   export
     D SS_header_setLeft...
     D                 PI
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D tempHdr         s                   like(SSHeader)
     D tempStr         s                   like(jString)
      /free
          tempHdr = SSSheet_getHeader(sheet);
          tempStr = new_String(string);
          SSHeader_setLeft(tempHdr: tempStr);
          ss_freelocalref(tempStr);
          ss_freelocalref(tempHdr);
      /end-free
     P                 E

     P HSSF_header_setLeft...
     P                 B                   export
     D HSSF_header_setLeft...
     D                 PI
     D    a                                like(HSSFSheet) const
     D    b                        1024A   const varying options(*varsize)
     C                   callp     ss_header_setLeft(a: b)
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_setCenter(): Wrapper around the Java routine
      *                          for SSHeader_setCenter()
      *
      *     hdr = (input) header to set the center string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_setCenter...
     P                 B                   export
     D SS_header_setCenter...
     D                 PI
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D tempHdr         s                   like(SSHeader)
     D tempStr         s                   like(jString)
      /free
          tempHdr = SSSheet_getHeader(sheet);
          tempStr = new_String(string);
          SSHeader_setCenter(tempHdr: tempStr);
          hssf_freelocalref(tempStr);
          hssf_freelocalref(tempHdr);
      /end-free
     P                 E

     P HSSF_header_setCenter...
     P                 B                   export
     D HSSF_header_setCenter...
     D                 PI
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)
     C                   callp     ss_header_setCenter(Sheet: String)
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_setRight(): Wrapper around the Java routine
      *                       that sets the right-hand portion
      *                       of the page header
      *
      *     hdr = (input) header to set the right string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_setRight...
     P                 B                   export
     D SS_header_setRight...
     D                 PI
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D tempHdr         s                   like(SSHeader)
     D tempStr         s                   like(jString)
      /free
        tempHdr = SSSheet_getHeader(sheet);
        tempStr = new_String(string);
        SSHeader_setRight(tempHdr: tempStr);
        ss_freelocalref(tempStr);
        ss_freelocalref(tempHdr);
      /end-free
     P                 E

     P HSSF_header_setRight...
     P                 B                   export
     D HSSF_header_setRight...
     D                 PI
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)
      /free
        ss_Header_setRight(sheet: string);
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_date(): Retrieve special characters that
      *                   indicate the current date in a
      *                   header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_date...
     P                 B                   export
     D SS_header_date...
     D                 PI          1024A   varying
      /free
        return String_getBytes(SSHeaderFooter_Date());
      /end-free
     P                 E

     P HSSF_header_date...
     P                 B                   export
     D HSSF_header_date...
     D                 PI          1024A   varying
      /free
        return String_getBytes(HSSFHeader_date());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_file(): Retrieve special characters that
      *                   indicate the current filename in
      *                   a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_file...
     P                 B                   export
     D SS_header_file...
     D                 PI          1024A   varying
      /free
        return String_getBytes(SSHeaderFooter_file());
      /end-free
     P                 E

     P HSSF_header_file...
     P                 B                   export
     D HSSF_header_file...
     D                 PI          1024A   varying
      /free
        return String_getBytes(HSSFHeader_file());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_font(): Retrieve special characters that
      *                   indicate a font of a particular
      *                   name & style in a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_font...
     P                 B                   export
     D SS_header_font...
     D                 PI          1024A   varying
     D    font                     1024A   varying const
     D    style                    1024A   varying const
     D f               s                   like(jString)
     D s               s                   like(jString)
     D retval          s           1024A   varying
      /free
        f = new_String(font);
        s = new_String(style);
        retval = String_getBytes(SSHeaderFooter_font(f:s));
        hssf_freeLocalRef(f);
        hssf_freeLocalRef(s);
        return retval;
      /end-free
     P                 E

     P HSSF_header_font...
     P                 B                   export
     D HSSF_header_font...
     D                 PI          1024A   varying
     D    font                     1024A   varying const
     D    style                    1024A   varying const
     D f               s                   like(jString)
     D s               s                   like(jString)
     D retval          s           1024A   varying
      /free
        f = new_String(font);
        s = new_String(style);
        retval = String_getBytes(HSSFHeader_font(f:s));
        hssf_freeLocalRef(f);
        hssf_freeLocalRef(s);
        return retval;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_fontSize(): Retrieve special characters
      *                       that set the font size in a
      *                       header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_fontSize...
     P                 B                   export
     D SS_header_fontSize...
     D                 PI          1024A   varying
     D    size                        5U 0 value
      /free
        return String_getBytes(SSHeaderFooter_fontSize(size));
      /end-free
     P                 E

     P HSSF_header_fontSize...
     P                 B                   export
     D HSSF_header_fontSize...
     D                 PI          1024A   varying
     D    size                        5U 0 value
      /free
        return String_getBytes(HSSFHeader_fontSize(size));
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_numPages(): Retrieve special characters
      *                       that insert the number of pages
      *                       in the doc into a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_numPages...
     P                 B                   export
     D SS_header_numPages...
     D                 PI          1024A   varying
      /free
        return String_getBytes(SSHeaderFooter_numPages());
      /end-free
     P                 E

     P HSSF_header_numPages...
     P                 B                   export
     D HSSF_header_numPages...
     D                 PI          1024A   varying
      /free
        return String_getBytes(HSSFHeader_numPages());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_page(): Retrieve special characters
      *                   that insert the current page
      *                   number into a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_page...
     P                 B                   export
     D SS_header_page...
     D                 PI          1024A   varying
      /free
        return String_getBytes(SSHeaderFooter_page());
      /end-free
     P                 E

     P HSSF_header_page...
     P                 B                   export
     D HSSF_header_page...
     D                 PI          1024A   varying
      /free
        return String_getBytes(HSSFHeader_page());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_sheetName(): Retrieve special characters
      *                        that insert the current sheet
      *                        name (or "tab name") into a
      *                        header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_sheetName...
     P                 B                   export
     D SS_header_sheetName...
     D                 PI          1024A   varying
      /free
        return String_getBytes(SSHeaderFooter_sheetName());
      /end-free
     P                 E

     P HSSF_header_sheetName...
     P                 B                   export
     D HSSF_header_sheetName...
     D                 PI          1024A   varying
      /free
        return String_getBytes(HSSFHeader_sheetName());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_header_time(): Retrieve special characters
      *                   that insert the current time
      *                   into a header string.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_header_time...
     P                 B                   export
     D SS_header_time...
     D                 PI          1024A   varying
      /free
        return String_getBytes(SSHeaderFooter_time());
      /end-free
     P                 E

     P HSSF_header_time...
     P                 B                   export
     D HSSF_header_time...
     D                 PI          1024A   varying
      /free
        return String_getBytes(HSSFHeader_time());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_setLeft(): set the left-hand data printed
      *                      in the page footer
      *
      *     hdr = (input) header to set the left string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_setLeft...
     P                 B                   export
     D SS_footer_setLeft...
     D                 PI
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D tempFtr         s                   like(SSFooter)
     D tempStr         s                   like(jString)
      /free
          tempFtr = SSSheet_getFooter(sheet);
          tempStr = new_String(string);
          SSFooter_setLeft(tempFtr: tempStr);
          ss_freelocalref(tempStr);
          ss_freelocalref(tempFtr);
      /end-free
     P                 E

     P HSSF_footer_setLeft...
     P                 B                   export
     D HSSF_footer_setLeft...
     D                 PI
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)
      /free
          ss_footer_setLeft(sheet: string);
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_setCenter(): set the string that appears
      *                        in the center of the page footer
      *
      *     hdr = (input) header to set the center string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_setCenter...
     P                 B                   export
     D SS_footer_setCenter...
     D                 PI
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D tempFtr         s                   like(SSFooter)
     D tempStr         s                   like(jString)
      /free
          tempFtr = SSSheet_getFooter(sheet);
          tempStr = new_String(string);
          SSFooter_setCenter(tempFtr: tempStr);
          ss_freelocalref(tempStr);
          ss_freelocalref(tempFtr);
      /end-free
     P                 E

     P HSSF_footer_setCenter...
     P                 B                   export
     D HSSF_footer_setCenter...
     D                 PI
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)
      /free
         ss_footer_setCenter(sheet: string);
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_setRight(): set the string to appear in the
      *                       right-hand corner of the page
      *                       footer.
      *
      *     hdr = (input) header to set the right string for
      *  string = (input) string to set
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_setRight...
     P                 B                   export
     D SS_footer_setRight...
     D                 PI
     D    sheet                            like(SSSheet) const
     D    string                   1024A   const varying options(*varsize)
     D tempFtr         s                   like(SSFooter)
     D tempStr         s                   like(jString)
      /free
          tempFtr = SSSheet_getFooter(sheet);
          tempStr = new_String(string);
          SSFooter_setRight(tempFtr: tempStr);
          ss_freelocalref(tempStr);
          ss_freelocalref(tempFtr);
      /end-free
     P                 E

     P HSSF_footer_setRight...
     P                 B                   export
     D HSSF_footer_setRight...
     D                 PI
     D    sheet                            like(HSSFSheet) const
     D    string                   1024A   const varying options(*varsize)
      /free
          ss_footer_setRight(sheet: string);
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_date(): Retrieve special characters that
      *                   indicate the current date in a
      *                   header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_date...
     P                 B                   export
     D SS_footer_date...
     D                 PI          1024A   varying
      /free
         return ss_header_date();
      /end-free
     P                 E

     P HSSF_footer_date...
     P                 B                   export
     D HSSF_footer_date...
     D                 PI          1024A   varying
      /free
          return String_getBytes(HSSFFooter_date());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_file(): Retrieve special characters that
      *                   indicate the current filename in
      *                   a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_file...
     P                 B                   export
     D SS_footer_file...
     D                 PI          1024A   varying
      /free
          return ss_header_file();
      /end-free
     P                 E

     P HSSF_footer_file...
     P                 B                   export
     D HSSF_footer_file...
     D                 PI          1024A   varying
      /free
          return String_getBytes(HSSFFooter_file());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_font(): Retrieve special characters that
      *                   indicate a font of a particular
      *                   name & style in a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_font...
     P                 B                   export
     D SS_footer_font...
     D                 PI          1024A   varying
     D    font                     1024A   varying const
     D    style                    1024A   varying const
     D f               s                   like(jString)
     D s               s                   like(jString)
     D retval          s           1024A   varying
      /free
        return ss_header_font(font: style);
      /end-free
     P                 E

     P HSSF_footer_font...
     P                 B                   export
     D HSSF_footer_font...
     D                 PI          1024A   varying
     D    font                     1024A   varying const
     D    style                    1024A   varying const
     D f               s                   like(jString)
     D s               s                   like(jString)
     D retval          s           1024A   varying
      /free
          f = new_String(font);
          s = new_String(style);
          retval = String_getBytes(HSSFFooter_font(f:s));
          hssf_freeLocalRef(f);
          hssf_freeLocalRef(s);
          return retval;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_fontSize(): Retrieve special characters
      *                       that set the font size in a
      *                       header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_fontSize...
     P                 B                   export
     D SS_footer_fontSize...
     D                 PI          1024A   varying
     D    size                        5U 0 value
      /free
         return ss_header_fontSize(size);
      /end-free
     P                 E

     P HSSF_footer_fontSize...
     P                 B                   export
     D HSSF_footer_fontSize...
     D                 PI          1024A   varying
     D    size                        5U 0 value
      /free
          return String_getBytes(HSSFFooter_fontSize(size));
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_numPages(): Retrieve special characters
      *                       that insert the number of pages
      *                       in the doc into a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_numPages...
     P                 B                   export
     D SS_footer_numPages...
     D                 PI          1024A   varying
      /free
         return ss_header_numPages();
      /end-free
     P                 E

     P HSSF_footer_numPages...
     P                 B                   export
     D HSSF_footer_numPages...
     D                 PI          1024A   varying
      /free
          return String_getBytes(HSSFFooter_numPages());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_page(): Retrieve special characters
      *                   that insert the current page
      *                   number into a header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_page...
     P                 B                   export
     D SS_footer_page...
     D                 PI          1024A   varying
      /free
         return SS_header_page();
      /end-free
     P                 E

     P HSSF_footer_page...
     P                 B                   export
     D HSSF_footer_page...
     D                 PI          1024A   varying
      /free
          return String_getBytes(HSSFFooter_page());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_sheetName(): Retrieve special characters
      *                        that insert the current sheet
      *                        name (or "tab name") into a
      *                        header string
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_sheetName...
     P                 B                   export
     D SS_footer_sheetName...
     D                 PI          1024A   varying
      /free
         return SS_header_sheetName();
      /end-free
     P                 E

     P HSSF_footer_sheetName...
     P                 B                   export
     D HSSF_footer_sheetName...
     D                 PI          1024A   varying
      /free
          return String_getBytes(HSSFFooter_sheetName());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SS_footer_time(): Retrieve special characters
      *                   that insert the current time
      *                   into a header string.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_footer_time...
     P                 B                   export
     D SS_footer_time...
     D                 PI          1024A   varying
      /free
          return SS_Header_Time();
      /end-free
     P                 E

     P HSSF_footer_time...
     P                 B                   export
     D HSSF_footer_time...
     D                 PI          1024A   varying
      /free
          return String_getBytes(HSSFFooter_time());
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HSSF_find_sheet(): Returns the index of a given sheet
      *
      *      workbook = (input) workbook object to search
      *         sheet = (input) sheet to get index of
      *
      * Returns the index number or -1 if sheet is not
      *         part of this workbook.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SS_find_sheet...
     P                 B                   export
     D SS_find_sheet...
     D                 PI            10I 0
     D   workbook                          like(SSWorkbook) const
     D   sheet                             like(SSSheet) const

     D getSheetAt      PR                  like(SSSheet)
     D                                     ExtProc(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     : 'getSheetAt')
     D   sheetIndex                        like(jint) value

     D getNumberOfSheets...
     D                 PR            10I 0
     D                                     ExtProc(*JAVA
     D                                     : WORKBOOK_CLASS
     D                                     : 'getNumberOfSheets')

     D testEqual       PR             1N   ExtProc(*JAVA:
     D                                     'java.lang.Object':
     D                                     'equals')
     D   object                        O   CLASS(*JAVA:'java.lang.Object')
     D                                     const

     D count           s             10I 0
     D x               s             10I 0
     D testsheet       s                   like(SSSheet)
      /free

          count = getNumberOfSheets(workbook);

          for x = 0 to (count - 1);
             testsheet = getSheetAt(workbook: x);
             if testEqual(testsheet: sheet);
                return x;
             endif;
          endfor;

          return -1;

      /end-free
     P                 E

     P HSSF_find_sheet...
     P                 B                   export
     D HSSF_find_sheet...
     D                 PI            10I 0
     D   w                                 like(HSSFWorkbook) const
     D   s                                 like(HSSFSheet) const
     C                   return    ss_find_sheet(w: s)
     P                 E


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
     P SS_setRepeating...
     P                 B                   export
     D SS_setRepeating...
     D                 PI
     D   workbook                          like(SSWorkbook) const
     D   sheet                             like(SSSheet) const
     D   startcol                    10I 0 value
     D   endcol                      10I 0 value
     D   startrow                    10I 0 value
     D   endrow                      10I 0 value

     D sheetno         s             10I 0
      /free
         sheetno = ss_find_sheet(workbook: sheet);
         if (sheetno = -1);
            return;
         endif;

         SSWorkbook_setRepeatingRowsAndColumns( workbook
                                              : sheetno
                                              : startcol
                                              : endcol
                                              : startrow
                                              : endrow );
      /end-free
     P                 E

     P HSSF_setRepeating...
     P                 B                   export
     D HSSF_setRepeating...
     D                 PI
     D   workbook                          like(HSSFWorkbook) const
     D   sheet                             like(HSSFSheet) const
     D   startcol                    10I 0 value
     D   endcol                      10I 0 value
     D   startrow                    10I 0 value
     D   endrow                      10I 0 value
      /free
          ss_setRepeating( workbook
                         : sheet
                         : startCol
                         : endCol
                         : startRow
                         : endRow );
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  ss_open():  Open an existing Workbook (either XSSF or HSSF)
      *
      *     peFilename = IFS path/filename of workbook to open
      *
      *  Returns the Workbook object opened
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_open         B                   EXPORT
     D ss_open         PI                  like(SSWorkbook)
     D   peFilename                1024A   const varying

     D RNX0301         c                   301

     D jFileInputStream...
     D                 S               O   CLASS(*JAVA
     D                                     : 'java.io.FileInputStream')

     D new_FileInputStream...
     D                 pr                  like(jFileInputStream)
     D                                     extproc(*JAVA
     D                                     :'java.io.FileInputStream'
     D                                     : *CONSTRUCTOR)
     D   filename                          like(jString) const

     D WorkbookFactory_create...
     D                 PR              O   class(*java
     D                                     : WORKBOOK_CLASS )
     D                                     ExtProc(*JAVA
     D                                     : 'org.apache.poi.ss.usermodel.-
     D                                     WorkbookFactory'
     D                                     : 'create')
     D                                     static
     D   fis                           O   class(*java: 'java.io.InputStream')
     D                                     const

     D closeFile       PR                  EXTPROC(*JAVA
     D                                     :'java.io.FileInputStream'
     D                                     :'close')

     D wwErr           s              1n   inz(*off)
     D wwStr           s                   like(jString)
     D                                     inz(*NULL)
     D wwFile          s                   like(jFileInputStream)
     D                                     inz(*NULL)
     D wwBook          s                   like(HSSFWorkbook)
     D                                     inz(*NULL)
     D wwRetVal        s                   like(HSSFWorkbook)
     D                                     inz(*NULL)

      /free

         hssf_begin_object_group(1000);

         // -------------------------------------------
         //   Open a Java FileInputStream to file
         // -------------------------------------------

         monitor;
            wwStr   = new_String(%trimr(peFilename));
            if wwStr <> *Null;
               wwFile  = new_FileInputStream(wwStr);
            endif;
         on-error RNX0301;
            // FIXME: retrieve exception
            wwErr = *on;
         endmon;


         // -------------------------------------------
         //   Attempt to create the workbook
         // -------------------------------------------

         monitor;
            if (wwErr = *off);
               wwBook = WorkbookFactory_create( wwFile );
            endif;
         on-error RNX0301;
            // FIXME: retrieve exception
            wwBook = *null;
            wwErr  = *on;
         endmon;


         // -------------------------------------------
         //  Clean up the stuff that's open
         // -------------------------------------------

         if (wwFile <> *NULL);
            closeFile(wwFile);
         endif;

         if (wwBook = *NULL);
            hssf_end_object_group();
         else;
            hssf_end_object_group(wwBook: wwRetval);
         endif;

         return wwRetVal;
      /end-free
     P                 E

     P hssf_open       B                   EXPORT
     D hssf_open       PI                  like(HSSFWorkbook)
     D   peFilename                1024A   const varying
     C                   return    ss_open(peFilename)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ss_getSheet(): Get the sheet object from a workbook
      *
      *        peBook = workbook to retrieve sheet from
      *   peSheetName = worksheet name to retrieve
      *
      * Returns the SSSheet object
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_getSheet     B                   EXPORT
     D ss_getSheet     PI                  like(SSSheet)
     D   peBook                            like(SSWorkbook) const
     D   peSheetName               1024A   varying const

     D wwStr           s                   like(jString)
     D wwSheet         s                   like(SSSheet)
      /free
         wwStr = new_String(peSheetName);
         wwSheet = SSWorkbook_getSheet(peBook: wwStr);
         ss_freeLocalRef(wwStr);
         return wwSheet;
      /end-free
     P                 E

     P hssf_getSheet   B                   EXPORT
     D hssf_getSheet   PI                  like(HSSFSheet)
     D   peBook                            like(HSSFWorkbook)
     D   peSheetName               1024A   varying const
     C                   return    ss_getSheet(peBook: peSheetName)
     P                 E


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
     P ss_style        B                   EXPORT
     D ss_style        PI                  like(SSCellStyle)
     D   peBook                            like(SSWorkbook)
     D   peNumFmt                  1024A   const varying
     D   peBold                       1N   value
     D   peCentered                   1N   value
     D   peBottomLine                 1N   value
     D   peFontSize                   5I 0 value options(*nopass)
     D   peBoxed                      1N   value options(*nopass)
     D   peItalic                     1n   value options(*nopass)

     D wwDataFmt       s                   like(SSDataFormat)
     D wwBoldFont      s                   like(SSFont)
     D wwStyle         s                   like(SSCellStyle)
     D wwStr           s                   like(jString)
     D wwFmt           s              5I 0

      /free

       // create the cell style

       wwStyle = SSWorkbook_createCellStyle(peBook);

       // If a numeric format was given, look it up now
       //  and then set it in the cell style

       if (%len(peNumFmt)>0 and peNumFmt<>*blanks);
           wwDataFmt = SSWorkbook_createDataFormat(peBook);
           wwStr = new_String(peNumFmt);
           wwFmt = SSDataFormat_getFormat(wwDataFmt: wwStr);
           SSCellStyle_setDataFormat(wwStyle: wwFmt);
           ss_freeLocalRef(wwStr);
           ss_freeLocalRef(wwDataFmt);
       endif;

       // for bold, we just need to use a bold font

       if (peBold
           or (%parms>=6 and peFontSize>0)
           or (%parms>=8 and peItalic=*ON));
          wwBoldFont = SSWorkbook_createFont(peBook);
          if (peBold);
              SSFont_setBoldweight(wwBoldFont: BOLDWEIGHT_BOLD);
          endif;
          if (%parms>=6 and peFontSize>0);
               SSFont_setFontHeightInPoints(wwBoldFont: peFontSize);
          endif;
          if (%parms>=8 and peItalic);
               SSFont_setItalic(wwBoldFont: *on);
          endif;
          SSCellStyle_setFont(wwStyle: wwBoldFont);
          ss_freeLocalRef(wwBoldFont);
       endif;

       // center if requested

       if peCentered;
           SSCellStyle_setAlignment(wwStyle: ALIGN_CENTER);
       endif;

       //  for bottom line, we set the bottom border of the cell
       //  to be a medium-thick line.

       if peBottomLine;
           SSCellStyle_setBorderBottom(wwStyle: BORDER_MEDIUM);
       endif;


       //  draw lines around cell.   If a bottom line was specified,
       //    we leave the BORDER_MEDIUM alone, otherwise we draw
       //    a thin border on all sides.
       //
       //  This means that if BottomLine is specified, the bottom
       //    line will be thicker than the others, which is good.
       //
       if %parms>=7 and peBoxed;
           if not peBottomLine;
              SSCellStyle_setBorderBottom(wwStyle: BORDER_THIN);
           endif;
           SSCellStyle_setBorderTop(wwStyle: BORDER_THIN);
           SSCellStyle_setBorderLeft(wwStyle: BORDER_THIN);
           SSCellStyle_setBorderRight(wwStyle: BORDER_THIN);
       endif;

       return wwStyle;
      /end-free
     P                 E

     P hssf_style      B                   EXPORT
     D hssf_style      PI                  like(HSSFCellStyle)
     D   peBook                            like(HSSFWorkbook)
     D   peNumFmt                  1024A   const varying
     D   peBold                       1N   value
     D   peCentered                   1N   value
     D   peBottomLine                 1N   value
     D   peFontSize                   5I 0 value options(*nopass)
     D   peBoxed                      1N   value options(*nopass)
     D   peItalic                     1n   value options(*nopass)
      /free
         return ss_style( peBook
                        : peNumFmt
                        : peBold
                        : peCentered
                        : peBottomLine
                        : peFontSize
                        : peBoxed
                        : peItalic );
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ss_addPicture():  This loads a picture into the Excel
      *                   workbook file. (However, you still need
      *                   to use an anchor and drawing to make the
      *                   picture show on the screen.)
      *
      *    stmf = (input) IFS pathname to picture file
      *  format = (input) format of picture (one of the SS_PIC_xxx
      *                     constants, below)
      *
      *  Returns the index to the picture in the workbook
      *  or -1 upon failure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ss_addPicture...
     P                 B                   EXPORT
     D ss_addPicture...
     D                 PI            10i 0
     D   book                              like(SSWorkbook) const
     D   stmf                      5000a   varying const options(*varsize)
     D   format                      10i 0 value

     D AddPicMethod    PR                  LIKE(jint)
     D                                     EXTPROC(*CWIDEN
     D                                     : JNINativeInterface.
     D                                      CallIntMethod_P)
     D  env                                LIKE(JNIEnv_P) VALUE
     D  obj                                LIKE(jobject) VALUE
     D  methodID                           LIKE(jmethodID) VALUE
     D  array                              like(jByteArray) value
     D                                     options(*nopass)
     D  format                       10i 0 value
     D                                     options(*nopass)

     D get_errno       PR              *   ExtProc('__errno')
     D strerror        PR              *   extproc('strerror')
     D   err                         10i 0 value

     D ADDPICTURE_SIG  C                   x'285b4249294900'
     D classid         s                   like(jclass)
     D                                     static inz(*null)
     D mid             s                   like(jmethodid)
     D                                     static inz(*null)
     D fd              s             10i 0 inz(-1)
     D arr             s                   like(jbyteArray)
     D buf             s                   like(jbyte)
     D                                     based(p_buf)
     D len             s             10i 0
     D isCopy          s                   like(jboolean)
     D st              ds                  likeds(statds)
     D rc              s             10i 0 inz(-1)
     D err             s             10i 0 based(p_err)
     D fail            s             80a   varying inz('')

      /free

        // -------------------------------------------------
        //   Get JNI environment handle.
        //   and start a new object frame
        // -------------------------------------------------

        JNIENV_P = hssf_get_jni_env();
        if (JNIENV_p = *NULL);
           ReportError('Unable to get JNI environment');
           return -1;
        endif;

        PushLocalFrame(JNIENV_P: 10000);


        // -------------------------------------------------
        //   Look up the class ID and method ID for the
        //   HSSFWorkbook.addPicture method
        // -------------------------------------------------

        if classid = *null;
           classid = FindClass( JNIENV_P
                              : asc( WORKBOOK_CLASS : *ON ) );
           if jni_CheckError();
              fail = 'FindClass: ' + WORKBOOK_CLASS
                   + ' class not found in CLASSPATH.';
              exsr cleanup;
           endif;
        endif;

        if mid = *null;
           mid = GetMethodID( JNIENV_P
                            : classid
                            : asc('addPicture')
                            : ADDPICTURE_SIG );
           if jni_CheckError();
              fail = 'GetMethodID: addPicture method not found.';
              exsr cleanup;
           endif;
        endif;


        // -------------------------------------------------
        //   Look up the size of the picture on disk
        // -------------------------------------------------

        if stat(stmf: st) = -1;
           p_err = get_errno();
           fail = 'stat: ' + %str(strerror(err));
           exsr cleanup;
        endif;


        // -------------------------------------------------
        //   Ask Java for a byte array.  Make it large
        //   enough to hold the entire picture file.
        // -------------------------------------------------

        arr = NewByteArray(JNIENV_P: st.st_size);
        if jni_CheckError();
           fail = 'NewByteArray() failed.';
           exsr cleanup;
        endif;

        if (arr = *null);
           fail = 'NewByteArray() returned *NULL';
           exsr cleanup;
        endif;


        // -------------------------------------------------
        //  Get a pointer to Java's byte array so we can
        //  load the picture into it.
        // -------------------------------------------------

        p_buf = GetByteArrayElements(JNIENV_P: arr: isCopy);
        if jni_CheckError();
           fail = 'Error calling JNI GetByteArrayElements';
           exsr cleanup;
        endif;

        if (p_buf = *null);
           fail = 'GetByteArrayElements returned *NULL';
           exsr cleanup;
        endif;

        // -------------------------------------------------
        //   Read IFS file into the byte array.
        // -------------------------------------------------

        fd = open(%trimr(stmf): O_RDONLY);
        if (fd = -1);
           p_err = get_errno();
           fail = 'open: ' + %str(strerror(err));
           exsr cleanup;
        endif;

        len = read(fd: p_buf: st.st_size);
        if (len < st.st_size);
           fail = 'read: Only able to read partial picture.';
           exsr cleanup;
        endif;

        callp close(fd);
        fd = -1;


        // -------------------------------------------------
        //   Commit the changes in the byte array back to
        //   the object in the JVM.
        // -------------------------------------------------

        if (isCopy = JNI_TRUE);
           ReleaseByteArrayElements( JNIENV_P: arr: buf: JNI_COMMIT);
           if jni_CheckError();
              fail = 'Commit of buf failed.';
              exsr cleanup;
           endif;
        endif;

        // -------------------------------------------------
        //  Call the addPicture() method of the HSSFWorkbook
        //  class.  This loads the picture into the workbook
        //  object (but does not draw it on the sheet)
        // -------------------------------------------------

        rc = AddPicMethod( JNIENV_P
                         : book
                         : mid
                         : arr
                         : format );
        if jni_checkError();
           fail = 'Call to Workbook.addPicture() failed.';
           exsr cleanup;
        endif;

        exsr cleanup;

        // -------------------------------------------------
        //   Do any needed cleanup to get the JVM into
        //   a consistent state, then exit.
        // -------------------------------------------------

        begsr cleanup;
           if (fd <> -1);
              callp close(fd);
           endif;

           if (arr <> *Null);
              ReleaseByteArrayElements( JNIENV_P: arr: buf: 0 );
           endif;

           PopLocalFrame(JNIENV_P: *NULL);

           if (%len(fail)>0 and fail<>*blanks);
              ReportError(fail);
              return -1;
           else;
              return rc;
           endif;

        endsr;
      /end-free
     P                 E

     P hssf_addPicture...
     P                 B                   EXPORT
     D hssf_addPicture...
     D                 PI            10i 0
     D   book                              like(HSSFWorkbook) const
     D   stmf                      5000a   varying const options(*varsize)
     D   format                      10i 0 value
     C                   return    ss_addPicture(book: stmf: format)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * new_SSClientAnchor():  Create a new SSClientAnchor object
      *      used to anchor a picture to a place within a sheet
      *
      *     book = workbook object that anchor is for (used
      *             to determine HSSF vs XSSF)
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
     P new_SSClientAnchor...
     P                 B                   Export
     D new_SSClientAnchor...
     D                 PI                  like(SSClientAnchor)
     D   book                              like(SSWorkbook) const
     D   dx1                         10i 0 value
     D   dy1                         10i 0 value
     D   dx2                         10i 0 value
     D   dy2                         10i 0 value
     D   col1                        10i 0 value
     D   row1                        10i 0 value
     D   col2                        10i 0 value
     D   row2                        10i 0 value

     D setDx1          pr                  extproc( *java
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setDx1')
     D   dx1                         10i 0 value

     D setDy1          pr                  extproc( *java
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setDy1')
     D   dy1                         10i 0 value

     D setDx2          pr                  extproc( *java
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setDx2')
     D   dx2                         10i 0 value

     D setDy2          pr                  extproc( *java
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setDy2')
     D   dy2                         10i 0 value

     D setCol1         pr                  extproc( *java
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setCol1')
     D   col1                        10i 0 value

     D setRow1         pr                  extproc( *java
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setRow1')
     D   row1                        10i 0 value

     D setCol2         pr                  extproc( *java
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setCol2')
     D   col2                        10i 0 value

     D setRow2         pr                  extproc( *java
     D                                     : CLIENTANCHOR_CLASS
     D                                     : 'setRow2')
     D   row2                        10i 0 value

     D helper          s                   like(SSCreationHelper)
     D anc             s                   like(SSClientAnchor)

      /free
         helper = SSWorkbook_getCreationHelper(book);
         anc = SSCreationHelper_createClientAnchor(helper);

         setDx1(anc: dx1);
         setDy1(anc: dy1);
         setDx2(anc: dx2);
         setDy2(anc: dy2);
         setCol1(anc: col1);
         setRow1(anc: row1);
         setCol2(anc: col2);
         setRow2(anc: row2);

         return anc;
      /end-free
     P                 E


      *-----------------------------------------------------------------
      * jni_checkError():  Check for an error in JNI routines
      *-----------------------------------------------------------------
     P jni_checkError  B
     D jni_checkError  PI             1N

     D sleep           pr            10I 0 extproc('sleep')
     D   intv                        10I 0 value

     D exc             s                   like(jthrowable)
      /free

          exc = ExceptionOccurred(JNIENV_P);
          if (exc = *NULL);
              return *OFF;
          endif;

          ExceptionDescribe(JNIENV_P);
          sleep(10);

          ExceptionClear(JNIENV_P);
          return *ON;
      /end-free
     P                 E


      *-----------------------------------------------------------------
      * asc():  Simple routine to convert a string to ASCII
      *-----------------------------------------------------------------
     P asc             B
     D asc             PI            80a   varying
     D  str                          80a   varying const options(*varsize)
     D  slash                         1n   const options(*nopass)

     D QDCXLATE        PR                  ExtPgm('QDCXLATE')
     D   len                          5p 0 const
     D   data                        80a
     D   table                       10a   const

     D VARPREF         C                   2
     D retval          s             80a   varying
     D dummy           s             80a   based(p_dummy)
      /free
         if %parms>=2 and slash=*on;
           retval = %xlate('.':'/': str);
         else;
           retval = str;
         endif;

         if %len(retval) > 0;
            p_dummy = %addr(retval) + VARPREF;
            QDCXLATE(%len(retval): dummy: 'QTCPASC');
         endif;

         return retval;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ReportError():  Go kaboom!
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ReportError     B
     D ReportError     PI
     D   msg                        200a   varying const


     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    200A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                32767A   options(*varsize)

     D ErrorCode       DS                  qualified
     D  BytesProv                    10I 0 inz(0)
     D  BytesAvail                   10I 0 inz(0)

     D MsgKey          S              4A
     D MsgID           s              7A
     D msgDta          s            200a
     D msgDtaLen       s             10i 0

      /free

         msgDta    = msg;
         msgDtaLen = %len(msg);
         MsgID     = 'CPF9897';

         QMHSNDPM( MsgID
                 : 'QCPFMSG   *LIBL'
                 : msgDta
                 : msgDtaLen
                 : '*ESCAPE'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ErrorCode         );

      /end-free
     P                 E
