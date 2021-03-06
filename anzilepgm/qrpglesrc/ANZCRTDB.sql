CREATE OR REPLACE TABLE QTEMP/ANZILEMOD (PGMNAME   CHAR(10),
                                         LIBNAME   CHAR(10),
                                         MODNAME   CHAR(10),
                                         MODLIB    CHAR(10),
                                         MODSRC    CHAR(10),
                                         MODSRCLIB CHAR(10),
                                         MODSRCMBR CHAR(10),
                                         MODATR    CHAR(10),
                                         MODCRT    CHAR(13),
                                         MODSRCUPD CHAR(13));

LABEL ON QTEMP/ANZILEMOD (PGMNAME   IS 'Prog Name',
                          LIBNAME   IS 'Libr Name',
                          MODNAME   IS 'Module Name',
                          MODLIB    IS 'Module Libr',
                          MODSRC    IS 'Mod Src File',
                          MODSRCLIB IS 'Mod Src Libr',
                          MODSRCMBR IS 'Mod Src Mbr',
                          MODATR    IS 'Mod Attrib',
                          MODCRT    IS 'Mod Created',
                          MODSRCUPD IS 'Src Changed');

CREATE OR REPLACE TABLE QTEMP/ANZILESVC (PGMNAME CHAR(10),
                                         LIBNAME CHAR(10),
                                         SVCNAME CHAR(10),
                                         SVCLIB  CHAR(10),
                                         SVCSIG  CHAR(16));

LABEL ON QTEMP/ANZILESVC (PGMNAME IS 'Program Name',
                          LIBNAME IS 'Library Name',
                          SVCNAME IS 'Srv Pgm Name',
                          SVCLIB  IS 'Srv Pgm Libr',
                          SVCSIG  IS 'Srv Pgm Signature');
