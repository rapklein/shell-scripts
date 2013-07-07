#!/bin/sh
# ----------------------------------------------------------------------------
#	Copyright 2013 rapha@iworkspace.org
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
# ----------------------------------------------------------------------------
#
#	Copyright (c) 2013 rapha@iworkspace.org.  All rights reserved.
#
# title			EDCS - Easy Deployment and Configuration Script
# description		Makes deployment and configuration of hosts nice and
#			easy. This script shows an overview of scripts
#			available and calls the subscript chosen. 
# author		rapha@iworkspace.org
# date			20130612
# last modified		20130707
# version		0.1
# usage			bash edcs.sh
# notes	
# ----------------------------------------------------------------------------

# GLOBAL CONFIGURATION -------------------------------------------------------
# These variables are true for all subscripts in SCRIPTS_FOLDER
SCRIPTS_FOLDER="scripts"	#Default: "scripts"
TEXT_EDITOR="nano"		#Default: "nano"  e.g. vi, vim, nano ... 

# FUNCTIONS ------------------------------------------------------------------

# PREREQUISITES --------------------------------------------------------------
# Make sure we are root

# Check dependencies

# MAIN SCRIPT ----------------------------------------------------------------
for f in $SCRIPTS_FOLDER/*.sh
do
	if [ -z "$(basename $f)" ]; then
		WHIPTAIL_ARGS=("${WHIPTAIL_ARGS[@]}" "-")
	else
		WHIPTAIL_ARGS=("${WHIPTAIL_ARGS[@]}" "$(basename $f)")
	fi
	if [ -z "$(bash $f -d)" ]; then
		WHIPTAIL_ARGS=("${WHIPTAIL_ARGS[@]}" "-")
	else
		WHIPTAIL_ARGS=("${WHIPTAIL_ARGS[@]}" "$(bash $f -d)")
	fi
done

while true
do
	clear
	# Display Main Menu
	MENUITEM=$(whiptail --title "EDCS - Easy Deployment and Configuration Script" --menu "Choose a script to execute" 20 78 10 "${WHIPTAIL_ARGS[@]}" "EXIT" "Leave this script" 2>&1 >/dev/tty)
	case $MENUITEM in
		EXIT)	echo "[$(date --rfc-3339=seconds)] Bye"
			exit
			;;
		*)	source "${SCRIPTS_FOLDER}/${MENUITEM}"
			echo "[$(date --rfc-3339=seconds)] ${SCRIPTS_FOLDER}/${MENUITEM} completed successfully"
			read -sn 1 -p "Press any key to return to the main menu..."
			;;
	esac
done
exit
