       ctl-opt DFTACTGRP(*NO) OPTION(*SRCSTMT) BNDDIR('YAJL');                                      
                                                                                                    
       dcl-f QSYSPRT printer(132);                                                                  
                                                                                                    
       /include yajl_h                                                                              
                                                                                                    
       dcl-ds result qualified;                                                                     
         success ind;                                                                               
         errmsg varchar(500);                                                                       
         num_list int(10);                                                                          
                                                                                                    
         dcl-ds list dim(999);                                                                      
           invoice char(5);                                                                         
           date char(10);                                                                           
           name char(25);                                                                           
           amount packed(9: 2);                                                                     
           weight packed(9: 1);                                                                     
         end-ds;                                                                                    
       end-ds;                                                                                      
                                                                                                    
       dcl-ds printme len(132) end-ds;                                                              
                                                                                                    
       dcl-s i int(10);                                                                             
       dcl-s dateISO date(*ISO);                                                                    
                                                                                                    
       data-into result %DATA('/tmp/example.json'                                                   
                             : 'doc=file case=any countprefix=num_')                                
                        %PARSER('YAJLINTO');                                                        
                                                                                                    
       for i = 1 to result.num_list;                                                                
         dateISO = %date(result.list(i).date:*USA);                                                 
         printme = result.list(i).invoice + ' '                                                     
                 + %char(dateISO:*ISO) + ' '                                                        
                 + result.list(i).name + ' '                                                        
                 + %editc(result.list(i).amount:'L') + ' '                                          
                 + %editc(result.list(i).weight:'L');                                               
         write QSYSPRT printme;                                                                     
       endfor;                                                                                      
                                                                                                    
       *inlr = *on;                                                                                 
