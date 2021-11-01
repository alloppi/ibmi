     H DFTACTGRP(*NO)

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D   command                  32702a   const options(*varsize)
     D   length                      15p 5 const
     D   igc                          3a   const options(*nopass)

     D QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
     D   MsgInfo                  32767A   options(*varsize)
     D   MsgInfoLen                  10I 0 const
     D   Format                       8A   const
     D   StackEntry                  10A   const
     D   StackCount                  10I 0 const
     D   MsgType                     10A   const
     D   MsgKey                       4A   const
     D   WaitTime                    10I 0 const
     D   MsgAction                   10A   const
     D   ErrorCode                32767A   options(*varsize)

     D Msg             DS                  qualified
     D  BytesRtn                     10I 0
     D  BytesAvail                   10I 0
     D  Severity                     10I 0
     D  Id                            7A
     D  Type                          2A
     D  Key                           4A
     D                                7A
     D  CCSID_ind                    10I 0
     D  CCSID                        10I 0
     D  Len                          10I 0
     D  Avail                        10I 0
     D  Data                       1024A

     D ErrorNull       ds                  qualified
     D    BytesProv                  10i 0 inz(0)
     D    BytesAvail                 10i 0 inz(0)

     D cmd             s            500A   varying
     D JobName         s             10a
     D JobUser         s             10a
     D JobNbr          s              6a
     D wait            s              1a
     D Count           s              2P 0

      /free

          for Count = 1 by 1 to 10 ;

            cmd = 'SBMJOB CMD(CALL DLYJOBC)';
            QCMDEXC(cmd: %len(cmd));

            QMHRCVPM( Msg
                    : %size(Msg)
                    : 'RCVM0100'
                    : '*'
                    : 0
                    : '*LAST'
                    : *blanks
                    : 0
                    : '*SAME'
                    : ErrorNull );

            if (Msg.Id<>'CPC1221' or Msg.Avail<26);
               // TODO: Report error message properly instead of DSPLY
               //       (This isn't supposed to happen!)
               dsply 'HELP!' '' wait;
               return;
            endif;

            JobName = %subst(Msg.Data: 1: 10);
            JobUser = %subst(Msg.Data:11: 10);
            JobNbr  = %subst(Msg.Data:21:  6);

            // TODO: Do whatever needs to be done with these fields,
            //       instead of just displaying them...

            dsply ('job ' +JobName+ ' User ' +JobUser+ ' Nbr ' +jobNbr)
                  '' wait;

          endfor;

          *inlr = *on;
      /end-free
