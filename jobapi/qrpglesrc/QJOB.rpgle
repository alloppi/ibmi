       // Demonstrates use of QUSLJOB with the JOBL0200 format (to return select list of fields)
     H
       // Demonstrate the use of QUSLJOB for format QUSL0200 (specific
       // fields)
       //////////////////////////////////////////////////////////////////////
       // Parameter is a qualified job queue name.  This program will search
       // jobs in *JOBQ status on the system, and find the jobs in the
       // specified queue.
       //
       // Example:  CALL QJOB ('QBATCH    QGPL')
       //
       // This will demonstrate the common things that need to be done
       // in order to properly utilize the QUSLJOB format JOBL0200.
       //////////////////////////////////////////////////////////////////////
     H OPTION(*NOSHOWCPY:*NOEXPDDS:*NODEBUGIO:*SRCSTMT)
     H DATFMT(*ISO) TIMFMT(*ISO) DFTACTGRP(*NO)
     H CVTOPT(*VARCHAR:*NODATETIME)
     H THREAD(*SERIALIZE)

     D myEntry         PR                  ExtPgm('QJOB')
     D  parmQueue                          Const LikeDS(qualObj_T)

     D myEntry         PI
     D  parmQueue                          Const LikeDS(qualObj_T)

     D listJobs        PR                  ExtPgm('QUSLJOB')
     D  userSpaceName                      Const LikeDS(qualObj_T)
     D  formatName                    8    Const
     D  jobName                            Const LikeDS(qualJob_T)
     D  status                       10    Const
     D  errStr                             Like(QUSEC)
     D  jobType                       1    Const Options(*NoPass)
     D  nbrFields                    10I 0 Const Options(*NoPass)
     D  fieldKeys                    10I 0 Const Options(*NoPass) Dim(255)

     D CreateUserSpace...
     D                 PR              *   ExtProc('crtUserSpace')
     D  UsrSpcName                   20    Value
     D  UsrSpcDescr                  50    Value
     D  ExtAttr                      10    Value Options(*NoPass)
     D  USEC                               LikeDS(QUSEC) Options(*NoPass)

     D MYSPACENAME     C                            'FINDINJOB QTEMP'
       // List Jobs Field-type constants (LJF_*)

     D LJF_JOBQ_NAME...
     D                 C                   1004

       // IBM-defined fields for QUSLJOB API
     D/COPY QSYSINC/QRPGLESRC,QUSLJOB

       // IBM-defined general structure for header sections of List APIs
     D/COPY QSYSINC/QRPGLESRC,QUSGEN

       // IBM-defined structure for API error management
     D/COPY QSYSINC/QRPGLESRC,QUSEC





     D qualObj_T       DS                  Qualified Based(proto_Only)
     D  obj                          10
     D  lib                          10

     D qualjob_T       DS                  Qualified Based(proto_Only)
     D  job                          10
     D  user                         10
     D  nbr                           6

     D myUSEC          DS                           LikeDS(QUSEC) Inz

     D fieldsArrDS     DS

        // fieldsArr should be dimensioned with exactly the number of
        // fields that will be requested.  Failure to dimension this
        // will cause unexpected results
     D                               10I 0          Inz(LJF_JOBQ_NAME)

     D****************************** 10I 0          Inz(LJF_other_field)

     D  fieldsArr                    10I 0          Dim(1) Overlay(fieldsArrDS)



     D pSpace          S               *
     D I               S             10I 0
     D J               S             10I 0
     D jobQueue        S                   Like(qualObj_T)



       // Define the list header in relocatable storage

     D pJobListHdr     S               *

     D joblistHdr      DS                  LikeDS(QUSH0100) Based(pJobListHdr)



       // Define the job entry (common portion) in relocatable storage
     D pJobEntry       S               *
     D jobEntry        DS                  Based(pJobEntry) Qualified
     D  common                             LikeDS(QUSL020001)
     D  cont                          1



       // Define the individual fields in relocatable storage
       // By present design, this structure will contain all the possible types
       // of field data that we want QUSLJOB to return to us.

     D pFieldEntry     S               *

     D fieldEntry      DS                  Based(pFieldEntry) Qualified
     D  common                             LikeDS(QUSLKF)
     D  data                       4096
     D  queueName                          Overlay(data) Like(qualObj_T)

      /Free



       Reset myUSEC ;

       myUSEC.QUSBPRV = %Size(myUSEC) ;              // Initialize the error struct

       pSpace = createUserSpace(MYSPACENAME          // Create our user space
                              : 'Jobs in job queue (for findInJob)'
                              : 'findInJob'
                              : myUSEC) ;

       If myUSEC.QUSBAVL = *Zero ;                  // No error

          listJobs(MYSPACENAME                      // Get list of jobs
                 : 'JOBL0200'                       // JOBL0200 format
                 : '*ALL      *ALL      *ALL'       // All jobs in system
                 : '*JOBQ'                          // Jobs on jobq only
                 : myUSEC                           // Error structure
                 : 'B'                              // Batch jobs only
                 : %Elem(fieldsArr)                 // Number of fields
                 : fieldsArr                        // Select fields
                  ) ;

       EndIF ;

       If myUSEC.QUSBAVL = *Zero ;                  // No error

          // We have our list of jobs in our user space.  First, we'll need to set
          // our header pointer so that we can access such information as the offset
          // to list data (QUSOLD), the number of matching jobs (QUSNBRLE), et cetera

          pJobListHdr = pSpace ;

          pJobEntry = pSpace + jobListHdr.QUSOLD ;

          For I = 1 to jobListHdr.QUSNBRLE ;

             // Loop through the results, one returned job at a time


             If jobEntry.common.QUSNBRFR = %Elem(fieldsArr) ; // Rtn all flds

                pFieldEntry = %Addr(jobEntry.cont) ;

                For J = 1 to jobEntry.common.QUSNBRFR ;       // Nbr flds rtn

                   Select ;

                      // Deal with each field-type that might be returned.
                      // Each type should have its own WHEN entry and action.

                      When fieldEntry.common.QUSKF = LJF_JOBQ_NAME ;

                         jobQueue = fieldEntry.queueName ;    // Save jobq name

                      // When fieldEntry.common.QUSKF = LJF_other_field ; ...

                   EndSL ;

                   pFieldEntry += fieldEntry.common.QUSLFIR ; // Point to next field

                EndFOR ;

                If jobQueue = parmQueue ;



                    // Do something with the job here.
                    // Job name is jobEntry.common.QUSJNU00
                    // User name is jobEntry.common.QUSUNU00
                    // Job number is jobEntry.common.QUSJNBRU00

                EndIF ;

             EndIF ;

             pJobEntry += jobListHdr.QUSSEE ;                // Point to next job

          EndFOR ;

       EndIF ;

       *INLR = *On ;

       Return ;



      /End-free


     P CreateUserSpace...
     P                 B                   Export

      *********************************************************************
      * Create a user space                                               *
      *                                                                   *
      * This routine will create a user space, or will modify an existing *
      * one to be extendable.  This procedure returns a pointer to the    *
      * user space.                                                       *
      *                                                                   *
      * Parameters:                                                       *
      *   UserSavFSpace (20 bytes: first 10 are object; next 10 are lib)  *
      *   Text description (50 bytes)                                     *
      *********************************************************************

     D CreateUserSpace...
     D                 PI              *
     D  UsrSpcName                   20    Value
     D  UsrSpcDescr                  50    Value
     D  ExtAttr                      10    Value Options(*NoPass)
     D  UserUSEC                           LikeDS(QUSEC) Options(*NoPass)

     D UsrSpcExtAttr   S             10    Inz('"WorkArea"')
     D SpcPointer      S               *
     D ReturnLib       S             10

     D MyUSEC          DS                  LikeDS(QUSEC) Inz

      *********************************************************************
      * IBM's create a user space API
      *********************************************************************

     D IBMCrtUsrSpc...
     D                 PR                  ExtPgm('QUSCRTUS')
     D   SavFSpace                   20    Const
     D   Attr                        10    Const
     D   InlSize                     10I 0 Const
     D   InlValue                     1    Const
     D   Authority                   10    Const

     D   TextDescr                   50    Const
     D   Replace                     10    Const
     D   ErrorParm                         Like(QUSEC)

      *********************************************************************
      * IBM API QUSCUSAT will change a user space's attributes.  We use
      * this to make a user space extendable
      *********************************************************************
     D ChgUserSpaceAttr...
     D                 PR                  ExtPgm('QUSCUSAT')
     D   RtnLib                      10
     D   SpaceName                   20    Const
     D   AttrList                 32767    Const Options(*VarSize)
     D   ErrorParm                         Like(QUSEC)

      *********************************************************************
      * Retrieve Pointer to a User Space object
      *********************************************************************

     D RtvPtrUserSpace...
     D                 PR                  ExtPgm('QUSPTRUS')
     D   SavFSpace                   20    Const
     D   ReturnPtr                     *
     D   ErrorParm                         Like(QUSEC)

     D* Structure to change the USRSPC attr to extendable

     D ChangeAttrs     DS

      * Description field-by-field
      *  Number_Attrs = Number of attributes (1)

      *  1-element array of attribute definitions as follows:
      *     Attr_Key1 = Identify attribute to change (3=Extendable attr.)
      *     Attr_Siz1 = Length of the attribute itself (1)
      *     Attr_Dta1 = New value for this attribute ('1' = "yes")

     D   Number_Attrs                10I 0 Inz(1)
     D   Attr_Key1                   10I 0 Inz(3)
     D   Attr_Siz1                   10I 0 Inz(1)
     D   Attr_Dta1                    1    Inz('1')

      /Free





       //******************************************************************
       // Create our user space                                           *
       //                                                                 *
       // Because we don't know how big the user spaces used by this pgm  *
       // need to be, we'll create them small and make them extendable.   *
       // API QUSCRTUS will create the User Space objects and QUSCHGUS    *
       // will allow us to change attributes to extendable.
       //***************************************************************

       MyUSEC.QUSBPRV = %Size(MyUSEC) ;

       If %Parms >= 3 And ExtAttr <> *Blanks ;
          UsrSpcExtAttr = ExtAttr ;
       EndIF ;

       // Before we create the space, let's see if it already exists
       // (in which case we will reuse it).  Attempt to obtain a pointer
       // to our user space.  If successful, we do not need to create



       RtvPtrUserSpace(UsrSpcName   : SpcPointer : MyUSEC) ;

       If (MyUSEC.QUSBAVL > *Zero) ;     // Gotta make a new one

          MyUSEC.QUSBAVL = *Zero ;

          // Create our user space

          IBMCrtUsrSpc(UsrSpcName        // User space name
                     : UsrSpcExtAttr     // Extended Attribute
                     : 1024              // INLSIZ(1024)
                     : x'00'             // INLVAL(X'00')
                     : '*USE'            // AUT(*USE)
                     : UsrSpcDescr       // User space description
                     : '*NO'             // REPLACE(*NO)
                     : MyUSEC
                      ) ;

          If (MyUSEC.QUSBAVL = *Zero) ;

             // Change user space to be extendable

             ChgUserSpaceAttr(ReturnLib: UsrSpcName: ChangeAttrs: MyUSEC) ;

          EndIF ;

          // Retrieve pointer to the user space

          RtvPtrUserSpace(UsrSpcName : SpcPointer : MyUSEC) ;

       EndIf ;

       If %Parms >= 4 ;
          UserUSEC = MyUSEC ;
       EndIF ;



       // If any error occurred, pass it on to the user (via Parm #4)



       If (MyUSEC.QUSBAVL > *Zero) ;

          spcPointer = *NULL ;

       EndIF ;

       Return SpcPointer ;



      /End-free

     P CreateUserSpace...
     P                 E

