      *========================================================================*
      * Program name: CALLQSHR                                                 *
      * Purpose ....: Call QSH Command and return result in STDOUT, STDERR     *
      *                                                                        *
      * Date written: 2020/11/26                                               *
      *                                                                        *
      * Modification:                                                          *
      * Date       Name       Pre  Ver  Mod#  Remarks                          *
      * ---------- ---------- --- ----- ----- -------------------------------- *
      * 2020/11/26 Alan       AC              New Development                  *
      *========================================================================*
     h Debug(*Yes)
     h DftActGrp(*No) BndDir('QC2LE')

      /copy QCpySrc,PSCY01R
      /copy QCpySrc,IFSIO_H

     dQzshSystemAPI    pr            10I 0 ExtProc('QzshSystem')
     d                                 *   value Options(*String)

      * Entry Parameters
     d P_QshCmd        s            512a
     d R_StdOut        s            512a
     d R_StdErr        s            512a
     d R_RtnCde        s                   Like(RtnCde)

     d STDOUTCrtErr    c                   'Unable to create STDOUT'
     d STDOUTOpnErr    c                   'Unable to read STDOUT'
     d STDERRCrtErr    c                   'Unable to create STDERR'
     d STDERROpnErr    c                   'Unable to read STDERR'

      * working variable
     d w1StdOut        s                   Like(R_StdOut)
     d w1StdErr        s                   Like(R_StdErr)
     d w1TimStpF       s             20A
     d w1CurTimStp     s               Z

     d SndUnixErr      pr             1N
     d   peMsgTxt                   512A   const

     d SetupIO         pr            80a
     d ReadStdOut      pr           512a
     d ReadStdErr      pr           512a
     d CloseIO         pr

     d rtnCode         s             10I 0
     d msg             s             80a
     d StdInFile       s             50a   varying
     d StdOutFile      s             50a   varying
     d StdErrFile      s             50a   varying

      *==============================================================*
      * Mainline Logic
      *==============================================================*
     c     *entry        plist
     c                   parm                    P_QshCmd
     c                   parm                    R_StdOut
     c                   parm                    R_StdErr
     c                   parm                    R_RtnCde

      * Setup file descriptors 0, 1 & 2 are used by unix-environments for
      *   stdin, stdout & stderr.
      * Error message can be found in msg
     c                   eval      msg = SetupIO
     c                   if        msg <> *blanks
     c     '0001'        dump
     c                   eval      R_RtnCde = 1
     c                   callp     SndUnixErr(msg)
     c                   goto      $ExitPgm
     c                   endif

      * Call qsh Command and capture stdin, stdout & stderr.
     c                   eval      rtnCode = QzshSystemAPI(%trimr(P_QshCmd))
     c                   if        rtnCode <> 0
     c                   callp     CloseIO
     c     '0002'        dump
     c                   eval      R_RtnCde = 2
     c                   callp     SndUnixErr('Error in Qsh Command: ' +
     c                                         %trimr(P_QshCmd))
     c                   goto      $ExitPgm
     c                   endif

      * Read STDOUT content
      * Error message can be found in w1StdOut
     c                   eval      w1StdOut = ReadStdOut
     c                   if        w1StdOut = STDOUTOpnErr
     c                   callp     CloseIO
     c     '0003'        dump
     c                   eval      R_RtnCde = 3
     c                   callp     SndUnixErr(w1StdOut)
     c                   goto      $ExitPgm
     c                   endif

      * Read STDERR content
      * Error message can be found in w1StdErr
     c                   eval      w1StdErr = ReadStdErr
     c                   if        w1StdErr = STDERROpnErr
     c                   callp     CloseIO
     c     '0004'        dump
     c                   eval      R_RtnCde = 4
     c                   callp     SndUnixErr(w1StdErr)
     c                   goto      $ExitPgm
     c                   endif

      * Close STDOUT, STDERR File if no error
     c                   callp     CloseIO

      * Return STDOUT, STDERR content
     c                   eval      R_StdOut = w1StdOut
     c                   eval      R_StdErr = w1StdErr

     c     $ExitPgm      tag
     c                   eval      *InLr = *on

      *==============================================================*
      * *InzSr
      *==============================================================*
     c     *InzSr        begsr

      * Set unique file name with timestamp + job no. for STDOUT and STDERR
     c/EXEC SQL
     c+ SET :w1CurTimStp = CURRENT_TIMESTAMP
     c/END-EXEC

     c                   Eval      w1TimStpF  = %char(w1CurTimStp:*ISO0)
     c                   Eval      StdInFile  = '/dev/qsh-stdin-null'
     c                   Eval      StdOutFile = '/tmp/stdout'+ %char(w1TimStpF)
     c                                        + %char(JOBNBR)
     c                   Eval      StdErrFile = '/tmp/stderr'+ %char(w1TimStpF)
     c                                        + %char(JOBNBR)

     c                   eval      R_RtnCde = 0
     c                   eval      R_StdOut = *Blank
     c                   eval      R_StdErr = *Blank

     c                   endsr

      *==============================================================*
      *  Send Program message if error occured
      *==============================================================*
     p SndUnixErr      b                   export
     d SndUnixErr      pi             1N
     d   peMsgTxt                   512A   const

     d SndPgmMsg       pr                  ExtPgm('QMHSNDPM')
     d   MessageID                    7A   Const
     d   QualMsgF                    20A   Const
     d   MsgData                    512A   Const
     d   MsgDtalen                   10I 0 Const
     d   MsgType                     10A   Const
     d   CallStkEnt                  10A   Const
     d   CallStkCnt                  10I 0 Const
     d   MessageKey                   4A
     d   ErrorCode                    1A

     d dsEC            ds
     d  dsECBytesP             1      4I 0 inz(512)
     d  dsECBytesA             5      8I 0 inz(0)
     d  dsECMsgID              9     15
     d  dsECReserv            16     16
     d  dsECMsgDta            17    512

     d wwMsglen        s             10I 0
     d wwTheKey        s              4A

     c                   eval      wwMsglen = %len(%trimr(peMsgTxt))
     c                   if        wwMsglen < 1
     c                   return    *off
     c                   endif

     c                   callp     SndPgmMsg('CPF9897': 'QCPFMSG   *LIBL':
     c                               peMsgTxt: wwMsglen: '*ESCAPE':
     c                               '*': 3: wwTheKey: dsEC)

     c                   return    *off
     p                 e

      *===============================================================
      * File descriptors 0, 1 & 2 are used by unix-environments for
      *   stdin, stdout & stderr.
      *
      * Here we just direct those 3 descriptors to stream files
      *===============================================================
     p SetupIO         b
     d SetupIO         pi            80A

      ** IFS APIs used for simulating STDIN, STDOUT, STDERR

     d msg             s             80A
     d x               s             10I 0

      * close and delete them if they're open
     c                   callp     CloseIO

     c                   eval      msg = *blanks

      * open up 0, 1, 2 as files with mode flag = 384 (Owner can Read or Write only)
     c                   if        open( StdInFile: O_RDONLY ) <> 0
     c                   eval      msg = 'Unable to create STDIN'
     c                   endif

     c                   if        open( StdOutFile:
     c                                   O_WRONLY+O_CREAT+O_TRUNC: 511 ) > 1
     c                   eval      msg = STDOUTCrtErr
     c                   endif

     c                   if        open( StdErrFile:
     c                                   O_WRONLY+O_CREAT+O_TRUNC: 511 ) > 2
     c                   eval      msg = STDERRCrtErr
     c                   endif

      * if error to open above files
     c                   if        msg <> *blanks
     c                   for       x = 0 to 2
     c                   callp     close(x)
     c                   endfor
     c                   endif

     c                   return    msg
     p                 e

      *===============================================================
      * Close and Delete STDOUT, STDERR stream files
      *===============================================================
     p CloseIO         b
     d CloseIO         pi

     d x               s             10I 0

      * close and delete them
     c                   for       x = 0 to 2
     c                   callp     close(x)
     c                   endfor

     c                   callp     unlink( StdOutFile )
     c                   callp     unlink( StdErrFile )
     p                 e

      *===============================================================
      * Read content in STDOUT stream file
      *===============================================================
     p ReadStdOut      b
     d ReadStdOut      pi           512A

     d fd              s             10I 0
     d rddata          s            512A
     d len             s             10I 0

     c                   eval      fd = open( StdOutFile: O_RDONLY )
     c                   if        fd < 0
     c                   return    STDOUTOpnErr
     c                   endif

     c                   eval      len = read( fd: %addr( rddata ):
     c                                             %size( rddata ))
     c                   if        len < 1
     c                   return    *Blank
     c                   else
     c                   return    rddata
     c                   endif

     p                 e
      *===============================================================
      * Read content in STDERR stream file
      *===============================================================
     p ReadStdErr      b
     d ReadStdErr      pi           512A

     d fd              s             10I 0
     d rddata          s            512A
     d len             s             10I 0

     c                   eval      fd = open( StdErrFile: O_RDONLY )
     c                   if        fd < 0
     c                   return    STDERROpnErr
     c                   endif

     c                   eval      len = read( fd: %addr( rddata ):
     c                                             %size( rddata ))

      * if STDERR contains text means error occured
     c                   if        len < 1
     c                   return    *Blank
     c                   else
     c                   return    rddata
     c                   endif

     p                 e
      *---------------------------------------------------------
