     H DFTACTGRP(*NO) ACTGRP(*NEW) OPTION(*SRCSTMT)                                                 
     H BNDDIR('YAJL')                                                                               
                                                                                                    
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
                                                                                                    
     D docNode         s                   like(yajl_val)                                           
     D list            s                   like(yajl_val)                                           
     D node            s                   like(yajl_val)                                           
     D val             s                   like(yajl_val)                                           
                                                                                                    
     D i               s             10i 0                                                          
     D lastElem        s             10i 0                                                          
     D dateUSA         s             10a                                                            
     D errMsg          s            500a   varying inz('')                                          
                                                                                                    
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
                                                                                                    
            lastElem = i;                                                                           
                                                                                                    
            val = YAJL_object_find(node: 'invoice');                                                
            result.list(i).inv = yajl_get_string(val);                                              
                                                                                                    
            val = YAJL_object_find(node: 'date');                                                   
            dateUSA = yajl_get_string(val);                                                         
            result.list(i).date = %dec(%date(dateUSA:*usa):*iso);                                   
                                                                                                    
            val = YAJL_object_find(node: 'name');                                                   
            result.list(i).name = yajl_get_string(val);                                             
                                                                                                    
            val = YAJL_object_find(node: 'amount');                                                 
            result.list(i).amount = yajl_get_number(val);                                           
                                                                                                    
            val = YAJL_object_find(node: 'weight');                                                 
            result.list(i).weight = yajl_get_number(val);                                           
                                                                                                    
         enddo;                                                                                     
                                                                                                    
         yajl_tree_free(docNode);                                                                   
                                                                                                    
         *inlr = *on;                                                                               
