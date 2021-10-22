      *===================================================================*
      * Program name: PSXX0LR                                             *
      * Purpose.....: Retrieve Job Queue Information (QSPRJOBQ)           *
      *                                                                   *
      * Date written: 2017/03/10                                          *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- ----------------------------*
      * 2017/03/10 Alan       AC        06515 New develop                 *
      *===================================================================*
     H debug(*yes)
     H option(*SRCSTMT:*NODEBUGIO)

      * Entry Parameter
     d P_Library       s             10a
     d P_JobQ          s             10a
     d R_RtnCde        s              2p 0
     d R_NoOfJobs      s              5p 0
     d R_JobQStatus    s             10a
     d R_SubSystem     s             10a
     d R_MaxActive     s              5p 0
     d R_CurActive     s              5p 0

      * Working variable
     d JobQName        s             20a

      * External Prototypes
     D GetJobQ         pr                  EXTPGM('QSPRJOBQ')
     D  Receiver                    144A
     D  RcvrLen                      10I 0 const
     D  Format                        8A   const
     D  JobQ                         20A   conST
     D  Error                       116A
      *
      * Copy from QSPRJOBQ
     ****** /INCLUDE QSYSINC/QRPGLESRC,QSPRJOBQ
      *
     DQSPQ010000       DS
     D*                                             Qsp JOBQ0100
     D QSPBRTN00               1      4B 0
     D*                                             Bytes Returned
     D QSPBAVL00               5      8B 0
     D*                                             Bytes Available
     D QSPJQN                  9     18
     D*                                             Job Queue Name
     D QSPJQLN                19     28
     D*                                             Job Queue Lib Name
     D QSPOC01                29     38
     D*                                             Operator Controlled
     D QSPAC                  39     48
     D*                                             Authority Check
     D QSPNBRJ                49     52B 0
     D*                                             Number Jobs
     D QSPJQS                 53     62
     D*                                             Job Queue Status
     D QSPSN                  63     72
     D*                                             Subsystem Name
     D QSPTD                  73    122
     D*                                             Text Description
     D QSPSLN                123    132
     D*                                             Subsystem Lib Name
     D QSPSNBR01             133    136B 0
     D*                                             Sequence Number
     D QSPMA00               137    140B 0
     D*                                             Maximum Active
     D QSPCA00               141    144B 0
      *                                             Current Active
      *
      *
     DQSPQ020000       DS
     D*                                             Qsp JOBQ0200
     D QSPBRTN05               1      4B 0
     D*                                             Bytes Returned
     D QSPBAVL03               5      8B 0
     D*                                             Bytes Available
     D QSPJQN02                9     18
     D*                                             Job Queue Name
     D QSPJQLN02              19     28
     D*                                             Job Queue Lib Name
     D QSPOC02                29     38
     D*                                             Operator Controlled
     D QSPAC00                39     48
     D*                                             Authority Check
     D QSPNBRJ00              49     52B 0
     D*                                             Number Jobs
     D QSPJQS01               53     62
     D*                                             Job Queue Status
     D QSPSN02                63     72
     D*                                             Subsystem Name
     D QSPSLN00               73     82
     D*                                             Subsystem Lib Name
     D QSPTD00                83    132
     D*                                             Text Description
     D QSPSNBR02             133    136B 0
     D*                                             Sequence Number
     D QSPMA01               137    140B 0
     D*                                             Maximum Active
     D QSPCA01               141    144B 0
     D*                                             Current Active
     D QSPMAP1               145    148B 0
     D*                                             Max Active Priority
     D QSPMAP2               149    152B 0
     D*                                             Max Active Priority
     D QSPMAP3               153    156B 0
     D*                                             Max Active Priority
     D QSPMAP4               157    160B 0
     D*                                             Max Active Priority
     D QSPMAP5               161    164B 0
     D*                                             Max Active Priority
     D QSPMAP6               165    168B 0
     D*                                             Max Active Priority
     D QSPMAP7               169    172B 0
     D*                                             Max Active Priority
     D QSPMAP8               173    176B 0
     D*                                             Max Active Priority
     D QSPMAP9               177    180B 0
     D*                                             Max Active Priority
     D QSPAJP0               181    184B 0
     D*                                             Active Jobs Priorit
     D QSPAJP1               185    188B 0
     D*                                             Active Jobs Priorit
     D QSPAJP2               189    192B 0
     D*                                             Active Jobs Priorit
     D QSPAJP3               193    196B 0
     D*                                             Active Jobs Priorit
     D QSPAJP4               197    200B 0
     D*                                             Active Jobs Priorit
     D QSPAJP5               201    204B 0
     D*                                             Active Jobs Priorit
     D QSPAJP6               205    208B 0
     D*                                             Active Jobs Priorit
     D QSPAJP7               209    212B 0
     D*                                             Active Jobs Priorit
     D QSPAJP8               213    216B 0
     D*                                             Active Jobs Priorit
     D QSPAJP9               217    220B 0
     D*                                             Active Jobs Priorit
     D QSPJOQP0              221    224B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP1              225    228B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP2              229    232B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP3              233    236B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP4              237    240B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP5              241    244B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP6              245    248B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP7              249    252B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP8              253    256B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP9              257    260B 0
     D*                                             RLS Jobs on Queue P
     D QSPJOQP000            261    264B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP100            265    268B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP200            269    272B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP300            273    276B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP400            277    280B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP500            281    284B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP600            285    288B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP700            289    292B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP800            293    296B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP900            297    300B 0
     D*                                             SCH Jobs on Queue P
     D QSPJOQP001            301    304B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP101            305    308B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP201            309    312B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP301            313    316B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP401            317    320B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP501            321    324B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP601            325    328B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP701            329    332B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP801            333    336B 0
     D*                                             HLD Jobs on Queue P
     D QSPJOQP901            337    340B 0
      *                                             HLD Jobs on Queue P
      *
      */INCLUDE QSYSINC/QRPGLESRC,QUSEC
      *
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
     D*
     D*                                      Varying length
     DQUSC0200         DS
     D*                                             Qus ERRC0200
     D QUSK01                  1      4B 0
     D*                                             Key
     D QUSBPRV00               5      8B 0
     D*                                             Bytes Provided
     D QUSBAVL14               9     12B 0
     D*                                             Bytes Available
     D QUSEI00                13     19
     D*                                             Exception Id
     D QUSERVED39             20     20
     D*                                             Reserved
     D QUSCCSID11             21     24B 0
     D*                                             CCSID
     D QUSOED01               25     28B 0
     D*                                             Offset Exc Data
     D QUSLED01               29     32B 0
     D*                                             Length Exc Data
     D*QUSRSV214              33     33
     D*                                             Reserved2

     D QUSED01                      100A
      *
      * Standard API error data structure
      *
     d ApiError        DS                  inz
     d  AEBYPR                 1      4B 0
     d  AEBYAV                 5      8B 0
     d  AEEXID                 9     15
     d  AEEXDT                16    116
      *
      *===================================================================*
      * Mainline logic
      *===================================================================*
     C     *Entry        Plist
     C                   Parm                    P_Library
     C                   Parm                    P_JobQ
     C                   Parm                    R_RtnCde
     C                   Parm                    R_NoOfJobs
     C                   Parm                    R_JobQStatus
     C                   Parm                    R_SubSystem
     C                   Parm                    R_MaxActive
     C                   Parm                    R_CurActive

     C                   Eval      JobQName = P_JobQ + P_Library

     C                   monitor
     C                   callp     GetJobQ( QSPQ010000                          Receiver variable
     C                                     :%size(QSPQ010000)                   Length of receiver
     C                                     :'JOBQ0100'                          Format Name
     C                                     :JobQName                            job queue name
     C                                     :ApiError)                           Error code
     C                   on-error
     C                   if        QUSBAVL > 0
     C     '0001'        dump
     C                   eval      R_RtnCde = 1
     C                   else
     C                   eval      R_NoOfJobs   = QSPNBRJ
     C                   eval      R_JobQStatus = QSPJQS
     C                   eval      R_SubSystem  = QSPSLN
     C                   eval      R_MaxActive  = QSPMA00
     C                   eval      R_CurActive  = QSPCA00
     C                   endif
     C                   endMon

     C                   eval      *inlr = *on
     C                   return

      *===================================================================*
      * *InzSr
      *===================================================================*
     C     *InzSr        Begsr
      *
     C                   eval      R_RtnCde     = 0
     C                   eval      R_NoOfJobs   = 0
     C                   eval      R_JobQStatus = *blank
     C                   eval      R_SubSystem  = *blank
     C                   eval      R_MaxActive  = 0
     C                   eval      R_CurActive  = 0
      *
     C                   endsr
