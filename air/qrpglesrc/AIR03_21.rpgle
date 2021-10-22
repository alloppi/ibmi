     F**********************************************************************
     F*  How to Compile:
     F*
     F*   (1. CREATE THE MODULE)
     F*   CRTBNDRPG PGM(AIRLIB/AIR03_21) SRCFILE(AIRLIB/AIRSRC) +
     F*             DFTACTGRP(*NO)
     D**********************************************************************
     D CCSID_EBCDIC    C                   CONST(00037)
     D CCSID_ASCII     C                   CONST(00367)
     D CCSID_ISO8859   C                   CONST(00819)
     D CCSID_UTF_8     C                   CONST(01208)
     D**********************************************************************
     Diconv_t          DS
     D ICORV                   1      4B 0
     D ICOC                    5     52B 0 DIM(00012)
     D**********************************************************************
     DQtqCode_t        DS
     D QTQCCSID                1      4B 0
     D QTQCA                   5      8B 0
     D QTQSA                   9     12B 0
     D QTQSA00                13     16B 0
     D QTQLO                  17     20B 0
     D QTQMEO                 21     24B 0
     D QTQERVED02             25     32
     D********************************************************************
     D* Open the Conversion Descriptor
     D QtqIconvOpen    PR                  ExtProc('QtqIconvOpen')
     D                                     like(iconv_t)
     D  argToCCSID                         like(QtqCode_t) const
     D  argFromCCSID                       like(QtqCode_t) const
     D* Convert CCSID from Input Buffer to Output Buffer
     D Iconv           PR                  ExtProc('iconv')
     D  argConvDesc                        like(iconv_t) value
     D  argInBuffer                    *
     D  argInBytes                   10I 0
     D  argOutBuffer                   *
     D  argOutBytes                  10I 0
     D* Close the Conversion Descriptor
     D Iconv_close     PR            10I 0 ExtProc('iconv_close')
     D  argConvDesc                        like(iconv_t) VALUE
     D* Custom Procedure to simplify Iconv_open
     D Air_openConverter...
     D                 PR                  likeDs(iconv_t)
     D   argToCCSID                  10I 0
     D   argFromCCSID                10I 0 options(*nopass)
     D* Custom Procedure to simplify Iconv
     D Air_convert...
     D                 PR         65535A   varying
     D   argCd                             likeDs(iconv_t)
     D   argInString              65535A   const varying
     D* Custom Procedure to simplify Iconv_close
     D Air_closeConverter...
     D                 PR
     D   argCd                             likeDs(iconv_t)
     D********************************************************************
     D to              DS                  likeDs(QtqCode_t)
     D from            DS                  likeDs(QtqCode_t)
     D cd              DS                  likeDs(iconv_t)
     D ebcdicString    S             10A   varying
     D asciiString     S             10A   varying
     D toCCSID         S             10I 0
     D**********************************************************************
      /free
        toCCSID = 1208;
        ebcdicString = '@AS/400@';
        cd = Air_openConverter(toCCSID);
        asciiString = Air_convert(cd: ebcdicString);
        Air_closeConverter(cd);
        *inLr = *ON;
      /end-free
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
