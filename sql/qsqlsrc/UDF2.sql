/* Drop SQL function first                 */
Drop Function EXTPRICE;

/* Extended Price User define SQL function */
Create Function ALAN/EXTPRICE(
  qty dec(9,0),
  price dec(11,2),
  discount dec(5,2))
returns dec(11,2)
language RPGLE
deterministic
no SQL
external name 'ALAN/MYSERVICE(EXTPRICE)'
parameter style GENERAL
program type SUB;

/* Our new Query */
/* Select O1ITEM, O1DESC,                     */
/* EXTPRICE(O1QTY,O1PRICE,O1DISC) from OTABLE */
