     /*-                                                                            +
      * Copyright (c) 2001 Scott C. Klement                                         +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +
      **----------------------------------------------------------------
      **  Retrieve Job Information API:
      **
      **    Parms:
      **       RcvVar = receiver variable
      **    RcvVarLen = length of actual receiver variable passed
      **       Format = Format to return receiver data in
      **      JobName = name of job to retrieve info for.  Consists
      **         of 10-char jobname, 10-char userid & 6-char number
      **         or the special value '*' for "current job"
      **         or the special value '*INT' to use an internal job id
      **     IntJobID = Internal job ID, you can use this instead of
      **        the job name, if you already know the Job ID.
      **    ErrorCode = Standard API error code
      **
      **----------------------------------------------------------------
     D RtvJobInf       PR                  ExtPgm('QUSRJOBI')
     D   RcvVar                   32766A   options(*varsize)
     D   RcvVarLen                   10I 0 CONST
     D   Format                       8A   CONST
     D   JobName                     26A   CONST
     D   IntJobID                    16A   CONST
     D   ErrorCode                32766A   options(*varsize)


      **----------------------------------------------------------------
      **  Send to Data Queue API (QSNDDTAQ)
      **
      **   parms:
      **      dtaqname -- name of data queue object
      **      dtaqlib  -- library containing data queue object
      **      dtaqlen  -- length of 'data' parameter
      **      data     -- data to place on data queue
      **
      **   optional parms 1:
      **      keylen   -- length of key data
      **      keydata  -- keys for this data queue entry
      **
      **   optional parms 2:
      **      asyncrec -- async request
      **
      **----------------------------------------------------------------
     D SndDtaQ         PR                  ExtPgm('QSNDDTAQ')
     D  dtaqname                     10A   const
     D  dtaqlib                      10A   const
     D  dtaqlen                       5P 0 const
     D  data                      32766A   const options(*varsize)
     D  keylen                        3P 0 const options(*nopass)
     D  keydata                   32766A   const options(*varsize: *nopass)
     D  asyncreq                     10A   const options(*nopass)


      **----------------------------------------------------------------
      **  Receive Entry from Data Queue API (QRCVDTAQ)
      **
      **  parms:
      **     DtaqName -- name of data queue object
      **     DtaqLib  -- library containing data queue object
      **     DtaqLen  -- length of data queue entry
      **     Data     -- variable to hold retrieved data queue entry
      **     WaitTime -- Time to wait for data queue entry (-1 = forever)
      **
      **  optional parms 1:
      **     KeyOrder   -- order to retrieve keys (GT, LT, LE, GE, etc)
      **     KeyLen     -- length of key data
      **     KeyData    -- key data
      **     SenderLen  -- length of sender data
      **     SenderInfo -- sender data
      **
      **  optional parms 2:
      **     RmvMsg     -- Remove from data queue? (*YES/*NO)
      **     RcvVarSize -- Size of receiver variable
      **     ErrorCode  -- error code data structure
      **
      **----------------------------------------------------------------
     D RcvDtaQ         PR                  ExtPgm('QRCVDTAQ')
     D   DtaqName                    10A   const
     D   DtaqLib                     10A   const
     D   DtaqLen                      5P 0
     D   Data                     32766A   options(*varsize)
     D   WaitTime                     5P 0 const
     D   KeyOrder                     2A   const options(*nopass)
     D   KeyLen                       3P 0 const options(*nopass)
     D   KeyData                  32766A   options(*varsize: *nopass)
     D   SenderLen                    3P 0 const options(*nopass)
     D   SenderInfo               32766A   options(*varsize: *nopass)
     D   RmvMsg                      10A   const options(*nopass)
     D   RcvVarSize                   5P 0 const options(*nopass)
     D   ErrorCode                32766A   options(*varsize: *nopass)


      **----------------------------------------------------------------
      **  Get Profile Handle API
      **
      **   Parameters:
      **      UserID = userid to retrieve a profile handle for
      **    Password = password of the user-id above
      **      Handle = the profile handle that's returned.
      **   ErrorCode = API error code, used to return any errors.
      **
      **----------------------------------------------------------------
     D GetProfile      PR                  ExtPgm('QSYGETPH')
     D   UserID                      10A   const
     D   Password                    10A   const
     D   Handle                      12A
     D   ErrorCode                32766A   options(*varsize: *nopass)


      **----------------------------------------------------------------
      **  Set User Profile API:
      **
      **   Parms:
      **      Handle = User Profile handle (returned by QSYGETPH API)
      **   ErrorCode = standard API error code structure
      **
      **----------------------------------------------------------------
     D SetProfile      PR                  ExtPgm('QWTSETP')
     D   Handle                      12A   const
     D   ErrorCode                32766A   options(*varsize: *nopass)


      **----------------------------------------------------------------
      **  Data structure for the JOBI0100 receiver variable
      **----------------------------------------------------------------
     D dsJobI0100      DS
     D   JobI_ByteRtn                10I 0
     D   JobI_ByteAvl                10I 0
     D   JobI_JobName                10A
     D   JobI_UserID                 10A
     D   JobI_JobNbr                  6A
     D   JobI_IntJob                 16A
     D   JobI_Status                 10A
     D   JobI_Type                    1A
     D   JobI_SbType                  1A
     D   JobI_Reserv1                 2A
     D   JobI_RunPty                 10I 0
     D   JobI_TimeSlc                10I 0
     D   JobI_DftWait                10I 0
     D   JobI_Purge                  10A

      **----------------------------------------------------------------
      ** error code structure
      **----------------------------------------------------------------
      /if not defined(DSEC_DEFINED)
     D dsEC            DS
     D*                                    Bytes Provided (size of struct)
     D  dsECBytesP             1      4I 0 INZ(256)
     D*                                    Bytes Available (returned by API)
     D  dsECBytesA             5      8I 0 INZ(0)
     D*                                    Msg ID of Error Msg Returned
     D  dsECMsgID              9     15
     D*                                    Reserved
     D  dsECReserv            16     16
     D*                                    Msg Data of Error Msg Returned
     D  dsECMsgDta            17    256
      /define DSEC_DEFINED
      /endif

      **----------------------------------------------------------------
      ** Job info structure
      **----------------------------------------------------------------
     D dsJobInfo       DS
      **                                  data queue msg type
     D   MsgType               1     10A
      **                                  Job Name
     D   JobName              11     20A
      **                                  Job User-ID
     D   JobUser              21     30A
      **                                  Job Number
     D   JobNbr               31     36A
      **                                  Job Internal ID
     D   InternalID           65     80A
