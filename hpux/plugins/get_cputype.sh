#!/sbin/sh
# ---------------------------------------------------------------------------
# @(#) $Id: get_cputype.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# Found somewhere in the internet on a hpux support forum. Fixed some stuff.
# ---------------------------------------------------------------------------
# $Log: get_cputype.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.11  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.10.1.1  2007/12/14 13:16:48  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.2  2007/12/14 13:16:48  ralproth
# 3.52: fixes for HP-UX 11.23/IA64, typo fixes
#
# Revision 3.1  2007/11/26 19:03:34  ralproth
# Added Files:
# 	get_cellinfo.sh get_cputype.sh
#
#

OS_REL=`uname -r | sed -e 's/^[AB]\.//' -e 's/\..*//'`
cpu_type=paXXXX
if [ "$OS_REL" -ge 11 ]; then
    typeset -i2 bin
    bin=`getconf CPU_CHIP_TYPE`
    typeset -i16 hex
    hex=2#`echo $bin | sed -e 's/2#//' -e 's/.....$//'`
    model_num=`echo $hex | cut -c4-`
    case $model_num in
        b)    cpu_type=PA7200   ;;
        d)    cpu_type=PA7100LC ;;
        e)    cpu_type=PA8000   ;;
        f)    cpu_type=PA7300LC ;;
        10)   cpu_type=PA8200   ;;
        11)   cpu_type=PA8500   ;;
        12)   cpu_type=PA8600   ;;
        13)   cpu_type=PA8700   ;;
        14)   cpu_type="PA8800 (1C/1P) or PA8900 (2C/1P)"   ;;
        15)   cpu_type=PA8750   ;;
         *)   cpu_type=paXXXX   ;;
    esac
else
    model_num=`model`
    model_num=`echo $model_num | sed -e 's/^9000\///'`
    l=`expr length $model_num`
    if [ $l -gt 5 ]; then
        model_num=`echo $model_num | sed -e 's/^[78]..\///'`
    else
        model_num=`echo $model_num | sed -e 's/\/.*//'`
    fi
    if [ $model_num = B1000 -o $model_num = B2000 ]; then
        cpu_type=PA8500
    fi
    for sm in /usr/lib/sched.models /usr/sam/lib/mo/sched.models /opt/langtools/lib/sched.models
    do
        if [ -s $sm ]; then
            h=`awk '(NF>=3&&$1=="'$model_num'"){print $3;exit}' $sm`
            if [ -n "$h" ]; then
                cpu_type=$h
                break
            fi
        fi
    done
fi
## echo $cpu_type" ("$bin")"
echo $cpu_type
