     H DftActGrp(*No) ActGrp(*New) Option(*SrcStmt)
     H BndDir('YAJL') bnddir('QC2LE')
     H DecEdit('0.')
     H Debug(*Yes)

     FJSONTREEF IF A E           K Disk                                         JSON Tree File
     FQSYSPRT   O    F  132        Printer

      /include yajl_h

      * This works like *ENTRY PLIST
     D JSONTREER       pr                  ExtPgm('JSONTREER')
     D  p_jsonfile                   60a   const
     D  r_rtncde                      2p 0

     D JSONTREER       pi
     D  p_jsonfile                   60a   const
     D  r_rtncde                      2p 0

      *--------------------------------------------------------------*
     D getObjNode      pr
     D  objNode                            like(yajl_val)
     D  o#                           10i 0
     D  key                          50a   varying
      *
     D getAryNode      pr
     D  aryNode                            like(yajl_val)
     D  a#                           10i 0
      *
     D wrtRecord       pr
     D  keyPath                      80a   varying
     D  data                      65535a   varying
      *
     D exitPgm         pr
     D  rtncde                        2p 0 const
      *
     D initRef         pr
      *
     D exit            pr                  extproc('exit')
     D                               10i 0 value
      *
      * Work variables
     D docNode         s                   like(yajl_val)
     D objNode         s                   like(yajl_val)
     D aryNode         s                   like(yajl_val)
     D key             s             50a   varying
      *
     D errMsg          s            500a   varying
      *
     D o#              s             10i 0
     D a#              s             10i 0
      *
     D data            s          65535a   varying
     D dataSize        s             10i 0
      *
     D keyPath         s             80a   varying
     D curPath         s             80a   varying
     D prvPath         s             80a   varying
     D KeyVal          s             50a   varying
      *
     D*MaxLen          c                   const(32650)
     D MaxLen          c                   const(1250)

      *--------------------------------------------------------------*
      * Main logic
      *--------------------------------------------------------------*
      /free

       initRef();

       // docNode = yajl_stmf_load_tree('/tmp/example.json': errMsg );
       docNode = yajl_stmf_load_tree(%trim(p_jsonfile): errMsg );

       // Check any parsing error and found error message in errMsg
       if (errmsg <> *blank);
         dump '0001';
         exitPgm(1);
       endif;

       // If JSON data not found
       if (docNode = *null);
         errMsg = 'No JSON data';
         dump '0002';
         exitPgm(1);
       endif;

       // Parse the first JSON node, assume it is an object or an array
       select;

       when YAJL_IS_OBJECT(docNode);
         data = 'JSON Doc Object';
         dataSize = YAJL_OBJECT_SIZE(docNode);
         o# = 1;
         dow o# <= dataSize;
           objNode = YAJL_OBJECT_ELEM(docNode: o#: key);
           getObjNode(objNode: o#: key);
           o# = o# + 1;
         enddo;

       when YAJL_IS_ARRAY(docNode);
         data = 'JSON Doc Array';
         dataSize = YAJL_ARRAY_SIZE(docNode);
         a# = 1;
         dow a# <= dataSize;
           aryNode = YAJL_ARRAY_ELEM(docNode: a#);
           getAryNode(aryNode: a#);
           a# = a# + 1;
         enddo;

       endsl;

       exitPgm(0);

      /end-free

     OQSYSPRT   E            PRINT
     O                       KeyPath             81
     O                       KeyVal             132

      *--------------------------------------------------------------*
      * Handle Object Node
      *--------------------------------------------------------------*
     P getObjNode      b
     D getObjNode      pi
     D @objNode                            like(yajl_val)
     D @i#                           10i 0
     D @key                          50a   varying

     D @objSubNode     s                   like(yajl_val)
     D @arySubNode     s                   like(yajl_val)
     D @subKey         s             50a   varying
     D @o#             s             10i 0
     D @a#             s             10i 0

     D @data           s          65535a   varying
     D @dataSize       s             10i 0

      /free

       @data = *blank;
       @dataSize = 0;

       select;

       when YAJL_IS_STRING(@objNode);
         @data = YAJL_GET_STRING(@objNode);
         keyPath = curPath + '/' + @key;
         keyVal = @data;
         except print;
         wrtRecord(keyPath: @data);

       when YAJL_IS_NUMBER(@objNode);
         @data = %char(YAJL_GET_NUMBER(@objNode));
         keyPath = curPath + '/' + @key;
         keyVal = @data;
         except print;
         wrtRecord(keyPath: @data);

       when YAJL_IS_TRUE(@objNode);
         @data = 'true';
         keyPath = curPath + '/' + @key;
         keyVal = @data;
         except print;
         wrtRecord(keyPath: @data);

       when YAJL_IS_FALSE(@objNode);
         @data = 'false';
         keyPath = curPath + '/' + @key;
         keyVal = @data;
         except print;
         wrtRecord(keyPath: @data);

       when YAJL_IS_OBJECT(@objNode);
         @data = 'JSON Sub Object';
         @dataSize = YAJL_OBJECT_SIZE(@objNode);
         @o# = 1;
         prvPath = curPath;
         curPath = curPath + '/' + @key;
         dow @o# <= @dataSize;
           @objSubNode = YAJL_OBJECT_ELEM(@objNode: @o#: @subKey);
           getObjNode(@objSubNode: @o#: @subKey);
           @o# = @o# + 1;
         enddo;
         curPath = prvPath;

       when YAJL_IS_ARRAY(@objNode);
         @data = 'JSON Sub Array';
         @dataSize = YAJL_ARRAY_SIZE(@objNode);
         @a# = 1;
         prvPath = curPath;
         curPath = curPath + '/' + @key;
         dow @a# <= @dataSize;
           @arySubNode = YAJL_ARRAY_ELEM(@objNode: @a#);
           getAryNode(@arySubNode: @a#);
           @a# = @a# + 1;
         enddo;
         curPath = prvPath;

       endsl;

      /end-free
     P                 E

      *--------------------------------------------------------------*
      * Handle Array Node
      *--------------------------------------------------------------*
     P getAryNode      b
     D getAryNode      pi
     D @aryNode                            like(yajl_val)
     D @i#                           10i 0

     D @objSubNode     s                   like(yajl_val)
     D @arySubNode     s                   like(yajl_val)
     D @subKey         s             50a   varying
     D @o#             s             10i 0
     D @a#             s             10i 0

     D @data           s          65535a   varying
     D @dataSize       s             10i 0

      /free

       @data = *blank;
       @dataSize = 0;

       select;

       when YAJL_IS_STRING(@aryNode);
         @data = YAJL_GET_STRING(@aryNode);
         keyPath = curPath;
         keyVal = @data;
         except print;
         wrtRecord(keyPath: @data);

       when YAJL_IS_NUMBER(@aryNode);
         @data = %char(YAJL_GET_NUMBER(@aryNode));
         keyPath = curPath;
         keyVal = @data;
         except print;
         wrtRecord(keyPath: @data);

       when YAJL_IS_TRUE(@aryNode);
         @data = 'true';
         keyPath = curPath;
         keyVal = @data;
         except print;
         wrtRecord(keyPath: @data);

       when YAJL_IS_FALSE(@aryNode);
         @data = 'false';
         keyPath = curPath;
         keyVal = @data;
         except print;
         wrtRecord(keyPath: @data);

       when (YAJL_IS_OBJECT(@aryNode));
         @data = 'JSON Sub Object';
         @dataSize = YAJL_OBJECT_SIZE(@aryNode);
         @o# = 1;
         dow @o# <= @dataSize;
           @objSubNode = YAJL_OBJECT_ELEM(@aryNode: @o#: @subKey);
           getObjNode(@objSubNode: @o#: @subKey);
           @o# = @o# + 1;
         enddo;

       when (YAJL_IS_ARRAY(@aryNode));
         @data = 'JSON Sub Array';
         @dataSize = YAJL_ARRAY_SIZE(@aryNode);
         @a# = 1;
         dow @a# <= @dataSize;
           @arySubNode = YAJL_ARRAY_ELEM(@aryNode: @a#);
           getAryNode(@arySubNode: @a#);
           @a# = @a# + 1;
         enddo;

       endsl;

      /end-free
     P                 E

      *--------------------------------------------------------------*
      * Write element to record
      *--------------------------------------------------------------*
     P wrtRecord       b
     D wrtRecord       pi
     D @keyPath                      80a   varying
     D @data                      65535a   varying

      /free

       JSONDATE = %Date();
       JSONSN   = 1;
       JSONPATH = @keyPath;

       if %len(@data) <= MaxLen;
         JSONLN = JSONLN + 1;
         JSONVAL = @data;
         write(e) JSONTREEFR;
         if %error();
           errMsg = 'Error to write JSONTREEF';
           dump '0011';
           exitPgm(1);
         endif;

       else;
         JSONLN = JSONLN + 1;
         JSONVAL = %subst(@data: 1: MaxLen);
         write(e) JSONTREEFR;
         if %error();
           errMsg = 'Error to write JSONTREEF';
           dump '0012';
           exitPgm(1);
         endif;

         JSONLN = JSONLN + 1;
         JSONVAL = %subst(@data: (MaxLen+1): (%len(@data)-MaxLen));
         write(e) JSONTREEFR;
         if %error();
           errMsg = 'Error to write JSONTREEF';
           dump '0013';
           exitPgm(1);
         endif;

       endif;

      /end-free
     P                 E

      *--------------------------------------------------------------*
      * Handle before exit program
      *--------------------------------------------------------------*
     P exitPgm         b
     D exitPgm         pi
     D @rtncde                        2p 0 const
      /free

       yajl_tree_free(docNode);

       *inlr = *on;
       r_rtncde = @rtncde;
       exit(@rtncde);

      /end-free

     P                 E

      *--------------------------------------------------------------*
      * Initial value
      *--------------------------------------------------------------*
     P initRef         b
     D initRef         pi
      /free

       r_rtncde = 0;
       JSONLN   = 0;

      /end-free

     P                 E

