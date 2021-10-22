/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Program . . : CBX220M                                            */
/*  Description : Change Data Queue - Create command                 */
/*  Author  . . : Carsten Flensburg                                  */
/*  Published . : System iNetwork Programming Tips Newsletter        */
/*  Date  . . . : October 28, 2010                                   */
/*                                                                   */
/*                                                                   */
/*  Program function:  Compiles, creates and configures all the      */
/*                     Change Data Queue command objects.            */
/*                                                                   */
/*                     This program expects a single parameter       */
/*                     specifying the library to contain the         */
/*                     command objects.                              */
/*                                                                   */
/*                     Object sources must exist in the respective   */
/*                     source type default source files in the       */
/*                     command object library.                       */
/*                                                                   */
/*                                                                   */
/*  Compile options:                                                 */
/*    CrtClPgm    Pgm( CBX220M )                                     */
/*                SrcFile( QCLSRC )                                  */
/*                SrcMbr( *PGM )                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
     Pgm    &UtlLib

     Dcl    &UtlLib         *Char     10

     MonMsg      CPF0000    *N        GoTo Error


     CrtRpgMod   &UtlLib/CBX220                  +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *Module )               +
                 DbgView( *LIST )

     CrtPgm      &UtlLib/CBX220                  +
                 Module( &UtlLib/CBX220 )        +
                 ActGrp( *NEW )

     CrtRpgMod   &UtlLib/CBX220O                 +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *Module )               +
                 DbgView( *LIST )

     CrtPgm      &UtlLib/CBX220O                 +
                 Module( &UtlLib/CBX220O )       +
                 ActGrp( *NEW )

     CrtRpgMod   &UtlLib/CBX220V                 +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *Module )               +
                 DbgView( *LIST )

     CrtPgm      &UtlLib/CBX220V                 +
                 Module( &UtlLib/CBX220V )       +
                 ActGrp( *NEW )


     CrtPnlGrp   &UtlLib/CBX220H                 +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *PNLGRP )


     CrtCmd      Cmd( &UtlLib/CHGDTAQ )          +
                 Pgm( CBX220 )                   +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( CBX220X )               +
                 VldCkr( CBX220V )               +
                 AlwLmtUsr( *NO )                +
                 HlpPnlGrp( CBX220H )            +
                 HlpId( *CMD )                   +
                 PmtOvrPgm( CBX220O )


     SndPgmMsg   Msg( 'Change Data Queue command'         *Bcat +
                      'successfully created in library'   *Bcat +
                      &UtlLib                             *Tcat +
                      '.' )                                     +
                 MsgType( *COMP )


     Call        QMHMOVPM    ( '    '                 +
                               '*COMP'                +
                               x'00000001'            +
                               '*PGMBDY'              +
                               x'00000001'            +
                               x'0000000800000000'    +
                             )

     RmvMsg      Clear( *ALL )

     Return

/*-- Error handling:  -----------------------------------------------*/
 Error:
     Call        QMHMOVPM    ( '    '                 +
                               '*DIAG'                +
                               x'00000001'            +
                               '*PGMBDY'              +
                               x'00000001'            +
                               x'0000000800000000'    +
                             )

     Call        QMHRSNEM    ( '    '                 +
                               x'0000000800000000'    +
                             )

 EndPgm:
     EndPgm
