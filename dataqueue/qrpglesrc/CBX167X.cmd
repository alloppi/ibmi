/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Compile options:                                                 */
/*                                                                   */
/*    CrtCmd  Cmd( DSPDTAQE )                                        */
/*            Pgm( CBX167 )                                          */
/*            SrcMbr( CBX167X )                                      */
/*            VldCkr( CBX167V )                                      */
/*            Allow( *INTERACT *IPGM *IREXX *IMOD )                  */
/*            HlpPnlGrp( CBX167H )                                   */
/*            HlpId( *CMD )                                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
          Cmd      Prompt( 'Display Data Queue Entries' )

          Parm     DTAQ        Q0001                            +
                   Min( 1 )                                     +
                   Choice( *NONE )                              +
                   Prompt( 'Data queue' )

          Parm     SEQ         *Char       1                    +
                   Rstd( *YES )                                 +
                   Dft( *DTAQDFN )                              +
                   SpcVal(( *DTAQDFN 'A' )                      +
                          ( *DTAQREV 'R' )                      +
                          ( *BYKEY   'K' )                      +
                          ( *FIRST   'F' )                      +
                          ( *LAST    'L' ))                     +
                   Prompt( 'Sequence' )

          Parm     SELECT      E0001                            +
                   PmtCtl( P0001 )                              +
                   Prompt('Select queue entries' )


E0001:    Elem                 *Char       2                    +
                   Rstd( *YES )                                 +
                   SpcVal(( *GT GT )                            +
                          ( *LT LT )                            +
                          ( *NE NE )                            +
                          ( *EQ EQ )                            +
                          ( *GE GE )                            +
                          ( *LE LE ))                           +
                   Min( 1 )                                     +
                   Expr( *YES )                                 +
                   Prompt( 'Relational operator' )

          Elem                 *Char     256                    +
                   SpcVal(( *BLANK ' ' ))                       +
                   Min( 1 )                                     +
                   Expr( *YES )                                 +
                   Vary( *YES *INT2 )                           +
                   Prompt( 'Key value' )

          Elem                 *Dec      ( 3 0 )                +
                   Dft( *DTAQDFN )                              +
                   SpcVal(( *DTAQDFN 0 ))                       +
                   Range( 1  256 )                              +
                   Expr( *YES )                                 +
                   Prompt( 'Key length' )


Q0001:    Qual                 *Name      10                    +
                   Min( 1 )                                     +
                   Expr( *YES )

          Qual                 *Name       10                   +
                   Dft( *LIBL )                                 +
                   SpcVal(( *LIBL )  ( *CURLIB *CURLIB ))       +
                   Expr( *YES )                                 +
                   Prompt( 'Library' )


 P0001:   PmtCtl   Ctl( SEQ )                                   +
                   Cond(( *EQ 'K' ))

          Dep      Ctl( &SEQ *NE 'K' )                          +
                   Parm(( SELECT ))                             +
                   NbrTrue( *EQ  0 )

          Dep      Ctl( &SEQ *EQ 'K' )                          +
                   Parm(( SELECT ))

