# global-functions.sh
#

function read_and_strip_file {
# extracts content from config files. In other words: strips the comments and new lines
	if test -s "$1" ; then
		sed -e '/^[[:space:]]/d;/^$/d;/^#/d' "$1"
	fi
}

######
### Functions for dealing with URLs
######

function url_scheme {
    local url=$1
    local scheme=${url%%://*}
    # rsync scheme does not have to start with rsync:// it can also be scp style
    echo $scheme | grep -q ":" && echo rsync || echo $scheme
}

function url_host {
    local url=$1
    local host=${url#*//}
    echo ${host%%/*}
}

function url_path {
    local url=$1
    local path=${url#*//}
    echo /${path#*/}
}

function output_path {
    local scheme=$1
    local path=$2
    case $scheme in
       (tape)  # no path for tape required
           path=""
           ;;
       (file)  # type file needs a local path (must be mounted by user)
           path="$path/${OUTPUT_PREFIX}"
           ;;
       (*)     # nfs, cifs, usb, a.o. need a temporary mount-path 
           path="${BUILD_DIR}/outputfs/${OUTPUT_PREFIX}"
           ;;
    esac
    echo "$path"
}


### Mount URL $1 at mountpoint $2[, with options $3]
function mount_url {
    local url=$1
    local mountpoint=$2
    local defaultoptions="rw,noatime"
    local options=${3:-"$defaultoptions"}

    ### Generate a mount command
    local mount_cmd
    case $(url_scheme $url) in
        (tape|file|rsync|fish|ftp|ftps|hftp|http|https|sftp)
            ### Don't need to mount anything for these
            return 0
            ;;
        (var)
            ### The mount command is given by variable in the url host
            local var=$(url_host $url)
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
            mount_cmd="mount $v -t $(url_scheme $url) -o $options $(url_host $url):$(url_path $url) $mountpoint"
            ;;
    esac

    Log "Mounting with '$mount_cmd'"
    $mount_cmd >&2
    StopIfError "Mount command '$mount_cmd' failed."
}

### Unmount url $1 at mountpoint $2
function umount_url {
    local url=$1
    local mountpoint=$2

    case $(url_scheme $url) in
        (tape|file|rsync|fish|ftp|ftps|hftp|http|https|sftp)
            ### Don't need to umount anything for these
            return 0
            ;;
	(sshfs)
	    umount_cmd="fusermount -u $mountpoint"
	    ;;
        (var)
            local var=$(url_host $url)
            umount_cmd="${!var} $mountpoint"

            Log "Unmounting with '$umount_cmd'"
            $umount_cmd
            StopIfError "Unmounting failed."

            RemoveExitTask "umount -f $v '$mountpoint' >&2"
            return 0
            ;;
    esac

    umount_mountpoint $mountpoint
    StopIfError "Unmounting '$mountpoint' failed."
}

### Unmount mountpoint $1
function umount_mountpoint {
    local mountpoint=$1

    ### First, try a normal unmount,
    Log "Unmounting '$mountpoint'"
    umount $v $mountpoint >&2
    if [[ $? -eq 0 ]] ; then
        return 0
    fi

    ### otherwise, try to kill all processes that opened files on the mount.
    # TODO: actually implement this

    ### If that still fails, force unmount.
    Log "Forced unmount of '$mountpoint'"
    umount $v -f $mountpoint >&2
    if [[ $? -eq 0 ]] ; then
        return 0
    fi

    Log "Unmounting '$mountpoint' failed."
    return 1
}
