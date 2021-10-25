Create Table ORDHEADF (
    OrderNo   character(10) not null,
    CustNo    numeric(6,0)  not null,
    ShipName  character(30) not null,
    ShipAddr1 character(30) not null,
    ShipAddr2 character(30) not null,
    ShipAddr3 character(30) not null,
    BillName  character(30) not null,
    BillAddr1 character(30) not null,
    BillAddr2 character(30) not null,
    BillAddr3 character(30) not null,
    SCAC      character(4)  not null,
    ShipDate  Date          not null,
  Primary Key (OrderNo)
);

Create Table ORDITEMF (
    OrderNo   character(10) not null,
    LineNo    numeric(3,0)  not null,
    ItemNo    character(8)  not null,
    Desc      character(20) not null,
    Price     numeric(9,2)  not null,
    Qty       numeric(5,0)  not null,
  Primary Key (OrderNo,LineNo)
);

Create Table CUSTFILEF (
    CustNo    numeric(6,0)  not null,
    ShipName  character(30) not null,
    ShipAddr1 character(30) not null,
    ShipAddr2 character(30) not null,
    ShipAddr3 character(30) not null,
    BillName  character(30) not null,
    BillAddr1 character(30) not null,
    BillAddr2 character(30) not null,
    BillAddr3 character(30) not null,
    SCAC      character(4)  not null,
    daysAdv   numeric(3,0)  not null,
  Primary Key (CustNo)
);

Create Table ITEMFILEF (
    ItemNo    character(8)  not null,
    Desc      character(20) not null,
    LowPrice  numeric(9,2)  not null,
    HighPrice numeric(9,2)  not null,
    MinQty    numeric(5,0)  not null,
    AvailQty  numeric(5,0)  not null,
  Primary Key (ItemNo)
);

Create Table CTRLFILEF (
    FileId    character(10) not null,
    FieldId   character(10) not null,
    CtrlNo    numeric(7,0) not null,
  Primary Key (FileId,FieldId)
);
