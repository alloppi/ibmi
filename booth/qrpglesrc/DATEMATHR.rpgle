      //*********************************************************************
      //      ___             _    _     __ __             _    _           *
      //     | . > ___  ___ _| |_ | |_  |  \  \ ___  _ _ _| |_ <_>._ _      *
      //     | . \/ . \/ . \ | |  | . | |     |<_> || '_> | |  | || ' |     *
      //     |___/\___/\___/ |_|  |_|_| |_|_|_|<___||_|   |_|  |_||_|_|     *
      //                                                                    *
      //     A Demo program of various date math techniques.                *
      //                                                                    *
      //  12/2010                                       booth@martinvt.com  *
      //*********************************************************************
      //   5/2014    Added Pop-up Calendar & updated code.                  *
      //*********************************************************************
     H option(*nodebugio) dftactgrp(*no) actgrp(*new)
     FDATEMATHD cf   e             workstn

      *  ASCII art panel for heading. (Use a Figlet generator.)
     D FIGLET          ds
     D Figar                         60    dim(6) ctdata perrcd(1)
      * Constants
     D  cTRQ           c                   x'30'
      // Work fields
     D wTestDate       s               d   inz(d'2010-01-04')
     D wNdx            s             10i 0
     D wS1Exit         s               n

     D GetCalendar     pr                  extpgm('POPUPCALR')
     D  pDate                          d

      /FREE
        //====================================================================*
        // MAIN CALCULATIONS                                                  *
        //====================================================================*
         // Loop until exit.
         wS1Exit = *off;
         dow wS1Exit = *off;
           //   Display screen.
           exsr S1Fill;
           exfmt FMT01;
           //   Perform keypress.
           select;
             //     F3=Exit.
           when *inkc = *on;
             wS1Exit = *on;
           when *inkd or FLD = 'DATEF4';
             GetCalendar(DAT);
           other;  // everything else; process the enter key
             exsr S1KeyEnter;
           endsl;
         enddo;
         exsr ExitPgm;
         //====================================================================*
         // MAINLINE-END                                                       *
         //====================================================================*
         //-------------------------------*  Sub-Routine  *
         // *inzsr()                      *---------------*
         // Initialize variables, set constants.          *
         //-----------------------------------------------*
       begsr *inzsr;
         DAT = %date();
         // change color in heading
         Figar(6) = %subst(Figar(5): 1:49) + cTRQ + '& Friends';
       endsr;
         //-------------------------------*  Sub-Routine  *
         // ExitPgm()                     *---------------*
         // Exit program.                                 *
         //-----------------------------------------------*
         begsr ExitPgm;
           *inlr = *on;
           return;
         endsr;
         //--------------------------------------------------------------------*
         // Screen 1 procedures.        Screen1                                *
         //--------------------------------------------------------------------*
         //-------------------------------*  Sub-Routine  *
         // S1Fill()                      *---------------*
         // Screen - Fill screen.                         *
         //-----------------------------------------------*
         begsr S1Fill;
           exsr GetDayOfWeek;
           exsr GetJulianDate;
           exsr GetEndOfMonth;
           exsr GetLastFriday;
           exsr GetNextTuesday;
           exsr AddDaysToDate;
           exsr SetCYYMMDDDate;
           TIMEUSA = (%char(%time(): *usa));
           DATEUSA = %char(%date(): *mdy);
         endsr;
         //-------------------------------*  Sub-Routine  *
         // S1KeyEnter()                  *---------------*
         // Enter key                                     *
         //-----------------------------------------------*
         begsr S1KeyEnter;
           exsr S1Validate;
           if *in90 = *off;  // If no errors then proceed.
             exsr S1Process;
           endif;
         endsr;
         //-------------------------------*  Sub-Routine  *
         // S1Validate()                  *---------------*
         // Screen - Validate entry fields.               *
         //-----------------------------------------------*
         begsr S1Validate;
           *in90 = *off;
         endsr;
         //-------------------------------*  Sub-Routine  *
         // S1Process()                   *---------------*
         // Process screen 1                              *
         //-----------------------------------------------*
         begsr S1Process;
         endsr;
         //-------------------------------*  Sub-Routine  *
         // GetDayOfWeek()                *---------------*
         // Get the day of the week                       *
         //-----------------------------------------------*
         begsr GetDayOfWeek;
            wNdx = %diff(DAT: wTestDate: *days);
            wNdx = %rem(wNdx: 7);
            select;
            when wNdx = 0;
              DOWEEK = 'Monday';
            when wNdx = 1;
              DOWEEK = 'Tuesday';
            when wNdx = 2;
              DOWEEK = 'Wednesday';
            when wNdx = 3;
              DOWEEK = 'Thursday';
            when wNdx = 4;
              DOWEEK = 'Friday';
            when wNdx = 5;
              DOWEEK = 'Saturday';
            when wNdx = 6;
              DOWEEK = 'Sunday';
            endsl;
         endsr;
        //-------------------------------*  Sub-Routine  *
        // GetJulianDate()               *---------------*
        // Get the Julian date                           *
        //-----------------------------------------------*
         begsr GetJulianDate;
           JDAY = DAT;
         endsr;
        //-------------------------------*  Sub-Routine  *
        // GetEndOfMonth()               *---------------*
        // Get the end of this month                     *
        //-----------------------------------------------*
        begsr GetEndOfMonth;
          EOM = DAT + %months(1);
          EOM = EOM - %days(%subdt(EOM: *days));
        endsr;
        //-------------------------------*  Sub-Routine  *
        // GetLastFriday()               *---------------*
        // Get a day in the past (next Friday, for demo.)*
        //-----------------------------------------------*
        begsr GetLastFriday;
          wNdx = %diff(DAT: wTestDate: *days);
          wNdx = %rem(wNdx: 7);
          wNdx = 3 + wNdx;
          LASTFRI = DAT - %days(wNdx);
        endsr;
        //-------------------------------*  Sub-Routine  *
        // GetNextTueday()               *---------------*
        // Get some day in the future (Tuesday as a demo)*
        //-----------------------------------------------*
        begsr GetNextTuesday;
          wNdx = %diff(DAT: wTestDate: *days);
          wNdx = %rem(wNdx: 7);
          if wNdx = 0;
            wNdx = 7;
          endif;
          wNdx = (8 - wNdx);
          NEXTTUE = DAT + %days(wNdx);
        endsr;
        //-------------------------------*  Sub-Routine  *
        // AddDaysToDate()               *---------------*
        // Add/subtract days from a date                 *
        //-----------------------------------------------*
        begsr AddDaysToDate;
          ADDSUB = DAT + %days(ADDDAYS);
        endsr;
        //-------------------------------*  Sub-Routine  *
        // SetCYYMMDDDate()              *---------------*
        // Deal with C datess                            *
        //-----------------------------------------------*
        begsr SetCYYMMDDDate;
          CDAY = %char(DAT: *CYMD0);
          REGDATE = %char(%date(CDAY: *CYMD0));
        endsr;
      /END-FREE
** FIGAR 1....+....2....+,,,,3,,,,+,,,,4,,,,+....5....+....6....+

  _ )              |    |        \  |            |   _)
  _ \   _ \   _ \   _|    \     |\/ |   _` |   _| _|  |    \
 ___/ \___/ \___/ \__| _| _|   _|  _| \__,_| _| \__| _| _| _|


