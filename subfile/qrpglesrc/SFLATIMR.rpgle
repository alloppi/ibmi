       ctl-opt option(*nodebugio:*srcstmt:*nounref) dftactgrp(*no) ;

       dcl-f SFLATIMD workstn indds(Dspf) sfile(SFL01:ZRRN) ;

       dcl-ds Dspf qualified ;
         Exit ind pos(3) ;
         PageDown ind pos(25) ;
         PageUp ind pos(26) ;

         SflInds char(4) pos(30) ;
           SflDspCtl ind pos(30) ;
           SflDsp ind pos(31) ;
           SflEnd ind pos(32) ;
           SflClr ind pos(33) ;
       end-ds ;

       dcl-f PERSONP disk keyed ;

       dcl-s SflSize like(ZRRN) inz(10) ;
       dcl-s SavedPosition like(ZPOSITION) ;

       SubfileDown() ;

       dow (1 = 1) ;
         write FOOT01 ;
         exfmt CTL01 ;

         if (Dspf.Exit) ;
           leave ;
         elseif (Dspf.PageDown) ;
           if not(Dspf.SflEnd) ;
             SubfileDown() ;
           endif ;
         elseif (Dspf.PageUp) ;
           SubfileUp() ;
         elseif (ZPOSITION <> SavedPosition) ;
           setll ZPOSITION PERSONR ;
           SubfileDown() ;
           SavedPosition = ZPOSITION ;
         endif ;
       enddo ;

       *inlr = *on ;

       dcl-proc SubfileDown ;
         Dspf.SflInds = '0001' ;
         write CTL01 ;
         Dspf.SflInds = '1000' ;

         for ZRRN = 1 to SflSize ;
           read PERSONR ;
           if (%eof) ;
             Dspf.SflEnd = *on ;
             leave ;
           endif ;

           NAME = %trimr(LASTNAME) + ', ' + FIRSTNAME ;
           write SFL01 ;
         endfor ;

         if (ZRRN > 1) ;
           Dspf.SflDsp = *on ;
         else ;
           return ;
         endif ;

         if not(Dspf.SflEnd) ;
           read PERSONR ;
           if (%eof) ;
             Dspf.SflEnd = *on ;
           else ;
             setll (LASTNAME:FIRSTNAME) PERSONR ;
           endif ;
         endif ;
       end-proc ;

       dcl-proc SubfileUp ;
         chain 1 SFL01 ;
         setll (LASTNAME:FIRSTNAME) PERSONR ;

         for ZRRN = 1 to SflSize ;
           readp PERSONR ;
           if (%eof) ;
             leave ;
           endif ;
         endfor ;

         setll (LASTNAME:FIRSTNAME) PERSONR ;

         SubfileDown() ;
       end-proc ;
