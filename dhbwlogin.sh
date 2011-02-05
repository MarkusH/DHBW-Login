#!/bin/bash

###########################################################################
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
#  Important: Start this script every time with the full/absolute
#  path to this file (e.g. "/home/username/DHBW-Login/dhbwlogin.sh").
#
#  This script uses an infinite loop. It checks in an interval as
#  specified in "sleeptime" whether you are logged into the DHBW
#  WLAN. To check this it sends pings to the internet address as
#  specified in "pingaddress".
#
#  If you are not logged in the script sends an request to the
#  login server with your userdata as specified in "username" and
#  "password"
#
#  To run this script you need "wget", "ping", "grep" and "zenity"
#  The first three are standard packages in common Linux distributions
#  so they should be installed. "zenity" is a programm for Gnome
#  desktop environment. Please ensure it is installed.
#
###########################################################################
#
#  With these parameters you can change the behaviour of the script:
#
#  Your username for DHBWWebAuth:
username=xxxxx
#
#  Your password (because it is stored in plain text
#  never use it for other purposes):
password=xxxxx
#
#  The internet address you want to check your login status with:
pingaddress=google.com
#
#  How long do you want to wait between login status checks?
#  (Write s for seconds, m for minutes and h for hours.)
sleeptime=15s
#
#  Where shall the log be stored?
logfile="`dirname \"$0\"`/dhbwlogin.log"
#
###########################################################################
#
#  The script:

workdir="`dirname \"$0\"`";
echo "DHBW Autologin Script";
echo "You want to log in as $username.";
echo "I'll check in intervals of $sleeptime for connections to $pingaddress.";

#Create icon in Gnome panel
exec 3> >(zenity --notification --window-icon=$workdir/network-offline.png --listen);
echo "tooltip:DHBW-Autologin – noch kein Verbindungsversuch unternommen" >&3;

echo -e "---\n`date`: Start script" >> $logfile;
sleep 2;
flag=-1;

#Changes the tray icon to visualize a successfull connection
setConnected () {
	echo "icon:$workdir/network-transmit-receive.png" >&3;
	echo "tooltip:DHBW-Autologin – verbunden" >&3;
	if [ $flag -eq 0 -o $flag -eq -1 ]
	    then
		flag=1;
		echo "message:Im DHBW-WLAN angemeldet" >&3;
		echo "`date`: Could connect to DHBWWebAuth." >> $logfile;
	fi
}
#Changes the tray icon to visualize a not existing connection
setDisconnected () {
	echo "icon:$workdir/network-error.png" >&3;
	echo "tooltip:DHBW-Autologin – nicht verbunden" >&3;
	if [ $flag -eq 1 -o $flag -eq -1 ]
	    then
		flag=0;
		echo "message:Konnte nicht mit DHBW-WLAN verbinden." >&3;
	fi
}

while(true)
do
	#Check if the current wlan is the DHBW WLAN; if not try again later
	if [ -z "`iwgetid -r`" -o "`iwgetid -r`" != "BaWebAuth" ]
	    then
		setDisconnected;
		echo "`date`: You're not connected to BaWebAuth.";
		sleep $sleeptime;
		continue;
	fi
	#Check if we can ping to a server outside the DHBW LAN
	ping -c 1 $pingaddress > /dev/null 2>&1;
	if [ $? -eq 0 ]
	    then
		#We are logged in
		setConnected;
		echo "`date`: You're logged in.";
	    else
		#We are not logged in
		echo "`date`: You're not logged in."
		echo "`date`: Trying to log in.";
		#Send login data to login server
		wget -T 5 -t 1 -O /dev/null --post-data 'buttonClicked=4&redirect_url=&err_flag=&info_flag=&info_msg=&username='$username'&password='$password'&Submit=Anmelden' "https://dhbwwebauth.dhbw-mannheim.de/login.html" > /dev/null 2>&1;
		if [ $? -eq 0 ]
		    then
			#We could connect:
			echo "`date`: Successfully logged in.";
			setConnected;
		    else
			#We could not connect
			echo "`date`: Failed to log in. Try again in $sleeptime.";
			setDisconnected;
		fi
	fi
	sleep $sleeptime;
done
