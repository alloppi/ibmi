            //-----------------------------------------------------//
            // Test program that builds the JSON employee array
            //    shown in the article. The code is not descibed
            //    in the article but follows the same basic pattern
            //-----------------------------------------------------//

            ctl-opt  DftActgrp(*No)    BndDir('YAJL/YAJL')
                     Option(*SrcStmt)  DecEdit('0.');

           /copy yajl/qrpglesrc,yajl_h

            dcl-s  i             Int(5);
            dcl-s  wait          Char(1);
            dcl-s  errMsg        VarChar(500) Inz;
            dcl-s  string        VarChar(500) Inz;

            //-------------------------------------------------------------//
            // The following DS array and subsequent "fill" logic are used
            //    to avoid having to use data files to provide test data
            //-------------------------------------------------------------//

            dcl-ds employees  Dim(3)  Qualified;
              firstName  Char(30);
              lastname   Char(30);
            end-ds;

            // Initialize the test data array
            employees(1).firstName = 'Alan';
            employees(1).lastname  = 'Chan';
            employees(2).firstName = 'Lam';
            employees(2).lastname  = 'Chan';
            employees(3).firstName = 'Paul';
            employees(3).lastname  = 'Au';

            //----------------------------//
            // Begin program's main logic
            //----------------------------//

            yajl_genOpen(*On); // Start generation with "pretty" format

            yajl_beginObj();   // Start root object

            yajl_beginArray('employees');  // Begin employees array

            for i = 1 to %Elem(employees); // Process all employees
              // Create employee object complete with first and lastname variables
              yajl_beginObj();
              yajl_addChar('firstName': %Trim(employees(i).firstName));
              yajl_addChar('lastName': %Trim(employees(i).lastName));
              yajl_endObj();
            EndFor;

            yajl_endArray(); // Close the employee array

            yajl_endObj();   // And the root object

            // Generation is complete so write JSON to IFS file
            yajl_saveBuf('/tmp/JSONCRT1.json': errMsg );

            string = YAJL_copyBufStr();

            if errMsg <> '';  // Check if any error was detected
              Dsply 'Error in create JSON !' ' ' Wait;
            EndIf;

            yajl_genClose();  // frees up memory

            *InLr = *On;

