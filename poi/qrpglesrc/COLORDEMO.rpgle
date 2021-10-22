      *  Demonstration of using colors in cell styles in POI
      *
      *  To compile:
      *      Make sure you've already created HSSFR4. See the instructions
      *      on that source member for details.
      *
      *>     CRTBNDRPG PGM(COLORDEMO) SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *
      *
     H DFTACTGRP(*NO)
     H OPTION(*SRCSTMT: *NODEBUGIO: *NOSHOWCPY)
     H THREAD(*SERIALIZE)
     H BNDDIR('HSSF')

      /copy POI36,hssf_h

     D IFSDIR          C                   '/tmp'

     D COLORDEMO       PR                  ExtPGm('COLORDEMO')
     D   peXSSF                       1n   const options(*nopass)
     D COLORDEMO       PI
     D   peXSSF                       1n   const options(*nopass)

     D xssf            s              1n   inz(*off)
     D book            s                   like(SSWorkbook)
     D sheet           s                   like(SSSheet)
     D row             s                   like(SSRow)
     D style           s                   like(SSCellStyle)
     D font            s                   like(SSFont)

      /free
        if %parms>=1 and peXSSF;
           xssf = *on;
        endif;

        ss_begin_object_group(100);

        if (xssf);
           book = new_XSSFWorkbook();
        else;
           book = new_HSSFWorkbook();
        endif;

        sheet = ss_newSheet(book: 'new sheet');
        row = SSSheet_createRow(sheet: 1);

        // Aqua background

        style = SSWorkbook_createCellStyle(book);
        ssCellStyle_setFillBackgroundColor( style: COLOR_AQUA );
        ssCellStyle_setFillPattern(style: SS_PATTERN_BIG_SPOTS);
        ss_text(row: 1: 'X': style);


        // Orange "foreground" (foreground meaning the fill color,
        //     rather than the font color.)

        style = SSWorkbook_createCellStyle(book);
        SSCellStyle_setFillForegroundColor( style: COLOR_ORANGE );
        SSCellStyle_setFillPattern(style: SS_PATTERN_SOLID_FOREGROUND);
        ss_text(row: 2: 'X': style);


        // White text on a black background
        //   note that the text color is a "font color"
        //   it is NOT the foreground color of the cell.

        style = SSWorkbook_createCellStyle(book);
        SSCellStyle_setFillForegroundColor( style: COLOR_BLACK );
        SSCellStyle_setFillPattern(style: SS_PATTERN_SOLID_FOREGROUND);

        font  = SSWorkbook_createFont(book);
        SSFont_setColor(font: COLOR_WHITE);
        SSCellStyle_setFont(style: font);
        ss_text(row: 3: 'X': style);


        // save results to a file

        if (xssf);
           ss_save(book: IFSDIR + '/filltest.xlsx');
        else;
           ss_save(book: IFSDIR + '/filltest.xls');
        endif;


        // cleanup and exit

        ss_end_object_group();
        *inlr = *on;

      /end-free
