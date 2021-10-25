Simplify Pattern Checking with Regular Expressions
by Scott Klement

-----------------------------------------------------------------------------
UPLOAD INSTRUCTIONS:
-----------------------------------------------------------------------------

This article contains a handy FTP script to help you upload the source code
from your PC to your IBM i system.  The script is called ftpsrc.bat.
To run it, type the following from an MS-DOS prompt:

   ftpsrc.bat HOST LIB USER PASSWORD

Where:   HOST = the TCP/IP host name or IP address of your system.
          LIB = library to upload the source code to
         USER = your userid to log on to FTP with
     PASSWORD = your password to log on to FTP with

For example, if you unzipped this code into the C:\Downloads folder on your PC, you'd open a Command

   C:
   cd \Downloads
   ftpsrc.bat as400.example.com qgpl scottk bigboy

This would connect to as400.example.com and log on as userid scottk, password
bigboy.  It would then upload the source code to the QGPL library on that
system.

Note: There's also an ftpsrc.sh shell script for FreeBSD users.  (Unfortunately
      I don't know if it's compatible with other Unix-like systems such as
      Linux.)

-----------------------------------------------------------------------------
MANUAL UPLOAD INSTRUCTIONS:
-----------------------------------------------------------------------------

If you are unable to use the FTP upload script, you can also upload the source
members using any other tool that you have available.  The members are
expected to be uploaded as follows:

PC source file        IBM i source file     source member
--------------        -------------------   -------------
qmhsndpm_h.rpgle.txt  QRPGLESRC             QMHSNDPM_H
regex_h.rpgle.txt     QRPGLESRC             REGEX_H
regexdemo.rpgle.txt   QRPGLESRC             REGEXDEMO
regsubf.rpgle.txt     QRPGLESRC             REGSUBF
regsubfs.dspf.txt     QDDSSRC               REGSUBFS
regexudf.rpgle.txt    QRPGLESRC             REGEXUDF
regexsql.sql.txt      QSQLSRC               REGEXSQL

-----------------------------------------------------------------------------
BUILD/COMPILE INSTRUCTIONS:
-----------------------------------------------------------------------------
See the compile instructions at the top of the REGEXDEMO, REGSUBF, and REGEXUDF
members.
