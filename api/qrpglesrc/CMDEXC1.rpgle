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

     D CmdString       s            132
     D CmdLength       s             15  5

      * Method 1 (Not Retrieve Error Description)
      /free
         CmdString = 'CLRPFM TESTFILE';
         CmdLength = 15 ;
      /end-free

     C                   Call(e)   'QCMDEXC'
     C                   Parm                    CmdString
     C                   Parm                    CmdLength

      /free
         If (%error);
           Dsply 'QCMDEXC Command Error';
         Endif;

         *InLr = *On;
      /end-free

