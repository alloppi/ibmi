            //---------------------  JSONCRT2  -------------------------//                          
            //  This is the example program to create JSON file                                     
            //----------------------------------------------------------//                          
            ctl-opt  DftActgrp(*No)    BndDir('YAJL')                                               
                     Option(*SrcStmt)  DecEdit('0.');                                               
                                                                                                    
           /copy yajl/qrpglesrc,yajl_h                                                              
                                                                                                    
            dcl-s  i             Int(5);                                                            
            dcl-s  wait          Char(1);                                                           
            dcl-s  errMsg        VarChar(500) Inz;                                                  
                                                                                                    
            // This DS is included just as a comparison with                                        
            //   JSON structure genrated by this program.                                           
                                                                                                    
            // dcl-ds Customers;                                                                    
            //   dcl-ds Customer Dim(3) Qualified;                                                  
            //      Id    Char(7);                                                                  
            //      Name  Char(40);                                                                 
            //      dcl-ds  Address;                                                                
            //       City   Char(30);                                                               
            //       State  Char(2);                                                                
            //     end-ds;                                                                          
            //   end-ds;                                                                            
            // end-ds;                                                                              
                                                                                                    
            // Main Process Begins ...                                                              
                                                                                                    
            yajl_genOpen(*On);                                                                      
                                                                                                    
                                                                                                    
           // In the following code I have attempted to indent the yajl_ calls                      
           //   to indicate the shape of the structure being generated. Hopefully                   
           //   you will find it helpful.                                                           
                                                                                                    
            yajl_beginObj();  // Start the root object                                              
                                                                                                    
              yajl_beginObj('Customers');                                                           
                                                                                                    
                yajl_beginArray('Customer');                                                        
                                                                                                    
                for i = 1 to 3;                                                                     
                                                                                                    
                 yajl_beginObj();                                                                   
                    yajl_addChar('Id': %Char(i));                                                   
                    yajl_addChar('Name': %Char(i));                                                 
                    yajl_beginObj('Address');                                                       
                      yajl_addChar('City': %Char(i));                                               
                      yajl_addChar('State': %Char(i));                                              
                    yajl_endObj();                                                                  
                  yajl_endObj();                                                                    
                                                                                                    
                EndFor;                                                                             
                                                                                                    
                yajl_endArray();  // End Customer array                                             
                                                                                                    
              yajl_endObj();  // End Customers object                                               
                                                                                                    
            yajl_endObj();  // End root object                                                      
                                                                                                    
            yajl_saveBuf('/tmp/JSONCRT2.json': errMsg );                                            
                                                                                                    
            if errMsg <> '';                                                                        
              Dsply 'Error in create JSON !' ' ' Wait;                                              
            EndIf;                                                                                  
                                                                                                    
            yajl_genClose();  // frees up memory                                                    
                                                                                                    
            *InLr = *On;                                                                            
