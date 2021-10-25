      *********************************************************************************************
      * PURPOSE:  To collect all of the procedures needed to send email from the iSeries with
      *           and without email attachments.
      *
      * SERVICE PROGRAM:  MAIL
      *
     d mail_error      ds                  qualified based(dummy)
     d  msgid                         7
     d  msgdta                      512
      *
      * If msgid = 'CPD0006', msgdta will contain message text otherwise it
      * it will be the message data for the specific msgid.
      *
      *******************************
      * Clear recipient and array lists
     d mail_clear_lists...
     d                 pr
     d  type                          3    const varying options(*nopass)       ALL, TO, CC, BCC
      *******************************
      * Clear recipient list
     d mail_clear_address_list...
     d                 pr
     d  type                          3    const varying options(*nopass)       ALL, TO, CC, BCC
      *******************************
      * Clear attachment list
     d mail_clear_attachment_list...
     d                 pr
      *******************************
      * Add address to recipient list (builds a stored array)
     d mail_add_address...
     d                 pr              n                                        1- invalid, 0- good
     d  address                     256    const varying                        email address
     d  type                          3    const varying options(*nopass)       CC - BCC
      *******************************
      * Add file to attachment list (builds a stored array)
     d mail_add_attachment...
     d                 pr              n                                        1- invalid, 0- good
     d  attachment                  256    const varying                        attachment location
      *******************************
      * Send mail using the stored address and attachment arrays
     d mail_send       pr
     d  subject                     256    const varying
     d  mailbody                   5000    const varying
     d  error                              likeds(mail_error)
