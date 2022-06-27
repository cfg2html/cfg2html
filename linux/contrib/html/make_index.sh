#  !/usr/bin/ksh
#######################################################################
# @(#) $Id: make_index.sh,v 6.14 2020/10/29 13:19:54 ralph Exp $
# $Log: make_index.sh,v $
# Revision 6.14  2020/10/29 13:19:54  ralph
# Fixes for make_index.sh (see issue #144)
# Fixes for regression in cfg2html-linux and crontab collecting
#
# Revision 6.12  2018/01/04 22:26:07  ralph
# Revision 6.10.1.1  2013-09-12 16:13:19  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
# Revision 4.18  2010-04-27 09:31:02  ralproth
# cfg4.70-24165: fixes for cfg2html_solaris 1.6.4
# Revision 4.15  2009/03/09 14:02:21  ralproth
# cfg4.23-22229: Enhancements for Brocade and Itanium
# Revision 4.14  2009/03/09 13:47:57  ralproth
# Revision 3.13  2008/02/07 20:49:53  ralproth
# 3.56: added SUN support
# Revision 3.10.1.1  2005/05/09 12:52:02  ralproth
# Initial 3.x stream import
# Revision 2.6  2004/11/17 11:39:41  ralproth
# Enhanced cron collector
#
#######################################################################
# (c) 1999-2022 by cfg2html@hotmail.com, All Rights Reserved, Freeware
# http://rose.rult.at/
#######################################################################
# Simply run this shell script in the directory, where your cfg2html
# files are stored. After running this script, load the allhosts.htm
# file in your browser. This is part of the cfg2html package!
#######################################################################
# 02-july-99  0.01 initial creation
#######################################################################

PATH=/bin:/usr/bin:$PATH                ## cygwin

OUT=index.htm

echo "Make_Index for Cfg2Html (Linux, HP-UX and *nix)"
echo "-------------------------------------------------------------------------"
echo "Make_Index creates an index of your cfg2html collected hosts files"
echo "\$Id: make_index.sh,v 6.14 2020/10/29 13:19:54 ralph Exp $"
echo ""

cat >$OUT<<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<body text="#000000" bgcolor="#FFFFFF" link="#0000FF" vlink="#800080" alink="#FF0000" background="cfg2html_back.jpg">
<br>
<B><A HREF="info.htm" TARGET="info">cfg2html Host Overview</A></B>
<br><hr>
<br><small>
EOF

for i in `(find . -iname "*.htm*" -print| grep -v -E './index.htm|./allhosts.htm|./info.htm' | sort -u )`  ## this find doesn't support spaces in the filename!
do
  # echo "Host= ["$i"]"
  if (grep -e cfg2Html -e "cfg2html/HPUX" -e "cfg2html/HP-UX" -e Cfg2Html \
    -e "(cfg2html for Linux)" \
    -e cfg2html-linux -e "cfg2html-brocade" -e "cfg2html/SUN" -e cfg2html_solaris "$i">/dev/null) ;
  then
    typ2=""
    ########### 0.54 changes ##########
    typ=`grep "HP-UX " "$i" | grep "uname -a" | head -1 | awk '{print $5"-"$7}'`
    if [ -z "$typ" ]
    then
      typ=`grep "kernel.osrelease" "$i"|grep "= "|head -1 | awk -F"= " '{print $2;}'	# cut -f3 -d" "`
      [ -z "$typ" ] && typ=$(grep "<B>SunOS" "$i"| head -1) ## <PRE><B>SunOS 5.9</B></PRE>
      [ -z "$typ" ] && typ=$(grep "Kernel version: SunOS" "$i"| head -1|awk '{print $3,$4,$5,$6;}') ## Kernel version: SunOS 5.8 Generic 108528-24 Sep 2003</PRE>
    else
      typ2=`grep 9000 "$i" | grep -E '0/8|Itanium'| head -1 | sed 's+^.*9000/\(.*\)$+\1+g' `
    fi
    echo "Added host: $i ($typ)"
    echo "<A HREF=\"$i\" TARGET=\"info\"><b>$i</b>" >> $OUT
    echo "</A> " >> $OUT

    if [ "$1" = "-v" ] ;
    then
      echo "($typ $typ2)" >> $OUT
    fi
    echo "<br>" >> $OUT
  else
    echo "Skipping: " $i
  fi
done

echo "<p><hr><p>Created: `date +%x-%X`">>$OUT

cat >> $OUT<<EOF
<br></small>
</BODY></HTML>
EOF

echo "-------------------------------------------------------------------------"
echo "All hosts collected! Now load the file allhosts.htm into your browser!"

# end
