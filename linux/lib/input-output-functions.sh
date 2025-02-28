# shellcheck disable=SC2148,SC2154,SC2034
# @(#) $Id: input-output-functions.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
#     Further modified by Joe Wulf:  20200323@1655.
# -------------------------------------------------------------------------
# input-output-functions.sh
#

# keep PID of main process
MASTER_PID=$$
# USR1 is used to abort on errors, not using Print to always print to the original STDOUT, even if quiet
# To get the output in the log, we need to use Log - if it is defined at trap runtime. # added on 20250215 by edrulrd
# We also need to use single-quotes so the statement is not evaluated until it is run. # added on 20250215 by edrulrd
trap 'if ! type Log 2>/dev/null ; then genout=echo; else genout=Log; fi ; $genout "FATAL: Aborting due to an error, check ${ERROR_LOG} for details"' USR1 # modified on 20250215 by edrulrd

LF="
"

# Check if any of the binaries/aliases exist
function has_binary {
	for bin in "$@"; do
		if type "${bin}" 2>/dev/null; then
			return 0
		fi
	done
	return 1
}

function Error {
	# If first argument is numerical, use it as exit code
	if [ "$1" -eq "$1" ]; then
		EXIT_CODE=$1
		shift
	else
		EXIT_CODE=1
	fi
	VERBOSE=1
	LogPrint "ERROR: $*"
	kill -USR1 ${MASTER_PID} # make sure that Error exits the master process, even if called from child processes
	trap TERM # upon return from the USR1 trap, turn off the TERM trap defined in the master program # added on 20250215 by edrulrd
	kill -TERM ${MASTER_PID} # now end the program, now that it's no longer getting trapped # added on 20250215 by edrulrd
}

function StopIfError {
	# If return code is non-zero, bail out
	if (( $? != 0 )); then
		Error "$@"
	fi
}

function BugError {
	# If first argument is numerical, use it as exit code
	if [ "$1" -eq "$1" ]; then
		EXIT_CODE=$1
		shift
	else
		EXIT_CODE=1
	fi
	Error "${EXIT_CODE}" "BUG BUG BUG! " "$@" " # add missing EXIT_CODE # modified on 20250215 by edrulrd
=== Issue report ===
Please report this unexpected issue at: https://github.com/cfg2html/cfg2html/issues
Also include the relevant bits from ${ERROR_LOG}
===================="
}

function BugIfError {
	# If return code is non-zero, bail out
	if (( $? != 0 )); then
		BugError "$@"
	fi
}

function Debug {
	test "$DEBUG" && Log "$@"
}

function Print {
	test "$VERBOSE" && _echo "$*"
}

# print if there is an error
function PrintIfError {
	# If return code is non-zero, bail out
	if (( $? != 0 )); then
		Print "$@"
	fi
}

function Stamp {
	date +"%Y-%m-%d %H:%M:%S "
}

function Log {
	if test $# -gt 0 ; then
		echo "$(Stamp)$*"
	else
		echo "$(Stamp)$(cat)"
	fi >> "${ERROR_LOG}"
}

# log if there is an error
function LogIfError {
	# If return code is non-zero, bail out
	if (( $? != 0 )); then
		Log "$@"
	fi
}

function LogPrint {
	Log "$@"
	Print "$@"
}

# log/print if there is an error
function LogPrintIfError {
	# If return code is non-zero, bail out
	if (( $? != 0 )); then
		LogPrint "$@"
	fi
}

