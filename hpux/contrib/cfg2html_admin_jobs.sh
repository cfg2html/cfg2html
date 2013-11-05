#!/bin/sh
#
# @(#) $Id:$

## purpose of this script is to remove old collections, and to
## keep a monthly overview of each server, and create for each system a new index.html file
## also we create each day a new main index.html file
## We can use apache httpd.conf file to make the main index and all systems visible via the intranet
## add to httpd.conf:
##    Alias /cfg2html/ "/mnt/xxx-hpux/hpux/cfg2html/"
##    <Directory "/mnt/xxx-hpux/hpux/cfg2html">
##    Options Indexes MultiViews
##    AllowOverride None
##    Order allow,deny
##    Allow from all
##    </Directory>

######
### Functions
######

function url_scheme {
    url=$1
    scheme=${url%%://*}
    # rsync scheme does not have to start with rsync:// it can also be scp style
    echo $scheme | grep -q ":" && echo rsync || echo $scheme
}

function url_host {
    url=$1
    host=${url#*//}
    echo ${host%%/*}
}

function url_path {
    url=$1
    path=${url#*//}
    echo /${path#*/}
}

### Mount URL $1 at mountpoint $2[, with options $3]
function mount_url {
    url=$1
    mountpoint=$2
    defaultoptions="rw"
    options=${3:-"$defaultoptions"}

    ### Generate a mount command
    mount_cmd=""
    case $(url_scheme $url) in
        (tape|file|rsync|fish|ftp|ftps|hftp|http|https|sftp)
            ### Don't need to mount anything for these
            return 0
            ;;
        (var)
            ### The mount command is given by variable in the url host
            var=$(url_host $url)
            mount_cmd="${!var} $mountpoint"
            ;;
        (cifs)
            if [ x"$options" = x"$defaultoptions" ];then
                mount_cmd="mount $v -o $options,guest //$(url_host $url)$(url_path $url) $mountpoint"
            else
                mount_cmd="mount $v -o $options //$(url_host $url)$(url_path $url) $mountpoint"
            fi
            ;;
        (usb)
            mount_cmd="mount $v -o $options $(url_path $url) $mountpoint"
            ;;
	(sshfs)
	    mount_cmd="sshfs $(url_host $url):$(url_path $url) $mountpoint -o $options"
	    ;;
        (*)
            #mount_cmd="mount $v -t $(url_scheme $url) -o $options $(url_host $url):$(url_path $url) $mountpoint"
            mount_cmd="mount $v -o $options $(url_host $url):$(url_path $url) $mountpoint"
            ;;
    esac

    echo "Mounting with '$mount_cmd'"
    $mount_cmd 
    if [[ $? -ne 0 ]]; then
        echo "Mount command '$mount_cmd' failed."
        exit 1
    fi
}

### Unmount url $1 at mountpoint $2
function umount_url {
    url=$1
    mountpoint=$2

    case $(url_scheme $url) in
        (tape|file|rsync|fish|ftp|ftps|hftp|http|https|sftp)
            ### Don't need to umount anything for these
            return 0
            ;;
	(sshfs)
	    umount_cmd="fusermount -u $mountpoint"
	    ;;
        (var)
            var=$(url_host $url)
            umount_cmd="${!var} $mountpoint"

            echo "Unmounting with '$umount_cmd'"
            $umount_cmd
            if [[ $? -ne 0 ]]; then
                echo "Unmounting failed."
                exit 1
            fi

            return 0
            ;;
    esac

    umount_mountpoint $mountpoint
    if [[ $? -ne 0 ]]; then
        echo "Unmounting '$mountpoint' failed."
        exit 1
    fi
}

### Unmount mountpoint $1
function umount_mountpoint {
    mountpoint=$1

    ### First, try a normal unmount,
    echo "Unmounting '$mountpoint'"
    umount $v $mountpoint >&2
    if [[ $? -eq 0 ]] ; then
        return 0
    fi

    ### otherwise, try to kill all processes that opened files on the mount.
    # TODO: actually implement this

    ### If that still fails, force unmount.
    echo "Forced unmount of '$mountpoint'"
    umount $v -f $mountpoint >&2
    if [[ $? -eq 0 ]] ; then
        return 0
    fi

    echo "Unmounting '$mountpoint' failed."
    return 1
}

function IsDigit {
    expr "$1" + 1 > /dev/null 2>&1  # sets the exit to non-zero if $1 non-numeric
}


function line2html {
    while { read dirent ; }
    do
        ww=$(echo $dirent | wc -w) ;
        if [[ $ww -eq 1 ]]; then
            echo "<font color=green>"$dirent"</font>"
        elif [[ $ww -eq 0 ]]; then
            echo
        else
            if [[ $MAKELINKS -eq 1  ]]; then
                fordir=$(echo $dirent | cut -d ' ' -f 7)
                printf "%10s %2d %10d %3s %2d %5s <a href=\"%s\">%s</a>\n" $dirent $fordir;
            else
                # be prepared to write foo -> foo.link or filenames with blanks
                printf "%10s %2d %10d %3s %2d %5s %s %s %s\n" $dirent;
            fi
        fi
    done
}

function ls2html {
    # code based on ls2html from http://www.strw.leidenuniv.nl/~mathar/progs/ls2html
    MAKELINKS=1
    echo '<html>'
    echo '<head>'
    echo '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
    echo '<meta http-equiv="Content-Language" content="en">'
    echo '<meta http-equiv="Last-Modified" content="'`date`'">'
    echo '<meta name="author" content="'$0'">'
    echo '<title>'
    echo  Config2HTML of $*
    echo '</title>'
    echo '</head>'
    echo '<body bgcolor="#f6feff">'
    echo '<pre>'

    if [[ $MAKELINKS  -eq 1 ]]; then
        ls -aoglFL $1  | fgrep -v index.html | sed '/^total/d' | line2html -h
    else
        ls -oglAR $*  | sed '/^total/d' | line2html
    fi

    echo '</pre>'
    echo "`date` by modified ls2html</a>"
    echo '</body>'
    echo '</html>'
}

function server2html {
    echo '<html>'
    echo '<head>'
    echo '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
    echo '<meta http-equiv="Content-Language" content="en">'
    echo '<meta http-equiv="Last-Modified" content="'`date`'">'
    echo '<meta name="author" content="'$0'">'
    echo '<title>'
    echo  Config2HTML Main
    echo '</title>'
    echo '</head>'
    echo '<body bgcolor="#f6feff">'
    echo '<pre>'

    for system in $(ls)
    do
        [[ -z "$system" ]] && continue
        if [[ -f $system/index.html ]]; then
            printf "<a href=\"%s\">%s</a>\n" $system/index.html $system
        fi
    done

    echo '</pre>'
    echo "<p>`date` by server2html</p>"
    echo '<p>index.html file created by code of Gratien D\'haese - GNU License v3</p>'
    echo '</body>'
    echo '</html>'
}

##############################################################################
# M A I N
##############################################################################

# must be root
if [[ $(id -u) -ne 0 ]]; then
    echo "ERROR: you must be root to execute $0"
    exit 1
fi

# CONFIG_DIR can be /etc/cfg2html or /opt/cfg2html/etc
if [[ -d /etc/cfg2html ]]; then
    CONFIG_DIR=/etc/cfg2html
elif [[ -d /opt/cfg2html/etc ]]; then
    CONFIG_DIR=/opt/cfg2html/etc
else
    echo "ERROR: Could not find configuration directory of cfg2html"
    exit 1
fi

# check if we find a local.conf file for the OUTPUT_URL definition
if [[ -f $CONFIG_DIR/local.conf ]]; then
    . $CONFIG_DIR/local.conf
else
    echo "ERROR: configuration file $CONFIG_DIR/local.conf mot found (need OUTPUT_URL)
    exit 1
fi

if [[ -z "$OUTPUT_URL" ]]; then
    echo "ERROR: No OUTPUT_URL defined. We need one to continue..."
    echo "       e.g. OUTPUT_URL="nfs://server/location_to_cfg2html_data"
    exit 1
fi

temp_mntpt=$(mktemp -d /tmp -p cfg2html_$$)
mkdir -m 755 -p $temp_mntpt
mount_url "$OUTPUT_URL" ${temp_mntpt}


# goto the cfg2html directory
cd ${temp_mntpt}/cfg2html
[[ $? -ne 0 ]] && {
    echo "ERROR: ${temp_mntpt}/cfg2html not mounted??"
    exit 1
    }

# remove old files
##################
# remove txt and err files older than 30 days
/usr/bin/find . -type f -xdev \( -name "*.err" -o -name "*.txt" \) -mtime +30 -exec rm -f {} \;

# html files - we would like to keep the latest of the month (as reference)
/usr/bin/find . -type f -xdev -name "*.html" -mtime +30 -exec ls -l {} \;  | while read LINE
do
    month=$( echo $LINE | awk '{print $6}' )
    filename=$( echo $LINE | awk '{print $9}' )    # ./gtsbcp01/gtsbcp01_20130721.html
    # would like to rename into ./gtsbcp01/gtsbcp01_Jul.html
    hname=$( echo ${filename##*/} | cut -d"_" -f1 )   # gtsbcp01
    yyyymmdd=$( echo ${filename##*/} | cut -d"_" -f2 | cut -d"." -f1 )  # 20130721
    IsDigit ${yyyymmdd} || continue                   # we found file named "gtsbcp01_Aug.html" - skip it
    dname=${filename%/*}                              # ./gtsbcp01
    mv -f $filename ${dname}/${hname}_${month}.html
done


# recreate new index.html files per system directory
for system in $(ls)
do
    [[ -d $system ]] && chmod 755 $system
    [[ ! -d $system ]] && continue
    ls2html $system > $system/index.html
    chmod 644 $system/index.html
done

# create top index.html file
server2html > index.html
chmod 644 index.html

cd /tmp
umount_url "$OUTPUT_URL" $temp_mntpt
rmdir -f $temp_mntpt

exit 0
