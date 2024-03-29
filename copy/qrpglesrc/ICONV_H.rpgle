     /**
      * This file is part of i5/OS Programmer's Toolkit.
      *
      * Copyright (C) 2010, 2011  Junlei Li.
      *
      * i5/OS Programmer's Toolkit is free software: you can redistribute it and/or modify
      * it under the terms of the GNU General Public License as published by
      * the Free Software Foundation, either version 3 of the License, or
      * (at your option) any later version.
      *
      * i5/OS Programmer's Toolkit is distributed in the hope that it will be useful,
      * but WITHOUT ANY WARRANTY; without even the implied warranty of
      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      * GNU General Public License for more details.
      *
      * You should have received a copy of the GNU General Public License
      * along with i5/OS Programmer's Toolkit.  If not, see <http://www.gnu.org/licenses/>.
      */

     /**
      * @file iconv.rpgleinc
      *
      * ILE RPG header for NLS Data Conversion APIs.
      *
      * @remark iconv APIs are exported from SRVPGM QSYS/QTQICONV which
      *         is included by BNDDIR QSYS/QUSAPIBD.
      */

      /if not defined(i5toolkit_rpg_iconv)
      /define i5toolkit_rpg_iconv

     /**
      * Conversion descriptor.
      */
     d iconv_t         ds                  qualified
      *
      * rtn is set to -1 if iconv_open() failed and errno is set to
      * corresponding error code.
      *
     d     rtn                       10i 0
     d     cd                        10i 0 dim(12)

     /**
      * toccsid parameter of iconv_open().
      */
     d iconv_toccsid_t...
     d                 ds                  qualified
      * should always be 'IBMCCSID'
     d     ibmccsid                   8a
      * character representation of CCSID number
     d     ccsid                      5a
      * reserved (binary 0)
     d                               19a

     /**
      * fromccsid parameter of iconv_open().
      */
     d iconv_fromccsid_t...
     d                 ds                  qualified
      * should always be 'IBMCCSID'
     d     ibmccsid                   8a
      * character representation of CCSID number
     d     ccsid                      5a
      * conversion alternative
      * @todo comments
     d     conv_alt                   3a
      * substitution alternative
     d     subst_alt                  1a
      * shift-state alternative
     d     shift_alt                  1a
      * input length option
     d     input_len_opt...
     d                                1a
      * error option for mixed data
     d     err_opt                    1a
      * reserved (binary 0)
     d                               12a

     /**
      * iconv_open()
      *
      * @todo comments
      */
     d iconv_open      pr                  extproc('iconv_open')
     d                                     likeds(iconv_t)
     d     toccsid                         likeds(iconv_toccsid_t)
     d     fromccsid                       likeds(iconv_fromccsid_t)

     /**
      * qtqcode_t is used by QtqIconvOpen().
      */
     d qtqcode_t       ds                  qualified
      * CCSID number
     d     ccsid                     10i 0
      * conversion alternative
     d     conv_alt                  10i 0
      * substitution alternative
     d     subst_alt                 10i 0
      * shift-state alternative
     d     shift_alt                 10i 0
      * input length option
     d     input_len_opt...
     d                               10i 0
      * error option for mixed data
     d     err_opt                   10i 0
      * reserved (binary 0)
     d                                8a

     /**
      * QtqIconvOpen()--Code Conversion Allocation API
      *
      * @todo comments
      * @todo difference between QtqIconvOpen() and iconv_open()
      */
     d QtqIconvOpen    pr                  extproc('QtqIconvOpen')
     d                                     likeds(iconv_t)
     d     toccsid                         likeds(qtqcode_t)
     d     fromccsid                       likeds(qtqcode_t)

     /**
      * iconv_close()--Code Conversion Deallocation API
      */
     d iconv_close     pr            10i 0 extproc('iconv_close')
     d     cd                              likeds(iconv_t)
     d                                     value

     /**
      * iconv()--Code Conversion API
      */
     d iconv           pr            10u 0 extproc('iconv')
     d     cd                              likeds(iconv_t)
     d                                     value
     d     inbuf_ptr                   *
     d     inbytesleft...
     d                               10u 0
     d     outbuf_ptr                  *
     d     outbytesleft...
     d                               10u 0

      * !defined(i5toolkit_rpg_iconv)
      /endif
