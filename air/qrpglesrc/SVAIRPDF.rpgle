     H NOMAIN THREAD(*SERIALIZE) OPTION(*NODEBUGIO: *SRCSTMT: *NOSHOWCPY)
     D**********************************************************************
     D* iText PDF Service Program
     D**********************************************************************
     D* ====================================================================
     D* ============== Advanced Integrated RPG by Tom Snyder ===============
     D* ====================================================================
     D* Advanced Integrated RPG (AIR), Copyright (c) 2010 by Tom Snyder
     D* All rights reserved.
     D*
     D* Publisher URL: http://www.mcpressonline.com, http://www.mc-store.com
     D* Author URL:    http://www.2WolvesOut.com
     D*
     D* Source code/material located at http://www.mc-store.com/5105.html
     D* On the books page, click the reviews, errata, downloads icon to go
     D* to the books forum.  This source code may not be hosted on any
     D* other site without my express, prior, written permission.
     D*
     D* I disclaim any and all responsibility for any loss, damage or
     D* destruction of data or any other property which may arise using
     D* this code. I will in no case be liable for any monetary damages
     D* arising from such loss, damage or destruction.
     D*
     D* This code is intended for educational purposes, which includes
     D* minimal exception handling to focus on the topic being discussed.
     D* You may want to implement additional exception handling to prepare
     D* for a production environment.
     D*
     D* Happy Coding!
     D**********************************************************************
     D* iText is used to create PDFs.  Created by Bruno Lowagie
     D* Official iText Website:
     D*   http://itextpdf.com
     D* JavaDocs hosted at 2WolvesOut.com
     D*   http://www.2wolvesout.com/javadocs/itext/itext_2_1_2u/index.html
     D**********************************************************************
     D*   HOW TO COMPILE:
     D*
     D*   (1. CREATE THE MODULE)
     D*   CRTRPGMOD MODULE(AIRLIB/SVAIRPDF) SRCFILE(AIRLIB/AIRSRC) +
     D*             DBGVIEW(*ALL) INDENT('.')
     D*
     D*   (2. CREATE THE SERVICE PROGRAM)
     D*   CRTSRVPGM SRVPGM(AIRLIB/SVAIRPDF) EXPORT(*ALL)
     D*   BNDSRVPGM(SVAIRFUNC SVAIRJAVA) ACTGRP(SVAIRPDF)
     D**********************************************************************
     D*** PROTOTYPES ***
     D/DEFINE OS400_JVM_12
     D/DEFINE JNI_COPY_CALL_METHOD_FUNCTIONS
     D/COPY QSYSINC/QRPGLESRC,JNI
     D/COPY AIRLIB/AIRSRC,SPAIRFUNC
     D/COPY AIRLIB/AIRSRC,SPAIRJAVA
     D/COPY AIRLIB/AIRSRC,SPAIRPDF
     D**********************************************************************
     P AirPdf_newDocumentOutput...
     P                 B                   EXPORT
     D AirPdf_newDocumentOutput...
     D                 PI                  like(ITextDocument)
     D  argFileName                2048A   const varying
     D                                     options(*varsize)
     D  argSizeName                  64A   const varying
     D                                     options(*nopass: *varsize)
     D  argRotate                     1N   const options(*nopass)
     D  svString       S                   like(jString)
     D  svDocument     S                   like(ITextDocument)
     D                                     inz(*NULL)
     D  svRectangle    S                   like(ITextRectangle)
     D                                     inz(*NULL)
     D  svOutFile      S                   like(FileOutputStream)
      /free
       if (%parms > 1);
         svString = new_String(%trim(argSizeName));
         monitor;
           svRectangle = PageSize_getRectangle(svString);
           if (%parms > 2);
             if (argRotate);
               svRectangle = ITextRectangle_Rotate(svRectangle);
             else;
             endif;
           else;
           endif;
           svDocument = new_ITextDocumentFromRectangle(svRectangle);
         on-error;
           svDocument = *NULL;
         endmon;
       else;
       endif;
       if (svDocument = *NULL);
         monitor;
           svDocument = new_ITextDocument();
         on-error;
           svDocument = *NULL;
           return svDocument;
         endmon;
       else;
       endif;
       svString = new_String(%trim(argFileName));
       monitor;
         svOutFile = new_FileOutputStream(svString);
         AirPdf_setPdfWriter(svDocument: svOutFile);
         ITextDocument_open(svDocument);
       on-error;
         svDocument = *NULL;
       endmon;
       // Clean Up
       freeLocalRef(svString);
       freeLocalRef(svOutFile);
       return svDocument;
      /end-free
     P                 E
      **********************************************************************
     P AirPdf_newCopyFromDocument...
     P                 B                   EXPORT
     D AirPdf_newCopyFromDocument...
     D                 PI                  like(PdfCopy)
     D  argDocument                        like(ITextDocument)
     D  argFileName                2048A   const varying
     D                                     options(*varsize)
     D  svString       s                   like(jString)
     D  svOutFile      S                   like(FileOutputStream)
     D  svCopy         S                   like(PdfCopy)
      /free
       svString = new_String(argFileName);
       svOutFile = new_FileOutputStream(svString);
       svCopy = new_PdfCopy(argDocument: svOutFile);
       // Clean Up
       freeLocalRef(svOutFile);
       return svCopy;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_newReader...
     P                 B                   EXPORT
     D AirPdf_newReader...
     D                 PI                  like(PdfReader)
     D  argFileName                2048A   const varying
     D  svReader       S                   like(PdfReader)
     D  svString       S                   like(jString)
      /free
       svString = new_String(%trim(argFileName));
       svReader = new_PdfReader(svString);
       // Clean Up
       freeLocalRef(svString);
       return svReader;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_setPdfWriter...
     P                 B                   EXPORT
     D AirPdf_setPdfWriter...
     D                 PI                  like(PdfWriter)
     D   argDocument                       like(ITextDocument)
     D   argOutFile                        like(FileOutputStream)
     D instanceID      S                   like(jMethodId)
     D writerClass     S                   like(jclass)
     D                                     inz(*NULL)
     D svWriter        S                   like(PdfWriter)
     D                                     inz(*NULL)
     D cd              DS                  likeDs(iconv_t)
     D ebcdicString    S           1024A
     D asciiWriter     S           1024A
     D asciiInit       S           1024A
     D asciiInstance   S           1024A
     D asciiInstanceSignature...
     D                 S           1024A
     D toCCSID         S             10I 0
      /free
          // PdfWriter_getInstance(svDocument: svOutFile);
         if (JNIEnv_P = *NULL);
           JNIEnv_P = getJNIEnv();
         else;
         endif;
         // Create Conversion Descriptor for CCSID conversions
         toCCSID = 1208;
         cd = Air_openConverter(toCCSID);
         ebcdicString = 'com/lowagie/text/pdf/PdfWriter';
         asciiWriter = Air_convert(cd: %trim(ebcdicString));
         //----------------------------------------------------------------
         // First, Find the JDBC Driver Class
         //----------------------------------------------------------------
         writerClass = FindClass(JNIEnv_P:
                             %trim(asciiWriter));
         if (Air_isJVMError());
           freeLocalRef(writerClass);
           Air_closeConverter(cd);
           return *NULL;
         else;
         endif;
         //----------------------------------------------------------------
         // Second, Find the MethodID for the Constructor
         //----------------------------------------------------------------
         ebcdicString = 'getInstance';
         asciiInstance = Air_convert(cd: %trim(ebcdicString));
         ebcdicString = '(Lcom/lowagie/text/Document;'
                      + 'Ljava/io/OutputStream;)'
                      + 'Lcom/lowagie/text/pdf/PdfWriter;';
         asciiInstanceSignature = Air_convert(cd: %trim(ebcdicString));
         InstanceID = GetStaticMethodID(JNIEnv_P:writerClass:
                                %trim(asciiInstance):
                                %trim(asciiInstanceSignature));
         if (Air_isJVMError());
           freeLocalRef(writerClass);
           Air_closeConverter(cd);
           return *NULL;
         else;
         endif;
         //----------------------------------------------------------------
         // Third, Call the getInstance method
         //----------------------------------------------------------------
         svWriter = CallWriterGetInstanceMethod(JNIEnv_P:
                                 writerClass:
                                 InstanceID:argDocument:
                                 argOutFile);
         if (Air_isJVMError());
           freeLocalRef(writerClass);
           Air_closeConverter(cd);
           return *NULL;
         else;
         endif;
         //----------------------------------------------------------------
         // Clean up
         freeLocalRef(writerClass);
         Air_closeConverter(cd);
         return svWriter;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_newChunk...
     P                 B                   EXPORT
     D AirPdf_newChunk...
     D                 PI                  like(ITextChunk)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
     D  svString       S                   like(jString)
     D  svChunk        S                   like(ITextChunk)
     D                                     inz(*NULL)
      /free
       svString = new_String(argBytes);
       svChunk = new_ITextChunk(svString);
       // Clean Up
       freeLocalRef(svString);
       return svChunk;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_newPhrase...
     P                 B                   EXPORT
     D AirPdf_newPhrase...
     D                 PI                  like(ITextPhrase)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
     D  svString       S                   like(jString)
     D  svPhrase       S                   like(ITextPhrase)
     D                                     inz(*NULL)
      /free
       svString = new_String(argBytes);
       svPhrase = new_ITextPhrase(svString);
       // Clean Up
       freeLocalRef(svString);
       return svPhrase;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_newParagraph...
     P                 B                   EXPORT
     D AirPdf_newParagraph...
     D                 PI                  like(ITextParagraph)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
     D  argFont                            like(ITextFont)
     D                                     options(*nopass)
     D  svString       S                   like(jString)
     D  svParagraph    S                   like(ITextParagraph)
     D                                     inz(*NULL)
      /free
       svString = new_String(argBytes);
       if (%parms > 1);
         svParagraph = new_ITextParagraphFromFont(svString: argFont);
       else;
         svParagraph = new_ITextParagraph(svString);
       endif;
       // Clean Up
       freeLocalRef(svString);
       return svParagraph;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_newAnchor...
     P                 B                   EXPORT
     D AirPdf_newAnchor...
     D                 PI                  like(ITextAnchor)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
     D  argFont                            like(ITextFont)
     D                                     options(*nopass)
     D  svString       S                   like(jString)
     D  svAnchor       S                   like(ITextAnchor)
     D                                     inz(*NULL)
      /free
       svString = new_String(argBytes);
       if (%parms > 1);
         svAnchor = new_ITextAnchorFromFont(svString: argFont);
       else;
         svAnchor = new_ITextAnchor(svString);
       endif;
       // Clean Up
       freeLocalRef(svString);
       return svAnchor;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_setAnchorReference...
     P                 B                   EXPORT
     D AirPdf_setAnchorReference...
     D                 PI
     D  argAnchor                          like(ITextAnchor)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
     D  svString       S                   like(jString)
      /free
       svString = new_String(argBytes);
       ITextAnchor_setReference(argAnchor: svString);
       // Clean Up
       freeLocalRef(svString);
       return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_setAnchorName...
     P                 B                   EXPORT
     D AirPdf_setAnchorName...
     D                 PI
     D  argAnchor                          like(ITextAnchor)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
     D  svString       S                   like(jString)
      /free
       svString = new_String(argBytes);
       ITextAnchor_setName(argAnchor: svString);
       // Clean Up
       freeLocalRef(svString);
       return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_addTitle...
     P                 B                   EXPORT
     D AirPdf_addTitle...
     D                 PI
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
     D  svString       S                   like(jString)
      /free
        svString = new_String(%trim(argBytes));
        ITextDocument_addTitle(argDocument: svString);
        // Clean Up
        freeLocalRef(svString);
        return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_addSubject...
     P                 B                   EXPORT
     D AirPdf_addSubject...
     D                 PI
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
     D  svString       S                   like(jString)
      /free
        svString = new_String(%trim(argBytes));
        ITextDocument_addSubject(argDocument: svString);
        // Clean Up
        freeLocalRef(svString);
        return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_addKeywords...
     P                 B                   EXPORT
     D AirPdf_addKeywords...
     D                 PI
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
     D  svString       S                   like(jString)
      /free
        svString = new_String(%trim(argBytes));
        ITextDocument_addKeywords(argDocument: svString);
        // Clean Up
        freeLocalRef(svString);
        return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_addCreator...
     P                 B                   EXPORT
     D AirPdf_addCreator...
     D                 PI
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
     D  svString       S                   like(jString)
      /free
        svString = new_String(%trim(argBytes));
        ITextDocument_addCreator(argDocument: svString);
        // Clean Up
        freeLocalRef(svString);
        return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_addAuthor...
     P                 B                   EXPORT
     D AirPdf_addAuthor...
     D                 PI
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
     D  svString       S                   like(jString)
      /free
        svString = new_String(%trim(argBytes));
        ITextDocument_addAuthor(argDocument: svString);
        // Clean Up
        freeLocalRef(svString);
        return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_getPageSizeRectangle...
     P                 B                   EXPORT
     D AirPdf_getPageSizeRectangle...
     D                 PI                  like(Rectangle)
     D  argSizeName                  64A   const varying options(*varsize)
     D  svString       S                   like(jString)
     D  svRectangle    S                   like(Rectangle)
     D                                     inz(*NULL)
      /free
        svString = new_String(%trim(argSizeName));
        monitor;
          svRectangle = PageSize_getRectangle(svString);
        on-error;
          svRectangle = *NULL;
        endmon;
        // Clean Up
        freeLocalRef(svString);
        return svRectangle;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_getImage...
     P                 B                   EXPORT
     D AirPdf_getImage...
     D                 PI                  like(ITextImage)
     D  argInFile                  2048A   const varying options(*varsize)
     D  svString       S                   like(jString)
     D  svImage        S                   like(ITextImage)
     D                                     inz(*NULL)
      /free
        // Create/Attach to JVM
        svString = new_String(%trim(argInFile));
        monitor;
          svImage = ITextImage_getInstance(svString);
        on-error;
          svImage = *NULL;
        endmon;
        // Clean Up
        freeLocalRef(svString);
        return svImage;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_setImageBorderColor...
     P                 B                   EXPORT
     D AirPdf_setImageBorderColor...
     D                 PI
     D  argImage                           like(ITextImage)
     D  argColor                      6A   const
     D  svColor        S                   like(JavaColor)
      /free
        svColor = Air_getColorFromHex(argColor);
        monitor;
          ITextImage_setBorderColor(argImage: svColor);
        on-error;
        endmon;
        // Clean Up
        freeLocalRef(svColor);
        return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_setBarcodeEANCode...
     P                 B                   EXPORT
     D AirPdf_setBarcodeEANCode...
     D                 PI
     D  argBarCode                         like(ITextBarcodeEAN)
     D  argBytes                    512A   const varying options(*varsize)
     D  argGuardBars                  1N   value options(*nopass)
     D  svString       S                   like(jString)
      /free
        svString = new_String(argBytes);
        monitor;
          ITextBarcodeEAN_setCode(argBarcode: svString);
          if %parms > 2;
            ITextBarcodeEAN_setGuardBars(argBarcode: argGuardBars);
          else;
          endif;
        on-error;
        endmon;
        // Clean Up
        freeLocalRef(svString);
        return;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_getBarcodeImage...
     P                 B                   EXPORT
     D AirPdf_getBarcodeImage...
     D                 PI                  like(ITextImage)
     D  argBarCode                         like(ITextBarcode)
     D  argContByte                        like(PdfContentByte)
     D  argBarColor                   6A   const options(*nopass)
     D  argTextColor                  6A   const options(*nopass)
     D  svBarColor     S                   like(JavaColor)
     D                                     inz(*NULL)
     D  svTextColor    S                   like(JavaColor)
     D                                     inz(*NULL)
     D  svImage        S                   like(ITextImage)
     D                                     inz(*NULL)
      /free
        if %parms > 2;
          svBarColor = Air_getColorFromHex(argBarColor);
          if %parms > 3;
            svTextColor = Air_getColorFromHex(argTextColor);
          else;
          endif;
        else;
        endif;
        // monitor;
          svImage =
          ITextBarcode_createImageWithBarCode(argBarCode:
                                              argContByte:
                                              svBarColor:
                                              svTextColor);
        // on-error;
        // endmon;
        // Clean Up
        freeLocalRef(svBarColor);
        freeLocalRef(svTextColor);
        return svImage;
      /end-free
     P                 E
      *------------------------------------------------------------------
     P AirPdf_addTableStringCell...
     P                 B                   EXPORT
     D AirPdf_addTableStringCell...
     D                 PI
     D  argTable                           like(PdfPTable)
     D  argBytes                  65535A   const varying options(*varsize)
     D  svString       S                   like(jString)
      /free
        svString = new_String(%trim(argBytes));
        PdfPTable_addStringCell(argTable: svString);
        // Clean Up
        freeLocalRef(svString);
        return;
      /end-free
     P                 E
