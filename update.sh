#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION="0.3"

# Helpers
red="\033[31m"
reset="\033[0m"
green="\033[32m"
yellow="\033[33m"
cyan="\033[36m"

# Auto-update the script from Git
if [[ $* != *--skip-update* ]]; then
  uptodate=$(git --git-dir=$DIR/.git fetch origin -q && git --git-dir=$DIR/.git log HEAD..origin/master --oneline | wc -l | sed 's/^ *//g') # Is the repository up to date? 0=yes

  if [[ "$uptodate" != "0" ]]; then
    echo "New version released, updating..."
    git --git-dir=$DIR/.git pull -q >/dev/null || echo -e "$red Error when updating this script. Please report to @jla $reset"
    newVersion=$(cat $0 | grep 'VERSION=' | head -n 1 | sed 's/VERSION="\(.*\)"/\1/')
    echo -e "Script updated from $green$VERSION$reset to $green$newVersion$reset"
    $0 --skip-update
    exit 0
  fi
fi

# Load Configuration
source "$DIR/config.properties" || exit 1

# Read a value with default
ask() {
  local default=$1
  read -p "(default: $default) " name
  name=${name:-$default}
  echo $name
}

#
# Check configuration
#

# Check if all variables are defined?
: ${capdematVersion?not defined}
: ${dirDelivery?not defined}
: ${dirData?not defined}
: ${dirTomcat?not defined}
: ${service?not defined}
: ${jenkinsToken?not defined}
: ${jenkinsUser?not defined}

# Folders are valid?
if [ ! -d "$service" ]; then echo "Service $service not found"; exit 1; fi;
if [ ! -d "$dirData" ]; then echo "Data directory $dirData not found"; exit 1; fi;
if [ ! -d "$dirTomcat" ]; then echo "Tomcat directory $dirTomcat not found"; exit 1; fi;

# Extract data
d=`date +"%Y-%m-%d-%Hh%M"`

#
# Summary
#
echo ""
echo -e "Capdemat Deployment $VERSION -$red Please double check the configuration! $reset"
if [[ $* == *--test* ]]; then
  echo -ne "$green"; echo -e "TEST MODE : Nothing will be modified$reset"
fi
echo ""
echo -e "  Tomcat               >$cyan $dirTomcat $reset"
echo -e "  Data                 >$cyan $dirData $reset"
echo -e "  Service              >$cyan $service $reset"
echo -ne "  Build Jenkins        > "; capdematRealBuild=$(ask $capdematBuild);
echo -ne "  Capdemat version     > "; capdematRealVersion=$(ask $capdematVersion);

# Suggest to dump DB if postgres user is defined
if [[ -n "pgUser" ]]; then 
  echo -ne "  Dump all DB (y/n)    > "; dumpDB=$(ask "n");
else
  dumpDB="n"
fi;

echo -ne "  Restart server (y/n) > "; restartServer=$(ask "y");

# Dump asked, check if postgres is accessible
if [[ "$dumpDB" = "y" || "$dumpDB" = "Y" ]]; then
  : ${pgUser?not defined} # Check if PgUser is defined
  su $pgUser -c 'true' || (echo -e "$red Cannot login to $pgUser, user not found! $reset"; exit 1)
  su $pgUser -c 'psql -l >/dev/null'  || (echo -e "$red Cannot connect to Postgres, $pgUser not authorized! $reset"; exit 1)
fi;

echo ""
echo -e "If everything is OK: $green<Enter>$reset, otherwise: $red<CTRL+C>$reset"

if [[ $* == *--test* ]]; then
  exit 0
fi

read pause

#
# Deploying
#
echo -ne "- Preparing delivery directory in $d: "
ls $dirDelivery &> /dev/null || (mkdir $dirDelivery || ( echo "$red Cannot create delivery dir $dirDelivery $reset"; exit 1)) # Create delivery directory if not exists
cd $dirDelivery
rm -Rf ./$d 2>/dev/null  # Empty delivery directory if there is already a deployment in the last minute
mkdir $d || exit 1
cd $d
echo "OK"

echo "-- Downloading last release of CapDemat-$capdematRealVersion.war"
wget --auth-no-challenge --http-user=$jenkinsUser --http-password=$jenkinsToken \
  "http://build-01.znx.fr/job/$capdematRealBuild/lastSuccessfulBuild/artifact/release/CapDemat-$capdematRealVersion.war" || exit 1
echo "-- Downloading last release of CapDemat-admin-$capdematRealVersion.zip"
wget --auth-no-challenge --http-user=$jenkinsUser --http-password=$jenkinsToken \
   "http://build-01.znx.fr/job/$capdematRealBuild/lastSuccessfulBuild/artifact/release/CapDemat-admin-$capdematRealVersion.zip" || exit 1

echo -ne "- Stopping server: "
svc -d $service || exit 1
sleep 2
echo "OK"

echo -ne "- Dump DBs: "
if [[ "$dumpDB" = "y" || "$dumpDB" = "Y" ]]; then
  dbs=$(su $pgUser -c 'psql -l -t -A' | cut -d "|" -f 1 | grep "capdemat_") # Get all db starting by capdemat_
  pghome=$(su $pgUser -c 'cd ~; pwd') # Get pghome (dir where DB dump will be created)
  mkdir dump

  echo ""
  for db in $dbs
  do
    echo -ne " -- Dumping $db: "
    su $pgUser -c "pg_dump -F c $db > ~/dump_$db.backup" || exit 1 # Launch dump
    mv $pghome/dump_$db.backup dump/ || exit 1 # And copy to delivery/dump directory
    echo "OK"
  done
else
  echo "Skipped"
fi;

echo -ne "- Installing new app: "
# Extract admin package
rm -Rf $durData/* || exit 1
unzip -o -qq -d $dirData CapDemat-admin-$capdematVersion.zip || exit 1
cp $dirTomcat/webapps/ROOT/WEB-INF/classes/CapDemat-config.properties $dirData/conf/spring || exit 1

# Extract CapDemat webapp
rm -rf $dirTomcat/webapps/ROOT || exit 1
unzip -o -qq -d $dirTomcat/webapps/ROOT CapDemat-$capdematVersion.war || exit 1
cp $dirData/conf/spring/CapDemat-config.properties $dirTomcat/webapps/ROOT/WEB-INF/classes/ || exit 1
echo "OK"

echo -ne "- Starting new app: "
if [[ "$restartServer" = "y" || "$restartServer" = "Y" ]]; then
  svc -u $service
  echo "OK"
else
  echo "Skipped (run > svc -u $service)"
fi;

echo ""
echo -ne "$green"; echo -e "Deploy finished with success! $reset"
echo "Check logs at: $dirTomcat/logs/CapDemat.log"
echo ""

exit 0
