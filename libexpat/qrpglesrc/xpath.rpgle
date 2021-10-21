      * Demonstration of making an Xpath from the XML element names
      *
      *                             Scott Klement, March 31, 2005
      *
      * To compile:
      *   CRTBNDRPG XPATH SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE':'EXPAT')

     FQSYSPRT   O    F  132        PRINTER

      /copy ifsio_h
      /copy errno_h
      /copy expat_h

     D start           PR
     D   data                          *   value
     D   elem                     16383C   const options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)
     D end             PR
     D   data                          *   value
     D   elem                     16383C   const options(*varsize)
     D chardata        PR
     D   data                          *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D blanks          s            132A
     D Buff            s           8192A
     D PrintMe         s            132A   varying

     D stack           s           1024A   varying dim(50)
     D Depth           s             10I 0

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
     D   elem                     16383C   const options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)

     D len             s             10I 0
     D elemName        s            100C   varying

      /free

         depth = depth + 1;

         len = %scan(u'0000': elem) - 1;
         elemName = %subst(elem:1:len);

         if (depth = 1);
            stack(depth) = '/' + %char(elemName);
         else;
            stack(depth) = stack(depth-1) + '/' + %char(elemName);
         endif;

      /end-free
     P                 E


     P end             B
     D end             PI
     D   data                          *   value
     D   elem                     16383C   const options(*varsize)
      /free
          depth = depth - 1;
      /end-free
     P                 E


     P chardata        B
     D chardata        PI
     D   data                          *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D x               s             10I 0
     D val             s            132C   varying
      /free

         val = %trim(%subst(string:1:len));

         x = %scan(u'000d': val);
         dow x <> 0;
            val = %replace(u'': val: x: 1);
            x = %scan(u'000d': val);
         enddo;

         x = %scan(u'000a': val);
         dow x <> 0;
            val = %replace(u'': val: x: 1);
            x = %scan(u'000a': val);
         enddo;

         if (%len(val) < 1);
            return;
         endif;

         printme = stack(depth) + ' = ' + %char(val);
         except print;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
