#!/bin/bash
#
# Setup environment to support running core3

##############################################################################
# Common functions and setup
##############################################################################
yorn() {
  echo -n -e "$@ Y\b"
  read yorn
  case $yorn in
    [Nn]* ) return 1;;
  esac
  return 0
}

nory() {
  echo -n -e "$@ N\b"
  read yorn
  case $yorn in
    [Yy]* ) return 0;;
  esac
  return 1
}
gerrit_host='review.swgemu.com'
gerrit_webport='8080'

# make sure mysql server is running
if [[ $(systemctl is-active mysql) == 'active' ]]
then
	echo "mysql server already running."
else
	echo "Starting mysql server..."
	systemctl start mysql
fi

# get all sql databases setup properly
if sudo mysql -u eschu -peschupw -NB -e 'show databases'|grep swgemu > /dev/null 2>&1; then
	echo "swgemu database already exists."
	:
else
	sudo ./createdb swgemu eschu eschupw
	echo "Restore blank swgemu database to mysql"
	sudo mysql -u eschu -peschupw -e source -e ../MMOCoreORB/sql/swgemu.sql;
	sudo ./createdb mantis eschu eschupw
	echo "Restore blank mantis database to mysql"
	sudo mysql -u eschu -peschupw -e source -e ../MMOCoreORB/sql/mantis.sql;
fi

# configure server options
echo "Server configuration"
rundir=../MMOCoreORB/bin/
runcfg=${rundir}conf/config.lua
runsrc=../MMOCoreORB/bin/conf/config.lua
if [ -f $runcfg ]; then
  echo "$runcfg already setup"
else
  echo "By default only tatooine and tutorial zones are enabled"
  if yorn "Would you like to edit the default configuration?"; then
    while :
    do
      kate $runcfg
      echo "Checking config syntax..."
      if zones=$(cd $rundir;echo 'for k,v in pairs(ZonesEnabled) do io.write(v .. " ") end' | lua -l ./conf/config); then
	echo "SUCCESS - $runcfg passed lua parser"
	echo "Zones enabled: $zones"
	break
      else
	echo "You have a syntax error, please fix it before continuing."
	echo -n "Press <ENTER> to edit the config again: "
	read junk
      fi
    done
  fi
fi


exit 0
