#!/bin/ksh
# This is a Veritas Cluster Services Plugin for cfg2html written by ROSE SWE,
# http://www.cfg2html.com. I found this utility so useful that I spent a few
# hours after a peoplesoft outage in the office sorting out  VCS Support. I
# hope this code is of as much use to others as it was to me.

# Written and tested on Sun Solaris 8/9 for Veritas Cluster 3.5 --> 4.1
# Keiran Sweet - Hutchison Telecoms Australia
# < Keiran at gmail . com >
# Current Release: 1.0 - Initial Release - May 13 2005
# Still to be Done:
# - HP-UX Testing - I havent had the time to test this on VCS/HP
# - Linux testing and adding to teh main script
# - More features - Give me feedback/info on how this can be improved


# Variables
export PATH=$PATH:/opt/VRTS/bin:/usr/sbin
export OSREV=`uname`

case $1 in

  status )
  # Display the Status of the Cluster #
  hastatus -sum
  ;;

  main )
  # Display the main.cf #
  cat /etc/VRTSvcs/conf/config/main.cf
  ;;

  processes )
  # Display the PID's of the VCS Processes #
  echo
  echo "VCS Processes IDs"
  HADPID=`ps -ef |grep had|grep -v grep |grep -v shadow|awk '{print $2}'`
  HASHADOW=`ps -ef |grep hashadow |grep -v grep |awk '{print $2}'`
  echo "had PID running at: $HADPID"
  echo "hashadow PID running at: $HASHADOW"
  echo
  ;;

  lltstat )
  # Display the Heartbeat status #
  lltstat -nvv
  ;;

  llttab )
  # Display the contents of the LLT Configuration File #
  echo
  cat /etc/llttab
  echo
  ;;

  version )
  # Display the Version of the VRTSvcs Software - HP + SunOS #
  case $OSREV in

  "SunOS" )
  export VCSPKG=`pkginfo -l VRTSvcs |grep VERSION |awk '{print $2}'`
        if [ "$VCSPKG" ]; then
     echo "Veritas VCS Software is Version: $VCSPKG"
        fi
  ;;

  HP-UX )
  echo "HP-UX Detected"
  export VCSPKG=`swlist |grep VRTSvcs |awk '{print $2}'`
  echo "Veritas VCS Software is Version: $VCSPKG"
  ;;

  * )  ## Linux
  echo "OS Type: $OSREV Not yet supported by this script."
  exit 1
  echo

  esac

  ;;

  check )
  # Check if there is any VCS Components Installed #
  # Returns 0 if VCS Found, Returns 1 if VCS Not Found #

        case $OSREV in

        "SunOS" )
  pkginfo VRTSvcs > /dev/null
  exit $?
        ;;

        HP-UX )
  swlist VRTSvcs > /dev/null
  exit $?
        ;;

        * )  ## Linux
        # If its not one of the Above exit 1 #
  ;;
        esac
  ;;


  * )
  echo "Usage: { status | main | processes | lltstat | llttab }"
  echo "       { version | check }"

  ;;

esac
