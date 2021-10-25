     A*  SAMPLE DDS TO PROVIDE AN EXAMPLE OF SEARCHING A
     A*  SUBFILE USING REGULAR EXPRESSIONS
     A*                       SCOTT KLEMENT, OCTOBER, 2012
     A*
     A*  TO COMPILE:
     A*>    CRTDSPF FILE(REGSUBFS) SRCFILE(QDDSSRC)
     A*
     A                                      DSPSIZ(24 80 *DS3)
     A                                      INDARA
     A          R REGSUBF1S                 SFL
     A            CUSNUM         6  0O  6 15
     A            LSTNAM         8   O  6 22
     A            INIT           3   O  6 31
     A            STREET        13   O  6 36
     A            CITY           6   O  6 50
     A            STATE          2   O  6 57
     A            ZIPCOD         5  0O  6 61
     A          R REGSUBF1C                 SFLCTL(REGSUBF1S)
     A                                      CA03(03)
     A                                      OVERLAY
     A N51                                  SFLDSP
     A N50                                  SFLDSPCTL
     A  50                                  SFLCLR
     A N50                                  SFLEND(*MORE)
     A                                      SFLSIZ(9999)
     A                                      SFLPAG(0016)
     A                                  1 26'Regular Expression Search Demo'
     A                                      DSPATR(HI)
     A                                  3  3'Pattern:'
     A            PATTERN       60   B  3 12CHECK(LC)
     A                                  5 15'CustNo'
     A                                      DSPATR(UL)
     A                                      DSPATR(HI)
     A                                  5 22'LastName'
     A                                      DSPATR(UL)
     A                                      DSPATR(HI)
     A                                  5 31'Init'
     A                                      DSPATR(UL)
     A                                      DSPATR(HI)
     A                                  5 36'   Street    '
     A                                      DSPATR(HI)
     A                                      DSPATR(UL)
     A                                  5 50' City '
     A                                      DSPATR(HI)
     A                                      DSPATR(UL)
     A                                  5 57'St'
     A                                      DSPATR(HI)
     A                                      DSPATR(UL)
     A                                  5 60'ZipCode'
     A                                      DSPATR(HI)
     A                                      DSPATR(UL)
     A          R REGSUBF1F
     A            MSG           60   O 23 11DSPATR(HI)
     A                                      DSPATR(BL)
     A                                 24  2'F3=Exit'
