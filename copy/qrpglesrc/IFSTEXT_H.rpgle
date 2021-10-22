      /if defined(IFSTEXT_H)
      /eof
      /endif

      /define IFSTEXT_H

     D writeline       PR            10I 0
     D   fd                          10I 0 value
     D   text                          *   value
     D   len                         10I 0 value

     D readline        PR            10I 0
     D   fd                          10I 0 value
     D   text                          *   value
     D   maxlen                      10I 0 value
