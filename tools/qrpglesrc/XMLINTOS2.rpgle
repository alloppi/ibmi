**free

// Refer: https://www.rpgpgm.com/2018/03/processing-simple-xml-using-xml-into.html

dcl-ds Person dim(10) qualified ;
  dcl-ds Name ;
    First varchar(20) ;
    Last varchar(30) ;
  end-ds ;
  CountName int(5) ;
  City varchar(30) ;
  CountCity int(5) ;
  State char(2) ;
  CountState int(5) ;
end-ds ;

dcl-ds PgmDs psds qualified ;
  Count int(20) pos(372) ;
end-ds ;

dcl-s i int(5) ;
dcl-s TotalName int(10) ;
dcl-s TotalCity int(10) ;
dcl-s TotalState int(10) ;

xml-into Person
  %xml('/home/cya012/Person.xml':
       'case=any doc=file countprefix=count') ;

for i = 1 to PgmDs.Count ;
  TotalName += Person(i).CountName ;
  TotalCity += Person(i).CountCity ;
  TotalState += Person(i).CountState ;
endfor ;

*inlr = *on ;
