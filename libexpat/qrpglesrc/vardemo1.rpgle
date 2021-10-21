      * This is a demonstration of parsing XML data from a variable.
      * This is intended to show the events that Expat triggers,
      * by printing out each event along with the parameters that are
      * passed.
      *
      * To Compile:
      *    CRTBNDRPG VARDEMO1 SRCFILE(LIBEXPAT/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO)
     H CCSID(*UCS2:1200) BNDDIR('EXPAT')

     FQSYSPRT   O    F  132        PRINTER OFLIND(Overflow)

      /copy expat_h

     D start           PR
     D   usrdta                        *   value
     D   elem                     16383C   options(*varsize) const
     D   attr                          *   dim(32767) options(*varsize)
     D end             PR
     D   usrdta                        *   value
     D   elem                     16383C   options(*varsize) const
     D chardata        PR
     D   usrdta                        *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D PrintMe         s            132A
     D Overflow        s              1N
     D parser          s                   like(XML_Parser)
     D done            s             10I 0
     D x               s             10I 0
     D rc              s             10I 0
     D errCode         s             10I 0

     D XMLdata         s            200C
     D len             s             10I 0
      /free

         XMLdata = %UCS2(
           '<?xml version="1.0" encoding="UTF-16"?>'
         + '<Cust number="1234">'
         +    '<name>Acme, Inc.</name>'
         +    '<balance>123.45</balance>'
         + '</Cust>' );

         len = %len(%trimr(XMLDATA)) * 2;

         parser = XML_ParserCreate(*OMIT);

         XML_SetStartElementHandler (parser: %paddr(start)   );
         XML_SetEndElementHandler   (parser: %paddr(end)     );
         XML_SetCharacterDataHandler(parser: %paddr(chardata));

         rc = XML_Parse( parser : %addr(XMLdata): len: 1);
         if (rc = XML_STATUS_ERROR);
            errCode = XML_GetErrorCode(parser);
            PrintMe = 'Parse error at line '
                    + %char(XML_GetCurrentLineNumber(parser))
                    + ','
                    + %char(XML_GetCurrentColumnNumber(parser))
                    + ': '
                    + %str(XML_ErrorString(errCode));
            except Print;
         endif;

         XML_ParserFree(parser);

         *inlr = *on;

      /end-free

     OQSYSPRT   E            Print
     O                       PrintMe            132


     P start           B
     D start           PI
     D   usrdta                        *   value
     D   elem                     16383C   options(*varsize) const
     D   attr                          *   dim(32767) options(*varsize)

     D elemName        s            100C   varying
     D attrName        s            100C   varying
     D attrVal         s            100C   varying
     D len             s             10I 0
     D data            s          16383C   based(p_data)

      /free

         len = %scan(U'0000': elem) - 1;
         elemName = %subst(elem:1:len);

         PrintMe = 'elemName = ' + %char(elemName);
         except Print;

         x = 1;
         dow attr(x) <> *NULL;

            p_data = attr(x);
            len = %scan(U'0000': data) - 1;
            attrName = %subst(data:1:len);

            p_data = attr(x+1);
            len = %scan(U'0000': data) - 1;
            attrVal  = %subst(data:1:len);

            PrintMe = 'attrName = ' + %char(attrName)
                    + ' attrVal = ' + %char(attrVal);
            except Print;

            x = x + 2;
         enddo;

      /end-free
     P                 E


     P chardata        B
     D chardata        PI
     D   usrdta                        *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D data            s          16383C   varying
      /free
            data = %subst(string:1:len);

            PrintMe = 'chardata = ' + %char(data);
            except Print;
      /end-free
     P                 E


     P end             B
     D end             PI
     D   usrdta                        *   value
     D   elem                     16383C   options(*varsize) const
     D elemName        s            100C   varying
      /free
          len = %scan(U'0000': elem) - 1;
          elemName = %subst(elem:1:len);

          PrintMe = 'end of element ' + %char(elemName);
          except Print;
      /end-free
     P                 E
