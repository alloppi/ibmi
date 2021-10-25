      *  ORDER_H -- Prototypes, constants and structures needed to call
      *             ORDERR4 routines from ILE RPG.  See ORDERR4 for
      *             more details.
      *
      /if defined(ORDER_H_DEFINED)
      /eof
      /endif
      /define ORDER_H_DEFINED

     D ORDER_ERROR_CUST_NOT_FOUND...
     D                 c                   const('ORD1101')
     D ORDER_ERROR_ORDER_NOT_FOUND...
     D                 c                   const('ORD1102')
     D ORDER_ERROR_LINE_NOT_FOUND...
     D                 c                   const('ORD1103')
     D ORDER_ERROR_ITEM_NOT_FOUND...
     D                 c                   const('ORD1104')
     D ORDER_ERROR_LOW_PRICE...
     D                 c                   const('ORD1105')
     D ORDER_ERROR_HIGH_PRICE...
     D                 c                   const('ORD1106')
     D ORDER_ERROR_LOW_QTY...
     D                 c                   const('ORD1107')
     D ORDER_ERROR_HIGH_QTY...
     D                 c                   const('ORD1108')
     D
      *****************************************************
      * Template for an customer's address
      *****************************************************
     D Order_Address_t...
     D                 ds                  qualified
     D                                     based(Template)
     D   Name                        30a
     D   Addr1                       30a
     D   Addr2                       30a
     D   addr3                       30a

      *****************************************************
      * Template for an error message
      *****************************************************
     D Order_Error_t   ds                  qualified
     D                                     based(Template)
     D   MsgId                        7a
     D   Text                       200a   varying

      *****************************************************
      * Template for 1 line of an order
      *****************************************************
     D Order_Item_t    ds                  qualified
     D                                     based(Template)
     D   LineNo                       3p 0
     D   ItemNo                       8a
     D   Qty                          5p 0
     D   Price                        9p 2
     D   Desc                        20a


      *****************************************************
      * Template representing header info for an order
      *****************************************************
     D Order_Header_t  ds                  qualified
     D                                     based(Template)
     D  OrderNo                      10a
     D  CustNo                        6p 0
     D  ShipTo                             likeds(Order_Address_t)
     D  BillTo                             likeds(Order_Address_t)
     D  SCAC                          4a
     D  ShipDate                       D   datfmt(*iso)

      *****************************************************
      *  Order_New(): Routine to create a new order.
      *
      *    CustNo = (input) Customer to create order for
      *    Header = (output) new order header with default
      *                      values
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     D Order_new       PR             1n   extproc(*CL:'ORDER_new')
     D   CustNo                       6p 0 const
     D   Header                            likeds(Order_Header_t)


      *****************************************************
      *  Order_loadHeader(): Routine to load the header
      *     info from an existing order on disk.
      *
      *   OrderNo = (input)  Order to load from disk
      *    Header = (output) Order header information
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     D Order_loadHeader...
     D                 PR             1N   extproc(*CL:'ORDER_loadHeader')
     D  OrderNo                      10a   const
     D  Header                             likeds(Order_Header_t)


      *****************************************************
      *  Order_loadItems(): Routine to load the items
      *     on an existing order on disk.
      *
      *   OrderNo = (input)  Order to load from disk
      *     Count = (output) number of items on order
      *      Item = (output) array of items on order
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     D Order_loadItems...
     D                 PR             1N   extproc(*CL:'ORDER_loadItems')
     D  OrderNo                      10a   const
     D  Count                         3p 0
     D  Item                               likeds(Order_Item_t) dim(999)


      *****************************************************
      * Order_saveHeader(): Save order header information
      *
      *    Header = (input)  Order header information
      *                      to save
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     D Order_saveHeader...
     D                 PR             1N   extproc(*CL:'ORDER_saveHeader')
     D  Header                             likeds(Order_Header_t) const


      *****************************************************
      * Order_saveItem(): Save line item on order
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
     D Order_saveItem  PR             1n   extproc(*CL:'ORDER_saveItem')
     D  OrderNo                      10a   const
     D  item                               likeds(Order_Item_t) const
     D  LineNo                        3p 0 options(*nopass)


      *****************************************************
      * Order_chkItem(): Check Item No & get Description
      *
      *      Item = (input) Item detail to save
      *      Desc = (output) item description
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     D Order_chkItem   PR             1n   extproc(*CL:'ORDER_chkItem')
     D  ItemNo                        8a   const
     D  Desc                         20a


      *****************************************************
      * Order_chkPrice(): Check the price of an item
      *
      *    ItemNo = (input) Item to check price for
      *     Price = (output) item description
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     D Order_chkPrice...
     D                 PR             1n   extproc(*CL:'ORDER_chkPrice')
     D  ItemNo                        8a   const
     D  Price                         9p 2 const


      *****************************************************
      * Order_checkQuantity(): Check valid quantity for
      *                        an item
      *
      *    ItemNo = (input) Item to check price for
      *       Qty = (input) proposed quantity
      *
      * Returns *ON when successful, *OFF otherwise.
      *****************************************************
     D Order_chkQuantity...
     D                 PR             1n   extproc(*CL:'ORDER_chkQuantity')
     D  ItemNo                        8a   const
     D  Qty                           5p 0 const


      *****************************************************
      * ORDER_error(): Return the last error found
      *
      *    ErrorId = (output) error id number
      *
      * returns the human-readable error message.
      *****************************************************
     D ORDER_error     PR            80A   varying extproc('ORDER_error')
     D   ErrorId                      7a   options(*nopass:*omit)
