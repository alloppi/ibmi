     H DFTACTGRP(*NO) ACTGRP(*NEW) OPTION(*SRCSTMT)                                                 
     H BNDDIR('YAJL')                                                                               
                                                                                                    
     FQSYSPRT   O    F  132        PRINTER                                                          
                                                                                                    
      /include yajl_h                                                                               
                                                                                                    
     D list_t          ds                  qualified                                                
     D                                     template                                                 
     D   inv                          5a                                                            
     D   date                         8s 0                                                          
     D   name                        25a                                                            
     D   amount                       9p 2                                                          
     D   weight                       9p 1                                                          
                                                                                                    
     D result          ds                  qualified                                                
     D   success                      1n                                                            
     D   errmsg                     500a   varying                                                  
     D   list                              likeds(list_t) dim(999)                                  
                                                                                                    
     D i               s             10i 0                                                          
     D j               s             10i 0                                                          
     D dateUSA         s             10a                                                            
     D errMsg          s            500a   varying inz('')                                          
                                                                                                    
     D docNode         s                   like(yajl_val)                                           
     D list            s                   like(yajl_val)                                           
     D node            s                   like(yajl_val)                                           
     D val             s                   like(yajl_val)                                           
     D key             s             50a   varying                                                  
                                                                                                    
     D prt             ds                  likeds(list_t)                                           
      /free                                                                                         
                                                                                                    
         docNode = yajl_stmf_load_tree( '/tmp/example.json' : errMsg );                             
         if errMsg <> '';                                                                           
            // handle error                                                                         
         endif;                                                                                     
                                                                                                    
         node = YAJL_object_find(docNode: 'success');                                               
         result.success = YAJL_is_true(node);                                                       
                                                                                                    
         node = YAJL_object_find(docNode: 'errmsg');                                                
         result.errmsg = YAJL_get_string(node);                                                     
                                                                                                    
         list = YAJL_object_find(docNode: 'list');                                                  
                                                                                                    
         i = 0;                                                                                     
         dow YAJL_ARRAY_LOOP( list: i: node );                                                      
                                                                                                    
            j = 0;                                                                                  
            dow YAJL_OBJECT_LOOP( node: j: key: val);                                               
               exsr load_subfield;                                                                  
            enddo;                                                                                  
                                                                                                    
         enddo;                                                                                     
                                                                                                    
         for i = 1 to YAJL_ARRAY_SIZE(list);                                                        
            prt = result.list(i);                                                                   
            except print;                                                                           
         endfor;                                                                                    
                                                                                                    
         *inlr = *on;                                                                               
                                                                                                    
         begsr load_subfield;                                                                       
                                                                                                    
            select;                                                                                 
            when key = 'invoice';                                                                   
               result.list(i).inv = yajl_get_string(val);                                           
            when key = 'date';                                                                      
               dateUSA = yajl_get_string(val);                                                      
               result.list(i).date = %dec(%date(dateUSA:*usa):*iso);                                
            when key = 'name';                                                                      
               result.list(i).name = yajl_get_string(val);                                          
            when key = 'amount';                                                                    
               result.list(i).amount = yajl_get_number(val);                                        
            when key = 'weight';                                                                    
               result.list(i).weight = yajl_get_number(val);                                        
            endsl;                                                                                  
                                                                                                    
         endsr;                                                                                     
                                                                                                    
                                                                                                    
      /end-free                                                                                     
                                                                                                    
     OQSYSPRT   E            PRINT                                                                  
     O                       PRT.INV              5                                                 
     O                       PRT.DATE            17 '    -  -  '                                    
     O                       PRT.NAME            44                                                 
     O                       PRT.AMOUNT    L     56                                                 
     O                       PRT.WEIGHT    L     67                                                 
