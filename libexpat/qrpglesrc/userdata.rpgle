      * Demonstration of using the XML_SetUserData() API to eliminate
      * the need for global variables to pass data back & forth from
      * Expat's handler functions.
      *
      *                             Scott Klement, March 31, 2005
      *
      * To compile:
      *   (Requires V5R2 for nested data structures)
      *   CRTBNDRPG USERDATA SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE':'EXPAT')

     FQSYSPRT   O    F  132        PRINTER

      /copy ifsio_h
      /copy errno_h
      /copy expat_h

     D start           PR
     D   d                                 likeds(mydata)
     D   elem                     16383C   const options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)
     D end             PR
     D   d                                 likeds(mydata)
     D   elem                     16383C   const options(*varsize)
     D chardata        PR
     D   d                                 likeds(mydata)
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D blanks          s            132A
     D Buff            s           8192A
     D PrintMe         s            132A   varying

     D address_t       ds                  qualified
     D   type                        10A
     D   name                        30A
     D   addr1                       30A
     D   addr2                       30A
     D   city                        13A
     D   state                        2A
     D   zip                         10A

     D item_t          ds                  qualified
     D   qty                          9P 0
     D   desc                        30A
     D   cost                         9P 2

     D mydata          ds                  qualified
     D   depth                       10I 0 inz
     D   stack                     1024A   varying inz
     D                                     dim(50)
     D   id                          10A
     D   shipto                            likeds(address_t)
     D   billto                            likeds(address_t)
     D   count                       10I 0 inz
     D   item                              likeds(item_t)
     D                                     dim(100)

     D fd              s             10I 0
     D p               s                   like(XML_Parser)
     D len             s             10I 0
     D done            s             10I 0
     D x               s             10I 0

      /free

         //
         //  Open XML document to parse
         //

         fd = open('testdoc/testdoc.xml': O_RDONLY);
         if (fd < 0);
           EscErrno(errno);
         endif;

         //
         // Create a "parser object" in memory that
         // will be used to parse the document.
         //

         p = XML_ParserCreate(*OMIT);
         if (p = *NULL);
           callp close(fd);
           die('Couldn''t allocate memory for parser');
         endif;

         //
         // Register subprocedures to be called for the
         // starting and ending elements of an XML document
         //

         XML_SetStartElementHandler(p: %paddr(start));
         XML_SetEndElementHandler(p: %paddr(end));
         XML_SetCharacterDataHandler(p: %paddr(chardata));
         XML_SetUserData(p: %addr(mydata));

         //
         // The following loop will read data from the XML
         // document, and feed it into the XML parser
         //
         // The parser will call the "start" and "end"
         // as the correct data is fed to it, and they'll
         // load the data into the array.
         //

         dou (done = 1);

             len = read(fd: %addr(Buff): %size(Buff));

             if (len < 1);
                done = 1;
             endif;

             if (XML_Parse(p: Buff: len: done) = XML_STATUS_ERROR);
                 callp close(fd);
                 die('Parse error at line '
                    + %char(XML_GetCurrentLineNumber(p)) + ': '
                    + %str(XML_ErrorString(XML_GetErrorCode(p))));
             endif;

         enddo;

         //
         // Done parsing... clean up!
         //

         XML_ParserFree(p);
         callp close(fd);

         //
         //  Invoice is now loaded into the "mydata" array.
         //  it can now be printed, or whatever you like...
         //

         PrintMe = 'Invoice #' + mydata.id;
         except Print;

         PrintMe = 'Ship to: ' + mydata.shipto.name + '   '
                 + 'Bill to: ' + mydata.billto.name;
         except Print;

         PrintMe = '         ' + mydata.shipto.addr1 + '   '
                 + '         ' + mydata.billto.addr1;
         except Print;

         PrintMe = '         ' + mydata.shipto.city
                 +         ' ' + mydata.shipto.state
                 +         ' ' + mydata.shipto.zip + '      '
                 + '         ' + mydata.billto.city
                 +         ' ' + mydata.billto.state
                 +         ' ' + mydata.billto.zip;
         except Print;

         for x = 1 to mydata.count;

            PrintMe = 'Qty:'  + %editc(mydata.item(x).qty: 'L') + ' '
                    + 'Desc:' + mydata.item(x).desc             + ' '
                    + 'Cost:' + %editc(mydata.item(x).cost: 'L');
            except Print;

         endfor;

         *inlr = *on;
      /end-free

     OQSYSPRT   E            Print
     O                       PrintMe            132


     P start           B
     D start           PI
     D   d                                 likeds(mydata)
     D   elem                     16383C   const options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)

     D len             s             10I 0
     D elemName        s            100C   varying
     D attrData        s          16383C   based(p_Attr)
     D attrName        s            100C   varying
     D attrVal         s            100C   varying
     D x               s             10I 0

      /free
         d.depth = d.depth + 1;

         len = %scan(u'0000': elem) - 1;
         elemName = %subst(elem:1:len);

         if (d.depth = 1);
            d.stack(d.depth) = '/' + %char(elemName);
         else;
            d.stack(d.depth) = d.stack(d.depth-1) + '/' + %char(elemName);
         endif;

         // -----------------------------------------
         // process XML element attributes
         // -----------------------------------------

         x = 1;
         dow attr(x) <> *NULL;

            p_attr   = attr(x);
            len      = %scan(U'0000': attrData) - 1;
            attrName = %subst(attrData:1:len);

            p_attr   = attr(x+1);
            len      = %scan(U'0000': attrData) - 1;
            attrVal  = %subst(attrData:1:len);

            select;
            when d.stack(d.depth) = '/invoice'
                 and attrName = %ucs2('id');
               d.id = %char(attrVal);

            when d.stack(d.depth) = '/invoice/ShipTo/address'
                 and attrName = %ucs2('type');
               d.shipto.type = %char(attrVal);

            when d.stack(d.depth) = '/invoice/BillTo/address'
                 and attrName = %ucs2('type');
               d.billto.type = %char(attrVal);
            endsl;

            x = x + 2;
         enddo;

         // -----------------------------------------
         //  change to next array element when a
         //  new item tag is found.
         // -----------------------------------------

         if d.stack(d.depth) = '/invoice/itemList/item';
            d.count = d.count + 1;
         endif;

      /end-free
     P                 E


     P end             B
     D end             PI
     D   d                                 likeds(mydata)
     D   elem                     16383C   const options(*varsize)
      /free
          d.depth = d.depth - 1;
      /end-free
     P                 E


     P chardata        B
     D chardata        PI
     D   d                                 likeds(mydata)
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D x               s             10I 0
     D val             s            132C   varying
      /free

         val = %subst(string:1:len);

         // -----------------------------------------
         //  map new value to the returned data,
         //  using the Xpath
         // -----------------------------------------

         //  Ship-To info:

         select;
         when  d.stack(d.depth) = '/invoice/ShipTo/name';
           d.shipto.name = %char(val);
         when  d.stack(d.depth) = '/invoice/ShipTo/address/addrLine1';
           d.shipto.addr1 = %char(val);
         when  d.stack(d.depth) = '/invoice/ShipTo/address/addrLine2';
           d.shipto.addr2 = %char(val);
         when  d.stack(d.depth) = '/invoice/ShipTo/address/city';
           d.shipto.city = %char(val);
         when  d.stack(d.depth) = '/invoice/ShipTo/address/state';
           d.shipto.state = %char(val);
         when  d.stack(d.depth) = '/invoice/ShipTo/address/zipCode';
           d.shipto.zip = %char(val);

         //  Bill-To info:

         when  d.stack(d.depth) = '/invoice/BillTo/name';
           d.billto.name = %char(val);
         when  d.stack(d.depth) = '/invoice/BillTo/address/addrLine1';
           d.billto.addr1 = %char(val);
         when  d.stack(d.depth) = '/invoice/BillTo/address/addrLine2';
           d.billto.addr2 = %char(val);
         when  d.stack(d.depth) = '/invoice/BillTo/address/city';
           d.billto.city = %char(val);
         when  d.stack(d.depth) = '/invoice/BillTo/address/state';
           d.billto.state = %char(val);
         when  d.stack(d.depth) = '/invoice/BillTo/address/zipCode';
           d.billto.zip = %char(val);

         //  Line items:

         when  d.stack(d.depth) = '/invoice/itemList/item/qty';
           d.item(d.count).qty = %dec(%char(val): 9: 0);
         when  d.stack(d.depth) = '/invoice/itemList/item/desc';
           d.item(d.count).desc = %char(val);
         when  d.stack(d.depth) = '/invoice/itemList/item/cost';
           d.item(d.count).cost = %dec(%char(val): 9: 2);
         endsl;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
