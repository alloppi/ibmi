      *  Demonstration of setting headers, footers & repeating rows
      *  using POI from RPG.
      *
      *  To compile:
      *      Make sure you've already created HSSFR4. See the instructions
      *      on that source member for details.
      *
      *>      CRTBNDRPG PGM(PHCCHIDEMR) SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *
      *
     H DFTACTGRP(*NO)
     H OPTION(*SRCSTMT: *NODEBUGIO: *NOSHOWCPY)
     H THREAD(*SERIALIZE)
     H BNDDIR('HSSF')
      * Optional specify conversion : CCSID(*UCS2 : 13488)
     H*CCSID(*UCS2 : 13488)
     H*CCSID(*UCS2 : 61952)
     H*CCSID(*CHAR: *JOBRUN)

     FPHCCHIF   IF   E           K DISK
     FPHBIG5F   IF   E           K DISK

      /copy qcpysrc,hssf_h

     D IFSDIR          C                   '/tmp'

     D PHCCHIDEMR      PR                  ExtPgm('PHCCHIDEMR')
     D   peXSSF                       1n   const options(*nopass)
     D PHCCHIDEMR      PI
     D   peXSSF                       1n   const options(*nopass)

     D CreateCellStyles...
     D                 PR

     D AddDetail       PR
     D   book                              like(SSWorkbook)

     D FormatColumns   PR
     D   sheet                             like(SSSheet)

     D SetHeadings     PR
     D   workbook                          like(SSWorkbook) const
     D   sheet                             like(SSSheet) const
     D   rowcount                    10I 0

     D String_getBytes...
     D                 pr          1024A   varying
     D                                     extproc(*JAVA:
     D                                     'java.lang.String':
     D                                     'getBytes')

     D xssf            s              1n   inz(*off)
     D dispose         s               n
     D book            s                   like(SSWorkbook)
     D LgHeading       s                   like(SSCellStyle)
     D SmHeading       s                   like(SSCellStyle)
     D ColHeading      s                   like(SSCellStyle)
     D Numeric         s                   like(SSCellStyle)
     D NumNoDec        s                   like(SSCellStyle)
     D Text            s                   like(SSCellStyle)
     D Dates           s                   like(SSCellStyle)
     D ChiText         s                   like(SSCellStyle)

      /free
        if %parms >= 1 and peXSSF;
           xssf = peXSSF;
        endif;

        ss_begin_object_group(100);

        if (xssf);
           book = new_SXSSFWorkbook();
        else;
           book = new_HSSFWorkbook();
        endif;

        CreateCellStyles();

        AddDetail(book);

        if (xssf);
           SS_save(book: IFSDIR + '/PHCCHIF.xlsx');
        else;
           SS_save(book: IFSDIR + '/PHCCHIF.xls');
        endif;

        ss_end_object_group();

        if (xssf);
           dispose = SXSSF_dispose(book);
        endif;

        *inlr = *on;

      /end-free


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CreateCellStyles(): Create the different display styles
      *    used for cells in this Excel workbook.
      *
      * NOTE: Uses the following global variables:
      *       Book, LgHeading, SmHeading, ColHeading, Numeric
      *       Text, Dates.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CreateCellStyles...
     P                 B
     D CreateCellStyles...
     D                 PI

     D LgFont          s                   like(SSFont)
     D SmFont          s                   like(SSFont)
     D ChFont          s                   like(SSFont)
     D ChiFont         s                   like(SSFont)
     D DftFont         s                   like(SSFont)
     D DataFmt         s                   like(SSDataFormat)
     D TempStr         s                   like(jString)
     D ufields         s              6C
     D NumFmt          s              5I 0
     D DateFmt         s              5I 0

      /free

         //
         //  Create a cell style for the large, centered
         //  title at the top of the report.
         //
         LgHeading = SSWorkbook_createCellStyle(book);

         LgFont = SSWorkbook_createFont(book);
         SSFont_setBoldweight(LgFont: BOLDWEIGHT_BOLD);
         SSFont_setFontHeightInPoints(LgFont: 16);
         SSCellStyle_setFont(LgHeading: LgFont);

         SSCellStyle_setAlignment(LgHeading: ALIGN_CENTER);

         //
         // Create a cell style for the smaller text that
         //  will be printed below the main heading.
         //

         SmHeading = SSWorkbook_createCellStyle(book);

         SmFont = SSWorkbook_createFont(book);
         SSFont_setFontHeightInPoints(SmFont: 8);
         SSCellStyle_setFont(SmHeading: SmFont);

         SSCellStyle_setAlignment(SmHeading: ALIGN_CENTER);

         //
         // Create a cell style for the column headings.
         // These are bold and have a border line at the bottom
         //

         ColHeading = SSWorkbook_createCellStyle(book);

         ChFont = SSWorkbook_createFont(book);
         TempStr = new_String('Arial');
         SSFont_setFontName(ChFont: TempStr);
         SSFont_setBoldweight(ChFont: BOLDWEIGHT_BOLD);
         SSCellStyle_setFont(ColHeading: ChFont);

         SSCellStyle_setAlignment(ColHeading: ALIGN_CENTER);
         SSCellStyle_setBorderBottom(ColHeading: BORDER_THIN);

         //
         // Create a cell style for numbers so that they are
         //  right-aligned and the number is formatted nicely.
         //

         Numeric = SSWorkbook_createCellStyle(book);

         DataFmt = SSWorkbook_createDataFormat(book);
         TempStr = new_String('#,##0.00');
         NumFmt = SSDataFormat_getFormat(DataFmt: TempStr);
         SSCellStyle_setDataFormat(Numeric: NumFmt);

         SSCellStyle_setAlignment(Numeric: ALIGN_RIGHT);

         //
         // Create a cell style for numbers without Deciaml so that they are
         //  right-aligned and the number is formatted nicely.
         //

         NumNoDec = SSWorkbook_createCellStyle(book);

         DataFmt = SSWorkbook_createDataFormat(book);
         TempStr = new_String('#,##0');
         NumFmt = SSDataFormat_getFormat(DataFmt: TempStr);
         SSCellStyle_setDataFormat(NumNoDec: NumFmt);

         SSCellStyle_setAlignment(NumNoDec: ALIGN_RIGHT);

         //
         // Create a cell style for text so that it's
         //  left-aligned
         //

         Text = SSWorkbook_createCellStyle(book);
         DftFont = SSWorkbook_createFont(book);
         TempStr = new_String('Courier');
         SSFont_setFontName(DftFont: TempStr);
         SSCellStyle_setFont(Text: DftFont);
         SSCellStyle_setAlignment(Text: ALIGN_LEFT);

         ChiText = SSWorkbook_createCellStyle(book);
         ChiFont = SSWorkbook_createFont(book);
         TempStr = new_String('PMingLiU');
         SSFont_setFontName(ChiFont: TempStr);
         SSCellStyle_setFont(ChiText: ChiFont);
         SSCellStyle_setAlignment(ChiText: ALIGN_LEFT);

         //
         // Create a cell style for dates.  Dates in Excel
         //  are numbers that are formatted in a particular
         //  way.
         //

         Dates = SSWorkbook_createCellStyle(book);

         DataFmt = SSWorkbook_createDataFormat(book);
         TempStr = new_String('m/d/yy');
         DateFmt = SSDataFormat_getFormat(DataFmt: TempStr);
         SSCellStyle_setDataFormat(Dates: DateFmt);

      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  AddDetail():  Add data to the given sheet
      *
      *       book = (input) Workbook to add sheet to
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P AddDetail       B
     D AddDetail       PI
     D   book                              like(SSWorkbook)

     D sheet           s                   like(SSSheet)
     D row             s                   like(SSRow)
     D rowcount        s             10I 0 inz(0)
     D start           s              5A   varying
     D end             s              5A   varying
     D AddFormula      s              1N   inz(*OFF)
     D filename        c                   'PHCCHIF'
     D cell            s                   like(SSCell)
     D TempStr         s                   like(jString)
     D StrVal          s             52A   varying
     D chichar         S              6A   INZ('測試')
     D ufield3         S              6C

      /free

         sheet = ss_newSheet(book: filename);

         FormatColumns(sheet);
         SetHeadings(book: sheet: rowcount);
         start = ss_cellname( rowcount+1: 3);

         read  PHCCHIF;
         dow not %eof(PHCCHIF);

            rowcount += 1;
            row = SSSheet_createRow(sheet: rowcount);
            ss_text( row: 0 : ' ' : Text);
            ss_text_ucs2( row: 1 : %trimr(CCHICHAR) : ChiText);

            read PHCCHIF ;
         enddo;

         read  PHBIG5F;
         dow not %eof(PHBIG5F);

            rowcount += 1;
            row = SSSheet_createRow(sheet: rowcount);
            ss_text( row: 0 : %trimr(BIG5CODE): Text);
            ss_text_ucs2( row: 1 : %trimr(BIG5CHAR) : ChiText);

            read PHBIG5F ;
         enddo;

      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * FormatColumns():  Set the column widths & merged cells
      *    in a given worksheet.
      *
      *   sheet = (input) sheet to set the column widths in
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P FormatColumns   B
     D FormatColumns   PI
     D   sheet                             like(SSSheet)
      /free

        //
        // The column width setting is in units that are approx
        //   1/256 of a character.
        //

        SSSheet_setColumnWidth( sheet:  0: 14 * 256 );

      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SetHeadings():  Set the text in the first few rows of
      *    the given worksheet so that they appear like "headings"
      *    to someone viewing the sheet.
      *
      *    sheet = (input) sheet that cells are set in.
      * rowcount = (input/output) row count (updated)
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SetHeadings     B
     D SetHeadings     PI
     D   workbook                          like(SSWorkbook) const
     D   sheet                             like(SSSheet) const
     D   rowcount                    10I 0

     D row             s                   like(SSRow)
     D hdr             s                   like(SSHeader)
      /free

         SS_header_setLeft(sheet: SS_header_date() + ' '
                                  + SS_header_time());

         SS_header_setCenter(sheet: SS_header_font('Arial': 'Italic')
                                  + SS_header_fontSize(16)
                                  + 'Assignment Data');

         SS_header_setRight (sheet: SS_header_sheetName());

         SS_footer_setLeft  (sheet: SS_footer_file());
         SS_footer_setRight (sheet: 'Page ' + SS_footer_page()
                                     +  ' of ' + SS_footer_numPages());

         rowcount = 0;
         row = SSSheet_createRow(sheet: rowcount);
         ss_text( row:  0 : 'Big5 Code'     : ColHeading);
         ss_text( row:  1 : 'Chinese Char.' : ColHeading);

         ss_setRepeating(workbook: sheet: -1: -1: 0: 0 );

      /end-free
     P                 E
