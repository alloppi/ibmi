      * Refer: https://www.mysamplecode.com/2013/05/sql-user-defined-functions-as400.html
      * create extended price subprocedure by compile service program
      * CRTRPGMOD MODULE(ALAN/MYSERVICE) SRCFILE(ALAN/SQLUDF) SRCMBR(MYSERVICE)
      * CRTSRVPGM SRVPGM(ALAN/MYSERVICE) MODULE(ALAN/MYSERVICE) EXPORT(*ALL)
      *
      * Drop the user Define SQL function first:
      *   Drop function EXTPRICE
      * Create the user Define SQL function:
      *   Create Function ALAN/EXTPRICE(
      *     qty dec(9,0),
      *     price dec(11,2),
      *     discount dec(5,2))
      *   returns dec(11,2)
      *   language RPGLE
      *   deterministic
      *   no SQL
      *   external name 'SQLDEMO/MYSERVICE(EXTPRICE)'
      *   parameter style GENERAL
      *   program type SUB

      * Run the query and check the results
      *   Select O1ITEM, O1DESC,
      *   EXTPRICE(O1QTY,O1PRICE,O1DISC) from OTABLE

      * Service Program for User Defined SQL functions
     h option(*nodebugio)

     d extPrice        PR            11p 2 ExtProc('EXTPRICE')
     d qty                            9p 0 const
     d price                         11p 2 const
     d discount                       5p 2 const

     c                   move      *on           *inlr
     c                   return

     P extPrice        B                   export
     d extPrice        PI            11p 2
     d qty                            9p 0 const
     d price                         11p 2 const
     d discount                       5p 2 const

     d $extPrice       s             11p 2

      /free

        //you can do complex routines here such as reading files,
        //calling other programs, etc.

        $extPrice = qty * (price * (1 - discount * .01));
        return $extPrice;

      /end-free

     P                 E

