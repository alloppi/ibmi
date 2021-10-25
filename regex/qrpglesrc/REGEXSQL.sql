Create or Replace Function
     RegExMatch(
         Pattern varchar(100),
         String  varchar(1000)
     )
     returns Integer
     language rpgle
     external name REGEXUDF(REGEXMATCH)
     program type sub
     parameter style sql
     no sql
     not deterministic
     final call;
