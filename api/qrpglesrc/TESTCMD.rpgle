      * Refer to http://www.think400.dk/apier_1.htm#eks0002
      * Use PDM Option 15 to create module with DBGVIEW(*source)
      * CRTPGM PGM(*curlib/TESTCMD) MODULE(TESTCMD RUNCMD)

      * prototype for RunCmd procedure/function
     D RunCmd          PR            10i 0 Extproc('RUNCMD')
     D  cmdTxt                         *   value options(*string)
     D  cmdErr                         *   value

      * set pointer for QUSEC data structure
     D pQusec          S               *
     D
      * Data structure used for APIs (can be copied from
      *  QSYSINC/QRPGLESRC,QUSEC) The structure here has been
      *  modified from the one in QSYSINC to include the
      *  "variable" length data field Qdata.
     DQUSEC            DS
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
     D Qdata                  17    216
     D
      * pass in a single CL command up to 50 characters
     C     *entry        Plist
     C                   Parm                    Cmd              50
     C
      * add x'00' (NULL terminator) to string passed to pgm.
     C                   Eval      cmd = %trim(cmd) + x'00'
     C
     C                   callp     RunCmd(%addr(cmd):
     C                             %addr(Qusec))
     C
     C                   Eval      *inlr = *on
     C                   Return
