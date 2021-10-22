             CMD        PROMPT('Change File Mode')
             PARM       KWD(OBJ) TYPE(*CHAR) LEN(640) MIN(1) +
                          PROMPT('Object')
             PARM       KWD(USER) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*NONE) VALUES(*NONE *R *RW *RX *RWX +
                          *W *WX *X) PROMPT('Owner permissions')
             PARM       KWD(GROUP) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*NONE) VALUES(*NONE *R *RW *RX *RWX +
                          *W *WX *X) PROMPT('Group Permissions')
             PARM       KWD(OTHER) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*NONE) VALUES(*NONE *R *RW *RX *RWX +
                          *W *WX *X) PROMPT('Others Permissions')
