/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Program . . : CBX167M                                            */
/*  Description : Display Data Queue Entries - Create command        */
/*  Author  . . : Carsten Flensburg                                  */
/*                                                                   */
/*                                                                   */
/*  Program function:  Compiles, creates and configures all the      */
/*                     Display Data Queue Entries command objects.   */
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
/*    CrtClPgm    Pgm( CBX167M )                                     */
/*                SrcFile( QCLSRC )                                  */
/*                SrcMbr( *PGM )                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
     Pgm    &UtlLib

     Dcl    &UtlLib         *Char     10

     MonMsg      CPF0000    *N        GoTo Error


     CrtMsgF     MsgF( &UtlLib/CBX167M )  Aut( *USE )

     AddMsgD     CBX1001                                        +
                 MsgF( &UtlLib/CBX167M )                        +
                 Msg( 'No data queue entries found' )           +
                 SecLvl( *NONE )


     CrtRpgMod   &UtlLib/CBX167                  +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *Module )               +
                 DbgView( *LIST )

     CrtPgm      &UtlLib/CBX167                  +
                 Module( &UtlLib/CBX167 )        +
                 ActGrp( *NEW )

     CrtRpgMod   &UtlLib/CBX167E                 +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *Module )               +
                 DbgView( *LIST )

     CrtPgm      &UtlLib/CBX167E                 +
                 Module( &UtlLib/CBX167E )       +
                 ActGrp( *CALLER )

     CrtRpgMod   &UtlLib/CBX167L                 +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *Module )               +
                 DbgView( *LIST )

     CrtPgm      &UtlLib/CBX167L                 +
                 Module( &UtlLib/CBX167L )       +
                 ActGrp( *CALLER )

     CrtRpgMod   &UtlLib/CBX167V                 +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *Module )               +
                 DbgView( *LIST )

     CrtPgm      &UtlLib/CBX167V                 +
                 Module( &UtlLib/CBX167V )       +
                 ActGrp( QILE )


     CrtPnlGrp   &UtlLib/CBX167H                 +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *PNLGRP )

     CrtPnlGrp   &UtlLib/CBX167P                 +
                 SrcFile( &UtlLib/DATAQUEUE )    +
                 SrcMbr( *PNLGRP )


     CrtCmd      Cmd( &UtlLib/DSPDTAQE )                        +
                 Pgm( CBX167 )                                  +
                 SrcFile( &UtlLib/DATAQUEUE )                   +
                 SrcMbr( CBX167X )                              +
                 VldCkr( CBX167V )                              +
                 Allow( *INTERACT *IPGM *IREXX *IMOD )          +
                 AlwLmtUsr( *NO )                               +
                 MsgF( &UtlLib/CBX167M )                        +
                 HlpPnlGrp( CBX167H )                           +
                 HlpId( *CMD )


     SndPgmMsg   Msg( 'Display Data Queue Entries command'  *Bcat +
                      'successfully created in library'     *Bcat +
                      &UtlLib                               *Tcat +
                      '.' )                                       +
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
