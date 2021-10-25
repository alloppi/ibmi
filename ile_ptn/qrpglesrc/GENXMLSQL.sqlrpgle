**free

dcl-s XmlData sqltype(xml_clob:3000) ccsid(37) ;
dcl-s Outfile sqltype(clob_File) ;
dcl-s Data sqltype(clob:1000000) ccsid(*utf8) ;

dcl-s Changed varchar(3000) ;
dcl-s Path varchar(100) inz('/home/cya12/OrderSQL.xml') ;

dcl-s ThisCustomer char(10) inz('CUS1') ;
dcl-s StartDate date(*iso) inz(d'2018-04-01') ;

exec sql SET OPTION COMMIT=*NONE, CLOSQLCSR=*ENDMOD, DATFMT=*ISO ;

exec sql VALUES(SELECT XMLGROUP(RTRIM(X1ORD) AS "Order_Number",
                                RTRIM(X1CUST) AS "Customer_Number",
                                X1ORDT AS "Order_Date",
                                X1OTOT AS "Order_Amount"
                       OPTION ROW "Order" ROOT "New_Orders")
                       FROM OHEAD
                       WHERE X1CUST  = :ThisCustomer
                         AND X1ORDT >= :StartDate)
          INTO :XmlData ;

clear Outfile ;
Outfile_Name = %trimr(Path) ;
Outfile_NL = %len(%trimr(Outfile_Name)) ;
Outfile_FO = SQFCRT ;

Changed = XmlData_Data ;
Data_Data = %scanrpl('IBM037':'UTF-8':Changed) ;
Data_Len = %len(%trimr(Data_Data)) ;

exec sql SET :Outfile = :Data ;

*inlr = *on ;
