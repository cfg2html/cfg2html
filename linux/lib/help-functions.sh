
## $Id: help-functions.sh,v 6.12 2017/11/15 13:48:23 ralph Exp $

function usage {
  echo "WARNING, use this script AT YOUR OWN RISK"
  echo
  echo "    Usage: `basename $0` [OPTIONS]"
  echo "           creates host documentation in HTML and plain ASCII "
  echo "    Output modifier:"
  echo "    -o      set directory to write to; or use the environment"
  echo "            variable OUTDIR=\"/path/to/dir\""
  echo "    -0      append the current date+time to the output files (D-M-Y-hhmm)"
  echo "    -1      append the current date to the output files (Day-Month-Year)"
  echo "    -2 arg  like option -1, you can use date +modifier, e.g. -2%d%m or -2 %Y%m%d-%H%M"
  echo "            DO NOT use spaces for the filename, e.g. -2%c"
  echo
  echo "    Help:"
  echo "    -v      output version information and exit"
  echo "    -h      display this help and exit"
  echo

  echo "    use the following options to disable / enable collections:" # modified the order of the statements  # modified on 20240119 by edrulrd
  echo "    -s      disable: System"
  echo "    -k      disable: Kernel/Libraries"
  echo "    -n      disable: Network"
  echo "    -H      disable: Hardware"
  echo "    -x      disable: PATH file listing (only effective if System is not disabled, ie. -s is not specified)" # modified on 20240119 by edrulrd
  echo "    -S      disable: Software"
  echo "    -a      disable: Applications"
  echo "    -f      disable: Filesystem"
  echo "    -l      disable: LVM"
  echo "    -z      disable: ZFS"
  echo "    -c      disable: Cron"
  echo "    -O      disable: listing of open but deleted files (only effective if System is not disabled, ie. -s is not specified)" # modified on 20240119 by edrulrd
  echo "    -L      disable: Screen tips inline, and do not display the issued command" # modified on 20240119 by edrulrd 
  echo "    -e      disable: Enhancements"
  echo "    -V      disable: Collecting VMWare log files and settings" # added on 20240119 by edrulrd
  echo "    -A      disable: Altiris ADL agent log files and settings"
  echo "    -w arg  adjust the width of the section separators in the generated ASCII file and allow for columnar output" # added on 20240119 by edrulrd
  echo "    -W      enable:  generate a message in the errorlog of executable commands which are not found on the system" # added on 20250216 by edrulrd
  echo "    -T      enable:  trace timings in output (txt, html and err)"
  echo "    -p      enable:  collecting the system's log files particularly if on an HP Proliant Server"
  echo "    -P      enable:  cfg2html plugin architecture"
  #echo
}

