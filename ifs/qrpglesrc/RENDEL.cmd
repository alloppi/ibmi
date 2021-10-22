             CMD        PROMPT('Rename or Delete an IFS object')
             PARM       KWD(OLD) TYPE(*CHAR) LEN(640) +
                          PROMPT('Original (OLD) Object Name')
             PARM       KWD(NEW) TYPE(*CHAR) LEN(640) +
                          CHOICE('Character or *DELETE') +
                          PROMPT('New Object Name or *DELETE')
