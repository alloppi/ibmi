     h dftactgrp(*no) bnddir('QC2LE')
     h option (*nodebugio)
      *
     fOhead     uf   e           k disk
     fOdetl     if   e           k disk

     d/copy phsrclib/qcpysrc,IFSIO_H

     d $cmp            s              3s 0 inz(1)
     d $file_name      s             50
     d $file_path      s            100
     d $ord_date       s              8s 0
     d $ord_date_a     s              8a
     d $ddmmyyyy       s             10a
     d $date           s             10a
     d $time           s             10a

     d fd              s             10I 0
     d crlf            c                   x'0D25'
     d $xml            s            512a

     d ProgStatus     sds
     d  Parms            *PARMS
     d  ProgName         *PROC
     d  ErrMsgID              40     46
     d  ErrMsg                91    169
     d  JobName              244    253
     d  Userid               254    263
     d  JobNumber            264    269

      *Date/Time Stamps
     d                 ds
     d @DateTime                       z
     d  @DteStmp                       d   overlay(@DateTime : 1)
     d  @TimStmp                       t   overlay(@DateTime : 12)

      *
      *----- Main Routine
      *
     c                   exsr      @open_file

     c     $cmp          setll     ohead
     c                   dou       %eof(ohead)
     c     $cmp          reade     ohead
     c                   if        %eof(ohead)
     c                   leave
     c                   endif

     c                   if        x1del <> 'A'
     c                   iter
     c                   endif

     c                   exsr      @header_info

     c                   eval      x1del  = 'B'
     c                   update    oheadr

     c                   enddo

     c                   exsr      @close_file
     c                   eval      *inlr = *on
     c                   return
      *
      *----- Create XML file
      *
     c     @open_file    begsr

     c                   eval      $file_name = 'Order.xml'
     c                   eval      $file_path = '/home/cya012/' +
     c                                          %trim($file_name)
      /free

        fd = open(%trim($file_path)
                  : O_WRONLY+O_CREAT+O_TRUNC+O_CCSID
                  : S_IRGRP + S_IWGRP + S_IXGRP +
                                               S_IRUSR + S_IWUSR + S_IXUSR
                  : 819);
        callp close(fd);
        fd = open(%trim($file_path):O_WRONLY+O_TEXTDATA);

        $xml = '<?xml version="1.0" encoding="UTF-8"?>' + crlf +
               '<Orders>' + crlf;

        callp write(fd: %addr($xml): %len(%trim($xml)));

      /end-free

     c                   endsr
      *
      *----- Close XML file
      *
     c     @close_file   begsr

      /free

        $xml = '</Orders>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));
        callp close(fd);

      /end-free

     c                   endsr
      *
      *----- Write Header info
      *
     c     @header_info  begsr

     c                   eval      $ord_date = %dec(x1ordt)
     c                   exsr      @get_date

     c                   select
     c                   when      x1type = 'O'
     c                   eval      $xml = '<Order Type="Sales">'
     c                   when      x1type = 'B'
     c                   eval      $xml = '<Order Type="Credit">'
     c                   endsl
     c                   eval      $xml = %trim($xml) + crlf
     c                   callp     write(fd: %addr($xml): %len(%trim($xml)))

      /free

        $xml = '<OrderID>' +
                 %trim(%editc(x1ord:'Z')) +
               '</OrderID>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

        $xml = '<CustNumber>' +
                 %trim(x1cust) +
               '</CustNumber>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

        $xml = '<OrderDate>' +
                 %trim($ddmmyyyy) +
               '</OrderDate>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

        $xml = '<CustPONumber>' +
                 %trim(x1po) +
               '</CustPONumber>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

        $xml = '<OrderTotal>' +
                 %trim(%editc(x1otot:'P')) +
               '</OrderTotal>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

      /end-free

     c                   exsr      @detail_info

     c                   eval      $xml = '</Order>' + crlf
     c                   callp     write(fd: %addr($xml): %len(%trim($xml)))

     c                   endsr
      *
      *----- Write Detail info
      *
     c     @detail_info  begsr

     c     keyord        setll     odetl
     c                   dou       %eof(odetl)
     c     keyord        reade     odetl
     c                   if        %eof(odetl)
     c                   leave
     c                   endif

     c                   if        x2del = 'D'
     c                   iter
     c                   endif

     c                   eval      $xml = '<OrderLine>' + crlf
     c                   callp     write(fd: %addr($xml): %len(%trim($xml)))

      /free

        $xml = '<OrderlineID>' +
                 %trim(%editc(x2seq:'Z')) +
               '</OrderlineID>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

        $xml = '<ItemID>' +
                 %trim(x2item) +
               '</ItemID>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

        $xml = '<ItemDescription>' +
                 %trim(x2item) +
               '</ItemDescription>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

        $xml = '<Quantity>' +
                 %trim(%editc(x2qty:'3')) +
               '</Quantity>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

        $xml = '<Price>' +
                 %trim(%editc(x2pric:'3')) +
               '</Price>' + crlf;
        callp write(fd: %addr($xml): %len(%trim($xml)));

      /end-free

     c                   eval      $xml = '</OrderLine>' + crlf
     c                   callp     write(fd: %addr($xml): %len(%trim($xml)))

     c                   enddo

     c                   endsr
      *
      *----- Initial Routine
      *
     c     *inzsr        begsr

     c     keyord        klist
     c                   kfld                    x1cmp
     c                   kfld                    x1ord

     c                   endsr
      *
      *----- Get date in DDMMYYYY format
      *
     c     @get_date     begsr

     c                   eval      $ord_date_a = %editc($ord_date:'Z')
     c                   eval      $ddmmyyyy = %subst($ord_date_a:7:2) + '-' +
     c                                         %subst($ord_date_a:5:2) + '-' +
     c                                         %subst($ord_date_a:1:4)
     c                   endsr
