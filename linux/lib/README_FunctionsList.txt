# Files from ./cfg2html/linux/lib/*.sh

# @(#) $Id: global-functions.sh,v 6.11 2013-10-08 08:53:58 ralph Exp $
  function define_outfile
  function read_and_strip_file
  -  function url_scheme
     function url_host
     function url_path
     function mount_url
     function umount_url
     function umount_mountpoint
     function CopyFilesAccordingOutputUrl
  function mktempDir
  function DoExitTasks
  function findproc
  function TimeOut


## $Id: help-functions.sh,v 6.12 2017/11/15 13:48:23 ralph Exp $
   function usage


# cfg2html - HTML function library - Linux part
# @(#) $Id: html-functions.sh,v 6.16 2017/11/15 13:51:20 ralph Exp $
  function open_html
  function inc_heading_level
  function dec_heading_level
  function paragraph
  function exec_command
  function AddText
  function close_html


# @(#) $Id: input-output-functions.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# input-output-functions.sh
  function has_binary
  function Error
  function StopIfError
  function BugError
  function BugIfError
  function Debug
  function Print
  function PrintIfError
  function Stamp
  function Log
  function LogIfError
  function LogPrint
  function LogPrintIfError


# @(#) $Id: linux-functions.sh,v 6.14 2017/11/15 13:52:01 ralph Exp $
# Common functions for the Linux part of cfg2html
# is_which_available, is_cnf_available, and replacement which function added on 20250215 by edrulrd
  function is_which_available
  function is_cnf_available
  function which
  function HostNames
  function posixversion
  function identify_linux_distribution
  function topFDhandles
  function DoSmartInfo
  function mcat
  function ProgStuff
  function display_ext_fs_param
  function PartitionDump
  function extract_xpinfo_i
  function extract_my_xpinfo
  function extract_xpinfo_c
  function extract_xpinfo_r
  function my_df
  function PVDisplay
  function GetElevator


# @(#) $Id: shell-functions.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# common shell functions for all versions
  function line
  function _banner
  function check_root
  function check_plugins_dir
  function create_dirs
  function check_lock
  function cat_and_grep
  function KillOnHang
  function CancelKillOnHang
  function LANG_C
  function _echo
  function _check_cmd_already_running
