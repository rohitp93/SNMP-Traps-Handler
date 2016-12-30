										*****	README	*****

Assignment3
-----------

The objective of this assignment is to send SNMP traps to an Upper Level Manager(MoM). The system should listen to all traps received on UDP:50162 port
The traphandle has to send traps to MoM when a device reports Fail state(3) or when two or more devices reports Danger(2)states. The traps also have 
to be logged in a file containing status of agents(current and previous) and times(current and previous). 
The trap information is also presented through the web dashboard.

This document describes the information about the various files in this folder, modules/software needed and steps to run this assignment.

This folder consists of 5 files in total:
-----------------------------------------

1. trapdaemon.pl
2. traps.log
3. index.php
4. db.php
5. readme.txt

Software Requirements:
----------------------

1. Operating System: Ubuntu 14.04 LTS.

2. You need to install Apache server, MySQL and PHP.

3. Modules which are needed to be installed from CPAN are:
	 Data::Dumper
	 DBD::Mysql
	 DBI
	 Cwd
   	 Net::SNMP
             
4. Install packages from terminal (sudo apt-get install ____)
	snmp && snmpd

Steps to run this assignment:
-----------------------------
1. Modify the db.conf file in the root directory accordingly. The trapdaemon script will access the database mentioned in db.conf 
   and insert trap information such as FQDN, Current status, Current Time, Previous Status and Previous Time into the "Traps" table.

2. Now, open a web browser and type the following URL: (it is assumed that the working directory is in /var/www/html/)
   http://localhost/et2536-ropo15/assignment3/
   It will open index.php and show the dashboard containing Manager table and Traps table
   Enter the MoM device credentials in web frontend, it will be inserted into Manager table. The traps received by the system will be displayed
   in the Traps table.

2. Give the trap command:
   sudo snmptrap -v 1 -c public 127.0.0.1:50162 .1.3.6.1.4.1.41717.10 10.2.3.4 6 247 '' .1.3.6.1.4.1.41717.10.1 s "" .1.3.6.1.4.1.41717.10.2 i 3
   where "" is used to insert the FQDN name of agent, 1 is an integer describing the status of device. (0="OK", 1="PROBLEM", 2="DANGER", 3="FAIL")

4. The user can see the traps using "wireshark"
   Apply filter as: "snmp" and start capture on the required interface, can be eth0.
   where "snmp" is the protocol. The IP address of source and destination of snmp trap

****Configuration for trap listener****
---------------------------------------

1. Add the following lines to the snmpdtrapd.conf file in the /etc/snmp/snmptrapd.conf:

	authCommunity log,execute,net public
	snmpTrapdAddr udp:50162
	traphandle 1.3.6.1.4.1.41717.10.* perl /path/to/et2536-ropo15/assignment3/trapdaemon.pl 

2. Open file snmpd from /etc/default/snmpd and change the line:

	 TRAPDRUN=no to TRAPDRUN=yes

3. Then, use the terminal command "sudo service snmpd restart".

