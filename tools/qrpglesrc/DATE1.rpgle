     H DatFmt(*ISO)

     D USA_date        S               D   datfmt(*usa) inz(*sys)
     D ISO_date        S               D   datfmt(*iso)
     D EUR_date        S               D   datfmt(*eur) inz(d'2019-11-23')
     D JIS_date        S               D   datfmt(*jis)

     D YMD_date        S               D   datfmt(*ymd)
     D DMY_date        S               D   datfmt(*dmy)
     D MDY_date        S               D   datfmt(*mdy)

     D JUL_date        S               D   datfmt(*jul)

     D Misc_date       S               D

     D A_USA           S              8    inz('09201995')
     D A_YMD           S             10    inz('93.01.21')
     D A_ISO1          S              8    inz
     D A_ISO2          S             10    inz('19501024')
     D N_CYMD          S              7  0 inz(1150930)

     C                   Eval      YMD_date = %date()

     C                   Eval      ISO_date = d'2019-10-30'
     C                   Eval      DMY_date = ISO_date
     C                   Eval      Misc_date = DMY_date
     C                   Eval      JUL_date = Misc_date

     C                   Eval      USA_date = d'1939-09-03'
     C***                Eval      MDY_date = USA_date

     C                   Eval      JIS_date = *loval
     C                   Eval      ISO_date = *hival
      /Free
         test(de) *usa0 A_USA ;
         if not(%error) ;
           YMD_date = %date(A_USA:*usa0) ;
         endif ;

         test(de) *ymd A_YMD ;
         if not(%error) ;
           MDY_date = %date(A_YMD:*ymd.) ;
         endif ;

         test(de) *iso0 A_ISO1 ;
         if (%error) ;
           clear ISO_date ;
         else ;
           ISO_date = %date(A_ISO1:*iso0) ;
         endif ;

         test(de) *iso0 A_ISO2 ;
         if not(%error) ;
           JIS_date = %date(A_ISO2:*iso0) ;
         endif ;

         test(de) *cymd N_CYMD ;
         if not(%error) ;
           USA_date = %date(N_CYMD:*cymd) ;
         endif ;



      /End-Free

     C                   Eval      *InLr = *On
