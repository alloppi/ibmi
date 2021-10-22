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
     F*   CRTBNDRPG PGM(AIRLIB/AIR02_01) SRCFILE(AIRLIB/AIRSRC)
     F**********************************************************************
     FSTUDENTS  IF   E           K DISK
     FGRADES    IF   E           K DISK
     D*
     DXSTUDENTS      E DS                  EXTNAME(STUDENTS)
     DHSTUDENTS      E DS                  EXTNAME(STUDENTS)
     D                                     PREFIX(H)
     D*
     D displayBytes    S             52A
     D rank            S             10I 0
     D rankAlpha       S             10A
     D currentTotal    S             10I 0
     D currentCount    S             10I 0
     D score           S              7S 4
     D rankScore       S              7S 4
     C*
     C     *START        SETLL     STUDENTS
     C                   READ      STUDENTS                               69
     C                   DOW       *IN69 = *OFF
     C                   EVAL      HSTUDENTS = XSTUDENTS
     C*
     C                   EXSR      GETRANK
     C* Reposition STUDENTS file pointer
     C     HSTACCT       CHAIN     STUDENTS                           69
     C*
     C                   EXSR      DSPINFO
     C*
     C                   READ      STUDENTS                               69
     C                   ENDDO
     C                   EVAL      *inlr = *ON
     C**********************************************************************************************
     C* GETRANK: Retrieves the rank for students in the same major
     C**********************************************************************************************
     C     GETRANK       BEGSR
     C                   EVAL      rank = 0
     C                   DOU       *IN67 = *ON
     C                   EVAL      currentTotal = 0
     C                   EVAL      currentCount = 0
     C     STACCT        CHAIN     GRADES                             68
     C                   DOW       *IN68 = *OFF
     C                   EVAL      currentTotal = currentTotal + SGCLGRADE
     C                   EVAL      currentCount = currentCount + 1
     C     STACCT        READE     GRADES                                 68
     C                   ENDDO
     C                   IF        currentCount = 0
     C                   EVAL      score = 0
     C                   ELSE
     C                   EVAL      score = currentTotal / currentCount
     C                   ENDIF
     C                   IF        STACCT = HSTACCT
     C                   EVAL      rank = 1
     C                   EVAL      rankScore = score
     C     *START        SETLL     STUDENTS
     C                   ELSE
     C                   IF        score > rankScore
     C                   EVAL      rank = rank + 1
     C                   ELSE
     C                   ENDIF
     C                   ENDIF
     C                   DOU       (STACCT <> HSTACCT
     C                             AND STMAJOR = HSTMAJOR)
     C                             OR *IN67
     C                   READ      STUDENTS                               67
     C                   ENDDO
     C                   ENDDO
     C                   ENDSR
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
