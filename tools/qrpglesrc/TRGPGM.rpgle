       ctl-opt option(*srcstmt) ;

       dcl-c TheFile const('TESTFILE') ;
       dcl-c NbrOfFields const(6) ;

       dcl-f Outfile usage(*output)
                       extfile('MYLIB/T_TESTFILE')
                       extdesc('MYLIB/T_TESTFILE')
                       rename(RCDFORMAT:OutMember) ;

       /copy rpglesrc,triggerpgm
