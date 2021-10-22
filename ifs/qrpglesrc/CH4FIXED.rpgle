      * CH4FIXED: Example of fixed-length records in an IFS file
      *  (From Chap 4)
      *
      * To compile:
      *   CRTBNDRPG CH4FIXED SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')

     D/copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D/copy IFSEBOOK/QRPGLESRC,ERRNO_H

     D dsRecord        DS
     D   PartNo                      10S 0
     D   Quantity                    10I 0
     D   UnitOfMeas                   3A
     D   Price                        7P 2
     D   Description                 50A

     D fd              S             10I 0
     D err             S             10I 0
     D MyStat          S                   like(statds)
     D recno           S             10I 0
     D NumRec          S             10I 0
     D SaveRec         S             10I 0
     D Pos             S             10I 0

     c                   exsr      MakeFile

     c                   eval      fd = open('/ifstest/ch4_records': O_RDWR)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     c                   exsr      UpdateEx
     c                   exsr      SearchEx

     c                   callp     close(fd)

     c                   eval      *inlr = *on


     C****************************************************************
     C* This creates a file in the IFS containing fixed-length
     C* records.
     C****************************************************************
     CSR   MakeFile      begsr
     C*------------------------
     c                   eval      fd = open('/ifstest/ch4_records':
     c                                    O_WRONLY+O_CREAT+O_TRUNC:
     c                                    S_IRUSR+S_IWUSR+S_IRGRP)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     c                   eval      PartNo = 5001
     c                   eval      Quantity = 14
     c                   eval      UnitOfMeas = 'BOX'
     c                   eval      Price = 7.95
     c                   eval      Description = 'BLUE WIDGETS'
     c                   callp     write(fd:%addr(dsRecord):%size(dsRecord))

     c                   eval      PartNo = 5002
     c                   eval      Quantity = 6
     c                   eval      UnitOfMeas = 'BOX'
     c                   eval      Price = 3.95
     c                   eval      Description = 'RAINBOW SUSPENDERS'
     c                   callp     write(fd:%addr(dsRecord):%size(dsRecord))

     c                   eval      PartNo = 5003
     c                   eval      Quantity = 19
     c                   eval      UnitOfMeas = 'SEA'
     c                   eval      Price = 29.95
     c                   eval      Description = 'RED BICYCLE SEATS'
     c                   callp     write(fd:%addr(dsRecord):%size(dsRecord))

     c                   eval      PartNo = 5004
     c                   eval      Quantity = 8
     c                   eval      UnitOfMeas = 'ITM'
     c                   eval      Price = 93512.80
     c                   eval      Description = 'REALLY EXPENSIVE ITEMS'
     c                   callp     write(fd:%addr(dsRecord):%size(dsRecord))

     c                   eval      PartNo = 5005
     c                   eval      Quantity = 414
     c                   eval      UnitOfMeas = 'BAT'
     c                   eval      Price = 11.41
     c                   eval      Description = 'BATS IN THE BELFRY'
     c                   callp     write(fd:%addr(dsRecord):%size(dsRecord))

     c                   eval      PartNo = 5006
     c                   eval      Quantity = 125
     c                   eval      UnitOfMeas = 'BOX'
     c                   eval      Price = 1.23
     c                   eval      Description = 'KATES OLD SHOES'
     c                   callp     write(fd:%addr(dsRecord):%size(dsRecord))

     c                   callp     close(fd)
     C*------------------------
     CSR                 endsr


     C****************************************************************
     C* This demonstrates updating our fixed-length record file:
     C****************************************************************
     CSR   UpdateEx      begsr
     C*------------------------
     C* Someone bought a box of suspenders, and we want to change
     C* the quantity:

     C* The suspenders are in record number 2, so get them now:
     c                   eval      recno = 2
     c                   eval      pos = %size(dsRecord) * (recno-1)
     c                   callp     lseek(fd: pos: SEEK_SET)
     c                   callp     read(fd: %addr(dsRecord):%size(dsRecord))

     c                   eval      Quantity = Quantity - 1
     c                   callp     lseek(fd: pos: SEEK_SET)
     c                   callp     write(fd:%addr(dsRecord):%size(dsRecord))

     C* Kate's shoes need to move faster, put them on sale!
     c                   eval      recno = 6
     c                   eval      pos = %size(dsRecord) * (recno-1)
     c                   callp     lseek(fd: pos: SEEK_SET)
     c                   callp     read(fd: %addr(dsRecord):%size(dsRecord))

     c                   eval      Price = 0.25
     c                   callp     lseek(fd: pos: SEEK_SET)
     c                   callp     write(fd:%addr(dsRecord):%size(dsRecord))
     C*------------------------
     CSR                 endsr


     C****************************************************************
     C* This demonstrates searching for a record in the file:
     C****************************************************************
     CSR   SearchEx      begsr
     C*------------------------
     C* GASP! I can't remember the record number for Bats!
     C* The part number was 5005, let's search for it
     c                   if        fstat(fd: %addr(mystat)) < 0
     c                   eval      err = errno
     c                   callp     close(fd)
     c                   callp     die('fstat(): ' + %str(strerror(err)))
     c                   endif

     c                   eval      p_statds = %addr(mystat)
     c                   eval      numrec = st_size / %size(dsRecord)
     c                   eval      SaveRec = -1

     c                   for       recno = 1 to numrec
     c                   eval      pos = %size(dsRecord) * (recno-1)
     c                   callp     lseek(fd: pos: SEEK_SET)
     c                   callp     read(fd: %addr(PartNo): %size(PartNo))
     c                   if        PartNo = 5005
     c                   eval      SaveRec = recno
     c                   leave
     c                   endif
     c                   endfor

     c                   if        SaveRec = -1
     c                   callp     close(fd)
     c                   callp     die('Part no 5005 not found!')
     c                   endif
     C*------------------------
     CSR                 endsr


      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY IFSEBOOK/QRPGLESRC,ERRNO_H
