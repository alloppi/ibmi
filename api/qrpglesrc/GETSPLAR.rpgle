      *====================================================================*
      * Program name: GETSPLAR                                             *
      * Purpose.....: Get Latest Job ID & Spool ID from an OUTQ            *
      *                                                                    *
      * Date written: 2010/05/25                                           *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- ---------------------------- *
      * 2010/05/25 Alan       AC        03675 New Develop                  *
      *====================================================================*
     HDEBUG(*YES)
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
     D USRSPC                 43     62    INZ('GETSPLAR  QTEMP     ')
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
     D  WkCurOutQ              1     10
     D  WkLib                 11     20
      *
      * Input Parameter
     D P_OutQ          S             10A
     D P_SplNam        S             10A
     D P_Job           S             10A
     D P_User          S             10A
     D R_JobNam        S             10A
     D R_JobUser       S             10A
     D R_JobNbr        S              6A
     D R_SplfNbr       S              6P 0
     D W1JobNam        S                   Like(R_JobNam)
     D W1JobUser       S                   Like(R_JobUser)
     D W1JobNbr        S                   Like(R_JobNbr)
     D W1SplfNbr       S                   Like(R_SplfNbr)
      *
     D USEXAT          S             10A
     D USINIT          S              1A
     D USAUTH          S             10A
     D USTEXT          S             50A
     D USREPL          S             10A
     D USRNAM          S             10A
     D JOBINF          S             26A
     D SPLFNM          S             10A
     D FMTNAM          S              8A
     D FRMTYP          S             10A
     D USRDTA          S             10A
      *
     D Count           S             14P 0
     D CrtTime         S             13A
     D LstTime         S             13A
      *
      * Standard D spec.
      /Copy Qcpysrc,PSCY01R
      *
      * Mainline logic
     C     *Entry        Plist
     C                   Parm                    P_OutQ
     C                   Parm                    P_SplNam
     C                   Parm                    P_Job
     C                   Parm                    P_User
     C                   Parm                    R_JobNam
     C                   Parm                    R_JobUser
     C                   Parm                    R_JobNbr
     C                   Parm                    R_SplfNbr
     C                   Parm                    RtnCde
      *
      * Create User Space
     C                   ExSr      @CrtUsrSp
      *
      * Build user space of spool file list
     C                   ExSr      @FilUsrSp
      *
      * Get 1st entry from user space
     C                   ExSr      @GetSplInfo
     C                   DoW       Not *In61
      *
     C                   If        P_SplNam = QUSSN01
     C                   If        (P_Job  = *Blank or P_Job  = QUSJN10) and
     C                             (P_User = *Blank or P_User = QUSUN12)
     C                   Eval      CrtTime = QUSDFILO + QUSTFILO
     C                   If        CrtTime > LstTime
     C                   Eval      W1JobNam  = QUSJN10
     C                   Eval      W1JobUser = QUSUN12
     C                   Eval      W1JobNbr  = QUSJNBR09
     C                   Eval      W1SplfNbr = QUSSNBR
     C                   Eval      LstTime   = CrtTime
     C                   EndIf
     C                   EndIf
     C                   EndIf
      *
      * Get next entry from user space
     C                   ExSr      @GetSplInfo
     C                   EndDo
      *
      * Return Latest Job ID & Spool ID
     C                   If        W1JobNam <> *Blank
     C                   Eval      R_JobNam  = W1JobNam
     C                   Eval      R_JobUser = W1JobUser
     C                   Eval      R_JobNbr  = W1JobNbr
     C                   Eval      R_SplfNbr = W1SplfNbr
     C                   Else
     C     '0001'        Dump
     C                   Eval      *In99 = *On
     C                   Eval      RtnCde = 1
     C                   EndIf
      *
      * Delete User Space
     C                   ExSr      @DltUsrSp
      *
     C                   Eval      *INLR = *On
     C                   Return
      *
      *===============================================================*
      * @FilUsrSp - Fill user space with spool files in OutQ          *
      *===============================================================*
      *
     C     @FilUsrSp     BegSr
      *
      * Retrieve Output Queue Information
     C                   Eval      WkCurOutQ = P_OutQ
     C                   Eval      WkLib = '*LIBL'
      *
     C                   Call      'QSPROUTQ'
     C                   Parm                    QSPQ0100
     C                   Parm      152           RCVLEN
     C                   Parm      'OUTQ0100'    FMTNAM
     C                   Parm                    OUTQ
     C                   Parm                    QUSEC
      *
     C* List Spool Files in OUTQ
     C                   Eval      WkLib = '*LIBL'
      *
     C                   Call      'QUSLSPL'
     C                   Parm                    USRSPC
     C                   Parm      'SPLF0100'    FMTNAM
     C                   Parm      '*ALL    '    USRNAM
     C                   Parm                    OUTQ
     C                   Parm      '*ALL    '    FRMTYP
     C                   Parm      '*ALL    '    USRDTA
     C                   Parm                    QUSBN
      *
     C* The User Space is filled with list of Spool Files
     C* Use QUSRTVUS to retrieve Number of Entries,
     C*   Offset and Size of Each Entry
     C                   Eval      GENLEN = 140
     C                   Eval      STRPOS = 1
      *
     C                   Call      'QUSRTVUS'
     C                   Parm                    USRSPC
     C                   Parm                    STRPOS
     C                   Parm                    GENLEN
     C                   Parm                    QUSH0100                       OffSet List Data
     C                   Parm                    QUSBN
      *
     C* Check Generic Header Data Structure for
     C*   Number of List Entries, Offset to List Entries and
     C*   Size of each list Entry.
     C*
     C                   Eval      STRPOS = QUSOLD + 1
     C                   Eval      RTVLEN = QUSSEE                              Size Each Entry
     C                   Eval      Count = 1
      *
     C                   EndSr
      *
      *==============================================================*
      * @GetSplInfo - Get 1 entry from spool file list user space    *
      *==============================================================*
      *
     C     @GetSplInfo   BegSr
      *
     C* Retreive Interial Job ID and Spool File ID from
     C*   each Entry in User Space.
     C* This information will be used to retreive
     C*   the attributes in spool file
     C                   If        Count > QUSNBRLE
      *
     C                   Eval      *In61 = *On
     C                   Else
     C                   Eval      *In61 = *Off
     C                   Call      'QUSRTVUS'
     C                   Parm                    USRSPC
     C                   Parm                    STRPOS
     C                   Parm                    RTVLEN
     C                   Parm                    QUSF0100
     C                   Parm                    QUSBN
      *
      * Retrieve Spool File Attributes using QUSRSPLA
     C                   Eval      JOBINF = '*INT'
     C                   Move      *Blank        SPLF#
      *
     C                   Call      'QUSRSPLA'
     C                   Parm                    QUSA010001
     C                   Parm      215           RCVLEN
     C                   Parm      'SPLA0100'    FMTNAM
     C                   Parm                    JOBINF
     C                   Parm      QUSIJID07     QUSIJID08                      Int Job ID
     C                   Parm      QUSISID       QUSISID00                      Int Splf ID
     C                   Parm      '*INT      '  SPLFNM
     C                   Parm                    SPLF#
     C                   Parm                    QUSBN
      *
     C* Process next Entry in User Space
     C                   Eval      STRPOS = STRPOS + QUSSEE
     C                   Eval      Count  = Count + 1
      *
     C                   EndIf
      *
     C                   EndSr
      *
      *===============================================================*
      * @CrtUsrSp - Create User Space                                 *
      *===============================================================*
      *
     C     @CrtUsrSp     BegSr
      *
     C* Create user space to store list of spooled files
     C                   Call      'QUSCRTUS'
     C                   Parm                    USRSPC
     C                   Parm      *BLANKS       USEXAT
     C                   Parm      1024          USSIZE
     C                   Parm      ' '           USINIT
     C                   Parm      '*CHANGE '    USAUTH
     C                   Parm      *BLANKS       USTEXT
     C                   Parm      '*YES    '    USREPL
     C                   Parm                    QUSBN
      *
     C                   EndSr
      *
      *==============================================================*
      * @DltUsrSp - Delete User Space                                *
      *==============================================================*
      *
     C     @DltUsrSp     BegSr
      *
     C                   Call      'QUSDLTUS'
     C                   Parm                    USRSPC
     C                   Parm                    QUSBN
      *
     C                   EndSr
      *
      *========================*
      * *INZSR                 *
      *========================*
      *
     C     *INZSR        BegSr
      *
      * Variable declarations
     C                   Eval      QUSBN  = *Blank
     C                   Eval      QUSBNB = *Zero
      *
     C                   Eval      R_JobNam  = *Blank
     C                   Eval      R_JobUser = *Blank
     C                   Eval      R_JobNbr  = *Blank
     C                   Eval      R_SplfNbr = *Zero
     C                   Eval      W1JobNam  = *Blank
     C                   Eval      W1JobUser = *Blank
     C                   Eval      W1JobNbr  = *Blank
     C                   Eval      W1SplfNbr = *Zero
     C                   Eval      LstTime   = *Blank
      *
     C                   EndSr
