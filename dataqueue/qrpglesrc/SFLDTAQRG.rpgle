      *
      *  To compile:
      *
      *             CRTRPGPGM PGM(XXX/SFL011RG) SRCFILE(XXX/QRPGLESRC)
      *
      *=======================================================================
     Fsfldtaqdf cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(window1:rrn2)
     F                                     infds(info)
     Fsfldtaqlf if   e           k disk    rename(pfr:lfr)
     Fsfldtaqpf uf a e           k disk
      *
      * Information data structure to hold attention indicator byte.
      *
     Dinfo             ds
     D cfkey                 369    369
      *
      * Constants and stand alone fields
      *
     Dexit             C                   const(X'33')
     Dcancel           C                   const(X'3C')
     Dadd              C                   const(X'36')
     Denter            C                   const(X'F1')
     Drollup           C                   const(X'F5')
     Drolldn           C                   const(X'F4')
     Dsflpag           C                   const(12)
     Dsflpag_plus_1    C                   const(13)
     Dqlen             C                   const(256)
     Ddisplay          C                   const('5')
     Dchange           C                   const('2')
     Ddelete           C                   const('4')

     Dlstrrn           S              4  0 inz(0)
     Dlstrrn2          S              4  0 inz(0)
     Dcount            S              4  0 inz(0)
     Dnew_id           S                   like(dbidnm)
     Dsavlnam          S                   like(dblnam)
     Dsavfnam          S                   like(dbfnam)
      *
      * Data Queue variables
      *
     Dlib              S             10    inz('QTEMP')
     Dqueue            S             10    inz('SFLDTAQDQ')
     Dlen              S              5  0 inz(256)
     Dkeyln            S              3  0 inz(9)
     Dwait             S              5  0 inz(0)
     Dsndlen           S              3  0 inz(0)
     Dorder            S              2    inz('EQ')
     Dsndr             S             10    inz('         ')
      *
      * Data structure to be loaded to data queue.
      *
     D data            DS
     D  option                        1
     D  dbidnm                 2     10s 0
     D  key                    2     10s 0
     D  filler                 9    256    inz(*blanks)
      *
      *
     D
      *
      *****************************************************************
      *  Main Routine
      *****************************************************************
      *
     C     *loval        setll     sfldtaqlf
     C                   exsr      sflbld
      *
     C                   dou       cfkey = exit
      *
     C                   write     fkey1
     C                   exfmt     sf1ctl
      *
     C                   select
      *
      * If ENTER key is pressed and position-to non blank,
      * reposition the subile to closet to what was entered.
      *
     C                   when      (cfkey = enter) and (ptname <> *blanks)
     C                   exsr      addque
     C     ptname        setll     sfldtaqlf
     C                   exsr      sflbld
     C                   clear                   ptname
      *
      * If ENTER key is pressed and position-to is blank,
      * process screen to interrogate options selected by user
      *
     C                   when      (cfkey = enter) and (ptname = *blanks)
     C                   exsr      addque
     C                   exsr      prcsfl
     C     savkey        setll     sfldtaqlf
     C                   exsr      sflbld
      *
      * Roll up - load the data Q's before loading subfile
      *
     C                   when      (cfkey = rollup) and (not *in90)
     C                   exsr      addque
     C                   exsr      sflbld
      *
      * User presses F6, throw the add screen, clear, and rebuild subfile
      *
     C                   when      cfkey = add
     C                   movel(p)  'Add   '      mode
     C                   exsr      addque
     C                   exsr      addrcd
     C     dblnam        setll     sfldtaqlf
     C                   exsr      sflbld
      *
      * Roll down - load the data Q's before loading the subfile.
      *
     C                   when      (cfkey = rolldn) and (not *in32)
     C                   exsr      addque
     C                   exsr      goback
     C                   exsr      sflbld
      *
     C                   when      cfkey = cancel
     C                   leave
      *
     C                   endsl
      *
     C                   enddo
      *
     C                   eval      *inlr = *on
      *
      *****************************************************************
      *  ADDQUE - Add subfile data to Data Queues
      *****************************************************************
      *
     C     addque        begsr
      *
      * Read the changed subfile records and write them to the data Q's
      * The first data queue is keyed by whatever the unique key of the file
      * is.  If no unique key in the file, use the relative record number. This
      * queue is used to save options selected on a specific subfile line.  The
      * second queue is keyed by option, and is used to process like options
      * together when the enter key is selected
      *
     C                   readc     sfl1
      *
     C                   dow       not %eof
      *
     C                   eval      len = qlen
      *
     C                   call      'QSNDDTAQ'
     C                   parm                    queue
     C                   parm                    lib
     C                   parm                    len
     C                   parm                    data
     C                   parm                    keyln
     C                   parm                    key
      *
     C                   readc     sfl1
     C                   enddo
      *
     C                   endsr
      *
      *****************************************************************
      *  RCVQUE - Check DATAQUEUE before writing to subfile
      *****************************************************************
      *
     C     rcvque        begsr
      *
      * Read the data Q by the whatever the unique key from the
      * physical file to see if there is a saved option.  If so, display
      * the saved option when the subfile is displayed.
      *
     C                   eval      order = 'EQ'
      *
     C                   call      'QRCVDTAQ'
     C                   parm                    queue
     C                   parm                    lib
     C                   parm                    len
     C                   parm                    data
     C                   parm                    wait
     C                   parm                    order
     C                   parm                    keyln
     C                   parm                    key
     C                   parm                    sndlen
     C                   parm                    sndr
      *
     C                   if        len > *zero
     C                   eval      *in74 = *on
     C                   endif
      *
     C                   endsr
      *
      *****************************************************************
      *  PRCSFL - process the options taken in the subfile.
      *****************************************************************
      *
     C     prcsfl        begsr
      *
     C                   eval      *in41 = *on
     C                   write     sf2ctl
     C                   eval      *in41 = *off
     C                   eval      rrn2 = *zero
      *
      * Receive data queue records until the queue is empty LEN = 0
      *
     C                   eval      dbidnm = 1
     C                   eval      order = 'GE'
      *
     C                   dou       len = *zero
      *
     C                   call      'QRCVDTAQ'
     C                   parm                    queue
     C                   parm                    lib
     C                   parm                    len
     C                   parm                    data
     C                   parm                    wait
     C                   parm                    order
     C                   parm                    keyln
     C                   parm                    key
     C                   parm                    sndlen
     C                   parm                    sndr
      *
      *  If length is greater than zero, there was a record read.
      *  Process that record and receive from the second dataq to
      *  keep them in cinc.
      *
     C                   if        len > *zero
      *
     C                   select
      *
      *  process the edit program or subroutine
      *
     C                   when      option = change
     C                   movel(p)  'Update'      mode
     C                   exsr      chgdtl
     C                   if        (cfkey = exit) or (cfkey = cancel)
     C                   leave
     C                   endif
      *
      * when a 4 is entered write the record the the confirmation screen,
      * set on the SFLNXTCHG indicator to mark this record as changed,
      * and update the subfile.  I mark this record incase F12 is pressed
      * from the confirmation screen and the user wants to keep his
      * originally selected records
      *
     C                   when      option = delete
     C                   eval      rrn2 = rrn2 +1
     C                   write     window1
      *
      *  process the display program or subroutine
      *
     C                   when      option = display
     C                   movel(p)  *blanks       mode
     C     dbidnm        chain     sfldtaqpf
     C                   exfmt     panel2
     C                   if        (cfkey = exit) or (cfkey = cancel)
     C                   leave
     C                   endif
      *
     C                   endsl
      *
     C                   endif
      *
     C                   enddo
      *
      *
      * If records were selected for delete (4), throw the subfile to
      * screen.  If enter is pressed execute the DLTRCD subroutine to
      * physically delete the records, clear, and rebuild the subfile
      * from the last deleted record (you can certainly position the
      * database file where ever you want)
      *
     C                   if        rrn2 > *zero
     C                   eval      lstrrn2 = rrn2
     C                   eval      rrn2 = 1
     C                   exfmt     sf2ctl
     C                   if        (cfkey <> exit) and (cfkey <> cancel)
     C                   exsr      dltrcd
     C     dblnam        setll     sfldtaqlf
     C                   endif
     C                   endif
      *
     C                   endsr
      *
      *****************************************************************
      *  SFLBLD - Build the List
      *****************************************************************
      *
     C     sflbld        begsr
      *
      *  Clear subfile
      *
     C                   eval      rrn1 = *zero
     C                   eval      *in31 = *on
     C                   write     sf1ctl
     C                   eval      *in31 = *off
      *
      * Load data to subfile
      *
     C                   do        sflpag
     C                   read      sfldtaqlf                              90
      *
     C                   if        *in90 and rrn1 = 0
     C     ptname        setgt     sfldtaqlf
     C                   readp     sfldtaqlf
     C                   endif
      *
     C                   if        *in90 and rrn1 > 0
     C                   leave
     C                   endif
      *
     C                   eval      option = *blanks
     C                   exsr      rcvque
     C                   eval      rrn1 = rrn1 + 1
     C                   if        rrn1 = 1
     C                   eval      savlnam = dblnam
     C                   eval      savfnam = dbfnam
     C                   endif
     C                   write     sfl1
     C                   eval      *in74 = *off
     C                   enddo
      *
     C                   if        rrn1 = *zero
     C                   eval      *in32 = *on
     C                   endif
      *
     C                   endsr
      *
      *****************************************************************
      *  GOBACK - page backward one page
      *****************************************************************
      *
     C     goback        begsr
      *
     C     savkey        setll     sfldtaqlf
      *
      * Re-position files for rolling backward.
      *
     C                   do        sflpag_plus_1
     C                   readp     sfldtaqlf
     C                   if        %eof
     C     *loval        setll     sfldtaqlf
     C                   leave
     C                   endif
      *
     C                   enddo
      *
     C                   endsr
      *
      *****************************************************************
      *  CHGDTL - allow user to change data
      *****************************************************************
      *
     C     chgdtl        begsr
      *
      * chain to data file using selected subfile record
      *
     C     dbidnm        chain     sfldtaqpf
      *
      * If the record is found (it better be), throw the change screen.
      * If F3 or F12 is pressed, do not update the data file
      *
     C                   if        %found
     C                   exfmt     panel1

     C                   if        (cfkey <> exit) and (cfkey <> cancel)
     C                   update    pfr
     C                   endif

     C                   endif

     C                   endsr
      *
      *****************************************************************
      *  ADDRCD - allow user to add data
      *****************************************************************
      *
     C     addrcd        begsr
      *
      * set to last record in the the file to get the last ID number
      *
     C     *hival        setgt     sfldtaqpf
     C                   readp     sfldtaqpf
      *
      * set a new unique ID and throw the screen
      *
     C                   if        not %eof
     C                   eval      new_id = dbidnm + 1
     C                   clear                   pfr
     C                   eval      dbidnm = new_id
     C                   exfmt     panel1
      *
      * add a new record if the pressed key was not F3 or F12
      *
     C                   if        (cfkey <> exit) and (cfkey <> cancel)
     C                   write     pfr
     C                   endif

     C                   endif

     C                   endsr
      *
      *****************************************************************
      *  DLTRCD - delete records
      *****************************************************************
      *
     C     dltrcd        begsr
      *
      * read all the records in the confirmation subfile
      * and delete them from the data base file
      *
     C                   do        lstrrn2       count
     C     count         chain     window1
     C                   if        %found
     C     dbidnm        delete    pfr                                99
     C                   endif
     C                   enddo

     C                   endsr
      *
     C     savkey        klist
     C                   kfld                    savlnam
     C                   kfld                    savfnam
