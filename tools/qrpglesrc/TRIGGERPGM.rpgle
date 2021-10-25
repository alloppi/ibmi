       dcl-ds Parm1 ;
         File char(10) ;            // File name
         Library char(10) ;         // Library file is in
         Member char(10) ;          // Member name
         TriggerEvent char(1) ;     // Trg event 1=Add 2=Delete 3=Change 4=Read
         TriggerTime char(1) ;      // Trigger time
         CommitLock char(1) ;       // Commit lock level
         *n char(3) ;               // Reserved
         CCSID int(10) ;            // CCSID
         *n char(8) ;               // Reserved
         BeforeOffset int(10) ;     // Offset to Before image
         BeforeLength int(10) ;     // Length of Before image
         BeforeNullOffset int(10) ; // Offset to Before null byte map
         BeforeNullLength int(10) ; // Length of Before null byte map
         AfterOffset int(10) ;      // Offset to After image
         AfterLength int(10) ;      // Length of After image
         AfterNullOffset int(10) ;  // Offset to After null byte map
         AfterNullLength int(10) ;  // Length of After null byte map
         *n char(16) ;              // Reserved

         // This part is file dependent
         BeforeImage char(203) ;    // Before image (= Record length)
         BeforeNulls char(30) ;     // Before null byte map (1 byte per field)
         *n char(7) ;               // Just to make the second record line up
         AfterImage char(203) ;     // After image
         AfterNulls char(30) ;      // After null byte map
       end-ds ;

       dcl-ds Parm2 ;
         Parm1Length int(10) ;      // Length of Parm1
       end-ds ;
