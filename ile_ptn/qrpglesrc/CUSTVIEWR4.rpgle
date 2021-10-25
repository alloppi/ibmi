      *  CUSTVIEWR4 --
      *  This is a sample display logic (view) module for the "new style"
      *  customer maintenance program.
      *                                        Scott Klement, Feb 2007
      *
      *  To compile:
      *    - Build the CUSTR4 service program first. (See CUSTR4.RPGLE)
      *    - Build the CUSTS display file first (See CUSTS.DSPF)
      *    - CRTRPGMOD CUSTVIEWR4 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
      *  This module is bound directly to the CUSTMNTR4 module.  See
      *  CUSTMNTR4.rpgle for further instructions.
      *
     H NOMAIN

     FCUSTS     CF   E             WORKSTN USROPN
     F                                     INDDS(Screen)

      /copy QRPGLESRC,cust_h

     D Screen          DS                  qualified
     D   Exit                         1N   overlay(Screen: 03)
     D   Add                          1N   overlay(Screen: 10)
     D   Cancel                       1N   overlay(Screen: 12)

     D Initialized     s              1N   inz(*off)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_Init(): Initialize this module
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CustView_Init   B                   export
     D CustView_Init   PI

     D CEE4RAGE        PR
     D   procedure                     *   procptr const
     D   feedback                    12A   options(*omit)

      /free
         if (Initialized);
            return;
         endif;

         if not %open(CUSTS);
            open CUSTS;
         endif;

         CEE4RAGE(%paddr(CustView_Done): *omit);
         Initialized = *on;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_Done(): Clean up this module
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CustView_Done   B                   export
     D CustView_Done   PI
      /free
         if %open(CUSTS);
            close CUSTS;
         endif;
         Initialized = *off;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_Clear(): Clear display fields
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CustView_Clear  B                   export
     D CustView_Clear  PI
      /free
         scCust = 0;
         scAddr = *blanks;
         scName = *blanks;
         scCity = *blanks;
         scStat = *blanks;
         scZip  = *blanks;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_AskCust(): Ask the user for a customer number
      *
      *    custno = (input) customer number to edit
      *       Add = (output) *ON if user hit "add cust" key
      *                     *OFF otherwise.
      *      Exit = (output) *ON if user hit "exit program" key
      *                     *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CustView_AskCust...
     P                 B                   export
     D CustView_AskCust...
     D                 PI
     D   Custno                            like(Cust_CustNo_t)
     D   Add                          1N
     D   Exit                         1N
      /free
         CustView_Init();

         Add = *OFF;
         Exit = *OFF;

         exfmt custs1;
         CustView_ErrMsg(*blanks);

         if (Screen.Exit);
            Exit = *ON;
            return;
         endif;

         if (Screen.Add);
            Add = *ON;
            return;
         endif;

         Custno = scCust;
      /end-free
     P                 E

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
     P CustView_EditCust...
     P                 B                   export
     D CustView_EditCust...
     D                 PI
     D   Custno                            like(Cust_CustNo_t) const
     D   Name                              like(Cust_Name_t)
     D   Addr                              likeds(Cust_Address_t)
     D   Cancel                       1N
      /free
         CustView_Init();

         Cancel = *OFF;

         scCust = custno;
         scName = Name;
         scAddr = Addr.Street;
         scCity = Addr.City;
         scStat = Addr.State;
         scZip  = Addr.Zip;

         exfmt CUSTS2;
         CustView_ErrMsg(*blanks);

         if (Screen.Cancel);
            Cancel = *ON;
            return;
         endif;

         Name        = scName;
         Addr.Street = scAddr;
         Addr.City   = scCity;
         Addr.State  = scStat;
         Addr.Zip    = scZip;
         return;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CustView_ErrMsg(): Set an error message on screen
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CustView_ErrMsg...
     P                 B                   export
     D CustView_ErrMsg...
     D                 PI
     D   ErrMsg                      60A   const
      /free
         scMsg = ErrMsg;
      /end-free
     P                 E
