      *===================================================
      * PROGRAM -
      * PURPOSE -
      * WRITTEN -
      * AUTHOR  -
      *
      * PROGRAM DESCRIPTION
      *
      *
      *
      * INPUT PARAMETERS
      *   Description        Type  Size    How Used
      *   -----------        ----  ----    --------
      *
      * INDICATOR USAGE
      *
      *===================================================
      *
      * Program Info
      *
     d                SDS
     d  @PGM                   1     10
     d  @PARMS                37     39  0
     d  @JOB                 244    253
     d  @USER                254    263
     d  @JOB#                264    269  0
      *
      *  Field Definitions.
      *
     d AllText         s             10    Inz('*ALL')
     d bOvr            s              1a   inz('0')
     d CmdString       s            256
     d CmdLength       s             15  5
     d Count           s              4  0
     d CRLF            c                   CONST(X'0d25')
     d CYMD            s              7  0
     d emailaddress    s             50    inz('helpdesk@xxxxxxxxx.com')
     d Fmt             s              8a   inz('MBRD0200')
     d fnd             s              4  0
     d Format          s              8
     d GenLen          s              8
     d heldjobq        s             10    dim(100)
     d heldjobqst      s               z   dim(100)
     d hj#             s              3  0
     d Howmany         s              8  0
     d InLibrary       s             10
     d InObject        s             10
     d InType          s             10
     d ISoDate         s               D
     d jj#             s              3  0
     d jobqlibrary     s             20
     d jobqjobs        s             10    dim(100)
     d jobqjobsst      s               z   dim(100)
     d Low             c                   CONST('abcdefghijklmnopqrstuvwxyz')
     d memberName      s             10    inz('*FIRST')
     d message         s            512    varying
     d ObjectLib       s             20
     d OS400_Cmd       s           2000    inz
     d OutNumber       s             10
     d P1deleted       s              8  0
     d P1created       s              8  0
     d P1changed       s              8  0
     d P1desc          s             50
     d P1Records       s              8  0
     d   Q             s              1    inz('''')
     d SpaceVal        s              1    inz(*BLANKS)
     d SpaceAuth       s             10    inz('*CHANGE')
     d SpaceText       s             50    inz(*BLANKS)
     d SpaceRepl       s             10    inz('*YES')
     d SpaceAttr       s             10    inz(*BLANKS)
     d subject         s             44    varying
     d subsystem       s             10    dim(999)
     d subsystemStamp  s               z   dim(999)
     d sb#             s              3  0
     d Up              c                   CONST('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     d USA             s              8  0
     d UserSpaceOut    s             20
À     *                                                                                            Ä
À     * GenHdr                                                                                     Ä
À     *                                                                                            Ä
     d GenHdr          ds                  inz
     d  OffSet                 1      4B 0
     d  NumEnt                 9     12B 0
     d  Lstsiz                13     16B 0
À     *                                                                                            Ä
À     *  Data structures                                                                           Ä
À     *                                                                                            Ä
     d GENDS           ds
     d  OffsetHdr              1      4B 0
     d  NbrInList              9     12B 0
     d  SizeEntry             13     16B 0
      *
      *
     d HeaderDs        ds
     d  OutFileNam             1     10
     d  OutLibName            11     20
     d  OutType               21     25
     d  OutFormat             31     40
     d  RecordLen                    10i 0
      *
      * API Error Data Structure
      *
     d ErrorDs         DS                  INZ
     d  BytesPrv               1      4B 0
     d  BytesAvl               5      8B 0
     d  MessageId              9     15
     d  ERR###                16     16
     d  MessageDta            17    116
      *
      * Create userspace datastructure
      *
     d                 DS
     d  StartPosit             1      4B 0
     d  StartLen               5      8B 0
     d  SpaceLen               9     12B 0
     d  ReceiveLen            13     16B 0
     d  MessageKey            17     20B 0
     d  MsgDtaLen             21     24B 0
     d  MsgQueNbr             25     28B 0
      *
      * Date structure for retriving userspace info
      *
     d InputDs         DS
     d  UserSpace              1     20
     d  SpaceName              1     10
     d  SpaceLib              11     20
     d  InpFileLib            29     48
     d  InpFFilNam            29     38
     d  InpFFilLib            39     48
     d  InpRcdFmt             49     58
      *
     d ObjectDs        ds
     d  Object                       10
     d  Library                      10
     d  ObjectType                   10
     d  InfoStatus                    1
     d  ExtObjAttrib                 10
     d  Description                  50

     d qcmdexc         pr                  extpgm( 'QCMDEXC' )
     d   os400_cmd                 2000A   options( *varsize ) const
     d   cmdlength                   15P 5                     const

     d $getjobq        pr                  extpgm('QSPRJOBQ')
     d  RECIEVER                    144A
     d  RCVRLEN                      10I 0 const
     d  FORMAT                        8A   const
     d  JOBQ                         20A   conST
     d  ERROR                       116A
      *
     DQSPQ020000       DS
     D BytesReturned                 10i 0
     D BytesAvailable                10i 0
     D QueueName                     10
     D QueueLib                      10
     D Controlled                    10
     D Authority                     10
     D NumberJobs                    10i 0
     D Status                        10
     D SubsystemName                 10
     D SubsystemLib                  10
     D SBSDescription                50
     D Sequence#                     10i 0
     D MaxActive                     10i 0
     D CurrentActive                 10i 0
     D MaxActiveP1                   10i 0
     D MaxActiveP2                   10i 0
     D MaxActiveP3                   10i 0
     D MaxActiveP4                   10i 0
     D MaxActiveP5                   10i 0
     D MaxActiveP6                   10i 0
     D MaxActiveP7                   10i 0
     D MaxActiveP8                   10i 0
     D MaxActiveP9                   10i 0
     D ActiveJobsP0                  10i 0
     D ActiveJobsP1                  10i 0
     D ActiveJobsP2                  10i 0
     D ActiveJobsP3                  10i 0
     D ActiveJobsP4                  10i 0
     D ActiveJobsP5                  10i 0
     D ActiveJobsP6                  10i 0
     D ActiveJobsP7                  10i 0
     D ActiveJobsP8                  10i 0
     D ActiveJobsP9                  10i 0
     D ReleaseJobs0                  10i 0
     D ReleaseJobs1                  10i 0
     D ReleaseJobs2                  10i 0
     D ReleaseJobs3                  10i 0
     D ReleaseJobs4                  10i 0
     D ReleaseJobs5                  10i 0
     D ReleaseJobs6                  10i 0
     D ReleaseJobs7                  10i 0
     D ReleaseJobs8                  10i 0
     D ReleaseJobs9                  10i 0
     D ScheduledJobs0                10i 0
     D ScheduledJobs1                10i 0
     D ScheduledJobs2                10i 0
     D ScheduledJobs3                10i 0
     D ScheduledJobs4                10i 0
     D ScheduledJobs5                10i 0
     D ScheduledJobs6                10i 0
     D ScheduledJobs7                10i 0
     D ScheduledJobs8                10i 0
     D ScheduledJobs9                10i 0
     D HeldJobs0                     10i 0
     D HeldJobs1                     10i 0
     D HeldJobs2                     10i 0
     D HeldJobs3                     10i 0
     D HeldJobs4                     10i 0
     D HeldJobs5                     10i 0
     D HeldJobs6                     10i 0
     D HeldJobs7                     10i 0
     D HeldJobs8                     10i 0
     D HeldJobs9                     10i 0
      *
     dQUSEC            DS
     d QUSBPRV                 1      4B 0
     d QUSBAVL                 5      8B 0
     d QUSEI                   9     15
     d QUSERVED               16     16

     d QUSED01                      100A
      *
      * Standard API error data structure
      *
     d apierror        ds                  inz
     d  AEBYPR                 1      4B 0
     d  AEBYAV                 5      8B 0
     d  AEEXID                 9     15
     d  AEEXDT                16    116
      *
      *  Create a userspace
      *
     c                   exsr      $QUSCRTUS
      *
      * List all the objects to the user space
      *
     c                   eval      Format = 'OBJL0200'
     c                   eval      objectlib =  InObject  + InLibrary
      *
     c                   call(e)   'QUSLOBJ'
     c                   parm      Userspace     UserSpaceOut
     c                   parm                    Format
     c                   parm                    ObjectLib
     c                   parm                    InType
      *
      * Retrive header entry and process the user space
      *
     c                   eval      StartPosit = 125
     c                   eval      StartLen   = 16
      *
      * Retrive header entry and process the user space
      *
     c                   call      'QUSRTVUS'
     c                   parm      UserSpace     UserSpaceOut
     c                   parm                    StartPosit
     c                   parm                    StartLen
     c                   parm                    GENDS
      *
     c                   eval      StartPosit = OffsetHdr + 1
     c                   eval      StartLen = %size(ObjectDS)
      *
À     *  Do for number of fields                                                                   Ä
      *
     c                   z-add     NbrInList     HowMany
B1   c                   do        NbrInList
      *
      *
     c                   call(e)   'QUSRTVUS'
     c                   parm      UserSpace     UserSpaceOut
     c                   parm                    StartPosit
     c                   parm                    StartLen
     c                   parm                    ObjectDs
      *
      *  Object = the jobq Name - get jobq information
      *
      /Free

        jobqlibrary = Object + 'QGPL';
        $GetJobQ(QSPQ020000:%SIZE(QSPQ020000):'JOBQ0200':
                  jobqlibrary:apierror);

        // send email if any jobq in QGPL is held.
        // wait 15 minutes to send again
        if Status = 'HELD';
         // see if message already sent
         fnd = %lookup(object : heldjobq);

         if fnd = *zeros or %diff(%timestamp():
                            heldjobqst(fnd):*minutes) >= 15;
          if fnd = *zeros;
           hj# +=1;
           heldjobq(hj#) = object;
           heldjobqst(hj#) = %timestamp();
          else;
           heldjobqst(fnd) = %timestamp();
          endif;

          subject = 'JobQ ' + %trim(object) + ' is HELD ' + %char(%time());
          message = 'Please logon to system and release this JobQ' +
                    ' currently there are ' + %char(ReleaseJobs5) +
                    ' job(s) on the queue.';
          exsr $snddst;
         endif;
        endif;


        // send email if more than 5 jobs in jobQ.
        // wait 15 minutes to send again

         // see if message already sent
         fnd = %lookup(object : jobqjobs);
         if releaseJobs5 >= 5;
          if fnd = *zeros or %diff(%timestamp():
                            jobqjobsst(fnd):*minutes) >= 15;
           if fnd = *zeros;
            jj# +=1;
            jobqjobs(jj#) = object;
            jobqjobsst(jj#) = %timestamp();
           else;
            jobqjobsst(fnd) = %timestamp();
           endif;

           subject = 'More than Allowed Jobs in jobq ' +  %trim(object);
           message = 'Please logon to system and check subsystem ' +
                      %trim(SubsystemName) +
                     ' currently there are ' + %char(ReleaseJobs5) +
                     ' job(s) on the queue. ' + CRLF +  %char(%timestamp);
           exsr $snddst;
          endif;
         endif;


      /end-free
      *
     c                   eval      StartPosit = StartPosit + SizeEntry
     c                   enddo
      *
      *  leave open so we can keep track of last email sent
      *
     c                   return
      *===============================================
      * $QUSCRTUS - API to create user space
      *===============================================
     c     $QUSCRTUS     begsr
      *
      * Create a user space named ListObjects in QTEMP.
      *
     c                   Eval      BytesPrv = 116
     c                   movel(p)  'LISTOBJECTS' SpaceName
     c                   movel(p)  'QTEMP'       SpaceLib
      *
      * Create the user space
      *
     c                   call(e)   'QUSCRTUS'
     c                   parm      UserSpace     UserSpaceOut
     c                   parm                    SpaceAttr
     c                   parm      4096          SpaceLen
     c                   parm                    SpaceVal
     c                   parm                    SpaceAuth
     c                   parm                    SpaceText
     c                   parm                    SpaceRepl
     c                   parm                    ErrorDs
      *
     c                   endsr
      /free

        //--------------------------------------------------------
        // $snddst - send email to helpdesk
        //--------------------------------------------------------
             begsr $snddst;

              // Send email to address
              os400_cmd = 'snddst type(*lmsg) ' +
                          'tointnet((' + Q + %trim(EmailAddress) +
                          Q + ')) dstd(' + Q    +
                          %trim(subject) +
                          Q + ') longmsg(' + Q  +
                          %trim(message) +
                          Q + ')';
              qcmdexc ( os400_cmd : %size ( os400_cmd ) );



             endsr;
        //--------------------------------------------------------

      /end-free
      *=================================================
      *    *Inzsr - One time run House keeping subroutine
      *=================================================
     c     *Inzsr        begsr
      *
     c                   eval      InObject = 'BOCJOBQ'
     c                   eval      InLibrary = 'QGPL'
     c                   eval      InType = '*JOBQ'

     c                   endsr
      *==============================================
