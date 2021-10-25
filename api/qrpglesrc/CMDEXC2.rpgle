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

     DPgmDs           SDS                  qualified
     D Proc_Name         *PROC                                                  Procedure Name
     D Pgm_Status        *STATUS                                                Status Code
     D Prv_Status             16     20S 0                                      Previous Status Code
     D Line_Nbr               21     28                                         Source Line No.
     D Routine           *ROUTINE                                               Exception Subroutine
     D Parms             *PARMS                                                 No. of Parameters
     D Excp_Type              40     42                                         Exception Type
     D Excp_Num               43     46                                         Exception No.
     D Pgm_Lib                81     90                                         Library
     D Excp_Data              91    170                                         Retrieved Exception
     D Excp_Id               171    174                                         Id of Exception
     D Date                  191    198                                         'Date' Job enter
     D Year                  199    200S 0                                      'Century' Job enter
     D Last_File             201    208                                         'File last' Operatio
     D File_Info             209    243                                         Status of File
     D Job_Name              244    253                                         Job Name
     D User                  254    263                                         User Profile
     D Job_Num               264    269S 0                                      Job Number
     D Job_Date              270    275S 0                                      Date Job Entered
     D Run_Date              276    281S 0                                      Date program Run
     D Run_Time              282    287S 0                                      Date Program Run
     D Crt_Date              288    293                                         Compile Date
     D Crt_Time              294    299                                         Compile Time
     D Cpl_Level             300    303                                         Level of Compile
     D Src_File              304    313                                         Source File Name
     D Src_Lib               314    323                                         Source Library
     D Src_Mbr               324    333                                         Source Member
     D Proc_Pgm              334    343                                         Program Module
     D Proc_Mod              344    353                                         Module Procedure

     D QCmdExc         PR                  extpgm('QCMDEXC')
     D                              132    options(*varsize) const
     D                               15  5 const

     D ErrorMsg        S              7
     D ErrorTxt        S             80
     D ShowMsg         S             52

     D CmdString       s            132
     D CmdLength       s             15  5

      * Option 2 (Use 'E' operation extender and show message)
      /free
         CmdString = 'CLRPFM TESTFILE';
         callp(e) QCmdExc(CmdString: %len(CmdString));
         if (%error) ;
            ErrorMsg = PgmDs.Excp_Type + PgmDs.Excp_Num;

            if (ErrorMsg = 'CPF3142');                      // File not found
              ErrorTxt   = PgmDs.Excp_Data;
              ShowMsg    = ErrorMsg + ' ' + %subst(ErrorTxt: 1: 44);
              Dsply ShowMsg;
            endif ;

         endif ;

         *InLr = *On;
      /end-free
