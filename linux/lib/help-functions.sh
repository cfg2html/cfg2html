function usage {
  echo "WARNING, use this script AT YOUR OWN RISK"
  echo
  echo "    Usage: `basename $0` [OPTIONS]"
  echo "    creates a HTML and plain ASCII host documentation"
  echo
  echo "    -o      set directory to write or use the environment"
  echo "            variable OUTDIR=\"/path/to/dir\" (directory must exist)"
  echo "    -v      output version information and exit"
  echo "    -h      display this help and exit"


  echo "    use the following options to disable / enable collections:"
  echo
  echo "    -s      disable: System"
  echo "    -c      disable: Cron"
  echo "    -S      disable: Software"
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

