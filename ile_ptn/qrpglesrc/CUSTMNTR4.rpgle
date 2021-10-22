      *  CUSTMNTR4 -- Sample "new style" customer maintenance program.
      *               This member contains the definitions for the
      *               "controller" module.
      *
      *    to Compile:
      *        - First build the business logic (Model) service
      *          program.  Details are in the CUSTR4.RPGLE member
      *        - Next, build the display logic (view) module.
      *          Details for that are in the CUSTVIEWR4.RPGLE member.
      *
      *        - CRTRPGMOD xxx/CUSTMNTR4 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
      *        - CRTPGM xxx/CUSTMNTR4 MODULE(CUSTMNTR4 CUSTVIEWR4) BNDSRVPGM(CUSTR4)
      *
      /copy ile_ptn,cust_h

     D Control_AskCust...
     D                 PR             1N
     D    CustNo                           like(Cust_CustNo_t)
     D Control_EditCust...
     D                 PR
     D    CustNo                           like(Cust_CustNo_t)

     D CustNo          s                   like(Cust_Custno_t)

      /free

        dow '1';
           if (Control_AskCust(CustNo) = *Off);
              leave;
           endif;
           Control_EditCust(CustNo);
        enddo;

        CustView_Done();
        Cust_Done();

        *inlr = *on;

      /end-free


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Control_AskCust(): Ask the user for a customer number
      *                    and validate it.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Control_AskCust...
     P                 B
     D Control_AskCust...
     D                 PI             1N
     D    CustNo                           like(Cust_CustNo_t)

     D success         s              1N
     D add             s              1N
     D exit            s              1N

      /free

         dou success;

            CustView_AskCust( CustNo: Add: Exit);
            if (Exit);
               return *OFF;
            endif;

            if (Add);
               success = Cust_New(CustNo);
            else;
               success = Cust_Load(CustNo);
            endif;

            if (not success);
               CustView_ErrMsg( Cust_Error() );
            endif;

         enddo;

         return *ON;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Control_EditCust(): Edit the customer information for a
      *                     given customer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Control_EditCust...
     P                 B
     D Control_EditCust...
     D                 PI
     D    CustNo                           like(Cust_CustNo_t)

     D Name            s                   like(Cust_Name_t)
     D Addr            ds                  likeds(Cust_Address_t)
     D success         s              1N
     D cancel          s              1N

      /free

        //
        //   Edit & save customer information
        //

         dou success;

            Name = Cust_getName();
            Addr = Cust_getAddress();

            CustView_EditCust( CustNo : Name : Addr : Cancel );
            if (Cancel = *ON);
               leave;
            endif;

            success = cust_setName(Name);
            if (not success);
               CustView_ErrMsg( Cust_Error() );
            endif;

            success = cust_setAddress(Addr);
            if (not success);
               CustView_ErrMsg( Cust_Error() );
            endif;

            if (success);
               success = cust_save();
            endif;

            if (success);
               CustView_Clear();
            endif;

         enddo;

      /end-free
     P                 E
