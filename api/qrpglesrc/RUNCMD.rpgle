      * Refer to: http://www.think400.dk/apier_1.htm#eks0002
      * Use PDM Option 15 to create module with DBGVIEW(*source)
    HH nomain
      ************************************************************************
      * Command execution function                                           *
      ************************************************************************
      * prototype for RunCmd procedure/function
     D RunCmd          PR            10i 0
     D  cmdTxt                         *   value options(*STRING)
     D  cmdErr                         *   value
     D
      * Prototype for QCAPCMD API
     D Qcapcmd         PR                  Extpgm('QCAPCMD')
     D  cTxt                       1000    options(*varsize) const
     D  cLen                         10i 0 const
     D  cCtlBlk                      20    const
     D  cCtlbLen                     10i 0 const
     D  cCtlbName                     8    const
     D  cChgCmd                    1000
     D  cChgCmdAv                    10i 0 const
     D  cChgCmdLen                   10i 0
     D  cErr                        216
     D
      * QCAPCMD structure
      * For clarity I have included this structure in the source
      * member but its probably better to just use /COPY to get it
      * from QSYSINC.
     D*****************************************************************
     DQCAP0100         DS
      *                                             Qca PCMD CPOP0100
     D QCACMDPT                1      4B 0
      *                                             Command Process Type
     D QCABCSDH                5      5
      *                                             DBCS Data Handling
     D QCAPA                   6      6
      *                                             Prompter Action
     D QCACMDSS                7      7
      *                                             Command String Syntax
     D QCAMK                   8     11
      *                                             Message Key
     D QCAERVED               12     20
      *                                             Reserved

     D* set pointer for QUSEC data structure
     D pQusec          S               *
     D
      * QUSEC exception data structure
      *  This structure will need to be placed in the source member
      *   because we need to modify it to be BASED on the pQusec
      *   pointer.
      *  Also, the Qdata field was added to capture the varying
      *   length message data for the exception received (if any).
     DQUSEC            DS                  Based(pQusec)
      *                                             Qus EC
     D QUSBPRV                 1      4B 0
      *                                             Bytes Provided
     D QUSBAVL                 5      8B 0
      *                                             Bytes Available
     D QUSEI                   9     15
      *                                             Exception Id
     D QUSERVED               16     16
      *                                             Reserved
     D*QUSED01                17     17
      *                                             Varying length
     D
     D Qdata                  17    216
      ************************************************************************
      * RunCmd - Command execution procedure/function                        *
      ************************************************************************
     P RunCmd          b                   Export
     D RunCmd          PI            10i 0
     D  cmdTxt                         *   value options(*string)
     D  cmdErr                         *   value
     D
      * API parameter variables
     D ChgCmdStr       S           1000
     D ChgCmdAv        S             10i 0
     D ChgCmdLen       S             10i 0
     D ctlBlkLen       S             10i 0

      * set pQusec to point at the QUSEC struct in the calling program
     C                   Eval      pQusec = cmdErr
      * Set API default values
      *  the values used here are being used to make the QCAPCMD work
      *  in a manner most similar to QCMDEXC.
     C                   Eval      Qcacmdpt = 0
     C                   Eval      Qcabcsdh = '0'
     C                   Eval      Qcapa = '0'
     C                   Eval      Qcacmdss = '0'
     C                   Eval      Qcamk = *blanks
     C                   Eval      Qcaerved = x'000000000000000000'
     C                   Eval      ChgCmdStr = *blanks
     C                   Eval      ChgCmdAv = 1000
     C                   Eval      ChgCmdLen = 0
     C                   Eval      QusbPrv = 216
     C                   Eval      QusbAvl = 0
     C                   Eval      ctlBlkLen = 20
     C
      * execute the command
     C                   Callp     Qcapcmd(%str(cmdTxt):
     C                             %len(%str(cmdTxt)):
     C                             QCAP0100:ctlBlkLen:'CPOP0100':
     C                             ChgCmdStr:
     C                             ChgCmdAv:ChgCmdLen:Qusec)
     C
      * Return 0 if the command executed without errors
     C                   If        QUSBAVL = 0
     C                   Return    0
     C                   Else
     C                   Return    1
     C                   Endif
     P RunCmd          E
