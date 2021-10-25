      // Retrieve User Group using QSYRUSRI API
      /COPY QSYSINC/QRPGLESRC,QUSEC
      /COPY QSYSINC/QRPGLESRC,QSYRUSRI

     D GetUsrInf       PR                  ExtPgm('QSYRUSRI')
     D   RcvVar                            Likeds(QSYI0200)
     D   RcvVarLen                   10i 0 const
     D   Format                       8    const
     D   UserPrf                     10    const
     D   Error                             Likeds(QUSEC)

     D Msg             s             40

      /Free
          QUSBPRV = 0; // Bytes provided in QUSEC error code parameter
          callp GetUsrInf(QSYI0200:%Size(QSYI0200):'USRI0200':'*CURRENT'
                         :QUSEC);
          Msg = 'Group profile is ' + QSYGP01;
          Dsply Msg;

          *InLR = *On;
      /End-Free
