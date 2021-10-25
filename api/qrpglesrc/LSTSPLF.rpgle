      * Refer to: http://www.think400.dk/apier_2.htm#eks0017

     H DFTACTGRP(*NO)

     D QUSLSPL         PR                  ExtPgm('QUSLSPL')
      * required parameters
     D   UsrSpc                      20A   const
     D   Format                       8A   const
     D   UserName                    10A   const
     D   QualOutQ                    20A   const
     D   FormType                    10A   const
     D   UserData                    10A   const
      * optional group 1:
     D   ErrorCode                32766A   options(*nopass: *varsize)
      * optional group 2:
     D   QualJob                     26A   options(*nopass) const
     D   FieldKeys                   10I 0 options(*nopass: *varsize)
     D                                     dim(9999)
     D   NumFields                   10I 0 options(*nopass) const
      * optional group 3:
     D   AuxStgPool                  10I 0 options(*nopass) const
      * optional group 4:
     D   JobSysName                   8A   options(*nopass) const
     D   StartCrtDate                 7A   options(*nopass) const
     D   StartCrtTime                 6A   options(*nopass) const

     D QUSCRTUS        PR                  ExtPgm('QUSCRTUS')
     D   UsrSpc                      20A   CONST
     D   ExtAttr                     10A   CONST
     D   InitialSize                 10I 0 CONST
     D   InitialVal                   1A   CONST
     D   PublicAuth                  10A   CONST
     D   Text                        50A   CONST
     D   Replace                     10A   CONST
     D   ErrorCode                32766A   options(*nopass: *varsize)

     D QUSPTRUS        PR                  ExtPgm('QUSPTRUS')
     D   UsrSpc                      20A   CONST
     D   Pointer                       *

     D QUSDLTUS        PR                  ExtPgm('QUSDLTUS')
     D   UsrSpc                      20A   CONST
     D   ErrorCode                32766A   options(*varsize)

     D GetStatus       PR             4A
     D   StatusCode                  10I 0 value

     D p_UsrSpc        s               *
     D dsLH            DS                   BASED(p_UsrSpc)
     D                                      qualified
     D   Filler1                    103A
     D   Status                       1A
     D   Filler2                     12A
     D   HdrOffset                   10I 0
     D   HdrSize                     10I 0
     D   ListOffset                  10I 0
     D   ListSize                    10I 0
     D   NumEntries                  10I 0
     D   EntrySize                   10I 0

     D p_Entry         s               *
     D dsSF            DS                   BASED(p_Entry)
     D                                      qualified
     D   JobName                     10A
     D   UserName                    10A
     D   JobNumber                    6A
     D   SplfName                    10A
     D   SplfNbr                     10I 0
     D   SplfStatus                  10I 0
     D   OpenDate                     7A
     D   OpenTime                     6A
     D   Schedule                     1A
     D   SysName                     10A
     D   UserData                    10A
     D   FormType                    10A
     D   OutQueue                    10A
     D   OutQueueLib                 10A
     D   AuxPool                     10I 0
     D   SplfSize                    10I 0
     D   SizeMult                    10I 0
     D   TotalPages                  10I 0
     D   CopiesLeft                  10I 0
     D   Priority                     1A
     D   Reserved                     3A

     D dsEC            DS                  qualified
     D  BytesProvided                10I 0 inz(%size(dsEC))
     D  BytesAvail                   10I 0 inz(0)
     D  MessageID                     7A
     D  Reserved                      1A
     D  MessageData                 240A

     D MYSPACE         C                   CONST('SPLLIST   QTEMP     ')
     D Keys            s             10I 0 dim(1)
     D size            s             10I 0
     D sf              s             10I 0
     D msg             s             52A

      /free
         // set this to zero to let OS/400 handle errors, instead
         //  of handling them ourselves...
         dsEC.BytesProvided = 0;

         // Create a user space.. make space for (approx) 300
         //  spooled files to be listed.
         size = %size(dsLH) + 512 + (%size(dsSF) * 300);
         QUSCRTUS(MYSPACE: 'USRSPC': size: x'00': '*ALL':
                 'Temp User Space for QUSLSPL API':  '*YES': dsEC);

         // List spooled files to the user space
         QUSLSPL(MYSPACE: 'SPLF0300':  *blanks: *blanks: *blanks: *blanks:
                 dsEC: '*': Keys: 0);

         // Get a pointer to the returned user space
         QUSPTRUS(MYSPACE: p_UsrSpc);

         // Loop through list, for each spooled file, display the
         // spooled file name, number and status.
         p_Entry = p_UsrSpc + dsLH.ListOffset;
         for sf = 1 to dsLH.NumEntries;
            if (dsSF.SplfStatus <> 10);
                msg = %trim(dsSF.SplfName) + ' ' +
                     %trim(%editc(dsSF.SplfNbr:'L')) + ' ' +
                     GetStatus(dsSF.SplfStatus);
                dsply msg;
            endif;
            p_Entry += dsLH.EntrySize;
         endfor;

         //  delete user space, we're done with it
         QUSDLTUS(MYSPACE: dsEC);

         //  give user a chance to read the screen before ending
         msg = 'Press ENTER to end';
         dsply '' '' msg;
         *inlr = *on;

      /end-free

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  get human-readable status code for a numeric status code:
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P GetStatus       B
     D GetStatus       PI             4A
     D   StatusCode                  10I 0 value
      /free
         if (StatusCode = 1);
             return 'RDY';
         elseif (StatusCode = 2);
             return 'OPN';
         elseif (StatusCode = 3);
             return 'CLO';
         elseif (StatusCode = 4);
             return 'SAV';
         elseif (StatusCode = 5);
             return 'WTR';
         elseif (StatusCode = 6);
             return 'HLD';
         elseif (StatusCode = 7);
             return 'MSGW';
         elseif (StatusCode = 8);
             return 'PND';
         elseif (StatusCode = 9);
             return 'PRT';
         elseif (StatusCode = 10);
             return 'FIN';
         elseif (StatusCode = 11);
             return 'SND';
         elseif (StatusCode = 12);
             return 'DFR';
         else;
             return '???';
         endif;
      /end-free
     P                 E
