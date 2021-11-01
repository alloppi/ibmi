      *====================================================================*
      * Program name: CHGSPLFR                                             *
      * Purpose.....: Change Spool File Content                            *
      *               Staff Number Setting for Output                      *
      *                                                                    *
      * Date written: 2010/04/12                                           *
      *                                                                    *
      * Reference   : Refer to Printing VI Redbook,                        *
      *               FCFC Character Definition:                           *
      *                 ' ' : one line space                               *
      *                 '+' : no space                                     *
      *                 '0' : two spaces                                   *
      *                 '-' : three spaces                                 *
      *                 '1' : new page                                     *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- ---------------------------- *
      * 2010/04/12 Alan       AC              New develop                  *
      *====================================================================*
     HDEBUG(*YES)
     FCHGSPLFF  UF   E             Disk
      *
      /Copy Qcpysrc,PSCY01R
      *
     DI_LocX           S              3P 0                                        X - Starting Pos.
     DI_LocY           S              2P 0                                        Y - Starting Pos.
      *
     DH1SN             S              4A
     DW1Lin#           S              2P 0
     DW1UpdFlg         S               N
      *
     DFCFC             S              1A
      *
     C     *Entry        Plist
     C                   Parm                    I_LocX
     C                   Parm                    I_LocY
     C                   Parm                    RtnCde
      *
     C                   ExSr      @InitRef
     C   99              Goto      $EndMain
      *
     C                   ExSr      @MainSr
     C   99              Goto      $EndMain
      *
      * End of Program
     C     $EndMain      Tag
     C                   Eval      *InLr = *On
     C                   Return
      *
      *====================================================================*
      * Main Subroutine                                                    *
      *====================================================================*
      *
     C     @MainSr       BegSr
     C                   Read      CHGSPLFFR                              96
     C                   DoW       Not (*In96)
      *
     C                   Eval      FCFC = %SubSt(SPLLIN:1:1)
      *
     C                   Select
     C                   When      FCFC = '1'
     C                   Eval      W1Lin# = 1
     C                   When      FCFC = ' '
     C                   Eval      W1Lin# = W1Lin# + 1
     C                   When      FCFC = '0'
     C                   Eval      W1Lin# = W1Lin# + 2
     C                   When      FCFC = '-'
     C                   Eval      W1Lin# = W1Lin# + 3
     C                   EndSl
      *
     C                   If        W1Lin# = I_LocY
     C                   Eval      W1UpdFlg = *On
      *
     C                   If        I_LocX = %Len(SPLLIN) - %Len(H1SN)
     C                   Eval      SPLLIN =
     C                             %SubSt(SPLLIN: 1: I_LocX) + H1SN
     C                   Else
     C                   Eval      SPLLIN =
     C                             %SubSt(SPLLIN: 1: I_LocX) + H1SN +
     C                             %SubSt(SPLLIN:
     C                                    I_LocX+%Len(H1SN)+1:
     C                                    %Len(SPLLIN)-I_LocX-%Len(H1SN))
     C                   EndIf
      *
     C                   UpDate    CHGSPLFFR                            99
     C                   If        *In99
     C                   Eval      RtnCde = 1
     C     '0001'        Dump
     C                   GoTo      $XMainSr
     C                   EndIf
      *
     C                   EndIf
      *
     C                   Read      CHGSPLFFR                              96
     C                   EndDo
      *
     C                   If        Not W1UpdFlg
     C                   Eval      *In99  = *On
     C                   Eval      RtnCde = 1
     C     '0002'        Dump
     C                   GoTo      $XMainSr
     C                   EndIf
      *
     C     $XMainSr      Tag
     C                   EndSr
      *
      *====================================================================*
      * Initial Reference                                                  *
      *====================================================================*
      *
     C     @InitRef      BegSr
     C                   Eval      H1SN = %SubSt(User:3:4)
     C                   Eval      W1UpdFlg = *Off
      *
     C     $XInitRef     Tag
     C                   EndSr
      *
      *====================================================================*
      * *InzSr                                                             *
      *====================================================================*
      *
     C     *InzSr        BegSr
      *
     C                   EndSr
