# cfg2html - HTML function library - Linux part
# @(#) $Id: html-functions.sh,v 6.19 2020/06/17 21:24:05 ralph Exp $
#     Further modified by Joe Wulf:  20200323@1021.
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4
# coding: utf-8 -*-  Ralph Roth


function open_html {
    UNAMEA=$(uname -a)
    # [20200316] {jcw} Enhanced html page functions.
    cat >${HTML_OUTFILE} <<-EOF

	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
	<HTML> <HEAD>
	<META NAME="GENERATOR" CONTENT="Selfmade-${VERSION}">
	<META NAME="AUTHOR" CONTENT="Ralph Roth, Gratien D'haese, Michael Meifert, Jeroen Kleen">
	<META NAME="Modifications by:" CONTENT="Joe Wulf">

	<META NAME="CHANGED" CONTENT="`id;date` ">
	<META NAME="DESCRIPTION" CONTENT="Config to HTML (cfg2html for Linux)">
	<META NAME="subject" CONTENT="${VERSION} on ${RECHNER} by $MAILTO and ${MAILTORALPH}">
	<style type="text/css">
	/* (c) 2001- 2020 by ROSE SWE, Ralph Roth - http://rose.rult.at
	* CSS for cfg2html.sh, 12.04.2001, initial creation
	*/

	Pre     {Font-Family: Courier-New, Courier;Font-Size: 10pt}
	BODY        {FONT-FAMILY: Arial, Verdana, Helvetica, Sans-serif; FONT-SIZE: 12pt;}
	A       {FONT-FAMILY: Arial, Verdana, Helvetica, Sans-serif}
	A:link      {text-decoration: none}
	A:visited   {text-decoration: none}
	A:hover     {text-decoration: underline}
	A:active    {color: red; text-decoration: none}

	H1      {FONT-FAMILY: Arial, Verdana, Helvetica, Sans-serif;FONT-SIZE: 20pt}
	H2      {FONT-FAMILY: Arial, Verdana, Helvetica, Sans-serif;FONT-SIZE: 14pt}
	H3      {FONT-FAMILY: Arial, Verdana, Helvetica, Sans-serif;FONT-SIZE: 12pt}
	DIV, P, OL, UL, SPAN, TD
	{FONT-FAMILY: Arial, Verdana, Helvetica, Sans-serif;FONT-SIZE: 11pt}

	</style>

	<TITLE>${RECHNER} - System Documentation - ${VERSION}</TITLE>
	</HEAD><BODY>
	<BODY LINK="#0000ff" VLINK="#800080" BACKGROUND="cfg2html_back.jpg">
	<H1><CENTER><FONT COLOR=blue>
	<P><hr><B>${RECHNER} - System Documentation</P></H1>
	<hr><FONT COLOR=blue><small><center>Created ${DATEFULL} by ${PROGRAM} ${VERSION} ... Customized (v:${CustomVer})</font></center></B><P>
	<center>${UNAMEA}</center>
	</small>

	<HR><H1>Contents</font></H1>

	EOF

    (line
      echo
      _banner ${RECHNER}
      #echo ${RECHNER}
      echo
    line) > ${TEXT_OUTFILE}
    _echo  "\n" >> ${TEXT_OUTFILE}
    _echo  "\n" > ${TEXT_OUTFILE_TEMP}
}

######################################################################
#  Increases the headling level
######################################################################

function inc_heading_level {
    HEADL=HEADL+1
    # echo -e "<UL>\n" >> ${HTML_OUTFILE}
    _echo "<UL type='square'>\n" >> ${HTML_OUTFILE}
}

######################################################################
#  Decreases the heading level
######################################################################

function dec_heading_level {
    HEADL=HEADL-1
    _echo "</UL>" >> ${HTML_OUTFILE}
}

######################################################################
#  Creates an own paragraph, $1 = heading
######################################################################

# [20200310] {jcw} added the reserved word 'function' for consistency.
function paragraph() {
    if [ "${HEADL}" -eq 1 ] ; then
        _echo "<HR>" >> ${HTML_OUTFILE_TEMP}
    fi

    echo "<A NAME=\"$1\">" >> ${HTML_OUTFILE_TEMP}
    echo "<A HREF=\"#Inhalt-$1\"><H${HEADL}> $1 </H${HEADL}></A><P>" >> ${HTML_OUTFILE_TEMP}

    # commented to eliminate the need of the gif
    #echo "<IMG SRC="profbull.gif" WIDTH=14 HEIGHT=14>" >> ${HTML_OUTFILE}
    echo "<A NAME=\"Inhalt-$1\"></A><A HREF=\"#$1\">$1</A>" >> ${HTML_OUTFILE}
    _echo "\nCollecting: " $1 " .\c"
    echo "    $1 ---- " >> ${TEXT_OUTFILE}
}

function exec_command {

    # Start elpased time and show command if -T set
    SECONDS=0

    [[ "${CFG_TRACETIME}" = "no" ]] && _echo ".\c"  # fails under Ubuntu/Linit Mint based systems!?

    _echo "\n---=[ $2 ]=----------------------------------------------------------------" | cut -c1-74 >> ${TEXT_OUTFILE_TEMP}
    echo "       - $2" >> ${TEXT_OUTFILE}
    ######the working horse##########
    TMP_EXEC_COMMAND_ERR=/tmp/exec_cmd.tmp.$$
    ## Modified 1/13/05 by marc.korte@oracle.com, Marc Korte, TEKsystems (150 -> 250)
    ## Do not cut off output from very wide commands which are  over 250 characters wide, but instead continue the output onto the next line # added on 202040119 by edrulrd 
    if [ ${CFG_TEXTWIDTH} -le  350 ] # check if the line length value defaulted to, or was specified to be, less than 350.  This will  handle commands with very wide output # added on 20240119 by edrulrd
    then # show command output with at least 350 characters (instead of 250) before wrapping to the next line # added on 20240119 by edrulrd
       EXECRES=$(eval $1 2> $TMP_EXEC_COMMAND_ERR | expand | fold -s -w 350)  # wrap extra long lines instead of cutting them off # modified 20240119 by edrulrd
    else
       EXECRES=$(eval $1 2> $TMP_EXEC_COMMAND_ERR | expand | fold -s -w ${CFG_TEXTWIDTH})  # wrap extra long lines using the desired line width # modified 20240119 by edrulrd
    fi


    ########### test it ############
    # Gert.Leerdam@getronics.com
    # Convert illegal characters for HTML into escaped ones.
    #CONVSTR='
    #s/</\&lt;/g
    #s/>/\&gt;/g
    #s/\\/\&#92;/g
    #'
    #EXECRES=$(eval $1 2> $TMP_EXEC_COMMAND_ERR | expand | cut -c 1-150 | sed +"$CONVSTR")

    if [ -z "$EXECRES" ]
    then
        EXECRES="n/a or not configured"
    fi
    if [ -s $TMP_EXEC_COMMAND_ERR ]
    then
        echo "stderr output from \"$1\":" >> $ERROR_LOG
        cat $TMP_EXEC_COMMAND_ERR | sed 's/^/    /' >> $ERROR_LOG
    fi
    rm -f $TMP_EXEC_COMMAND_ERR

    #### new ###  #  13.08.2007, 13:28 modified by Ralph Roth
    if [ "$CFG_STINLINE" = "no" ]
    then
        ## screen tips like cfg2html 1.20 when dragging mouse over link?
        _echo "<A NAME=\"$2\"></A> <H${HEADL}><A HREF=\"#Inhalt-$2\" title=\"$1\"> $2 </A></H${HEADL}>" >>${HTML_OUTFILE_TEMP} #orig screen tips by Ralph
    else
        ## or more netscape friendly inline?
        _echo "<A NAME=\"$2\"></A> <A HREF=\"#Inhalt-$2\"><H${HEADL}> $2 </H${HEADL}></A>" >>${HTML_OUTFILE_TEMP}

        if [ "X$1" = "X$2" ]
            then    : #no need to duplicate, do nothing
        else
                echo "<h6>$1</h6>">>${HTML_OUTFILE_TEMP}
        fi
    fi      # screen tips inline???

    ###  Put the result out in proportional font
    _echo "<PRE>$EXECRES</PRE>"  >>${HTML_OUTFILE_TEMP}

    _echo "<LI><A NAME=\"Inhalt-$2\"></A><A HREF=\"#$2\" title=\"$1\">$2</A>" >> ${HTML_OUTFILE}
    echo "$EXECRES" >> ${TEXT_OUTFILE_TEMP}

    # Show each exec_command and elapsed secs
    if [[ "${CFG_TRACETIME}" = "yes" ]]; then
        SECS=$SECONDS
        Log "${SECS} secs: $(echo $1 | cut -c-79)"
        echo "${SECS} secs: $(echo $1 | cut -c-79)\n" >> ${TEXT_OUTFILE_TEMP}
        echo "<h6>${SECS} secs: $(echo $1 | cut -c-79)</h6>" >> ${HTML_OUTFILE_TEMP}
    fi
}

################# adds a text to the output files, rar, 25.04.99 ##########

function AddText {

    echo "<p>$*</p>" >> ${HTML_OUTFILE_TEMP}
    _echo "$*\n" >> ${TEXT_OUTFILE_TEMP}
}

function close_html {

    echo "<hr>" >> ${HTML_OUTFILE}
    _echo "</P><P>\n<hr><FONT COLOR=blue>Created "${DATEFULL}" with " ${PROGRAM} ${VERSION} "</font>" >> ${HTML_OUTFILE_TEMP}
    _echo "</P><P>\n<FONT COLOR=blue>Copyright and maintained by <A HREF="mailto:${MAILTORALPH}?subject=${VERSION}_">Ralph Roth, ROSE SWE, </A></P></font>" >> ${HTML_OUTFILE_TEMP}
    _echo "<hr><center> <A HREF="http://www.cfg2html.com">[ Download cfg2html from external home page ]</b></A></center></P><hr></BODY></HTML>\n" >> ${HTML_OUTFILE_TEMP}
    cat ${HTML_OUTFILE_TEMP} >>${HTML_OUTFILE}
    cat ${TEXT_OUTFILE_TEMP} >> ${TEXT_OUTFILE}
    rm ${HTML_OUTFILE_TEMP} ${TEXT_OUTFILE_TEMP}
    _echo  "\n\nCreated ${DATEFULL} by ${PROGRAM} ${VERSION}" >> ${TEXT_OUTFILE}
    _echo  "(c) 1998- 2020 by ROSE SWE, Ralph Roth and others" >> ${TEXT_OUTFILE}
}

## end ##
