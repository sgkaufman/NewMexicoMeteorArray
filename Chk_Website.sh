#!/bin/bash
#
# Chk_Website.sh 31-Jul 2022, 1551 bytes

# added (Buster): sudo nano /etc/xdg/lxsession/LXDE-pi/autostart
# sleep 2
# @lxterminal -e ""$HOME"/source/RMS/Chk_Website.sh"
#
# var=$(printf "FORMAT" var1)

cd $HOME/RMS_data

timenow=$(date +%m/%d_%T)

echo "Press [CTRL+C] to stop monitoring complex.org/~gnto status..."
env printf "%s Station has rebooted\n" "$timenow"
env printf "%s Station has rebooted\n" "$timenow"  >> Web_Status.txt
env sleep 60

while :
do
	timenow=$(date +%m/%d_%T)

	status=$( curl -IL "complex.org/~gnto" 2>&1 | awk '/HTTP\// {print $2}' )
	if [ -z "$status" ] ; then
	    	web="dn"
	else
	    if [[ $status == *"301"* ]] ; then
		web="^"
	    else
		web="dn"
	    fi
	fi

	ping -q -c 1 10.8.0.61 > /dev/null
	if [ $? -eq 1 ] ; then
	    server="dn"
	else
	    server="^"
	fi

	if [ $web = "dn" ]  && [ $server = "dn" ] ; then
	    if ping -q -c 1 google.com > /dev/null ; then
		env printf "%s  web: %s  server: %s\n" "$timenow" $web $server
		env printf "%s  web: %s  server: %s\n" "$timenow" $web $server >> Web_Status.txt
	    else
		env printf "%s  Local Internet connection is down!\n" "$timenow"
		env printf "%s  Local Internet connection is down!\n" "$timenow" >> Web_Status.txt
	    fi
	else
	    if [ $web = "dn" ]  || [ $server = "dn" ] ; then
		env printf "%s  web: %s  server: %s\n" "$timenow" $web $server
		env printf "%s  web: %s  server: %s\n" "$timenow" $web $server >> Web_Status.txt
	    else
		env printf "%s  web: %s  server: %s\n" "$timenow" $web $server
	    fi
	fi

	env sleep 900
done
