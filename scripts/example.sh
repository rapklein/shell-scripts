#!/bin/bash
# ----------------------------------------------------------------------------
#       Copyright 2013 rapha@iworkspace.org
#
#       Licensed under the Apache License, Version 2.0 (the "License");
#       you may not use this file except in compliance with the License.
#       You may obtain a copy of the License at
#
#               http://www.apache.org/licenses/LICENSE-2.0
#
#       Unless required by applicable law or agreed to in writing, software
#       distributed under the License is distributed on an "AS IS" BASIS,
#       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#       See the License for the specific language governing permissions and
#       limitations under the License.
# ----------------------------------------------------------------------------
#
#       Copyright (c) 2013 rapha@iworkspace.org.  All rights reserved.
#
# title                 Example Script for EDCS
# description           This is an example frame for a sub-script for usage
#			under EDCS
# author                rapha@iworkspace.org
# date                  20130612
# last modified         20130707
# version               0.1
# usage                 Usually via EDCS: 'bash edcs.sh', or direcly via
#			'bash example.sh'
# notes
# ----------------------------------------------------------------------------

# VARIABLES ------------------------------------------------------------------
TITLE="Example"
DESCRIPTION="Only an example script"

# LOCAL FAILSAFE CONFIGURATION -----------------------------------------------
# This is allows this script to run separately, without the need for edcs.sh.
# It define some variables if this script is run without edcs.sh and the
# global variables are not available. Usually you should not make any changes
# here, but in edcs instead.
: "${TEXT_EDITOR:=nano}"

# FUNCTIONS ------------------------------------------------------------------


# MANAGE ARGUMENTS -----------------------------------------------------------
while getopts "td" opt; do	#allowed arguments and options
	case $opt in
	d)
		echo $DESCRIPTION
		exit 0
		;;
        t)
                echo $TITLE >&2
                exit 0
                ;;

	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;
	esac
done

# MAIN SCRIPT ----------------------------------------------------------------

echo "[$(date --rfc-3339=seconds)] Running the script"

#Exit the script w/o error code, if it was not called via edcs.sh
if [ -z "${SCRIPTS_FOLDER}" ]; then
	exit 0
fi
