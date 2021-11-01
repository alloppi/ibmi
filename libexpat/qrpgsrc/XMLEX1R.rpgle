      *===================================================================*
      * Program name: XMLEX1R                                             *
      * Purpose.....: US Security Council Consolidated list Parsing       *
      * Spec........:                                                     *
      *                                                                   *
      * Date written: 2019/03/06                                          *
      *                                                                   *
      * Description : This program would parse the XML and store  it in   *
      *               storage file.                                       *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2019/03/06 Alan       AC              New development             *
      *===================================================================*
     H DFTACTGRP(*NO) ACTGRP(*CALLER) BNDDIR('QC2LE':'HTTPAPI')
     H CCSID(*UCS2:1200)
     H Debug(*Yes)

     FXMLEX1F   IF A E           K Disk    Commit

      /copy QCpySrc,ifsio_h
      /copy QCpySrc,errno_h
      /copy QCpySrc,expat_h
      /copy Qcpysrc,pscy01r

     D XMLEX1R         pr                  ExtPgm('XMLEX1R')
     D*  P_ReqType                    2a   const
     D*  P_PID                       17a   const
     D   P_RpyFile                   50a   const
     D   R_RtnCde                     2p 0
     D XMLEX1R         pi
     D*  P_ReqType                    2a   const
     D*  P_PID                       17a   const
     D   P_RpyFile                   50a   const
     D   R_RtnCde                     2p 0

     D start           pr
     D   data                          *   value
     D   elem                     16383C   options(*varsize) CCSID(1200)
     D   attr                          *   dim(32767) options(*varsize)
     D end             pr
     D   data                          *   value
     D   elem                     16383C   options(*varsize) CCSID(1200)
     D chardata        pr
     D   data                          *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D blanks          s            132A
     D w1rtncde        s              2P 0
     D w1errmsg        s            132A

     D Buff            s           8192A
     D Depth           s             10I 0

     D fd              s             10I 0
     D p               s                   like(XML_Parser)
     D len             s             10I 0
     D done            s             10I 0
     D x               s             10I 0
     D y               s             10I 0

     D stkPkgId        s             17A   varying dim(9999)
     D stkAttr         s            100C   varying dim(9999)
     D stkAttrVal      s            100C   varying dim(9999)
     D stkElem         s            200C   varying dim(9999)
     D stkElemVal      s            200C   varying dim(999)
      *
      *
     C                   Time                    RnTime
     C                   Eval      DsDtYY = RnDtYY
     C                   Eval      DsDtMM = RnDtMM
     C                   Eval      DsDtDD = RnDtDD
     C                   Eval      DsTmHM = RnTmHM

      /free

         // Initial Process
         r_rtncde = 1;
         w1rtncde = *zero;
               XM01RT  = DsYMDT;
               XM01RP  = PgmID@;
               XM01UT  = DsYMDT;
               XM01UP  = PgmID@;
               XM01RD  = %Date(RnDt);

         // Main Process
         //  Open XML document to check its existence on IFS
         if (w1rtncde = *zero);
           fd = open(%trim(P_RpyFile): O_RDONLY);
           if (fd < 0);
             w1errmsg = 'Error in opening reply file';
             dump(a) '0EX1';
             w1rtncde = 1;
           endif;
         endif;

         // Create a "parser object" in memory that
         // will be used to parse the document.
         if (w1rtncde = *zero);
           p = XML_ParserCreate(*OMIT);
           if (p = *NULL);
             callp close(fd);
             w1errmsg = 'Couldn''t allocate memory for parser';
             dump(a) '0002';
             w1rtncde = 1;
           endif;
         endif;

         if (w1rtncde = *zero);

           // Register subprocedures to be called for the
           // starting and ending elements of an XML document
           XML_SetStartElementHandler(p: %paddr(start));
           XML_SetEndElementHandler(p: %paddr(end));
           XML_SetCharacterDataHandler(p: %paddr(chardata));

           // The following loop will read data from the XML
           // document, and feed it into the XML parser
           // The parser will call the "start" and "end"
           // as the correct data is fed to it, and they'll
           // create the outline.
           dou (done = 1);

             len = read(fd: %addr(Buff): %size(Buff));

             if (len < 1);
               done = 1;
             endif;

             if (XML_Parse(p: Buff: len: done) = XML_STATUS_ERROR);
               callp close(fd);
               w1errmsg ='Parse error at line '
                 + %char(XML_GetCurrentLineNumber(p)) + ': '
                 + %str(XML_ErrorString(XML_GetErrorCode(p)));
               dump(a) '0003';
               w1rtncde = 1;
               done = 1;
             endif;

           enddo;
         endif;

         // Done parsing... clean up!
         XML_ParserFree(p);
         callp close(fd);

         if (w1rtncde = *zero);
           R_RtnCde = *zero;
           Commit;
         else;
           RolBk;
         endif;

         *inlr = *on;

      /end-free

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

      /free

         depth = depth + 1;

         len = %scan(u'0000': elem) - 1;
         if (len < 1);
           return;
         endif;

         XM01EN  = %trim(%subst(elem:1:len));

           x = 1;
           dow attr(x) <> *NULL;
      //     if  x = 1;
      //       stkElem(depth) = stkElem(depth);
      //     else;
      //       depth = depth + 1;
      //       stkElem(depth) = stkElem(depth - 1);
      //     endif;

           p_attr = attr(x);
           len = %scan(u'0000': attrData) - 1;
           if (len < 1);
      //     stkAttr(depth) = U'';
             XM01AN = U'';
           else;
      //     stkAttr(depth) = %subst(attrData:1:len);
             XM01AN = %subst(attrData:1:len);
           endif;
      //
           p_attr = attr(x+1);
           len = %scan(u'0000': attrData) - 1;
           if (len < 1);
      //     stkAttrVal(depth) = U'';
             XM01AV = U'';
           else;
      //     stkAttrVal(depth) = %subst(attrData:1:len);
             XM01AV = %subst(attrData:1:len);
           endif;
      //
           write XMLEX1FR;
           Clear XM01AN;
           Clear XM01AV;
           x = x + 2;
         enddo;

         // stkElem(depth) = %subst(elem:1:len);
         // stkElemVal(depth) = U'';
           Clear XM01EV;
           write XMLEX1FR;

      /end-free
     P                 E


     P end             B
     D end             PI
     D   data                          *   value
     D   elem                     16383C   options(*varsize)

      /free
      //   depth = depth + 1;
         len = %scan(U'0000': elem) - 1;
         if (len < 1);
           return;
         endif;

           XM01EN = U'002F' + %subst(elem:1:len);
           write XMLEX1FR;
           Clear XM01EV;

      /end-free
     P                 E


     P chardata        B
     D chardata        PI
     D   data                          *   value
     D   string                   16383C   const options(*varsize)
     D   len                         10I 0 value

     D x               s             10I 0
     D val             s            132C   varying
     D pos             s              5U 0

      /free
         if (len < 1);
           return;
         endif;

         // remove line feed and horizontal tab control character
         val = %subst(string:1:len);
         pos = %scan(U'000A': val);
         if pos = 0;
           pos = %scan(U'0009': val);
         endif;

         if pos = 0;
        // stkElem(depth) = stkElem(depth);
        // stkElemVal(depth) = stkElemVal(depth) + %subst(string:1:len);
               XM01EV   = %trim(%subst(string:1:len));
        //     write XMLEX1FR;
         endif;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy Qcpysrc,errno_h
