      *===================================================================*
      * Program name: XMLSRR4                                             *
      * Purpose.....: Reply File Parsing                                  *
      *                                                                   *
      * Date written: 2017/03/01                                          *
      *                                                                   *
      * Description : This program would parse the Reply XML and store    *
      *               it in corresponding storage file                    *
      *                                                                   *
      * Modification:                                                     *
      * Date       Name       Pre  Ver  Mod#  Remarks                     *
      * ---------- ---------- --- ----- ----- --------------------------- *
      * 2017/03/01 Alan       AC              New Develeopment            *
      *===================================================================*
     H DFTACTGRP(*NO) ACTGRP(*CALLER) BNDDIR('QC2LE':'HTTPAPI')
     H CCSID(*UCS2:1200)
     H Debug(*Yes)

     FPHBTRF    IF A E           K Disk    Commit UsrOpn
     FPHBTERF   IF A E           K Disk    Commit UsrOpn
     FPHBPCRF   IF A E           K Disk    Commit UsrOpn
06636FPHBBERF   IF A E           K Disk    Commit UsrOpn

      /copy QCpySrc,ifsio_h
      /copy QCpySrc,errno_h
      /copy QCpySrc,expat_h
      /copy Qcpysrc,pscy01r

     D XMLSRR4         pr                  ExtPgm('XMLSRR4')
     D   P_ReqType                    2a   const
     D   P_PID                       17a   const
     D   P_RpyFile                   50a   const
     D   R_RtnCde                     2p 0
     D XMLSRR4         pi
     D   P_ReqType                    2a   const
     D   P_PID                       17a   const
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

     D stkPkgId        s             17A   varying dim(999)
     D stkAttr         s            100C   varying dim(999)
     D stkAttrVal      s            100C   varying dim(999)
     D stkElem         s            200C   varying dim(999)
     D stkElemVal      s            200C   varying dim(999)

     C                   Time                    RnTime
     C                   Eval      DsDtYY = RnDtYY
     C                   Eval      DsDtMM = RnDtMM
     C                   Eval      DsDtDD = RnDtDD
     C                   Eval      DsTmHM = RnTmHM

      /free

         // Initial Process
         r_rtncde = 1;
         w1rtncde = *zero;

         // Main Process
         //  Open XML document to check its existence on IFS
         if (w1rtncde = *zero);
           fd = open(%trim(P_RpyFile): O_RDONLY);
           if (fd < 0);
             w1errmsg = 'Error in opening reply file';
             dump(a) '0001';
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

           // write record to Bank Transfer Reply File
           if P_ReqType = '01';
             open PHBTRF;

             for y = 1 to depth;
               BTRRT   = DsYMDT;
               BTRRP   = PgmID@;
               BTRUT   = DsYMDT;
               BTRUP   = PgmID@;
               BTRPID  = P_PID;
               BTRD    = %date();
               BTREN   = %trim(%char(stkElem(y)));
               BTRAN   = %trim(%char(stkAttr(y)));
               BTRAV   = %trim(%char(stkAttrVal(y)));
               BTREV   = %trim(%char(stkElemVal(y)));
               write PHBTRFR;
             endfor;
           endif;

           // write record to BOC Transfer Enquiry Reply File
           if P_ReqType = '02';
             open PHBTERF;

             for y = 1 to depth;
               BTERRT  = DsYMDT;
               BTERRP  = PgmID@;
               BTERUT  = DsYMDT;
               BTERUP  = PgmID@;
               BTERPID = P_PID;
               BTEREN  = %trim(%char(stkElem(y)));
               BTERAN  = %trim(%char(stkAttr(y)));
               BTERAV  = %trim(%char(stkAttrVal(y)));
               BTEREV  = %trim(%char(stkElemVal(y)));
               write PHBTERFR;
             endfor;
           endif;

           // write record to BOC Password Change Reply File
           if P_ReqType = '03';
             open PHBPCRF;

             for y = 1 to depth;
               BPCRRT  = DsYMDT;
               BPCRRP  = PgmID@;
               BPCRUT  = DsYMDT;
               BPCRUP  = PgmID@;
               BPCRPID = P_PID;
               BPCRD   = %date();
               BPCREN  = %trim(%char(stkElem(y)));
               BPCRAN  = %trim(%char(stkAttr(y)));
               BPCRAV  = %trim(%char(stkAttrVal(y)));
               BPCREV  = %trim(%char(stkElemVal(y)));
               write PHBPCRFR;
             endfor;
           endif;

           // no parsing is required
           if P_ReqType = '04';
           endif;

           // write record to Bank Balance Inquiry Reply File
           if P_ReqType = '05';                                          // 06636
             open PHBBERF;                                               // 06636

             for y = 1 to depth;                                         // 06636
               BBERRT  = DsYMDT;                                         // 06636
               BBERRP  = PgmID@;                                         // 06636
               BBERUT  = DsYMDT;                                         // 06636
               BBERUP  = PgmID@;                                         // 06636
               BBERPID = P_PID;                                          // 06636
               BBEREN  = %trim(%char(stkElem(y)));                       // 06636
               BBERAN  = %trim(%char(stkAttr(y)));                       // 06636
               BBERAV  = %trim(%char(stkAttrVal(y)));                    // 06636
               BBEREV  = %trim(%char(stkElemVal(y)));                    // 06636
               write PHBBERFR;                                           // 06636
             endfor;                                                     // 06636
           endif;                                                        // 06636

         endif;

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

         stkElem(depth) = %subst(elem:1:len);
         stkElemVal(depth) = U'';

         x = 1;
         dow attr(x) <> *NULL;
           if  x = 1;
             stkElem(depth) = stkElem(depth);
           else;
             depth = depth + 1;
             stkElem(depth) = stkElem(depth - 1);
           endif;

           p_attr = attr(x);
           len = %scan(u'0000': attrData) - 1;
           if (len < 1);
             stkAttr(depth) = U'';
           else;
             stkAttr(depth) = %subst(attrData:1:len);
           endif;

           p_attr = attr(x+1);
           len = %scan(u'0000': attrData) - 1;
           if (len < 1);
             stkAttrVal(depth) = U'';
           else;
             stkAttrVal(depth) = %subst(attrData:1:len);
           endif;

           x = x + 2;
         enddo;

      /end-free
     P                 E


     P end             B
     D end             PI
     D   data                          *   value
     D   elem                     16383C   options(*varsize)

      /free
         depth = depth + 1;
         len = %scan(U'0000': elem) - 1;
         if (len < 1);
           return;
         endif;

         stkElem(depth) = U'002F' + %subst(elem:1:len);

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
           stkElem(depth) = stkElem(depth);
           stkElemVal(depth) = stkElemVal(depth) + %subst(string:1:len);
         endif;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy Qcpysrc,errno_h
