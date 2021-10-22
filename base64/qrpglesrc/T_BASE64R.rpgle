     H DFTACTGRP(*NO) BNDDIR('BASE64')

     FT_BASE64D CF   E             WorkStn InfDs( InfDs )

      /Copy QBase64Src,BASE64_H
      /Copy QBase64Src,ICONV_H
      /Copy Qcpysrc,PSCY01R

     d encode64        s            256a
     d decode64        s            256a
     d decodelen       s             10u 0
     D outputbuf       s            256a
     D outputlen       s             10u 0

     d encodelen       s             10u 0

     d source          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d target          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d toEBC           ds                  likeds(iconv_t)
     d toUTF           ds                  likeds(iconv_t)

     D p_input         s               *
     D p_output        s               *
     D inputleft       s             10u 0
     D outputleft      s             10u 0

      * Mainline logic
     C                   DoU       Key = F03
      *
      * Retreive user message
      /Copy Qcpysrc,PSCY02R
     C                   Write     FT001
     C                   ExFmt     DSP01
     C                   Eval      HDMSGID = *Blanks
     C                   Eval      HDMSG = *Blanks
      *
     C                   If        Key = F02
     C                   ExSr      @Swap
     C                   Iter
     C                   EndIf
      *
     C                   If        D1Action = 'D'
     C                   ExSr      @Decode
     C                   Eval      D1Out = outputbuf
     C                   EndIf
      *
     C                   If        D1Action = 'E'
     C                   ExSr      @Encode
     C                   Eval      D1Out = %subst(encode64:1:encodelen)
     C                   EndIf
      *
     C                   EndDo
      *
      * End of Program
     C                   Eval      *InLR = *On
     C                   Return
      *
      /FREE
        // -----------------------------------------------------------------
        //   decode some data from base64 into UTF-8
        // -----------------------------------------------------------------

        Begsr @Decode ;

            encode64  = D1Inp;
            decode64  = *blank;
            decodelen = 0;
            outputbuf = *blank;
            outputlen = 0;
            source = *ALLx'00';
            target = *ALLx'00';
            toEBC  = *ALLx'00';

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

            source.CCSID = D1InpCCSID;
            target.CCSID = D1OutCCSID;
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


            // -----------------------------------------------
            //  you can call iconv() many more times if you
            //  want, using the same 'toEBC' table for
            //  translation.
            //   - -
            //  when you are completely done, call iconv_close()
            //  to free up memory.
            // -----------------------------------------------

            iconv_close(toEBC);

        Endsr;

        // -----------------------------------------------------------------
        //   encode some data from base64 into UTF-8
        // -----------------------------------------------------------------

        Begsr @Encode ;

            encode64  = *blank;
            decode64  = D1Inp;
            decodelen = 0;
            outputbuf = *blank;
            outputlen = 0;
            source = *ALLx'00';
            target = *ALLx'00';
            toUTF  = *ALLx'00';

            // -----------------------------------------------
            //   find the appropriate translation 'table'
            //   for converting the job's CCSID to UTF-8
            //
            //  Note: 0 is a special value that means
            //        "job CCSID".  Better to use that than
            //        to hard-code 37.
            // -----------------------------------------------

            source.CCSID = D1InpCCSID;
            target.CCSID = D1OutCCSID;
            toUTF = QtqIconvOpen( target: source );

            if (toUTF.return_value = -1);
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
            inputleft = %len(%trimr(decode64));

            p_output = %addr(outputbuf);
            outputleft = %size(outputbuf);

            iconv( toUTF
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
            //  the UTF data.
            // -----------------------------------------------

            outputlen = %size(outputbuf) - outputleft;


            encodelen = base64_encode( %addr(outputbuf)
                                     : outputlen
                                     : %addr(encode64)
                                     : %size(encode64) );

            // -----------------------------------------------
            //  you can call iconv() many more times if you
            //  want, using the same 'toUTF' table for
            //  translation.
            //   - -
            //  when you are completely done, call iconv_close()
            //  to free up memory.
            // -----------------------------------------------

            iconv_close(toUTF);

        Endsr;

        // -----------------------------------------------------------------
        //   Swap
        // -----------------------------------------------------------------
        Begsr @Swap;

            If D1Action = 'E';

                D1Action   = 'D';    // Decode to 937中文
                D1InpCCSID = 1208;   // 1208 = UTF-8
                D1OutCCSID = 0;      //    0 = current job's CCSID
                D1OutCCSID = 937;    //  937 = 中文ebcdic
                D1Inp = D1Out;
                D1Out = *Blank;

            Else;

                D1Action   = 'E';    // 1208 = UTF-8
                D1InpCCSID = 937;    //  937 = 中文ebcdic                                  　　
                D1OutCCSID = 0;      //    0 = current job's CCSID
                D1OutCCSID = 1208;   // 1208 = UTF-8
                D1Inp = D1Out;
                D1Out = *Blank;

            EndIf;

        Endsr;

        // -----------------------------------------------------------------
        //   Initial varaibles
        // -----------------------------------------------------------------
        Begsr *InzSr;

            // Encode ----------------------------------------
            D1Action   = 'E';    // 1208 = UTF-8
            D1InpCCSID = 937;    //  937 = 中文ebcdic
            D1OutCCSID = 0;      //    0 = current job's CCSID
            D1OutCCSID = 1208;   // 1208 = UTF-8

            D1Inp = '測試 abcdeXYZ12345';

        Endsr;

      /END-FREE
