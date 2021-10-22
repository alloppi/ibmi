  **************************************************  ***
      * Check for an Active Job using
      * List Jobs API (QUSLJOB) prototype
      **************************************************  ***
     D QUSLJOB         PR                  ExtPgm('QUSLJOB')
     D   UserSpace                   20A   const
     D   Format                       8A   const
     D   QualJob                     26A   const
     D   Status                      10A   const
      * optional group 1:
     D   ErrorCode                 8000A   options(*varsize: *nopass)
      * optional group 2:
     D   JobType                      1A   const options(*nopass)
     D   NbrKeyFld                   10I 0 const options(*nopass)
     D   KeyFlds                     10I 0 const dim(1000)
     D                                     options(*varsize: *nopass)
      * optional group 3:
     D   ContHandle                  48A   const options(*nopass)

      **************************************************  ***
      * API error code data structure
      **************************************************  ***
     D MyErrCode       DS
     D  BytesProv                    10I 0 inz(%size(MyErrCode))
     D  BytesAvail                   10I 0 inz(0)
     D  MsgID                         7A
     D  Reserved                      1A
     D  MessageData                1000A

      **************************************************  ***
      * Generic Header Format used by the "List APIs"
      *
      *  There is a lot of information returned in the
      *  generic header, but all I'm interested in is
      *  the offsets needed to access the list entries
      *  themselves.
      **************************************************  ***
     D p_ListHeader    s               *
     D ListHeader      ds                  based(p_ListHeader)
     D   DataOffset          125    128I 0
     D   NumEntries          133    136I 0
     D   EntrySize           137    140I 0

      **************************************************  ***
      * This structure is designed to match format
      * JOBL0100 the QUSLJOB API.
      **************************************************  ***
     D p_ListEntry     s               *
     D JOBL0100        ds                  based(p_ListEntry)
     D   JobName                     10A
     D   JobUser                     10A
     D   JobNbr                       6A
     D   InternalID                  16A
     D   Status                      10A
     D   JobType                      1A
     D   JobSubtype                   1A

      **************************************************  ***
      * Create User Space (QUSCRTUS) API
      **************************************************  ***
     D QUSCRTUS        PR                  ExtPgm('QUSCRTUS')
     D   UserSpace                   20A   const
     D   Attrib                      10A   const
     D   InitSize                    10I 0 const
     D   InitVal                      1A   const
     D   PubAuth                     10A   const
     D   Text                        50A   const
      * optional group 1:
     D   Replace                     10A   const options(*nopass)
     D   ErrorCode                 8000A   options(*varsize: *nopass)
      * optional group 2:
     D   Domain                      10A   const options(*nopass)
      * optional group 3:
     D   XferSizeReq                 10I 0 const options(*nopass)
     D   OptAlign                     1A   const options(*nopass)

      **************************************************  ***
      *  Retrieve Pointer to User Space (QUSPTRUS) API
      **************************************************  ***
     D QUSPTRUS        PR                  ExtPgm('QUSPTRUS')
     D   UserSpace                   20A   const
     D   Pointer                       *
     D   ErrorCode                 8000A   options(*varsize: *nopass)


     D p_Start         s               *
     D EntryNo         s             10I 0
     D JobFound        s              1
     D JobCheck        s             10


      **
      **  Create a user space that the QUSLJOB API can store it's
      **  output into.
      **
      **  The initial size of the user space will be 256k (256 * 1024)
      **  however, the QUSLJOB API will extend it if it needs to be
      **  larger.
      **
     c     *entry        plist
     c                   parm                    JobFound
     c                   parm                    JobCheck
     c
     c                   eval      JobFound = '0'

     c                   callp     QUSCRTUS( 'JOBLIST   QTEMP'
     c                                     : 'MYPGMNAME'
     c                                     : 256 * 1024
     c                                     : x'00'
     c                                     : '*USE'
     c                                     : 'List of active jobs'
     c                                     : '*YES'
     c                                     : MyErrCode            )

     c                   if        BytesAvail <> 0
     c                   eval      *inlr = *on
     c                   return
     c                   endif


      **
      **  List all active jobs on the system.  The output
      **  will go into the user space we created (above)
      **
     c                   callp     QUSLJOB( 'JOBLIST   QTEMP'
     c                                    : 'JOBL0100'
     c                                    : '*ALL      *ALL      *ALL'
     c                                    : '*ACTIVE'
     c                                    : MyErrCode                 )

     c                   if        BytesAvail <> 0
     c                   eval      *inlr = *on
     c                   return
     c                   endif

      **
      **  Get a pointer to the user space.  In this example, the
      **  "Bytes Provided" field is zero, so the program will halt
      **  with a "CPFxxxx" error if something goes wrong:
      **
     c                   eval      BytesProv = 0

     c                   callp     QUSPTRUS( 'JOBLIST   QTEMP'
     c                                     : p_ListHeader     )

      **
      **  Use data structure that's based on a pointer to view each
      **  entry in the list. After viewing each entry, increase
      **  the pointer so that we view the next item.
      **
     c                   eval      p_Start = p_ListHeader + DataOffset

     c                   for       EntryNo = 1 to NumEntries

     c                   eval      p_ListEntry = p_Start +
     c                                 (EntryNo - 1) * EntrySize

      ** If the job is found

     c                   if        %trim(JobName) = %trim(Jobcheck)

     C                   eval      Jobfound = *on

     c
     C                   endif
     c                   endfor

      **
      **  That's all, end the program.
      **
     c                   eval      *inlr = *on

