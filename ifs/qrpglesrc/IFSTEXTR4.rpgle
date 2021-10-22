      ** Service program to assist in creating TEXT files in the IFS
      **
      **  To compile:
      **     CRTRPGMOD IFSTEXTR4 SRCFILE(IFSEBOOK/QRPGLESRC) DBGVIEW(*LIST)
      **     CRTSRVPGM IFSTEXTR4 TEXT('IFS Text service program')
      **                EXPORT(*SRCFILE) SRCFILE(IFSEBOOK/QSRVSRC)

     H NOMAIN OPTION(*NOSHOWCPY: *SRCSTMT)

     D/copy ifsebook/qrpglesrc,ifsio_h
     D/copy ifsebook/qrpglesrc,ifstext_h

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  The concept here is very simple:
      *     1) Write the data passed to us into the stream file.
      *     2) Add the end of line characters.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P writeline       B                   export
     D writeline       PI            10I 0
     D   fd                          10I 0 value
     D   text                          *   value
     D   len                         10I 0 value

     D rc1             S             10I 0
     D rc2             S             10I 0
     D eol             S              2A

     C* write the text provided
     c                   if        len > 0
     c                   eval      rc1 = write(fd: text: len)
     c                   if        rc1 < 1
     c                   return    rc1
     c                   endif
     c                   endif

     C* then add the end-of-line chars
     c                   eval      eol = x'0d25'
     c                   eval      rc2 = write(fd: %addr(eol): 2)
     c                   if        rc2 < 1
     c                   return    rc2
     c                   endif

     c                   return    rc1 + rc2
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This one's a bit more complicated.
      *     a) We don't know how long the text will go before
      *         an end-of-line sequence is encountered.
      *     b) We could just read one byte at a time until we found
      *         the EOL sequence, but that would run very slowly
      *         since it's inefficient to transfer chunks of data
      *         that small from disk.
      *
      *  So...  we keep a "read buffer".  We load chunks of data
      *  from disk into the buffer, then get one character at a
      *  time from that buffer.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P readline        B                   export
     D readline        PI            10I 0
     D   fd                          10I 0 value
     D   text                          *   value
     D   maxlen                      10I 0 value

     D rdbuf           S           1024A   static
     D rdpos           S             10I 0 static
     D rdlen           S             10I 0 static

     D p_retstr        S               *
     D RetStr          S          32766A   based(p_retstr)
     D len             S             10I 0

     c                   eval      len = 0
     c                   eval      p_retstr = text
     c                   eval      %subst(RetStr:1:MaxLen) = *blanks

     c                   dow       1 = 1

     C* Load the buffer
     c                   if        rdpos>=rdlen
     c                   eval      rdpos = 0
     c                   eval      rdlen=read(fd:%addr(rdbuf):%size(rdbuf))
     c                   if        rdlen < 1
     c                   return    -1
     c                   endif
     c                   endif

     C* Is this the end of the line?
     c                   eval      rdpos = rdpos + 1
     c                   if        %subst(rdbuf:rdpos:1) = x'25'
     c                   return    len
     c                   endif

     C* Otherwise, add it to the text string.
     c                   if        %subst(rdbuf:rdpos:1) <> x'0d'
     c                               and len<maxlen
     c                   eval      len = len + 1
     c                   eval      %subst(retstr:len:1) =
     c                               %subst(rdbuf:rdpos:1)
     c                   endif

     c                   enddo

     c                   return    len
     P                 E
