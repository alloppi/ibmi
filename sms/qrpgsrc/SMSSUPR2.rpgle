      *====================================================================*
      * Program name: SMSSUPR2                                             *
      * Purpose.....: IT Support Request - Get Staff Phone No. / Email     *
      *                                                                    *
      * Date written: 2015/07/23                                           *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre   Ver  Mod#  Remarks                     *
      * ---------- ---------- ---  ----- ----- --------------------------- *
      * 2015/07/23 Alan       AC               New Develop                 *
      *====================================================================*
     H Debug(*Yes)
      *
     FSMSSUPFB  IF   E           K Disk
      *
      * Standard D spec.
      /COPY QCPYSRC,PSCY01R
      *
      * Input Parameters
     D P_Staff         S                   Like(SMSSUPBSTF)
     D R_StfName       S                   Like(SMSSUPBNAM)
     D R_StfTel        S                   Like(SMSSUPBTEL)
     D R_StfEmail      S                   Like(SMSSUPBEML)
      *
      * Key fields
     D K_Stf           S                   Like(SMSSUPBSTF)
      *
     C     *Entry        PList
     C                   Parm                    P_Staff
     C                   Parm                    R_StfName
     C                   Parm                    R_StfTel
     C                   Parm                    R_StfEmail
     C                   Parm                    RtnCde
      *
      *====================================================================*
      * Main Logic
      *====================================================================*
      *
      * Initial Reference
     C                   ExSr      @InitRef
      *
      * Get Staff Phone No. / Email
     C                   ExSr      @GetStaff
     C   99              Goto      $XPgm
      *
      * End of Program
     C     $XPgm         Tag
     C                   If        *In99
     C                   Eval      RtnCde = 1
     C                   EndIf
      *
     C                   Eval      *InLr = *On
     C                   Return
      *
      *====================================================================*
      * Get Staff Information
      *====================================================================*
     C     @GetStaff     BegSr
      *
     C                   Eval      K_Stf = P_Staff
     C     K_Stf         Chain     SMSSUPFBR                          99
     C                   If        Not *In99
     C                   Eval      R_StfName  = SMSSUPBNAM
     C                   Eval      R_StfTel   = SMSSUPBTEL
     C                   Eval      R_StfEmail = SMSSUPBEML
     C                   Else
     C     '0001'        Dump
     C                   LeaveSr
     C                   EndIf
      *
     C                   EndSr
      *
      *====================================================================*
      * Initial Reference
      *====================================================================*
     C     @InitRef      BegSr
      *
     C                   Eval      R_StfName  = *Blank
     C                   Eval      R_StfTel   = *Blank
     C                   Eval      R_StfEmail = *Blank
     C                   Eval      RtnCde     = 0
      *
     C                   EndSr
      *
