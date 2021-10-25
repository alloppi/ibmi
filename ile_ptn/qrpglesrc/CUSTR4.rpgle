      *  CUSTR4 --
      *  Sample business logic module (or "model") for the "new style"
      *  customer maintenance program.
      *                                  Scott Klement, February 2007
      *
      *  To Compile:
      *    - Make sure the CUST_H member has been uploaded to a
      *        QRPGLESRC file in your library list.
      *    - Make sure the binder source (CUSTR4.BND) is in a QSRVSRC
      *        file in your source library.
      *    - Make sure you've already built the CUSTF physical file.
      *
      *    - CRTRPGMOD CUSTR4 SRCFILE(*CURLIB/QRPGLESRC) DBGVIEW(*LIST)
      *    - CRTSRVPGM CUSTR4 EXPORT(*SRCFILE) SRCFILE(*CURLIB/QSRVSRC)
      *
     H NOMAIN

     FCUSTF     UF A E           K DISK    USROPN

      /copy QRPGLESRC,cust_h

      * Register Activation Group Exit Procedure (CEE4RAGE) API
      * The Register Activation Group Exit Procedure (CEE4RAGE) API is used to register procedures
      * that are called when an activation group ends

     D CEE4RAGE        PR
     D   procedure                     *   procptr const
     D   feedback                    12A   options(*omit)

     D SetError        PR
     D   ErrNo                       10I 0 value
     D   Msg                         80A   varying const

     D Initialized     s              1N   inz(*Off)
     D save_Errno      s             10I 0 inz(0)
     D save_ErrMsg     s             80A   varying
     D                                     inz('No Error')
     D InCust          ds                  likerec(RCUST:*INPUT)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_init():  Initialize customer module
      *   Note: If you don't call this manually, it'll be called
      *         automatically when you call another subprocedure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cust_Init       B                   export
     D cust_Init       PI
      /free
       monitor;
         if (Initialized);
           return;
         endif;

         open CUSTF;

         CEE4RAGE( %paddr(Cust_Done): *omit );
         Initialized = *On;
         return;
       on-error;
           close CUSTF;
           Initialized = *Off;
       endmon;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_Done():  Done with module
      *   Note: If you don't call this manually, it'll be called
      *         automatically when the activation group is reclaimed
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cust_Done       B                   export
     D cust_Done       PI
      /free
         if %open(CUSTF);
           close CUSTF;
         endif;
         Initialized = *Off;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Cust_new(): Create a new customer with empty fields
      *
      *      Cust = (input) customer number of new customer
      *
      * returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Cust_new        B                   export
     D Cust_new        PI             1N
     D   Cust                              like(Cust_CustNo_t) const
     D err             s             10i 0
      /free
         cust_init();

         chain(en) Cust RCUST InCust;
         if %error;
            err = %status();
            SetError(CUST_ECHNERR: 'RPG status ' + %char(err)
                    + ' on CHAIN operation.');
            return *OFF;
         endif;

         if %found();
            SetError(CUST_EALREADY: 'Customer ' + %char(Cust)
                                  + ' already exists!');
            return *OFF;
         endif;

         clear InCUST;
         InCust.CustNo = Cust;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Cust_load(): Load customer information from a given
      *              customer number.
      *
      *      Cust = (input) customer number to load
      *
      * returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Cust_load       B                   export
     D Cust_load       PI             1N
     D   Cust                              like(Cust_CustNo_t) const
     D err             s             10i 0
      /free
         cust_init();

         chain(en) Cust RCUST InCust;
         if %error;
            err = %status();
            SetError(CUST_ECHNERR: 'RPG status ' + %char(err)
                    + ' on CHAIN operation.');
            return *OFF;
         endif;

         if not %found;
            SetError(CUST_ENOTFND: 'Customer Not Found');
            return *OFF;
         endif;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_getName(): Get a customer's name
      *
      * returns name field
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cust_getName...
     P                 B                   export
     D cust_getName...
     D                 PI            25A   varying
      /free
         return %trimr(InCust.Name);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_setName(): Get a customer's name
      *
      * returns name field
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cust_setName...
     P                 B                   export
     D cust_setName...
     D                 PI             1N
     D    Name                       25A   const
      /free
         if (Name = *blanks);
             SetError(CUST_EBADNAME: 'Name can''t be blank!');
             return *OFF;
         endif;
         InCust.Name = Name;
         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_getAddress(): Get a customer's address
      *
      * returns the address of the loaded customer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cust_getAddress...
     P                 B                   export
     D cust_getAddress...
     D                 PI                  likeds(Cust_Address_t)
     D Addr            ds                  likeds(Cust_Address_t)
      /free
         Addr.Street = %trimr(InCust.Street);
         Addr.City   = %trimr(InCust.City  );
         Addr.State  = %trimr(InCust.State );
         Addr.Zip    = %trimr(InCust.Zip   );
         return Addr;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_setAddress(): Set a customer's address
      *
      *    Addr = (input) address to set
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cust_setAddress...
     P                 B                   export
     D cust_setAddress...
     D                 PI             1N
     D   Addr                              likeds(Cust_Address_t) const
      /free
         if (Addr.Street = *blanks);
             SetError(CUST_EBADADDR: 'Street address is blank!');
             return *OFF;
         endif;
         if (Addr.City   = *blanks);
             SetError(CUST_EBADADDR: 'City is blank!');
             return *OFF;
         endif;
         if (Addr.State  = *blanks);
             SetError(CUST_EBADADDR: 'State is blank!');
             return *OFF;
         endif;
         if (Addr.Zip    = *blanks);
             SetError(CUST_EBADADDR: 'Zip is blank!');
             return *OFF;
         endif;

         InCust.Street = Addr.Street;
         InCust.City   = Addr.City;
         InCust.State  = Addr.State;
         InCust.Zip    = Addr.Zip;
         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_save(): Save customer's information to disk
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cust_save...
     P                 B                   export
     D cust_save...
     D                 PI             1N
     D err             s             10i 0
     D Ignore          ds                  likerec(RCUST:*INPUT)
     D OutCust         ds                  likerec(RCUST:*OUTPUT)
      /free
        if (  InCust.CustNo = 0
           or InCust.Street = *blanks
           or InCust.City   = *blanks
           or InCust.State  = *blanks
           or InCust.Zip    = *blanks
           or InCust.name   = *blanks );
            SetError(CUST_EFLDMIS: 'Not all fields were set!');
            return *OFF;
         endif;

         OutCust = InCust;

         chain(e) InCust.CustNo RCUST Ignore;
         if %error;
            err = %status();
            SetError(CUST_ECHNERR: 'RPG status ' + %char(err)
                    + ' on CHAIN operation.');
            return *OFF;
         endif;

         if not %found;
            write RCUST OutCust;
         else;
            update RCUST OutCust;
         endif;

         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cust_Error(): Get last error that occurred in this module
      *
      *   ErrNo = (output/optional) Error number
      *
      * Returns the last error message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cust_Error      B                   Export
     D cust_Error      PI            80A   varying
     D   ErrNo                       10I 0 options(*nopass:*omit)
      /free
         Cust_Init();

         if %parms >= 1 and %addr(Errno) <> *NULL;
            ErrNo = save_Errno;
         endif;
         return save_ErrMsg;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SetError(): (INTERNAL) set the error number and message
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SetError        B
     D SetError        PI
     D   ErrNo                       10I 0 value
     D   Msg                         80A   varying const
      /free
         save_Errno = Errno;
         save_ErrMsg = Msg;
      /end-free
     P                 E
