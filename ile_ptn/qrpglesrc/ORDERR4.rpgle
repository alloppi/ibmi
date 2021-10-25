      *  ORDERR4 -- Business Logic Service Program for placing orders
      *             here at Acme Widgets.
      *
      *  To compile:
      *
      *> CRTSQLRPGI OBJ(ORDERR4) OBJTYPE(*MODULE) -
      *>            SRCFILE(QRPGLESRC) DBGVIEW(*SOURCE)
      *> CRTSRVPGM SRVPGM(ORDERR4) SRCFILE(QSRVSRC)
      *> DLTMOD ORDERR4
      *
      *> RUNSQLSTM SRCFILE(QSQLSRC) SRCMBR(CRTPROC) -
      *>           COMMIT(*NONE) ERRLVL(20)
     H NOMAIN

     FORDHEAD   UF A E           K DISK    USROPN
     FORDITEM   UF A E           K DISK    USROPN
     FCUSTFILE  IF   E           K DISK    USROPN
     FITEMFILE  IF   E           K DISK    USROPN
     FCTRLFILE  UF A E           K DISK    USROPN

      /copy QRPGLESRC,ORDER_H

     D openFiles       PR
     D getNewOrderNo   PR             8a
     D setError        PR
     D   ErrId                        7a   const
     D   ErrMsg                      80a   varying const

     D Error           ds                  qualified
     D   MsgId                        7a
     D   Msg                         80a   varying
     D ORDER_new_sp    PR
     D   CustNo                       6p 0 const
     D ORDER_loadHeader_sp...
     D                 PR
     D   OrderNo                     10a   const
     D ORDER_loadItems_sp...
     D                 PR
     D   OrderNo                     10a   const
     D ORDER_saveHeader_sp...
     D                 PR
     D   OrderNo                     10a   const
     D   CustNo                       6p 0 const
     D   SCAC                         4a   const
     D   ShipName                    30a   const
     D   ShipAddr1                   30a   const
     D   ShipAddr2                   30a   const
     D   ShipAddr3                   30a   const
     D   BillName                    30a   const
     D   BillAddr1                   30a   const
     D   BillAddr2                   30a   const
     D   BillAddr3                   30a   const
     D   ShipDate                    10a   const
     D ORDER_saveItem_sp...
     D                 PR
     D   OrderNo                     10a   const
     D   LineNo                       3p 0 const
     D   ItemNo                       8a   const
     D   Qty                          5p 0 const
     D   Price                        9p 2 const
     D ORDER_chkItem_sp...
     D                 PR
     D   ItemNo                       8a   const
     D ORDER_chkPrice_sp...
     D                 PR
     D   ItemNo                       8a   const
     D   Price                        9p 2 const
     D ORDER_chkQuantity_sp...
     D                 PR
     D   ItemNo                       8a   const
     D   Qty                          5p 0 const

     D FilesAreOpen    s              1N   inz(*OFF)

      *****************************************************
      *  ORDER_New(): Routine to create a new order.
      *
      *    CustNo = (input) Customer to create order for
      *    Header = (output) new order header with default
      *                      values
      *     Error = (output) error information (if any)
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     P ORDER_new       B                   export
     D ORDER_new       PI             1n
     D   CustNo                       6p 0 const
     D   Header                            likeds(ORDER_Header_t)

     D CUSTFILE1       ds                  likerec(CUSTFILEF:*INPUT)
      /free
         openFiles();

         chain CustNo CUSTFILEF CUSTFILE1;
         if not %found;
            SetError( ORDER_ERROR_CUST_NOT_FOUND
                    : 'Customer ' + %editc(CustNo:'X') + ' not found!');
            return *OFF;
         endif;

         Header.custNo       = CustNo;
         Header.orderNo      = getNewOrderNo();

         Header.shipTo.Name  = CUSTFILE1.ShipName;
         Header.shipTo.Addr1 = CUSTFILE1.shipAddr1;
         Header.shipTo.Addr2 = CUSTFILE1.shipAddr2;
         Header.shipTo.Addr3 = CUSTFILE1.shipAddr3;

         Header.billTo.Name  = CUSTFILE1.BillName;
         Header.billTo.Addr1 = CUSTFILE1.billAddr1;
         Header.billTo.Addr2 = CUSTFILE1.billAddr2;
         Header.billTo.Addr3 = CUSTFILE1.billAddr3;

         Header.SCAC         = CUSTFILE1.SCAC;
         Header.shipDate     = %date() + %days(CUSTFILE1.daysAdv);
         return *ON;

      /end-free
     P                 E

      *****************************************************
      *  ORDER_loadHeader(): Routine to load the header
      *     info from an existing order on disk.
      *
      *   OrderNo = (input)  Order to load from disk
      *    Header = (output) Order header information
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     P ORDER_loadHeader...
     P                 B                   export
     D ORDER_loadHeader...
     D                 PI             1n
     D  OrderNo                      10a   const
     D  Header                             likeds(ORDER_Header_t)

     D ORDHEAD1        ds                  likerec(ORDHEADF:*INPUT)
      /free
        openFiles();

        chain(n) OrderNo ORDHEAD ORDHEAD1;
        if not %found;
           SetError( ORDER_ERROR_ORDER_NOT_FOUND
                   : 'Order ' + OrderNo + ' not found!');
           return *OFF;
        endif;

        Header.OrderNo      = ORDHEAD1.OrderNo;
        Header.CustNo       = ORDHEAD1.CustNo;
        Header.ShipTo.Name  = ORDHEAD1.ShipName;
        Header.ShipTo.Addr1 = ORDHEAD1.ShipAddr1;
        Header.ShipTo.Addr2 = ORDHEAD1.ShipAddr2;
        Header.ShipTo.Addr3 = ORDHEAD1.ShipAddr3;
        Header.BillTo.Name  = ORDHEAD1.BillName;
        Header.BillTo.Addr1 = ORDHEAD1.BillAddr1;
        Header.BillTo.Addr2 = ORDHEAD1.BillAddr2;
        Header.BillTo.Addr3 = ORDHEAD1.BillAddr3;
        Header.SCAC         = ORDHEAD1.SCAC;
        Header.ShipDate     = ORDHEAD1.ShipDate;
        return *ON;

      /end-free
     P                 E


      *****************************************************
      *  ORDER_loadItems(): Routine to load the items
      *     on an existing order on disk.
      *
      *   OrderNo = (input)  Order to load from disk
      *     Count = (output) number of items on order
      *      Item = (output) array of items on order
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     P ORDER_loadItems...
     P                 B                   export
     D ORDER_loadItems...
     D                 PI             1N
     D  OrderNo                      10a   const
     D  Count                         3p 0
     D  Item                               likeds(ORDER_Item_t) dim(999)
     D ORDITEM1        ds                  likerec(ORDITEMF:*INPUT)
      /free
          openFiles();

          Count = 0;

          setll OrderNo ORDITEM;
          reade(n) OrderNo ORDITEMF ORDITEM1;

          dow not %eof(ORDITEM);
             Count += 1;
             Item(Count).LineNo = ORDITEM1.LineNo;
             Item(Count).ItemNo = ORDITEM1.ItemNo;
             Item(Count).Qty    = ORDITEM1.Qty;
             Item(Count).Price  = ORDITEM1.Price;
             Item(Count).Desc   = ORDITEM1.Desc;
             reade(n) OrderNo ORDITEMF ORDITEM1;
          enddo;

          return *ON;
      /end-free
     P                 E


      *****************************************************
      * ORDER_saveHeader(): Save order header information
      *
      *    Header = (input)  Order header information
      *                      to save
      *     Error = (output) error information (if any)
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     P ORDER_saveHeader...
     P                 B                   export
     D ORDER_saveHeader...
     D                 PI             1N
     D  Header                             likeds(ORDER_Header_t) const

     D AddNew          s              1N   inz(*OFF)
     D ORDHEAD1        ds                  likerec(ORDHEADF:*OUTPUT)
      /free
        openFiles();

        chain Header.OrderNo ORDHEADF;
        if not %found();
           AddNew = *ON;
        endif;

        ORDHEAD1.OrderNo   = Header.OrderNo;
        ORDHEAD1.CustNo    = Header.CustNo;
        ORDHEAD1.ShipName  = Header.ShipTo.Name;
        ORDHEAD1.ShipAddr1 = Header.ShipTo.Addr1;
        ORDHEAD1.ShipAddr2 = Header.ShipTo.Addr2;
        ORDHEAD1.ShipAddr3 = Header.ShipTo.Addr3;
        ORDHEAD1.BillName  = Header.BillTo.Name;
        ORDHEAD1.BillAddr1 = Header.BillTo.Addr1;
        ORDHEAD1.BillAddr2 = Header.BillTo.Addr2;
        ORDHEAD1.BillAddr3 = Header.BillTo.Addr3;
        ORDHEAD1.SCAC      = Header.SCAC;
        ORDHEAD1.ShipDate  = Header.ShipDate;

        if (AddNew);
           write ORDHEADF ORDHEAD1;
        else;
           update ORDHEADF ORDHEAD1;
        endif;

        return *ON;
      /end-free
     P                 E


      *****************************************************
      * ORDER_saveItem(): Save line item on order
      *                   or add a new item to order
      *
      *   OrderNo = (input) Order to save item on
      *      Item = (input) Item detail to save
      *                     (set lineno=0 to add a new one)
      *    LineNo = (output) line number assigned to a new
      *                     item on order.
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     P ORDER_saveItem  B                   export
     D ORDER_saveItem  PI             1n
     D  OrderNo                      10a   const
     D  item                               likeds(ORDER_Item_t) const
     D  LineNo                        3p 0 options(*nopass)

     D tempDesc        s             20a
     D AddNew          s              1N   inz(*OFF)
     D ORDHEAD1        ds                  likerec(ORDHEADF:*INPUT)
     D ORDITEM1        ds                  likerec(ORDITEMF:*OUTPUT)
     D ORDITEM2        ds                  likerec(ORDITEMF:*INPUT)
      /free
        openFiles();

        // check valid values

        if (order_chkItem(Item.ItemNo: tempDesc) = *OFF
            or order_chkPrice(Item.ItemNo: item.Price) = *OFF
            or order_chkQuantity(Item.ItemNo: item.Qty) = *OFF );
           return *OFF;
        endif;

        // Lock the header record for ensure that no other job
        // is currently updating this order.

        chain (OrderNo) ORDHEADF ORDHEAD1;
        if not %found;
           SetError( ORDER_ERROR_ORDER_NOT_FOUND
                   : 'Order ' + OrderNo + ' not found!');
           return *OFF;
        endif;

        // If line number given, look up that database record
        // otherwise, calculate a new line item number.

        clear ORDITEM1;

        if (item.LineNo <> 0);
           chain (OrderNo:item.LineNo) ORDITEMF ORDITEM2;
           if not %found;
               SetError( ORDER_ERROR_LINE_NOT_FOUND
                       : 'Order ' + OrderNo + ' has no line #'
                       + %char(item.LineNo));
               unlock ORDHEAD;
               return *OFF;
           endif;
           ORDITEM1 = ORDITEM2;
        else;
           AddNew = *ON;
           setgt     (OrderNo) ORDITEMF;
           readpe(n) (OrderNo) ORDITEMF ORDITEM2;
           if not %eof;
              ORDITEM1.LineNo = ORDITEM2.LineNo + 1;
           else;
              ORDITEM1.LineNo = 1;
           endif;
        endif;

        if %parms >= 3;
           LineNo = ORDITEM1.LineNo;
        endif;

        // Update the fields in the file

        ORDITEM1.OrderNo = OrderNo;
        ORDITEM1.ItemNo  = item.ItemNo;
        ORDITEM1.Qty     = item.Qty;
        ORDITEM1.Price   = item.Price;
        ORDITEM1.Desc    = item.Desc;

        if (AddNew);
           write ORDITEMF ORDITEM1;
        else;
           update ORDITEMF ORDITEM1;
        endif;

        unlock ORDHEAD;
        return *ON;
      /end-free
     P                 E


      *****************************************************
      * ORDER_chkItem(): Check item number & get description
      *
      *      Item = (input) Item detail to save
      *      Desc = (output) item description
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     P ORDER_chkItem   B                   export
     D ORDER_chkItem   PI             1n
     D  ItemNo                        8a   const
     D  Desc                         20a
     D ITEMFILE1       ds                  likerec(ITEMFILEF:*INPUT)
      /free
         openFiles();

         chain ItemNo ITEMFILEF ITEMFILE1;
         if not %found();
            SetError( ORDER_ERROR_ITEM_NOT_FOUND
                    : 'Item ' + ItemNo + ' does not exist.');
            return *OFF;
         endif;

         Desc = ITEMFILE1.Desc;
         return *ON;
      /end-free
     P                 E


      *****************************************************
      * ORDER_chkPrice(): Check the price of an item
      *
      *    ItemNo = (input) Item to check price for
      *     Price = (output) item description
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     P ORDER_chkPrice...
     P                 B                   export
     D ORDER_chkPrice...
     D                 PI             1n
     D  ItemNo                        8a   const
     D  Price                         9p 2 const
     D ITEMFILE1       ds                  likerec(ITEMFILEF:*INPUT)
      /free
         openFiles();

         chain ItemNo ITEMFILEF ITEMFILE1;
         if not %found();
            SetError( ORDER_ERROR_ITEM_NOT_FOUND
                    : 'Item ' + ItemNo + ' does not exist.');
            return *OFF;
         endif;

         if (Price < ITEMFILE1.LowPrice);
            SetError( ORDER_ERROR_LOW_PRICE
                    : 'Price < ' + %char(ITEMFILE1.LowPrice) );
            return *OFF;
         endif;

         if (Price > ITEMFILE1.HighPrice);
            SetError( ORDER_ERROR_HIGH_PRICE
                    : 'Price > ' + %char(ITEMFILE1.HighPrice) );
            return *OFF;
         endif;

         return *ON;
      /end-free
     P                 E


      *****************************************************
      * ORDER_chkQuantity(): Check valid quantity for
      *                        an item
      *
      *    ItemNo = (input) Item to check price for
      *       Qty = (input) proposed quantity
      *     Error = (output) error information (if any)
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     P ORDER_chkQuantity...
     P                 B                   export
     D ORDER_chkQuantity...
     D                 PI             1n
     D  ItemNo                        8a   const
     D  Qty                           5p 0 const
     D ITEMFILE1       ds                  likerec(ITEMFILEF:*INPUT)
      /free
         openFiles();

         chain ItemNo ITEMFILEF ITEMFILE1;
         if not %found();
            SetError( ORDER_ERROR_ITEM_NOT_FOUND
                    : 'Item ' + ItemNo + ' does not exist.');
            return *OFF;
         endif;

         if (Qty < ITEMFILE1.MinQty);
            SetError( ORDER_ERROR_LOW_QTY
                    : 'Must order at least '
                    + %char(ITEMFILE1.MinQty) + ' units.');
            return *OFF;
         endif;

         if (Qty > ITEMFILE1.AvailQty);
            SetError( ORDER_ERROR_HIGH_QTY
                    : 'We only have ' + %char(ITEMFILE1.AvailQty)
                    + ' units in stock.' );
            return *OFF;
         endif;

         return *ON;
      /end-free
     P                 E

      *****************************************************
      * ORDER_error(): Return the last error found
      *
      *    ErrorId = (output) error id number
      *
      * returns the human-readable error message.
      *****************************************************
     P ORDER_error     B                   export
     D ORDER_error     PI            80A   varying
     D   ErrorId                      7a   options(*nopass:*omit)
      /free
         if %parms>=1 and %addr(ErrorId)<>*null;
            ErrorId = Error.MsgId;
         endif;
         return Error.Msg;
      /end-free
     P                 E

      *****************************************************
      * openFiles(): Open files used by this srvpgm
      *****************************************************
     P openFiles       B
     D openFiles       PI
      /free
        if (FilesAreOpen);
           return;
        endif;

        open ORDHEAD;
        open ORDITEM;
        open CUSTFILE;
        open ITEMFILE;
        open CTRLFILE;

        FilesAreOpen=*ON;
        return;

        begsr *pssr;
           close *all;
           FilesAreOpen=*OFF;
        endsr;

      /end-free
     P                 E

      *****************************************************
      * getNewOrderNo(): Retrieve the next order number
      *                  to be used.
      *
      * Note: All order numbers begin with 'A' (for ACME)
      *       followed by a 7-digit incrementing number.
      *****************************************************
     P getNewOrderNo   B
     D getNewOrderNo   PI             8a

     D CTRLFILE1       ds                  likerec(CTRLFILEF:*INPUT)
     D CTRLFILE2       ds                  likerec(CTRLFILEF:*OUTPUT)
      /free
         chain ('ORDHEAD':'ORDERNO') CTRLFILEF CTRLFILE1;

         if not %found;
             CTRLFILE2.FileID  = 'ORDHEAD';
             CTRLFILE2.FieldID = 'ORDERNO';
             CTRLFILE2.CtrlNo  = 1;
             write CTRLFILEF CTRLFILE2;
         else;
             CTRLFILE2 = CTRLFILE1;
             CTRLFILE2.CtrlNo += 1;
             if CTRLFILE2.CtrlNo = *HIVAL;
                CTRLFILE2.CtrlNo = 1;
             endif;
             update CTRLFILEF CTRLFILE2;
         endif;

         return 'A' + %editc(CTRLFILE2.CtrlNo:'X');
      /end-free
     P                 E

      *****************************************************
      * setError():  Set the last error that has occurred
      *              in this program.
      *****************************************************
     P setError        B
     D setError        PI
     D   ErrId                        7a   const
     D   ErrMsg                      80a   varying const
      /free
         Error.MsgId = ErrId;
         Error.Msg   = ErrMsg;
      /end-free
     P                 E


      *****************************************************
      * ORDER_new_sp(): Create a new order for a customer
      *    (Stored procedure interface for Order_new)
      *
      *    CustNo = (input) Customer number to create
      *                     order for.
      *
      *  Returns a result set with one row:
      *
      *      OrderNo = order number assigned
      *       CustNo = customer number
      *         SCAC = Default Shipping Carrier Code
      *     ShipName = Default Ship-To Name
      *    ShipAddr1 = Default Ship-To Address (line 1)
      *    ShipAddr2 = Default Ship-To Address (line 2)
      *    ShipAddr2 = Default Ship-To Address (line 3)
      *     BillName = Default Bill-To Name
      *    BillAddr1 = Default Bill-To Address (line 1)
      *    BillAddr2 = Default Bill-To Address (line 2)
      *    BillAddr2 = Default Bill-To Address (line 3)
      *     ShipDate = Default Ship Date (yyyy-mm-dd format)
      *        MsgId = Error Msg ID (or *blanks = success)
      *          Msg = Error Msg (or *blanks = success)
      *****************************************************
     P ORDER_new_sp    B                   export
     D ORDER_new_sp    PI
     D   CustNo                       6p 0 const
     D Hdr             ds                  likeds(Order_Header_t)

     D RESULT1         ds                  qualified occurs(1)
     D  OrderNo                      10a   inz
     D  CustNo                        6p 0 inz
     D  SCAC                          4a   inz
     D  ShipName                     30a   inz
     D  ShipAddr1                    30a   inz
     D  ShipAddr2                    30a   inz
     D  ShipAddr3                    30a   inz
     D  BillName                     30a   inz
     D  BillAddr1                    30a   inz
     D  BillAddr2                    30a   inz
     D  BillAddr3                    30a   inz
     D  ShipDate                     10a
     D  MsgId                         7a   inz
     D  Msg                          80a   varying inz

     C/exec SQL set option naming=*SYS,commit=*NONE
     C/end-exec

      /free
        %occur(RESULT1) = 1;

        if (ORDER_new(CustNo: hdr));
           Result1.OrderNo   = hdr.OrderNo;
           Result1.SCAC      = hdr.SCAC;
           Result1.CustNo    = hdr.CustNo;
           Result1.ShipName  = hdr.ShipTo.Name;
           Result1.ShipAddr1 = hdr.ShipTo.Addr1;
           Result1.ShipAddr2 = hdr.ShipTo.Addr2;
           Result1.ShipAddr3 = hdr.ShipTo.Addr3;
           Result1.BillName  = hdr.BillTo.Name;
           Result1.BillAddr1 = hdr.BillTo.Addr1;
           Result1.BillAddr2 = hdr.BillTo.Addr2;
           Result1.BillAddr3 = hdr.BillTo.Addr3;
           Result1.ShipDate  = %char(hdr.ShipDate:*ISO);
        else;
           Result1.Msg = ORDER_error(RESULT1.MsgID);
        endif;

      /end-free
     C/exec SQL set Result sets Array :RESULT1 for 1 Rows
     C/end-exec
     P                 E


      *****************************************************
      * ORDER_loadHeader_sp(): Load order header from disk
      *    (Stored procedure interface for ORDER_loadHeader)
      *
      *   OrderNo = (input) Order number to load header from
      *
      *  Returns a result set with one row:
      *
      *      OrderNo = order number
      *       CustNo = customer number
      *         SCAC = Shipping Carrier Code
      *     ShipName = Ship-To Name
      *    ShipAddr1 = Ship-To Address (line 1)
      *    ShipAddr2 = Ship-To Address (line 2)
      *    ShipAddr2 = Ship-To Address (line 3)
      *     BillName = Bill-To Name
      *    BillAddr1 = Bill-To Address (line 1)
      *    BillAddr2 = Bill-To Address (line 2)
      *    BillAddr2 = Bill-To Address (line 3)
      *     ShipDate = Ship Date (yyyy-mm-dd format)
      *        MsgId = Error Msg ID (or *blanks = success)
      *          Msg = Error Msg (or *blanks = success)
      *****************************************************
     P ORDER_loadHeader_sp...
     P                 B                   export
     D ORDER_loadHeader_sp...
     D                 PI
     D   OrderNo                     10a   const
     D Hdr             ds                  likeds(Order_Header_t)

     D Result2         ds                  qualified occurs(1)
     D  OrderNo                      10a   inz
     D  CustNo                        6p 0 inz
     D  SCAC                          4a   inz
     D  ShipName                     30a   inz
     D  ShipAddr1                    30a   inz
     D  ShipAddr2                    30a   inz
     D  ShipAddr3                    30a   inz
     D  BillName                     30a   inz
     D  BillAddr1                    30a   inz
     D  BillAddr2                    30a   inz
     D  BillAddr3                    30a   inz
     D  ShipDate                     10a
     D  MsgId                         7a   inz
     D  Msg                          80a   varying inz
      /free

        %occur(Result2) = 1;

        if (ORDER_loadHeader(OrderNo: hdr));
           Result2.OrderNo   = hdr.OrderNo;
           Result2.SCAC      = hdr.SCAC;
           Result2.CustNo    = hdr.CustNo;
           Result2.ShipName  = hdr.ShipTo.Name;
           Result2.ShipAddr1 = hdr.ShipTo.Addr1;
           Result2.ShipAddr2 = hdr.ShipTo.Addr2;
           Result2.ShipAddr3 = hdr.ShipTo.Addr3;
           Result2.BillName  = hdr.BillTo.Name;
           Result2.BillAddr1 = hdr.BillTo.Addr1;
           Result2.BillAddr2 = hdr.BillTo.Addr2;
           Result2.BillAddr3 = hdr.BillTo.Addr3;
           Result2.ShipDate  = %char(hdr.ShipDate:*ISO);
        else;
           Result2.Msg = ORDER_error(Result2.MsgID);
        endif;

      /end-free
     C/exec SQL set Result sets Array :Result2 for 1 Rows
     C/end-exec
     P                 E


      *****************************************************
      * ORDER_loadItems_sp(): Load items ordered from disk
      *   (Stored procedure interface for ORDER_loadItems)
      *
      *   OrderNo = (input) Order number to load items from
      *
      *  Returns a result set with many rows, one
      *     for each item on the order:
      *
      *       LineNo = Line number within order
      *       ItemNo = item number
      *          Qty = quantity requested
      *        Price = price to sell item for
      *         Desc = description of item
      *        MsgId = Error Msg ID (or *blanks = success)
      *          Msg = Error Msg (or *blanks = success)
      *****************************************************
     P ORDER_loadItems_sp...
     P                 B                   export
     D ORDER_loadItems_sp...
     D                 PI
     D   OrderNo                     10a   const

     D Result3         ds                  qualified occurs(999)
     D  LineNo                        3p 0 inz
     D  ItemNo                        8a   inz
     D  Qty                           5p 0 inz
     D  Price                         9p 2 inz
     D  Desc                         20a   inz
     D  MsgId                         7a   inz
     D  Msg                          80a   varying inz

     D count           s              3p 0
     D item            ds                  likeds(ORDER_item_t) dim(999)
     D x               s              3p 0
      /free

        %occur(Result3) = 1;

        if (ORDER_loadItems(OrderNo: count: item) = *OFF);
           count = 1;
           %occur(Result3) = 1;
           Result3.Msg = ORDER_error(Result3.MsgID);
        else;
           for x = 1 to count;
              %occur(Result3) = x;
              Result3.LineNo  = item(x).LineNo;
              Result3.ItemNo  = item(x).ItemNo;
              Result3.Qty     = item(x).Qty;
              Result3.Price   = item(x).Price;
              Result3.Desc    = item(x).Desc;
           endfor;
        endif;

      /end-free
     C/exec SQL set Result sets Array :Result3 for :COUNT Rows
     C/end-exec
     P                 E


      *****************************************************
      * ORDER_saveHeader_sp(): Save/Write Order Header info
      *    (Stored procedure interface for ORDER_saveHeader)
      *
      *    OrderNo = (input) Order number to save as
      *     CustNo = (input) Customer number to save as
      *       SCAC = (input) Shipping Carrier Code
      *   ShipName = (input) Ship-To Name
      *  ShipAddr1 = (input) Ship-To Address (line 1)
      *  ShipAddr2 = (input) Ship-To Address (line 2)
      *  ShipAddr3 = (input) Ship-To Address (line 3)
      *   BillName = (input) Bill-To Name
      *  BillAddr1 = (input) Bill-To Address (line 1)
      *  BillAddr2 = (input) Bill-To Address (line 2)
      *  BillAddr3 = (input) Bill-To Address (line 3)
      *   ShipDate = (input) Date order is to be shipped
      *                       in yyyy-mm-dd format
      *
      *  Returns a result set with one row:
      *      MsgId = Error Msg ID (or *blanks = success)
      *        Msg = Error Msg (or *blanks = success)
      *****************************************************
     P ORDER_saveHeader_sp...
     P                 B                   export
     D ORDER_saveHeader_sp...
     D                 PI
     D   OrderNo                     10a   const
     D   CustNo                       6p 0 const
     D   SCAC                         4a   const
     D   ShipName                    30a   const
     D   ShipAddr1                   30a   const
     D   ShipAddr2                   30a   const
     D   ShipAddr3                   30a   const
     D   BillName                    30a   const
     D   BillAddr1                   30a   const
     D   BillAddr2                   30a   const
     D   BillAddr3                   30a   const
     D   ShipDate                    10a   const

     D Hdr             ds                  likeds(Order_Header_t)

     D Result4         ds                  qualified occurs(1)
     D  MsgId                         7a   inz
     D  Msg                          80a   varying inz
      /free
         Hdr.OrderNo      = OrderNo;
         Hdr.CustNo       = CustNo;
         Hdr.SCAC         = SCAC;
         Hdr.ShipTo.Name  = ShipName;
         Hdr.ShipTo.Addr1 = ShipAddr1;
         Hdr.ShipTo.Addr2 = ShipAddr2;
         Hdr.ShipTo.Addr3 = ShipAddr3;
         Hdr.BillTo.Name  = BillName;
         Hdr.BillTo.Addr1 = BillAddr1;
         Hdr.BillTo.Addr2 = BillAddr2;
         Hdr.BillTo.Addr3 = BillAddr3;

         monitor;
           Hdr.ShipDate   = %date(ShipDate:*ISO);
         on-error;
           Hdr.ShipDate   = d'9999-12-31';
         endmon;

         %occur(Result4) = 1;

         if ( Order_saveHeader(hdr) = *OFF );
           Result4.Msg = ORDER_error(Result4.MsgID);
         endif;

      /end-free
     C/exec SQL set Result sets Array :Result4 for 1 Rows
     C/end-exec
     P                 E


      *****************************************************
      * ORDER_saveItem_sp(): Save line item data to disk
      *    (Stored procedure interface to Order_saveItem)
      *
      *    OrderNo = (input) Order number to save as
      *     LineNo = (input) Line number to update
      *                       or 0 = new item
      *     ItemNo = (input) Item number to save
      *        Qty = (input) Quantity to order
      *      Price = (input) Price to sell item for
      *
      *  Returns a result set with one row:
      *
      *     LineNo = Line number saved under
      *      MsgId = Error Msg ID (or *blanks = success)
      *        Msg = Error Msg (or *blanks = success)
      *****************************************************
     P ORDER_saveItem_sp...
     P                 B                   export
     D ORDER_saveItem_sp...
     D                 PI
     D   OrderNo                     10a   const
     D   LineNo                       3p 0 const
     D   ItemNo                       8a   const
     D   Qty                          5p 0 const
     D   Price                        9p 2 const

     D Result5         ds                  qualified occurs(1)
     D  LineNo                        3p 0 inz
     D  MsgId                         7a   inz
     D  Msg                          80a   varying inz

     D ITEM            ds                  likeds(ORDER_Item_t)

      /free
         Item.ItemNo = ItemNo;
         Item.LineNo = LineNo;
         Item.Qty    = Qty;
         Item.Price  = Price;

         if ( Order_saveItem(OrderNo: Item: Result5.LineNo) = *OFF);
           Result5.Msg = ORDER_error(Result5.MsgID);
         endif;

      /end-free
     C/exec SQL set Result sets Array :Result5 for 1 Rows
     C/end-exec
     P                 E


      *****************************************************
      * ORDER_chkItem_sp(): Check if item no is valid
      *   (Stored procedure interface to ORDER_chkItem)
      *
      *    ItemNo = (input) Item number to check
      *
      *  Returns a result set with one row:
      *
      *    Desc = Description of item (if valid)
      *   MsgId = Error Msg ID (or *blanks = success)
      *     Msg = Error Msg (or *blanks = success)
      *****************************************************
     P ORDER_chkItem_sp...
     P                 B                   export
     D ORDER_chkItem_sp...
     D                 PI
     D   ItemNo                       8a   const

     D Result6         ds                  qualified occurs(1)
     D  Desc                         20a   inz
     D  MsgId                         7a   inz
     D  Msg                          80a   varying inz
      /free

           %occur(Result6) = 1;

           if ( Order_ChkItem(ItemNo: Result6.Desc) = *OFF);
              Result6.Msg = ORDER_error(Result6.MsgID);
           endif;

      /end-free
     C/exec SQL set Result sets Array :Result6 for 1 Rows
     C/end-exec
     P                 E


      *****************************************************
      * ORDER_chkPrice_sp(): Check if price is valid for
      *        a given item number
      *   (Stored procedure interface for ORDER_chkPrice)
      *
      *    ItemNo = (input) Item number
      *     Price = (input) Price to check
      *
      *  Returns a result set with one row:
      *
      *   MsgId = Error Msg ID (or *blanks = success)
      *     Msg = Error Msg (or *blanks = success)
      *****************************************************
     P ORDER_chkPrice_sp...
     P                 B                   export
     D ORDER_chkPrice_sp...
     D                 PI
     D   ItemNo                       8a   const
     D   Price                        9p 2 const

     D Result7         ds                  qualified occurs(1)
     D  MsgId                         7a   inz
     D  Msg                          80a   varying inz
      /free

           %occur(Result7) = 1;

           if ( Order_ChkPrice(ItemNo: Price) = *OFF);
              Result7.Msg = ORDER_error(Result7.MsgID);
           endif;

      /end-free
     C/exec SQL set Result sets Array :Result7 for 1 Rows
     C/end-exec
     P                 E


      *****************************************************
      * ORDER_chkQuantity_sp(): Check if quantity of item
      *     is valid for a given item number
      *   (Stored procedure interface for ORDER_ChkQuantity)
      *
      *    ItemNo = (input) Item number
      *       Qty = (input) Quantity to check
      *
      *  Returns a result set with one row:
      *
      *   MsgId = Error Msg ID (or *blanks = success)
      *     Msg = Error Msg (or *blanks = success)
      *****************************************************
     P ORDER_chkQuantity_sp...
     P                 B                   export
     D ORDER_chkQuantity_sp...
     D                 PI
     D   ItemNo                       8a   const
     D   Qty                          5p 0 const

     D Result8         ds                  qualified occurs(1)
     D  MsgId                         7a   inz
     D  Msg                          80a   varying inz
      /free

           %occur(Result8) = 1;

           if ( Order_ChkQuantity(ItemNo: Qty) = *OFF);
              Result8.Msg = ORDER_error(Result8.MsgID);
           endif;

      /end-free
     C/exec SQL set Result sets Array :Result8 for 1 Rows
     C/end-exec
     P                 E
