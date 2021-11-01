      *============================================================================================*
      * Program name: FNDJOBQR                                                                     *
      * Purpose.....: Find the Job Queuing in Specify Job Queue                                    *
      *              - P_JobNam can be '*ALL', any job found                                       *
      *                                                                                            *
      * Date written: 2017/03/10                                                                   *
      *                                                                                            *
      * Description.: Accessing Job Queue Entries to Find a Particular Job                         *
     * Assumption..: (The job must be in 'RLS' status, otherwise not count find it in the queue)  *
      *                                                                                            *
      * API Used    : Open List of Jobs (QGYOLJOB) - Generate a list of jobs in a job queue        *
      *               Get List Entries (QGYGTLE)   - Access jobs that are selected in QGYOLJOB API *
      *               Close List (QGYCLST)         - Close the generate list of jobs               *
      *                                                                                            *
      * Modification:                                                                              *
      * Date       Name       Pre  Ver  Mod#  Remarks                                              *
      * ---------- ---------- --- ----- ----- ---------------------------------------------------- *
      * 2017/03/16 Alan       AC              New develop                                          *
      *============================================================================================*
     h debug(*yes)
     h dftactgrp(*no) actgrp(*caller)

      * Entry Parameter
     d P_Library       s             10a
     d P_JobQ          s             10a
     d P_JobNam        s             10a
     d R_RtnCde        s              2p 0
     d R_FndJobinJobQ  s              1a
      *
     d OpnLstJobs      pr                  extpgm('QGYOLJOB')
     d RcvVar                         1a   options(*varsize)
     d LenRcvVar                     10i 0 const
     d FmtRcvVar                      8a   const
     d RcvDfn                         1a   options(*varsize)
     d LenRcvDfn                     10i 0 const
     d LstInfo                       80a
     d NbrRcds                       10i 0 const
     d SortInfo                    4096a   const options(*varsize)
     d JobInfo                     4096a   const options(*varsize)
     d LenJobInfo                    10i 0 const
     d NbrKeys                       10i 0 const
     d KeyLst                      4096a   const options(*varsize)
     d ErrCde                              likeds(QUSEC)
     d FmtJobInfo                     8a   const options(*nopass)
     d ResetStats                     1a   const options(*nopass)
     d StatsDta                       1a   options(*nopass)
     d LenStatsDta                   10i 0 const options(*nopass)

     d GetNxtEnt       pr                  extpgm('QGYGTLE')
     d RcvVar                         1a   options(*varsize)
     d LenRcvVar                     10i 0 const
     d RqsHdl                         4a   const
     d LstInfo                       80a
     d NbrRcds                       10i 0 const
     d StrRcd                        10i 0 const
     d ErrCde                              likeds(QUSEC)

     d ClsLst          pr                  extpgm('QGYCLST')
     d RqsHdl                         4a   const
     d ErrCde                              likeds(QUSEC)

     d JobEntPtr       s               *
     d JobEnt          ds                  likeds(QGYB0200)
     d                                     based(JobEntPtr)

     d JobInfo         ds                  qualified
     d Hdr                                 likeds(QGYLJBJS)
     d PriJobSts                     10a
     d JobQJobSts                    10a
     d QualJobQ                      20a

     d KeyLst          ds
     d KeyFlds                       10i 0 dim(10)

     d ErrCde          ds                  qualified
     d Hdr                                 likeds(QUSEC)
     d MsgDta                       256a

     d Count           s              5u 0
     d JobLst          s           4096a
     d RcvDfn          s           4096a

      /copy qsysinc/qrpglesrc,qgyoljob
      /copy qsysinc/qrpglesrc,qusec

      *===================================================================*
      * Mainline logic
      *===================================================================*
     C     *Entry        Plist
     C                   Parm                    P_Library
     C                   Parm                    P_JobQ
     C                   Parm                    P_JobNam
     C                   Parm                    R_RtnCde
     C                   Parm                    R_FndJobinJobQ

      /free

        // Find all jobs with release status in particular job queue
        JobInfo.Hdr.QGYJN07  = '*ALL';  // Data Structure of QGYLJBJS
        JobInfo.Hdr.QGYUN04  = '*ALL';
        JobInfo.Hdr.QGYJNbr  = '*ALL';
        JobInfo.Hdr.QGYJT01  = '*';
        JobInfo.Hdr.QGYPJSO  = (%addr(JobInfo.PriJobSts) - %addr(JobInfo));
        JobInfo.Hdr.QGYPJSC  = 1;
        JobInfo.PriJobSts    = '*JOBQ';
        JobInfo.Hdr.QGYAJSO  = 0;
        JobInfo.Hdr.QGYAJSC  = 0;
        JobInfo.Hdr.QGYJQJSO = (%addr(JobInfo.JobQJobSts) - %addr(JobInfo));
        JobInfo.Hdr.QGYJQJSC = 1;

        // Count job only in 'RLS' status
        JobInfo.JobQJobSts   = 'RLS';
        JobInfo.Hdr.QGYJQNO  = (%addr(JobInfo.QualJobQ) - %addr(JobInfo));

        JobInfo.Hdr.QGYJQNC  = 1;
        JobInfo.QualJobQ     = P_JobQ + P_Library;

        KeyFlds(1) = 1004;     // for qualified job queue name
        KeyFlds(2) = 1903;     // for the status of the job on the job queue

        QGYNbrSK = 0;

        OpnLstJobs(JobLst :%size(JobLst) :'OLJB0200'
             :RcvDfn :%size(RcvDfn)
             :QGYLJBLI :50
             :QGYLJBSI :JobInfo :%size(JobInfo)
             :2 :KeyLst :ErrCde);

        DoW ((ErrCde.Hdr.QUSBAvl = 0) and
            ((QGYIC05 = 'C') or (QGYIC05 = 'P')));

            for Count = 1 to QGYRRTN01;
                if Count = 1;
                    JobEntPtr = %addr(JobLst);
                else;
                    JobEntPtr += QGYRL05;
                endif;
                // If given, *ALL, any job found, return found
                if P_JobNam = '*ALL' and JobEnt.QGYJNU00 <> *Blank ;
                   R_FndJobinJobQ = 'Y';
                   leave;
                EndIf;

                // Handle specified job
                if P_JobNam = JobEnt.QGYJNU00;
                   R_FndJobinJobQ = 'Y';
                   leave;
                endif;

            endfor;

            if ( (QGYLS04 = '2') and
                 ( ((QGYFRIB + QGYRRTN01) > QGYTR05) or (QGYRRTN01 = 0) ) ) or
                    (R_FndJobinJobQ = 'Y');
                leave;
            else;
                GetNxtEnt(JobLst :%size(JobLst) :QGYRH05 :QGYLJBLI
                    :50 :(QGYFRIB + QGYRRTN01) :ErrCde);
            endif;
        enddo;

        // Error occured
        if ( (QGYIC05 <> 'C') or (ErrCde.Hdr.QUSBAvl <> 0) );
            dump;
            R_RtnCde = 1;
        endif;

        ClsLst(QGYRH05 :ErrCde);

        *inlr = *on;
        return;

        begsr *inzsr;

            // Initialize Returned Value
            R_RtnCde = 0;
            R_FndJobinJobQ = *blank;

            // Initialize Error QUSEC Data Structure
            QUSBPrv = 0;
            ErrCde.Hdr.QUSBPrv = %size(ErrCde);

        endsr;

      /end-free
