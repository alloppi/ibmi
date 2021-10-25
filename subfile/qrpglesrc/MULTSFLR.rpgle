       ctl-opt option(*nodebugio:*srcstmt)
                 dftactgrp(*no) ;

       dcl-f MULTSFLD workstn indds(Dspf)
                        sfile(SFL01:Z1RRN) sfile(SFL02:Z2RRN) ;

       dcl-ds Dspf qualified ;
         Exit ind pos(3) ;

         Sfl1DspCtl ind pos(30) ;
         Sfl1Dsp ind pos(31) ;

         Sfl2DspCtl ind pos(32) ;
         Sfl2Dsp ind pos(33) ;
         Sfl2Fold ind pos(2) ;
         Sfl2Mode ind pos(35) ;
       end-ds ;

       // Z1SCREEN = %trimr(Pgm.ProcNme) + '-1' ;

       LoadSubfiles() ;

       dow (1 = 1) ;
         write FOOTER ;
         write CTL01 ;
         exfmt CTL02 ;

         if (Dspf.Exit) ;
           leave ;
         endif ;
       enddo ;

       *inlr = *on ;

       dcl-proc LoadSubfiles ;
         dcl-c MaxSfl 30 ;  // Maximum records in subfile

         SflSiz01 = 30 ;
         Dspf.Sfl1DspCtl = *off ;
         Dspf.Sfl1Dsp = *off ;
         write CTL01 ;
         Dspf.Sfl1DspCtl = *on ;
         Dspf.Sfl1Dsp = *on ;
         F2 = 1 ;
         for Z1RRN = 1 to MaxSfl ;
           Z1LINE = 'Subfile No. 1  Record ' + %char(Z1RRN) ;
           write SFL01 ;
         endfor ;

         Dspf.Sfl2DspCtl = *off ;
         Dspf.Sfl2Dsp = *off ;
         write CTL02 ;
         Dspf.Sfl2DspCtl = *on ;
         Dspf.Sfl2Dsp = *on ;

         Mode = '1';
         if (Dspf.Sfl2Fold) ;
           Dspf.Sfl2Mode = Mode ;
         endif ;

         for Z2RRN = 1 to MaxSfl ;
           Z2LINE = '***** Subfile No. 2  Record ' + %char(Z2RRN)
                  + ' Line 1' + '****';
           Z2LINE2= 'Subfile No. 2  Record ' + %char(Z2RRN) + ' Line 2';
           Z2LINE3= 'Subfile No. 2  Record ' + %char(Z2RRN) + ' Line 3';
           write SFL02 ;
         endfor ;
       end-proc ;
