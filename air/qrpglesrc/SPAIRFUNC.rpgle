      /if not defined(SPAIRFUNC)
     D**********************************************************************
     D* Generic Prototypes and Constants
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
     D* DATA STRUCTURES
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
     D**********************************************************************
     D* Prototype Wrappers for...
     D* APIs
     D**********************************************************************
     D* Prototype for QCMDEXC API
     D ExecuteCommand...
     D                 PR                  extPgm('QCMDEXC')
     D  argInCommand              65535A   const options(*varsize)
     D  argInLength                  15P 5 const
     D**********************************************************************
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
      **********************************************************************
      *  IFS API prototypes
      ******************************************************************
     DIFSOpen          PR            10I 0 extProc('open')
     D argPath                         *   value options(*STRING)
     D argFlag                       10I 0 value
     D argMode                       10U 0 value options(*NOPASS)
     D argToConv                     10U 0 value options(*NOPASS)
     D argFromConv                   10U 0 value options(*NOPASS)
     D*
     DIFSClose         PR            10I 0 extProc('close')
     D argFD                         10I 0 value
     D**********************************************************************
     D* CONSTANTS
     D**********************************************************************
     D CCSID_EBCDIC    C                   CONST(00037)
     D CCSID_ASCII     C                   CONST(00367)
     D CCSID_ISO8859   C                   CONST(00819)
     D CCSID_UTF_8     C                   CONST(01208)
     D*
     D EBCDIC_CR       C                   X'0D'
     D EBCDIC_LF       C                   X'25'
     D EBCDIC_CRLF     C                   X'0D25'
     D**********************************************************************
     D* QSYSINC/H,FCNTL: File System File Control Definitions
     D**********************************************************************
     D O_RDONLY        C                   1
     D O_WRONLY        C                   2
     D O_RDWR          C                   4
     D O_CREAT         C                   8
     D**********************************************************************
     D* QSYSINC/H,UNISTD: File System API Definitions
     D* CONSTANTS: stdin, stdout, and stderr
     D**********************************************************************
     D STDIN_FILENO    C                   0
     D STDOUT_FILENO   C                   1
     D STDERR_FILENO   C                   2
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
      /define SPAIRFUNC
      /endif
