       //***************************************************************
       //   ___             _    _     __ __             _    _        *
       //  | . > ___  ___ _| |_ | |_  |  \  \ ___  _ _ _| |_ <_>._ _   *
       //  | . \/ . \/ . \ | |  | . | |     |<_> || '_> | |  | || ' |  *
       //  |___/\___/\___/ |_|  |_|_| |_|_|_|<___||_|   |_|  |_||_|_|  *
       //                                                              *
       //  A full-screen data editor                                   *
       //                                                              *
       //   3/2015                                 booth@martinvt.com  *
       //***************************************************************
       // COMMENTS  Added error checking with cursor positioning.      *
       //                                                              *
       //***************************************************************

     h COPYRIGHT('(C) Booth Martin 2013.')
     h option(*nodebugio) dftactgrp(*no) actgrp(*new)
     fDATAEDITD cf   e             workstn sfile(SFL1 : SF1NUM)
     fDATAEDITF if a f  128        disk

     d FIGLET          ds
     d Figar                         65    dim(5) ctdata perrcd(1)

     d wNewRecords     s              5  0 inz(30)
     d wNdx            s              5  0
     d wErrorFound     s               n

     d NewRecordDS     ds
     d  NewData                            like(DATA)

     d wcmd            s           1024    varying
     d QCMD            pr                  ExtPgm('QCMDEXC')
     d                             1024    const
     d                               15  5 const

     iDATAEDITF NS
     i                                  1  128  DATA

      //====================================================================*
      // MAINLINE-BEGIN                                                     *
      //====================================================================*
      // Display screen.
      /FREE
         //   Display screen.
         write S1CMD;
         exfmt S1;
         select;
         when *inkc = *on;    // F3=Exit.
           exsr ExitPgm;
         other;
           exsr Validate;
           if wErrorFound = *off;    // save data & refill subfile.
             exsr SaveData;
             exsr S1Fill;
           endif;
         endsl;
       //====================================================================*
       // MAINLINE-END                                                       *
       //====================================================================*
       //-------------------------------*  Sub-Routine  *
       // INZSR()                       *---------------*
       //                                               *
       //-----------------------------------------------*
       begsr *INZSR;
         exsr S1Fill;
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
       // S1Fill()                      *---------------*
       // Screen - Fill screen.                         *
       //-----------------------------------------------*
       begsr S1Fill;
         // Clear subfile.
         *in50 = *on;
         write S1;
         *in50 = *off;
         // Fill SFL.
         SF1NUM = *zero;
         // Read the file.
         setll *start DATAEDITF;
         read DATAEDITF;
         dow not %eof;
           SF1NUM = SF1NUM + 1;
           write SFL1;
           read DATAEDITF;
         enddo;
         // Create some empty records for adding records.
         clear DATA;
         for wNdx = 1 to wNewRecords;
           SF1NUM = SF1NUM + 1;
           write SFL1;
         endfor;
         // Save values.
         SF1RECS = SF1NUM;
         SF1TOP = 1;
       endsr;
       //-------------------------------*  Sub-Routine  *
       // Validate()                    *---------------*
       // Validate the data.                            *
       //-----------------------------------------------*
       begsr Validate;
         wErrorFound = *off;
         // Check the lines of data for errors
         for wNdx = 1 to SF1RECS;
           chain wNdx SFL1;
           If %trim(DATA) = 'Error';  //  <-demo error condition.
             wErrorFound = *on;
             *in33 = *on;
             update SFL1;
           endif;
         endfor;
       endsr;
       //-------------------------------*  Sub-Routine  *
       // SaveData()                    *---------------*
       // Save the edited data                          *
       //-----------------------------------------------*
       begsr SaveData;
         // Clear the data file.
         close DATAEDITF;
         wCmd = 'CLRPFM FILE(DATAEDITF)';
         qcmd(wCmd:%len(wCmd));
         open DATAEDITF;
         // Find the last filled record.  ( This process ia to allow blank
         // records in the file.)
         for SF1RECS = SF1NUM downto 1;
           chain SF1RECS SFL1;
           if DATA <> *blanks;
             leave;
           endif;
         endfor;
         // Fill the data file with the data.
         for wNdx = 1 to SF1RECS;
           chain wNdx SFL1;
           NewData = DATA;
           write DATAEDITF NewRecordDS;
         endfor;
         // Refill the subfile with the new data.
         exsr S1Fill;
       endsr;

      /END-FREE
** Figar 1....+....2....+....3....+....4....+....5....+....6....+
    ____        __           ______    ___ __
   / __ \____ _/ /_____ _   / ____/___/ (_) /_____  _____
  / / / / __ `/ __/ __ `/  / __/ / __  / / __/ __ \/ ___/
 / /_/ / /_/ / /_/ /_/ /  / /___/ /_/ / / /_/ /_/ / /
/_____/\__,_/\__/\__,_/  /_____/\__,_/_/\__/\____/_/
