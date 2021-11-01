       // DATA-INTO Sample program DATAINTOJ1
       //
       // To make it easy for you to test this code I have embedded the
       //   JSON a constant in the prorgam. I also supplied a copy of the
       //   same data in file DataIntoJ1.json
       //
       // See program DATAINTOJ2 to see the differences when reading the
       //   JSON from a file.

       dcl-c  jsonData  '{ "Orders" : [ +
                { "Customer" : "B012345", "Items" : +
                    [ { "Code" : "12-345", "Quantity" : 120 }, +
                      { "Code" : "12-678", "Quantity" : 10 } ] } , +
                { "Customer" : "C123456", "Items" : +
                    [ { "Code" : "23-456", "Quantity" : 50 }, +
                      { "Code" : "26-789", "Quantity" : 3 }, +
                      { "Code" : "34-567", "Quantity" : 5 } ] } +
                      ] }';

(E)    dcl-ds  orders Dim(99) Qualified;
(F)       customer     char(7);
(I)       count_items  int(5);
(G)       dcl-ds  items  Dim(20);
(H)          code      char(6);
             quantity  packed(5);
          end-ds  items;
       end-ds orders;

       dcl-ds *N psds;
         count Int(20) Pos(372);
       end-ds;

       dcl-s i      Int(5);
       dcl-s o      Int(5);

       dcl-s reply  Char(1);

       DATA-INTO orders  %Data( jsonData:
                                'case=any countprefix=count_')
                         %Parser('QOAR/JSONPARSE');

       For o = 1 to count;
          Dsply ( 'Customer: ' + orders(o).customer + ' ordered '
                + %Char(orders(o).count_items) + ' items');
          For i = 1 to orders(o).count_items;
             Dsply ( 'Item: ' + orders(o).items(i).code
                   + ' quantity: ' + %Char(orders(o).items(i).quantity) );
          EndFor;
       EndFor;

       Dsply ( 'Processed ' + %char(count) + ' orders' );
       Dsply ( 'Press <Enter> to end program' ) ' ' reply;

       *InLR = *On;
