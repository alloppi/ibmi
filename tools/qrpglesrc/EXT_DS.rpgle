      * Refer tp:
      * http://www.rpgpgm.com/2013/12/system-as-alternative-to-qcmdexc.html
      *
      /Copy Qcpysrc,PSCY01R
      *
      * Externally descripted DS is under construction
     D*PgmDs         ESDS                  extname(RPG4DS)
     D*                                      qualified
      * Tempoary using a Program descripted DS for testing
     D PgmDs          SDS                    qualified
     D EXCPTTYP               40     42
     D EXCPTNBR               43     46
     D RTVEXCPTDT             91    190
      *
     D QCmdExc         PR                  extpgm('QCMDEXC')
     D                              132    options(*varsize) const
     D                               15  5 const
     D CmdString       S            132
     D ErrorMsg        S              7
     D ErrorTxt        S             80
      /free
         CmdString = 'CLRPFM TESTFILE' ;
         callp(e) QCmdExc(CmdString:%len(CmdString)) ;
         if (%error) ;
            ErrorMsg = PgmDs.ExcptTyp + PgmDs.ExcptNbr ;
            if (ErrorMsg = 'CPF3142') ;  //File not found
              ErrorTxt = PgmDs.RtvExcptDt ;
         //  .
         //  .
            endif ;
         endif ;
      /end-free
      *
     C     $Exit         Tag
     C                   Eval      *INLR = *On
     C                   Return
