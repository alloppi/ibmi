      * Capturing QCMDEXC error codes
      *
      * Refer: https://www.rpgpgm.com/2013/10/capturing-qcmdexc-error-codes.html
      *
      * QCMDEXC is used to execute AS/400 command, takes 2 parameters
      *    - Command string
      *    - Command string length
      *
      * QCMDEXC API: https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_74/apis/qcmdexc.htm
      *

     D PgmDs         ESDS                  extname(PSDSF)
     D                                       qualified
     D QCmdExc         PR                  extpgm('QCMDEXC')
     D                              132    options(*varsize) const
     D                               15  5 const

     D ErrorMsg        S              7
     D ErrorTxt        S             80
     D ShowMsg         S             52

     D CmdString       s            132
     D CmdLength       s             15  5

      * Option 3 (Use 'E' operation extender and show message)
      /free
         CmdString = 'CLRPFM TESTFILE';

         Monitor;
            QCmdExc(CmdString: %len(CmdString));

         On-Error;
            ErrorMsg = PgmDs.ExcptTyp + PgmDs.ExcptNbr;
            if (ErrorMsg = 'CPF3142');                      // File not found
              ErrorTxt   = PgmDs.RtvExcptDt;
              ShowMsg    = ErrorMsg + ' ' + %subst(ErrorTxt: 1: 44);
              Dsply ShowMsg;
            endif ;

         endmon;

         *InLr = *On;
      /end-free
