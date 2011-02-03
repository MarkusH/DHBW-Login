#!/bin/bash

##############################################################################
# This script makes a login at the DHBW WLAN more easy
# Copyright (C) 2011  Markus Holtermann
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
###########################################################################
#
#  This script uses an infinite loop. It checks in an interval as
#  specified in "sleeptime" whether you are logged in to the DHBW
#  WLAN. To check this it sends pings to the internet address as
#  specified in "pingaddress".
#
#  If you are not logged in the script sends an request to the
#  login server with your userdata as specified in "username" and
#  "password"
#
#  To run this script you need "wget", "ping" and "grep". These
#  are standard packages in common Linux distributions so they
#  should be installed.
#
###########################################################################
#
#  With these parameters you can change the behaviour of the script:
#
#  Your username for DHBWWebAuth:
username=xxx
#
#  Your password (because it is stored in plain text
#  never use it for other purposes):
password=xxx
#
#  The internet address you want to check your login status with:
pingaddress=google.com
#
#  How long do you want to wait between login status checks?
#  (Write s for seconds, m for minutes and h for hours.)
sleeptime=15s
#
###########################################################################
#
#  The script:

echo "DHBW Autologin Script"
echo "You want to log in as $username."
echo "I'll check in intervals of $sleeptime for connections to $pingaddress."

while [ "something" ]
do
	ping -c 1 $pingaddress > /dev/null 2>&1
	if [ $? -eq 0 ]
	    then
		echo "`date`: You're logged in."
	    else
		echo "`date`: You're not logged in."
		echo "`date`: Trying to log in."
		wget -T 5 -t 1 -O /dev/null --post-data 'buttonClicked=4&redirect_url=&err_flag=&info_flag=&info_msg=&username='$username'&password='$password'&Submit=Anmelden' "https://dhbwwebauth.dhbw-mannheim.de/login.html" > /dev/null 2>&1
		if [ $? -eq 0 ]
		    then
			echo "`date`: Successfully logged in."
		    else
			echo "`date`: Failed to log in. Try again in $sleeptime."
		fi
	fi
	sleep $sleeptime
done
