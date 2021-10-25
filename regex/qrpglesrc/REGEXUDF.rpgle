      *  Sample program to demonstrate running regular expressions
      *  from SQL through the user-defined function interface.
      *                             Scott Klement, October, 2012
      *  To Compile:
      *
      *   upload REGEX_H to QRPGLESRC in your *LIBL
      *>  CRTRPGMOD REGEXUDF SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *>  CRTSRVPGM REGEXUDF MODULE(REGEXUDF) BNDDIR(QC2LE) EXPORT(*ALL)
      *>  DLTMOD REGEXUDF
      *
      *  To Install, run the SQL statement in the REGEXSQL member
      *>  RUNSQLSTM SRCFILE(QSQLSRC) SRCMBR(REGEXSQL) COMMIT(*NONE)
      *
     H NOMAIN

      /copy REGEX,regex_h

     D CALL_FIRST      C                   CONST(-1)
     D CALL_NORMAL     C                   CONST(0)
     D CALL_FINAL      C                   CONST(1)
     D PARM_NULL       C                   CONST(-1)
     D PARM_NOTNULL    C                   CONST(0)

     P RegExMatch      B                   export
     D                 PI
     D   pattern                    100a   varying const
     D   String                    1000a   varying const
     D   match                       10i 0
     D   n_pattern                    5i 0 const
     D   n_string                     5i 0 const
     D   n_match                      5i 0
     D   state_sql                    5a
     D   function                   517a   varying
     D   specific                   128a   varying
     D   errorMsg                    70a   varying
     D   callType                    10i 0 const

     D err             s             10i 0
     D buf             s          32767a
     D exp             ds                  likeds(regex_t) static
     D subexp          ds                  likeds(regmatch_t)

      /free
        n_Match = PARM_NOTNULL;
        match = 0;


        // ----------------------------------------------
        //  We cannot accept a null pattern or string
        // ----------------------------------------------

        if n_Pattern = PARM_NULL;
           state_sql = '38999';
           errorMsg = 'NULL pattern not allowed';
           return;
        endif;

        if n_String = PARM_NULL;
           state_sql = '38998';
           errorMsg = 'NULL string not allowed';
           return;
        endif;


        // ----------------------------------------------
        //  Logic:
        //     1) On first call, compile the reg exp
        //     2) On each call, compare the reg exp
        //         against the string
        //     3) On final call, free memory.
        // ----------------------------------------------

        select;
        when callType = CALL_FIRST;

           err = regcomp( exp : pattern : REG_EXTENDED
                                        + REG_NOSUB    );
           if err <> 0;
              regerror( err: exp: buf: %size(buf));
              errorMsg = pattern + ': ' + %str(%addr(buf));
              state_sql = '38999';
           endif;

        when callType = CALL_NORMAL;

           err = regexec( exp : %trimr(string): 1: subexp: 0 );
           select;
           when err = 0;
             match = 1;
           when err = REG_NOMATCH;
             match = 0;
           other;
              regerror( err: exp: buf: %size(buf));
              errorMsg = %str(%addr(buf));
              state_sql = '38999';
           endsl;

        when CallType = CALL_FINAL;

           regfree(exp);

        endsl;

      /end-free
     P                 E
