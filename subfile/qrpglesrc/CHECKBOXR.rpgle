				   //***************************************************************
       //   ___             _    _     __ __             _    _        *
       //  | . > ___  ___ _| |_ | |_  |  \  \ ___  _ _ _| |_ <_>._ _   *
       //  | . \/ . \/ . \ | |  | . | |     |<_> || '_> | |  | || ' |  *
       //  |___/\___/\___/ |_|  |_|_| |_|_|_|<___||_|   |_|  |_||_|_|  *
       //                                                              *
       //  A program to demo Checkboxes & Radio Buttons.               *
       //                                                              *
       //   1/2013                                 booth@martinvt.com  *
       //***************************************************************
       // COMMENTS                                                     *
       //                                                              *
       //***************************************************************

     H COPYRIGHT('(C) Booth Martin 2013.')
     H option(*nodebugio) dftactgrp(*no) actgrp(*caller)

     FCHECKBOXD cf   e             workstn

      /FREE
       //====================================================================*
       // MAIN CALCULATIONS                                                  *
       //====================================================================*
       // Display screen.
       dow *inkc = *off;
       exfmt FMT01;
       exsr ProcessFMT01;
       enddo;
        // Exit.
       exsr ExitPgm;
        //====================================================================*
        // MAINLINE-END                                                       *
        //====================================================================*
        //-------------------------------*  Sub-Routine  *
        // *inzsr()                      *---------------*
        // Initialize variables, set constants.          *
        //-----------------------------------------------*
       begsr *inzsr;
       exsr FillLabels;
       endsr;
        //-------------------------------*  Sub-Routine  *
        // ExitPgm()                     *---------------*
        // Exit program.                                 *
        //-----------------------------------------------*
       begsr ExitPgm;
         *inlr = *on;
         return;
       endsr;
        //-------------------------------*  Sub-Routine  *
        // FillLabels()                  *---------------*
        // Fill labels for check boxes & radio buttons.  *
        //-----------------------------------------------*
       begsr FillLabels;
           CB01 = 'Apples';
           CB02 = 'Bananas';
           CB03 = 'Cherries';
           CB04 = 'Danish';
           CB05 = 'Elk';
           CB06 = 'Fish';
           CB07 = 'Gourds';
           CB08 = 'Honey';
           CB09 = 'Iguana';
           CB10 = 'Jelly';
           CB11 = 'Kelp';
           CB12 = 'Lemons';
           CB13 = 'Mangoes';
           CB14 = 'Nectar';
           CB15 = 'Orange';
           CB16 = 'Plums';
           CB17 = 'Quince';
           CB18 = 'Rhubarb';
           RB01 = 'Aqua';
           RB02 = 'Blue';
           RB03 = 'Coral';
           RB04 = 'DarkCyan';
           RB05 = 'Euchre';
           RB06 = 'FireBrick';
           RB07 = 'Green';
           RB08 = 'HoneyDew';
           RB09 = 'Indigo';
           RB10 = 'Jinko';
           RB11 = 'Khaki';
           RB12 = 'Lavender';
           RB13 = 'Magenta';
           RB14 = 'Navy';
           RB15 = 'Olive';
           RB16 = 'Pink';
           RB17 = 'Red';
           RB18 = 'Slate';
       endsr;
        //-------------------------------*  Sub-Routine  *
        // ProcessFMT01()                *---------------*
        // Do whatever you want to do with the screen    *
        //-----------------------------------------------*
       begsr ProcessFMT01;
         // your code
       endsr;
