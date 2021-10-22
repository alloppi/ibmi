      /if not defined(SPMSCPDF)
     D**********************************************************************
     D* iText PDF Prototypes and Constants
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
     D*  iText Data Types
     D**********************************************************************
     D* iText is used to create PDFs.  Created by Bruno Lowagie
     D* Official iText Website:
     D*   http://itextpdf.com
     D* JavaDocs hosted at 2WolvesOut.com
     D*   http://www.2wolvesout.com/javadocs/itext/itext_2_1_2u/index.html
     D**********************************************************************
     D PdfReader       S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader')
     D PdfWriter       S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfWriter')
     D PdfCopy         S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfCopy')
     D PdfImportedPage...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfImportedPage')
     D PdfContentByte...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfContentByte')
     D PdfPCell...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPCell')
     D PdfPTable...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPTable')
     D ITextDocument...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Document')
     D ITextRectangle...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Rectangle')
     D ITextChunk...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Chunk')
     D ITextPhrase...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Phrase')
     D ITextParagraph...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Paragraph')
     D ITextAnchor...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Anchor')
     D ITextElement...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Element')
     D ITextList...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .List')
     D ITextFont...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Font')
     D ITextImage...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Image')
     D ITextBarcode...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .Barcode')
     D ITextBarcodeEAN...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .BarcodeEAN')
     D ITextBarcodeEANSUPP...
     D                 S               O   CLASS(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .BarcodeEANSUPP')
      ******************************************************************
      *  Constructors
      **********************************************************************
     D new_PdfReader...
     D                 PR                  like(PdfReader)
     D                                     ExtProc(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :*CONSTRUCTOR)
     D  inFileName                         like(jString)
     D new_PdfPCell...
     D                 PR                  like(PdfPCell)
     D                                     ExtProc(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPCell'
     D                                     :*CONSTRUCTOR)
     D new_PdfPCellFromPhrase...
     D                 PR                  like(PdfPCell)
     D                                     ExtProc(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPCell'
     D                                     :*CONSTRUCTOR)
     D  inPhrase                           like(ITextPhrase)
     D new_PdfPTable...
     D                 PR                  like(PdfPTable)
     D                                     ExtProc(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPTable'
     D                                     :*CONSTRUCTOR)
     D  inColumns                          like(jInt) value
     D new_ITextDocument...
     D                 PR                  like(ITextDocument)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Document':
     D                                     *CONSTRUCTOR)
     D new_ITextDocumentFromRectangle...
     D                 PR                  like(ITextDocument)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Document':
     D                                     *CONSTRUCTOR)
     D  inRectangle                        like(ITextRectangle)
     D new_ITextChunk...
     D                 PR                  like(ITextChunk)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Chunk':
     D                                     *CONSTRUCTOR)
     D  inString                           like(jString)
     D new_ITextPhrase...
     D                 PR                  like(ITextPhrase)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Phrase':
     D                                     *CONSTRUCTOR)
     D  inString                           like(jString)
     D new_ITextParagraph...
     D                 PR                  like(ITextParagraph)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Paragraph':
     D                                     *CONSTRUCTOR)
     D  inString                           like(jString)
     D*
     D new_ITextParagraphFromFont...
     D                 PR                  like(ITextParagraph)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Paragraph':
     D                                     *CONSTRUCTOR)
     D  inString                           like(jString)
     D  inFont                             like(ITextFont)
     D*
     D new_ITextList...
     D                 PR                  like(ITextList)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .List':
     D                                     *CONSTRUCTOR)
     D  inNumbered                    1N   value
     D*
     D new_ITextFont...
     D                 PR                  like(ITextFont)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Font':
     D                                     *CONSTRUCTOR)
     D  inFamily                           like(jInt) value
     D  inSize                             like(jFloat) value
     D  inStyle                            like(jInt) value
     D*
     D new_ITextAnchor...
     D                 PR                  like(ITextAnchor)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Anchor':
     D                                     *CONSTRUCTOR)
     D  inString                           like(jString)
     D*
     D new_ITextAnchorFromFont...
     D                 PR                  like(ITextAnchor)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text-
     D                                     .Anchor':
     D                                     *CONSTRUCTOR)
     D  inString                           like(jString)
     D  inFont                             like(ITextFont)
     D*
     D new_ITextBarcodeEAN...
     D                 PR                  like(ITextBarcodeEAN)
     D                                     ExtProc(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .BarcodeEAN'
     D                                     :*CONSTRUCTOR)
     D*
     D new_ITextBarcodeEANSUPP...
     D                 PR                  like(ITextBarcodeEANSUPP)
     D                                     ExtProc(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .BarcodeEANSUPP'
     D                                     :*CONSTRUCTOR)
     D  argEAN                             like(ITextBarCode)
     D  argSUPP                            like(ITextBarCode)
     D*
     D new_PdfCopy...
     D                 PR                  like(PdfCopy)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text.pdf-
     D                                     .PdfCopy':
     D                                     *CONSTRUCTOR)
     D  inDocument                         like(ITextDocument)
     D  inFileOut                          like(OutputStream)
      **********************************************************************
     D new_PdfImportedPage...
     D                 PR                  like(PdfImportedPage)
     D                                     ExtProc(*JAVA:
     D                                     'com.lowagie.text.pdf-
     D                                     .PdfImportedPage':
     D                                     *CONSTRUCTOR)
     D  inReader                           like(PdfReader)
     D  inPageNbr                          like(jint) value
      **********************************************************************
      *  Method Prototypes
      **********************************************************************
     D ITextDocument_open...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'open')
     D ITextDocument_add...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'add')
     D  inElement                          like(ITextElement)
     D ITextDocument_close...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'close')
     D ITextDocument_newPage...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'newPage')
     D ITextDocument_addTitle...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'addTitle')
     D  inString                           like(jString)
     D ITextDocument_addSubject...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'addSubject')
     D  inString                           like(jString)
     D ITextDocument_addKeywords...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'addKeywords')
     D  inString                           like(jString)
     D ITextDocument_addCreator...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'addCreator')
     D  inString                           like(jString)
     D ITextDocument_addAuthor...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'addAuthor')
     D  inString                           like(jString)
     D ITextDocument_addCreationDate...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Document'
     D                                     :'addCreationDate')
     D ITextParagraph_add...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Paragraph'
     D                                     :'add')
     D  inObject                           like(jObject)
     D*
     D ITextList_add...
     D                 PR             1N
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.List'
     D                                     :'add')
     D  inObject                           like(jObject)
     D*
     D ITextAnchor_setReference...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Anchor'
     D                                     :'setReference')
     D  inString                           like(jString)
     D*
     D ITextAnchor_setName...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Anchor'
     D                                     :'setName')
     D  inString                           like(jString)
     D*
     D ITextFont_setColor...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Font'
     D                                     :'setColor')
     D  inColor                            like(JavaColor)
     D*
     D ITextBarCodeEAN_setCode...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .BarcodeEAN'
     D                                     :'setCode')
     D  inCode                             like(jString)
     D*
     D ITextBarCodeEAN_setCodeType...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .BarcodeEAN'
     D                                     :'setCodeType')
     D  inCodeType                         like(jInt) value
     D*
     D ITextBarCodeEAN_setBaseline...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .BarcodeEAN'
     D                                     :'setBaseline')
     D  inCodeType                         like(jFloat) value
     D*
     D ITextBarCodeEAN_setGuardBars...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .BarcodeEAN'
     D                                     :'setGuardBars')
     D  inGuardBars                   1N   value
     D*
     D ITextBarCode_createImageWithBarCode...
     D                 PR                  like(ITextImage)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .Barcode'
     D                                     :'createImageWithBarcode')
     D  inContByte                         like(PdfContentByte)
     D  inBarColor                         like(JavaColor)
     D  inTextColor                        like(JavaColor)
     D*
     D PdfCopy_open...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf.PdfCopy'
     D                                     :'open')
     D PdfCopy_close...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf.PdfCopy'
     D                                     :'close')
     D PdfCopy_addPage...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf.PdfCopy'
     D                                     :'addPage')
     D  inPage                             like(PdfImportedPage)
     D PdfReader_close...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :'close')
     D PdfReader_getPdfVersion...
     D                 PR                  like(jChar)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :'getPdfVersion')
     D PdfReader_getNumberOfPages...
     D                 PR                  like(jint)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :'getNumberOfPages')
     D PdfReader_getPageSizeWithRotation...
     D                 PR                  like(ITextRectangle)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :'getPageSizeWithRotation')
     D  argPageNbr                         like(jint) value
     D PdfReader_getPageSize...
     D                 PR                  like(ITextRectangle)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :'getPageSize')
     D  argPageNbr                         like(jint) value
     D PdfReader_getPageRotation...
     D                 PR                  like(jInt)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :'getPageRotation')
     D  argPageNbr                         like(jint) value
     D PdfReader_getFileLength...
     D                 PR                  like(jInt)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :'getFileLength')
     D PdfReader_getInfo...
     D                 PR                  like(HashMap)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfReader'
     D                                     :'getInfo')
     D PdfWriter_getDirectContent...
     D                 PR                  like(PdfContentByte)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfWriter'
     D                                     :'getDirectContent')
     D ITextRectangle_getWidth...
     D                 PR                  like(jfloat)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Rectangle'
     D                                     :'getWidth')
     D ITextRectangle_getHeight...
     D                 PR                  like(jfloat)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Rectangle'
     D                                     :'getHeight')
     D ITextRectangle_rotate...
     D                 PR                  like(ITextRectangle)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Rectangle'
     D                                     :'rotate')
     D ITextRectangle_toString...
     D                 PR                  like(jString)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .Rectangle'
     D                                     :'toString')
     D PdfCopy_getImportedPage...
     D                 PR                  like(PdfImportedPage)
     D                                     EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfCopy'
     D                                     :'getImportedPage')
     D  inReader                           like(PdfReader)
     D  inPageNbr                          like(jint) value
     D*
     D PdfPCell_setColSpan...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPCell'
     D                                     :'setColspan')
     D  argColSpan                         like(jint) value
     D*
     D PdfPTable_addCell...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPTable'
     D                                     :'addCell')
     D  argCell                            like(PdfPCell)
     D*
     D PdfPTable_addStringCell...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPTable'
     D                                     :'addCell')
     D  argString                          like(jString)
     D*
     D PdfPTable_addPhraseCell...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPTable'
     D                                     :'addCell')
     D  argPhrase                          like(ITextPhrase)
     D*
     D PdfPTable_addImageCell...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPTable'
     D                                     :'addCell')
     D  argImage                           like(ITextImage)
     D*
     D PdfPTable_addTableCell...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.pdf-
     D                                     .PdfPTable'
     D                                     :'addCell')
     D  argTable                           like(PdfPTable)
     D*
     D PageSize_getRectangle...
     D                 PR                  like(ITextRectangle)
     D                                     ExtProc(*JAVA
     D                                     :'com.lowagie.text-
     D                                     .PageSize'
     D                                     :'getRectangle')
     D                                     static
     D   argSizeName                       like(jString)
     D*
     D ITextImage_getInstance...
     D                 PR                  like(ITextImage)
     D                                     extProc(*JAVA
     D                                     :'com.lowagie.text.Image'
     D                                     :'getInstance')
     D                                     static
     D  argImageName                       like(jString)
      **********************************************************************
     D ITextImage_setAlignment...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Image'
     D                                     :'setAlignment')
     D  argAlign                           like(jInt) value
      **********************************************************************
     D ITextImage_setBorder...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Image'
     D                                     :'setBorder')
     D  argValue                           like(jInt) value
      **********************************************************************
     D ITextImage_setBorderColor...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Image'
     D                                     :'setBorderColor')
     D  argColor                           like(JavaColor)
      **********************************************************************
     D ITextImage_setBorderWidth...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Image'
     D                                     :'setBorderWidth')
     D  argWidth                           like(jFloat) value
      **********************************************************************
     D ITextImage_scalePercent...
     D                 PR                  EXTPROC(*JAVA
     D                                     :'com.lowagie.text.Image'
     D                                     :'scalePercent')
     D  argWidth                           like(jFloat) value
     D**********************************************************************
     D* CONSTANTS
     D* MOST OF THESE CAN BE FOUND IN THE iText JAVADOCS
     D* http://www.2wolvesout.com/javadocs/itext/itext_2_1_2u/index.html
     D**********************************************************************
     D* com.lowagie.text.Font Constant Field Values
     D**********************************************************************
     D ITEXT_FONT_BOLD...
     D                 C                   1
     D ITEXT_FONT_BOLD_ITALIC...
     D                 C                   3
     D ITEXT_FONT_COURIER...
     D                 C                   0
     D ITEXT_FONT_DEFAULT_SIZE...
     D                 C                   12
     D ITEXT_FONT_HELVETICA...
     D                 C                   1
     D ITEXT_FONT_ITALIC...
     D                 C                   2
     D ITEXT_FONT_NORMAL...
     D                 C                   0
     D ITEXT_FONT_STRIKE_THRU...
     D                 C                   8
     D ITEXT_FONT_SYMBOL...
     D                 C                   3
     D ITEXT_FONT_TIMES_ROMAN...
     D                 C                   2
     D ITEXT_FONT_UNDEFINED...
     D                 C                   -1
     D ITEXT_FONT_UNDERLINE...
     D                 C                   4
     D ITEXT_FONT_ZAPFDINGBATS...
     D                 C                   4
     D**********************************************************************
     D* com.lowagie.text.List Constant Field Values
     D**********************************************************************
     D ITEXT_LIST_ALPHABETICAL...
     D                 C                   CONST(*ON)
     D ITEXT_LIST_LOWERCASE...
     D                 C                   CONST(*ON)
     D ITEXT_LIST_NUMERICAL...
     D                 C                   CONST(*OFF)
     D ITEXT_LIST_ORDERED...
     D                 C                   CONST(*ON)
     D ITEXT_LIST_UNORDERED...
     D                 C                   CONST(*OFF)
     D ITEXT_LIST_UPPERCASE...
     D                 C                   CONST(*OFF)
     D**********************************************************************
     D* com.lowagie.text.Chunk Constant Field Values
     D**********************************************************************
     D ITEXT_CHUNK_ACTION...
     D                 C                   'ACTION'
     D ITEXT_CHUNK_BACKGROUND...
     D                 C                   'BACKGROUND'
     D ITEXT_CHUNK_COLOR...
     D                 C                   'COLOR'
     D ITEXT_CHUNK_ENCODING...
     D                 C                   'ENCODING'
     D ITEXT_CHUNK_GENERICTAG...
     D                 C                   'GENERICTAG'
     D ITEXT_CHUNK_HSCALE...
     D                 C                   'HSCALE'
     D ITEXT_CHUNK_HYPHENATION...
     D                 C                   'HYPHENATION'
     D ITEXT_CHUNK_IMAGE...
     D                 C                   'IMAGE'
     D ITEXT_CHUNK_LOCALDESTINATION...
     D                 C                   'LOCALDESTINATION'
     D ITEXT_CHUNK_LOCALGOTO...
     D                 C                   'LOCALGOTO'
     D ITEXT_CHUNK_NEWPAGE...
     D                 C                   'NEWPAGE'
     D ITEXT_CHUNK_OBJECTREPLACEMENTCHARACTER...
     D                 C                   '\ufffc'
     D ITEXT_CHUNK_PDFANNOTATION...
     D                 C                   'PDFANNOTATION'
     D ITEXT_CHUNK_REMOTEGOTO...
     D                 C                   'REMOTEGOTO'
     D ITEXT_CHUNK_SEPARATOR...
     D                 C                   'SEPARATOR'
     D ITEXT_CHUNK_SKEW...
     D                 C                   'SKEW'
     D ITEXT_CHUNK_SPLITCHARACTER...
     D                 C                   'SPLITCHARACTER'
     D ITEXT_CHUNK_SUBSUPSCRIPT...
     D                 C                   'SUBSUPSCRIPT'
     D ITEXT_CHUNK_TAB...
     D                 C                   'TAB'
     D ITEXT_CHUNK_TEXTRENDERMODE...
     D                 C                   'TEXTRENDERMODE'
     D ITEXT_CHUNK_UNDERLINE...
     D                 C                   'UNDERLINE'
     D**********************************************************************
     D* com.lowagie.text.Image Constant Field Values (Partial)
     D**********************************************************************
     D ITEXT_IMAGE_ALIGN_BASELINE...
     D                 C                   7
     D ITEXT_IMAGE_ALIGN_BOTTOM...
     D                 C                   6
     D ITEXT_IMAGE_ALIGN_CENTER...
     D                 C                   1
     D ITEXT_IMAGE_ALIGN_JUSTIFIED...
     D                 C                   3
     D ITEXT_IMAGE_ALIGN_JUSTIFIED_ALL...
     D                 C                   8
     D ITEXT_IMAGE_ALIGN_LEFT...
     D                 C                   0
     D ITEXT_IMAGE_ALIGN_MIDDLE...
     D                 C                   5
     D ITEXT_IMAGE_ALIGN_RIGHT...
     D                 C                   2
     D ITEXT_IMAGE_ALIGN_TOP...
     D                 C                   4
     D ITEXT_IMAGE_ALIGN_UNDEFINED...
     D                 C                   -1
     D ITEXT_IMAGE_ANCHOR...
     D                 C                   17
     D ITEXT_IMAGE_ANNOTATION...
     D                 C                   29
     D ITEXT_IMAGE_AUTHOR...
     D                 C                   4
     D ITEXT_IMAGE_BOTTOM...
     D                 C                   2
     D ITEXT_IMAGE_BOX...
     D                 C                   15
     D ITEXT_IMAGE_JPEG...
     D                 C                   32
     D ITEXT_IMAGE_TOP...
     D                 C                   1
     D ITEXT_IMAGE_TEXTWRAP...
     D                 C                   4
     D**********************************************************************
     D* com.lowagie.text.pdf.Barcode Field Values (Partial)
     D**********************************************************************
     D ITEXT_BARCODE_CODABAR...
     D                 C                   12
     D ITEXT_BARCODE_CODE128...
     D                 C                   9
     D ITEXT_BARCODE_CODE128_RAW...
     D                 C                   11
     D ITEXT_BARCODE_CODE128_UCC...
     D                 C                   10
     D ITEXT_BARCODE_EAN13...
     D                 C                   1
     D ITEXT_BARCODE_EAN8...
     D                 C                   2
     D ITEXT_BARCODE_PLANET...
     D                 C                   8
     D ITEXT_BARCODE_POSTNET...
     D                 C                   7
     D ITEXT_BARCODE_SUPP2...
     D                 C                   5
     D ITEXT_BARCODE_SUPP5...
     D                 C                   6
     D ITEXT_BARCODE_UPCA...
     D                 C                   3
     D ITEXT_BARCODE_UPCE...
     D                 C                   4
      **********************************************************************
      *  >>>>>>>>>>>>>>>>>> Local Prototypes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      **********************************************************************
     D* USE JNI to call Transport.send
     D CallWriterGetInstanceMethod...
     D                 PR                  like(PdfWriter)
     D                                     ExtProc(*CWIDEN:
     D                                      JNINativeInterface.
     D                                      CallStaticObjectMethod_P)
     D  argEnv                             Like(JNIEnv_P) value
     D  argClass                           Like(jclass) value
     D  argMethodId                        Like(jmethodID) value
     D  argDocument                        Like(ITextDocument) value
     D  argOutFile                         Like(OutputStream) value
     D  argDummy                      1A   Options(*NoPass)
     D**********************************************************************
     D AirPdf_newDocumentOutput...
     D                 PR                  like(ITextDocument)
     D  argFileName                2048A   const varying
     D                                     options(*varsize)
     D  argSizeName                  64A   const varying
     D                                     options(*nopass: *varsize)
     D  argRotate                     1N   const options(*nopass)
      **********************************************************************
     D AirPdf_newReader...
     D                 PR                  like(PdfReader)
     D  argFileName                2048A   const varying
      **********************************************************************
     D AirPdf_newCopyFromDocument...
     D                 PR                  like(PdfCopy)
     D  argDocument                        like(ITextDocument)
     D  argFileName                2048A   const varying
     D                                     options(*varsize)
      **********************************************************************
     D AirPdf_newChunk...
     D                 PR                  like(ITextChunk)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
      **********************************************************************
     D AirPdf_newPhrase...
     D                 PR                  like(ITextPhrase)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
      **********************************************************************
     D AirPdf_newParagraph...
     D                 PR                  like(ITextParagraph)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
     D  argFont                            like(ITextFont)
     D                                     options(*nopass)
      **********************************************************************
     D AirPdf_newAnchor...
     D                 Pr                  like(ITextAnchor)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
     D  argFont                            like(ITextFont)
     D                                     options(*nopass)
      **********************************************************************
     D AirPdf_addTitle...
     D                 PR
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
      **********************************************************************
     D AirPdf_addSubject...
     D                 PR
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
      **********************************************************************
     D AirPdf_addKeywords...
     D                 PR
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
      **********************************************************************
     D AirPdf_addCreator...
     D                 PR
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
      **********************************************************************
     D AirPdf_addAuthor...
     D                 PR
     D  argDocument                        like(ITextDocument)
     D  argBytes                  65535A   const varying options(*varsize)
      **********************************************************************
     D AirPdf_getPageSizeRectangle...
     D                 PR                  like(Rectangle)
     D  argSizeName                  64A   const varying options(*varsize)
      **********************************************************************
     D AirPdf_setPdfWriter...
     D                 PR                  like(PdfWriter)
     D   argDocument                       like(ITextDocument)
     D   argOutFile                        like(FileOutputStream)
      **********************************************************************
     D AirPdf_setAnchorReference...
     D                 PR
     D  argAnchor                          like(ITextAnchor)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
      **********************************************************************
     D AirPdf_setAnchorName...
     D                 PR
     D  argAnchor                          like(ITextAnchor)
     D  argBytes                  65535A   const varying
     D                                     options(*varsize)
      **********************************************************************
     D AirPdf_getImage...
     D                 PR                  like(ITextImage)
     D  argInFile                  2048A   const varying options(*varsize)
      **********************************************************************
     D AirPdf_setImageBorderColor...
     D                 PR
     D  argImage                           like(ITextImage)
     D  argHexColor                   6A   const
      **********************************************************************
     D AirPdf_setBarcodeEANCode...
     D                 PR
     D  argBarcode                         like(ITextBarcodeEAN)
     D  argBytes                    512A   const varying options(*varsize)
     D  argGuardBars                  1N   value options(*nopass)
      **********************************************************************
     D AirPdf_getBarcodeImage...
     D                 PR                  like(ITextImage)
     D  argBarCode                         like(ITextBarcode)
     D  argContByte                        like(PdfContentByte)
     D  argBarColor                   6A   const options(*nopass)
     D  argTextColor                  6A   const options(*nopass)
      **********************************************************************
     D AirPdf_addTableStringCell...
     D                 PR
     D  argTable                           like(PdfPTable)
     D  argBytes                  65535A   const varying options(*varsize)
      **********************************************************************
     D AirPdf_splitPages...
     D                 PR            10I 0
     D  argFileName                2048A   const varying options(*varsize)
     D**********************************************************************
      /define SPMSCPDF
      /endif
