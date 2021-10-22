       // Accessing Job Queue Entries API
       // Refer: http://www.mcpressonline.com/programming/apis/the-api-corner-accessing-job-queue-entries

       // API Used: Open List of Jobs (QGYOLJOB) Used to generate a list of jobs
       //           Get List Entries (QGYGTLE) Used to access additional jobs that were selected for the QGYOLJOB API
       //           Close List (QGYCLST) Used to close the generated list of jobs after processing all entries

     h dftactgrp(*no)

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

     d RunCmd          pr                  extpgm('QCAPCMD')
     d Cmd                         4096a   const options(*varsize)
     d LenCmd                        10i 0 const
     d CtlBlck                     4096a   const options(*varsize)
     d LenCtlBlck                    10i 0 const
     d FmtCtlBlck                     8a   const
     d ChgdCmd                        1a   options(*varsize)
     d LenAvlChgdCmd                 10i 0 const
     d LenRtnChgdCmd                 10i 0
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

     d Cmd             s           4096a
     d Count           s              5u 0
     d JobLst          s           4096a
     d NotUsedChr      s              1a
     d NotUsedInt      s             10i 0
     d RcvDfn          s           4096a

      /copy qsysinc/qrpglesrc,qcapcmd
      /copy qsysinc/qrpglesrc,qgyoljob
      /copy qsysinc/qrpglesrc,qusec

      /free

        // Find jobs in held status

        // Data Structure of QGYLJBJS
        JobInfo.Hdr.QGYJN07  = '*ALL';
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
        JobInfo.JobQJobSts   = 'RLS';
        JobInfo.Hdr.QGYJQNO  = (%addr(JobInfo.QualJobQ) - %addr(JobInfo));

        JobInfo.Hdr.QGYJQNC  = 1;
        JobInfo.QualJobQ     = 'BOCJOBQ   QGPL      ';

        KeyFlds(1) = 1004; // for qualified job queue name
        KeyFlds(2) = 1903; // for the status of the job on the job queue

        QGYNbrSK = 0;

        OpnLstJobs(JobLst :%size(JobLst) :'OLJB0200'
             :RcvDfn :%size(RcvDfn)
             :QGYLJBLI :50
             :QGYLJBSI :JobInfo :%size(JobInfo)
             :2 :KeyLst :ErrCde);


        dow ((ErrCde.Hdr.QUSBAvl = 0) and
            ((QGYIC05 = 'C') or (QGYIC05 = 'P')));

            for Count = 1 to QGYRRTN01;
                if Count = 1;
                    JobEntPtr = %addr(JobLst);
                else;
                    JobEntPtr += QGYRL05;
                endif;

                //  Cmd = 'RlsJob Job(' +
                //      JobEnt.QGYJNbrU00 + '/' +
                //      %trimr(JobEnt.QGYUNU00) + '/' +
                //      %trimr(JobEnt.QGYJNU00) + ')';

                //  RunCmd(Cmd :%len(%trimr(Cmd))
                //      :QCAP0100 :%size(QCAP0100) :'CPOP0100'
                //      :NotUsedChr :0 :NotUsedInt :ErrCde);

            endfor;

            if ((QGYLS04 = '2') and
                (((QGYFRIB + QGYRRTN01) > QGYTR05) or
                (QGYRRTN01 = 0)));
            leave;

            else;
                GetNxtEnt(JobLst :%size(JobLst) :QGYRH05 :QGYLJBLI
                    :50 :(QGYFRIB + QGYRRTN01) :ErrCde);
            endif;
        enddo;

        if ((QGYIC05 <> 'C') or (ErrCde.Hdr.QUSBAvl <> 0));
            // Failure encountered
            dsply ErrCde.Hdr.QUSEI;
        endif;

        ClsLst(QGYRH05 :ErrCde);

        *inlr = *on;
        return;

        begsr *inzsr;

            // Initial Data Structure for Error QUSEC
            QUSBPrv = 0;
            ErrCde.Hdr.QUSBPrv = %size(ErrCde);

            // Initial Data Structure for API QCAPCMD
            //  QCAP0100 = *loval;
            //  QCACMDPT = 0;
            //  QCABCSDH = '0';
            //  QCAPA = '0';
            //  QCACMDSS = '0';

        endsr;

      /end-free
