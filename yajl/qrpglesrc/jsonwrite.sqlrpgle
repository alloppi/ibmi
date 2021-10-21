     H DFTACTGRP(*NO) ACTGRP(*NEW) OPTION(*SRCSTMT)                                                 
     H BNDDIR('YAJL') DECEDIT('0.')                                                                 
                                                                                                    
      /include yajl_h                                                                               
                                                                                                    
     D row             ds                  qualified                                                
     D   inv                          5a                                                            
     D   date                         8s 0                                                          
     D   name                        25a                                                            
     D   amount                       9p 2                                                          
     D   weight                       9p 1                                                          
                                                                                                    
     D cust            s              4s 0 inz(4997)                                                
     D sdate           s              8s 0 inz(20140101)                                            
     D edate           s              8s 0 inz(20210930)                                            
     D dateUSA         s             10a   varying                                                  
                                                                                                    
     D success         s              1n                                                            
     D errMsg          s            500a   varying                                                  
                                                                                                    
      /free                                                                                         
                                                                                                    
       exec SQL set option naming=*SYS;                                                             
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
       *inlr = *on;                                                                                 
                                                                                                    
       begsr JSON_Start;                                                                            
                                                                                                    
         yajl_genOpen(*OFF);  // use *ON for easier to read JSON                                    
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
                                                                                                    
          yajl_saveBuf('/tmp/example.json': errMsg);                                                
          if errMsg <> '';                                                                          
             // handle error                                                                        
          endif;                                                                                    
                                                                                                    
          yajl_genClose();                                                                          
                                                                                                    
       endsr;                                                                                       
