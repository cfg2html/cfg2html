function line {
    echo "--=[ http://www.cfg2html.com ]=---------------------------------------------"
}

function _banner {
    local txt="$*"
    BANNER_EXE=$(which banner 2>/dev/null)
    [[ -z "$BANNER_EXE" ]] && BANNER_EXE=echo
    $BANNER_EXE "$txt"
}

function check_root {
    if [ `id|cut -c5-11` != "0(root)" ]; then
        line
        _banner "Sorry"
        _echo "You must run this script as Root\n"
        exit 4
    fi
}

function check_plugins_dir {
    if [ ! -x $PLUGINS/get_ministat.sh ]; then
        line
        _banner "Error"
        echo "Installation Error, the plug-in directory is missing or execution bit is not set"
        echo "You MUST install cfg2html via swinstall or tar xvf"
        echo "Plugin-Dir = $PLUGINS"
        exit 5
    fi
}

function create_dirs {
    [[ ! -d $OUTDIR ]] && mkdir -p -m 755 $OUTDIR
    [[ ! -d $VAR_DIR ]] && mkdir -p -m 755 $VAR_DIR
    [[ ! -d $TMP_DIR ]] && mkdir -p -m 755 $TMP_DIR
}

function check_lock {
    if [ -f $LOCK ]; then
        echo "Found $LOCK file - we could be locked..."
        OTHERPID=$(<$LOCK)
        if kill -s 0 ${OTHERPID} 2>/dev/null ; then
            echo "locked on ${OTHERPID}"
            echo "stop processing"
            exit
        else
            echo "lock is stale - will continue"
        fi
    fi
    if echo $$ > $LOCK ; then
        echo "lock succeeded: $$ - $LOCK"
    else
        echo "lock failed: $LOCK with rc=$?"
        echo "stop processing"
        exit 14
    fi
}

function cat_and_grep {
    # removes comment and blank lines, remove lines with only whitespace
    #  prints $1 out and filters the output for comments and empty lines
    #  $1  = unix command,  $2 = text for the heading

    exec_command "awk 'NF && ! /^[[:space:]]*#/' $1" "$2"
}

function KillOnHang {
    # Schedule a job for killing commands which may hang under special conditions
    #  Argument 1: regular expression to search process list for
    #  Argument 2: number of minutes to wait for process to complete
    TMP_KILL_OUTPUT=/tmp/kill_hang.tmp.$$
    at now + $2 minutes 1>$TMP_KILL_OUTPUT 2>&1 <<-EOF
	ps -ef | grep root | grep -v grep | egrep $1 | awk '{print \$2}' | sort -n -r | xargs kill
	EOF
    AT_JOB_NR=`egrep '^job' $TMP_KILL_OUTPUT | awk '{print \$2}'`
    rm -f $TMP_KILL_OUTPUT
}

function CancelKillOnHang {
    # You should always match a KillOnHang() call with a matching call
    # to this function immediately after the command which could hang
    # has properly finished.
    at -r $AT_JOB_NR
}

function LANG_C {
    LANG="C"
    LANG_ALL="C"
    LC_MESSAGE="C"
    export LANG LANG_ALL LC_MESSAGE
}

function _echo {
    case $OS in
        linux|darwin) arg="-e " ;;
    esac
    echo $arg "$*"
} # echo is not the same between UNIX and Linux

