      *====================================================================*
      * Program name: JSONEX3B                                             *
      * Purpose.....: JSON and REST API Example with OAuth authentication  *
      *                                                                    *
      * Description : Parasing JSON file                                   *
      *                                                                    *
      * Modification:                                                      *
      * Date       Name       Pre  Ver  Mod#  Remarks                      *
      * ---------- ---------- --- ----- ----- -----------------------------*
      * 2021/07/23 Alan       AC              New Develop                  *
      *====================================================================*
       ctl-opt DFTACTGRP(*NO) OPTION(*SRCSTMT) BNDDIR('YAJL');

       dcl-f QSYSPRT printer(132);

       /include yajl_h

       dcl-ds result qualified;
         dcl-ds header;
           resCode char(6);
           resMsg varchar(100);
           timestamp packed(14: 0);
         end-ds;

         dcl-ds body;
           serverTime char(20);
           retCode char(6);
           retMsg varchar(100);
           num_value int(10);

           dcl-ds value dim(50);
             businessNo char(64);
             orderNo char(64);

             dcl-ds loanAccount;
               zaSettleCount int(10);
               zaUnSettleCount int(10);
               zaUnSettleAmout packed(10: 4);
               externalCustId char(64);
             end-ds;

             dcl-ds individualInformation;
               birthDay char(10);
               academicLevel int(10);
               idType char(10);
               nationality char(10);
               martialStatus int(10);
               gender char(2);
               livingTogether int(10);
             end-ds;

             dcl-ds residenceInformation;
               residenceType char(10);
               residenceOwner char(50);
               residencePeriod char(5);
               withHomeTelephone char(1);
               livingTogether int(10);
             end-ds;

             dcl-ds occupationInformation;
               occupationType char(10);
               jobType char(10);
               paymentMethod char(10);
               income packed(8: 2);
               commencementDate char(10);
             end-ds;

             dcl-ds tuData;
               tuef varchar(65535);
             end-ds;

             dcl-ds checkInformation;
               address char(2);
               income char(2);
               telephone char(2);
             end-ds;

           end-ds;
         end-ds;
       end-ds;

       dcl-ds printme len(132) end-ds;

       dcl-s i int(10);
       dcl-s dateISO date(*ISO);

       data-into result %DATA('/home/alan/jsonex/RcvDtl2.json'
        : 'doc=file case=any countprefix=num_ allowmissing=yes allowextra=yes')
        %PARSER('YAJLINTO');

       for i = 1 to result.body.num_value;
         printme = result.body.value(i).businessNo + ' '
                 + result.body.value(i).orderNo + ' ';
         write QSYSPRT printme;
       endfor;

       *inlr = *on;
