      ** ERRNO_H --  Header file for working with C-Runtime and
      **     UNIX-Type API error handling routines.
      **                                               SCK 04/25/01
      **
      **  To use this:
      **       1)  put a /COPY ERRNO_H in the D-specs of your program.
      **       2)  put a "/define ERRNO_LOAD_PROCEDURE", followed by a
      **               2nd "/COPY ERRNO_H" somewhere that procedures
      **               are allowed to be defined :)
      **       3)  bind to the QC2LE binding directory.
      **
      **
      /if not defined(ERRNO_LOAD_PROCEDURE)

      *-------------------------------------------------------------------
      * error constant definitions
      *-------------------------------------------------------------------

      * these values come originally from file QCLE/H member ERRNO

      * domain error in math function
     D EDOM            C                   3001
      * range error in math function
     D ERANGE          C                   3002
      * truncation on I/O operation
     D ETRUNC          C                   3003
      * file has not been opened
     D ENOTOPEN        C                   3004
      * file not opened for read
     D ENOTREAD        C                   3005
      * file opened for record I/O
     D ERECIO          C                   3008
      * file not opened for write
     D ENOTWRITE       C                   3009
      * stdin cannot be opened
     D ESTDIN          C                   3010
      * stdout cannot be opened
     D ESTDOUT         C                   3011
      * stderr cannot be opened
     D ESTDERR         C                   3012
      * bad offset to seek to
     D EBADSEEK        C                   3013
      * invalid file name specified
     D EBADNAME        C                   3014
      * invalid file mode specified
     D EBADMODE        C                   3015
      * invalid position specifier
     D EBADPOS         C                   3017
      * no record at specified position
     D ENOPOS          C                   3018
      * no ftell if more than 1 member
     D ENUMMBRS        C                   3019
      * no ftell if too many records
     D ENUMRECS        C                   3020
      * invalid function pointer
     D EBADFUNC        C                   3022
      * record not found
     D ENOREC          C                   3026
      * message data invalid
     D EBADDATA        C                   3028
      * bad option on I/O function
     D EBADOPT         C                   3040
      * file not opened for update
     D ENOTUPD         C                   3041
      * file not opened for delete
     D ENOTDLT         C                   3042
      * padding occurred on write operation
     D EPAD            C                   3043
      * bad key length option
     D EBADKEYLN       C                   3044
      * illegal write after read
     D EPUTANDGET      C                   3080
      * illegal read after write
     D EGETANDPUT      C                   3081
      * I/O exception non-recoverable error
     D EIOERROR        C                   3101
      * I/O exception recoverable error
     D EIORECERR       C                   3102

      * The following were taken from QSYSINC/SYS ERRNO:

      *  Permission denied.
     D EACCES          C                   3401
      *  Not a directory.
     D ENOTDIR         C                   3403
      *  No space available.
     D ENOSPC          C                   3404
      *  Improper link.
     D EXDEV           C                   3405
      *  Operation would have caused the process
     D EWOULDBLOCK     C                   3406
      *  Operation would have caused the process
     D EAGAIN          C                   3406
      *  Interrupted function call.
     D EINTR           C                   3407
      *  The address used for an argument was no
     D EFAULT          C                   3408
      *  Operation timed out
     D ETIME           C                   3409
      *  No such device or address
     D ENXIO           C                   3415
      *  Socket closed
     D ECLOSED         C                   3417
      *  Address already in use.
     D EADDRINUSE      C                   3420
      *  Address not available.
     D EADDRNOTAVAIL   C                   3421
      *  The type of socket is not supported in
     D EAFNOSUPPORT    C                   3422
      *  Operation already in progress.
     D EALREADY        C                   3423
      *  Connection ended abnormally.
     D ECONNABORTED    C                   3424
      *  A remote host refused an attempted conn
     D ECONNREFUSED    C                   3425
      *  A connection with a remote socket was r
     D ECONNRESET      C                   3426
      *  Operation requires destination address.
     D EDESTADDRREQ    C                   3427
      *  A remote host is not available.
     D EHOSTDOWN       C                   3428
      *  A route to the remote host is not avail
     D EHOSTUNREACH    C                   3429
      *  Operation in progress.
     D EINPROGRESS     C                   3430
      *  A connection has already been establish
     D EISCONN         C                   3431
      *  Message size out of range.
     D EMSGSIZE        C                   3432
      *  The network is not currently available.
     D ENETDOWN        C                   3433
      *  A socket is connected to a host that is
     D ENETRESET       C                   3434
      *  Cannot reach the destination network.
     D ENETUNREACH     C                   3435
      *  There is not enough buffer space for th
     D ENOBUFS         C                   3436
      *  The protocol does not support the speci
     D ENOPROTOOPT     C                   3437
      *  Requested operation requires a connecti
     D ENOTCONN        C                   3438
      *  The specified descriptor does not refer
     D ENOTSOCK        C                   3439
      *  Operation not supported.
     D ENOTSUP         C                   3440
      *  Operation not supported.
     D EOPNOTSUPP      C                   3440
      *  The socket protocol family is not suppo
     D EPFNOSUPPORT    C                   3441
      *  No protocol of the specified type and d
     D EPROTONO...
     DSUPPORT          C                   3442
      *  The socket type or protocols are not co
     D EPROTOTYPE      C                   3443
      *  An error indication was sent by the pee
     D ERCVDERR        C                   3444
      *  Cannot send data after a shutdown.
     D ESHUTDOWN       C                   3445
      *  The specified socket type is not suppor
     D ESOCKTNO...
     D SUPPORT         C                   3446
      *  A remote host did not respond within th
     D ETIMEDOUT       C                   3447
      *  The protocol required to support the sp
     D EUNATCH         C                   3448
      *  Descriptor not valid.
     D EBADF           C                   3450
      *  Too many open files for this process.
     D EMFILE          C                   3452
      *  Too many open files in the system.
     D ENFILE          C                   3453
      *  Broken pipe.
     D EPIPE           C                   3455
      *  File exists.
     D EEXIST          C                   3457
      *  Resource deadlock avoided.
     D EDEADLK         C                   3459
      *  Storage allocation request failed.
     D ENOMEM          C                   3460
      *  The synchronization object no longer ex
     D EOWNERTERM      C                   3462
      * The synchronization object was destroyed
     D EDESTROYED      C                   3463
      *  Operation terminated.
     D ETERM           C                   3464
      *  Maximum link count for a file was excee
     D EMLINK          C                   3468
      *  Seek request not supported for object.
     D ESPIPE          C                   3469
      *  Function not implemented.
     D ENOSYS          C                   3470
      *  Specified target is a directory.
     D EISDIR          C                   3471
      *  Read-only file system.
     D EROFS           C                   3472
      *  Unknown system state.
     D EUNKNOWN        C                   3474
      *  Iterator is invalid.
     D EITERBAD        C                   3475
      *  A damaged object was encountered.
     D EDAMAGE         C                   3484
      *  A loop exists in the symbolic links.
     D ELOOP           C                   3485
      *  A path name is too long.
     D ENAMETOOLONG    C                   3486
      *  No locks available
     D ENOLCK          C                   3487
      *  Directory not empty.
     D ENOTEMPTY       C                   3488
      *  System resources not available to compl
     D ENOSYSRSC       C                   3489
      *  Conversion error.
     D ECONVERT        C                   3490
      *  Argument list too long.
     D E2BIG           C                   3491
      *  Conversion stopped due to input charact
     D EILSEQ          C                   3492
      * Object has soft damage.
     D ESOFTDAMAGE     C                   3497
      *  User not enrolled in system distributio
     D ENOTENROLL      C                   3498
      *  Object is suspended.
     D EOFFLINE        C                   3499
      * Object is a read only object.
     D EROOBJ          C                   3500
      * Area being read from or written to is lo
     D ELOCKED         C                   3506
      * Object too large.
     D EFBIG           C                   3507
      * The semaphore, shared memory, or message
     D EIDRM           C                   3509
      * The queue does not contain a message of
     D ENOMSG          C                   3510
      * File ID conversion of a directory failed
     D EFILECVT        C                   3511
      * A File ID could not be assigned when lin
     D EBADFID         C                   3512
      * A File ID could not be assigned when lin
     D ESTALE          C                   3513
      * No such process.
     D ESRCH           C                   3515
      * Process not enabled for signals.
     D ENOTSIGINIT     C                   3516
      * No child process.
     D ECHILD          C                   3517
      * The operation would have exceeded the ma
     D ETOOMANYREFS    C                   3523
      * Function not allowed.
     D ENOTSAFE        C                   3524
      * Object is too large to process.
     D EOVERFLOW       C                   3525
      * Journal damaged.
     D EJRNDAMAGE      C                   3526
      * Journal inactive.
     D EJRNINACTIVE    C                   3527
      * Journal space or system storage error.
     D EJRNRCVSPC      C                   3528
      * Journal is remote.
     D EJRNRMT         C                   3529
      * New journal receiver is needed.
     D ENEWJRNRCV      C                   3530
      * New journal is needed.
     D ENEWJRN         C                   3531
      * Object already journaled.
     D EJOURNALED      C                   3532
      * Entry too large to send.
     D EJRNENTTOOLONG  C                   3533
      * Object is a Datalink object.
     D EDATALINK       C                   3534

      * The following values are defined by POSIX ISO/IEC 9945-1:1990
      *  (these were also taken from QCLE/H member ERRNO)

      * invalid argument
     D EINVAL          C                   3021
      * input/output error
     D EIO             C                   3006
      * no such device
     D ENODEV          C                   3007
      * resource busy
     D EBUSY           C                   3029
      * no such file or library
     D ENOENT          C                   3025
      * operation not permitted
     D EPERM           C                   3027

      *-------------------------------------------------------------------
      * prototype definitions
      *-------------------------------------------------------------------
     D @__errno        PR              *   ExtProc('__errno')

     D strerror        PR              *   ExtProc('strerror')
     D    errnum                     10I 0 value

     D perror          PR                  ExtProc('perror')
     D    comment                      *   value options(*string)

     D errno           PR            10I 0

     D die             PR             1N
     D    msg                       256A   const

     D escerrno        PR             1N
     D    errnum                     10I 0 value
      /endif

      *-------------------------------------------------------------------
      * procedure definitions:
      *-------------------------------------------------------------------
      /if defined(ERRNO_LOAD_PROCEDURE)
      ** Retrieve the C-language "errno" (error number)
     P errno           B
     D errno           PI            10I 0
     D p_errno         S               *
     D wwreturn        S             10I 0 based(p_errno)
     C                   eval      p_errno = @__errno
     c                   return    wwreturn
     P                 E

      ** end program with a (user-defined) escape message
     P die             B
     D die             PI             1N
     D    msg                       256A   const

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                    1A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 inz(%size(dsEC))
     D  dsECBytesA             5      8I 0 inz(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D MsgLen          S             10I 0
     D TheKey          S              4A

     c     ' '           checkr    msg           MsgLen
     c                   if        MsgLen<1
     c                   return    *off
     c                   endif

     c                   callp     QMHSNDPM('CPF9897': 'QCPFMSG   *LIBL':
     c                               Msg: MsgLen: '*ESCAPE':
     c                               '*': 3: TheKey: dsEC)

     c                   return    *off
     P                 E


      ** End program with an escape message that corresponds to
      **  the value of "errno" above.
     P EscErrno        B
     D EscErrno        PI             1N
     D   errnum                      10i 0 value

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                      1A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                    1A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 inz(%size(dsEC))
     D  dsECBytesA             5      8I 0 inz(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D TheKey          S              4A
     D MsgID           S              7A

     c                   move      errnum        MsgID
     c                   movel     'CPE'         MsgID

     c                   callp     QMHSNDPM(MsgID: 'QCPFMSG   *LIBL':
     c                               ' ': 0: '*ESCAPE':
     c                               '*': 3: TheKey: dsEC)

     c                   return    *off
     P                 E
      /endif

      /define ERRNO_H
