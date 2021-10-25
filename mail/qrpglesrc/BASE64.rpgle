     H DFTACTGRP(*NO) BNDDIR('BASE64')
      /copy SMTPUTIL,BASE64_H
     D Input           s             23a
     D Output          s             52a

      /free

          // inputascii = 'abk75';
          // input = x'61626b3735';
          // output = 'YWJrNzU='
          input = 'smtpauth@promise.com.hk';
          Output = *blanks;

          base64_encode( %addr(Input)
                  : %len(%trimr(Input))
                  : %addr(Output)
                  : %size(Output) );

          dsply input;
          dsply Output;
          *inlr = *on;

      /end-free
