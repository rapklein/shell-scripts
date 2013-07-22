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
# title                 Project Open setup script for EDCS
# description           This script will setup Project-Open on CentOS / RHEL
#			version 6.4
# author                rapha@iworkspace.org
# date                  20130615
# last modified         20130707
# version               0.1
# usage                 Usually via EDCS: 'bash edcs.sh', or direcly via
#			'bash example.sh'
# notes
# ----------------------------------------------------------------------------

# VARIABLES ------------------------------------------------------------------
TITLE="Project Open Setup"
DESCRIPTION="Setup wizard for  ProjectOpen (CentOS 6.4)"
SHOWEXPLANATIONS=1

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
echo "[$(date --rfc-3339=seconds)] Beginn ProjectOpen (CentOS 6.4) Wizard"

dialog --title "ProjectOpen Install Wizard (CentOS 6.4)" --yesno "This wizard is meant for CentOS 6.4 and will guide you through the installation and setup.\n\nThis server should be a bare installation of CentOS 6.4 minimal (You should have used 'CentOS-6.4-x86_64-minimal.iso'.\n\nDo you want to continue?" 20 78
RESULT=$?
clear

if [ $RESULT = 0 ]
then
	# check dependencies
	if [ $SHOWEXPLANATIONS = 1 ]
	then
		dialog --title "Check dependencies" --msgbox "Necessary dependencies will be checked and you will be prompted to install them if necessary." 20 78
		clear
	fi
	checkdependencies "cvs wget gcc nano redhat-lsb libXaw expat expat-devel pango graphviz-devel ImageMagick libdbi-dbd-pgsql openldap-clients openldap-devel perl-YAML openoffice.org-impress openoffice.org-writer openoffice.org-headless postgresql postgresql-server postgresql-contrib postgresql-devel postgresql-docs"
	checkoperatingsystem "Linux"
	# Download Required Files
	if [ $SHOWEXPLANATIONS = 1 ]
	then
		dialog --title "Download Required Files" --msgbox "Some required files will be downloaded from sourceforge." 20 78
		clear
	fi
	wget http://sourceforge.net/projects/project-open/files/project-open/Support%20Files/aolserver451rc2-po2.nsreturnz.el6.i686.tgz -O /usr/src/aolserver451rc2-po2.nsreturnz.el6.i686.tgz
	wget http://sourceforge.net/projects/project-open/files/project-open/Support%20Files/aolserver451rc2-po2.nsreturnz.el6.x86_64.tgz -O /usr/src/aolserver451rc2-po2.nsreturnz.el6.x86_64.tgz
	wget http://sourceforge.net/projects/project-open/files/project-open/Support%20Files/web_projop-aux-files.4.0.4.0.0.tgz -O /usr/src/web_projop-aux-files.4.0.4.0.0.tgz
	wget http://sourceforge.net/projects/project-open/files/project-open/V4.0/project-open-Update-4.0.4.0.0.tgz -O /usr/src/project-open-Update-4.0.4.0.0.tgz
	if [ $SHOWEXPLANATIONS = 1 ]
	then
		dialog --title "Prerequisites" --msgbox "The installation will be prepared:\n\n * A new group will be created\n * A new user will be created\n * The downloads will be extracted\n * The ownership of the files will be amended" 20 78
		clear
	fi
	# create a group called "projop"
	groupadd projop
	# super-directory for all Web servers /web/ by default
	mkdir /web/
	# create user "projop" with home directory /web/projop
	useradd -d /web/projop -g projop projop
	cd /web/projop/
	# extract auxillary files
	tar xzf /usr/src/web_projop-aux-files.4.0.4.0.0.tgz
	# extract the ]po[ product source code + database dump
	tar xzf /usr/src/project-open-Update-4.0.4.0.0.tgz
	# set ownership to all files
	chown -R projop:projop /web/projop
	cd /usr/local
	# extract the AOLserver binary
	tar xzf /usr/src/aolserver451rc2-po2.nsreturnz.el6.x86_64.tgz
	# Initialize the database
	if [ $SHOWEXPLANATIONS = 1 ]
	then
		dialog --title "Database setup" --msgbox "The database will be initialized." 20 78
		clear
	fi
	/etc/init.d/postgresql initdb
	if [ $SHOWEXPLANATIONS = 1 ]
	then
		dialog --title "ProjectOpen Install Wizard (CentOS 6.4) - Postgres" --msgbox "Now please edit the file /var/lib/pgsql/data/postgresql.conf, search for the following parameters and set the values accordingly (don't forget to remove the comments):\n\n add_missing_from = on \n regex_flavor = extended \n default_with_oids = on" 20 78
		clear
	else
		echo -e "Now please edit the file /var/lib/pgsql/data/postgresql.conf, search for the following parameters and set the values accordingly (don't forget to remove the comments):\n\n add_missing_from = on \n regex_flavor = extended \n default_with_oids = on"
		read -p "Press [Enter] to continue..."
	fi
	${TEXT_EDITOR} "/var/lib/pgsql/data/postgresql.conf"
	/etc/init.d/postgresql start
	# database user "projop" with admin rights
	su - postgres -c "createuser -s projop"
	# new database
	su - projop -c "createdb -E utf8 -O projop projop"
	# enable the procedural language PlPg/SQL
	su - projop -c "createlang plpgsql projop"
	echo "[$(date --rfc-3339=seconds)] Please check that the database is working:"
	su - projop -c psql
	read -sn 1 -p "$(echo $'\n')[$(date --rfc-3339=seconds)] Press any key to continue..."
	su - projop -c "psql -f /web/projop/pg_dump.4.0.4.0.0.sql > import.log 2>&1"
	echo "[$(date --rfc-3339=seconds)] Please check that the database dump has loaded correctly:"
	su - projop -c "psql -c 'select count(*) from users'"
	read -sn 1 -p "$(echo $'\n')[$(date --rfc-3339=seconds)] The database should reply with \"196\". Press any key to continue..."
	if [ $SHOWEXPLANATIONS = 1 ]
	then
		dialog --title "ProjectOpen Install Wizard (CentOS 6.4) - Postgres" --msgbox "Please modify /web/projop/etc/config.tcl for the following parameters:\n\n set servername   \"<your_company> \]project-open\[ Server\"\n set homedir      /usr/local/aolserver451_rc2\n\nYou may modify 'httpport' as well." 20 78
		clear
	else
		echo -e "Please modify /web/projop/etc/config.tcl for the following parameters:\n\n set servername   \"<your_company> \]project-open\[ Server\"\n set homedir      /usr/local/aolserver451_rc2\n\nYou may modify 'httpport' as well."
		read -p "Press [Enter] to continue..."
	fi
	${TEXT_EDITOR} "/web/projop/etc/config.tcl"
	dialog --title "ProjectOpen Install Wizard (CentOS 6.4) - Firewall (iptables) setup" --yesno "This script can apply a default config for iptables that lets you access ]po[ and Webmin as well as ssh and ping the server.\n\nPlease note that this may limit availability of other services you may use, however it would increase security.\n\nDo you want to continue?" 20 78
	RESULT=$?
	clear
	if [ $RESULT = 0 ]
	then
		echo -e "# Firewall configuration written by system-config-firewall\n# Manual customization of this file is not recommended.\n*filter\n:FORWARD ACCEPT\n[0:0]\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n-A FORWARD -o eth0 -j LOG --log-level 7 --log-prefix BANDWIDTH_OUT:\n-A FORWARD -i eth0 -j\nLOG --log-level 7 --log-prefix BANDWIDTH_IN:\n-A OUTPUT -o eth0 -j LOG --log-level 7 --log-prefix BANDWIDTH_OUT:\n-A INPUT -i eth0 -j LOG\n--log-level 7 --log-prefix BANDWIDTH_IN:\n-A INPUT -p tcp -m state -m tcp --dport 10000 --state NEW -j ACCEPT\n# -A INPUT -p tcp -m state -m tcp\n--dport 10010 --state NEW -j ACCEPT\n# -A INPUT -p udp -m state -m udp --dport 10000 --state NEW -j ACCEPT\n-A INPUT -p tcp -m state -m tcp\n--dport 8000 --state NEW -j ACCEPT\n-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n-A INPUT -p icmp -j ACCEPT\n-A INPUT -i lo -j ACCEPT\n-A INPUT -p tcp -m state -m tcp --dport 22 --state NEW -j ACCEPT\n-A INPUT -j REJECT --reject-with icmp-host-prohibited\n-A FORWARD -j REJECT\n--reject-with icmp-host-prohibited\nCOMMIT" > /etc/sysconfig/iptables
		service iptables restart
	fi
fi


#Exit the script w/o error code, if it was not called via edcs.sh
if [ -z "${SCRIPTS_FOLDER}" ]; then
	exit 0
fi
