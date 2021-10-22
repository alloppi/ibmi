      **  CUST_H -- this is a copybook used by the "new style" customer
      **            maintenance program. This member is not compiled
      **            by itself, but is required to compile the CUSTR4,
      **            CUSTVIEWR4 and CUSTMNTR4 programs.
      **
      **            Please put it in a QRPGLESRC file in your library list
      **
      /if defined(CUST_H_DEFINED)
      /eof
      /endif
      /define CUST_H_DEFINED

     D Cust_CustNo_t   s              4S 0 based(Template)
     D Cust_Name_t     s             25A   based(Template)

     D Cust_Address_t  ds                  qualified
     D                                     based(Template)
     D   Street                      25A
     D   City                        15A
     D   State                        2A
     D   Zip                         10A

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_init():  Initialize customer module
      *   Note: If you don't call this manually, it'll be called
      *         automatically when you call another subprocedure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D cust_Init       PR


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_Done():  Done with module
      *   Note: If you don't call this manually, it'll be called
      *         automatically when the activation group is reclaimed
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D cust_Done       PR


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Cust_new(): Create a new customer with empty fields
      *
      *      Cust = (input) customer number of new customer
      *
      * returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D Cust_new        PR             1N
     D   Cust                              like(Cust_CustNo_t) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Cust_load(): Load customer information from a given
      *              customer number.
      *
      *      Cust = (input) customer number to load
      *
      * returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D Cust_load       PR             1N
     D   Cust                              like(Cust_CustNo_t) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_getName(): Get a customer's name
      *
      * returns name field
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D cust_getName...
     D                 PR            25A   varying


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_setName(): Set a customer's name
      *
      *    Name = (input) name to set
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D cust_setName...
     D                 PR             1N
     D    Name                       25A   const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_getAddress(): Get a customer's address
      *
      * returns the address of the loaded customer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D cust_getAddress...
     D                 PR                  likeds(Cust_Address_t)
     D Addr            ds                  likeds(Cust_Address_t)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_setAddress(): Set a customer's address
      *
      *    Addr = (input) address to set
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D cust_setAddress...
     D                 PR             1N
     D   Addr                              likeds(Cust_Address_t) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_save(): Save customer's information to disk
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D cust_save...
     D                 PR             1N

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_Error(): Get last error that occurred in this module
      *
      *   ErrNo = (output/optional) Error number
      *
      * Returns the last error message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D cust_Error      PR            80A   varying
     D   ErrNo                       10I 0 options(*nopass:*omit)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_Init(): Initialize green screen view
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CustView_Init   PR

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_Done(): Clean up green screen view
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CustView_Done   PR

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_Clear(): Clear display fields
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CustView_Clear  PR

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_AskCust(): Ask the user for a customer number
      *
      *    custno = (input) customer number to edit
      *       Add = (output) *ON if user hit "add cust" key
      *                     *OFF otherwise.
      *      Exit = (output) *ON if user hit "exit program" key
      *                     *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CustView_AskCust...
     D                 PR
     D   Custno                            like(Cust_CustNo_t)
     D   Add                          1N
     D   Exit                         1N

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_EditCust():  Ask the user to edit customer info
      *
      *    custno = (input) customer number to edit
      *      Name = (i/o) Name to edit
      *      Addr = (i/o) Address to edit
      *    Cancel = (output) *ON if user hit "cancel" key
      *                     *OFF otherwise.
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CustView_EditCust...
     D                 PR
     D   Custno                            like(Cust_CustNo_t) const
     D   Name                              like(Cust_Name_t)
     D   Addr                              likeds(Cust_Address_t)
     D   Cancel                       1N


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_ErrMsg(): Set an error message on screen
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D CustView_ErrMsg...
     D                 PR
     D   ErrNo                       60A   const

     D CUST_ECHNERR    C                   1101
     D CUST_EALREADY   C                   1102
     D CUST_ENOTFND    C                   1103
     D CUST_EBADNAME   C                   1104
     D CUST_EBADADDR   C                   1105
     D CUST_EFLDMIS    C                   1106
