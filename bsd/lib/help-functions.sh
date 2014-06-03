function usage {
   echo "WARNING, use this script AT YOUR OWN RISK"
   echo
   echo "  Usage: $(basename $0) [OPTION]"
   echo "  creates HTML and plain ASCII host documentation"
   echo
   echo "  -o     set directory to write or use the environment"
   echo "         variable OUTDIR=\"/path/to/dir\" (directory must exist)"
   echo "  -v     output version information and exit"
   echo "  -h     display this help and exit"
   echo
   echo "  use the following options to disable collections:"
   echo
   echo "  -s     disable: System"
   echo "  -k     disable: Kernel"
   echo "  -H     disable: Hardware"
   echo "  -C     disable: Cluster"
   echo "  -f     disable: Filesystems"
   echo "  -F     disable: Locval Files"
   echo "  -d     disable: Disks"
   echo "  -n     disable: Network"
   echo "  -P     disable: Printers"
   echo "  -c     disable: Cron"
   echo "  -p     disable: Passwords"
   echo "  -e     enable:  Plugins"
   echo "  -s     disable: Software"
   echo "  -F     disable: Files"
   echo "  -a     disable: Applications"
   echo "  -b     disable: Boot System"
   echo "  -D     disable: Volume Manager"
   echo "  -l     disable: Licenses"
   echo "  -x     don't create background images"
}

