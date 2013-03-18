#!/bin/sh
# ---------------------------------------------------------------------------
# custom example plugin, provided by Andre Naumann, 25. August 2009
# @(#) $Id: templateexample_plugin.sh,v 5.12 2012-04-04 12:47:49 ralproth Exp $
# ---------------------------------------------------------------------------

CFG2HTML_PLUGINTITLE="Example Plugin: This will go into the section title for each plugin"

function cfg2html_plugin {
        echo "Here you can add a shell script, all output to stdout will be added to the"
        echo "cfg2html output file."

		## do something useful....
        ## echo "The PID of this plugin run was " $$
}

