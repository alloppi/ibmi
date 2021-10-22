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
     F*   CRTRPGMOD MODULE(AIRLIB/AIR02_02) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE PROGRAM)
     F*   CRTPGM PGM(AIRLIB/AIR02_02)
     F*   MODULE(AIRLIB/AIR02_02)
     F*   BNDSRVPGM(AIRLIB/SVAIRSAMP) ACTGRP(AIR02_02)
     F**********************************************************************
     FSTUDENTS  IF   E           K DISK
     D*
     D/COPY AIRLIB/AIRSRC,SPAIRSAMP
     D*
     D displayBytes    S             52A
     D rank            S             10I 0
     D rankAlpha       S             10A
     C*
     C                   CALLP     Air_openFiles('MAINCAMPUS')
     C     *START        SETLL     STUDENTS
     C                   READ      STUDENTS                               69
     C                   DOW       *IN69 = *OFF
     C*
     C                   EVAL      rank = Air_getRank(STACCT)
     C*
     C                   EXSR      DSPINFO
     C*
     C                   READ      STUDENTS                               69
     C                   ENDDO
     C                   CALLP     Air_closeFiles()
     C                   EVAL      *inlr = *ON
     C**********************************************************************************************
     C* DSPINFO: Display the Rank Information on the Screen.
     C**********************************************************************************************
     C     DSPINFO       BEGSR
     C                   EVAL      displayBytes = '----------------'
     C     displayBytes  DSPLY
     C                   EVAL      displayBytes = 'First Name: '
     C                                          + STFNAM
     C     displayBytes  DSPLY
     C                   EVAL      displayBytes = 'Last Name: '
     C                                          + STLNAM
     C     displayBytes  DSPLY
     C                   EVAL      displayBytes = 'Major: '
     C                                          + STMAJOR
     C     displayBytes  DSPLY
     C                   MOVE      rank          rankAlpha
     C                   EVAL      displayBytes = 'Rank: '
     C                                          + rankAlpha
     C     displayBytes  DSPLY
     C                   ENDSR
