      * Demonstration of using Expat's namespace support in RPG
      *                            Scott Klement, March 15, 2007
      *
      *  To compile:
      *     - make sure LIBEXPAT is in your library list.
      *     crtbndrpg namespace srcfile(libexpat/qrpglesrc) dbgview(*LIST)
      *
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE':'EXPAT')

     FQSYSPRT   O    F  132        PRINTER

      /copy ifsio_h
      /copy errno_h
      /copy expat_h

     D start           PR
     D   UserData                      *   value
     D   elem                     16363C   const options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)

     D end             PR
     D   UserData                      *   value
     D   elem                     16363C   const options(*varsize)

     D chardata        PR
     D   UserData                      *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D Buff            s           8192A

     D count           s             10I 0 inz(0)

     D item_t          ds                  qualified
     D   sku                         15a
     D   desc                        30a
     D   price                        9s 2

     D invoice         ds                  qualified
     D   id                          15a
     D   name                        30a
     D   street                      30a
     D   city                        30a
     D   state                       30a
     D   country                     30a
     D   item                              likeds(item_t)
     D                                     dim(100)

     D Prt             ds           132

     D INVOICE_NAMESPACE...
     D                 C                   %ucs2('http://www.scottklement-
     D                                     .com/xml/schemas/invoice')

     D depth           s             10I 0
     D stack           s            512C   varying dim(32)
     D stackval        s            512C   varying dim(32)
     D stackns         s            400C   varying dim(32)

     D fd              s             10I 0
     D p               s                   like(XML_Parser)
     D len             s             10I 0
     D done            s             10I 0
     D x               s             10I 0

      /free


         //
         //  Open XML document to parse.
         //  Ask the open() API to translate it into UTF-8 so
         //  that Expat will understand it.
         //

         fd = open( 'testdoc/nameSpaceDemo.xml'
                  : O_RDONLY );
         if (fd < 0);
           EscErrno(errno);
         endif;

         //
         // Create a "parser object" in memory that
         // will be used to parse the document.
         //

         p = XML_ParserCreateNS(*OMIT: x'0C');
         if (p = *NULL);
           callp close(fd);
           die('Couldn''t allocate memory for parser');
         endif;

         //
         // Register subprocedures to be called for the
         // starting and ending elements of an XML document
         //

         XML_SetStartElementHandler( p : %paddr(start) );
         XML_SetEndElementHandler( p : %paddr(end) );
         XML_SetCharacterDataHandler( p : %paddr(chardata) );

         //
         // The following loop will read data from the XML
         // document, and feed it into the XML parser
         //
         // The parser will call the "start" and "end"
         // as the correct data is fed to it.
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


         // for the sake of demonstration, print the fields:

         prt = 'invoice.id      = ' + invoice.id;
         write QSYSPRT prt;
         prt = 'invoice.name    = ' + invoice.name;
         write QSYSPRT prt;
         prt = 'invoice.street  = ' + invoice.street;
         write QSYSPRT prt;
         prt = 'invoice.city    = ' + invoice.city;
         write QSYSPRT prt;
         prt = 'invoice.state   = ' + invoice.state;
         write QSYSPRT prt;
         prt = 'invoice.country = ' + invoice.country;
         write QSYSPRT prt;

         for x = 1 to count;
             prt = invoice.item(x).sku + ' '
                 + invoice.item(x).desc + ' '
                 + %editc(invoice.item(x).price:'L');
             write QSYSPRT prt;
         endfor;

         *inlr = *on;
      /end-free


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Expat calls this at the start of each element
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P start           B
     D start           PI
     D   userdata                      *   value
     D   elem                     16363C   const options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)

     D len             s             10I 0
     D elemName        s            400C   varying
     D nameSpace       s            400C   varying
     D attrData        s          16383C   based(p_Attr)
     D attrName        s            100C   varying
     D attrVal         s            200C   varying
     D nspos           s             10I 0
     D x               s             10I 0
     D temp            s             50a

      /free
         len = %scan(U'0000':elem) - 1;
         elemName = %subst(elem:1:len);

         // -----------------------------------------
         //  If the name space separator is found
         //  split the nameSpace from the elemName
         // -----------------------------------------

         nspos = %scan(U'000C': elemName);
         if (nspos > 0);
            nameSpace = %subst(elemName:1:nspos-1);
            elemName  = %subst(elemName:nspos+1);
         else;
            nameSpace = U'';
         endif;

         if (elemName = %ucs2('name'));
            temp = %char(nameSpacE);
            dsply temp;
         endif;

         // -----------------------------------------
         //  Store the element info into a stack.
         // -----------------------------------------

         depth = depth + 1;
         stack(depth) = elemName;
         stackns(depth) = nameSpace;
         stackval(depth) = U'';


         // -----------------------------------------
         //  If this is an "item" element in the
         //  invoice's name space, add 1 to the
         //  count of items loaded.
         // -----------------------------------------

         if ( stackns(depth) = INVOICE_NAMESPACE
               and elemName = %ucs2('item') );
            count = count + 1;
         endif;


         // -----------------------------------------
         //  Look through attributes
         //    and save any that we need
         // -----------------------------------------

         x = 1;
         dow attr(x) <> *NULL;

            p_Attr = attr(x);
            len = %scan(U'0000': attrData) - 1;
            attrName = %subst(attrdata:1:len);

            p_Attr = attr(x+1);
            len = %scan(U'0000': attrData) - 1;
            attrVal = %subst(attrData:1:len);

            if ( stackns(depth) = INVOICE_NAMESPACE
                  and elemName = %ucs2('invoice')
                  and attrName = %ucs2('id') );
                invoice.id = %char(AttrVal);
            endif;

            if ( stackns(depth) = INVOICE_NAMESPACE
                  and elemName = %ucs2('item')
                  and attrName = %ucs2('sku') );
                invoice.item(count).sku = %char(AttrVal);
            endif;

            x = x + 2;
         enddo;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Expat calls this for any character data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P chardata        B
     D chardata        PI
     D   UserData                      *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

      /free
         stackval(depth) = stackval(depth)
                         + %subst(string:1:len);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Expat calls this for the end element
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P end             B
     D end             PI
     D   UserData                      *   value
     D   elem                     16363C   const options(*varsize)
      /free

         // -----------------------------------------
         //  Save data for this element
         //  if it's in the invoice name space
         // -----------------------------------------

          if stackns(depth) = INVOICE_NAMESPACE;

             select;
             when stack(depth) = %ucs2('name');
                invoice.name = %char(stackval(depth));

             when stack(depth) = %ucs2('street');
                invoice.street = %char(stackval(depth));

             when stack(depth) = %ucs2('city');
                invoice.city   = %char(stackval(depth));

             when stack(depth) = %ucs2('state');
                invoice.state  = %char(stackval(depth));

             when stack(depth) = %ucs2('country');
                invoice.country = %char(stackval(depth));

             when stack(depth) = %ucs2('description');
                invoice.item(count).desc = %char(stackval(depth));

             when stack(depth) = %ucs2('price');
               invoice.item(count).price = %dec(%char(stackval(depth)):9:2);
             endsl;

         endif;

         // -----------------------------------------
         //  go back to previous stack entry
         // -----------------------------------------
          depth = depth - 1;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
