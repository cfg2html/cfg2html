# input-output-functions.sh
#

# keep PID of main process
MASTER_PID=$$
# USR1 is used to abort on errors, not using Print to always print to the original STDOUT, even if quiet
trap "echo 'Aborting due to an error, check $ERROR_FILE for details' ; kill $MASTER_PID" USR1

LF="
"

# Check if any of the binaries/aliases exist
function has_binary {
	for bin in $@; do
		if type $bin 2>/dev/null; then
			return 0
		fi
	done
	return 1
}

function Error {
	# If first argument is numerical, use it as exit code
	if [ $1 -eq $1 ]; then
		EXIT_CODE=$1
		shift
	else
		EXIT_CODE=1
	fi
	VERBOSE=1
	LogPrint "ERROR: $*"
	kill -USR1 $MASTER_PID # make sure that Error exits the master process, even if called from child processes
}

function StopIfError {
	# If return code is non-zero, bail out
	if (( $? != 0 )); then
		Error "$@"
	fi
}

function BugError {
	# If first argument is numerical, use it as exit code
	if [ $1 -eq $1 ]; then
		EXIT_CODE=$1
		shift
	else
		EXIT_CODE=1
	fi
	Error "BUG BUG BUG! " "$@" "
=== Issue report ===
Please report this unexpected issue at: https://github.com/cfg2html/cfg2html/issues
Also include the relevant bits from $LOGFILE
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
	fi >> $ERROR_FILE
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

