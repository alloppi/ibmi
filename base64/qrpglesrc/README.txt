Please see LICENSE.TXT for legal information.

This contains my base64 encode/decode service program.
(Requires V5R2 or later)

PC Filename		           Source File,Member on i5/OS
-----------------       -------------------------------
LICENSE.TXT		           QRPGLESRC,LICENSE
BASE64R4.RPGLE		        QRPGLESRC,BASE64R4
BASE64_H.RPGLE		        QRPGLESRC,BASE64_H
BASE64R4.BND		          QSRVSRC,BASE64R4


Copying these members to the iSeries:

a) Copy the members that end with .RPGLE to whichever source file
    you use for ILE RPG source.  (I use QRPGLESRC)

b) Copy the member that ends with .BND to whichever source file you
    use for binder language source (I use QSRVSRC)

c) You may need to edit BASE64R4.RPGLE/B64OLD.RPGLE to change the
    library or source file name on the /COPY statement if the compiler
    can't find it when building the program.

d) There are instructions on how to compile this in the
    BASE64R4.RPGLE member, just after the copyright
    information.
