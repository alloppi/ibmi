     H DFTACTGRP(*NO)
     H OPTION(*SRCSTMT: *NODEBUGIO: *NOSHOWCPY)
     H THREAD(*SERIALIZE)
     H BNDDIR('HSSF')

      /copy POI36,hssf_h

     D IFSDIR          C                   '/tmp'

     D complain        PR
     D   msg                        256a   varying const

     D book            s                   like(SSWorkbook)
     D sheet           s                   like(SSSheet)
     D row             s                   like(SSRow)
     D cell            s                   like(SSCell)
     D TempStr         s                   like(jString)
     D StrVal          s             52A   varying
     D NumVal          s              8F
     D type            s             10I 0

     D String_getBytes...
     D                 pr          1024A   varying
     D                                     extproc(*JAVA:
     D                                     'java.lang.String':
     D                                     'getBytes')

      /free

        ss_begin_object_group(100);

        //
        // Load an existing spreadsheet into memory
        //
        book = ss_open(IFSDIR + '/xldemo3.6.xlsx');
        if (book = *null);
            complain('Unable to open workbook!');
        endif;

        //
        // get the SSCell object that needs changing
        //
        sheet = ss_getSheet(book: 'January');
        if (sheet = *null);
           Complain('No January sheet in workbook!');
        endif;

        row = SSSheet_getRow(sheet: 5);
        if (row = *null);
           row = SSSheet_createRow(sheet: 5);
        endif;

        cell = SSRow_GetCell(row: 1);
        if (cell = *null);
           cell = SSRow_createCell(row: 1);
        endif;

        //
        // Change the cell to a String cell and set the
        //  value to 'Nifty New Value'
        //
        SSCell_setCellType(cell: CELL_TYPE_STRING);
        TempStr = new_String('Nifty New Value');
        SSCell_setCellValueStr(cell: TempStr);

        //
        //  See what the value of the cell in row 7, column 2 is:
        //
        row = SSSheet_getRow(sheet: 7);
        if (row = *null);
            row = SSSheet_createRow(sheet: 7);
        endif;

        cell = SSRow_GetCell(row: 3);
        if cell = *null;
          cell = SSRow_createCell(row: 2);
          SSCell_setCellType(cell: CELL_TYPE_STRING);
          SSCell_setCellValueStr(cell: new_String('Fill me in!'));
        endif;

        type = SSCell_getCellType(cell);
        StrVal = 'Cell D8 = ';

        select;
        when type = CELL_TYPE_STRING;
           StrVal += String_getBytes(SSCell_getStringCellValue(cell));
        when type = CELL_TYPE_FORMULA;
           StrVal += String_getBytes(SSCell_getCellFormula(cell));
        when type = CELL_TYPE_NUMERIC;
           NumVal = SSCell_getNumericCellValue(cell);
           StrVal += %char(%dech(NumVal:15:2));
        endsl;

        dsply StrVal;

        ss_save(book: IFSDIR + '/xldemo3.6.xls');
        ss_end_object_group();

        *inlr = *on;

      /end-free

     P complain        B
     D complain        PI
     D   msg                        256a   varying const

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const options(*varsize)
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                 8192A   options(*varsize)

     D ErrorCode       DS                  qualified
     D  BytesProv                    10I 0 inz(0)
     D  BytesAvail                   10I 0 inz(0)

     D MsgKey          S              4A

      /free

         QMHSNDPM( 'CPF9897'
                 : 'QCPFMSG   *LIBL'
                 : msg
                 : %len(msg)
                 : '*ESCAPE'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ErrorCode         );

      /end-free
     P                 E
