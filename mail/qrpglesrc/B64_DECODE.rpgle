     H DFTACTGRP(*NO) BNDDIR('BASE64')

      /copy SMTPUTIL,base64_h
      /copy SMTPUTIL,iconv_h

     d encode64        s            256a
     d decode64        s            256a
     d decodelen       s             10u 0
     D outputbuf       s            256a
     D outputlen       s             10u 0

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
        // -----------------------------------------------
        //   decode some data from base64 into UTF-8
        // -----------------------------------------------

        encode64 = 'ew0KInRva2VuIjogew0KInVzZXJfY29kZSI6' +
                   'ICIxMjM0NSIsDQoiZGVhbGVyX2NvZGUiOiAiMTA4OTc' +
                   '2MSIsDQoidGltZV9zdGFtcCI6ICIyMDEzLTExLTE5VD' +
                   'A5OjMzOjAzLjkwMDA4MiINCiAgICAgICAgIH0NCn0NCg==';

        decodelen = base64_decode( %addr(encode64)
                                 : %len(%trimr(encode64))
                                 : %addr(decode64)
                                 : %size(decode64) );


        // -----------------------------------------------
        //   find the appropriate translation 'table'
        //   for converting UTF-8 to the job's CCSID
        //
        //  Note: 0 is a special value that means
        //        "job CCSID".  Better to use that than
        //        to hard-code 37.
        // -----------------------------------------------

        source.CCSID = 1208;   // 1208 = UTF-8
        target.CCSID = 0;      //    0 = current job's CCSID
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

        p_input  = %addr(decode64);
        inputleft = decodelen;

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
        dsply %subst(outputbuf:1:52);


        // -----------------------------------------------
        //  you can call iconv() many more times if you
        //  want, using the same 'toEBC' table for
        //  translation.
        //   - -
        //  when you are completely done, call iconv_close()
        //  to free up memory.
        // -----------------------------------------------

        iconv_close(toEBC);

        *inlr = *on;
