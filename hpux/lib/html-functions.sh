function open_html {
    # Header/begin of HTML file
    cat $PLUGINS/head01.html > $HTML_OUTFILE

    cat >> $HTML_OUTFILE <<-EOF

	<TITLE>${RECHNER} - Documentation - $VERSION</TITLE></HEAD>

	<BODY LINK=\"#0000ff\" VLINK=\"#800080\" BACKGROUND=\"cfg2html_back.jpg\"><center><hr>
	<FONT COLOR=blue>
	<br><h1><B>$RECHNER - HP-UX "$osrevdot" System Documentation</b><br></H1>

	<hr><small>Created $DATEFULL with $PROGRAM $VERSION<br>
	EOF

    cat $PLUGINS/head02.html >> $HTML_OUTFILE
    $PLUGINS/get_ministat.sh >> $HTML_OUTFILE
    AddText "Used command line was=$CFG_CMDLINE"
    cat $PLUGINS/head03.html >> $HTML_OUTFILE

    (echo ;line;banner $RECHNER;line) > $TEXT_OUTFILE
    echo "\n" >> $TEXT_OUTFILE
    echo "\n" > $TEXT_OUTFILE_TEMP
}

function inc_heading_level {
    # Increases the heading level
    HEADL=HEADL+1
    echo "<UL type='square'>\n" >> $HTML_OUTFILE
}

function dec_heading_level {
    #  Decreases the heading level
    HEADL=HEADL-1
    echo "</UL>\n" >> $HTML_OUTFILE
}

function paragraph {
    #  Creates an own paragraph, $1 = heading
    if [ "$HEADL" -le 1 ] ; then
        echo "\n<HR>\n" >> $HTML_OUTFILE_TEMP
        HEADL=1
    fi
    echo "<A NAME=\"$1\"></A>" >> $HTML_OUTFILE_TEMP
    echo "<H${HEADL}><A HREF=\"#Inhalt-$1\"> $1 </A></H${HEADL}><P>" >> $HTML_OUTFILE_TEMP

    echo "<A NAME=\"Inhalt-$1\"></A><A HREF=\"#$1\">$1</A>" >> $HTML_OUTFILE
    #   echo "\nCollecting: " $1 " .\c"
    echo "\nCollecting:  $1 \c"

    [[ "$CFG_TRACETIME" = "no" ]] && echo ".\c" || echo
    echo "    $1 ---- " >> $TEXT_OUTFILE
}

function AddText {
    # adds a text to the output files
    echo "<p>$*</p>" >> $HTML_OUTFILE_TEMP
    echo "$*\n" >> $TEXT_OUTFILE_TEMP
}

function exec_command {
    # Start elpased time and show command if -T set
    SECONDS=0

    [[ "$CFG_TRACETIME" = "no" ]] && echo ".\c"

    echo "\n---=[ $2 ]=----------------------------------------------------------------" | cut -c1-78 >> $TEXT_OUTFILE_TEMP
    echo "       - $2" >> $TEXT_OUTFILE
    ######the working horse##########
    TMP_EXEC_COMMAND_ERR=/tmp/exec_cmd.tmp.$$
    EXECRES=`eval $1 2> $TMP_EXEC_COMMAND_ERR | expand | fold -w160`
    if [ -z "$EXECRES" ]; then
        EXECRES="n/a, error, no output or resource is not configured!"        #  23.11.2004, 17:45 modified by Ralph.Roth
    fi
    if [ -s $TMP_EXEC_COMMAND_ERR ]; then
        echo "stderr output from \"$1\":" >> $ERROR_LOG
        cat $TMP_EXEC_COMMAND_ERR | sed 's/^/    /' >> $ERROR_LOG
    fi
    rm -f $TMP_EXEC_COMMAND_ERR
    echo "\n" >> $HTML_OUTFILE_TEMP
    if [ "$CFG_STINLINE" = "no" ]; then
        ## screen tips like cfg2html 1.20 when dragging mouse over link?
        echo "<A NAME=\"$2\"></A> <H${HEADL}><A HREF=\"#Inhalt-$2\" title=\"$1\"> $2 </A></H${HEADL}>\n" >>$HTML_OUTFILE_TEMP
    else
	echo "<A NAME=\"$2\"></A> <A HREF=\"#Inhalt-$2\"><H${HEADL}> $2 </H${HEADL}></A>\n" >>$HTML_OUTFILE_TEMP

	if [ "X$1" = "X$2" ]; then
	    : #no need to duplicate, do nothing
        else
	    echo "<h6>$1</h6>">>$HTML_OUTFILE_TEMP
	fi

    fi

    echo "<PRE>$EXECRES</PRE>\n"  >>$HTML_OUTFILE_TEMP
    echo "<LI><A NAME=\"Inhalt-$2\"></A><A HREF=\"#$2\" title=\"$1\">$2</A>\n" >> $HTML_OUTFILE
    echo "\n$EXECRES\n" >> $TEXT_OUTFILE_TEMP

    # Show each exec_command and elapsed secs
    if [[ "$CFG_TRACETIME" = "yes" ]]; then 
	typeset -R3 SECS=$SECONDS
	#echo "$SECS secs: $(echo $1 | cut -c-79)"
	Log "$SECS secs: $(echo $1 | cut -c-79)"
	echo "$SECS secs: $(echo $1 | cut -c-79)\n" >> $TEXT_OUTFILE_TEMP
	echo "<h6>$SECS secs: $(echo $1 | cut -c-79)</h6>" >> $HTML_OUTFILE_TEMP
    fi
}

function close_html {
    #  end of the html document
    echo "\n<hr>\n" >> $HTML_OUTFILE
    echo "</P><P>\n<hr><FONT COLOR=blue><small>Created $DATEFULL with  $PROGRAM $VERSION (c) 1998-2023 by "  >> $HTML_OUTFILE_TEMP
    echo "<A HREF=\"mailto:cfg2html&#64;&#104;&#111;&#116;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109?subject=$VERSION_\">ROSE SWE</A></small></P></font>" >> $HTML_OUTFILE_TEMP
    echo "<center><A HREF=\"http://www.cfg2html.com\"><b>[ Download cfg2html collectors from the cfg2html home page ] </b></A></center></P><hr></BODY></HTML>\n" >> $HTML_OUTFILE_TEMP
    cat $HTML_OUTFILE_TEMP >>$HTML_OUTFILE
    cat $TEXT_OUTFILE_TEMP >> $TEXT_OUTFILE
    rm $HTML_OUTFILE_TEMP $TEXT_OUTFILE_TEMP
    echo "\n\nCreated $DATEFULL with $PROGRAM $VERSION (c) 1998-2023 by ROSE SWE\n" >> $TEXT_OUTFILE
}
