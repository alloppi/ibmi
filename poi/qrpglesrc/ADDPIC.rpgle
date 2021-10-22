      *  Demonstration of loading an image into an Excel spreadsheet
      *                               Scott Klement, December 11, 2008
      *
      *    To compile:
      *      - Change IFSDIR, below, to an appropriate directory.
      *      - Make sure SKLogo.png has been uploaded to the IFSDIR
      *          location.  If you're using FTP to upload SKLogo.png
      *          make sure you use BINARY mode.
      *      - Make sure you've built HSSFR4.  See the HSSFR4
      *          source member for build instructions.
      *      - run the following:
      *>     CRTBNDRPG ADDPIC DBGVIEW(*LIST)
      *
      *
     H DFTACTGRP(*NO) BNDDIR('HSSF')

      /copy POI36,hssf_h

     D ADDPIC          PR                  ExtPgm('ADDPIC')
     D   peXSSF                       1n   const options(*nopass)
     D ADDPIC          PI
     D   peXSSF                       1n   const options(*nopass)

     D IFSDIR          C                   '/tmp'

     D xssf            s              1n   inz(*off)
     D book            s                   like(SSWorkbook)
     D sheet           s                   like(SSSheet)
     D row             s                   like(SSRow)
     D NameStyle       s                   like(SSCellStyle)
     D AddrStyle       s                   like(SSCellStyle)
     D img             s                   like(SSPicture)
     D Drw             s                   like(SSdrawing)
     D Anc             s                   like(SSClientAnchor)
     D Pic             s            500a   varying
     D idx             s             10i 0

      /free
          if %parms>=1 and peXSSF;
             xssf = *on;
          endif;

          ss_begin_object_group(10000);

          if (xssf);
             book = new_XSSFWorkbook();
          else;
             book = new_HSSFWorkbook();
          endif;

          sheet = ss_newSheet(book: 'Test');

          // ------------------------------------------
          // Create a large bold font for my name
          // ------------------------------------------

          NameStyle = SSWorkbook_createCellStyle( book );
          SSCellStyle_setFont( NameStyle
                             : ss_CreateFont( book
                                            : 'Arial'
                                            : 36
                                            : BOLDWEIGHT_BOLD
                                            : *OMIT
                                            : *OMIT
                                            : *OMIT
                                            : *OMIT
                                            : *OMIT ) );

          // ------------------------------------------
          // Create a medium-sized italic font for
          //  my address
          // ------------------------------------------

          AddrStyle = SSWorkbook_createCellStyle( book );
          SSCellStyle_setFont( AddrStyle
                             : ss_CreateFont( book
                                            : 'Arial'
                                            : 16
                                            : *OMIT
                                            : *OMIT
                                            : *ON
                                            : *OMIT
                                            : *OMIT
                                            : *OMIT ) );

          // ------------------------------------------
          //  Load my logo into the workbook
          // ------------------------------------------

          Pic = IFSDIR + '/SKLogo.png';
          idx = SS_addPicture(book: Pic: SS_PIC_PNG);

          // ------------------------------------------
          //   Put my name and address in cells...
          // ------------------------------------------

          row = SSSheet_createRow(sheet: 0);
          ss_text(row: 0: 'Scott Klement': NameStyle);

          row = SSSheet_createRow(sheet: 1);
          ss_text(row: 0: '123 Main Street': AddrStyle);

          row = SSSheet_createRow(sheet: 2);
          ss_text(row: 0: 'Milwaukee, WI 53201': AddrStyle);

          // ------------------------------------------
          //   Anchors are always specified by the
          //   upper-left cell and the lower-right
          //   cell to create a rectangle.
          //
          //   Draw the logo from cells 6,0 (G1) to
          //   cells 8,6 (I7)
          // ------------------------------------------

          Drw = SSSheet_createDrawingPatriarch(sheet);
          Anc = new_SSClientAnchor( book: 512: 128: 512: 128
                                        :   6:   0:   8:   6);
          SSClientAnchor_setAnchorType(Anc: SS_ANCHOR_MOVE);
          img = SSDrawing_createPicture(Drw: anc: idx);

          // enable this to force picture to it's original
          //  (unscaled) size:
          // SSPicture_resetSize(img);

          // ------------------------------------------
          //  Save workbook to the IFS
          // ------------------------------------------

          if (xssf);
             ss_save(book: IFSDIR + '/pictest3.6.xlsx');
          else;
             ss_save(book: IFSDIR + '/pictest3.6.xls');
          endif;

          ss_end_object_group();
          *inlr = *on;
      /end-free
