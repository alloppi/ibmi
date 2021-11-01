      *==============================================================*
      * Program name: SNDSPLFR                                       *
      * Purpose.....: Send Spool file to printer                     *
      *                                                              *
      * Date written: 1999/06/14                                     *
      *                                                              *
      * Modification:                                                *
      * Date       Name       Prefix Mod#  Remarks                   *
      * ---------- ---------- ------ ----- ------------------------- *
      * 1999/06/14 Alan                    Develop                   *
      *==============================================================*
      * Data Stru
     DSTRUCT           DS
     D USSIZE                  1      4B 0
     D GENLEN                  5      8B 0
     D RTVLEN                  9     12B 0
     D STRPOS                 13     16B 0
     D RCVLEN                 17     20B 0
     D SPLF#                  21     24B 0
     D MSGDLN                 25     28B 0
     D MSGQ#                  29     32B 0
     D FIL#                   33     38
     D MSGKEY                 39     42
     D USRSPC                 43     62    INZ('PSXX21R   QTEMP     ')
     D MSGQ                   63     82    INZ('*REQUESTER          ')
     D/COPY QCPYSRC,QUSGEN
     D/COPY QCPYSRC,QUSLSPL
     D/COPY QCPYSRC,QUSRSPLA
     D/COPY QCPYSRC,QSPROUTQ
     D/COPY QCPYSRC,QSPRWTRI
     D/COPY QCPYSRC,QUSEC
     DQUSBN            DS
     D QUSBNB                  1      4B 0
     D QUSBNC                  5      8B 0
     D QUSBND                  9     15
     D QUSBNF                 16     16
     D EXCDTA                 17    116
      *
     D                 DS
     D OUTQ                    1     20
     D WkCurOutQ               1     10
     D WkLib                  11     20    INZ('*LIBL     ')
      *
     D USRNAM          S             10A   INZ('*ALL      ')
     D P_SplfNam       S             10A
     D P_JobNbr        S              6A
     D P_UsrNam        S             10A
     D P_JobNam        S             10A
     D P_SplNbr        S              9P 0
      *
     D P_PgmID         S             10
     D P_OutQ          S             10
     D P_Printer       S             10
      *
      * Standard D spec.
      /Copy Qcpysrc,PSCY01R
      *
      * Mainline logic
     C     *Entry        Plist
     C                   Parm                    P_PgmID
     C                   Parm                    P_OutQ
     C                   Parm                    P_Printer
     C                   Parm                    RtnCde
      *
      * Create User Space
     C                   Exsr      @CrtUsrSp
      *
      * Build user space of spool file list
     C                   Exsr      @FilUsrSp
      *
      * Get 1st entry from user space
     C                   Exsr      @GetSplInfo
      *
     C                   DoW       not *In99
      *
      * If user data = program name, send splf to printer
     C                   If        QUSUD01 = P_PgmID
     C                   Eval      P_SplfNam = QUSSN01
     C                   Eval      P_JobNbr  = QUSJNBR09
     C                   Eval      P_UsrNam  = QUSUN12
     C                   Eval      P_JobNam  = QUSJN10
     C                   Eval      P_SplNbr  = QUSSNBR
     C                   Call      'PSXX22C'
     C                   Parm                    P_SplfNam
     C                   Parm                    P_JobNbr
     C                   Parm                    P_UsrNam
     C                   Parm                    P_JobNam
     C                   Parm                    P_SplNbr
     C                   Parm                    P_Printer
     C                   Endif
      *
      * Get next entry from user space
     C                   Exsr      @GetSplInfo
     C                   EndDo
      * End of program
      *
      * Delete User Space
     C                   Exsr      @DltUsrSp
     C                   Eval      *INLR = *On
     C                   Return
      *
      *==============================================================*
      * @FilUsrSp - Fill the user space with spool files in OutQ     *
      *==============================================================*
      *
     C     @FilUsrSp     BegSr
      *
      * RETRIEVE OUTPUT QUEUE STATUS
     C                   Eval      WkCurOutQ = P_OutQ
     C                   MoveL(P)  '*LIBL'       WkLib
     C                   CALL      'QSPROUTQ'
     C                   PARM                    QSPQ0100
     C                   PARM      152           RCVLEN
     C                   PARM      'OUTQ0100'    FMTNM2            8
     C                   PARM                    OUTQ
     C                   PARM                    QUSEC
      *
     C* FILL THE USER SPACE WITH SPOOLED FILES IN THE OUTQ
     C                   MoveL(P)  '*LIBL'       WkLib
     C                   CALL      'QUSLSPL'
     C                   PARM                    USRSPC
     C                   PARM      'SPLF0100'    FMTNM1            8
     C                   PARM      '*ALL    '    USRNAM
     C                   PARM                    OUTQ
     C                   PARM      '*ALL    '    FRMTYP           10
     C                   PARM      '*ALL    '    USRDTA           10
     C                   PARM                    QUSBN
     C* THE USER SPACE IS NOW FILLED WITH THE LIST OF SPOOLED FILES.
     C* NOW USE THE QUSRTVUS API TO FIND THE NUMBER OF ENTRIES AND
     C* THE OFFSET AND SIZE OF EACH ENTRY IN THE USER SPACE.
     C                   Z-ADD     140           GENLEN
     C                   Z-ADD     1             STRPOS
     C*
     C                   CALL      'QUSRTVUS'
     C                   PARM                    USRSPC
     C                   PARM                    STRPOS
     C                   PARM                    GENLEN
     C                   PARM                    QUSH0100                       OffSet List Data
     C                   PARM                    QUSBN
     C* CHECK THE GENERIC HEADER DATA STRUCTURE FOR NUMBER OF LIST
     C* ENTRIES, OFFSET TO LIST ENTRIES, AND SIZE OF EACH LIST ENTRY.
     C*
     C                   Z-ADD     QUSOLD        STRPOS
     C                   ADD       1             STRPOS
     C                   Z-ADD     QUSSEE        RTVLEN                         Size Each Entry
     C*                  Z-ADD     215           RCVLEN
     C                   Z-ADD     1             COUNT            14 0
      *
C    C                   EndSr
      *
      *==============================================================*
      * @GetSplInfo - Get 1 entry from spool file list user space    *
      *==============================================================*
      *
     C     @GetSplInfo   BegSr
      *
     C* RETRIEVE THE INTERNAL JOB ID AND SPOOLED FILE ID FORM THE ENTRY
     C* IN THE USER SPACE. THIS INFORMATION WILL BE USED TO RETRIEVE
     C* THE ATTRIBUTES OF THE SPOOLED FILE.
     C* THIS WILL BE DONE FOR EACH ENTRY IN THE USER SPACE
     C                   If        COUNT > QUSNBRLE
     C                   Eval      *In99 = *On
     C                   Else
     C                   Eval      *In99 = *Off
     C                   CALL      'QUSRTVUS'
     C                   PARM                    USRSPC
     C                   PARM                    STRPOS
     C                   PARM                    RTVLEN
     C                   PARM                    QUSF0100
     C                   PARM                    QUSBN
     C* NOW RETRIEVE THE SPOOLED FILE ATTRIBUTES USING THE QUSRSPLA
     C* API
     C                   MOVE      *BLANKS       JOBINF
     C                   MOVEL     '*INT'        JOBINF           26
     C                   MOVE      QUSIJID07     QUSIJID08                      INT JOB ID
     C                   MOVE      QUSISID       QUSISID00                      INT SPLF ID
     C                   MOVEL     '*INT'        SPLFNM           10
     C                   MOVE      *BLANKS       SPLF#
     C*
     C                   CALL      'QUSRSPLA'
     C                   PARM                    QUSA010001
     C                   PARM      215           RCVLEN
     C                   PARM      'SPLA0100'    FMTNM2            8
     C                   PARM                    JOBINF
     C                   PARM                    QUSIJID08                      INT JOB ID
     C                   PARM                    QUSISID00                      INT SPLF ID
     C                   PARM                    SPLFNM
     C                   PARM                    SPLF#
     C                   PARM                    QUSBN
     C* GO BACK AND PROCESS THE REST OF THE ENTRIES IN THE USER SPACE
     C     QUSSEE        ADD       STRPOS        STRPOS
     C     1             ADD       COUNT         COUNT
     C                   Endif
      *
C    C                   EndSr
      *
      *==============================================================*
      * @CrtUsrSp - Create User Space                                *
      *==============================================================*
      *
     C     @CrtUsrSp     BegSr
      *
     C* CREATE A USER SPACE TO STORE THE LIST OF SPOOLED FILES
     C                   CALL      'QUSCRTUS'
     C                   PARM                    USRSPC
     C                   PARM      *BLANKS       USEXAT           10
     C                   PARM      1024          USSIZE
     C                   PARM      ' '           USINIT            1
     C                   PARM      '*CHANGE '    USAUTH           10
     C                   PARM      *BLANKS       USTEXT           50
     C                   PARM      '*YES    '    USREPL           10
     C                   PARM                    QUSBN
      *
C    C                   EndSr
      *
      *==============================================================*
      * @DltUsrSp - Delete User Space                                *
      *==============================================================*
      *
     C     @DltUsrSp     BegSr
      *
     C                   CALL      'QUSDLTUS'
     C                   PARM                    USRSPC
     C                   PARM                    QUSBN
      *
C    C                   EndSr
      *
      *========================*
      * *INZSR                 *
      *========================*
      *
     C     *INZSR        BegSr
      *
      * Variable declarations
     C                   Time                    RnTime
     C                   MOVE      *BLANKS       QUSBN
     C                   Z-ADD     0             QUSBNB
      *
C    C                   EndSr
