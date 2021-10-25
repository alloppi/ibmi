       //***************************************************************
       //   ___             _    _     __ __             _    _        *
       //  | . > ___  ___ _| |_ | |_  |  \  \ ___  _ _ _| |_ <_>._ _   *
       //  | . \/ . \/ . \ | |  | . | |     |<_> || '_> | |  | || ' |  *
       //  |___/\___/\___/ |_|  |_|_| |_|_|_|<___||_|   |_|  |_||_|_|  *
       //                                                              *
       //  A program to  show a subfile that can link to images.       *
       //                                                              *
       //                                                              *
       //                                                              *
       //  10/2010                                 booth@martinvt.com  *
       //***************************************************************
       // COMMENTS   This program uses MOUBTN() to click F8 to pick    *
       //            a subfile line for linking to an image.           *
       //            It uses the PC Client's file extension default    *
       //            to open the image.                                *
       //                                                              *
       //            (I suppose it could open any file.  I know if     *
       //             one uses a filename of "NOTEPAD" then            *
       //             NOTEPAD.EXE opens with a blank panel.)           *
       //                                                              *
       //  Note:  This program uses STRPCCMD.  STRPCCMD uses a command *
       //         parm of 123 characters.  This is normally a problem  *
       //         but solving it is not part of this demo.             *
       //         -= be warned =-                                      *
       //                                                              *
       //--------------------------------------------------------------*
     H COPYRIGHT('Booth Martin, All rights reserved.')
     H option(*nodebugio) dftactgrp(*no) actgrp(*new)

     FSFLIMAGED cf   e             workstn sfile(SFL1 : SF1NUM)
     FSFLIMAGEP if   e             disk

     D STRPCOflag      s               n
     D wNdx            s             10i 0

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D  wCommand                  32702A   const options(*varsize)
     D  wLength                      15P 5 const
     D wCmd            s           1000    varying

      //====================================================================*
      // MAINLINE-BEGIN                                                     *
      //====================================================================*
      /FREE
       exsr S1Fill;
       // Display screen.
       exsr S1Main;
       // Exit.
       exsr ExitPgm;
       //====================================================================*
       // MAINLINE-END                                                       *
       //====================================================================*
       //-------------------------------*  Sub-Routine  *
       // *inzsr()                      *---------------*
       // Initializing sub routine                      *
       //-----------------------------------------------*
       begsr *inzsr;
       endsr;
       //-------------------------------*  Sub-Routine  *
       // ExitPgm()                     *---------------*
       // end of processing                             *
       //-----------------------------------------------*
       begsr ExitPgm;
         *inlr = *on;
         return;
       endsr;
       //-------------------------------*  Sub-Routine  *
       // S1Main()                      *---------------*
       // Screen - Main processing.                     *
       //-----------------------------------------------*
       begsr S1Main;
         // Loop until exit.
         dow *inkc = *off;
           //   Display screen.
           write S1CMD;
           exfmt S1;

           select;
             // F3=Exit.
           when *inkc = *on;
             // F8 on either by key or by mouseclick, and on a subfile line.
           when *inkh and SF1PICKED > 0;
             exsr SFL1Link;
           endsl;
         enddo;
       endsr;
       //-------------------------------*  Sub-Routine  *
       // SFL1Link()                    *---------------*
       // Link to the images.                           *
       //-----------------------------------------------*
       begsr SFL1Link;
         // Start PC Organizer if not started.
         if STRPCOflag = *off;
           wCmd = 'STRPCO PCTA(*NO)';
           callp(e) QCmdExc(wCmd: %len(wCmd) );
           STRPCOflag = *on;
         endif;

         chain SF1PICKED SFL1;
         if HAVEFILE = '*';
           wCmd =
               'STRPCCMD PCCMD('
               + '''rundll32 shell32,ShellExec_RunDLL '
               + %trim(SERVERLOC) + %trim(FILENAME)
               + ''') PAUSE(*NO)';
           QCmdExc(wCmd: %len(wCmd) );
         else;
           // do whatever you want to when there is no hit.
         endif;
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
         // Fill the subfile.
         //   Read the file.
         setll *start SFLIMAGEP;
         read(e) SFLIMAGEP;
         dow %eof = *off;
           SF1NUM = SF1NUM + 1;
           if SERVERLOC <> *blanks or FILENAME <> *blanks;
             HAVEFILE = '*';
             *in31 = *on;
           else;
             HAVEFILE = *blanks;
             *in31 = *off;
           endif;
           write(e) SFL1;
           read(e) SFLIMAGEP;
         enddo;

         // No records?
         if SF1NUM = *zero;
           SF1NUM = 1;
           DESCRIPT = 'No records in file';
           write(e) SFL1;
         endif;

         // Save values.
         SF1RECS = SF1NUM;
         SF1TOP = 1;
       endsr;

