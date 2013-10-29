# @(#) $Id: get_emcsum.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
############################################################################

##### Initial creation:  cfg2html@hotmail.com, ASO BBN, HPCS ##################
# $Log: get_emcsum.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.1  2009/01/13 15:04:51  ralproth
# EMC/inq stuff added/changed
#
# Revision 4.12  2008/11/13 19:53:44  ralproth
# Revision 1.1  2003/11/27 15:40:54  ralproth
############################################################################

# sd1-v01: /root # inq -no_dots -et -f_emc | grep -v FAILED | grep ^/dev/
# /dev/rdsk/c147t0d0    :9600609000 :REG   :N/A   :FBA    :FIBRE :S     :SYMM7 :mirrored    :   :R08C-0 :20081107
# /dev/rdsk/c147t0d1    :960047c000 :REG   :N/A   :FBA    :FIBRE :S     :SYMM7 :RAID-5      :   :R08C-0 :20081107
# /dev/rdsk/c147t1d0    :960072a000 :REG   :N/A   :FBA    :FIBRE :S     :SYMM7 :RAID-5      :   :R08C-0 :20081107
# /dev/rdsk/c147t1d1    :960072b000 :REG   :N/A   :FBA    :FIBRE :S     :SYMM7 :RAID-5      :   :R08C-0 :20081107

# sd1-v01: /root # inq -no_dots  -f_emc | grep -v FAILED | grep ^/dev/
# /dev/rdsk/c147t0d0  :EMC     :SYMMETRIX       :5772  :9600609000 :        2880
# /dev/rdsk/c147t0d1  :EMC     :SYMMETRIX       :5772  :960047c000 :    11011200
# /dev/rdsk/c147t1d0  :EMC     :SYMMETRIX       :5772  :960072a000 :    11011200
# /dev/rdsk/c147t1d1  :EMC     :SYMMETRIX       :5772  :960072b000 :    11011200
# /dev/rdsk/c147t1d2  :EMC     :SYMMETRIX       :5772  :960072c000 :    11011200

# dsk -> dev HPUX 11.31, a/# port:snr, b/# Type:snr
inq -no_dots -et -f_emc | grep -v FAILED | grep ^/dev/ | sort |  tr -d " "|awk -F":" '                    
{
    a[$11" ("$2")"]++;                         
    b[$8 $9" ("$2")"]++;                  
}

END {
    for (t in a) { printf("Port %s \t # LUNS %s\n", t, a[t]); }
    print"";
    for (t in b) { printf("%20s\t # %s\n", t, b[t]); }
}
'
