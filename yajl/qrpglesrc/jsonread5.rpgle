     H DFTACTGRP(*NO) ACTGRP(*NEW) OPTION(*SRCSTMT)                                                 
     H BNDDIR('YAJL')                                                                               
                                                                                                    
     FQSYSPRT   O    F  132        PRINTER                                                          
                                                                                                    
      /include yajl_h                                                                               
                                                                                                    
      *--------------------------------------------------------------*                              
      * Work variables                                                                              
     D docNode         s                   like(yajl_val)                                           
     D objNode2        s                   like(yajl_val)                                           
     D objNode3        s                   like(yajl_val)                                           
     D objNode4        s                   like(yajl_val)                                           
     D objNode5        s                   like(yajl_val)                                           
     D objNode6        s                   like(yajl_val)                                           
     D objNode7        s                   like(yajl_val)                                           
     D objNode8        s                   like(yajl_val)                                           
     D objNode9        s                   like(yajl_val)                                           
     D arrayNode2      s                   like(yajl_val)                                           
     D arrayNode3      s                   like(yajl_val)                                           
     D arrayNode4      s                   like(yajl_val)                                           
     D arrayNode5      s                   like(yajl_val)                                           
     D arrayNode6      s                   like(yajl_val)                                           
     D arrayNode7      s                   like(yajl_val)                                           
     D arrayNode8      s                   like(yajl_val)                                           
     D arrayNode9      s                   like(yajl_val)                                           
     D key             s             50a   varying                                                  
      *                                                                                             
     D errMsg          s            500a   varying                                                  
      *                                                                                             
     D data            S          65535a   varying                                                  
     D dataSize        S             10i 0                                                          
      *                                                                                             
     D o2              S             10i 0                                                          
     D o3              S             10i 0                                                          
     D o4              S             10i 0                                                          
     D o5              S             10i 0                                                          
     D o6              S             10i 0                                                          
     D o7              S             10i 0                                                          
     D o8              S             10i 0                                                          
     D o9              S             10i 0                                                          
      *                                                                                             
     D a2              S             10i 0                                                          
     D a3              S             10i 0                                                          
     D a4              S             10i 0                                                          
     D a5              S             10i 0                                                          
     D a6              S             10i 0                                                          
     D a7              S             10i 0                                                          
     D a8              S             10i 0                                                          
     D a9              S             10i 0                                                          
      *                                                                                             
     D keyPath         s             50a                                                            
     D prvPath         s             50a                                                            
     D KeyVal          s             79a                                                            
                                                                                                    
      *--------------------------------------------------------------*                              
      /free                                                                                         
                                                                                                    
       docNode = yajl_stmf_load_tree( '/tmp/example.json' : errMsg );                               
                                                                                                    
       if (docNode <> *NULL);                                                                       
                                                                                                    
         select;                                                                                    
                                                                                                    
         when (YAJL_IS_OBJECT(docNode));                                                            
           data = 'JSON Object';                                                                    
           dataSize = YAJL_OBJECT_SIZE(docNode);                                                    
           o2 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(docNode: o2: key: objNode2);                                        
             exsr load_objLvl2;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(docNode));                                                             
           data = 'JSON Array';                                                                     
           dataSize = YAJL_ARRAY_SIZE(docNode);                                                     
           a2 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(docNode: a2: arrayNode2);                                            
             exsr load_arrayLvl2;                                                                   
           enddo;                                                                                   
                                                                                                    
         endsl;                                                                                     
                                                                                                    
       else;                                                                                        
         errMsg = 'No JSON data';                                                                   
       endif;                                                                                       
                                                                                                    
       yajl_tree_free(docNode);                                                                     
                                                                                                    
       *INLR = *on;                                                                                 
                                                                                                    
      *--------------------------------------------------------------*                              
       begsr load_objLvl2;                                                                          
                                                                                                    
         keyPath = *blank;                                                                          
         keyPath = %trim(keyPath) + %trim(key);                                                     
         prvPath = keyPath;                                                                         
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(objNode2));                                                           
           data = yajl_get_string(objNode2);                                                        
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(objNode2));                                                           
           data = %char(yajl_get_number(objNode2));                                                 
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(objNode2));                                                             
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(objNode2));                                                            
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(objNode2));                                                           
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(objNode2);                                                   
           o3 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(objNode2: o3: key: objNode3);                                       
             exsr load_objLvl3;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(objNode2));                                                            
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(objNode2);                                                    
           a3 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(objNode2: a3: arrayNode3);                                           
             exsr load_arrayLvl3;                                                                   
           enddo;                                                                                   
                                                                                                    
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
      *--------------------------------------------------------------*                              
       begsr load_arrayLvl2;                                                                        
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(arrayNode2));                                                         
           data = yajl_get_string(arrayNode2);                                                      
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(arrayNode2));                                                         
           data = %char(yajl_get_number(arrayNode2));                                               
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(arrayNode2));                                                           
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(arrayNode2));                                                          
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(arrayNode2));                                                         
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(arrayNode2);                                                 
           o3 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(arrayNode2: o3: key: objNode3);                                     
             exsr load_objLvl3;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(arrayNode2));                                                          
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(arrayNode2);                                                  
           a3 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(arrayNode2: a3: arrayNode3);                                         
             exsr load_arrayLvl3;                                                                   
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
      *--------------------------------------------------------------*                              
       begsr load_objLvl3;                                                                          
                                                                                                    
         keyPath = %trim(prvPath) + '/' + %trim(key);                                               
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(objNode3));                                                           
           data = yajl_get_string(objNode3);                                                        
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(objNode3));                                                           
           data = %char(yajl_get_number(objNode3));                                                 
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(objNode3));                                                             
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(objNode3));                                                            
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(objNode3));                                                           
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(objNode3);                                                   
           o4 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(objNode3: o4: key: objNode4);                                       
             exsr load_objLvl4;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(objNode3));                                                            
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(objNode3);                                                    
           a4 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(objNode3: a4: arrayNode4);                                           
             exsr load_arrayLvl4;                                                                   
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
                                                                                                    
      *--------------------------------------------------------------*                              
       begsr load_arrayLvl3;                                                                        
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(arrayNode3));                                                         
           data = yajl_get_string(arrayNode3);                                                      
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(arrayNode3));                                                         
           data = %char(yajl_get_number(arrayNode3));                                               
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(arrayNode3));                                                           
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(arrayNode3));                                                          
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(arrayNode3));                                                         
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(arrayNode3);                                                 
           o4 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(arrayNode3: o4: key: objNode4);                                     
             exsr load_objLvl4;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(arrayNode3));                                                          
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(arrayNode3);                                                  
           a4 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(arrayNode3: a4: arrayNode4);                                         
             exsr load_arrayLvl4;                                                                   
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
                                                                                                    
      *--------------------------------------------------------------*                              
       begsr load_objLvl4;                                                                          
                                                                                                    
         keyPath = %trim(prvPath) + '/' + %trim(key);                                               
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(objNode4));                                                           
           data = yajl_get_string(objNode4);                                                        
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(objNode4));                                                           
           data = %char(yajl_get_number(objNode4));                                                 
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(objNode4));                                                             
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(objNode4));                                                            
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(objNode4));                                                           
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(objNode4);                                                   
           o5 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(objNode4: o5: key: objNode5);                                       
             exsr load_objLvl5;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(objNode4));                                                            
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(objNode4);                                                    
           a5 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(objNode4: a5: arrayNode5);                                           
             exsr load_arrayLvl5;                                                                   
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
                                                                                                    
      *--------------------------------------------------------------*                              
       begsr load_arrayLvl4;                                                                        
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(arrayNode4));                                                         
           data = yajl_get_string(arrayNode4);                                                      
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(arrayNode4));                                                         
           data = %char(yajl_get_number(arrayNode4));                                               
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(arrayNode4));                                                           
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(arrayNode4));                                                          
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(arrayNode4));                                                         
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(arrayNode4);                                                 
           o5 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(arrayNode4: o5: key: objNode5);                                     
             exsr load_objLvl5;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(arrayNode4));                                                          
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(arrayNode4);                                                  
           a5 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(arrayNode4: a5: arrayNode5);                                         
             exsr load_arrayLvl5;                                                                   
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
                                                                                                    
      *--------------------------------------------------------------*                              
       begsr load_objLvl5;                                                                          
                                                                                                    
         keyPath = %trim(prvPath) + '/' + %trim(key);                                               
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(objNode5));                                                           
           data = yajl_get_string(objNode5);                                                        
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(objNode5));                                                           
           data = %char(yajl_get_number(objNode5));                                                 
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(objNode5));                                                             
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(objNode5));                                                            
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(objNode5));                                                           
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(objNode5);                                                   
           o6 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(objNode5: o6: key: objNode6);                                       
             exsr load_objLvl6;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(objNode5));                                                            
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(objNode5);                                                    
           a6 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(objNode4: a6: arrayNode6);                                           
             exsr load_arrayLvl6;                                                                   
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
                                                                                                    
      *--------------------------------------------------------------*                              
       begsr load_arrayLvl5;                                                                        
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(arrayNode5));                                                         
           data = yajl_get_string(arrayNode5);                                                      
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(arrayNode5));                                                         
           data = %char(yajl_get_number(arrayNode5));                                               
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(arrayNode5));                                                           
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(arrayNode5));                                                          
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(arrayNode5));                                                         
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(arrayNode5);                                                 
           o6 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(arrayNode5: o6: key: objNode6);                                     
             exsr load_objLvl6;                                                                     
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(arrayNode5));                                                          
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(arrayNode5);                                                  
           a6 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(arrayNode5: a6: arrayNode6);                                         
             exsr load_arrayLvl6;                                                                   
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
                                                                                                    
      *--------------------------------------------------------------*                              
       begsr load_objLvl6;                                                                          
                                                                                                    
         keyPath = %trim(prvPath) + '/' + %trim(key);                                               
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(objNode6));                                                           
           data = yajl_get_string(objNode6);                                                        
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(objNode6));                                                           
           data = %char(yajl_get_number(objNode6));                                                 
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(objNode6));                                                             
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(objNode6));                                                            
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(objNode6));                                                           
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(objNode6);                                                   
           o7 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(objNode6: o7: key: objNode7);                                       
             // exsr load_objLvl7;                                                                  
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(objNode6));                                                            
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(objNode6);                                                    
           a7 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(objNode4: a7: arrayNode7);                                           
             // exsr load_arrayLvl7;                                                                
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
                                                                                                    
      *--------------------------------------------------------------*                              
       begsr load_arrayLvl6;                                                                        
                                                                                                    
         data = *blank;                                                                             
         dataSize = 0;                                                                              
                                                                                                    
         select;                                                                                    
         when (YAJL_IS_STRING(arrayNode6));                                                         
           data = yajl_get_string(arrayNode6);                                                      
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_NUMBER(arrayNode6));                                                         
           data = %char(yajl_get_number(arrayNode6));                                               
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_TRUE(arrayNode6));                                                           
           data = 'true';                                                                           
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_FALSE(arrayNode6));                                                          
           data = 'false';                                                                          
           keyVal = %trim(data);                                                                    
           except print;                                                                            
                                                                                                    
         when (YAJL_IS_OBJECT(arrayNode6));                                                         
           data = 'JSON Sub-Object';                                                                
           dataSize = YAJL_OBJECT_SIZE(arrayNode6);                                                 
           o7 = 0;                                                                                  
           dow YAJL_OBJECT_LOOP(arrayNode6: o7: key: objNode7);                                     
             // exsr load_objLvl7;                                                                  
           enddo;                                                                                   
                                                                                                    
         when (YAJL_IS_ARRAY(arrayNode6));                                                          
           data = 'JSON Sub-Array';                                                                 
           dataSize = YAJL_ARRAY_SIZE(arrayNode6);                                                  
           a7 = 0;                                                                                  
           dow YAJL_ARRAY_LOOP(arrayNode6: a7: arrayNode7);                                         
             // exsr load_arrayLvl7;                                                                
           enddo;                                                                                   
         endsl;                                                                                     
                                                                                                    
       endsr;                                                                                       
                                                                                                    
      /end-free                                                                                     
                                                                                                    
     OQSYSPRT   E            PRINT                                                                  
     O                       KeyPath             51                                                 
     O                       KeyVal             132                                                 
                                                                                                    
