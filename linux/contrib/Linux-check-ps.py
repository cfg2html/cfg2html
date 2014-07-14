#!/usr/bin/python

# Description: Check Linux processes by type
#              Results are displayed on stdout or redirected to a file
#
# If you obtain this script via Web, convert it to Unix format. For example:
# dos2unix -n Linux-check-ps.py.txt Linux-check-ps.py
#
# Last Update:  23 June 2014
# Designed by:  Dusan U. Baljevic (dusan.baljevic@ieee.org)
# Coded by:     Dusan U. Baljevic (dusan.baljevic@ieee.org)
#
# Copyright 2014 Dusan Baljevic
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import subprocess
import shlex
import sys
import os
import getopt

os.environ['PATH'] = "/bin:/usr/bin:/sbin:" + os.environ['PATH']

def main(argv):
   try:
      opts, args = getopt.getopt(argv,"h")
   except getopt.GetoptError:
      print 'Linux-check-ps.py [-h]'
      sys.exit(1)
   for opt, arg in opts:
      if opt == '-h':
         print 'Linux-check-ps.py [-h]'
         sys.exit()

if __name__ == "__main__":
   main(sys.argv[1:])

# Command to run to list all processes
#
myprocess = "ps auxwwZ"

# Initialise lists for each process type
#
lsleep   = []
lunsleep = []
lrun     = []
lstop    = []
lpage    = []
ldead    = []
lzombie  = []

linecnt = 0

p = subprocess.Popen(myprocess, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():

    if linecnt == 0:
        lunsleep.append(line)
        lrun.append(line)
        lstop.append(line)
        lpage.append(line)
        lsleep.append(line)
        ldead.append(line)
        lzombie.append(line)
        linecnt += 1
    else:
        psent = shlex.split(line)

        if psent[8].startswith('S') == True:
            lsleep.append(line)

        if psent[8].startswith('D') == True:
            lunsleep.append(line)

        if psent[8].startswith('R') == True:
            lrun.append(line)

        if psent[8].startswith('T') == True:
            lstop.append(line)

        if psent[8].startswith('W') == True:
            lpage.append(line)

        if psent[8].startswith('X') == True:
            ldead.append(line)

        if psent[8].startswith('Z') == True:
            lzombie.append(line)

retval = p.wait()

if retval == 0:
    if len(lsleep) > 1:
        print "INFO: Processes in interruptible sleep"
        print ''.join(lsleep)

    if len(lunsleep) > 1:
        print "INFO: Processes in uninterruptible sleep (usually I/O issue)"
        print ''.join(lunsleep)

    if len(lrun) > 1:
        print "INFO: Processes in runnable state"
        print ''.join(lrun)

    if len(lpage) > 1:
        print "INFO: Paging processes (should not be seen since the 2.6.xx kernel)"
        print ''.join(lpage)

    if len(ldead) > 1:
        print "INFO: Dead processes"
        print ''.join(ldead)

    if len(lzombie) > 1:
        print "INFO: Defunct (zombie) processes"
        print ''.join(lzombie)
else:
    print "ERROR: Command failed:", myprocess
    exit(1)

exit(0)
