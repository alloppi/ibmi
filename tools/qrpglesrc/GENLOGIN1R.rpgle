      *==============================================================*
      * Program name: GENLOGIN1R                                     *
      * Purpose ....: Generate Remote Login encrypted hash           *
      * Remark......: Using OpenSSL to encrypt plain text            *
      *                                                              *
      * Date written: 2018/03/17                                     *
      *                                                              *
      * Modification:                                                *
      * Date       Name       Pre  Ver  Mod#  Remarks                *
      * ---------- ---------- --- ----- ----- ---------------------- *
      * 2018/03/17 Alan       AC              New Development        *
      *==============================================================*
     H Debug(*Yes)
     H DftActGrp(*No) ActGrp(*Caller) BndDir('QC2LE')

      /copy QCpySrc,IFSIO_H

     DQzshSystemAPI    pr            10I 0 ExtProc('QzshSystem')
     D                                 *   value Options(*String)

      * Entry Parameters
     D P_PlainTxt      s             25a
     D R_EncHex        s             80a
     D R_EncLen        s              2P 0
     D R_RtnCde        s              2P 0
      *
      * Parameters for PSXX0XR
     D I_KeyLabel      s             32A
     D O_Key           s             64A
     D O_IV            s             32A
     D O_RtnCde        s              2P 0
      *
      * Working Variable
     D w1EncHex        s             80a
     D w1EncLen        s              2P 0
      *
      * Constant
     D LF              C                   CONST(x'25')

     D                sds
     D  dsJobNo              264    269A

     D SndUnixErr      pr             1N
     D   peMsgTxt                   256A   const

     D SetupIO         pr            80a
     D ReadIO          pr            80a
     D CloseIO         pr

     D cmd             s            256a
     D RtnCode         s             10I 0
     D msg             s             80a

      * Mainline logic
     C     *Entry        PList
     C                   Parm                    P_PlainTxt
     C                   Parm                    R_EncHex
     C                   Parm                    R_EncLen
     C                   Parm                    R_RtnCde
      *
     c                   eval      R_EncHex = *Blank
     c                   eval      R_EncLen = 0
     c                   eval      R_RtnCde = 0
      *
      * Setup file descriptors 0, 1 & 2 are used by unix-environments for
      *   stdin, stdout & stderr.
     c                   eval      msg = SetupIO
     c                   if        msg <> *blanks
     c                   callp     SndUnixErr(msg)
     c     '0001'        dump
     c                   eval      R_RtnCde = 1
     c                   goto      $ExitPgm
     c                   endif

      * Get key and iv for encryption
     c                   eval      I_KeyLabel = 'INTEGRATION_RMTLOGIN_AS400'
     c                   call      'GENLOGIN2R'
     c                   parm                    I_KeyLabel
     c                   parm                    O_Key
     c                   parm                    O_IV
     c                   parm                    O_RtnCde

     c                   if        O_RtnCde <> 0
     c                   callp     CloseIO
     c                   callp     SndUnixErr('Unable to get the key')
     c     '0002'        dump
     c                   eval      R_RtnCde = 1
     c                   goto      $ExitPgm
     c                   endif

      * Call openssl to perform encryption
      /free
         Cmd = 'echo ''' + %trimr(P_PlainTxt) + '''' +
           ' | openssl enc -aes-256-cbc -K ' + %trimr(O_Key) +
           ' -iv ' + %trimr(O_IV) + ' -base64';
      /end-free

     c                   eval      RtnCode = QzshSystemAPI(%trimr(cmd))
     c                   if        RtnCode <> 0
     c                   callp     CloseIO
     c                   callp     SndUnixErr('Error in Qsh Command: ' +
     c                                          %trim(Cmd))
     c     '0003'        dump
     c                   eval      R_RtnCde = 1
     c                   goto      $ExitPgm
     c                   endif

      * Read encrypted message
     c                   eval      w1EncHex = ReadIO
     c                   if        w1EncHex = 'Unable to read STDOUT'
     c                   callp     CloseIO
     c                   callp     SndUnixErr('Unable to read STDOUT')
     c     '0004'        dump
     c                   eval      R_RtnCde = 1
     c                   goto      $ExitPgm
     c                   else
     c                   eval      w1EncLen = %scan(LF: w1EncHex) - 1
     c                   if        w1EncLen > 0
     c                   eval      R_EncHex = %subst(w1EncHex: 1: w1EncLen)
     c                   eval      R_EncLen = w1EncLen
     c                   else
     c                   callp     CloseIO
     c                   callp     SndUnixErr('Error to read Encrypted Hex')
     c     '0005'        dump
     c                   eval      R_RtnCde = 1
     c                   goto      $ExitPgm
     c                   endif
     c                   endif

      * Close STDOUT, STDERR File
     c                   callp     CloseIO

     c     $ExitPgm      tag
     c                   eval      *InLr = *on

      *==============================================================*
      *  Send program message if error occured
      *==============================================================*
     P SndUnixErr      B                   export
     D SndUnixErr      PI             1N
     D   peMsgTxt                   256A   const

     D SndPgmMsg       PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtalen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                    1A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 inz(256)
     D  dsECBytesA             5      8I 0 inz(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D wwMsglen        S             10I 0
     D wwTheKey        S              4A

     c                   eval      wwMsglen = %len(%trimr(peMsgTxt))
     c                   if        wwMsglen < 1
     c                   return    *off
     c                   endif

     c                   callp     SndPgmMsg('CPF9897': 'QCPFMSG   *LIBL':
     c                               peMsgTxt: wwMsglen: '*DIAG' :
     c                               '*': 3: wwTheKey: dsEC)

     c                   return    *off
     P                 E

      *===============================================================
      * File descriptors 0, 1 & 2 are used by unix-environments for
      *   stdin, stdout & stderr.
      *
      * Here we just direct those 3 descriptors to stream files
      *===============================================================
     P SetupIO         B
     D SetupIO         PI            80A

      ** IFS APIs used for simulating STDIN, STDOUT, STDERR

     D msg             S             80A
     D x               S             10I 0

      * close and delete them if they're open
     c                   for       x = 0 to 2
     c                   callp     close(x)
     c                   endfor

     c                   callp     unlink('/RmtLogin/response/stdout-' + dsJobNo)
     c                   callp     unlink('/RmtLogin/response/stderr-' + dsJobNo)

     c                   eval      msg = *blanks

      * open up 0, 1, 2 as files with mode flag = 384 (Owner can Read or Write only)
     c                   if        open('/dev/qsh-stdin-null': O_RDONLY) <> 0
     c                   eval      msg = 'Unable to open STDIN'
     c                   endif

     c                   if        open('/RmtLogin/response/stdout-' + dsJobNo:
     c                                   O_WRONLY+O_CREAT+O_TRUNC: 384) <> 1
     c                   eval      msg = 'Unable to open STDOUT'
     c                   endif

     c                   if        open('/RmtLogin/response/stderr-' + dsJobNo:
     c                                   O_WRONLY+O_CREAT+O_TRUNC: 384) <> 2
     c                   eval      msg = 'Unable to open STDERR'
     c                   endif

      * if error to open files
     c                   if        msg <> *blanks
     c                   for       x = 0 to 2
     c                   callp     close(x)
     c                   endfor
     c                   endif

     c                   return    msg
     P                 E

      *===============================================================
      * File descriptors 0, 1 & 2 are used by unix-environments for
      *   stdin, stdout & stderr.
      *
      * Here we just direct those 3 descriptors to stream files
      *===============================================================
     P CloseIO         B
     D CloseIO         PI

     D x               S             10I 0

      * close and delete them
     c                   for       x = 0 to 2
     c                   callp     close(x)
     c                   endfor

     c                   callp     unlink('/RmtLogin/response/stdout-' + dsJobNo)
     c                   callp     unlink('/RmtLogin/response/stderr-' + dsJobNo)
     P                 E

      *===============================================================
      * File descriptors 0, 1 & 2 are used by unix-environments for
      *   stdin, stdout & stderr.
      *
      * Here we just direct those 3 descriptors to stream files
      *===============================================================
     P ReadIO          B
     D ReadIO          PI            80A

     D fd              S             10I 0
     D rddata          S             80A
     D len             S             10I 0

     c                   eval      fd = open('/RmtLogin/response/stdout-'+ dsJobNo
     c                                   : O_RDONLY)

     c                   eval      len = read(fd: %addr(rddata):
     c                                            %size(rddata))
     c                   if        len < 1
     c                   return    'Unable to read STDOUT'
     c                   else
     c                   return    rddata
     c                   endif

     P                 E
      *---------------------------------------------------------
