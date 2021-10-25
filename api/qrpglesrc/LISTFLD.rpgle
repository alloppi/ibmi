       dcl-pr CrtUserSpace extpgm('QUSCRTUS') ;
         *n char(20) const ;  // Name
         *n char(10) const ;  // Attribute
         *n int(10) const ;   // Initial size
         *n char(1) const ;   // Initial value
         *n char(10) const ;  // Authority
         *n char(50) const ;  // Text
         *n char(10) const options(*nopass) ;  // Replace existing
         *n char(32767) options(*varsize:*nopass) ;  // Error feedback
       end-pr ;

       dcl-pr GetPointer extpgm('QUSPTRUS') ;
         *n char(20) const ;   // Name
         *n pointer ;          // Pointer to user space
         *n char(32767) options(*varsize:*nopass) ;  // Error feedback
       end-pr ;

       dcl-pr DltUserSpace extpgm('QUSDLTUS') ;
         *n char(20) const ;   // Name
         *n char(32767) options(*varsize:*nopass) ;  // Error feedback
       end-pr ;

       /copy qsysinc/qrpglesrc,qusec

       dcl-pr ListFields extpgm('QUSLFLD') ;
         *n char(20) const ;  // User space name
         *n char(8) const ;   // Format
         *n char(20) const ;  // File name
         *n char(10) const ;  // Record format
         *n char(1) const ;   // Use override
         *n char(32767) options(*varsize:*nopass) ;  // Error feedback
       end-pr ;

       dcl-ds ListHeader based(UserSpacePointer) qualified ;
         Offset int(10) pos(125) ;
         Count int(10) pos(133) ;
         Size int(10) pos(137) ;
       end-ds ;

       dcl-ds FieldInfo based(FieldPointer) qualified ;
         Name char(10) pos(1) ;
       end-ds ;

       dcl-s i int(3) ;

       CrtUserSpace('@USRSPACE QTEMP':'':131072:x'00':
                    '*ALL':'List of fields in CUSTF   ':'*YES':QUSEC) ;

       ListFields('@USRSPACE QTEMP':'FLDL0100':'CUSTF     *LIBL':
                  'RCUST    ':'0':QUSEC) ;

       GetPointer('@USRSPACE QTEMP':UserSpacePointer) ;

       for i = 1 to ListHeader.Count ;
         FieldPointer = UserSpacePointer
                        + ListHeader.Offset
                        + (ListHeader.Size * (i - 1)) ;

         dsply FieldInfo.Name ;
       endfor ;

       *inlr = *on ;
       DltUserSpace('@USRSPACE QTEMP':QUSEC) ;
