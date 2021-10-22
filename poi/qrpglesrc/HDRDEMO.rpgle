      *  Demonstration of setting headers, footers & repeating rows
      *  using POI from RPG.
      *
      *  To compile:
      *      Make sure you've already created HSSFR4. See the instructions
      *      on that source member for details.
      *
      *> ign: CRTPF DIVSALES SRCFILE(QDDSSRC)
      *>      CRTBNDRPG PGM(HDRDEMO) SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *
      *
     H DFTACTGRP(*NO)
     H OPTION(*SRCSTMT: *NODEBUGIO: *NOSHOWCPY)
     H THREAD(*SERIALIZE)
     H BNDDIR('HSSF')

     FDIVSALES  IF   E           K DISK

      /copy POI36,hssf_h

     D IFSDIR          C                   '/tmp'

     D HDRDEMO         PR                  ExtPgm('HDRDEMO')
     D   peXSSF                       1n   const options(*nopass)
     D HDRDEMO         PI
     D   peXSSF                       1n   const options(*nopass)

     D CreateCellStyles...
     D                 PR

     D AddMonth        PR
     D   book                              like(SSWorkbook)
     D   month                        2P 0 value
     D   monthname                   20A   varying const

     D FormatColumns   PR
     D   sheet                             like(SSSheet)

     D SetHeadings     PR
     D   workbook                          like(SSWorkbook) const
     D   sheet                             like(SSSheet) const
     D   monthname                   20A   varying const
     D   rowcount                    10I 0

     D xssf            s              1n   inz(*off)
     D book            s                   like(SSWorkbook)
     D LgHeading       s                   like(SSCellStyle)
     D SmHeading       s                   like(SSCellStyle)
     D ColHeading      s                   like(SSCellStyle)
     D Numeric         s                   like(SSCellStyle)
     D Text            s                   like(SSCellStyle)
     D Dates           s                   like(SSCellStyle)

      /free
        if %parms >= 1 and peXSSF;
           xssf = peXSSF;
        endif;

        ss_begin_object_group(100);

        if (xssf);
           book = new_XSSFWorkbook();
        else;
           book = new_HSSFWorkbook();
        endif;

        CreateCellStyles();

        AddMonth(book:  1: 'January');
        AddMonth(book:  2: 'February');
        AddMonth(book:  3: 'March');
        AddMonth(book:  4: 'April');
        AddMonth(book:  5: 'May');
        AddMonth(book:  6: 'June');
        AddMonth(book:  7: 'July');
        AddMonth(book:  8: 'August');
        AddMonth(book:  9: 'September');
        AddMonth(book: 10: 'October');
        AddMonth(book: 11: 'November');
        AddMonth(book: 12: 'December');

        if (xssf);
           SS_save(book: IFSDIR + '/hdrdemo3.6.xlsx');
        else;
           SS_save(book: IFSDIR + '/hdrdemo3.6.xls');
        endif;

        ss_end_object_group();
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
     D DataFmt         s                   like(SSDataFormat)
     D TempStr         s                   like(jString)
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
         TempStr = new_String('Courier');
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
         // Create a cell style for text so that it's
         //  left-aligned
         //

         Text = SSWorkbook_createCellStyle(book);
         SSCellStyle_setAlignment(Text: ALIGN_LEFT);

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
      *  AddMonth():  Add 1 months data to the given sheet
      *
      *      month = (input) month number (1=January - 12=December)
      *  monthname = (input) human-readable month name ('January')
      *       book = (input) Workbook to add sheet to
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P AddMonth        B
     D AddMonth        PI
     D   book                              like(SSWorkbook)
     D   month                        2P 0 value
     D   monthname                   20A   varying const

     D sheet           s                   like(SSSheet)
     D row             s                   like(SSRow)
     D rowcount        s             10I 0 inz(0)
     D start           s              5A   varying
     D end             s              5A   varying
     D AddFormula      s              1N   inz(*OFF)

      /free

         sheet = ss_newSheet(book: monthname);

         FormatColumns(sheet);
         SetHeadings(book: sheet: monthname: rowcount);
         start = ss_cellname( rowcount+1: 3);

         setll (month) DIVSALES;
         reade (month) DIVSALES;

         dow not %eof(DIVSALES);

            rowcount += 1;
            row = SSSheet_createRow(sheet: rowcount);

            ss_text( row: 0 : %char(DIVNO)   : Text);
            ss_text( row: 1 : %trimr(DIVNAME): Text);
            ss_date( row: 2 : PostDate       : Dates);
            ss_num ( row: 3 : Sales          : Numeric);
            AddFormula = *On;

            reade (month) DIVSALES;
         enddo;

         if (AddFormula);

            end = ss_cellname( rowcount: 3);

            rowcount += 2;
            row = SSSheet_createRow(sheet: rowcount);
            ss_text   ( row: 2 : 'Total:'                : Text);
            ss_formula( row: 3: 'SUM('+start+':'+end+')': Numeric);

         endif;

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

        SSSheet_setColumnWidth( sheet: 0:  4 * 256 );
        SSSheet_setColumnWidth( sheet: 1: 30 * 256 );
        SSSheet_setColumnWidth( sheet: 2: 10 * 256 );
        SSSheet_setColumnWidth( sheet: 3: 15 * 256 );

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
     D   monthname                   20A   varying const
     D   rowcount                    10I 0

     D row             s                   like(SSRow)
     D hdr             s                   like(SSHeader)
      /free

         SS_header_setLeft  (sheet: SS_header_date() + ' '
                                  + SS_header_time());

         SS_header_setCenter(sheet: SS_header_font('Arial': 'Italic')
                                  + SS_header_fontSize(16)
                                  + 'Weekly Sales Figures');

         SS_header_setRight (sheet: SS_header_sheetName());

         SS_footer_setLeft  (sheet: SS_footer_file());
         SS_footer_setRight (sheet: 'Page ' + SS_footer_page()
                                     +  ' of ' + SS_footer_numPages());

         rowcount = 0;
         row = SSSheet_createRow(sheet: rowcount);
         ss_text( row: 0 : 'Div':           ColHeading);
         ss_text( row: 1 : 'Division Name': ColHeading);
         ss_text( row: 2 : 'Date':          ColHeading);
         ss_text( row: 3 : 'Sales':         ColHeading);

         ss_setRepeating(workbook: sheet: -1: -1: 0: 0 );

      /end-free
     P                 E
