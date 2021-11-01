      * http://newsolutions.de/forum-systemi-as400-i5-iseries/threads/19291-_C_IFS_fgets-und-_C_IFS_
      * fputs
     h dftactgrp(*no) Option( *NoDebugIO ) bnddir('QC2LE')
     h datfmt(*dmy.) timfmt(*hms:) datedit(*dmy.) decedit('0,') debug(*yes)

     d Lesen           s               *
     d FILE_i          s               *
     d FILE_o          s               *
     d ErrTxt          s            128a
     d String          s            512a
     d String_aus      s            512a    Varying
     d rc              s             10i 0
     d File_Input      s            200
     d File_Output     s            200
     d Laenge          s             10i 0
     d
     d* -- IFS stream file functions: -----------------------------------**
     D open            Pr              *   ExtProc( '_C_IFS_fopen' )
     D                                 *    Value Options( *String )
     D                                 *    Value Options( *String )
     **
     D fgets           Pr              *   ExtProc( '_C_IFS_fgets' )
     D                                 *    Value
     D                               10i 0  Value
     D                                 *    Value
     **
     D fputs           Pr            10i 0 ExtProc( '_C_IFS_fputs' )
     D                                 *    Value Options( *String )
     D                                 *    Value
     **
     D remove          Pr            10i 0 ExtProc( 'unlink')
     D                                 *    Value Options( *String )
     **
     D close           Pr            10i 0 ExtProc( '_C_IFS_fclose' )
     D                                 *    Value

     c
     c                   Eval      File_Input  ='/home/alan/MyFile.txt'
     c                   Eval      File_Output ='/home/alan/MyNewFile.txt'
     c                   Eval      File_O = Open( %TrimR( File_Output)
     c                                          : 'w, codepage=850'  )
     c                   Eval      RC = Close( File_O )
     c                   Eval      File_O = Open( %TrimR( File_Output)
     c                                          : 'w'                )
     c                   Eval      File_I = Open( %TrimR( File_Input )
     c                                          : 'r'                )
     c                   If        File_I = *Null
     c                   Eval      ErrTxt = %Char( Errno ) + ': ' +
     c                                      Strerror
     c                   Else
     c                   Eval      Lesen = fgets( %Addr( String )
     c                                          : %Size( String )
     c                                          : File_i         )
     c                   DoW       Lesen <> *Null
     c                   Eval      Laenge = %Len( %Str(Lesen ) )
     c                   Eval      String_aus = %SubSt(%Str(lesen)
     c                                                 : 1 : Laenge-1)
     c                   Eval      String_aus = %Trim(String_aus) +'neuer Text'+
     c                                          x'25'
     c                   Eval      rc = fputs( String_aus
     c                                       : File_o                )
     c                   Eval      Lesen = fgets( %Addr( String )
     c                                          : %Size( String )
     c                                          : File_i         )
     c                   EndDo
     c                   Eval      rc = Close( FILE_i )
     C                   EndIf
     c                   Eval      rc = Close( FILE_o )
     c
     c                   Eval      *InLr  = *On
     **
     **-- Get runtime error number: -----------------------------------
     P Errno           B
     D                 Pi            10i 0
     D sys_errno       Pr              *   ExtProc( '__errno' )
     D Error           s             10i 0 Based( pError ) NoOpt
     C                   Eval      pError = sys_errno
     C                   Return    Error
     P Errno           E

     **-- Get runtime error text: --------------------------------------**
     P Strerror        B
     D                 Pi           128a   Varying
     D sys_strerror    Pr              *   ExtProc( 'strerror' )
     D                               10i 0 Value
     C                   Return    %Str( sys_strerror( Errno ))
     P Strerror        E
