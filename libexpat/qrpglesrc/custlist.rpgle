     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE':'EXPAT')
     H CCSID(*UCS2:1200)

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
     D custrec         ds                  qualified
     D                                     dim(100)
     D   custno                       4P 0
     D   name                        30A
     D   street                      30A
     D   city                        15A
     D   state                        2A
     D   zip                          9P 0 inz(0)

     D pr              ds                  likeds(CustRec)

     D depth           s             10I 0
     D stack           s            512C   varying dim(32)
     D stackval        s            512C   varying dim(32)

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

         fd = open( 'testdoc/custmas.xml'
                  : O_RDONLY+O_TEXTDATA+O_CCSID
                  : 0
                  : 1200 );
         if (fd < 0);
           EscErrno(errno);
         endif;

         //
         // Create a "parser object" in memory that
         // will be used to parse the document.
         //

         p = XML_ParserCreate(XML_ENC_UTF16);
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

         for x = 1 to Count;
             pr = CustRec(x);
             except Label;
         endfor;

         *inlr = *on;
      /end-free

     OQSYSPRT   E            Label          1  3
     O                       pr.Name
     O          E            Label          1
     O                       pr.Street
     O          E            Label          1
     O                       pr.City
     O                       pr.State            +1
     O                       pr.Zip              +2 '     -    '


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Expat calls this at the start of each element
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P start           B
     D start           PI
     D   userdata                      *   value
     D   elem                     16363C   const options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)

     D len             s             10I 0
     D elemName        s            200C   varying
     D attrData        s          16383C   based(p_Attr)
     D attrName        s            100C   varying
     D attrVal         s            200C   varying
     D x               s             10I 0

      /free
         depth = depth + 1;
         stackval(depth) = U'';

         len = %scan(U'0000':elem) - 1;
         elemName = %subst(elem:1:len);

         // -----------------------------------------
         //  Create XPath at this depth
         // -----------------------------------------

         if (depth = 1);
            stack(depth) = %ucs2('/') + elemName;
         else;
            stack(depth) = stack(depth-1) + %ucs2('/') + elemName;
         endif;

         // -----------------------------------------
         //  If this is a CustRec element, start a
         //  new array element
         // -----------------------------------------

         if ( stack(depth) = %ucs2('/CustFile/CustRec') );
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

            if (stack(depth) = %ucs2('/CustFile/CustRec') )
                 and attrName = %ucs2('custno');
                custrec(count).custno = %dec(%char(AttrVal):4:0);
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
         // -----------------------------------------

          select;
          when stack(depth) = %ucs2('/CustFile/CustRec/name');
             custrec(count).Name = %char(stackval(depth));

          when stack(depth) = %ucs2('/CustFile/CustRec/Address/Street');
             custrec(count).Street = %char(stackval(depth));

          when stack(depth) = %ucs2('/CustFile/CustRec/Address/City');
             custrec(count).City = %char(stackval(depth));

          when stack(depth) = %ucs2('/CustFile/CustRec/Address/State');
             custrec(count).State = %char(stackval(depth));

          when stack(depth) = %ucs2('/CustFile/CustRec/Address/Zip');
             stackval(depth) = %xlate( %UCS2('-')
                                     : %UCS2(' ')
                                     : stackval(depth) );
             custrec(count).Zip = %dec( %char(stackval(depth)) : 9 : 0 );
          endsl;

         // -----------------------------------------
         //  go back to previous stack entry
         // -----------------------------------------
          depth = depth - 1;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
