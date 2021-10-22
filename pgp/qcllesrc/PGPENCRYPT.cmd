             CMD        PROMPT('Encrypt')

             PARM       KWD(CMDTYPE) TYPE(*CHAR) LEN(1) CONSTANT('1')

             PARM       KWD(FILE) TYPE(*PNAME) LEN(200) CASE(*MIXED) +
                          CHOICE('NAME') PROMPT('File to encrypt')

             PARM       KWD(DIR) TYPE(*PNAME) LEN(200) CASE(*MIXED) +
                          CHOICE('NAME') PROMPT('Target directory')

             PARM       KWD(ARMOR) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) CHOICE('*YES, +
                          *NO') PROMPT('Armor')

             PARM       KWD(INTEGRITY) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) CHOICE('*YES, +
                          *NO') PROMPT('Integrity')

             PARM       KWD(KEYFILE) TYPE(*PNAME) LEN(200) +
                          CASE(*MIXED) CHOICE('NAME') PROMPT('Key +
                          file')

             PARM       KWD(KEYID) TYPE(*CHAR) LEN(200) CASE(*MIXED) +
                          PROMPT('Key id (0XHexValue)')

             PARM       KWD(SIGACTION) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          DFT(*NOSIGN) VALUES(*NOSIGN *SIGN) +
                          CHOICE('*NOSIGN, *SIGN') +
                          PROMPT('Signature action')

             PARM       KWD(SIGKEYFILE) TYPE(*PNAME) LEN(200) +
                          CASE(*MIXED) CHOICE('NAME') PMTCTL(SIGCTL) +
                          PROMPT('Signature key file')

             PARM       KWD(SIGKEYID) TYPE(*CHAR) LEN(200) +
                          CASE(*MIXED) PMTCTL(SIGCTL) +
                          PROMPT('Signature key id (0XHexValue)')

             PARM       KWD(SIGPASSPHR) TYPE(*PNAME) LEN(200) +
                          CASE(*MIXED) CHOICE('NAME') PMTCTL(SIGCTL) +
                          PROMPT('Signature passphrase')

 SIGCTL:     PMTCTL     CTL(SIGACTION) COND((*EQ '*SIGN'))
