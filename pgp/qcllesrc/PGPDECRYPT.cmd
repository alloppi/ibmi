             CMD        PROMPT('Decrypt')

             PARM       KWD(CMDTYPE) TYPE(*CHAR) LEN(1) CONSTANT('2')

             PARM       KWD(FILE) TYPE(*PNAME) LEN(200) CASE(*MIXED) +
                          CHOICE('NAME') PROMPT('File to decrypt')

             PARM       KWD(DIR) TYPE(*PNAME) LEN(200) CASE(*MIXED) +
                          CHOICE('NAME') PROMPT('Target directory')

             PARM       KWD(ARMOR) TYPE(*CHAR) LEN(4) CONSTANT(' ')

             PARM       KWD(INTEGRITY) TYPE(*CHAR) LEN(4) CONSTANT(' ')

             PARM       KWD(SECKEYFILE) TYPE(*PNAME) LEN(200) +
                          CASE(*MIXED) CHOICE('NAME') +
                          PROMPT('Secret key file')

             PARM       KWD(PASSPHRASE) TYPE(*PNAME) LEN(200) +
                          CASE(*MIXED) CHOICE('NAME') +
                          PROMPT('Passphrase')

             PARM       KWD(SIGACTION) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          DFT(*IGNORE) VALUES(*IGNORE *WARN *ERROR) +
                          CHOICE('*IGNORE, *WARN, *ERROR') +
                          PROMPT('Signature action')

             PARM       KWD(SIGKEYFILE) TYPE(*PNAME) LEN(200) +
                          CASE(*MIXED) CHOICE('NAME') +
                          PROMPT('Signature key file')

             PARM       KWD(SIGKEYID) TYPE(*CHAR) LEN(200) +
                          CONSTANT(' ')

             PARM       KWD(SIGPASSPHR) TYPE(*CHAR) LEN(200) +
                          CONSTANT(' ')
