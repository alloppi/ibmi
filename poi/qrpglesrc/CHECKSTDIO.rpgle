      * Create the program with a simple CRTBNDRPG
      * Call it with no parameters at the beginning of the job

     h bnddir('QC2LE') dftactgrp(*no)
     Fqsysprt   o    f   80        printer
     D prtds           ds            80

     D O_CREAT         C                   x'00000008'
     D O_TRUNC         C                   x'00000040'
     D O_RDONLY        C                   x'00000001'
     D O_WRONLY        C                   x'00000002'
     D O_RDWR          C                   x'00000004'

     D O_ACCMODE       c                   %BITOR(O_RDONLY
     D                                          : %BITOR(O_WRONLY
     D                                                 : O_RDWR))

     D S_IRUSR         C                   x'0100'
     D S_IROTH         C                   x'0004'
     D S_IWUSR         C                   x'0080'
     D S_IWOTH         C                   x'0002'

     D chk             pr              n
     D   descriptor                  10i 0 value
     D   mode                        10i 0 value
     D   aut                         10i 0 value
     D   other_valid_mode...
     D                               10i 0 value

     D sndErr          pr
     D   msg                       1000a   const varying

     D ok              s               n

      /free
       // Validate or open descriptors 0, 1 and 2
       ok = chk (0
               : 0 + O_CREAT + O_TRUNC + O_RDWR
               : 0 + S_IRUSR + S_IROTH
               : 0 + O_RDONLY)
       and  chk (1
               : 0 + O_CREAT + O_TRUNC + O_WRONLY
               : 0 + S_IWUSR + S_IWOTH
               : 0 + O_RDWR)
       and  chk (2
               : 0 + O_CREAT + O_TRUNC + O_WRONLY
               : 0 + S_IWUSR + S_IWOTH
               : 0 + O_RDWR);

       // If the descriptors were not all correct,
       // signal an exception to our caller
       if not ok;
          sndErr ('Descriptors 0, 1 and 2 not opened successfully.');
       endif;
       *inlr = '1';

       begsr *pssr;
          // endsr *cancl will signal an exception to the caller
       endsr '*CANCL';
      /end-free
     P chk             b
     D chk             pi              n
     D   descriptor                  10i 0 value
     D   mode                        10i 0 value
     D   aut                         10i 0 value
     D   other_valid_mode...
     D                               10i 0 value

     D open            pr            10i 0 extproc('open')
     D   filename                      *   value options(*string)
     D   mode                        10i 0 value
     D   aut                         10i 0 value
     D   unused                      10i 0 value options(*nopass)

     D closeFile       pr            10i 0 extproc('close')
     D   handle                      10i 0 value

     D fcntl           pr            10I 0 extproc('fcntl')
     D   descriptor                  10I 0 value
     D   action                      10I 0 value
     D   arg                         10I 0 value options(*nopass)

     D F_GETFL         c                   x'06'

     D flags           s             10i 0
     D new_desc        s             10i 0

     D actual_acc      s             10i 0
     D required_acc    s             10i 0
     D allowed_acc     s             10i 0
      /free
          flags = fcntl (descriptor : F_GETFL);
          if flags < 0;
             // no flags returned, attempt to open this descriptor
             new_desc = open ('/dev/null' : mode : aut);
             if new_desc <> descriptor;
                // we didn't get the right descriptor number, so
                // close the one we got and return '0'
                if new_desc >= 0;
                   closeFile (new_desc);
                   prtds = 'wanted desc = ' + %char(descriptor) + ' '
                         + 'got desc = ' + %char(new_desc);
                   write qsysprt prtds;
                endif;
                return '0';
             endif;
          else;
             // check if the file was opened with the correct
             // access mode
             actual_acc = %bitand (flags : O_ACCMODE);
             required_acc = %bitand (mode : O_ACCMODE);
             allowed_acc = %bitand (other_valid_mode : O_ACCMODE);
             if  actual_acc <> required_acc
             and actual_acc <> allowed_acc;
                prtds = 'desc = ' + %char(descriptor) + ' '
                      + 'act = ' + %char(actual_acc) + ' '
                      + 'oth = ' + %char(allowed_acc);
                write qsysprt prtds;
                return '0';
             endif;
          endif;

          prtds = 'desc = ' + %char(descriptor) + ' '
                + 'ok';
                write qsysprt prtds;
          return '1';
      /end-free
     P chk             e
     P sndErr          b
     D sndErr          pi
     D   msg                       1000a   const varying
     D qmhsndpm        pr                  extpgm('QMHSNDPM')
     D   msgid                        7a   const
     D   msgfile                     20a   const
     D   msgdata                    500a   const
     D   datalen                     10i 0 const
     D   msgtype                     10a   const
     D   stackentry                  10a   const
     D   stackoffset                 10i 0 const
     D   msgkey                       4a   const
     D   errorCode                         likeds(errCode)
     D key             s              4a
     D errCode         ds
     D   bytesProv                   10i 0 inz(0)
     D   bytesAvail                  10i 0
      /free
         qmhsndpm ('CPF9897'
                 : 'QCPFMSG   *LIBL'
                 : msg
                 : %len(msg)
                 : '*ESCAPE' : '*' : 3  // send to caller of this program
                 : key : errCode);
      /end-free
     P sndErr          e
