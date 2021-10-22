     F* ====================================================================
     F* ============== Advanced Integrated RPG by Tom Snyder ===============
     F* ====================================================================
     F* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     F* All rights reserved.
     F*
     F* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     F* Author URL:    http://www.2WolvesOut.com
     F**********************************************************************
     F*  How to Compile:
     F*
     F*   (1. CREATE THE MODULE)
     F*   CRTRPGMOD MODULE(AIRLIB/AIR03_01) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR03_01)
     F*   MODULE(AIRLIB/AIR03_01)
     F*   BNDSRVPGM(AIRLIB/SVAIRSAMP) ACTGRP(*NEW)
     F*****************************************************************
     FSTUDENTS  IF   E           K DISK
     D*
     D/COPY AIRLIB/AIRSRC,SPAIRSAMP
     D*
     D displayBytes    S             52A
     D rank            S             10I 0
     D rankAlpha       S             10A
     C*
      /free
       Air_openFiles('MAINCAMPUS');
       setll *START STUDENTS;
       read STUDENTS;
       dow not %eof(STUDENTS);
         rank = Air_getRank(STACCT);
         exsr DSPINFO;
         read STUDENTS;
       enddo;
       Air_closeFiles();
       *inlr = *ON;
       //-----------------------------------------------------------
       // DSPINFO: Display the Rank Information on the Screen.
       //-----------------------------------------------------------
       begsr DSPINFO;
         displayBytes = '----------------';
         DSPLY displayBytes;
         displayBytes = 'First Name: ' + STFNAM;
         DSPLY displayBytes;
         displayBytes = 'Last Name: ' + STLNAM;
         DSPLY displayBytes;
         displayBytes = 'Major: ' + STMAJOR;
         DSPLY displayBytes;
      /end-free
     C* OP CODE 'MOVE' IS NOT AVAILABLE IN FREE-FORMAT
     C                   MOVE      rank          rankAlpha
      /free
         displayBytes = 'Rank: ' + rankAlpha;
         DSPLY displayBytes;
       endsr;
      /end-free
