      *  Sample program to demonstrate checking variable values
      *  using regular expressions:
      *                             Scott Klement, October, 2012
      *
      *  To compile:
      *    upload REGEX_H to QRPGLESRC in your *LIBL
      *    upload QMHSNDPM_H to QRPGLESRC in your *LIBL
      *>   CRTBNDRPG REGEXDEMO SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP('KLEMENT')

      * This works like *ENTRY PLIST:
     D REGEXDEMO       pr                  extpgm('REGEXDEMO')
     D   Object                      32a   const
     D   Location                    32a   const
     D REGEXDEMO       pi
     D   Object                      32a   const
     D   Location                    32a   const

     D re_compile      pr                  likeds(regex_t)
     D  flags                        10i 0 value
     D  pattern                     500a   varying const
     D                                     options(*trim)

     d re_match        pr             1n
     d  regex                              likeds(regex_t) const
     d  string                    65535a   const varying
     d                                     options(*varsize)

      /copy REGEX,regex_h
      /copy REGEX,qmhsndpm_h

     D errCode         ds                  qualified
     D   bytesProv                   10i 0 inz(0)
     D   bytesAvail                  10i 0 inz(0)
     D MsgKey          s              4a

     D pattern         s             50a   varying
     D mail_addr       s            320a   varying
     D errMsg          s             52a
     D objpat          ds                  likeds(regex_t)
     D locexp          ds                  likeds(regex_t)
     D mailexp         ds                  likeds(regex_t)

      /free
       *inlr = *on;
       if %parms < 2;
          errMsg = 'This program requires 2 parameters!';
          QMHSNDPM( 'CPF9897': 'QCPFMSG   *LIBL'
                  : errMsg   : %size(errMsg)
                  : '*ESCAPE': '*PGMBDY': 1
                  : MsgKey   : errCode )   ;
          return;
       endif;


       // -------------------------------------------------
       //  Validate an IBM i object name
       // -------------------------------------------------

       pattern = '^[A-Za-z$#@][A-Za-z0-9$#@_.]{0,9}$';
       objpat = re_compile( REG_EXTENDED: pattern );
       if re_match( objpat: Object );
          dsply 'valid';
       else;
          dsply 'invalid';
       endif;
       regfree(objpat);


       // -------------------------------------------------
       //  Validate a Klement's warehouse location
       // -------------------------------------------------

       locexp = re_compile( REG_BASIC
                          : '^[A-Y][CF][0-9][0-9][A-E]$');
       if not re_match( locexp: Location );
          errMsg = 'Invalid location!';
       else;
          errMsg = 'location is valid!';
       endif;
       dsply errMsg;
       regfree(locexp);


       // -------------------------------------------------
       //  Validate an e-mail address
       // -------------------------------------------------

       mail_addr = %trim('mr.wizard@example.com');

       mailexp = re_compile( REG_EXTENDED + REG_ICASE
                           : '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$');

       if not re_match( mailexp: mail_addr );
          errMsg = 'Invalid e-mail address!';
       else;
          errMsg = 'E-mail address looks okay';
       endif;
       dsply errMsg;
       regfree(mailexp);


       return;
      /end-free


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * re_compile(): Compile a regular expression
      *                (wrapper around regcomp API)
      *
      *   flags = (input) flags to specify on the compile
      *              REG_BASIC, REG_EXTENDED, REG_ICASE
      * pattern = (input) the expression to compile.
      *
      *  Returns the compiled regular expression
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P re_compile      B                   export
     d                 PI                  likeds(regex_t)
     d  flags                        10i 0 value
     d  pattern                     500a   varying const
     d                                     options(*trim)

     D err             s             10i 0
     D errMsg          s          32767a   static
     D result          ds                  likeds(regex_t)

      /free
       flags = %bitor(flags: REG_NOSUB);

       err = regcomp( result
                    : pattern
                    : flags );

       if err <> 0;
          regerror( err: result: errMsg: %size(errMsg));
          errMsg = %str(%addr(errMsg));
          QMHSNDPM( 'CPF9897': 'QCPFMSG   *LIBL'
                  : errMsg   : %size(errMsg)
                  : '*ESCAPE': '*': 1
                  : MsgKey   : errCode )   ;
       endif;

       return result;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * re_match(): Check if a regular expression matches
      *               string
      *
      *   regex = (input) compiled regular expression to match
      *  string = (input) string to find match in.
      *
      * returns *ON if match is found, *OFF otherwise.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     p re_match        B                   export
     d                 PI             1n
     d  regex                              likeds(regex_t) const
     d  string                    65535a   const varying
     d                                     options(*varsize)

     D rc              s             10i 0
     D errMsg          s          32767a   static
     D match           ds                  likeds(regmatch_t)

      /free

       rc = regexec( regex
                   : %trimr(string)
                   : 1
                   : match
                   : 0 );
       select;
       when rc = 0;
          return *on;
       when rc = REG_NOMATCH;
          return *off;
       other;
          regerror( rc: regex: errMsg: %size(errMsg));
          errMsg = %str(%addr(errMsg));
          QMHSNDPM( 'CPF9897': 'QCPFMSG   *LIBL'
                  : errMsg   : %size(errMsg)
                  : '*ESCAPE': '*': 1
                  : MsgKey   : errCode )   ;
       endsl;
      /end-free
     P                 E
