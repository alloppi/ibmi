**free

// Refer: https://www.rpgpgm.com/2018/03/processing-simple-xml-using-xml-into.html

dcl-c XML2 '<People>+
             <Person>+
               <Name>+
                 <First>Simon</First>+
                 <Last>Hutchinson</Last>+
               </Name>+
               <City>Los Angeles</City>+
               <State>CA</State>+
             </Person>+
             <Person>+
               <Name>+
                 <First>Donald</First>+
                 <Last>Trump</Last>+
               </Name>+
               <City>Washington</City>+
               <State>DC</State>+
             </Person>+
            </People>' ;

dcl-ds Person dim(10) qualified ;
  dcl-ds Name ;
    First varchar(20) ;
    Last varchar(30) ;
  end-ds ;
  City varchar(30) ;
  State char(2) ;
end-ds ;

xml-into Person %xml(XML2:'case=any') ;

*inlr = *on ;
