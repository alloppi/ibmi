      *====================================================================*
      * Program name: SMSSUPR1                                             *
      * Purpose.....: IT Support Request - Get Supporting Staff            *
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
     FSMSSUPFB01IF   E           K Disk
      *
      * Standard D spec.
      /COPY QCPYSRC,PSCY01R
      *
      * Input Parameters
     D P_Party         S              7A
     D P_JobDate       S               D
     D P_NoOfSnd       S              2P 0
     D R_RtnCde        S                   Like(RtnCde)
     D R_SupStaff      S                   Like(SMSSUPBSTF)
     D R_SupStfNam     S                   Like(SMSSUPBNAM)
      *
      * Work fields
     D W1NoOfSnd       S              2P 0
     D W2NoOfSnd       S              2P 0
     D W1Pty           S                   Like(SMSSUPBPTY)
     D W1Grp           S                   Like(SMSSUPBGRP)
     D W1Pri           S                   Like(SMSSUPBPRI)
     D W1Mth           S              2P 0
     D W1MthDiv        S              1P 0
     D W1MthRem        S              1P 0
     D W1SndRem        S              1P 0
      *
      * Key fields
     D K_Pty           S                   Like(SMSSUPBPTY)
     D K_Grp           S                   Like(SMSSUPBGRP)
     D K_Pri           S                   Like(SMSSUPBPRI)
      *
     C     *Entry        PList
     C                   Parm                    P_Party
     C                   Parm                    P_JobDate
     C                   Parm                    P_NoOfSnd
     C                   Parm                    R_RtnCde
     C                   Parm                    R_SupStaff
     C                   Parm                    R_SupStfNam
      *
      *====================================================================*
      * Main Logic
      *====================================================================*
      *
      * Initial Reference
     C                   ExSr      @InitRef
     C   99              Goto      $XPgm
      *
      * Setting Working Variable for Selecting Staff from Group
     C                   ExSr      @SetSltStf
      *
      * Get Supporting Staff Information
     C                   ExSr      @GetSupStf
      *
      * End of Program
     C     $XPgm         Tag
     C                   If        *In99
     C                   Eval      R_RtnCde = 1
     C                   EndIf
      *
     C                   Eval      *InLr = *On
     C                   Return
      *
      *====================================================================*
      * Setting Working Variable for Selecting Staff from Group
      *====================================================================*
     C     @SetSltStf    BegSr
      *
     C                   Eval      W1Pty = P_Party
      *
     C                   Eval      W1Mth    = %SubDt(P_JobDate:*Months)
     C                   Eval      W1MthDiv = %Div(W1Mth: 2)
     C                   Eval      W1MthRem = %Rem(W1Mth: 2)
     C                   If        W1MthRem <> 0
     C                   Eval      W1MthDiv = W1MthDiv + 1
     C                   EndIf
      *
     C                   Eval      W2NoOfSnd = %Rem(W1NoOfSnd: 12)
     C                   If        W2NoOfSnd = 0
     C                   Eval      W2NoOfSnd = 12
     C                   EndIf
     C                   Eval      W1SndRem  = %Rem(W2NoOfSnd: 2)
      *
      * Determine the First supporting Staff
      *   - For Odd  Month, Use Group A Staff,
      *   - For Even Month, Use Group B Staff
     C                   If        W1MthRem = 1
     C                   Eval      W1Grp = 'A'
     C                   Else
     C                   Eval      W1Grp = 'B'
     C                   EndIf
      *
      *   - For  the First 2 Months (i.e. Jan, Feb), Use Priority 1 Staff
      *   - For  the Next  2 Months (i.e. Mar, Apr), Use Priority 2 Staff
      *   - From the above Months pattern, Select Priority 1 or 2 Staff
     C                   If        W1MthDiv = 1
     C                             or W1MthDiv = 3
     C                             or W1MthDiv = 5
     C                   Eval      W1Pri = '1'
     C                   Else
     C                   Eval      W1Pri = '2'
     C                   EndIf
      *
      * Determine Supporting Staff Alternatively
      *   acccording to No. of request
     C                   If        W2NoOfSnd > 6
     C                   If        W1Grp = 'A'
     C                   Eval      W1Grp = 'B'
     C                   Else
     C                   Eval      W1Grp = 'A'
     C                   EndIf
     C                   EndIf
      *
     C                   If        W1SndRem = 0
     C                   If        W1Pri = '1'
     C                   Eval      W1Pri = '2'
     C                   Else
     C                   Eval      W1Pri = '1'
     C                   EndIf
     C                   EndIf
      *
     C                   EndSr
      *
      *====================================================================*
      * Get Supporting Staff Information
      *====================================================================*
     C     @GetSupStf    BegSr
      *
     C     K_48FB01      KList
     C                   KFld                    K_Pty
     C                   KFld                    K_Grp
     C                   KFld                    K_Pri
      *
     C                   Eval      K_Pty = W1Pty
     C                   Eval      K_Grp = W1Grp
     C                   Eval      K_Pri = W1Pri
     C     K_48FB01      Chain     SMSSUPFBR                          96
      *
      * If Staff cannot found, take the First Staff in File
     C                   If        *In96
     C     K_Pty         SetLL     SMSSUPFBR
     C                   Read      SMSSUPFBR                              96
     C                   EndIf
      *
     C                   If        Not *In96
     C                   Eval      R_SupStaff  = SMSSUPBSTF
     C                   Eval      R_SupStfNam = SMSSUPBNAM
     C                   Else
     C                   Eval      *In99 = *On
     C     '0010'        Dump
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
     C                   Eval      R_SupStaff  = *Blank
     C                   Eval      R_SupStfNam = *Blank
     C                   Eval      R_RtnCde    = 0
      *
      * Testing for Date Format
     C                   Test                    P_JobDate              99
     C                   If        *In99 or
     C                             P_JobDate = ISOZeroDate
     C                   Eval      R_RtnCde = 1
     C     '0001'        Dump
     C                   LeaveSr
     C                   EndIf
      *
      * Set Default, No. of Sending Times = 1
     C                   If        P_NoOfSnd >= 1
     C                   Eval      W1NoOfSnd = P_NoOfSnd
     C                   Else
     C                   Eval      W1NoOfSnd = 1
     C                   EndIf
      *
     C                   EndSr
      *
