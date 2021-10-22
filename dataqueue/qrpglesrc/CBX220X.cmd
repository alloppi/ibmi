/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Compile options:                                                 */
/*                                                                   */
/*    CrtCmd Cmd( CHGDTAQ )                                          */
/*           Pgm( CBX220 )                                           */
/*           SrcMbr( CBX220X )                                       */
/*           VldCkr( CBX220V )                                       */
/*           HlpPnlGrp( CBX220H )                                    */
/*           HlpId( *CMD )                                           */
/*           PmtOvrPgm( CBX220O )                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
             Cmd        Prompt( 'Change Data Queue' )


             Parm       DTAQ        Q0001                  +
                        Min( 1 )                           +
                        Keyparm( *YES )                    +
                        Prompt( 'Data queue' )

             Parm       AUTRCL      *Char         1        +
                        Rstd( *YES )                       +
                        Dft( *SAME )                       +
                        SpcVal(( *SAME  '*' )              +
                               ( *NO    '0' )              +
                               ( *YES   '1' ))             +
                        Expr( *YES )                       +
                        Prompt( 'Automatic reclaim' )

             Parm       ENFORCE     *Char         1        +
                        Rstd( *YES )                       +
                        Dft( *SAME )                       +
                        SpcVal(( *SAME  '*' )              +
                               ( *NO    '0' )              +
                               ( *YES   '1' ))             +
                        Expr( *YES )                       +
                        Prompt( 'Enforce data queue locks' )


Q0001:       Qual                   *Name        10        +
                        Expr( *YES )

             Qual                   *Name        10        +
                        Dft( *LIBL )                       +
                        SpcVal(( *LIBL ) ( *CURLIB ))      +
                        Expr( *YES )                       +
                        Prompt( 'Library' )

