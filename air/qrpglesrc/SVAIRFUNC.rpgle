     H NOMAIN THREAD(*SERIALIZE) OPTION(*NODEBUGIO: *SRCSTMT: *SHOWCPY)
     D**********************************************************************
     D* Generic Procedures
     D**********************************************************************
     D* ====================================================================
     D* ============== Advanced Integrated RPG by Tom Snyder ===============
     D* ====================================================================
     D* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     D* All rights reserved.
     D*
     D* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     D* Author URL:    http://www.2WolvesOut.com
     D*
     D* Source code/material located at http://www.mc-store.com/5105.html
     D* On the books page, click the reviews, errata, downloads icon to go
     D* to the books forum.  This source code may not be hosted on any
     D* other site without my express, prior, written permission.
     D*
     D* I disclaim any and all responsibility for any loss, damage or
     D* destruction of data or any other property which may arise using
     D* this code. I will in no case be liable for any monetary damages
     D* arising from such loss, damage or destruction.
     D*
     D* This code is intended for educational purposes, which includes
     D* minimal exception handling to focus on the topic being discussed.
     D* You may want to implement additional exception handling to prepare
     D* for a production environment.
     D*
     D* Happy Coding!
     D**********************************************************************
     D*   HOW TO COMPILE:
     D*
     D*   (1. CREATE THE MODULE)
     D*   CRTRPGMOD MODULE(YourLib/SVAIRFUNC) SRCFILE(YourLib/AIRSRC) +
     D*             DBGVIEW(*ALL) INDENT('.')
     D*
     D*   (2. CREATE THE SERVICE PROGRAM)
     D*   CRTSRVPGM SRVPGM(YourLib/SVAIRFUNC) EXPORT(*ALL) ACTGRP(SVAIRFUNC)
     D**********************************************************************
     D*** PROTOTYPES ***
     D/COPY AIRSRC,SPAIRFUNC
      *-----------------------------------------------------------------
      * Air_openConverter: Opens the Conversion Descriptor for iconv
      *-----------------------------------------------------------------
     P Air_openConverter...
     P                 B                   export
     D Air_openConverter...
     D                 PI                  likeDs(iconv_t)
     D   argToCCSID                  10I 0
     D   argFromCCSID                10I 0 options(*nopass)
     D* Local Variables
     D from            DS                  likeDs(QtqCode_t)
     D to              DS                  likeDs(QtqCode_t)
     D cd              DS                  likeDs(iconv_t)
     D********************************************************************
      /free
        // Set the target CCSID
        to = *ALLx'00';
        to.QTQCCSID = argToCCSID;
        to.QTQSA00 = 1;
        // If Specified, Set the From CCSID
        from = *ALLx'00';
        if %PARMS < 2;
          from.QTQCCSID = 0;
        else;
          from.QTQCCSID = argFromCCSID;
        endif;
        from.QTQSA00 = 1;
        // If Specified, Set the From CCSID
        cd = QtqIconvOpen(to: from);
        if (cd.ICORV < *zeros);
          // FAILURE
        else;
          // SUCCESS
        endif;
        return cd;
      /end-free
     P                 E
      *-----------------------------------------------------------------
      * Air_convert: Converts the CCSIDs of Conversion Descriptor
      *-----------------------------------------------------------------
     P Air_convert...
     P                 B                   EXPORT
     D Air_convert...
     D                 PI         65535A   varying
     D   argCd                             likeDs(iconv_t)
     D   argInString              65535A   const varying
     D********************************************************************
     D inBuf           S          65535A
     D inBufPtr        S               *
     D inBufBytes      S             10I 0
     D outBuf          S          65535A
     D outBufPtr       S               *
     D outBufBytes     S             10I 0
     D bytesIn         S             10I 0
     D bytesOut        S             10I 0
     D outReturn       S          65535A   varying
     D********************************************************************
      /free
        inBuf = argInString;
        inBufPtr = %addr(inBuf);
        // Set to Hex Zeros or will initialize to Ebcdic Spaces
        outBuf = *ALLx'00';
        outBufPtr = %addr(outBuf);
        // Do not trimr, use Varying and %len()
        inBufBytes = %len(argInString);
        outBufBytes = %size(outBuf);
        bytesIn = outBufBytes;
        iconv(argCd: inBufPtr: inBufBytes:
                    outBufPtr: outBufBytes);
        bytesOut = bytesIn - outBufBytes;
        outReturn = %subst(outBuf:1:bytesOut);
        return outReturn;
      /end-free
     P                 E
      *-----------------------------------------------------------------
      * Air_closeConverter: Closes the Conversion Descriptor
      *-----------------------------------------------------------------
     P Air_closeConverter...
     P                 B                   EXPORT
     D Air_closeConverter...
     D                 PI
     D   argCd                             likeDs(iconv_t)
     D********************************************************************
      /free
        iconv_close(argCd);
      /end-free
     P                 E
