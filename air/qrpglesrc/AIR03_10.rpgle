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
     F*   CRTBNDRPG PGM(AIRLIB/AIR03_10) SRCFILE(AIRLIB/AIRSRC) +
     F*             DFTACTGRP(*NO)
     F*****************************************************************
     D/COPY AIRLIB/AIRSRC,SPAIRFUNC
     D Air_quantify    PR            10I 0
     D  arg1                         10A   const varying options(*varsize)
     D  arg2                         10A   const varying options(*varsize)
     D  argEOL                       10A   const varying
     D                                     options(*nopass: *omit: *varsize)
     D  argBold                       1N   options(*nopass: *omit)
     D*
     D airResult       S             10I 0
     D airBold         S              1N
     D displayBytes    S             52A
     C*
      /free
       // All of these variables take two bytes of space.
       airBold = *ON;
       displayBytes = 'Result Size:';
       airResult = Air_quantify('Bold ': 'Line':*OMIT: airBold);
       displayBytes = %trim(displayBytes) + ' '
                    + %trim(%editc(airResult:'Z'));
       DSPLY displayBytes;
       *inlr = *ON;
      /end-free
     P Air_quantify    B                   EXPORT
      *
     D Air_quantify    PI            10I 0
     D  arg1                         10A   const varying options(*varsize)
     D  arg2                         10A   const varying options(*varsize)
     D  argEOL                       10A   const varying
     D                                     options(*nopass: *OMIT: *varsize)
     D  argBold                       1N   options(*nopass: *OMIT)
      * LOCAL VARIABLES *
     D displayBytes    S             52A
     D svReturn        S             10I 0
     D svBold          S              1N
     D svEOL           S             10A
     D svArray         S             10A   DIM(20)
     D svOccur         S             25A   DIM(35)
      /free
       svReturn = *ZEROS;
       displayBytes = 'array [size] '
                    + %trim(%editc(%size(svArray):'Z'))
                    + ' [elem] '
                    + %trim(%editc(%elem(svArray):'Z'));
       DSPLY displayBytes;
       displayBytes = 'occur [size] '
                    + %trim(%editc(%size(svOccur):'Z'))
                    + ' [elem] '
                    + %trim(%editc(%elem(svOccur):'Z'));
       DSPLY displayBytes;
       displayBytes = 'len[1] ' + %trim(%editc(%len(arg1):'Z'))
                    + ' len[2] ' + %trim(%editc(%len(arg2):'Z'));
       DSPLY displayBytes;
       displayBytes = 'size[1] ' + %trim(%editc(%size(arg1):'Z'))
                    + ' size[2] ' + %trim(%editc(%size(arg2):'Z'));
       DSPLY displayBytes;
       svEOL = EBCDIC_CR + EBCDIC_LF;
       if %parms > 2;
         if %addr(argEOL) <> *NULL;
           eval svEOL = argEOL;
         else;
         endif;
       else;
       endif;
       displayBytes = 'argEol size: ' + %trim(%editc(%size(svEOL):'Z'))
                    + ' length: ' + %trim(%editc(%len(svEOL):'Z'));
       DSPLY displayBytes;
       displayBytes = 'Required: '
                    + arg1 + arg2
                         + svEOL;
       DSPLY displayBytes;
       svBold = *OFF;
       if %parms > 3;
         if %addr(argBold) <> *NULL;
           svBold = argBold;
         else;
         endif;
       else;
       endif;
       if svBold;
         eval displayBytes = '<b>'
                           + %trim(displayBytes)
                           + '</b>';
       else;
       endif;
       DSPLY displayBytes;
       svReturn = %len(%trim(displayBytes));
       return svReturn;
      /end-free
     C*
     P                 E
