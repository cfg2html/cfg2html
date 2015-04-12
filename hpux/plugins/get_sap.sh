#!/usr/bin/ksh
# @(#) $Id: get_sap.sh,v 6.15 2015/04/12 18:00:10 ralph Exp $
# ---------------------------------------------------------------------------
#  First Version:    Roland Schoettler, HP Ratingen
#  Update: 23/08/99: Klaus Doemer, HP Ratingen
#          11/10/00: Klaus Doemer / SG-Specials
#                                 / Saprouter-Config
#                                 / HP Somersault
#          06/02/02: Klaus Doemer / Oracle 8.1.X/9.x
#          19/03/02: Klaus Doemer / SAP Logfilesize Change
#          11/04/15: GdH / Enhancements
# ---------------------------------------------------------------------------

get_database()
{
  database=""
  dbname=""
  if [ -d /oracle/$sid ]
  then
    database="oracle"
    dbname="Oracle"
  fi
  if [ -d /informix/$sid ]
  then
    database="informix"
    dbname="Informix"
  fi
  if [ -n "$database" ]
  then
    if [ -d /$database/$sid/sapcheck ]
    then
      filename=`ls -t /$database/$sid/sapcheck | grep -n .chk | grep "^1:" | awk ' BEGIN { FS=":"} {print $2} '`
      if [ -f "/$database/$sid/sapcheck/$filename" ]
      then
        echo "@@@@@@ START OF ${sid}_sapdba-check_($dbname)"
        echo ""
        ###cat /$database/$sid/sapcheck/$filename | grep -v "^\*\*\*"
	# too big files
        tail -20 /$database/$sid/sapcheck/$filename | grep -v "^\*\*\*"
        echo ""
        echo "###### END OF ${sid}_sapdba-check_($dbname)"
        echo ""
      fi
    fi
  fi
}

get_oracle_config()
{
  if [ -r /oracle/$sid/saptrace/background/alert_${sid}.log ]
  then
    echo "@@@@@@ START OF ${sid}_OracleVersion"
    echo
    cat /oracle/$sid/saptrace/background/alert_${sid}.log | \
    grep Version | tail -1
    echo
    echo "###### END OF ${sid}_OracleVersion"
    echo
  fi
  transdir=/usr/sap/trans
  for i in $transdir/listener.ora $transdir/tnsnames.ora $transdir/sqlnet.ora \
           /etc/listener.ora /etc/tnsnames.ora /etc/sqlnet.ora
  do
    if [ -r "$i" ]
    then
      echo "@@@@@@ START OF ${i}"
      echo
      cat $i
      echo
      echo "###### END OF ${i}"
      echo
    fi
  done

  for o in /oracle/$sid /oracle/$sid/81?_?? /oracle/$sid/11?_?? /oracle/$sid/12?_??
  do
    if [ -d $o ]
    then
      oradir=$o/dbs
      ora1dir=$o/network/admin
      ora2dir=$o/net80/admin
      for i in $ora1dir/listener.ora $ora1dir/tnsnames.ora $ora1dir/sqlnet.ora \
           $ora2dir/listener.ora $ora2dir/tnsnames.ora $ora2dir/sqlnet.ora \
           $oradir/init${sid}.ora $oradir/init${sid}.sap $oradir/init${sid}.dba
      do
        if [ -r "$i" ]
        then
          echo "@@@@@@ START OF ${i}"
          echo
          cat $i
          echo
          echo "###### END OF ${i}"
          echo
        fi
      done
    fi
  done
}

get_profiles()
{
  if [ -d /usr/sap/$sid/SYS/profile ]
  then
    hostname=`hostname`
    profile="`echo /usr/sap/$sid/SYS/profile/START_*_* | grep -v \*`"
    if [ -n "$profile" ]
    then
      for i in $profile
      do
        echo "@@@@@@ START OF $i"
        echo ""
        if [ -r "$i" ]
        then
          cat "$i"
        else
          echo "$i not readable"
        fi
        echo ""
        echo "###### END OF $i"
        echo ""
      done
    fi
    echo "@@@@@@ START OF /usr/sap/$sid/SYS/profile/DEFAULT.PFL"
    echo ""
    if [ -r /usr/sap/$sid/SYS/profile/DEFAULT.PFL ]
    then
      cat /usr/sap/$sid/SYS/profile/DEFAULT.PFL
    else
      echo "no DEFAULT.PFL configured"
    fi
    echo ""
    echo "###### END OF /usr/sap/$sid/SYS/profile/DEFAULT.PFL"
    echo ""
    profile="`echo /usr/sap/$sid/SYS/profile/${sid}_*_* | grep -v \*`"
    if [ -n "$profile" ]
    then
      for i in $profile
      do
        echo "@@@@@@ START OF $i"
        echo ""
        if [ -r "$i" ]
        then
          cat "$i"
        else
          echo "$i not readable"
        fi
        echo ""
        echo "###### END OF $i"
        echo ""
      done
    fi
  fi
}

get_tracefiles()
{
  directories="`echo /usr/sap/$sid/D*/work | grep -v \*`"
  if [ -n "$directories" ]
  then
    for d in $directories
    do
      instance=`echo $d | awk -F/ '{ print $5 }'`
      cd "$d"
      files=`echo dev_w* dev_disp dev_ms`
      if [ -n "$files" ]
      then
        for i in $files
        do
          echo "@@@@@@ START OF ${sid}_${instance}_${i} first 40/last 40 lines"
          echo ""
          if [ -r "$i" ]
          then
            if [ `wc -l $i | awk ' { print $1} ' ` -lt 80 ]
            then
              cat $i
            else
              head -40 "$i"
              echo "............."
              tail -40 "$i"
            fi
          else
            echo "$i not readable"
          fi
          echo ""
          echo "###### END OF ${sid}_${instance}_${i}"
          echo ""
        done
      fi
    done
  fi
}

get_dispwork_version()
{
  if [ -x /usr/sap/$sid/SYS/exe/run/disp+work ]
  then
    echo "@@@@@@ START OF ${sid}_what_disp+work"
    echo
    what /usr/sap/$sid/SYS/exe/run/disp+work
    echo
    echo "###### END OF ${sid}_what_disp+work"
    echo
  fi
}

get_transportconfig()
{
  if [ -r /usr/sap/trans/bin/TPPARAM ]
  then
    echo "@@@@@@ START OF TPPARAM"
    echo
    cat /usr/sap/trans/bin/TPPARAM
    echo
    echo "###### END OF TPPARAM"
    echo
  fi
}

get_saproutconfig()
{
  if [ -r /usr/sap/saprouter/saprouttab ]
  then
    echo "@@@@@@ START OF SAPROUTTAB"
    echo
    cat /usr/sap/saprouter/saprouttab
    echo
    echo "###### END OF SAPROUTTAB"
    echo
  fi
}

get_ss_config()
{
  ssdir=/var/opt/hpsom/$sid
  if [ -d ${ssdir} ]
  then
    for i in /home/${sid}adm/.SS_machines $ssdir/settings_custom \
     $ssdir/enq_config $ssdir/${sid}_*_hpsom_srv \
     $ssdir/SS_comp_file $ssdir/Status/*_status_* \
     $ssdir/Trace/ENQ* $ssdir/Trace/*hpsom*_trc_*
    do
      if [ -r "$i" ]
      then
        echo "@@@@@@ START OF ${i}"
        echo
        cat $i
        echo
        echo "###### END OF ${i}"
        echo
      fi
    done
  fi
}

################ MAIN #############

if [ -d /usr/sap ]
then
  cd /usr/sap
  sids=`ls | grep -v "put|tmp|trans|archive|ccms"`
  for sid in $sids
  do
    get_database;
    if [ "$database" = "oracle" ]
    then
      get_oracle_config;
    fi
    get_profiles;
    get_tracefiles;
    get_dispwork_version;
    get_ss_config;
  done
  get_transportconfig;
  get_saproutconfig;
else
  echo "No SAP-System installed or detected"
fi
