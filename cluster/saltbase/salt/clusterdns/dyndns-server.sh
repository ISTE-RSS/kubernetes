#!/bin/bash
# starts dnsmasq and nc
#
# Copyright (C) James Budiono 2013
# License: GPL Version 3 or later.

### configuration
SERVER="192.168.1.99 9000" # ip address and port of server
SERVER_NAME="sb32"         # name of server
HOSTDIR=/tmp/hosts         # location of dynamic host files
CONFFILE=/etc/dnsmasq-dyndns.conf   # dnsmasq conf to use
PIDFILE=/var/run/dnsmasq-dyndns.pid # dnsmasq pid file
NCPIDFILE=/var/run/nc-dyndns.pid    # nc pid file
DYNDNS_LISTENER=/usr/bin/local-dyndns-listen # the listener program
[ -e /etc/local-dyndns.conf ] && . /etc/local-dyndns.conf

watch_hostdir() {
	inotifyd - $HOSTDIR:dmnxy | while read a b; do
		case $a in
			x) break ;;
			*) kill -HUP $(cat $PIDFILE)
		esac
	done
}

start() {
	[ -e $PIDFILE ] && return # don't start when already running
	echo "local dyndns server starting..."
	mkdir -p $HOSTDIR
	echo 127.0.0.1 localhost > $HOSTDIR/localhost
	echo ${SERVER% *} ${SERVER_NAME} > $HOSTDIR/${SERVER_NAME}
	dnsmasq --pid-file=$PIDFILE -C $CONFFILE		
	echo ${SERVER#* }
        nc -lkp ${SERVER#* } -e "$DYNDNS_LISTENER $(cat $PIDFILE)" &
	echo $! > $NCPIDFILE
	#watch_hostdir &   ### uncomment this if you want to use inotify
}

stop() {
	! [ -e $PIDFILE ] && return
	kill $(cat $PIDFILE) $(cat $NCPIDFILE) 
	rm -rf $PIDFILE $NCPIDFILE 
}

### main
case $1 in
	start) start ;;
	stop)  stop  ;;
	status) [ -e $PIDFILE ] && echo "local-dyndns-server is running" || 
	        echo "local-dyndns-server is stopped" ;; 
	restart) stop; sleep 2; start ;;
esac
