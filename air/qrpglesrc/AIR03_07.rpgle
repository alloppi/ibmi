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
     F*   CRTBNDRPG PGM(AIRLIB/AIR03_07) SRCFILE(AIRLIB/AIRSRC) +
     F*             DFTACTGRP(*NO)
     F*****************************************************************
     D inputBytes      S             42A
     D subBytes        S             10A
     D numberBytes     S             10A
     D junkInBytes     S             10A
     D junkOutBytes    S             10A
     D displayBytes    S             52A
     D posi            S             10I 0
     D*   XLATE STRUCTURE FOR LOWER TO UPPER CASE CONVERSION + X'3A' FOR E'*
     D lc              S             27A                                        LOWER CASE
     D uc              S             27A                                        UPPER CASE
     C*
      /free
       // Lower Case and Upper Case Characters
       lc = 'abcdefghijklmnopqrstuvwxyz';
       uc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
       // ALSO include conversion of Acute Accent "E'" to "E" in Cafe' ***
       lc = %TRIM(LC) + X'3A';
       uc = %TRIM(UC) + 'E';
       junkInBytes = ':"''-,';
       junkOutBytes = '     ';
       numberBytes = '1234567890';
       inputBytes = '   621 '
                  + 'Caf' + X'3A'
                  + ', "Air" ''Book'':'
                  + ' 1114-0812    ';
       displayBytes = '[' + inputBytes + ']';
       DSPLY displayBytes;
       // trim
       displayBytes = '%trim['
                    + %trim(inputBytes)
                    + ']';
       DSPLY displayBytes;
       // trimR
       displayBytes = '%trimR['
                    + %trimR(inputBytes)
                    + ']';
       DSPLY displayBytes;
       // trimL
       displayBytes = '%trimL['
                    + %trimL(inputBytes)
                    + ']';
       DSPLY displayBytes;
       // Using Check to get the Front Number.
       posi = %check(numberBytes:%trimL(inputBytes));
       subBytes = %subst(%trimL(inputBytes):1:posi);
       displayBytes = 'Front # ['
                    + %trim(subBytes)
                    + ']';
       DSPLY displayBytes;
       // Using CheckR to get the Back Number.
       posi = %checkR(numberBytes:%trimR(inputBytes));
       subBytes = %subst(%trimR(inputBytes):posi+1);
       displayBytes = 'Back # ['
                    + %trim(subBytes)
                    + ']';
       DSPLY displayBytes;
       // XLATE to UPPER Case
       displayBytes = 'lc->UC['
                    + %xlate(lc:uc:inputBytes)
                    + ']';
       DSPLY displayBytes;
       // Strip the Junk
       displayBytes = 'junk['
                    + %xlate(junkInBytes:junkOutBytes:inputBytes)
                    + ']';
       DSPLY displayBytes;
       // All Cleaned Up
       displayBytes = 'clean['
                    + %trim(%xlate(lc:uc:
                      %xlate(junkInBytes:junkOutBytes:inputBytes)))
                    + ']';
       DSPLY displayBytes;
       *inlr = *ON;
      /end-free
