#!/bin/bash
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
# last modified		20130708
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

function checkoperatingsystem {
	# determine system type
        if [[ $(uname -a | grep -E $1) ]]; then
		echo "[$(date --rfc-3339=seconds)] $(uname -a)"
		echo "[$(date --rfc-3339=seconds)] This operating system is supported"
        else
                echo "[$(date --rfc-3339=seconds)] $(uname -a)"
                echo "[$(date --rfc-3339=seconds)] This operating system is NOT supported"
                exit 1
        fi
}

function checkdependencies {
	# Check dependencies
	# Source: http://www.mirkopagliai.it/bash-scripting-check-for-and-install-missing-dependencies/

	IFS=' ' read -a DEPENDENCIES <<< "${1}"

	# What dependencies are missing?
	PKGSTOINSTALL=""
	for (( i=0; i<${tLen=${#DEPENDENCIES[@]}}; i++ )); do
		# Debian, Ubuntu and derivatives (with dpkg)
			if which dpkg &> /dev/null; then
			if [[ ! $(dpkg -l | grep -w "ii  ${DEPENDENCIES[$i]} ") ]]; then
				PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
			fi
		# OpenSuse, Mandriva, Fedora, CentOs, ecc. (with rpm)
		elif which rpm &> /dev/null; then
			if [[ ! $(rpm -qa | grep ${DEPENDENCIES[$i]}) ]]; then
				PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
			fi
		# ArchLinux (with pacman)
		elif which pacman &> /dev/null; then
			if [[ ! $(pacman -Qqe | grep "${DEPENDENCIES[$i]}") ]]; then
				PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
			fi
		# If it's impossible to determine if there are missing dependencies, mark all as missing
		else
			PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
		fi
	done

	# If some dependencies are missing, asks if user wants to install
	if [ "$PKGSTOINSTALL" != "" ]; then
		echo -n "[$(date --rfc-3339=seconds)] Some dependencies are missing. Want to install them? (Y/n): "
		read SURE
		# If user want to install missing dependencies
		if [[ $SURE = "Y" || $SURE = "y" || $SURE = "" ]]; then
			# Debian, Ubuntu and derivatives (with apt-get)
			if which apt-get &> /dev/null; then
				apt-get install $PKGSTOINSTALL
			# OpenSuse (with zypper)
			elif which zypper &> /dev/null; then
				zypper in $PKGSTOINSTALL
			# Mandriva (with urpmi)
			elif which urpmi &> /dev/null; then
				urpmi $PKGSTOINSTALL
			# Fedora and CentOS (with yum)
			elif which yum &> /dev/null; then
				yum install $PKGSTOINSTALL
			# ArchLinux (with pacman)
			elif which pacman &> /dev/null; then
				pacman -Sy $PKGSTOINSTALL
			# Else, if no package manager has been founded
			else
				# Set $NOPKGMANAGER
				NOPKGMANAGER=TRUE
				echo "[$(date --rfc-3339=seconds)] ERROR: impossible to found a package manager in your sistem. Please, install manually ${DEPENDENCIES[*]}."
			fi
			# Check if installation is successful
			if [[ $? -eq 0 && ! -z $NOPKGMANAGER ]] ; then
				echo "[$(date --rfc-3339=seconds)] All dependencies are satisfied."
			# Else, if installation isn't successful
			else
				echo "[$(date --rfc-3339=seconds)] ERROR: impossible to install some missing dependencies. Please, install manually ${DEPENDENCIES[*]}."
			fi
		# Else, if user don't want to install missing dependencies
		else
			echo "[$(date --rfc-3339=seconds)] WARNING: Some dependencies may be missing. So, please, install manually ${DEPENDENCIES[*]}."
		fi
	fi
}

# MAIN SCRIPT ----------------------------------------------------------------
# user must be sudo
if [[ $EUID -ne 0 ]]; then
   echo "[$(date --rfc-3339=seconds)] This script must be run as root" 1>&2
   exit 1
fi

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

checkoperatingsystem "Ubuntu|Debian|Linux"	#Ubuntu, Debian, Linux (CentOS)
checkdependencies "whiptail dialog"

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
			dialog --title "${SCRIPTS_FOLDER}/${MENUITEM} completed." --msgbox "[$(date --rfc-3339=seconds)]\n\n${SCRIPTS_FOLDER}/${MENUITEM} completed.\n\nPress OK to return to the main menu..." 20 78
#			echo "[$(date --rfc-3339=seconds)] ${SCRIPTS_FOLDER}/${MENUITEM} completed"
#			read -sn 1 -p "Press any key to return to the main menu..."
			;;
	esac
done
exit 0
