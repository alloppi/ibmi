     H COPYRIGHT('(C) Copyright Tom Snyder, 2010')
     H NOMAIN THREAD(*SERIALIZE) OPTION(*NODEBUGIO: *SRCSTMT: *NOSHOWCPY)
     F**********************************************************************
     F* ====================================================================
     F* ============== Advanced Integrated RPG by Tom Snyder ===============
     F* ====================================================================
     F* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     F* All rights reserved.
     F*
     F* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     F* Author URL:    http://www.2WolvesOut.com
     F*
     F* Source code/material located at http://www.mc-store.com/5105.html
     F* On the books page, click the reviews, errata, downloads icon to go
     F* to the books forum.  This source code may not be hosted on any
     F* other site without my express, prior, written permission.
     F*
     F* I disclaim any and all responsibility for any loss, damage or
     F* destruction of data or any other property which may arise using
     F* this code. I will in no case be liable for any monetary damages
     F* arising from such loss, damage or destruction.
     F*
     F* This code is intended for educational purposes, which includes
     F* minimal exception handling to focus on the topic being discussed.
     F* You may want to implement additional exception handling to prepare
     F* for a production environment.
     F*
     F* Happy Coding!
     F**********************************************************************
     F*   HOW TO COMPILE:
     F*
     F*   (1. CREATE THE MODULE)
     F*   CRTRPGMOD MODULE(AIRLIB/SVAIRSAMP) SRCFILE(AIRLIB/AIRSRC) +
     F*             DBGVIEW(*ALL) INDENT('.')
     F*
     F*   (2. CREATE THE SERVICE PROGRAM)
     F*   CRTSRVPGM SRVPGM(AIRLIB/SVAIRSAMP) EXPORT(*ALL) ACTGRP(SVAIRSAMP)
     F**********************************************************************
     FSTUDENTS  IF   E           K DISK    usropn
     FGRADES    IF   E           K DISK    usropn
     D*
     DXSTUDENTS      E DS                  EXTNAME(STUDENTS)
     DHSTUDENTS      E DS                  EXTNAME(STUDENTS)
     D                                     PREFIX(H)
     D*
     D/COPY AIRLIB/AIRSRC,SPAIRSAMP
      *-----------------------------------------------------------------
      * Air_openFiles: Opens the files for the specified Member
      *-----------------------------------------------------------------
     P Air_openFiles...
     P                 B                   export
     D Air_openFiles...
     D                 PI             1N
     D  argMember                    10A   const
     D* Local Variables
     D  string         S           1000A
     C*
     C                   EVAL      STRING = 'OVRDBF FILE(STUDENTS)'
     C                                    + ' MBR(' + %trim(argMember)
     C                                    + ')'
     C                   Z-ADD     1000          STRLEN
     C                   CALL      'QCMDEXC'
     C                   PARM                    STRING
     C                   PARM                    STRLEN           15 5
     C*
     C                   EVAL      STRING = 'OVRDBF FILE(GRADES)'
     C                                    + ' MBR(' + %trim(argMember)
     C                                    + ')'
     C                   Z-ADD     1000          STRLEN
     C                   CALL      'QCMDEXC'
     C                   PARM                    STRING
     C                   PARM                    STRLEN           15 5
     C*
     C                   OPEN      STUDENTS                             59
     C  N59              OPEN      GRADES                               59
     c                   RETURN    *IN59
     P                 E
      *-----------------------------------------------------------------
      * Air_closeFiles: Closes the files
      *-----------------------------------------------------------------
     P Air_closeFiles...
     P                 B                   export
     D Air_closeFiles...
     D                 PI             1N
     C                   CLOSE     STUDENTS                             59
     C  N59              CLOSE     GRADES                               59
     c                   RETURN    *IN59
     P                 E
      *-----------------------------------------------------------------
      * Air_getRank: Retrieves the Rank for students in the same major
      *-----------------------------------------------------------------
     P Air_getRank...
     P                 B                   export
     D Air_getRank...
     D                 PI            10I 0
     D   argAccount                   6S 0 const
     D* Local Variables
     D currentTotal    S             10I 0
     D currentCount    S             10I 0
     D score           S              7S 4
     D rankScore       S              7S 4
     D rank            S             10I 0
     C************************************************************************
     C                   EVAL      rank = 0
     C     argAccount    CHAIN     STUDENTS                           69
     C                   EVAL      HSTUDENTS = XSTUDENTS
     C                   DOU       *IN69 = *ON
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
     C                             OR *IN69
     C                   READ      STUDENTS                               69
     C                   ENDDO
     C                   ENDDO
     C                   RETURN    rank
     P                 E
