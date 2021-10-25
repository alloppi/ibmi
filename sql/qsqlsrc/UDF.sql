/* Drop SQL function first                 */
Drop Function EXTPRICE;
/* Extended Price User define SQL function */
Create Function ALAN/EXTPRICE(
  qty dec(9,0),
  price dec(11,2),
  discount dec(5,2))
returns dec(11,2)
language SQL
BEGIN
  return( qty * (price * cast((1 - discount/100) as dec(11,2))));
END;

/* Our new Query */
/* Select O1ITEM, O1DESC,                     */
/* EXTPRICE(O1QTY,O1PRICE,O1DISC) from OTABLE */
