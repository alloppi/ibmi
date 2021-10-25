      * ACMEORDR4 -- 5250 User Interface & Control Logic for placing
      *    an order here at Acme Widgets.
      *
      * To compile:
      *
      *  -- Compile ORDERR4 first --
      *> CRTDSPF FILE(ACMEORDS) SRCFILE(QDDSSRC)
      *> CRTRPGMOD MODULE(ACMEORDR4) SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *> CRTPGM PGM(ACMEORDR4) BNDSRVPGM(ORDERR4) ACTGRP(ACME)
      *> DLTMOD MODULE(ACMEORDR4)
      *
     FACMEORDS  CF   E             WORKSTN INDDS(DspFunc)
     F                                     SFILE(ACMEORD3S: RRN3)

      /copy QRPGLESRC,ORDER_H

     D getOrder        PR             1N
     D   Order                             like(Order_header_t.OrderNo)
     D   Cust                              like(Order_header_t.CustNo)
     D loadOrder       PR             1N
     D   Order                             like(Order_header_t.OrderNo)
     D   Cust                              like(Order_header_t.CustNo) const
     D editHeader      PR             1N
     D editItems       PR             1N
     D chkSfl          PR             1N
     D saveItems       PR             1N
     D   Order                             like(Order_header_t.OrderNo) const
     D saveHeader      PR             1N
     D   Order                             like(Order_header_t.OrderNo) const
     D validNum        PR             1N
     D   Char                        15a   const
     D confirm         PR
     D   Order                       10a   const

     D DspFunc         ds                  qualified
     D   Exit                         1n   overlay(DspFunc:03)
     D   Cancel                       1n   overlay(DspFunc:12)
     D   ClearSfl                     1n   overlay(DspFunc:50)

     D RRN3            s              4s 0
     D HighRRN         s                   like(RRN3)
     D Order           s                   like(Order_header_t.OrderNo)
     D Cust            s                   like(Order_header_t.CustNo)
     D Step            s             10i 0

      /free

         select;
         when   step = 0;
             if (getOrder(Order:Cust)=*OFF);
                *inlr = *on;
                return;
             else;
                 step = step + 1;
             endif;

         when   step = 1;
             if ( loadOrder(Order:Cust) = *OFF );
                 step = step - 1;
             else;
                 step = step + 1;
             endif;

         when   step = 2;
             if ( editHeader() = *OFF );
                 step = 0;
             else;
                 step = step + 1;
             endif;

         when   step = 3;
             if ( editItems() = *OFF );
                 step = step - 1;
             else;
                 step = step + 1;
             endif;

         when   step = 4;
             if ( saveHeader(Order) = *OFF
                or saveItems(Order) = *OFF );
                 step = step - 1;
             else;
                 step = step + 1;
             endif;

         other;
             confirm(Order);
             step = 0;
         endsl;

      /end-free


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * getOrder(): Ask user for order number to edit,
      *             or enter a customer number to create new order
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getOrder        B
     D getOrder        PI             1N
     D   Order                             like(Order_header_t.OrderNo)
     D   Cust                              like(Order_header_t.CustNo)
      /free

       dou scErrMsg = *blanks;

           exfmt ACMEORDS1;
           scErrMsg = *Blanks;

           if (dspFunc.Exit);
              return *OFF;
           endif;

           if scOrder<>*blanks and scCust<>0;
              scErrMsg = 'Please provide one or the other!';
           endif;

           if scOrder=*blanks and scCust=0;
              scErrMsg = 'You must provide either a customer +
                          or order number';
           endif;

       enddo;

       Order = scOrder;
       Cust  = scCust;
       return *ON;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * loadOrder():  Load an order into memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P loadOrder       B
     D loadOrder       PI             1N
     D   Order                             like(Order_header_t.OrderNo)
     D   Cust                              like(Order_header_t.CustNo) const
     D Count           s              3p 0
     D rc              s              1n
     D Hdr             ds                  likeds(Order_header_t)
     D Item            ds                  likeds(Order_Item_t) dim(999)
     D x               s             10i 0
      /free

       if (Order <> *blanks);
         rc = Order_loadHeader(Order: Hdr);
       else;
         rc = Order_new(Cust: Hdr);
         Order = Hdr.OrderNo;
       endif;

       if (rc = *OFF);
          scErrMsg = Order_error();
          return *OFF;
       endif;

       if (not Order_LoadItems( Order: Count: Item));
          scErrMsg = Order_error();
          return *OFF;
       endif;

       scCust  = Hdr.CustNo;

       scShip1 = Hdr.ShipTo.Name;
       scShip2 = Hdr.ShipTo.Addr1;
       scShip3 = Hdr.ShipTo.Addr2;
       scShip4 = Hdr.ShipTo.Addr3;

       scBill1 = Hdr.BillTo.Name;
       scBill2 = Hdr.BillTo.Addr1;
       scBill3 = Hdr.BillTo.Addr2;
       scBill4 = Hdr.BillTo.Addr3;

       scTruck = Hdr.SCAC;
       scShipDate = %char(Hdr.ShipDate:*ISO);

       DspFunc.ClearSfl = *ON;
       write ACMEORD3C;
       DspFunc.ClearSfl = *OFF;
       RRN3 = 0;

       for x = 1 to Count;
          scLine  = Item(x).LineNo;
          scItem  = Item(x).ItemNo;
          scQty   = %char(Item(x).Qty);
          scPrice = %char(Item(x).Price);
          scDesc  = Item(x).Desc;
          scMsg   = *blanks;
          RRN3 += 1;
          write ACMEORD3S;
       endfor;

       clear ACMEORD3S;

       dow RRN3 < 999;
          RRN3 += 1;
          write ACMEORD3S;
       enddo;

       HighRRN = RRN3;
       return *ON;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * editHeader(): Let user change order header info
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P editHeader      B
     D editHeader      PI             1N
      /free

       dou scErrMsg = *blanks;
          exfmt ACMEORDS2;
          scErrMsg = *blanks;
          if (DspFunc.Cancel);
             return *OFF;
          endif;

        // FIXME: We should also validate the data on this
        //        screen.
        //  order_CheckAddress();
        //  order_CheckAddress();
        //  order_CheckTruckline();
        //  order_CheckShipDate();

       enddo;

       return *ON;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * editHeader(): Let user change item on orders
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P editItems       B
     D editItems       PI             1N

     D errFree         s             10i 0
      /free

        dou errFree>=2;

          write ACMEORD3F;
          exfmt ACMEORD3C;
          scErrMsg = *blanks;

          if (dspfunc.CANCEL);
             return *OFF;
          endif;

          if chkSfl();
             errFree = 1;
          else;
             errFree +=1;
          endif;

        enddo;

        return *ON;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * chkSfl(): Check the contents of the subfile for errors
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P chkSfl          B
     D chkSfl          PI             1N
     D Changes         s              1N   inz(*OFF)
     D Errors          s              1N   inz(*OFF)
      /free

         readc ACMEORD3S;
         if not %eof;
            Changes = *ON;
         endif;

         for RRN3 = 1 to HighRRN;

            chain RRN3 ACMEORD3S;
            if (not %found);
               iter;
            endif;
            scMsg = *Blanks;

            if (scItem=*blanks and scPrice=*blanks and scQty=*blanks);
               scDesc = *Blanks;
               update ACMEORD3S;
               iter;
            endif;

            select;
            when scMsg <> *blanks;
            when ORDER_chkItem(scItem: scDesc) = *OFF;
               scMsg = Order_error();
               errors = *ON;
            when validNum(scPrice) = *OFF;
               scMsg = 'Invalid Price.';
               errors = *ON;
            when ORDER_chkPrice(scItem: %dec(scPrice:9:2)) = *OFF;
               scMsg = Order_error();
               errors = *ON;
            when validNum(scQty) = *OFF;
               scMsg = 'Invalid Qty';
               errors = *ON;
            when ORDER_chkQuantity(scItem: %dec(scQty:5:0)) = *OFF;
               scMsg = Order_error();
               errors = *ON;
            endsl;

            update ACMEORD3S;

         endfor;

         if (errors);
            changes = *ON;
            scErrMsg = 'Please fix errors and press <ENTER>';
         else;
            scErrMsg = 'No errors found. Press <ENTER> to save order';
         endif;

         return Changes;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  saveItems():  Save item information back to disk
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P saveItems       B
     D saveItems       PI             1N
     D   Order                             like(Order_header_t.OrderNo) const
     D Item            ds                  likeds(Order_item_t)
      /free
         for RRN3 = 1 to HighRRN;

            chain RRN3 ACMEORD3S;
            if (not %found);
               iter;
            endif;

            if (scDesc=*blanks and scLine=0);
               iter;
            endif;

            Item.LineNo = scLine;
            Item.ItemNo = scItem;
            Item.Qty    = %dec(scQty:5:0);
            Item.Price  = %dec(scPrice:9:2);
            Item.Desc   = scDesc;

            if (Order_saveItem(Order: Item) = *OFF);
               scErrMsg = Order_error();
               return *OFF;
            endif;

         endfor;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * saveHeader(): Save order header information to disk
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P saveHeader      B
     D saveHeader      PI             1N
     D   Order                             like(Order_header_t.OrderNo) const

     D Hdr             ds                  likeds(Order_header_t)
      /free

       Hdr.OrderNo      = Order;
       Hdr.CustNo       = scCust;
       Hdr.ShipTo.Name  = scShip1;
       Hdr.ShipTo.Addr1 = scShip2;
       Hdr.ShipTo.Addr2 = scShip3;
       Hdr.ShipTo.Addr3 = scShip4;

       Hdr.BillTo.Name  = scBill1;
       Hdr.BillTo.Addr1 = scBill2;
       Hdr.BillTo.Addr2 = scBill3;
       Hdr.BillTo.Addr3 = scBill4;

       Hdr.SCAC         = scTruck;
       Hdr.ShipDate     = %date(scShipDate:*ISO);

       if Order_saveHeader(hdr) = *Off;
           scErrMsg = Order_error();
           return *OFF;
       else;
           return *ON;
       endif;

       begsr *pssr;
          return *OFF;
       endsr;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Check if a character field contains a valid number
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P validNum        B
     D validNum        PI             1N
     D   Char                        15a   const

     D rc              s              1N
     D num             s             10p 3
      /free
         if %check('0123456789 .-,': Char) <> 0;
            return *OFF;
         endif;
         monitor;
            num = %dec(char:10:3);
            rc = *ON;
         on-error;
            rc = *OFF;
         endmon;
         return rc;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * confirm(): Show a screen confirming that order was placed
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P confirm         B
     D confirm         PI
     D   Order                       10a   const
      /free
         scOrder = Order;
         exfmt ACMEORDS4;
         clear scOrder;
         clear scCust;
         clear scErrMsg;
      /end-free
     P                 E
