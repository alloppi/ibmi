     H DFTACTGRP(*NO) BNDDIR('BASE64')

      /copy SMTPUTIL,base64_h
      /copy SMTPUTIL,iconv_h

     d plaintxt        s            256a
     d decode64        s            256a
     d decodelen       s             10u 0
     D outputbuf       s            256a
     D outputlen       s             10u 0
     d b64encode       s            256a
     d b64encodelen    s             10u 0

     d source          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d target          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d toEBC           ds                  likeds(iconv_t)

     D p_input         s               *
     D p_output        s               *
     D inputleft       s             10u 0
     D outputleft      s             10u 0

      /FREE
        plaintxt = 'smtpauth@promise.com.hk';

        // -----------------------------------------------
        //   find the appropriate translation 'table'
        //   for converting UTF-8 to the job's CCSID
        //
        //  Note: 0 is a special value that means
        //        "job CCSID".  Better to use that than
        //        to hard-code 37.
        // -----------------------------------------------

        source.CCSID = 0;        //    0 = current job's CCSID
        target.CCSID = 819;      //  819 = ISO 8859-1 ASCII
        toEBC = QtqIconvOpen( target: source );

        if (toEBC.return_value = -1);
           // handle error...
        endif;


        // -----------------------------------------------
        //   Translate data.
        //
        //   the iconv() API will increment/decrement
        //   the pointers and lengths, so make sure you
        //   do not use the original pointers...
        // -----------------------------------------------

        p_input  = %addr(plaintxt);
        inputleft = %len(%trimr(plaintxt));

        p_output = %addr(outputbuf);
        outputleft = %size(outputbuf);

        iconv( toEBC
             : p_input
             : inputleft
             : p_output
             : outputleft );

        // -----------------------------------------------
        //  if needed, you can calculate the length of
        //  the decoded data by subtracting the amount
        //  of space left in the buffer from the total
        //  buffer size.
        //
        //  At this point, 'outputbuf' should contain
        //  the EBCDIC data.
        // -----------------------------------------------

        outputlen = %size(outputbuf) - outputleft;


        // -----------------------------------------------
        //  you can call iconv() many more times if you
        //  want, using the same 'toEBC' table for
        //  translation.
        //   - -
        //  when you are completely done, call iconv_close()
        //  to free up memory.
        // -----------------------------------------------

        iconv_close(toEBC);

        // -----------------------------------------------
        //   encode some data from ascii into base64
        // -----------------------------------------------

        b64encodelen = base64_encode( %addr(outputbuf)
                                    : outputlen
                                    : %addr(b64encode)
                                    : %size(b64encode) );

        dsply %subst(b64encode:1:52);

        *inlr = *on;
