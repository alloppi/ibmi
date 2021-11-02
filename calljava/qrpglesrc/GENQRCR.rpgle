      //--------------------------------------------------------------------------------------------
      // Author: Alan Chan
      // Desc: Program showing how to create multiple types of QR codes
      //--------------------------------------------------------------------------------------------
     H dftactgrp(*no)

     D GenQR           pr                  extpgm('GENQRCODER')
     D  P_Txt                      4296a   const
     D  P_Width                      10i 0 const
     D  P_Height                     10i 0 const
     D  P_File                      128a   const
     D  R_Result                           likeds(gResult)

     D gResult         ds                  qualified
     D  code                         10a
     D  text                       5000a

     D gTxt            s           4296a   varying
     D gWidth          s             10i 0 inz(200)
     D gHeight         s             10i 0 inz(200)
     D gFile           s            128a   varying
      /free

       *inlr = *on;

       //
       // Create QR code with new line characters in it.
       //
       gTxt  = 'Alan Chan\n14/F., Luk Kwok Center\n72 Gloucester Road, Wanchai';
       gFile = '/javaapps/QRCode/myNewLine.png';
       GenQR(gTxt: gWidth: gHeight: gFile: gResult);
       exsr chkErr;

       //
       // Create QR code using the MECARd format so it comes up as a contact on
       // the phone.
       //
       gTxt  = 'MECARD:N:Chan,Alan;ADR:Hong Kong' +
               ';TEL:+85212345678;EMAIL:dept@abc.com.hk;';
       gFile = '/javaapps/QRCode/myCard.png';
       GenQR(gTxt: gWidth: gHeight: gFile: gResult);
       exsr chkErr;

       //
       // Create QR code that will prefill an email with TO, SUB and BODY
       //
       gTxt  = 'MATMSG:TO:dept@abc.com.hk;SUB:Gen QR Code Test;' +
               'BODY:Hi Alan, Can you see the correct QR code?;';
       gFile = '/javaapps/QRCode/myMsg.png';
       GenQR(gTxt: gWidth: gHeight: gFile: gResult);
       exsr chkErr;

       //
       // Create QR code that will contain a URL
       //
       gTxt  = 'https://www.abc.com.hk';
       gFile = '/javaapps/QRCode/myURL.png';
       GenQR(gTxt: gWidth: gHeight: gFile: gResult);
       exsr chkErr;

       //***********************************************
       // chkErr - Check for errors
       //***********************************************
       begsr chkErr;
       if gResult.code <> 'SUCCESS';
         dsply ('Error occurred:' + gResult.code);
         dsply ( %subst(gResult.text: 1: 52) );
         // review gResult.text for Java error.
       endif;
       endsr;

      /end-free

