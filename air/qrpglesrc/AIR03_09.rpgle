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
     F*   CRTBNDRPG PGM(AIRLIB/AIR03_09) SRCFILE(AIRLIB/AIRSRC) +
     F*             DFTACTGRP(*NO)
     F*****************************************************************
     D airChar         S              2A
     D airInt          S              5I 0
     D airUnsigned1    S              5U 0
     D airUnsigned2    S              5U 0
     D airResult       S              5U 0
     D airResultBig    S             10U 0
     D displayBytes    S             52A
     C*
      /free
       // All of these variables take two bytes of space.
       airChar = x'FFFF';
       airInt = x'2222';
       // airUnsigned1 and 2 have alternating bits assigned.
       // airUnsigned1 = x'5555' = b'0101 0101 0101 0101'
       // airUnsigned2 = x'AAAA' = b'1010 1010 1010 1010'
       airUnsigned1 = x'5555';
       airUnsigned2 = x'AAAA';
       airResult = %bitAND(airUnsigned1: airUnsigned2);
       // airResult = x'0000' = b'0000 0000 0000 0000'
       airResult = %bitOR(airUnsigned1: airUnsigned2);
       // airResult = x'FFFF' = b'1111 1111 1111 1111'
       airResultBig = %bitXOR(airUnsigned1: airUnsigned2);
       // airResultBig
       //    = x'0000FFFF'
       //    = b'0000 0000 0000 0000 1111 1111 1111 1111'
       airResult = %bitNOT(airUnsigned1);
       // airResult = x'AAAA' = b'1010 1010 1010 1010'
       *inlr = *ON;
      /end-free
