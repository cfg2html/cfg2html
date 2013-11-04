#!/bin/sh
# ---------------------------------------------------------------------------
# custom example plugin, provided by Andre Naumann, 25. August 2009
# @(#) $Id: templateexample_plugin.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# ---------------------------------------------------------------------------

CFG2HTML_PLUGINTITLE="Example Plugin: This will go into the section title for each plugin"

function cfg2html_plugin {
        echo "Here you can add a shell script, all output to stdout will be added to the"
        echo "cfg2html output file."

		## do something useful....
        ## echo "The PID of this plugin run was " $$
}

