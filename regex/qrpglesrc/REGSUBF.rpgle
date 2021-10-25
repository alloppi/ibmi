      *  Sample program to demonstrate loading a subfile and
      *  scanning fields in each record using regular
      *  expressions.
      *                             Scott Klement, October, 2012
      *
      *  To compile:
      *    upload REGEX_H to QRPGLESRC in your *LIBL
      *    upload QMHSNDPM_H to QRPGLESRC in your *LIBL
      *    ADDLIBLE QIWS *LAST
      *>   CRTDSPF FILE(REGSUBFS) SRCFILE(QDDSSRC)
      *>   CRTBNDRPG REGSUBF SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP('KLEMENT') BNDDIR('QC2LE')
     H OPTION(*SRCSTMT:*NODEBUGIO:*NOSHOWCPY)

     FQCUSTCDT  IF   E           K DISK
     FREGSUBFS  CF   E             WORKSTN SFILE(REGSUBF1S:RRN) INDDS(Func)

      /copy REGEX,regex_h
      /copy REGEX,qmhsndpm_h

     D re_compile      pr                  likeds(regex_t)
     D  flags                        10i 0 value
     D  pattern                     500a   varying const
     D                                     options(*trim)

     d re_match        pr             1n
     d  regex                              likeds(regex_t) const
     d  string                    65535a   const varying
     d                                     options(*varsize)

     D Func            ds                  qualified
     D   Exit                         1n   overlay(Func:03)
     D   ClrSfl                       1n   overlay(Func:50)
     D   EmptySfl                     1n   overlay(Func:51)

     D rrn             s              4p 0
     D SFL             ds                  likerec(REGSUBF1S:*output)
     D CUST            ds                  likerec(CUSREC:*input)
     D exp             ds                  likeds(regex_t)
      /free

       dou Func.Exit = *on;

          // Compile the regular expression
          exp = RE_Compile( REG_EXTENDED : %trim(pattern));

          // clear the subfile
          Func.ClrSfl = *on;
          Func.EmptySfl = *on;
          write REGSUBF1C;
          Func.ClrSfl = *off;
          RRN = 0;

          // Load the subfile

          setll *start QCUSTCDT;
          read QCUSTCDT CUST;

          dow not %eof(QCUSTCDT);

             if RE_Match( exp: %trimr(CUST.street) )
                 or RE_Match( exp: %trimr(CUST.city) )
                 or RE_Match( exp: %trimr(CUST.lstnam) );
                eval-corr SFL = CUST;
                rrn += 1;
                write REGSUBF1S SFL;
                Func.EmptySfl = *off;
             endif;

             read QCUSTCDT CUST;
          enddo;

          write REGSUBF1F;
          exfmt REGSUBF1C;

          regfree(exp);
       enddo;

       *inlr = *on;

      /end-free


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * RE_Compile(): Compile a regular expression
      *                (wrapper around regcomp API)
      *
      *   flags = (input) flags to specify on the compile
      *              REG_BASIC, REG_EXTENDED, REG_ICASE
      * pattern = (input) the expression to compile.
      *
      *  Returns the compiled regular expression
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P RE_Compile      B
     d                 PI                  likeds(regex_t)
     d  flags                        10i 0 value
     d  pattern                     500a   varying const
     d                                     options(*trim)

     D errCode         ds                  qualified
     D   bytesProv                   10i 0 inz(0)
     D   bytesAvail                  10i 0 inz(0)

     D err             s             10i 0
     D errMsg          s          32767a   static
     D result          ds                  likeds(regex_t)
     D MsgKey          s              4a

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
      * RE_Match(): Check if a regular expression matches
      *               string
      *
      *   regex = (input) compiled regular expression to match
      *  string = (input) string to find match in.
      *
      * returns *ON if match is found, *OFF otherwise.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     p RE_Match        B
     d                 PI             1n
     d  regex                              likeds(regex_t) const
     d  string                    65535a   const varying
     d                                     options(*varsize)

     D errCode         ds                  qualified
     D   bytesProv                   10i 0 inz(0)
     D   bytesAvail                  10i 0 inz(0)

     D rc              s             10i 0
     D errMsg          s          32767a   static
     D match           ds                  likeds(regmatch_t)
     D MsgKey          s              4a

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
