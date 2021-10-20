             CMD        PROMPT('Read JSON in Tree Structure')

             PARM       KWD(STMF) TYPE(*PNAME) LEN(60) +
                          DFT('/home/CYA012/zabank/RcvDtl2.json') +
                          EXPR(*YES) CASE(*MIXED) +
                          PROMPT('JSON IFS file')

