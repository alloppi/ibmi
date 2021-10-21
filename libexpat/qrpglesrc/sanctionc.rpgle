     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE':'EXPAT')
     H CCSID(*UCS2:1200)

     FSANCTIONF IF A E           K Disk

      * Prototypes
     D Main            PR                  ExtPgm('SANCTIONR')
     D                               32A   const
     D Main            PI
     D   XMLFile                     32A   const

      /copy ifsio_h
      /copy errno_h
      /copy expat_h

     D start           PR
     D   userData                      *   value
     D   elem                     16383C   const options(*varsize)
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
     D sancRec         ds                  qualified
     D                                     dim(2000)
     D   dataId                            like(sancDs.DATAID)
     D   versionNum                        like(sancDs.VERSIONNUM)
     D   first_name                        like(sancDs.FIRST_NAME)
     D   second_nam                        like(sancDs.SECOND_NAM)
     D   third_name                        like(sancDs.THIRD_NAME)
     D   fourth_nam                        like(sancDs.FOURTH_NAM)
     D   un_list_ty                        like(sancDs.UN_LIST_TY)
     D   reference_                        like(sancDs.REFERENCE_)
     D   listed_on                         like(sancDs.LISTED_ON)
     D                                     Inz(D'0001-01-01')
     D   submitt_on                        like(sancDs.SUBMITT_ON)
     D                                     Inz(D'0001-01-01')
     D   gender                            like(sancDs.GENDER)
     D   submitt_by                        like(sancDs.SUBMITT_BY)
     D                                     Inz(D'0001-01-01')
     D   name_origi                        like(sancDs.NAME_ORIGI)
     D   comments1                         like(sancDs.COMMENTS1)
     D   national_2                        like(sancDs.NATIONAL_2)
     D   title                             like(sancDs.TITLE)
     D   designatio                        like(sancDs.DESIGNATIO)
     D   nationalit                        like(sancDs.NATIONALIT)
     D   individual                        like(sancDs.INDIVIDUAL)
     D   list_type                         like(sancDs.LIST_TYPE)
     D   last_day_u                        like(sancDs.LAST_DAY_U)
     D                                     Inz(D'0001-01-01')

     D sancDs          ds                  likerec(SANCTIONFR)

     D depth           s             10I 0
     D stack           s           1024C   varying dim(32)
     D stackval        s           1024C   varying dim(32)

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
         fd = open(%trim(XMLFile)
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
         parser = XML_ParserCreate(XML_ENC_UTF16);
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
             sancDs = sancRec(x);
             write SANCTIONFR sancDs;
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
     D elemName        s            200C   varying
     D attrData        s          16383C   based(p_Attr)
     D attrName        s            100C   varying
     D attrVal         s            200C   varying
     D x               s             10I 0
     D multiTitle      s             10I 0
     D multiDesig      s             10I 0

      /free
         depth = depth + 1;
         stackval(depth) = U'';

         len = %scan(U'0000': elem) - 1;
         elemName = %subst(elem: 1: len);

         // -----------------------------------------
         //  Create XPath at this depth
         // -----------------------------------------

         if (depth = 1);
           stack(depth) = %ucs2('/') + elemName;
         else;
           stack(depth) = stack(depth-1) + %ucs2('/') + elemName;
         endif;

         // -----------------------------------------
         //  If this is a INDIVIDUAL/ENTITY,
         //  start a new array element
         // -----------------------------------------

         if (stack(depth) = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL'))
             or (stack(depth) = %ucs2('/CONSOLIDATED_LIST/ENTITIES/ENTITY'));
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
      /free

         // -----------------------------------------
         //  Save data for this element
         // -----------------------------------------

         // ----INDIVIDUALS DATA --------------------
          select;
          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/DATAID');
            sancRec(count).dataId = %int(%char(stackval(depth)));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/VERSIONNUM');
            sancRec(count).versionNum = %int(%char(stackval(depth)));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/FIRST_NAME');
            sancRec(count).first_name = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/SECOND_NAME');
            sancRec(count).second_nam = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/THIRD_NAME');
            sancRec(count).third_name = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/FOURTH_NAM');
            sancRec(count).fourth_nam = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/UN_LIST_TYPE');
            sancRec(count).un_list_ty = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL+
                  /REFERENCE_NUMBER');
            sancRec(count).reference_ = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/LISTED_ON');
            sancRec(count).listed_on
                = %date(%subst(%char(stackval(depth)):1:10));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/COMMENTS1');
            sancRec(count).comments1
                = %trimr(%char(stackval(depth)));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/TITLE/VALUE');
            sancRec(count).title = %trimr(%char(stackval(depth)));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL/+
                  DESIGNATION/VALUE');
            sancRec(count).designatio = %trimr(%char(stackval(depth)));


         // ----ENTITY DATA --------------------
          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/ENTITIES/ENTITY/DATAID');
            sancRec(count).dataId = %int(%char(stackval(depth)));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/ENTITIES/ENTITY/VERSIONNUM');
            sancRec(count).versionNum = %int(%char(stackval(depth)));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/ENTITIES/ENTITY/FIRST_NAME');
            sancRec(count).first_name = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/ENTITIES/ENTITY/UN_LIST_TYPE');
            sancRec(count).un_list_ty = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/ENTITIES/ENTITY+
                  /REFERENCE_NUMBER');
            sancRec(count).reference_ = %char(stackval(depth));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/ENTITIES/ENTITY/LISTED_ON');
            sancRec(count).listed_on
                = %date(%subst(%char(stackval(depth)):1:10));

          when stack(depth)
              = %ucs2('/CONSOLIDATED_LIST/ENTITIES/ENTITY/COMMENTS1');
            sancRec(count).comments1
                = %trimr(%char(stackval(depth)));

          endsl;

         // -----------------------------------------
         //  go back to previous stack entry
         // -----------------------------------------
          depth = depth - 1;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
