     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE':'EXPAT')

     FQSYSPRT   O    F  132        PRINTER

      /copy ifsio_h
      /copy errno_h
      /copy expat_h

     D start           PR
     D   data                          *   value
     D   elem                     16383C   options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)
     D end             PR
     D   data                          *   value
     D   elem                          *   value

     D Buff            s           8192A
     D Depth           s             10I 0
     D PrintMe         s            132A   varying

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

         XML_SetElementHandler(p: %paddr(start): %paddr(end));

         //
         // The following loop will read data from the XML
         // document, and feed it into the XML parser
         //
         // The parser will call the "start" and "end"
         // as the correct data is fed to it, and they'll
         // create the outline.
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
         *inlr = *on;

      /end-free

     OQSYSPRT   E            Print
     O                       PrintMe            132


     P start           B
     D start           PI
     D   data                          *   value
     D   elem                     16383C   options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)

     D len             s             10I 0
     D elemName        s          16383C   varying
     D attrData        s          16383C   based(p_Attr)
     D attrName        s            100C   varying
     D attrVal         s            100C   varying
     D blanks          s            132A   static

      /free

         depth = depth + 1;

         len = %scan(u'0000': elem) - 1;
         if (len < 1);
            return;
         endif;

         elemName = %subst(elem:1:len);

         printme = %subst(blanks: 1: depth)
                 + %char(elemName);

         x = 1;
         dow attr(x) <> *NULL;
            p_attr = attr(x);
            len = %scan(u'0000': attrData) - 1;
            if (len < 1);
               AttrName = U'';
            else;
               AttrName = %subst(attrData:1:len);
            endif;

            p_attr = attr(x+1);
            len = %scan(u'0000': attrData) - 1;
            if (len < 1);
               AttrVal = U'';
            else;
               AttrVal = %subst(attrData:1:len);
            endif;

            printme = printme + ' ' + %char(Attrname)
                              + '="' + %char(AttrVal) + '"';
            x = x + 2;
         enddo;

         except print;

      /end-free
     P                 E


     P end             B
     D end             PI
     D   data                          *   value
     D   elem                          *   value
      /free
          depth = depth - 1;
      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
