      *===================================================================*
      * Program name: GETJOBSTSR                                          *
      *              - Return first found status with given subsystem/Job *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2017/03/20 Alan       AC              New                         *
      *===================================================================*
     H Debug(*Yes)
      *
      * CrtUsrSpc: Create User Space for OS/400 API's
      *
     d QUSCRTUS        pr                  extpgm('QUSCRTUS')
     d   UsrSpc                      20A   const
     d   ExtAttr                     10A   const
     d   InitialSize                 10I 0 const
     d   InitialVal                   1A   const
     d   PublicAuth                  10A   const
     d   Text                        50A   const
     d   Replace                     10A   const
     d   ErrorCode                32766A   options(*nopass: *varsize)
      *
      * --- Prototype for API Retrive User Space
      *
     d QUSRTVUS        pr                  extpgm( 'QUSRTVUS' )
     d   QRtvUserSpace...
     d                               20
     d   QRtvStartingPosition...
     d                                8b 0
     d   QRtvLengthOfData...
     d                                8b 0
     d   QRtvReceiverVariable...
     d                            32048
     d   QRtvError...
     d                              256

      * --- Prototype for API Retrive List Job
      *
     d QUSLJOB         pr                  extpgm( 'QUSLJOB' )
     d   QJobUserSpace...
     d                               20
     d   QJobFormatName...
     d                                8
     d   QJobJobName...
     d                               26
     d   QFldStatus...
     d                               10
     d   QFldError...
     d                              256
     d   QJobType...
     d                                1
     d   QNbrFldRtn...
     d                                8b 0
     d   QKeyFldRtn...
     d                                8b 0 dim( 100 )
      *
     d qcmdexc         pr                  extpgm( 'QCMDEXC' )
     d   os400_cmd                 2000A   options( *varsize ) const
     d   cmdlength                   15P 5                     const
      *
      * Defined variables
      *
     d size            s             10I 0
     d UsrSpcName      s             20    inz( 'GETJOBSTSRQTEMP     ' )
      ******************************************************************
     dQUSA0100         DS
     d QUsrSpcOffset...
     d                         1      4B 0
     d QUsrSpcEntries...
     d                         9     12B 0
     d QUsrSpcEntrieSize...
     d                        13     16B 0
     dLJOBINPUT        ds                           qualified
     d  JobName...
     d                         1     10
     d  UserName...
     d                        11     20
     d  JobNumber...
     d                        21     26
     d  Status...
     d                        27     36
     d  UserSpace...
     d                        37     46
     d  UserSpaceLibrary...
     d                        47     56
     d  Format...
     d                        57     64
     d  JobType...
     d                        65     65
     d  Reserved01...
     d                        66     68
     d  Reserved02...
     d                        69     72B 0
      *
     dLJOB100          ds                           qualified
     d  JobName...
     d                         1     10
     d  UserName...
     d                        11     20
     d  JobNumber...
     d                        21     26
     d  InternalJobId...
     d                        27     42
     d  Status...
     d                        43     52
     d  JobType...
     d                        53     53
     d  JobSubType...
     d                        54     54
     d  Reserved01...
     d                        55     56
      *
     dLJOB200          ds                           qualified
     d  JobName...
     d                         1     10
     d  UserName...
     d                        11     20
     d  JobNumber...
     d                        21     26
     d  InternalJobId...
     d                        27     42
     d  Status...
     d                        43     52
     d  JobType...
     d                        53     53
     d  JobSubType...
     d                        54     54
     d  Reserved01...
     d                        55     56
     d  JobInfoStatus...
     d                        57     57
     d  Reserved02...
     d                        58     60
     d  NumberOfFieldsReturned...
     d                        61     64B 0
     d  ReturnedData...
     d                        65   1064
      *
     dLJOB200KEY       ds                           qualified
     d  KeyNumber01...
     d                         1      4B 0
     d  NumberOfKeys...
     d                         5      8B 0
      *
     dLJOBKEYINFO      ds                           qualified
     d  LengthOfInformation...
     d                         1      4b 0
     d  KeyField...
     d                         5      8b 0
     d  TypeOfData...
     d                         9      9
     d  Reserved01...
     d                        10     12
     d  LengthOfData...
     d                        13     16B 0
     d  KeyData...
     d                        17   1016
      *
      *  APIErrDef     Standard API error handling structure.                  *
      *
     dQUSEC            DS
     d  ErrorBytesProvided...
     d                         1      4B 0
     d  ErrorBytesAvailble...
     d                         5      8b 0
     d  ErrorExceptionId...
     d                         9     15
     d  ErrorReserved...
     d                        16     16
      *
     dAPIError         DS
     d APIErrorProvied...
     d                                     LIKE( ErrorBytesProvided )
     d                                     INZ(%LEN( APIError ) )
     d APIErrorAvailble...
     d                                     LIKE( ErrorBytesAvailble )
     d APIErrorMessageID...
     d                                     LIKE( ErrorExceptionId )
     d APIErrorReserved...
     d                                     LIKE( ErrorReserved )
     d APIErrorInformation...
     d                              240A
      *-----------------------------------------------------------------
      * program status dataarea
      *-----------------------------------------------------------------
     d PgmSts         SDS
     d   P1User              254    263
     d   W1Program       *PROC
      *--------------------------------------------------------------*
      * work fields                                                  *
      *--------------------------------------------------------------*
     d Variables       ds
     d   Q                            1    inz( '''' )
     d   Count                       15  0 inz(  0   )
     d   KeyCount                    15  0 inz(  0   )
     d   EndPos                      15  0 inz(  0   )
     d   JobbStatus                   4    inz( ' '  )
     d   Subsystem                   20    inz( ' '  )
     d   ReturnCode                   1    inz( ' '  )
     d   FormatName                   8    inz( ' ' )
     d   QualifedJobName...
     d                               26    inz( ' ' )
     d   JobStatus                   10    inz( ' ' )
     d   JobType                      1    inz( ' ' )
     d   NbrOfFldRtn                  8B 0 inz(  0  )
     d   KeyFldRtn                    8B 0 inz(  0  ) dim( 100 )
     d   StartingPosition...
     d                                8B 0 inz(  0  )
     d   LengthOfData...
     d                                8B 0 inz(  0  )
     d   KeyStartingPosition...
     d                                8B 0 inz(  0  )
     d   KeyLengthOfData...
     d                                8B 0 inz(  0  )
     d   ReceiverVariable...
     d                            32048
     d   True                         1    inz( *on  )
     d   False                        1    inz( *off )
      * Input / Out Parameter
     DP_Sbs            S             10A
     DP_Job            S             10A
     DR_Status         S              4A
      *
      *****************************************************************
      * Mainline logic
      *****************************************************************
     C     *Entry        Plist
     C                   Parm                    P_Sbs
     C                   Parm                    P_Job
     C                   Parm                    R_Status

      /free

       //
       // Create a user space
       //
          size = 10000;
          R_Status = *Blank ;
       //
       // Delete user space
       //
         QUSDLTUS(UsrSpcName: APIError);
       //
       // Object Not found
        if APIErrorMessageID = 'CPF2105';
          APIErrorMessageID = *Blank;
        endif;

       // Create a user space
         QUSCRTUS(UsrSpcName: 'USRSPC': size: x'00': '*ALL':
          'Temp User Space for  QUSLJOB API':  '*YES': APIError);

       exsr CheckStatusOfJob;
       //
       // Delete user space
       //
         QUSDLTUS(UsrSpcName: APIError);
       //
       // End of Program
       //
         *inlr = *on;
       //
       // -------------------------------------------------------------
       // check status of an job
       // -------------------------------------------------------------
       begsr CheckStatusOfJob;

       // run API to fill user space with information about all iSeries job

       FormatName = 'JOBL0200';
       // QualifedJobName = '*ALL      ' + '*ALL      ' + '*ALL  ';
       QualifedJobName = P_Job + '*ALL      ' + '*ALL  ';
       JobStatus = '*ACTIVE';
       JobType = '*';
       NbrOfFldRtn = 2;
       KeyFldRtn( 1 ) = 0101;
       KeyFldRtn( 2 ) = 1906;
        callp QUSLJOB( UsrSpcName : FormatName  : QualifedJobName :
                       JobStatus  : APIError    :
                       JobType    : NbrOfFldRtn : KeyFldRtn         );

         // if error message from the retrieve job API then dump program
        if APIErrorMessageID <> ' ';
          dump '0001';
          ReturnCode = True;
          leavesr;
        endif;

        // run API to get user space attribute

        StartingPosition = 125;
        LengthOfData = 16;
        callp QUSRTVUS( UsrSpcName   : StartingPosition  :
                        LengthOfData : ReceiverVariable  :
                        APIError                           );
        QUSA0100 = ReceiverVariable;
         // if error message from the retrieve user space API then dump program

        if APIErrorMessageID <> ' ';
          dump '0002';
          ReturnCode = True;
          leavesr;
        endif;
        // preperation to read from user space

        StartingPosition = QUsrSpcOffset + 1;
        LengthOfData = QUsrSpcEntrieSize;

        // read from user space

        for count = 1 to QUsrSpcEntries;
          callp QUSRTVUS( UsrSpcName   : StartingPosition  :
                          LengthOfData : ReceiverVariable  :
                          APIError                           );
          LJOB200 = ReceiverVariable;
          if APIErrorMessageID <> ' ';
            dump '0003';
            ReturnCode = True;
            leavesr;
          endif;
          // check status of job
          JobbStatus = ' ';
          Subsystem = ' ';
          LJobKeyInfo = LJob200.ReturnedData;
          KeyStartingPosition = 1;
          KeyLengthOfData = LJobKeyInfo.LengthOfInformation;
          for keycount = 1 to LJob200.NumberOfFieldsReturned;
            LJobKeyInfo = %subst( LJob200.ReturnedData :
                                  KeyStartingPosition :
                                  KeyLengthOfData );
            KeyLengthOfData = LJobKeyInfo.LengthOfInformation;
            LJobKeyInfo = %subst( LJob200.ReturnedData :
                                  KeyStartingPosition :
                                  KeyLengthOfData );
            Endpos = LJobKeyInfo.LengthOfData;
            if     LJobKeyInfo.KeyField = 0101;
               JobbStatus = %subst( LJobKeyInfo.KeyData : 1 :  Endpos );
            elseif LJobKeyInfo.KeyField = 1906;
               Subsystem = %subst( LJobKeyInfo.KeyData : 1 : Endpos );
            endif;
            KeyStartingPosition = KeyStartingPosition + KeyLengthOfData;
          endfor;
          // variable email address
          // if Jobbstatus = 'MSGW';
          //             '12345678901234567890
          // Subsystem = 'QUSRWRK   QSYS      '
          // Subsystem = %trim( %subst( Subsystem : 11 : 10 ) ) + '/' +
          //             %trim( %subst( Subsystem :  1 : 10 ) );
             If    %subst(Subsystem :1 : 10) = P_Sbs    ;
                   R_Status = JobbStatus ;
                   leavesr;
             EndIf;
          StartingPosition = StartingPosition + LengthOfData;

        endfor;

        endsr;
