             CMD        PROMPT('Check for IFS Object')
             PARM       KWD(OBJ) TYPE(*CHAR) LEN(640) MIN(1) +
                          PROMPT('Object')
             PARM       KWD(AUT) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*NONE) VALUES(*NONE *R *RW *RX *RWX +
                          *W *WX *X) PROMPT('Authority')
