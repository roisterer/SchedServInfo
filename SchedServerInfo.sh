# Comments: This script will enable a user with sudo privileges to arrange a report offering various bits of 
#           information about a server or other host, and have that information emailed at regular intervals 
#           to the root user of the server or other host for review.
#
#           A main strength of this script is it's modularity.  By following a simple syntax, for example, 
#			'sudo echo "cat /proc/cpuinfo >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo' and then adding 
#			the corresponding menu entries, new functions can be added for customization to specific needs.

# Author Christopher George Bollinger

#!/bin/bash
clear

# Variable Declaration

Count=1

# Function Library
# Intro & Info
IntroInfo()
{ 
	echo ""
	echo ""
echo " __          __  _                            "
echo " \ \        / / | |                           "
echo "  \ \  /\  / /__| | ___ ___  _ __ ___   ___   "
echo "   \ \/  \/ / _ \ |/ __/ _ \|  _   _ \ / _ \  "
echo "    \  /\  /  __/ | (_| (_) | | | | | |  __/  "
echo "     \/  \/ \___|_|\___\___/|_| |_| |_|\___|  "

	echo ""
	echo "**This script requires sudo, or, root privileges.**"                                            
    echo "This script will enable you to create a system information report to be mailed to the Root user at regular, chosen intervals."
    echo ""
    echo "This first menu enables you to choose the report sections you would like in the final report, and the order in which they will be presented."
	
}
# First Menu
MenuMain()
{
while :
do
echo ""

echo "1.  CPU HW Information Report           8.  Ports Open Report"
echo "2.  CPU Usage Statistics Report         9.  NIC Information Report"
echo "3.  Top CPU Users by Process            10.  Ping LocalHost and Default Gateway Report"
echo "4.  Virtual Memory Statistics Report    11.  SELinux Enforcing Status Report"
echo "5.  RAM Information Report              12.  IPtables Status Report"
echo "6.  Hard Disk Space Information         13.  Done Selecting Reports"
echo "7.  System Uptime Report"
echo ""
echo ""
echo "Q/q.   Quit with no Reports Generated"
read -p "Enter Selection (this will be section $Count of the Report):   " ans

case $ans in
	1) 
		clear
		echo ""
		echo ""
		CpuInfo
		;;
	2)
		clear
		echo ""
		echo ""
		CPUStats
		;;
	3)
		clear
		echo ""
		echo ""
		CpuProcs
		;;
	4)
		clear
		echo ""
		echo ""
		VirtMem
		;;
	5)
		clear
		echo ""
		echo ""
		MemInfo
		;;
	6)
		clear
		echo ""
		echo ""
		DiskInfo
		;;
	7)
		clear
		echo ""
		echo ""
		UpTime
		;;
	8)
		clear
		echo ""
		echo ""
		OpenPorts
		;;
	9)
		clear
		echo ""
		echo ""
		IfaceInfo
		;;
	10)
		clear
		echo ""
		echo ""
		PingTest
		;;
	11)
		clear
		echo ""
		echo ""
		CheckSELinux
		;;
	12)
		clear
		echo ""
		echo ""
		IpTablesCheck
		;;
	13)
		clear
		echo ""
		echo ""
		break
		;;
	Q|q)
		rm -f /usr/bin/ServerInfo
		rm -f /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfo.report
		exit
		;;
	*)
		clear
		echo ""
		echo ""
		echo "Invalid Response"
		clear
		;;	

esac
done
	
}
# --HostInfo Section

CpuInfo ()
{
	sudo echo "cat /proc/cpuinfo >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}

CPUStats ()
{
	rpm -q sysstat 2> /dev/null
	if [[ $? = 0 ]] 2> /dev/null
	then
		echo 'mpstat -P ALL >> /tmp/ServerInfo.report' >> /usr/bin/ServerInfo 2> /dev/null && Count=$((Count+1))
	else
		read -p "The required tool, mpstat (part of the sysstat suite), was not found on the system.  Do you want to install it? [Y/n]: " YorN
		case $YorN in  
		Y|y)  
			sudo yum install sysstat  2> /dev/null ||
			sudo apt-get install sysstat 2> /dev/null
			echo 'mpstat -P ALL >> /tmp/ServerInfo.report' >> /usr/bin/ServerInfo 2> /dev/null && Count=$((Count+1))
			clear
			;;
		N|n)
			;;
		*)  
			echo "Invalid input, exiting to the main menu." 
			;;
		esac
	fi
}

CpuProcs ()
{
	sudo echo "ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10 >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}

VirtMem ()
{
	sudo echo "vmstat >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}
MemInfo ()
{
	sudo echo "cat /proc/meminfo >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}

DiskInfo ()
{
	sudo echo "df -hT >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}

UpTime ()
{
	echo "uptime >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}

# --NetworkInfo Section

OpenPorts()
{
	rpm -q nmap 2> /dev/null
	if [[ $? = 0 ]] 2> /dev/null
	then
		echo 'nmap -sV 127.0.0.1 >> /tmp/ServerInfo.report' >> /usr/bin/ServerInfo 2> /dev/null && Count=$((Count+1))
	else
		read -p "The required tool, nmap, was not found on the system.  Do you want to install it? [Y/n]: " YorN
		case $YorN in  
		Y|y)  
			sudo yum install nmap  2> /dev/null ||
			sudo apt-get install nmap 2> /dev/null
			echo 'nmap -sV 127.0.0.1 >> /tmp/ServerInfo.report' >> /usr/bin/ServerInfo 2> /dev/null && Count=$((Count+1))
			clear
			;;
		N|n)
			;;
		*)  
			echo "Invalid input, exiting to the main menu." 
			;;
		esac
	fi
}
IfaceInfo ()
{
	echo "netstat --interfaces >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}	

PingTest ()
{
	echo "ping -c 5 127.0.0.1 >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	IP=$(/sbin/ip route | awk '/default/ { print $3 }')
	echo "ping -c 5 $IP >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}

#  Security Section

CheckSELinux ()
{
	echo "getenforce >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}

IpTablesCheck ()
{
	echo "iptables -L >> /tmp/ServerInfo.report" >> /usr/bin/ServerInfo
	Count=$((Count+1))
}

IntroInfo
MenuMain

	while :
	do
	echo "Now that you are finished selecting the order of the sections of your report, how often would you like this information to be sent for review to the root user?"
	echo ""
	echo ""
	echo "1. Every 5 minutes"
	echo "2. Every 15 minutes"
	echo "3. Every hour"
	echo "4. Every 3 hours"
	echo "5. Every 6 hours"
	echo "6. Every 12 hours"
	echo "7. Every day at Midnight"
	echo "8. Every other day at Midnight"
	echo "9. Once a week (Saturday at Midnight)"
	echo "10. Twice a month (the fifteenth and the twenty-eight)"
	echo "11. Make your own (prior knowledge of crontab required!)"
	read -p "Enter selection: " CronAns
	
	case $CronAns in
	1)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '*/5 * * * * /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		break
		;;
	
	2)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '*/5 * * * * /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
		
	3)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '0 * * * * /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
		
	4)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '0 */3 * * * /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
	5)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '0 */6 * * * /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
	6)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '0 */12 * * * /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
	7)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '0 0 * * * /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
	8)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '0 0 * * 2 /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
	9)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '0 0 * * 6 /usr/bin/ServerInfo'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
	10)
		clear
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		echo >> /tmp/ServerInfoCron.txt '0 0 15 * * /usr/bin/ServerInfot'
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
	
	11)
		clear
		echo "Are you certain you know what you are doing?  To exit, use CTRL-x"
		echo "cat /tmp/ServerInfo.report | mail -s 'Server Info Report' root" >> /usr/bin/ServerInfo 
		chown root /usr/bin/ServerInfo
		chmod 700 /usr/bin/ServerInfo
		nano /tmp/ServerInfoCron.txt
		sudo crontab /tmp/ServerInfoCron.txt
		rm -f /tmp/ServerInfoCron.txt
		echo "All Finished!"
		sleep 1s
		exit
		;;
	*)
		clear
		echo "Invalid Input, Please Choose a number."
		;;
	esac
	done
	exit
		


