      //********************************************************************
      //
      //  CRTBNDDIR BNDDIR(MAILTEST)
      //  ADDBNDDIRE BNDDIR(MAILTEST) OBJ((*LIBL/MAILPROCS *SRVPGM))
      //
      //  CRTBNDRPG PGM(MAILTEST) DFTACTGRP(*NO) ACTGRP(*NEW)
      //
      //*******************************************************************
     h debug bnddir('MAILTEST') dftactgrp(*no)
      /copy mailproc_p
     d testprompt      s             40    inz('1-Add Address 2-Add Attach +
     d                                          3-Send 4-Exit')
     d addrprompt1     c                   'Address'
     d addrprompt2     c                   'Address type (blank, to, cc, bcc)'
     d attchprompt     c                   'File'
     d subprompt       c                   'Subject'
     d msgprompt       c                   'Body'
     d test            s              1
     d address         s             45
     d subject         s             45
     d body            s             45
     d addresstype     s              3
     d filename        s             45
     d ok              s               n
     d failmsg         s             16
     d error           ds                  likeds(mail_error)
      //
      /FREE
       dou test = '4';
       //Exit
         //
         clear test;
         dsply testprompt ' ' test;
         //
         select;
         when test = '1';
       //Add address
           clear address;
           clear addresstype;
           dsply addrprompt1 ' ' address;
           dsply addrprompt2 ' ' addresstype;
           if addresstype = *blanks;
       //Default to TO
             ok = mail_add_address(address);
           else;
             ok = mail_add_address(address : addresstype);
           endif;
           exsr showresults;
           //
         when test = '2';
       //Add attachment
           clear filename;
           dsply attchprompt ' ' filename;
           if filename <> *blanks;
             ok = mail_add_attachment(filename);
             exsr showresults;
           endif;
           //
         when test = '3';
       //Send and clear lists
           clear subject;
           clear body;
           dsply subprompt ' ' subject;
           dsply msgprompt ' ' body;
           clear error;
           mail_send(subject : body : error);
           exsr showresults;
           mail_clear_lists();
           //
         endsl;
       enddo;
       //
       *INlr = *ON;
       return;
       //
       begsr showresults;
         if test <> '3';
           if not ok;
             dsply 'Failed';
           else;
             dsply 'Successful';
           endif;
         else;
           if error.msgid = *blanks;
             dsply 'Successful';
           else;
             failmsg = 'Failed - ' + error.msgid;
             dsply failmsg;
           endif;
         endif;
       endsr;
      /END-FREE
