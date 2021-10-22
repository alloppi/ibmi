     h nomain
     h debug option(*nodebugio) bnddir('MAILPROCS')
      //********************************************************************
      //
      //A. NAME:       Email Generation Service Program
      //
      //B. PROGRAM:    MAILPROCS
      //
      //C. PURPOSE:    To provide functions used for generating email with or
      //               without attachments
      //
      //
      // CRTBNDDIR BNDDIR(MAILPROCS)
      // ADDBNDDIRE BNDDIR(MAILPROCS) OBJ((QTCP/QTMSCRTSNM *SRVPGM))
      //
      // CRTSQLRPGI OBJ(MAILPROCS) SRCFILE(QRPGLESRC) COMMIT(*NONE)
      //            OBJTYPE(*SRVPGM) TGTRLS(*CURRENT) DBGVIEW(*SOURCE)
      //            USRPRF(*USER)
      //
      //********************************************************************
      /copy qerrcode_d
      //********************************************************************
      // Start of global variables
      //
     d g_to_arr        s            256    varying dim(100) inz(' ')
     d g_cc_arr        s            256    varying dim(100) inz(' ')
     d g_bcc_arr       s            256    varying dim(100) inz(' ')
     d g_addr          s             10i 0                                      Address counter
     d g_addr_list     ds         65535    qualified
     d  arr                          16    dim(100) overlay(g_addr_list)
     d g_to            s             10i 0                                      TO counter
     d g_cc            s             10i 0                                      CC counter
     d g_bcc           s             10i 0                                      BCC counter
     d g_att_arr       s            256    varying dim(100) inz(' ')            Attch files
     d g_atttype_arr   s              3p 0 dim(100) inz(0)                      Attch file types
     d g_att           s             10i 0                                      Attachment counter
     d g_att_list      ds         65535    qualified
     d  arr                          16    dim(100) overlay(g_att_list)
     d g_next_offset   s             10i 0
     d g_rcpt          s             10i 0 inz(0)
     d g_rcpt_0100     ds                  qualified dim(100)
     d  CCSID                        10i 0 inz(0)
     d  type                         10i 0 inz(0)
     d  addr_off                     10i 0 inz(0)
     d  addr_len                     10i 0 inz(0)
     d g_addresses     s          25600    varying inz('')
      //*************************************************************************
      // Start of copies for shared prototypes
      /copy mailproc_p
      //*************************************************************************
      // Start of internal prototypes
      //*************************************************************************
     d set_address_type...
     d                 pr             3
     d  type                          3    const varying
     d build_address_list...
     d                 pr
     d  addr_arr                    256    varying dim(100)
     d  addr_count                   10i 0 const
     d  addr_type                    10i 0 const
     d api_send_mail   pr                  Extproc('QtmsCreateSendEmail')
     d  address_array                  *   value
     d  address_count                10i 0 value
     d  address_fmt                    *   value
     d  note                           *   value
     d  note_fmt                       *   value
     d  attch_array                    *   value
     d  attch_count                  10i 0 value
     d  attch_fmt                      *   value
     d  api_error_ds                   *   value
     d uppercase       pr           500a    varying
     d  oldstring                   500a    varying const
      //*************************************************************************
      //*************************************************************************
      // Clear global address lists
      //
     p mail_clear_address_list...
     p                 b                   export
     d                 pi
     d  address_type                  3    const options(*nopass) varying       Addresses to clear
      //
     d w_address_type  s              3
      //
      /free
       if %parms = 0;                 //Check for address type
         w_address_type = 'ALL';
       else;
         w_address_type =
             set_address_type(address_type);
       endif;
       //
       select;
       when w_address_type = 'ALL';   //Clear all address lists
         clear g_to_arr;
         clear g_cc_arr;
         clear g_bcc_arr;
         g_to = 0;
         g_cc = 0;
         g_bcc = 0;
         g_addr = 0;
         //
       when w_address_type = 'TO';    //Clear To: list
         clear g_to_arr;
         g_addr = g_addr - g_to;
         g_to = 0;
         //
       when w_address_type = 'CC';    //Clear CC: list
         clear g_cc_arr;
         g_addr = g_addr - g_cc;
         g_cc = 0;
         //
       when w_address_type = 'BCC';   //Clear BCC: list
         clear g_bcc_arr;
         g_addr = g_addr - g_bcc;
         g_bcc = 0;
         //
       endsl;
       //
       return;
       //
      /end-free
     p                 e
      //*************************************************************************
      //*************************************************************************
      // Clear global attachment list
      //
     p mail_clear_attachment_list...
     p                 b                   export
     d                 pi
      //
      /free
       clear g_att_arr;
       clear g_atttype_arr;
       g_att = 0;
       return;
       //
      /end-free
     p                 e
      //*************************************************************************
      //*************************************************************************
      // Clear both global address and attachment lists
      //
     p mail_clear_lists...
     p                 b                   export
     d                 pi
     d  address_type                  3    const options(*nopass) varying       Addresses to clear
      //
     d w_address_type  s              3
      //
      /free
       if %parms = 0;                 //Check for Address type
         w_address_type = 'ALL';
       else;
         w_address_type =
             set_address_type(address_type);
       endif;
       //
       mail_clear_address_list(w_address_type);     //Clear addresses
       //
       mail_clear_attachment_list();                //Clear attachments
       //
       return;
       //
      /end-free
     p                 e
      //*************************************************************************
      //*************************************************************************
      // Add single address to global address lists
      //
     p mail_add_address...
     p                 b                   export
     d                 pi              n                                        1 - success
     d  address                     256    const varying                        Addresses to add
     d  address_type                  3    const options(*nopass) varying       Addresses type
      //
     d w_addr          s            256    varying
     d w_address_type  s              3
      //
      /free
       if g_addr = 100;             //Max 100 addresses
         return *off;
       endif;
       //
       if %parms = 1;               //Set address type
         w_address_type = 'TO';
       else;
         w_address_type =
             set_address_type(address_type);
         if w_address_type = 'ALL';
           w_address_type = 'TO';
         endif;
       endif;
       //
       w_addr = %trim(address);
       //
       select;
       when w_address_type = 'TO';   //Add main address
         g_to += 1;
         g_to_arr(g_to) = w_addr;
       when w_address_type = 'CC';   //Add CC: address
         g_cc += 1;
         g_cc_arr(g_cc) = w_addr;
       when w_address_type = 'BCC';  //Add BCC: address
         g_bcc += 1;
         g_bcc_arr(g_bcc) = w_addr;
       other;                        //Invalid address type
         return *off;
       endsl;
       g_addr += 1;                  //Increment total addresses
       //
       return *on;                   //Address added
       //
      /end-free
     p                 e
      //*************************************************************************
      //*************************************************************************
      // Add file name to global attachment list
      //
     p mail_add_attachment...
     p                 b                   export
     d                 pi              n                                        1 - success
     d  attachment                  256    const varying                        File name
      //
     d w_work          s            256    varying
     d w_ext           s            256    varying
     d w_ext_code      s              3p 0
     d w               s              3p 0
      //
      /free
       if g_att = 100;                               //Max. 100 attachments
         return *off;
       endif;
       //
       w_work = %trim(attachment);
       //
       for w = %len(w_work) downto 1;                //Search for dot (.)
         if %subst(w_work : w : 1) = '.';
           leave;
         endif;
       endfor;
       //
       if w = 1 or w = 256;                          // dot 1st or last - invalid
         return *off;
       endif;
       //
       w_ext = uppercase(%subst(w_work : w + 1));    //isolate extension
       //
       // Find match in content type file
       //
       exec sql select mimetype
              into :w_ext_code
            from mailprocs
              where extension = :w_ext;
       if sqlcode <> 0;                              //no match or error
         return *off;
       endif;
       //
       g_att = g_att ++1;                            //update attachment array and counter
       g_att_arr(g_att)  = w_work;
       g_atttype_arr(g_att)  = w_ext_code;
       //
       return *on;                                   //Success
       //
      /end-free
     p                 e
      //*************************************************************************
      //*************************************************************************
      // Send email - blank message ID in error code indicates success
      //
     p mail_send       b                   export
     d                 pi
     d  subject                     256    const varying
     d  mailbody                   5000    const varying
     d  error                              likeds(mail_error)
      //
     d w_rcpt0100      s              8    inz('RCPT0100')
     d w_note0100      s              8    inz('NOTE0100')
     d w_atch0100      s              8    inz('ATCH0100')
     d w_atch0000      s              8    inz('ATCH0000')
     d w_err           ds                  likeds(qerrcode_100)
     d w_filenames     s          25600    varying inz('')
     d w               s              5p 0
     d w_subject       s            256    varying
     d w_body          s           5000    varying
      //
     d w_note          s           6000
      //
     d w_note_ds       ds                  qualified
     d  CCSID                        10i 0 inz(0)
     d  pwd_off                      10i 0 inz(0)
     d  pwd_len                      10i 0 inz(0)
     d  sub_off                      10i 0 inz(0)
     d  sub_len                      10i 0 inz(0)
     d  body_off                     10i 0 inz(0)
     d  body_len                     10i 0 inz(0)
     d  sec_lvl                      10i 0 inz(0)
     d  type                         10i 0 inz(0)
      //
     d w_atch_0100     ds                  qualified dim(100)
     d  CCSID                        10i 0 inz(0)
     d  off                          10i 0 inz(0)
     d  len                          10i 0 inz(0)
     d  type                         10i 0 inz(0)                               Code for pdf
      //
      /free
       clear error;
       // Format note section
       clear w_note_ds;
       //
       w_note_ds.ccsid = 0;            //Use job CCSID
       //
       w_note_ds.pwd_off = 0;          //no password
       w_note_ds.pwd_len = 0;
       //
       if subject = *blank;            //at least one blank
         w_subject = ' ';
       else;
         w_subject = %trim(subject);
       endif;
       w_note_ds.sub_len = %len(w_subject);
       w_note_ds.sub_off = 36 + w_note_ds.pwd_len;
       //
       if mailbody = *blank;     //at least one blank
         w_body = ' ';
         w_note_ds.body_off = 0;
       else;
         w_body = %trim(mailbody);
       endif;
       w_note_ds.body_len = %len(w_body);
       w_note_ds.body_off = 36 + w_note_ds.pwd_len +
           w_note_ds.sub_len;
       //
       w_note_ds.sec_lvl = 0;                         //unencrypted
       w_note_ds.type = 0;                            //UTF-8
       //
       w_note = %trim(w_note_ds) +                    //No password
           w_subject + w_body;
       //
       clear g_addresses;                             //Load address section
       eval g_addr_list = *blank;
       g_rcpt = 0;
       g_next_offset = 16 * g_addr;
       build_address_list(g_to_arr : g_to : 0);
       build_address_list(g_cc_arr : g_cc : 1);
       build_address_list(g_bcc_arr : g_bcc : 2);
       g_addr_list.arr =
           %subarr(g_rcpt_0100:1:g_addr);
       g_addr_list = %trim(g_addr_list) +
           g_addresses;
       //
       if g_att > 0;                                  //Load attachment section if needed
         clear w_filenames;
         eval g_att_list = *blank;
         g_next_offset = 16 * g_att;
         //
         for w = 1 to g_att;
           w_atch_0100(w).ccsid = 0;                  //Use job CCSID
           w_atch_0100(w).off = g_next_offset;
           w_atch_0100(w).type = g_atttype_arr(w);
           w_atch_0100(w).len = %len(g_att_arr(w));
           //
           g_next_offset = g_next_offset +            //calculate next offset
               w_atch_0100(w).len;
           //
           w_filenames = w_filenames + g_att_arr(w);
         endfor;
         //
         g_att_list.arr = %subarr(w_atch_0100:1:g_att);
         g_att_list = %trim(g_att_list) + w_filenames;
       endif;
       //
       if g_att > 0;
         callp(e) api_send_mail(%addr(g_addr_list) :     //Send with attachment
             g_addr :
             %addr(w_rcpt0100) :
             %addr(w_note) :
             %addr(w_note0100) :
             %addr(g_att_list) :
             g_att :
             %addr(w_atch0100) :
             %addr(w_err));
       else;
         callp(e) api_send_mail(%addr(g_addr_list) :     //Send w/o attachment
             g_addr :
             %addr(w_rcpt0100) :
             %addr(w_note) :
             %addr(w_note0100) :
             *null :
             g_att :
             %addr(w_atch0000) :
             %addr(w_err));
       endif;
       if %error or
             w_err.err_id <> *blank;
         select;
         when w_err.err_id = 'TCP530F';                  //Clarify error
           error.msgid = 'CPD0006';
           error.msgdta = '0000User executing the +
               command is not enrolled in the +
               distribution directory or does +
               not have a corresponding entry +
               in the system SMTP alias table.';
         when w_err.err_id <> *blanks;                   //Extract error message info
           error.msgid = w_err.err_id;
           error.msgdta = w_err.excp_data;
         other;                                          //Unknown error
           error.msgid = 'CPD0006';
           error.msgdta = '0000Unknown error occurred +
               while attempting to send +
               the email.';
         endsl;
       endif;
       //
       return;
       //
      /end-free
     p                 e
      //*************************************************************************
      //*************************************************************************
      //
      // Local procedures
      //
      //*************************************************************************
      // Determine address type
      //
     p set_address_type...
     p                 b
     d                 pi             3
     d  type                          3    const varying                        Address type
     d  w_type         s              3
      //
      /free
       w_type = uppercase(type);
       select;
       when w_type = 'ALL';
       when w_type = 'TO';
       when w_type = 'CC';
       when w_type = 'BCC';
       other;
         w_type = 'ALL';                                                      //Default to ALL
       endsl;
       return w_type;
       //
      /end-free
     p                 e
      //*************************************************************************
      //*************************************************************************
      // Change to uppercase
      //
     p uppercase       b
     d                 pi           500a   varying
     d   oldstring                  500a   varying const
      //
     d w_up            c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     d w_lo            c                   'abcdefghijklmnopqrstuvwxyz'
     d w_newstring     s            500a   varying inz(*blanks)
      //
      /free
       if oldstring <> *blanks;
         w_newstring = %xlate(w_lo : w_up : oldstring);
        else;
         w_newstring = oldstring;
       endif;
       //
       return w_newstring;
       //
      /end-free
     p                 e
      //*************************************************************************
      //*************************************************************************
      // Assemble Address list for call to API
      //
     p build_address_list...
     p                 b
     d                 pi
     d  addr_arr                    256    varying dim(100)
     d  addr_count                   10i 0 const
     d  addr_type                    10i 0 const
     d  w              s              5p 0
      //
      /free
       for w = 1 to addr_count;
         g_rcpt += 1;
         g_rcpt_0100(g_rcpt).ccsid = 0;                  // Use job CCSID
         g_rcpt_0100(g_rcpt).type = addr_type;
         g_rcpt_0100(g_rcpt).addr_off = g_next_offset;
         g_rcpt_0100(g_rcpt).addr_len =
             %len(addr_arr(w));
         //
         g_next_offset = g_next_offset +                 //calculate next offset
             g_rcpt_0100(g_rcpt).addr_len;
         //
         g_addresses = g_addresses + addr_arr(w);
       endfor;
       //
       return;
       //
      /end-free
     p                 e
