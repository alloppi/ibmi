      *===================================================================*
      * Program name: XMLEX2R                                             *
      * Purpose.....: Parsing US Security Council Consolidated List       *
      *                                                                   *
      * Date written: 2019/03/06                                          *
      *                                                                   *
      * Description : This program would parse the XML and store it in    *
      *               storage file.                                       *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2019/03/06 Alan       AC              New development             *
      *===================================================================*
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE':'EXPAT')
     H CCSID(*UCS2:1200)

     FXMLEX2F   IF A E           K Disk

      * Prototypes
     D Main            PR                  ExtPgm('XMLEX2R')
     D                               32A   const
     D Main            PI
     D   XMLFile                     32A   const

      /copy qcpysrc,ifsio_h
      /copy qcpysrc,errno_h
      /copy qcpysrc,expat_h

     D start           PR
     D   userData                      *   value
     D   elem                     16383C   const options(*varsize) CCSID(1200)
     D   attr                          *   dim(32767) options(*varsize)

     D end             PR
     D   userData                      *   value
     D   elem                     16383C   const options(*varsize)

     D chardata        PR
     D   userData                      *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D buff            s           8192A

     D count           s             10I 0 inz(0)
     D UnscRec         ds                  qualified
     D                                     dim(2000)
     D   UNSCID                            like(UnscDs.UNSCID)
     D   UNSC1N                            like(UnscDs.UNSC1N)
     D   UNSC2N                            like(UnscDs.UNSC2N)
     D   UNSC3N                            like(UnscDs.UNSC3N)
     D   UNSC4N                            like(UnscDs.UNSC4N)

     D UnscDs          ds                  likerec(XMLEX2FR)

     D depth           s             10I 0
     D stack           s           1024A   varying dim(32)
     D stackval        s           1024A   varying dim(32)

     D fd              s             10I 0
     D parser          s                   like(XML_Parser)
     D len             s             10I 0
     D done            s             10I 0
     D x               s             10I 0

      /free

         //
         //  Open XML document to parse.
         //  Ask the open() API to translate it into UTF-8 so
         //  that Expat will understand it.
         //
         fd = open(%trim(XMLFile): O_RDONLY);
         //test fd = open(%trim(XMLFile)
         //test         : O_RDONLY+O_TEXTDATA+O_CCSID
         //test         : 0
         //test         : 1200 );
         if (fd < 0);
           EscErrno(errno);
         endif;

         //
         // Create a "parser object" in memory that
         // will be used to parse the document.
         //
         parser = XML_ParserCreate(*OMIT);
         //test parser = XML_ParserCreate(XML_ENC_UTF16);
         if (parser = *NULL);
           callp close(fd);
           die('Couldn''t allocate memory for parser');
         endif;

         //
         // Register subprocedures to be called for the
         // starting and ending elements of an XML document
         //
         XML_SetStartElementHandler( parser : %paddr(start) );
         XML_SetEndElementHandler( parser : %paddr(end) );
         XML_SetCharacterDataHandler( parser : %paddr(chardata) );

         //
         // The following loop will read data from the XML
         // document, and feed it into the XML parser
         //
         // The parser will call the "start" and "end"
         // as the correct data is fed to it.
         //
         dou (done = 1);

             len = read(fd: %addr(buff): %size(buff));

             if (len < 1);
                done = 1;
             endif;

             if (XML_Parse( parser: buff: len: done) = XML_STATUS_ERROR);
                 callp close(fd);
                 die('Parse error at line '
                    + %char(XML_GetCurrentLineNumber( parser )) + ', '
                    + %char(XML_GetCurrentColumnNumber( parser )) + ': '
                    + %str(XML_ErrorString(XML_GetErrorCode( parser ))));
             endif;

         enddo;

         //
         // Done parsing... clean up!
         //
         XML_ParserFree( parser );
         callp close(fd);

         for x = 1 to Count;
             UnscDs = UnscRec(x);
             write XMLEX2FR UnscDs;
         endfor;

         *inlr = *on;
      /end-free

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Expat calls this at the start of each element
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P start           B
     D start           PI
     D   userData                      *   value
     D   elem                     16383C   const options(*varsize)
     D   attr                          *   dim(32767) options(*varsize)

     D len             s             10I 0
     D elemName        s            100C   varying
     D attrData        s          16383C   based(p_Attr)
     D attrName        s            100C   varying
     D attrVal         s            200C   varying
     D x               s             10I 0

      /free
         depth = depth + 1;
         stackval(depth) = '';

         len = %scan(U'0000': elem) - 1;
         elemName = %subst(elem: 1: len);

         // -----------------------------------------
         //  Create XPath at this depth
         // -----------------------------------------

         if (depth = 1);
           stack(depth) = '/' + %char(elemName);
         else;
           stack(depth) = stack(depth-1) + '/' + %char(elemName);
         endif;

         // -----------------------------------------
         //  If this is a INDIVIDUAL/ENTITY,
         //  start a new array element
         // -----------------------------------------

         if stack(depth) = '/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL'
             or stack(depth) = '/CONSOLIDATED_LIST/ENTITIES/ENTITY';
           count = count + 1;
         endif;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Expat calls this for any character data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P chardata        B
     D chardata        PI
     D   userData                      *   value
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
     D   userData                      *   value
     D   elem                     16383C   const options(*varsize)

     D tempName        s            100a   varying
      /free

         // -----------------------------------------
         //  Save data for this element
         // -----------------------------------------

         // ----INDIVIDUALS DATA --------------------
          select;
          when stack(depth)
              = '/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/DATAID';
            UnscRec(count).UNSCID = %int(%char(stackval(depth)));

          when stack(depth)
              = '/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/FIRST_NAME';
            UnscRec(count).UNSC1N = formatString(%char(stackval(depth)));

          when stack(depth)
              = '/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/SECOND_NAME';
            UnscRec(count).UNSC2N = formatString(%char(stackval(depth)));

          when stack(depth)
              = '/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/THIRD_NAME';
            UnscRec(count).UNSC3N = formatString(%char(stackval(depth)));

          when stack(depth)
              = '/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/FOURTH_NAM';
            UnscRec(count).UNSC4N = formatString(%char(stackval(depth)));


         // ----ENTITY DATA --------------------
          when stack(depth)
              = '/CONSOLIDATED_LIST/ENTITIES/ENTITY/DATAID';
            UnscRec(count).UNSCID = %int(%char(stackval(depth)));

          when stack(depth)
              = '/CONSOLIDATED_LIST/ENTITIES/ENTITY/FIRST_NAME';
            UnscRec(count).UNSC1N = formatString(%char(stackval(depth)));

          endsl;

         // -----------------------------------------
         //  go back to previous stack entry
         // -----------------------------------------
          depth = depth - 1;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * formatString - Format string
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P formatString...
     P                 B
     D formatString...
     D                 PI           100A   varying
     D   argInBytes                 100A   const varying

     D formBytes       S            100A   varying
     D outBytes        S            100A   varying

      /free

       formBytes = %trim(argInBytes);
       outBytes = *blank;

       if (formBytes <> *blank);
         formBytes = %scanrpl(x'25': '': formBytes);
         formBytes = %scanrpl(x'20': '': formBytes);
         formBytes = squeezeString(formBytes);
         formBytes = removeDBCS(formBytes);
         outBytes = %trim(formBytes);
         return outBytes;
       endif;

       return outBytes;

      /end-free

     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * squeezeString - Squeezes out multiple spaces
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P squeezeString...
     P                 B
     D squeezeString...
     D                 PI           100A   varying
     D   argInBytes                 100A   const varying

     D posi            S              3S 0
     D inBytes         S            100A   varying
     D outBytes        S            100A   varying

      /free

       inBytes = %trim(argInBytes);
       outBytes = *blank;

       posi = %scan(' ': inBytes);

       dow posi > 0;
         outBytes = %trim(outBytes) + ' ' + %subst(inBytes: 1: posi);
         inBytes = %trim(%subst(inBytes: posi));

         if (inBytes = *blank);
           leave;
         endif;

         posi = %scan(' ': inBytes);

       enddo;

       if (inBytes <> *blank);
         outBytes = %trim(outBytes) + ' ' + %trim(inBytes);
       endif;

       return %trim(outBytes);

      /end-free

     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * removeDBCS - remove double byte characters
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P removeDBCS...
     P                 B
     D removeDBCS...
     D                 PI           100A   varying
     D   argInBytes                 100A   const varying

     D  dbcsStart      S              3S 0
     D  dbcsEnd        S              3S 0
     D  dbcsLen        S              3S 0

     D inBytes         S            100A   varying
     D outBytes        S            100A   varying
     D dbcsBytes       S            100A   varying

      /free

       inBytes = %trim(argInBytes);
       dbcsLen = 0;
       outBytes = *blank;

       dbcsStart = %scan(x'0E': inBytes);
       dbcsEnd = %scan(x'0F': inBytes);

       dow (dbcsStart > 0 and dbcsEnd <> 0);
         dbcsBytes = %subst(inBytes: dbcsStart+1: dbcsEnd-dbcsStart-1);

         select;
         when dbcsBytes = x'4461';
           outBytes = %trim(outBytes) + ''''
                    + %subst(inBytes: 1: dbcsStart-1);
         other;
           outBytes = %trim(outBytes) + ' '
                    + %subst(inBytes: 1: dbcsStart-1);
         endsl;

         dbcsLen = %len(inBytes);
         if ((dbcsEnd+1) < dbcsLen);
           inBytes = %trim(%subst(inBytes: dbcsEnd+1));
         else;
           inBytes = *blank;
         endif;

         if (inBytes = *blank);
           leave;
         endif;

         dbcsStart = %scan(x'0E': inBytes);
         dbcsEnd = %scan(x'0F': inBytes);

       enddo;

       if (inBytes <> *blank);
         outBytes = %trim(outBytes) + %trim(inBytes);
       endif;

       return %trim(outBytes);

      /end-free

     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy qcpysrc,errno_h
