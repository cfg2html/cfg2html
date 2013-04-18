##############################################################################
# vparstatus reconstructor,  initial creation 12.12.2007, Ralph Roth
##############################################################################
# @(#) $Id: vparcreate_reconstruct.sh,v 5.10.1.1 2011-02-15 14:29:04 ralproth Exp $
# ---------------------------------------------------------------------------
# This plugin (contrib)) is part of the cfg2html package for HP-UX
# ---------------------------------------------------------------------------
# only tested with vPars 4.0.x -- Dienstag, 18. August 2009
# tested with vPars 5.0.5 -- 08. Sep. 2009 - 18:59

# If floating memory is configured, a separate list of floating memory is 
# added to the display following the CLM granularity subfield. The list will 
# be in the following order:
# 
# floating user assigned ILM ranges
# floating monitor assigned ILM ranges
# floating ILM size
# floating user assigned CLM ranges
# floating monitor assigned CLM ranges
# floating CLM size
# 
# If there is no floating memory configured in the vPar, this list is empty.


##############################################################################
# vparstatus(1M)
# ---------------------------------------------------------------------------   
# vPar configurations: The full list of major fields, and their order, is: 
# vPar name (1), vPar state (2), attributes (3), kernel path (4), boot options 
# (5), CPU resources (6), I/O resources (7), memory resources (8), reboot for 
# reconfiguration flag (9). Each vPar is displayed on a separate line, 
# regardless of length.
##############################################################################

[ -x /usr/sbin/vparstatus ] || exit 1   # no vpar box?

echo "## $0 - started at "$(date)" on host "$(hostname)
echo ""

# what /stand/vpmon|grep vpar
vparstatus -M | awk -F: '
BEGIN{}
{ 
printf("## vPar state: %s, attributes: %s\n## boot options (-o): %s/%s, kernel (-b) = %s \n", $2, $3, $5, $11, $4);

split($6, CPU, ";");  gsub("/",":",CPU[1]);
split($7, IO, ";");
split($8, MEM, ";");

printf("\n#### =------ begin of vparcreate command line ------= ####\n");
printf("## 0=%s 2=%s", CPU[0], CPU[2]);
printf("vparcreate -p %s -a cpu::%s -a mem:%s:%s \\ \n", $1, CPU[1], MEM[1], MEM[2]);

split(IO[1], IOSUB, ",");
## asort(IOSUB); # awk: Function asort is not defined. - ONLY GAWK!

for (t in IOSUB)  { printf("-a %s \\\n", IOSUB[t]) }

# -g memtype:size[:update_fw]
#  memtype is one of the two case-insensitive strings:
#  clm   Cell Local Memory
#  ilm   InterLeaved Memory

printf("-g ilm:%s ", MEM[6]);

printf("\n#### =------- end of vparcreate command line -------= ####\n\n")
}'

# IA64, vPars4.xx
# -a cpu: [1] 1:8 \
# -a cpu: [2]  \
# -a cpu: [3] 1.120 \
# -a cpu: [4]  \
# -a cpu: [5]  \
# -a cpu: [6] 0 \
# -a cpu: [7] 1 \
# -a cpu: [8]  \
# 
# -a io:[1] 1.0.1,1.0.2,1.0.4,1.0.6,1.0.1.1.0.4.0.8.0.0.0.0.0 BOOT,1.0.2.1.0.4.0.8.0.0.0.0.0 ALTBOOT \
# MEM[x]
# -g [1]  \
# -g [2] 32189 \
# -g [3]  \
# -g [4] 0x20000000/511,0x900000000/27648,0xfc0000000/960,0x4040000000/2048,0x40c0000000/1022 \
# -g [5] 32189 \
# -g [6] 1024 \
# -g [7]  \
# -g [8]  \
# -g [9]  \
# -g [10] 128 \


##############################################################################
# $Log: vparcreate_reconstruct.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:04  ralproth
# Initial 5.xx import
#
# Revision 4.7  2010-11-23 15:50:53  ralproth
# cfg4.87-25244: Added comments about plugin and contrib location
#
# Revision 4.6  2010-09-28 17:11:34  ralproth
# cfg4.84-24820: misc fixes from svn upstream
#
# Revision 4.3  2009-09-03 09:13:16  ralproth
# cfg4.52-23593: fixed: sfmconfig, vpar stuff
#
# Revision 4.2  2009-08-19 20:00:17  ralproth
# cfg4.48-23483: vPar 5.0.5
#
# Revision 4.1  2009/01/07 15:27:23  ralproth
# Revision 3.3  2007/12/17 14:44:45  rothra
# Revision 3.2  2007/12/17 14:31:39  rothra
# Revision 2.1  2007/12/17 13:41:47  ralproth
#
##############################################################################
