      //  ______________________________________________________________________
      //   ___             _    _     __ __             _    _
      //  | . > ___  ___ _| |_ | |_  |  \  \ ___  _ _ _| |_ <_>._ _
      //  | . \/ . \/ . \ | |  | . | |     |<_> || '_> | |  | || ' |
      //  |___/\___/\___/ |_|  |_|_| |_|_|_|<___||_|   |_|  |_||_|_|
      //
      //                                                     booth@martinvt.com
      //  ______________________________________________________________________
      //    Web demo of Web Menu
      //    Nov, 2019
      //  ______________________________________________________________________
       ctl-opt
       option(*nodebugio) dftactgrp(*no) actgrp(*new);

       dcl-f WEBMENUD workstn  sfile(SFL1: SF1NUM);

       dcl-c cTrq x'30';
       dcl-c cBLUu x'3E';

       dcl-ds *n PSDS;
        USERID char(10) pos(358);
       end-ds;

       dcl-s SavedMENUCAT like(smenucat);
       dcl-s wMenuCat like(smenucat);
       dcl-s wMenuItem like(smenuitem);
       dcl-s wMenuCmd like(smenucmd);
       dcl-s wNbr1 zoned(3);
       dcl-s wNbr2 zoned(3);
       dcl-s wNdx zoned(3);
       dcl-s wCount zoned(3);
       dcl-s Ar1 like(smenuitem) dim(16);
       dcl-s Ar2 like(smenucmd) dim(16);
       dcl-s Ar3 like(smenucat) dim(16);

       dcl-s wcmd varchar(1024);
       dcl-pr qCmd extpgm('QCMDEXC');
        *n char(1024) const;
        *n packed(15: 5) const;
       end-pr;

       // The immediately following /EXEC SQL set options is SQL's version of
       // RPG's H Spec.  It is never executed; just used at compile time.
       // MUST be in source code above any other exec SQL statements.
       exec sql set option
             Commit = *None,
             SrtSeq = *LangIDShr;   // allows sort & search with upper/lower
       //==================================================================== *
       // MAINLINE                                                            *
       //==================================================================== *
       exsr FillFMT01;
       dow *inkc = *off;
         exsr ChangeColors;
         write S1CMD;
         exfmt FMT01;
         if SFLTOP2 < NBRREC;
         SFLTOP1 = SFLTOP2;   // Resets screen to same position.
         endif;
         select;
           when *inkc;        // exit
           when *inkp;
             wCmd = 'SIGNOFF';
               monitor;
                 qCmd(wCmd: %len(%trim(wCmd)));
               on-error;
               endmon;
           when SF1PICKED <> 0;
             chain SF1PICKED SFL1;
             wCmd = SMENUCMD;
             monitor;
               qCmd(wCmd: %len(%trim(wCmd)));
             on-error;
             endmon;
           other;
           endsl;
         enddo;
         *inlr = *on;
        //==================================================================== *
        // MAINLINE-END                                                        *
        //==================================================================== *
        //  Get & Set Heading info  --------------------------------------------
        begsr GetHeading;
          HDG5X40 =
                    '   _      __    __     __ __     __     '
                  + '  | | /| / /__ / /    / // /_ __/ /_    '
                  + '  | |/ |/ / -_) _ \  / _  / // / __/    '
                  + '  |__/|__/\__/_.__/ /_//_/\_,_/\__/     ';
          HDG7X23 =
                      '                       '
                    + '                       '
                    + '          ,,,          '
                    + '         (O-O)         '
                    + '  ----oo0-(_)-0oo----  '
                    + '                       '
                    + '                       ';
         exec SQL                              // Get user's name to display.
           select CID.ODOBTX
             into :S1USERNAME
             from Table( QSYS2/USERS() ) AS CID
             where CID.ODOBNM = :USERID;
         evalr S1USERNAME = 'with' + cTrq + %trim(S1USERNAME);
        endsr;
        //  Fill Screen  -------------------------------------------------------
        begsr FillFMT01;
          exsr GetHeading;
          SF1NUM = 0;                 // clear subfile
          *in80=*on;
          clear SFL1;
          write FMT01;
          *in80 = *off;
          SF1NUM = *zero;

          // Fill Array of entries (reduce widows & orphans)
          exec sql declare C1 cursor for  // Get all records
            select MENUCAT, MENUITEM, MENUCMD
              from WEBMENUP
              order by MENUCAT, MENUSEQ;
          exec sql open C1;

          dow Sqlcode = 0;                   // Table read loop
            exec sql fetch C1 into :wMenuCat, :wMenuItem, :wMenuCmd;
            if sqlcode = 0;
              if wMenuCat <> SavedMENUCAT;    // Category change: Show a heading
                SavedMENUCAT = wMenuCat;
                exsr AddMenuItems;
                wCount += 1;           // top line, blank, blue, underlined
                Ar1(wCount) = cBLUu;
                Ar2(wCount) = *blank;
                Ar3(wCount) = *blank;

                wCount += 1;    // 2nd line, Category centered, blue, underlined
                wNbr1 = (%size(SMENUITEM) + 1) -
                        (%len(%trim(wMenuCat)));
                wNbr2 = wNbr1 / 2;
                clear SMENUITEM;
                %subst(SMENUITEM: wNbr2:    // Center Category on column
                   %len(%trim(wMenuCat))) = %trim(wMenuCat);
                Ar1(wCount) = cBLUu + SMENUITEM;
                Ar2(wCount) = *blank;
                Ar3(wCount) = *blank;
              endif;
              if wMenuItem <> *blank;
                wCount += 1;           // Item shown, normal
                Ar1(wCount) = '  ' + wMenuItem;
                Ar2(wCount) = wMenuCmd;
                Ar3(wCount) = wMenuCat;
              endif;
            endif;
          enddo;
          exec sql close C1;
          exsr AddMenuItems;     // Add entries still in array.
        endsr;
        //  Add Menu Items  ----------------------------------------------------
        //   This step lessens widows & orphans
        begsr AddMenuItems;
            wNbr1 = 16 - %rem(SF1NUM: 16);   // = empty rows left in column
            if wCount > wNbr1;              // array is filled with more rows:
              for wNdx = 1 to wNbr1;        // fill rest of column
                SMENUITEM = *blank;         // with blamk lines.
                SMENUCMD = *blank;
                SMENUCAT = *blank;
                SF1NUM = SF1NUM + 1;
                write SFL1;
              endfor;
            endif;
            for wNdx = 1 to wCount;
              SMENUITEM = Ar1(wNdx);
              SMENUCMD = Ar2(wNdx);
              SMENUCAT = Ar3(wNdx);
              SF1NUM = SF1NUM + 1;
              write SFL1;
            endfor;
          NBRREC = SF1NUM;
          SFLTOP1 = 1;
          clear AR1;
          clear AR2;
          clear AR3;
          clear wCount;
        endsr;
        // --  Change Heading Colors  ----------------------------------------
        begsr ChangeColors;
          select;
            when *in61;
              *in61 = *off;
              *in62 = *on;
            when *in62;
              *in62 = *off;
              *in63 = *on;
            when *in63;
              *in63 = *off;
              *in64 = *on;
            when *in64;
              *in64 = *off;
              *in65 = *on;
            when *in65;
              *in65 = *off;
              *in66 = *on;
            when *in66;
              *in66 = *off;
              *in67 = *on;
            other;
              *in67 = *off;
              *in61 = *on;
          endsl;
        endsr;





