      * ILE RPG example of a REST provider with multiple parameters                                 
      *  using YAJL to generate the JSON data.                                                      
      *                                                                                             
      * This gets it's input parameters from the URL, in a format                                   
      * like this:                                                                                  
      *                                                                                             
      *    http://whatever/rest/jsonwebsrv/495/20100901/20100930                                    
      *                                                                                             
      * It will then look up all invoices for the customer number                                   
      * in the provided date range, and output them all in a                                        
      * list like this one:                                                                         
      *                                                                                             
      *     [                                                                                       
      *       {                                                                                     
      *         "invoice": "xyz",                                                                   
      *         "date": "01/30/2012",                                                               
      *         "name": "Acme Industries, Inc.",                                                    
      *         "amount": 123.45,                                                                   
      *         "weight": 123.45,                                                                   
      *       },                                                                                    
      *       { same fields again },                                                                
      *       { same fields again },                                                                
      *       { etc }                                                                               
      *     ]                                                                                       
      *                                                                                             
      * To compile:                                                                                 
      *> CRTSQLRPGI JSONWEBSRV SRCFILE(QRPGLESRC) DBGVIEW(*SOURCE) -                                
      *>            OBJTYPE(*MODULE)                                                                
      *> CRTPGM JSONWEBSRV BNDSRVPGM(QHTTPSVR/QZHBCGI) ACTGRP(KLEMENT)                              
      *                                                                                             
     H OPTION(*SRCSTMT) BNDDIR('YAJL') DECEDIT('0.')                                                
                                                                                                    
      /include yajl_h                                                                               
                                                                                                    
     D getenv          PR              *   extproc('getenv')                                        
     D   var                           *   value options(*string)                                   
                                                                                                    
     D QtmhWrStout     PR                  extproc('QtmhWrStout')                                   
     D   DtaVar                  100000a   options(*varsize) const                                  
     D   DtaVarLen                   10I 0 const                                                    
     D   ErrorCode                 8000A   options(*varsize)                                        
                                                                                                    
     D err             ds                  qualified                                                
     D   bytesProv                   10i 0 inz(0)                                                   
     D   bytesAvail                  10i 0 inz(0)                                                   
                                                                                                    
     D CCSID           S             10i 0 inz(0)                                                   
     D charVar         s            500a   varying                                                  
     D bigCharVar      s         100000A                                                            
     D length          s             10i 0                                                          
     D CRLF            C                   X'0d25'                                                  
                                                                                                    
     D row             ds                  qualified                                                
     D   inv                          5a                                                            
     D   date                         8s 0                                                          
     D   name                        25a                                                            
     D   amount                       9p 2                                                          
     D   weight                       9p 1                                                          
                                                                                                    
     D uri             s           5000a   varying                                                  
     d custpos         s             10i 0                                                          
     d sdatepos        s             10i 0                                                          
     d edatepos        s             10i 0                                                          
     D cust            s              4s 0                                                          
     D sdate           s              8s 0                                                          
     D edate           s              8s 0                                                          
     D dateUSA         s             10a   varying                                                  
     D httpStatus      s              3p 0                                                          
                                                                                                    
     D success         s              1n                                                            
     D errMsg          s            500a   varying                                                  
                                                                                                    
      /free                                                                                         
       exec SQL set option naming=*SYS;                                                             
       *inlr = *on;                                                                                 
                                                                                                    
       monitor;                                                                                     
          uri = %str(getenv('REQUEST_URI'));                                                        
          custpos = %scan('/jsonwebsrv/': uri) + %len('/jsonwebsrv/');                              
          sdatepos = %scan('/': uri: custpos) + 1;                                                  
          edatepos = %scan('/': uri: sdatepos) + 1;                                                 
          cust  = %int(%subst(uri: custpos: (sdatepos-custpos-1)));                                 
          sdate = %int(%subst(uri: sdatepos: (edatepos-sdatepos-1)));                               
          edate = %int(%subst(uri: edatepos));                                                      
       on-error;                                                                                    
          success = *off;                                                                           
          errmsg = 'invalid URI!';                                                                  
          exsr JSON_Start;                                                                          
          exsr JSON_Finish;                                                                         
          exsr JSON_Save;                                                                           
          return;                                                                                   
       endmon;                                                                                      
                                                                                                    
       exec SQL declare C1 cursor for                                                               
           select aiOrdn, aiIDat, aiSNme, aiDamt, aiLbs                                             
             from ARSHIST                                                                           
            where aiCust=:cust                                                                      
              and aiIDat between :sdate and :edate;                                                 
                                                                                                    
       exec SQL open C1;                                                                            
       exec SQL fetch next from C1 into :row;                                                       
                                                                                                    
       if sqlstt<>'00000'                                                                           
          and %subst(sqlstt:1:2) <> '01'                                                            
          and %subst(sqlstt:1:2) <> '02';                                                           
          success = *off;                                                                           
          errmsg = 'SQL state ' + SQLSTT + ' querying file';                                        
       else;                                                                                        
          success = *on;                                                                            
          errmsg = '';                                                                              
       endif;                                                                                       
                                                                                                    
       exsr JSON_Start;                                                                             
                                                                                                    
       dow sqlstt='00000' or %subst(sqlstt:1:2)='01';                                               
          exsr JSON_AddRow;                                                                         
          exec SQL fetch next from C1 into :row;                                                    
       enddo;                                                                                       
                                                                                                    
       exec SQL close C1;                                                                           
                                                                                                    
       exsr JSON_Finish;                                                                            
       exsr JSON_Save;                                                                              
       return;                                                                                      
                                                                                                    
       begsr JSON_Start;                                                                            
                                                                                                    
         yajl_genOpen(*ON);  // use *ON for easier to read JSON                                     
                             //    *OFF for more compact JSON                                       
                                                                                                    
         yajl_beginObj();                                                                           
         yajl_addBool('success': success );                                                         
         yajl_addChar('errmsg': errMsg );                                                           
         yajl_beginArray('list');                                                                   
                                                                                                    
       endsr;                                                                                       
                                                                                                    
       begsr JSON_addRow;                                                                           
                                                                                                    
          dateUsa = %char( %date(row.date:*iso) : *usa );                                           
                                                                                                    
          yajl_beginObj();                                                                          
          yajl_addChar('invoice': row.inv );                                                        
          yajl_addChar('date': dateUsa );                                                           
          yajl_addChar('name': %trim(row.name));                                                    
          yajl_addNum('amount': %char(row.amount));                                                 
          yajl_addNum('weight': %char(row.weight));                                                 
          yajl_endObj();                                                                            
                                                                                                    
       endsr;                                                                                       
                                                                                                    
       begsr JSON_Finish;                                                                           
                                                                                                    
          yajl_endArray();                                                                          
          yajl_endObj();                                                                            
                                                                                                    
       endsr;                                                                                       
                                                                                                    
       begsr JSON_Save;                                                                             
                                                                                                    
          if (success);                                                                             
             httpStatus = 200;                                                                      
          else;                                                                                     
             httpStatus = 500;                                                                      
          endif;                                                                                    
                                                                                                    
          CharVar = 'Status: ' + %char(httpStatus) + CRLF                                           
                  + 'Content-type: text/plain' + CRLF                                               
                  + CRLF;                                                                           
          QtmhWrStout( charVar : %len(charVar): err );                                              
                                                                                                    
          yajl_copyBuf( CCSID                                                                       
                      : %addr(bigCharVar)                                                           
                      : %size(bigCharVar)                                                           
                      : length );                                                                   
                                                                                                    
          yajl_genClose();                                                                          
                                                                                                    
          QtmhWrStout( bigCharVar : length: err );                                                  
                                                                                                    
       endsr;                                                                                       
