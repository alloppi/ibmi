      * CH6CSV: Example of a report in ASCII CSV format
      *  (From Chap 6)
      *
      * To compile:
      *   CRTBNDRPG CH6CSV SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE') BNDDIR('IFSTEXT')

     FQADSPOBJ  IF   E           K DISK    USROPN

     D/copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D/copy IFSEBOOK/QRPGLESRC,ERRNO_H
     D/copy IFSEBOOK/QRPGLESRC,IFSTEXT_H

     D Cmd             PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   len                         15P 5 const

     D FmtDate         PR            10A
     D   mmddyy                       6A   const

     D fd              S             10I 0
     D line            S            100A
     D len             S             10I 0
     D LineNo          S             10I 0

     c     *entry        plist
     c                   parm                    MyLib            10

     C*********************************************************
     C* Create a file containing the objects we wish to report
     C*********************************************************
     C                   callp     cmd('DSPOBJD OBJ('+%trim(MyLib)+'/*ALL)'+
     C                               ' OBJTYPE(*ALL) OUTPUT(*OUTFILE) ' +
     C                               ' OUTFILE(QTEMP/QADSPOBJ) ' +
     C                               ' OUTMBR(*FIRST *REPLACE)': 200)

     C*********************************************************
     C* Open the list of objects:
     C*********************************************************
     c                   callp     cmd('OVRDBF FILE(QADSPOBJ) TOFILE(' +
     c                                  'QTEMP/QADSPOBJ)': 200)
     c                   open      QADSPOBJ

     C*********************************************************
     C* Open a stream file to CSV data to:
     C*********************************************************
     c                   eval      fd = open('/ifstest/object_report.csv':
     c                                 O_CREAT+O_TRUNC+O_CODEPAGE+O_WRONLY:
     c                                 S_IRWXU+S_IRWXG+S_IROTH: 819)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif
     c                   callp     close(fd)

     c                   eval      fd = open('/ifstest/object_report.csv':
     c                                       O_TEXTDATA+O_WRONLY)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     c                   endif

     C*********************************************************
     C* Create the report
     C*********************************************************
     c                   read      QADSPOBJ

     c                   dow       not %eof(QADSPOBJ)
     c                   exsr      WriteObj
     c                   read      QADSPOBJ
     c                   enddo


     C*********************************************************
     c* Clean up and exit
     C*********************************************************
     c                   callp     close(fd)
     c                   close     QADSPOBJ
     c                   callp     cmd('DLTOVR FILE(QADSPOBJ)': 50)
     c                   callp     cmd('DLTF QTEMP/QADSPOBJ': 50)

     c                   eval      *inlr = *on



     C*===============================================================
     C* Add an object to the report
     C*===============================================================
     CSR   WriteObj      begsr
     C*------------------------
     c                   eval      Line = '"' + %trim(odobnm) + '",' +
     c                               '"' + %trim(odobtp) + '",' +
     c                               %trim(%editc(odobsz:'L')) + ',' +
     c                               '"' + %trim(FmtDate(odldat)) + '",' +
     c                               '"' + %trim(FmtDate(odudat)) + '"'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     C*------------------------
     csr                 endsr


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Format a date into human-readable YYYY-MM-DD format:
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P FmtDate         B
     D FmtDate         PI            10A
     D   mmddyy                       6A   const

     D Temp6           S              6  0
     D TempDate        S               D
     D Temp10          S             10A

     C* If date isn't a valid number, return *blanks
     c                   testn                   mmddyy               99
     c                   if        *in99 = *off
     c                   return    *blanks
     c                   endif

     C* If date isn't a valid MMDDYY date, return *blanks
     c                   move      mmddyy        Temp6
     c     *mdy          test(de)                Temp6
     c                   if        %error
     c                   return    *blanks
     c                   endif

     C* Convert date to ISO format, and return it.
     c     *mdy          move      Temp6         TempDate
     c     *iso          move      TempDate      Temp10
     c                   return    Temp10

     P                 E

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY IFSEBOOK/QRPGLESRC,ERRNO_H
