
## $Id: help-functions.sh,v 6.12 2017/11/15 13:48:23 ralph Exp $

function usage {
  echo "WARNING, use this script AT YOUR OWN RISK"
  echo
  echo "    Usage: `basename $0` [OPTIONS]"
  echo "    creates a HTML and a plain ASCII host documentation"
  echo "    Output modifier:"
  echo "    -o      set directory to write or use the environment"
  echo "            variable OUTDIR=\"/path/to/dir\" (directory must exist)"
  echo "    -0      append the current date+time to the output files (D-M-Y-hhmm)"
  echo "    -1      append the current date to the output files (Day-Month-Year)"
  echo "    -2 arg  like option -1, you can use date +modifier, e.g. -2%d%m"
  echo "            DO NOT use spaces for the filename, e.g. -2%c"
  echo
  echo "    Help:"
  echo "    -v      output version information and exit"
  echo "    -h      display this help and exit"
  echo

  echo "    use the following options to disable / enable collections:"
  echo "    -s      disable: System"
  echo "    -c      disable: Cron"
  echo "    -S      disable: Software"
  echo "    -T      enable:  trace timings in output (txt, html and err)"
  echo "    -f      disable: Filesystem"
  echo "    -l      disable: LVM"
  echo "    -L      disable: Screen tips inline"
  echo "    -k      disable: Kernel/Libraries"
  echo "    -e      disable: Enhancements"
  echo "    -n      disable: Network"
  echo "    -a      disable: Applications"
  echo "    -H      disable: Hardware"
  echo "    -p      enable: HP Proliant Server log files and settings"
  echo "    -A      disable: Altiris ADL agent log files and settings"
  echo "    -P      enable: cfg2html plugin architecture"
  #echo
}

