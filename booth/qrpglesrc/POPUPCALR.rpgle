      //***************************************************************
      //   ___             _    _     __ __             _    _        *
      //  | . > ___  ___ _| |_ | |_  |  \  \ ___  _ _ _| |_ <_>._ _   *
      //  | . \/ . \/ . \ | |  | . | |     |<_> || '_> | |  | || ' |  *
      //  |___/\___/\___/ |_|  |_|_| |_|_|_|<___||_|   |_|  |_||_|_|  *
      //                                                              *
      //                                         booth@martinvt.com   *
      //***************************************************************
      // A program to show a pop-up calendar                          *
      //    7/02  Booth M.  Rewritten 2/12 & 5/2014                   *
      //                                                              *
      // Notes on use:                                                *
      //   1 - This calendar also works if no parm is used.           *
      //   2 - The parm is defined as a date field:                   *
      //         (not numeric, not alpha, but as a date field)        *
      //   3 - If *loval is passed in then the calendar is set        *
      //       at today's date.                                       *
      //   4 - When F3 or F12 is pressed the job ends with the        *
      //       parm unchanged.                                        *
      //   5 - A mouse button click selects a date.                   *
      //                                                              *
      //  Original source came from:                                  *
      //  http://www.400times.com/FrameData/Pop-up_Calendar.htm       *
      //    Modifications:                                            *
      //    05/02/11 C.Wilt - Replaced a couple of bunches of IF      *
      //                       statements with loops.  Modified  to   *
      //                       exit only on valid select or F3/F12    *
      //                       Protect all day fields                 *
      //   06/13/11 C.Wilt - Modified to work with both DS3 and DS4   *
      //                      screen sizes.                           *
      //***************************************************************
     H COPYRIGHT('(C) Copyright Booth Martin, 2010 All rights reserved.')
     H option(*nodebugio) dftactgrp(*no) actgrp(*caller)
     FPOPUPCALD cf   e             workstn

     d StartDate       s               d
     d wDate           s               d
      // Use firstdate to figure 1st day-of-month (1900-01-07 is a Sunday).
     d firstdate       s               d   inz(d'1900-01-07')
     d day#            s              2s 0
     d wNdx            s             10i 0
     d wString         s             10
     d wMONTHYEAR      s                   like(MONTHYEAR)
     d CurYear         s              4s 0
     d CurMonth        s              2s 0
     d CurDay          s              2
      // Array of slots on calendar (6 rows of 7 days)
     d                 ds
     d wCalendar                     76
      * Fill the screen's 38 slots from the wCalendaray.
     d   day01                             overlay(wCalendar)
     d   day02                             overlay(wCalendar: *next)
     d   day03                             overlay(wCalendar: *next)
     d   day04                             overlay(wCalendar: *next)
     d   day05                             overlay(wCalendar: *next)
     d   day06                             overlay(wCalendar: *next)
     d   day07                             overlay(wCalendar: *next)
     d   day08                             overlay(wCalendar: *next)
     d   day09                             overlay(wCalendar: *next)
     d   day10                             overlay(wCalendar: *next)
     d   day11                             overlay(wCalendar: *next)
     d   day12                             overlay(wCalendar: *next)
     d   day13                             overlay(wCalendar: *next)
     d   day14                             overlay(wCalendar: *next)
     d   day15                             overlay(wCalendar: *next)
     d   day16                             overlay(wCalendar: *next)
     d   day17                             overlay(wCalendar: *next)
     d   day18                             overlay(wCalendar: *next)
     d   day19                             overlay(wCalendar: *next)
     d   day20                             overlay(wCalendar: *next)
     d   day21                             overlay(wCalendar: *next)
     d   day22                             overlay(wCalendar: *next)
     d   day23                             overlay(wCalendar: *next)
     d   day24                             overlay(wCalendar: *next)
     d   day25                             overlay(wCalendar: *next)
     d   day26                             overlay(wCalendar: *next)
     d   day27                             overlay(wCalendar: *next)
     d   day28                             overlay(wCalendar: *next)
     d   day29                             overlay(wCalendar: *next)
     d   day30                             overlay(wCalendar: *next)
     d   day31                             overlay(wCalendar: *next)
     d   day32                             overlay(wCalendar: *next)
     d   day33                             overlay(wCalendar: *next)
     d   day34                             overlay(wCalendar: *next)
     d   day35                             overlay(wCalendar: *next)
     d   day36                             overlay(wCalendar: *next)
     d   day37                             overlay(wCalendar: *next)
     d   day38                             overlay(wCalendar: *next)
     d Arr                            2    dim(38) overlay(wCalendar)
      //  Number of days in the month:
     d pdmds           ds
     d                                2  0 inz(31)
     d                                2  0 inz(28)
     d                                2  0 inz(31)
     d                                2  0 inz(30)
     d                                2  0 inz(31)
     d                                2  0 inz(30)
     d                                2  0 inz(31)
     d                                2  0 inz(31)
     d                                2  0 inz(30)
     d                                2  0 inz(31)
     d                                2  0 inz(30)
     d                                2  0 inz(31)
     d                                2  0 inz(01)
     d pdm                            2  0 dim(13) overlay(pdmds)
     d MonthNames      ds
     d                                9    inz('January  ')
     d                                9    inz('February ')
     d                                9    inz('March    ')
     d                                9    inz('April    ')
     d                                9    inz('May      ')
     d                                9    inz('June     ')
     d                                9    inz('July     ')
     d                                9    inz('August   ')
     d                                9    inz('September')
     d                                9    inz('October  ')
     d                                9    inz('November ')
     d                                9    inz('December ')
     d  MthNam                        9    dim(12) overlay(MonthNames)

      *Retrieve Screen Dimensions
     d SetScreenSize   pr            10i 0 extproc('QsnRtvScrDim')
     d   NbrRows                     10i 0 options(*omit)
     d   NbrCols                     10i 0 options(*omit)
     d   Handle                      10i 0 options(*omit)
     d   ErrorCode                32767    options(*varsize: *omit)
     d   NbrColumns    s             10i 0

     d POPUPCALR       pr
     k  pDate                          d
     d POPUPCALR       pi
     d  pDate                          d

      // ===============================================================
      // ==         Mainline                                          ==
      // ===============================================================
      /free
       //check current screen size, configure to match
       SetScreenSize(*omit:NbrColumns:*omit:*omit);
       if nbrColumns = 132;
         *in90 = *on;
       else;
         *in90 = *off;
       endif;
       exsr FillCalendar;

       dow not *inlr;
         exfmt fmt001;
         select;
         when *inkl or *inkc;   // exit/return
           exsr ExitPgm;
           // Go back one year.
         when CSRFLD = 'PREVYEAR';
           startdate = startdate - %years(1);
           exsr FillCalendar;
           // Go back one month
         when CSRFLD = 'PREVMONTH';  // Pagedown
           startdate = startdate - %months(1);
           exsr FillCalendar;
           // Go forward one month
         when CSRFLD = 'NEXTMONTH';  // Pageup
           startdate = startdate + %months(1);
           exsr FillCalendar;
           // Go forward one year.
         when CSRFLD = 'NEXTYEAR';
           startdate = startdate + %years(1);
           exsr FillCalendar;
           // end of job -  Either a command key or Enter key:
         other;
         if %parms = 1 and %subst(CSRFLD: 1: 3) = 'DAY';
           exsr FillParm;
           exsr ExitPgm;
         endif;
         endsl;
       enddo;
       // End of routine:
       // ===============================================================
       // ==         Sub Routines                                      ==
       // ===============================================================
       //-------------------------------------------------------------------
       //--  Initializing routine                                       --
       //-------------------------------------------------------------------
       begsr *inzsr;
         if (%parms = 1) and (pdate <> *loval);
           StartDate = pDate;
         else;
           StartDate = %date();
         endif;
       endsr;
       //-------------------------------------------------------------------
       //--  Exit routine                                                 --
       //-------------------------------------------------------------------
       begsr ExitPgm;
         *inlr = *on;
         return;
       endsr;
       //-------------------------------------------------------------------
       //--  Fill the calendar fields.                                    --
       //-------------------------------------------------------------------
       begsr FillCalendar;
         // Get fields to fill calendar
         CurYear  = %subdt(StartDate: *y);
         CurMonth = %subdt(StartDate: *m);
         CurDay   = %char(%subdt(StartDate: *d));
         clear MONTHYEAR;
         wMONTHYEAR = %trim(mthnam(CurMonth)) + ', ' + %char(CurYear);
         wNdx = (%size(MONTHYEAR) - %len(%trim(wMONTHYEAR))) / 2;
         %subst(MONTHYEAR: wNdx) = %trim(wMONTHYEAR);
         // is this a leap year?
         if %rem(CurYear: 4) = 0
               and CurYear <> 2000;
           pdm(2) = 29;
         endif;
         // Fill array with date numbers
         clear arr;
         // Find day of the week for first day on the calendar
         wDate = StartDate - %days(%int(CurDay) - 1);
         day# = %rem((%diff(wDate: firstdate: *days)): 7) + 1;
         // Fill the calendar slots with days of the month, beginning @ day#
         for wNdx = 1 to pdm(CurMonth);
           evalr Arr(day#) = %char(wNdx);
           day# += 1;
         endfor;
       endsr;
       //-------------------------------------------------------------------
       //--  Fill return parm                                         --
       //-------------------------------------------------------------------
       begsr FillParm;
       // Fill return fields
       wNdx = %int(%subst(%trim(csrfld): 4: 2));
       if Arr(wNdx) > ' ';
         wNdx = %int(Arr(wNdx));
         if wNdx < 10;  // Re-insert leading zero if day is 1st - 9th.
           CurDay = '0' + %trim(%char(wNdx));
         else;
           CurDay = %char(wNdx);
         endif;
         wString = %editc(CurYear: 'X') + '-'
               + %editc(CurMonth: 'X') + '-'
               + CurDay;
         pDate = %date(wString: *iso);
       endif;
       endsr;
       //-------------------------------------------------------------------
       //--  End-of subroutines                                           --
       //-------------------------------------------------------------------
