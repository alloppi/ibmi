      * CH7QSHDIR: More complex example of reading a dir in the IFS
      *  We try to make our output look like the MS-DOS "DIR" command
      *  (From Chap 7)
      *
      * To compile:
      *   CRTBNDRPG CH7QSHDIR SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE') BNDDIR('IFSTEXT')

     D/copy IFSEBOOK/QRPGLESRC,IFSIO_H
     D/copy IFSEBOOK/QRPGLESRC,ERRNO_H
     D/copy IFSEBOOK/QRPGLESRC,IFSTEXT_H

     D STDIN           C                   CONST(0)
     D STDOUT          C                   CONST(1)
     D STDERR          C                   CONST(2)

     D S_ISDIR         PR             1N
     D   mode                        10U 0 value

     D CEEUTCO         PR                  ExtProc('CEEUTCO')
     D   hours                       10I 0
     D   minutes                     10I 0
     D   seconds                      8F

     D line            s           1024A
     D len             s             10I 0
     D dir             S               *
     D filename        S           1024A   varying
     D fnwithdir       S           2048A   varying
     D mystat          S                   like(statds)
     D curr            s           1024A
     D curdir          s           1024A   varying
     D dot             S             10I 0
     D notdot          S             10I 0
     D epoch           S               Z   inz(z'1970-01-01-00.00.00.000000')
     D ext             S              3A
     D filedate        S              8A
     D filetime        S              6A
     D modtime         S               Z
     D mydate          S               D
     D mytime          S               T
     D shortfn         S              8A
     D size            S             13A
     D worktime        S              8A
     D hours_utc       s             10I 0
     D mins_utc        s             10I 0
     D secs_utc        s              8F
     D utcoffset       s             10I 0

      * Here's an example of what an MS-DOS directory listing
      * looks like:
      *
      *   Directory of C:\WINDOWS
      *
      *  .              <DIR>        10-24-00 10:28a .
      *  ..             <DIR>        10-24-00 10:28a ..
      *  COMMAND        <DIR>        05-08-00 11:54a COMMAND
      *  VB       INI         1,245  10-04-01  9:12p VB.INI
      *  LOCALS~1       <DIR>        10-06-01  9:44p Local Settings
      *  BDDKL    DRV         1,986  11-21-01  8:43p bddkl.drv
      *  BPKPC    DRV         3,234  11-21-01  8:43p bpkpc.drv
      *  PILCIKK  DRV         1,122  11-21-01  8:43p pilcikk.drv
      *  NEWRES~1 RC          1,440  12-12-01  2:02a newrestest.rc

     c                   eval      *inlr = *on

     C*******************************************
     C* get the number of seconds between local
     C* time an Universal Time Coordinated (UTC)
     C*******************************************
     c                   callp(e)  CEEUTCO(hours_utc: mins_utc: secs_utc)
     c                   if        %error
     c                   eval      utcoffset = 0
     c                   else
     c                   eval      utcoffset = secs_utc
     c                   endif

     C*******************************************
     C* Use the getcwd() API to find out the
     C* name of the current directory:
     C*******************************************
     c                   if        getcwd(%addr(curr): %size(curr)) = *NULL
     c                   eval      line = 'getcwd(): ' +
     c                                     %str(strerror(errno))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(STDERR: %addr(line): len)
     c                   return
     c                   endif

     c                   eval      curdir = %str(%addr(curr))

     C*******************************************
     C* open the current directory:
     C*******************************************
     c                   eval      dir = opendir(curdir)
     c                   if        dir = *NULL
     c                   eval      line = 'opendir(): ' +
     c                                     %str(strerror(errno))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(STDERR: %addr(line): len)
     c                   return
     c                   endif

     c                   eval      line = ''
     c                   eval      len = 0
     c                   callp     writeline(STDOUT: %addr(line): len)

     c                   eval      line = ' Directory of ' + curdir
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(STDOUT: %addr(line): len)

     c                   eval      line = ''
     c                   eval      len = 0
     c                   callp     writeline(STDOUT: %addr(line): len)

     c                   eval      p_statds = %addr(mystat)

     c                   eval      p_dirent = readdir(dir)
     c                   dow       p_dirent <> *NULL
     c                   eval      filename = %subst(d_name:1:d_namelen)
     c                   eval      fnwithdir = curdir + '/' + filename
     c                   if        stat(fnwithdir: %addr(mystat))=0
     c                   exsr      PrintFile
     c                   endif
     c                   eval      p_dirent = readdir(dir)
     c                   enddo

     c                   callp     closedir(dir)


     C*===============================================================
     C* For each file in the directory, print a line of info:
     C*===============================================================
     CSR   PrintFile     begsr
     C*------------------------
     C* Separate into extension & short filename:
     c     '.'           check     filename      notdot
     c                   if        notdot = 0
     c                   eval      ext = *blanks
     c                   eval      shortfn = filename
     c                   else
     c                   eval      dot = %scan('.': filename: notdot)
     c                   if        dot > 0
     c                   eval      ext = %subst(filename:dot+1)
     c                   eval      shortfn = %subst(filename: 1: dot-1)
     c                   else
     c                   eval      ext = *blanks
     c                   eval      shortfn = filename
     c                   endif
     c                   endif

     C* Show size if this is not a directory:
     c                   if        S_ISDIR(st_mode)
     c                   eval      size = '<DIR>'
     c                   else
     c                   eval      size = %editc(st_size: 'K')
     c                   endif

     C* figure out date & time:
     c     epoch         adddur    st_atime:*S   modtime
     c                   adddur    utcoffset:*S  modtime
     c                   move      modtime       mydate
     c                   move      modtime       mytime
     c     *MDY-         move      mydate        filedate
     c     *USA          move      mytime        worktime
     c                   eval      filetime=%subst(worktime:1:5) +
     c                                      %subst(worktime:7:1)

     C* and write it to QSH STDOUT:
     c                   eval      line = shortfn + ' ' + ext + '  ' +
     c                               size + '  ' + filedate + ' ' +
     c                               filetime + ' ' + filename
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(STDOUT: %addr(line): len)
     C*------------------------
     CSR                 endsr


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This tests a file mode to see if a file is a directory.
      *
      * Here is the C code we're trying to duplicate:
      *      #define _S_IFDIR    0040000                                       */
      *      #define S_ISDIR(mode) (((mode) & 0370000) == _S_IFDIR)
      *
      * 1) ((mode) & 0370000) takes the file's mode and performs a
      *      bitwise AND with the octal constant 0370000.  In binary,
      *      that constant looks like: 00000000000000011111000000000000
      *      The effect of this code is to turn off all bits in the
      *      mode, except those marked with a '1' in the binary bitmask.
      *
      * 2) ((result of #1) == _S_IFDIR)  What this does is compare
      *      the result of step 1, above with the _S_IFDIR, which
      *      is defined to be the octal constant 0040000.  In decimal,
      *      that octal constant is 16384.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P S_ISDIR         B
     D S_ISDIR         PI             1N
     D   mode                        10U 0 value

     D                 DS
     D  dirmode                1      4U 0
     D  byte1                  1      1A
     D  byte2                  2      2A
     D  byte3                  3      3A
     D  byte4                  4      4A

     C* Turn off bits in the mode, as in step (1) above.
     c                   eval      dirmode = mode

     c                   bitoff    x'FF'         byte1
     c                   bitoff    x'FE'         byte2
     c                   bitoff    x'0F'         byte3
     c                   bitoff    x'FF'         byte4

     C* Compare the result to 0040000, and return true or false.
     c                   if        dirmode = 16384
     c                   return    *On
     c                   else
     c                   return    *Off
     c                   endif
     P                 E

      /DEFINE ERRNO_LOAD_PROCEDURE
      /COPY IFSEBOOK/QRPGLESRC,ERRNO_H
