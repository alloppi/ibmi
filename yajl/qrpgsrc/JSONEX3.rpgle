      *====================================================================*
      * Program name: JSONEX3                                              *
      * Purpose.....: JSON and REST API Example with OAuth authentication  *
      *                                                                    *
      * Description : Parasing JSON file                                   *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2021/07/23 Alan       AC              New Develop                  *
      *====================================================================*

     H Debug(*Yes)
     H DftActGrp(*No) ActGrp(*Caller) Option(*SrcStmt) DecEdit('0.')
     H BndDir('YAJL/YAJL')

     FJSOLPF01  IF A E           K Disk     UsrOpn Commit                       Order List Parsed Fi
     FJSTUEF01  IF A E           K Disk     UsrOpn Commit                       TU Parsed File

     FJSRNPF01  IF A E           K Disk     UsrOpn Commit                       Result Notice Parasd
     FJSSRPF01  IF A E           K Disk     UsrOpn Commit                       Success Result Paras
     FJSCFPF01  IF A E           K Disk     UsrOpn Commit                       Confirm Parasd File

      * Parameters
     D P_ApiType       s              1a

      /include YAJL/QRPGLESRC,yajl_h

     D loanAccount_t   ds                  qualified
     D                                     template
     D  zaSettleCount                10i 0 Inz(*hival)
     D  extCustId                    64a
     D  zaUnSettleAmt                10  4 Inz(*hival)
     D  zaUnSettleCnt                10i 0 Inz(*hival)

     D
     D individInfo_t   ds                  qualified
     D                                     template
     D  birthDay                     10a
     D  academicLevel                10i 0 Inz(*hival)
     D  idType                       10a
     D  nationality                  10a
     D  gender                        2a
     D  livTogether                  10i 0 Inz(*hival)
     D  martialSts                   10i 0 Inz(*hival)

     D occupatInfo_t   ds                  qualified
     D                                     template
     D  income                       16  2 Inz(*hival)
     D  commenceDate                 10a
     D  occupatType                  10a
     D  employType                    7a
     D  paymentMethod                10a
     D  declareIncome                16  2 Inz(*hival)
     D  jobType                      10a

     D tuData_t        ds                  qualified
     D                                     template
     D  tuef                      65535a   varying inz(' ')

     D checkInfo_t     ds                  qualified
     D                                     template
     D  income                        2a
     D  address                       2a
     D  telephone                     2a

     D residInfo_t     ds                  qualified
     D                                     template
     D  residPeriod                   5a
     D  residenceType                10a
     D  withHomeTel                   1a
     D  livTogether                  10i 0 Inz(*hival)
     D  residenceOwn                 50a
     D

     D body_t          ds                  qualified
     D                                     template
     D  serverTime                   20a
     D  retCode                       6a
     D  retMsg                       64a
     D  values                             likeds(value_t) dim(50)
     D  value                        10a

     D value_t         ds                  qualified
     D                                     template
     D  businessNo                   64a
     D  orderNo                      64a
     D  expiryDate                   10a
     D  loanAccount                        likeds(loanAccount_t)
     D  individInfo                        likeds(individInfo_t)
     D  occupatInfo                        likeds(occupatInfo_t)
     D  tuData                             likeds(tuData_t)
     D  checkInfo                          likeds(checkInfo_t)
     D  residInfo                          likeds(residInfo_t)
      *
      * for successResults API
     D  drawdownDate                 10a
     D  drawdownTime                  8a
     D  amount                        8  2 Inz(*hival)
     D  tenor                        10i 0 Inz(*hival)
     D  monthlyRate                   4  2 Inz(*hival)
     D  annualRate                    4  2 Inz(*hival)
     D  monthRepayAmt                 4  2 Inz(*hival)
      *
      * for confirm API
     D  orderStatus                   1a
     D  retCode                       6a
     D  retMsg                       64a

     D header_t        ds                  qualified
     D                                     template
     D  resCode                       6a
     D  resMsg                       64a
     D  timestamp                    14  0

     D result          ds                  qualified
     D  header                             likeds(header_t)
     D  body                               likeds(body_t)

     D i#              s             10i 0
     D j#              s             10i 0
     D k#              s             10i 0
     D m#              s             10i 0
     D errMsg          s            500a   varying inz('')

     D docNode         s                   like(yajl_val)
     D headerNode      s                   like(yajl_val)
     D bodyNode        s                   like(yajl_val)
     D valuesNode      s                   like(yajl_val)
     D loanAccountNod  s                   like(yajl_val)
     D individInfoNod  s                   like(yajl_val)
     D residInfoNode   s                   like(yajl_val)
     D occupatInfoNod  s                   like(yajl_val)
     D checkInfoNode   s                   like(yajl_val)
     D tuDataNode      s                   like(yajl_val)
     D node            s                   like(yajl_val)
     D val             s                   like(yajl_val)
     D subVal          s                   like(yajl_val)
     D key             s             50a   varying
     D subKey          s             50a   varying
     D elements        s              5p 0

     D w1Path          c                   const('/home/alan/jsonex/')
     D w1RcvDtlF       S             64a   varying

     D w1MchDate       s               d
     D w1TimStp        s               z
     D w1tuef          s          65535a
     D w1tuefLen       s              6p 0
     D w1Pos           s              6p 0
     D w1ValCount      s              6p 0
     D ENDTUEF         s              7a
     D ENDTUEFLen      s              2p 0
     D TUEFLen         s              6p 0 inz(32650)

     D w1OLPTSN        s                   like(OLPTSN)
     D w1RNPTSN        s                   like(RNPTSN)
     D w1SRPTSN        s                   like(SRPTSN)
     D w1CfPTSN        s                   like(CFPTSN)

      * Parameter for QCMDEXC
     D I_Cmd           S            500a
     D I_CmdLen        S             15p 5
      *
     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  Cmd                         500a   const
     D  Cmd_Len                      15p 5 const
      *
     c     *entry        plist
     c                   parm                    P_APIType

      /free

       // P_API_Type:
       //   2=order/orderList
       //   3=risk/resultNotice
       //   4=order/successResults
       //   5=order/confirm
       select;
       when P_APIType = '2';
         exsr OLInitRef;
       when P_APIType = '3';
         exsr RNInitRef;
       when P_APIType = '4';
         exsr SRInitRef;
       when P_APIType = '5';
         exsr CfInitRef;
       endsl;

       docNode = yajl_stmf_load_tree( w1RcvDtlF: errMsg );
       if errMsg <> *blank;
         // handle error
         dsply 'Ooppppssss - JSON file load problem!';
         return;
       endif;

       clear result;
       reset result;

       //-------------------------------
       // Parse 1st level : header, body
       //-------------------------------
       headerNode = YAJL_OBJECT_FIND( docNode: 'header' );
       if headerNode = *null;
         dsply 'JSON header element not found!';
         return;
       endif;

       bodyNode = YAJL_OBJECT_FIND( docNode: 'body' );
       if bodyNode = *null;
         dsply 'JSON body element not found!';
         return;
       endif;

       //--------------------------------
       // Parse 2nd level : inside header
       //--------------------------------
       node = YAJL_OBJECT_FIND( headerNode: 'resCode' );
       if node = *null;
         dsply 'JSON resCode element not found!';
         return;
       else;
         result.header.resCode = YAJL_GET_STRING( node );
       endif;

       node = YAJL_OBJECT_FIND( headerNode: 'resMsg' );
       if node = *null;
         dsply 'JSON resMsg element not found!';
         return;
       else;
         result.header.resMsg = YAJL_GET_STRING( node );
       endif;

       node = YAJL_OBJECT_FIND( headerNode: 'timestamp' );
       if node = *null;
         dsply 'JSON timestamp element not found!';
         return;
       else;
         result.header.timestamp = YAJL_GET_NUMBER( node );
       endif;

       //--------------------------------
       // Parse 2nd level : inside body
       //--------------------------------
       node = YAJL_OBJECT_FIND( bodyNode: 'serverTime' );
       if node = *null;
         dsply 'JSON serverTime element not found!';
         return;
       else;
         result.body.serverTime = YAJL_GET_STRING( node );
       endif;

       node = YAJL_OBJECT_FIND( bodyNode: 'retCode' );
       if node = *null;
         dsply 'JSON retCode element not found!';
         return;
       else;
         result.body.retCode = YAJL_GET_STRING( node );
       endif;

       node = YAJL_OBJECT_FIND( bodyNode: 'retMsg' );
       if node = *null;
         dsply 'JSON retMsg element not found!';
         return;
       else;
         result.body.retMsg = YAJL_GET_STRING( node );
       endif;

       valuesNode = YAJL_OBJECT_FIND( bodyNode: 'value' );
       if valuesNode = *null;
         // dsply 'JSON value element not found!';
         // return;
       else;
         elements = YAJL_array_size( valuesNode );
         if elements > %elem( result.body.values );
           dsply ('Can only process ' + %char( %elem( result.body.values ) ) +
             ' values - JSON contains ' + %char( elements ) );               // Too many to handle
         endif;
         if elements = 0;
           result.body.value = YAJL_GET_STRING( node );
         endif;
       endif;

       //-------------------------------------------
       // Parse 3rd level : inside value with arrays
       //-------------------------------------------
       i# = 0;
       dow YAJL_ARRAY_LOOP( valuesNode: i#: node );

         j# = 0;
         dow YAJL_OBJECT_LOOP( node: j#: key: val );
           exsr load_subfield;
         enddo;

       enddo;

       // Check missing value in data strcture
       select;
       when P_APIType = '2';
         exsr OLCheckMissing;
       when P_APIType = '3';
         exsr RNCheckMissing;
       when P_APIType = '4';
         exsr SRCheckMissing;
       when P_APIType = '5';
         exsr CfCheckMissing;
       endsl;

       // Write data strcture to files
       select;
       when P_APIType = '2';
         exsr OLWriteRecord;
       when P_APIType = '3';
         exsr RNWriteRecord;
       when P_APIType = '4';
         exsr SRWriteRecord;
       when P_APIType = '5';
         exsr CfWriteRecord;
       endsl;

       if (Not *in99);
         commit;
       else;
         rolbk;
       endif;

       // release JSON tree resource
       yajl_tree_free( docNode );

       *inlr = *on;

       //--------------------------------------------------------------//
       // Parse 4th level : inside each array
       //--------------------------------------------------------------//
       begsr load_subfield;

       select;
       when key = 'businessNo';
         result.body.values( i# ).businessNo = YAJL_GET_STRING( val );

       when key = 'orderNo';
         result.body.values( i# ).orderNo = YAJL_GET_STRING( val );

       when key = 'expiryDate';
         result.body.values( i# ).expiryDate = YAJL_GET_STRING( val );

       //-------------------------------------
       // Parse 5th level : inside loanAccount
       //-------------------------------------
       when key = 'loanAccount';
         k# = 0;
         loanAccountNod = YAJL_OBJECT_FIND( node: 'loanAccount' );
         dow YAJL_OBJECT_LOOP( loanAccountNod: k#: subKey: subVal );
           exsr load_loanAccount;
         enddo;

       //-------------------------------------
       // Parse 5th level : inside individualInformation
       //-------------------------------------
       when key = 'individualInformation';
         k# = 0;
         individInfoNod = YAJL_OBJECT_FIND( node: 'individualInformation' );
         dow YAJL_OBJECT_LOOP( individInfoNod: k#: subKey: subVal );
           exsr load_individInfo;
         enddo;

       //-------------------------------------
       // Parse 5th level : inside occupationInformation
       //-------------------------------------
       when key = 'occupationInformation';
         k# = 0;
         occupatInfoNod = YAJL_OBJECT_FIND( node
                                          :'occupationInformation' );
         dow YAJL_OBJECT_LOOP( occupatInfoNod: k#: subKey: subVal );
           exsr load_occupatInfo;
         enddo;

       //-------------------------------------
       // Parse 5th level : inside tuData
       //-------------------------------------
       when key = 'tuData';
         k# = 0;
         tuDataNode = YAJL_OBJECT_FIND( node: 'tuData' );
         dow YAJL_OBJECT_LOOP( tuDataNode: k#: subKey: subVal );
           exsr load_tuData;
         enddo;

       //-------------------------------------
       // Parse 5th level : inside checkInformation
       //-------------------------------------
       when key = 'checkInformation';
         k# = 0;
         checkInfoNode = YAJL_OBJECT_FIND( node: 'checkInformation' );
         dow YAJL_OBJECT_LOOP( checkInfoNode: k#: subKey: subVal );
           exsr load_checkInfo;
         enddo;

       //-------------------------------------
       // Parse 5th level : inside residenceInformation
       //-------------------------------------
       when key = 'residenceInformation';
         k# = 0;
         residInfoNode = YAJL_OBJECT_FIND( node
                                        : 'residenceInformation' );
         dow YAJL_OBJECT_LOOP( residInfoNode: k#: subKey: subVal );
           exsr load_residInfo;
         enddo;

       when key = 'drawdownDate';
         result.body.values( i# ).drawdownDate = YAJL_GET_STRING( val );

       when key = 'drawdownTime';
         result.body.values( i# ).drawdownTime = YAJL_GET_STRING( val );

       when key = 'amount';
         result.body.values( i# ).amount = YAJL_GET_NUMBER( val );

       when key = 'tenor';
         result.body.values( i# ).tenor = YAJL_GET_NUMBER( val );

       when key = 'monthlyRate';
         result.body.values( i# ).monthlyRate = YAJL_GET_NUMBER( val );

       when key = 'annualizedRate';
         result.body.values( i# ).annualRate = YAJL_GET_NUMBER( val );

       when key = 'monthlyRepaymentAmount';
         result.body.values( i# ).monthRepayAmt = YAJL_GET_NUMBER( val );

       when key = 'orderStatus';
         result.body.values( i# ).orderStatus = YAJL_GET_STRING( val );

       when key = 'retCode';
         result.body.values( i# ).retCode = YAJL_GET_STRING( val );

       when key = 'retMsg';
         result.body.values( i# ).retMsg = YAJL_GET_STRING( val );

       endsl;
       endsr;

       //--------------------------------------------------------------//
       // Parse 5th level : inside loanAccount
       //--------------------------------------------------------------//
       begsr load_loanAccount;

       select;
       when subKey = 'zaSettleCount';
         result.body.values( i# ).loanAccount.zaSettleCount =
           YAJL_GET_NUMBER( subVal );

       when subKey = 'externalCustId';
         result.body.values( i# ).loanAccount.extCustId =
           YAJL_GET_STRING( subVal );

       when subKey = 'zaUnSettleAmout';
         result.body.values( i# ).loanAccount.zaUnSettleAmt =
           YAJL_GET_NUMBER( subVal );

       when subKey = 'zaUnSettleCount';
         result.body.values( i# ).loanAccount.zaUnSettleCnt =
           YAJL_GET_NUMBER( subVal );

       other;
         dsply 'JSON loanAccount contains extra element!';
         return;

       endsl;
       endsr;

       //--------------------------------------------------------------//
       // Parse 5th level : inside individualInformation
       //--------------------------------------------------------------//
       begsr load_individInfo;

       select;
       when subKey = 'birthDay';
         result.body.values( i# ).individInfo.birthDay =
           YAJL_GET_STRING( subVal );

       when subKey = 'academicLevel';
         result.body.values( i# ).individInfo.academicLevel =
           YAJL_GET_NUMBER( subVal );

       when subKey = 'idType';
         result.body.values( i# ).individInfo.idType =
           YAJL_GET_STRING( subVal );

       when subKey = 'nationality';
         result.body.values( i# ).individInfo.nationality =
           YAJL_GET_STRING( subVal );

       when subKey = 'gender';
         result.body.values( i# ).individInfo.gender =
           YAJL_GET_STRING( subVal );

       when subKey = 'livingTogether';
         result.body.values( i# ).individInfo.livTogether =
           YAJL_GET_NUMBER( subVal );

       when subKey = 'martialStatus';
         result.body.values( i# ).individInfo.martialSts =
           YAJL_GET_NUMBER( subVal );

       other;
         dsply 'JSON individualInformation contains extra element!';
         return;

       endsl;
       endsr;

       //--------------------------------------------------------------//
       // Parse 5th level : inside occupationInformation
       //--------------------------------------------------------------//
       begsr load_occupatInfo;

       // Optionally field: declareIncome
       result.body.values( i# ).occupatInfo.declareIncome = 0;

       select;
       when subKey = 'income';
         result.body.values( i# ).occupatInfo.income =
           YAJL_GET_NUMBER( subVal );

       when subKey = 'commencementDate';
         result.body.values( i# ).occupatInfo.commenceDate =
           YAJL_GET_STRING( subVal );

       when subKey = 'occupationType';
         result.body.values( i# ).occupatInfo.occupatType =
           YAJL_GET_STRING( subVal );

       when subKey = 'employType';
         result.body.values( i# ).occupatInfo.employType =
           YAJL_GET_STRING( subVal );

       when subKey = 'paymentMethod';
         result.body.values( i# ).occupatInfo.paymentMethod =
           YAJL_GET_STRING( subVal );

       when subKey = 'declareIncome';
         result.body.values( i# ).occupatInfo.declareIncome =
           YAJL_GET_NUMBER( subVal );

       when subKey = 'jobType';
         result.body.values( i# ).occupatInfo.jobType =
           YAJL_GET_STRING( subVal );

       other;
         dsply 'JSON occupationInformation contains extra element!';
         return;

       endsl;
       endsr;

       //--------------------------------------------------------------//
       // Parse 5th level : inside tuData
       //--------------------------------------------------------------//
       begsr load_tuData;

       select;
       when subKey = 'tuef';
         result.body.values( i# ).tuData.tuef =
           YAJL_GET_STRING( subVal );

       other;
         dsply 'JSON tuData contains extra element!';
         return;

       endsl;
       endsr;

       //--------------------------------------------------------------//
       // Parse 5th level : inside checkInformation
       //--------------------------------------------------------------//
       begsr load_checkInfo;

       select;
       when subKey = 'income';
         result.body.values( i# ).checkInfo.income =
           YAJL_GET_STRING( subVal );

       when subKey = 'address';
         result.body.values( i# ).checkInfo.address =
           YAJL_GET_STRING( subVal );

       when subKey = 'telephone';
         result.body.values( i# ).checkInfo.telephone =
           YAJL_GET_STRING( subVal );

       other;
         dsply 'JSON checkInformation contains extra element!';
         return;

       endsl;
       endsr;

       //--------------------------------------------------------------//
       // Parse 5th level : inside residenceInformation
       //--------------------------------------------------------------//
       begsr load_residInfo;

       select;
       when subKey = 'residencePeriod';
         result.body.values( i# ).residInfo.residPeriod =
           YAJL_GET_STRING( subVal );

       when subKey = 'residenceType';
         result.body.values( i# ).residInfo.residenceType =
           YAJL_GET_STRING( subVal );

       when subKey = 'withHomeTelephone';
         result.body.values( i# ).residInfo.withHomeTel =
           YAJL_GET_STRING( subVal );

       when subKey = 'livingTogether';
         result.body.values( i# ).residInfo.livTogether =
           YAJL_GET_NUMBER( subVal );

       when subKey = 'residenceOwner';
         result.body.values( i# ).residInfo.residenceOwn =
           YAJL_GET_STRING( subVal );

       other;
         dsply 'JSON residenceInformation contains extra element!';
         return;

       endsl;
       endsr;

       //--------------------------------------------------------------//
       // For Order List, check JSON missing mandatory value
       //--------------------------------------------------------------//
       begsr OLCheckMissing;

       // Checking for Header Message in Response
       exsr HdrCheckMissing;

       // Checking for Body Message in Response
       exsr BodyCheckMissing;

       for i# = 1 to elements;
         if result.body.values( i# ).businessNo = *blank;
           dsply ('Miss val in businessNo for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).orderNo = *blank;
           dsply ('Miss val in orderNo for rec ' + %char(i#) + '!');
           return;
         endif;

         // if result.body.values( i# ).expiryDate = *blank;
         //   dsply ('Miss val in expiryDate for rec ' + %char(i#) + '!');
         //   return;
         // endif;

         if result.body.values( i# ).loanAccount.zaSettleCount = *hival;
           dsply ('Miss val in zaSettleCount for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).loanAccount.extCustId = *blank;
           dsply ('Miss val in externalCustId for rec ' +  %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).loanAccount.zaUnSettleAmt = *hival;
           dsply ('Miss val in zaUnSettleAmout for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).loanAccount.zaUnSettleCnt = *hival;
           dsply ('Miss val in zaUnSettleCount for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).individInfo.birthDay = *blank;
           dsply ('Miss val in birthDay for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).individInfo.academicLevel = *hival;
           dsply ('Miss val in academicLevel for rec ' +  %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).individInfo.idType = *blank;
           dsply ('Miss val in idType for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).individInfo.nationality = *blank;
           dsply ('Miss val in nationality for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).individInfo.gender = *blank;
           dsply ('Miss val in gender for rec ' +  %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).individInfo.livTogether = *hival;
           dsply ('Miss val in livingTogether for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).individInfo.martialSts = *hival;
           dsply ('Miss val in martialStatus for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).occupatInfo.income = *hival;
           dsply ('Miss val in income for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).occupatInfo.commenceDate = *blank;
           dsply ('Miss val in commenceDate for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).occupatInfo.occupatType = *blank;
           dsply ('Miss val in occupatType for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).occupatInfo.paymentMethod = *blank;
           dsply ('Miss val in paymentMethod for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).occupatInfo.jobType = *blank;
           dsply ('Miss val in jobType for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).tuData.tuef = *blank;
           dsply ('Miss val in tuef for rec ' + %char(i#) + '!');
           return;
         endif;

         // Check "ES02**\n" must exists
         w1tuef = result.body.values( i# ).tuData.tuef;
         w1Pos = %scan( ENDTUEF: w1tuef );
         if w1Pos = 0;
           dsply ('Miss ES02**\n in tuef for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).checkInfo.income = *hival;
           dsply ('Miss val in income for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).checkInfo.address = *blank;
           dsply ('Miss val in address for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).checkInfo.telephone = *blank;
           dsply ('Miss val in telephone for rec ' +  %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).residInfo.residPeriod = *blank;
           dsply ('Miss val in residencePeriod for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).residInfo.residenceType = *blank;
           dsply ('Miss val in residenceType for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).residInfo.withHomeTel = *blank;
           dsply ('Miss val in withHomeTelephone for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).residInfo.livTogether = *hival;
           dsply ('Miss val in livingTogether for rec ' + %char(i#) + '!');
           return;
         endif;

         // Spec. residenceOwner is mandatory, but actual data give optional
         // if result.body.values( i# ).residInfo.residenceOwn = *blank;
         //   dsply ('Miss val in residenceOwner for rec ' + %char(i#) + '!'); //
         //   return;
         // endif;

       endfor;

       endsr;

       //--------------------------------------------------------------//
       // For Result Notice API, check JSON missing mandatory value
       //--------------------------------------------------------------//
       begsr RNCheckMissing;

       // Checking for Header Message in Response
       exsr HdrCheckMissing;

       // Checking for Body Message in Response
       exsr BodyCheckMissing;

       endsr;

       //--------------------------------------------------------------//
       // For Success Result API, check JSON missing mandatory value
       //--------------------------------------------------------------//
       begsr SRCheckMissing;

       // Checking for Header Message in Response
       exsr HdrCheckMissing;

       // Checking for Body Message in Response
       exsr BodyCheckMissing;

       for i# = 1 to elements;

         if result.body.values( i# ).businessNo = *blank;
           dsply ('Miss val in businessNo for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).orderNo = *blank;
           dsply ('Miss val in orderNo for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).drawdownDate = *blank;
           dsply ('Miss val in drawdownDate for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).drawdownTime = *blank;
           dsply ('Miss val in drawdownTime for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).amount = 0;
           dsply ('Miss val in amount for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).tenor = 0;
           dsply ('Miss val in tenor for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).monthlyRate = 0;
           dsply ('Miss val in monthlyRate for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).annualRate = 0;
           dsply ('Miss val in annualizedRate for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).monthRepayAmt = 0;
           dsply ('Miss val in monthlyRepaymentAmount for '+%char(i#)+'!');
           return;
         endif;

       endfor;

       endsr;

       //--------------------------------------------------------------//
       // For Confirm API, check JSON missing mandatory value
       //--------------------------------------------------------------//
       begsr CfCheckMissing;

       // Checking for Header Message in Response
       exsr HdrCheckMissing;

       // Checking for Body Message in Response
       exsr BodyCheckMissing;

       for i# = 1 to elements;

         if result.body.values( i# ).businessNo = *blank;
           dsply ('Miss val in businessNo for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).orderNo = *blank;
           dsply ('Miss val in orderNo for rec ' + %char(i#) + '!');
           return;
         endif;

         if result.body.values( i# ).retCode = *blank;
           dsply ('Miss val in retCode for rec ' + %char(i#) + '!');
           return;
         endif;

         // Spec. retMsg is not mandatory
         // if result.body.values( i# ).retMsg = *blank;
         //   dsply ('Miss val in retMsg for rec ' + %char(i#) + '!');
         //   return;
         // endif;

       endfor;

       endsr;

       //--------------------------------------------------------------//
       // For Response Header in general, check JSON missing mandatory value
       //--------------------------------------------------------------//
       begsr HdrCheckMissing;

       if result.header.resCode = *blank;
         dsply ('Missing value in element resCode!');
         return;
       endif;

       if result.header.resMsg = *blank;
         dsply ('Missing value in element resMsg!');
         return;
       endif;

       // if result.header.businessId = *blank;
       //   dsply ('Missing value in element businessId!');
       //   return;
       // endif;

       if result.header.timestamp = 0;
         dsply ('Missing value in element timestamp!');
         return;
       endif;

       endsr;

       //--------------------------------------------------------------//
       // For Response Body in general, check JSON missing mandatory value
       //--------------------------------------------------------------//
       begsr BodyCheckMissing;

       if result.body.retCode = *blank;
         dsply ('Missing value in element retCode!');
         return;
       endif;

       if result.body.retCode = *blank;
         dsply ('Missing value in element retCode!');
         return;
       endif;

       if result.body.serverTime = *blank;
         dsply ('Missing value in element serverTime!');
         return;
       endif;

       endsr;

       //--------------------------------------------------------------//
       // Write record to JSOLPF, JSTUEF
       //--------------------------------------------------------------//
       begsr OLWriteRecord;

       monitor;
         I_Cmd = 'CLRPFM FILE(JSOLPF)';
         Exc_Cmd( %trim( I_Cmd ): %len( %trim( I_Cmd ) ) );
       on-error;
         dsply ('Cannot Clear JSOLPF');
         dump '0001';
         return;
       endmon;

       monitor;
         I_Cmd = 'CLRPFM FILE(JSTUEF)';
         Exc_Cmd( %trim( I_Cmd ): %len( %trim( I_Cmd ) ) );
       on-error;
         dump '0002';
         return;
       endmon;

       open(e) JSOLPF01;
       if %error();
         dsply ('Cannot open JSOLPF');
         dump '0003';
         return;
       endif;

       open(e) JSTUEF01 ;
       if %error();
         dsply ('Cannot open JSTUEF');
         dump '0004';
         return;
       endif;

       m# = 0;

       exsr OLInitRcd;
       OLPEP = 'header/resCode';
       OLPVS = result.header.resCode;
       write(e) JSOLPFR;
       if %error();
         *in99 = *on;
         dump '0005';
       endif;

       exsr OLInitRcd;
       OLPEP = 'header/resMsg';
       OLPVS = result.header.resMsg;
       write(e) JSOLPFR;
       if %error();
         *in99 = *on;
         dump '0006';
       endif;

       exsr OLInitRcd;
       OLPEP = 'header/timestamp';
       OLPVN = result.header.timestamp;
       write(e) JSOLPFR;
       if %error();
         *in99 = *on;
         dump '0007';
         leavesr;
       endif;

       exsr OLInitRcd;
       OLPEP = 'body/serverTime';
       OLPVS = result.body.serverTime;
       write(e) JSOLPFR;
       if %error();
         *in99 = *on;
         dump '0008';
       endif;

       exsr OLInitRcd;
       OLPEP = 'body/retCode';
       OLPVS = result.body.retCode;
       write(e) JSOLPFR;
       if %error();
         *in99 = *on;
         dump '0009';
       endif;

       exsr OLInitRcd;
       OLPEP = 'body/retMsg';
       OLPVS = result.body.retMsg;
       write(e) JSOLPFR;
       if %error();
         *in99 = *on;
         dump '0010';
       endif;

       for m# = 1 to elements;

         exsr OLInitRcd;
         OLPEP = 'value/businesssNo';
         OLPVS = result.body.values( m# ).businessNo;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0011';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/orderNo';
         OLPVS = result.body.values( m# ).orderNo;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0012';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/expiryDate';
         OLPVS = result.body.values( m# ).expiryDate;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0012a';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/loanAccount/zaSettleCount';
         OLPVN = result.body.values( m# ).loanAccount.zaSettleCount;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0013';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/loanAccount/extneralCustId';
         OLPVS = result.body.values( m# ).loanAccount.extCustId;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0014';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/loanAccount/zaUnSettleAmout';
         OLPVN = result.body.values( m# ).loanAccount.zaUnSettleAmt;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0015';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/loanAccount/zaUnSettleCount';
         OLPVN = result.body.values( m# ).loanAccount.zaUnSettleCnt;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0016';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/individualInformation/birthDay';
         OLPVS = result.body.values( m# ).individInfo.birthDay;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0017';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/individualInformation/academicLevel';
         OLPVN = result.body.values( m# ).individInfo.academicLevel;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0018';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/individualInformation/idType';
         OLPVS = result.body.values( m# ).individInfo.idType;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0019';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/individualInformation/nationality';
         OLPVS = result.body.values( m# ).individInfo.nationality;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0020';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/individualInformation/gender';
         OLPVS = result.body.values( m# ).individInfo.gender;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0021';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/individualInformation/livingTogether';
         OLPVN = result.body.values( m# ).individInfo.livTogether;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0022';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/individualInformation/martialStatus';
         OLPVN = result.body.values( m# ).individInfo.martialSts;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0023';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/occupationInformation/income';
         OLPVN = result.body.values( m# ).occupatInfo.income;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0024';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/occupationInformation/commencementDate';
         OLPVS = result.body.values( m# ).occupatInfo.commenceDate;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0025';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/occupationInformation/occupationType';
         OLPVS = result.body.values( m# ).occupatInfo.occupatType;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0026';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/occupationInformation/employType';
         OLPVS = result.body.values( m# ).occupatInfo.employType;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0026a';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/occupationInformation/paymentMethod';
         OLPVS = result.body.values( m# ).occupatInfo.paymentMethod;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0027';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/occupationInformation/declareIncome';
         OLPVN = result.body.values( m# ).occupatInfo.declareIncome;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0027a';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/occupationInformation/jobType';
         OLPVS = result.body.values( m# ).occupatInfo.jobType;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0028';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/checkInformation/income';
         OLPVS = result.body.values( m# ).checkInfo.income;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0029';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/checkInformation/address';
         OLPVS = result.body.values( m# ).checkInfo.address;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0030';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/checkInformation/telephone';
         OLPVS = result.body.values( m# ).checkInfo.telephone;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0031';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/residenceInformation/residencePeriod';
         OLPVS = result.body.values( m# ).residInfo.residPeriod;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0032';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/residenceInformation/residenceType';
         OLPVS = result.body.values( m# ).residInfo.residenceType;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0033';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/residenceInformation/withHomeTelephone';
         OLPVS = result.body.values( m# ).residInfo.withHomeTel;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0034';
         endif;

         exsr OLInitRcd;
         OLPEP = 'value/residenceInformation/livingTogether';
         OLPVN = result.body.values( m# ).residInfo.livTogether;
         write(e) JSOLPFR;
         if %error();
           *in99 = *on;
           dump '0035';
         endif;

         If result.body.values( m# ).residInfo.residenceOwn <> *blank;
           exsr OLInitRcd;
           OLPEP = 'value/residenceInformation/residenceOwner';
           OLPVS = result.body.values( m# ).residInfo.residenceOwn;
           write(e) JSOLPFR;
           if %error();
             *in99 = *on;
             dump '0036';
           endif;
         endif;

         exsr TUEInitRcd;
         TUEEP = 'value/tuData/tuef';
         w1tuef = result.body.values( m# ).tuData.tuef;
         w1tuefLen = %len( %trimr( w1tuef ) );
         w1Pos = %scan( ENDTUEF: w1tuef );
         select;
         when w1tuefLen <= TUEFLen;
           TUERSN = 1;
           TUERRD = w1tuef;
         when ( w1tuefLen > TUEFLen ) and ( w1Pos <= TUEFLen );
           TUERSN = 1;
           TUERRD = %subst( w1tuef: 1: w1Pos - 1 );
           TUERSN = 2;
           TUERRD = %subst( w1tuef: w1Pos: ( w1tuefLen - w1Pos + 1 ) );
         when ( w1tuefLen > TUEFLen ) and ( w1Pos > TUEFLen );
           TUERSN = 1;
           TUERRD = %subst( w1tuef: 1: TUEFLen );
           TUERSN = 2;
           TUERRD = %subst( w1tuef: ( TUEFLen + 1 )
                        : ( w1tuefLen - TUEFLen ) );
         endsl;
         write(e) JSTUEFR;
         if %error();
           *in99 = *on;
           dump '0037';
         endif;

       endfor;

       close JSOLPF01;
       close JSTUEF01;

       endsr;

       //--------------------------------------------------------------//
       // Write record to JSRNPF
       //--------------------------------------------------------------//
       begsr RNWriteRecord;

       monitor;
         I_Cmd = 'CLRPFM FILE(JSRNPF)';
         Exc_Cmd( %trim( I_Cmd ): %len( %trim( I_Cmd ) ) );
       on-error;
         dsply ('Cannot Clear JSRNPF');
         dump '0051';
         return;
       endmon;

       open(e) JSRNPF01;
       if %error();
         dsply ('Cannot open JSRNPF');
         dump '0052';
         return;
       endif;

       m# = 0;

       exsr RNInitRcd;
       RNPEP = 'header/resCode';
       RNPVS = result.header.resCode;
       write(e) JSRNPFR;
       if %error();
         *in99 = *on;
         dump '0053';
       endif;

       exsr RNInitRcd;
       RNPEP = 'header/resMsg';
       RNPVS = result.header.resMsg;
       write(e) JSRNPFR;
       if %error();
         *in99 = *on;
         dump '0054';
       endif;

       exsr RNInitRcd;
       RNPEP = 'header/timestamp';
       RNPVN = result.header.timestamp;
       write(e) JSRNPFR;
       if %error();
         *in99 = *on;
         dump '0055';
       endif;

       exsr RNInitRcd;
       RNPEP = 'body/serverTime';
       RNPVS = result.body.serverTime;
       write(e) JSRNPFR;
       if %error();
         *in99 = *on;
         dump '0056';
       endif;

       exsr RNInitRcd;
       RNPEP = 'body/retCode';
       RNPVS = result.body.retCode;
       write(e) JSRNPFR;
       if %error();
         *in99 = *on;
         dump '0057';
       endif;

       exsr RNInitRcd;
       RNPEP = 'body/retMsg';
       RNPVS = result.body.retMsg;
       write(e) JSRNPFR;
       if %error();
         *in99 = *on;
         dump '0058';
       endif;

       close JSRNPF01;

       endsr;

       //--------------------------------------------------------------//
       // Write record to JSSRPF
       //--------------------------------------------------------------//
       begsr SRWriteRecord;

       monitor;
         I_Cmd = 'CLRPFM FILE(JSSRPF)';
         Exc_Cmd( %trim( I_Cmd ): %len( %trim( I_Cmd ) ) );
       on-error;
         dsply ('Cannot Clear JSSRPF');
         dump '0061';
         return;
       endmon;

       open(e) JSSRPF01;
       if %error();
         dsply ('Cannot open JSSRPF');
         dump '0062';
         return;
       endif;

       m# = 0;

       exsr SRInitRcd;
       SRPEP = 'header/resCode';
       SRPVS = result.header.resCode;
       write(e) JSSRPFR;
       if %error();
         *in99 = *on;
         dump '0063';
       endif;

       exsr SRInitRcd;
       SRPEP = 'header/resMsg';
       SRPVS = result.header.resMsg;
       write(e) JSSRPFR;
       if %error();
         *in99 = *on;
         dump '0064';
       endif;

       exsr SRInitRcd;
       SRPEP = 'header/timestamp';
       SRPVN = result.header.timestamp;
       write(e) JSSRPFR;
       if %error();
         *in99 = *on;
         dump '0065';
       endif;

       exsr SRInitRcd;
       SRPEP = 'body/serverTime';
       SRPVS = result.body.serverTime;
       write(e) JSSRPFR;
       if %error();
         *in99 = *on;
         dump '0066';
       endif;

       exsr SRInitRcd;
       SRPEP = 'body/retCode';
       SRPVS = result.body.retCode;
       write(e) JSSRPFR;
       if %error();
         *in99 = *on;
         dump '0067';
       endif;

       exsr SRInitRcd;
       SRPEP = 'body/retMsg';
       SRPVS = result.body.retMsg;
       write(e) JSSRPFR;
       if %error();
         *in99 = *on;
         dump '0068';
       endif;

       for m# = 1 to elements;

         exsr SRInitRcd;
         SRPEP = 'value/orderNo';
         SRPVS = result.body.values( m# ).orderNo;
         write(e) JSSRPFR;
         if %error();
           *in99 = *on;
           dump '0069';
         endif;

         exsr SRInitRcd;
         SRPEP = 'value/drawdownDate';
         SRPVS = result.body.values( m# ).drawdownDate;
         write(e) JSSRPFR;
         if %error();
           *in99 = *on;
           dump '0070';
         endif;

         exsr SRInitRcd;
         SRPEP = 'value/drawdownTime';
         SRPVS = result.body.values( m# ).drawdownTime;
         write(e) JSSRPFR;
         if %error();
           *in99 = *on;
           dump '0071';
         endif;

         exsr SRInitRcd;
         SRPEP = 'value/amount';
         SRPVN = result.body.values( m# ).amount;
         write(e) JSSRPFR;
         if %error();
           *in99 = *on;
           dump '0072';
         endif;

         exsr SRInitRcd;
         SRPEP = 'value/tenor';
         SRPVN = result.body.values( m# ).tenor;
         write(e) JSSRPFR;
         if %error();
           *in99 = *on;
           dump '0073';
         endif;

         exsr SRInitRcd;
         SRPEP = 'value/monthlyRate';
         SRPVN = result.body.values( m# ).monthlyRate;
         write(e) JSSRPFR;
         if %error();
           *in99 = *on;
           dump '0074';
         endif;

         exsr SRInitRcd;
         SRPEP = 'value/annualizedRate';
         SRPVN = result.body.values( m# ).annualRate;
         write(e) JSSRPFR;
         if %error();
           *in99 = *on;
           dump '0075';
         endif;

         exsr SRInitRcd;
         SRPEP = 'value/monthlyRepaymentAmount';
         SRPVN = result.body.values( m# ).monthRepayAmt;
         write(e) JSSRPFR;
         if %error();
           *in99 = *on;
           dump '0076';
         endif;

       endfor;

       close JSSRPF01;

       endsr;

       //--------------------------------------------------------------//
       // Write record to JSCFPF
       //--------------------------------------------------------------//
       begsr CFWriteRecord;

       monitor;
         I_Cmd = 'CLRPFM FILE(JSCFPF)';
         Exc_Cmd( %trim( I_Cmd ): %len( %trim( I_Cmd ) ) );
       on-error;
         dsply ('Cannot Clear JSCFPF');
         dump '0081';
         return;
       endmon;

       open(e) JSCFPF01;
       if %error();
         dsply ('Cannot open JSCFPF');
         dump '0082';
         return;
       endif;

       m# = 0;

       exsr CFInitRcd;
       CFPEP = 'header/resCode';
       CFPVS = result.header.resCode;
       write(e) JSCFPFR;
       if %error();
         *in99 = *on;
         dump '0083';
       endif;

       exsr CFInitRcd;
       CFPEP = 'header/resMsg';
       CFPVS = result.header.resMsg;
       write(e) JSCFPFR;
       if %error();
         *in99 = *on;
         dump '0084';
       endif;

       exsr CFInitRcd;
       CFPEP = 'header/timestamp';
       CFPVN = result.header.timestamp;
       write(e) JSCFPFR;
       if %error();
         *in99 = *on;
         dump '0085';
       endif;

       exsr CFInitRcd;
       CFPEP = 'body/serverTime';
       CFPVS = result.body.serverTime;
       write(e) JSCFPFR;
       if %error();
         *in99 = *on;
         dump '0086';
       endif;

       exsr CFInitRcd;
       CFPEP = 'body/retCode';
       CFPVS = result.body.retCode;
       write(e) JSCFPFR;
       if %error();
         *in99 = *on;
         dump '0087';
         leavesr;
       endif;

       exsr CFInitRcd;
       CFPEP = 'body/retMsg';
       CFPVS = result.body.retMsg;
       write(e) JSCFPFR;
       if %error();
         *in99 = *on;
         dump '0088';
       endif;

       for m# = 1 to elements;

         exsr CFInitRcd;
         CFPEP = 'value/businessNo';
         CFPVS = result.body.values( m# ).businessNo;
         write(e) JSCFPFR;
         if %error();
           *in99 = *on;
           dump '0089';
         endif;

         exsr CFInitRcd;
         CFPEP = 'value/orderNo';
         CFPVS = result.body.values( m# ).orderNo;
         write(e) JSCFPFR;
         if %error();
           *in99 = *on;
           dump '0090';
         endif;

         exsr CFInitRcd;
         CFPEP = 'value/orderStatus';
         CFPVS = result.body.values( m# ).orderStatus;
         write(e) JSCFPFR;
         if %error();
           *in99 = *on;
           dump '0091';
         endif;

         exsr CFInitRcd;
         CFPEP = 'value/retCode';
         CFPVS = result.body.values( m# ).retCode;
         write(e) JSCFPFR;
         if %error();
           *in99 = *on;
           dump '0092';
         endif;

         // Spec. retMsg is not mandatory
         If result.body.values( m# ).retMsg <> *blank;
           exsr CFInitRcd;
           CFPEP = 'value/retMsg';
           CFPVS = result.body.values( m# ).retMsg;
           write(e) JSCFPFR;
           if %error();
             *in99 = *on;
             dump '0093';
         endif;
           endif;

       endfor;

       close JSSRPF01;

       endsr;

       //--------------------------------------------------------------//
       begsr OLInitRcd;
       //--------------------------------------------------------------//

       clear *all JSOLPFR;

       OLPTCD = w1MchDate;
       // OLPTSN = w1OLPTSN;
       OLPTSN = m#;
       OLPLUT = w1TimStp;
       OLPOS  = m#;
       If m# = 0;
         OLPON = *blank;
         OLPBN = *blank;
       else;
         OLPON = result.body.values( m# ).orderNo;
         OLPBN = result.body.values( m# ).businessNo;
       endif;

       endsr;

       //--------------------------------------------------------------//
       begsr TUEInitRcd;
       //--------------------------------------------------------------//

       clear *all JSTUEFR;

       TUETCD = w1MchDate;
       // TUETSN = w1OLPTSN;
       TUETSN = m#;
       TUEOS  = m#;
       if m# = 0;
         TUEON = *blank;
       else;
         TUEON = result.body.values( m# ).orderNo;
       endif;

       endsr;

       //--------------------------------------------------------------//
       begsr RNInitRcd;
       //--------------------------------------------------------------//

       clear *all JSRNPFR;

       RNPTCD = w1MchDate;
       RNPTSN = w1RNPTSN;
       RNPLUT = w1TimStp;
       RNPOS = m#;
       RNPON = *blank;
       RNPBN = *blank;

       endsr;

       //--------------------------------------------------------------//
       begsr SRInitRcd;
       //--------------------------------------------------------------//

       clear *all JSSRPFR;

       SRPTCD = w1MchDate;
       SRPTSN = w1SRPTSN;
       SRPLUT = w1TimStp;
       SRPOS = m#;
       SRPON = *blank;
       if m# = 0;
         SRPBN = *blank;
       else;
         SRPBN = result.body.values( m# ).businessNo;
       endif;

       endsr;

       //--------------------------------------------------------------//
       begsr CfInitRcd;
       //--------------------------------------------------------------//

       clear *all JSCFPFR;

       CFPTCD = w1MchDate;
       CFPTSN = w1CFPTSN;
       CFPLUT = w1TimStp;
       CFPOS  = m#;
       if m# > 0;
         CFPON = result.body.values( m# ).orderNo;
         CFPBN = result.body.values( m# ).businessNo;
       endif;

       endsr;

       //--------------------------------------------------------------//
       begsr *InzSr;
       //--------------------------------------------------------------//

       w1MchDate  = %date();
       w1TimStp   = %timestamp();
       ENDTUEF    = 'ES02**' + x'25';
       ENDTUEFLen = %size(ENDTUEF);

       endsr;

       //--------------------------------------------------------------//
       begsr OLInitRef;
       //--------------------------------------------------------------//

       w1RcvDtlF = w1Path + 'RcvDtl2.json';

       open JSOLPF01;

       setgt *hival JSOLPFR;
       readp JSOLPFR;
       if not %eof();
         w1OLPTSN = OLPTSN + 1;
       else;
         w1OLPTSN = 1;
       endif;

       close JSOLPF01;

       endsr;

       //--------------------------------------------------------------//
       begsr RNInitRef;
       //--------------------------------------------------------------//

       w1RcvDtlF = w1Path + 'RcvDtl3.json';

       open JSRNPF01;

       setgt *hival JSRNPFR;
       readp JSRNPFR;
       if not %eof();
         w1RNPTSN = RNPTSN + 1;
       else;
         w1RNPTSN = 1;
       endif;

       close JSRNPF01;

       endsr;

       //--------------------------------------------------------------//
       begsr SRInitRef;
       //--------------------------------------------------------------//

       w1RcvDtlF = w1Path + 'RcvDtl4.json';

       open JSSRPF01;

       setgt *hival JSSRPFR;
       readp JSSRPFR;
       if not %eof();
         w1SRPTSN = SRPTSN + 1;
       else;
         w1SRPTSN = 1;
       endif;

       close JSSRPF01;

       endsr;

       //--------------------------------------------------------------//
       begsr CfInitRef;
       //--------------------------------------------------------------//

       w1RcvDtlF = w1Path + 'RcvDtl5.json';

       open JSCFPF01;

       setgt *hival JSCFPFR;
       readp JSCFPFR;
       if not %eof();
         w1CFPTSN = CFPTSN + 1;
       else;
         w1CFPTSN = 1;
       endif;

       close JSCFPF01;

       endsr;

      /end-free

