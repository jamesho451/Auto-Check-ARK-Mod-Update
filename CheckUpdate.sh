#!/bin/bash

#update certificate(CentOS only, delete this section if you're using Debian/Ubuntu) 
update-ca-trust enable
update-ca-trust

#update certificate(Debian/Ubuntu only, delte this section if your're using CentOS)
update-ca-certificates


#put this script into the arkserverpath defined below
arkserverpath='' #this is your server directory, the directory should shoud include a ShooterGame directory and an Engine directory among other files.
emails="" #this is the gmail address where you want to receive the reminder
#put a comma and add more email addresses if you want multiple recipients, like so *****@gmail.com,*****.gmail.com


declare -a mods=()
#the format:declare -a mods=("modid01" "modid02" "modid03" ...)

#Nothing needs to be changed below this line

modupdateavaliable="false"
updateavaliable="false"
ARKUpdate=""


locallinewithbuildid="$(grep -n "buildid" "$arkserverpath/steamapps/appmanifest_376030.acf")"
locallinewithbuildid01=${locallinewithbuildid#*\"buildid\"		\"}
localbuildid=${locallinewithbuildid01%\"*}
buildid="$(curl -s GET 'https://api.steamcmd.net/v1/info/376030' | jq -r '.data."376030".depots.branches.public.buildid')"


if [ "$localbuildid" != "$buildid" ] 
then 
	updateavaliable="true"
 	ARKUpdate="New version of ARK avaliable."
fi


declare -a modswithupdates
for i in "${mods[@]}"
do
   locallastupdated=$(cat "${arkserverpath}/ShooterGame/Content/Mods/$i/__modversion__.info")
   serverresp="$(curl -s -d "itemcount=1&publishedfileids[0]=$i" "http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1")"
   serverresptemp=${serverresp#*\"time_updated\":}
   lastupdated=${serverresptemp%,\"visibility\"*}
   if [ "$locallastupdated" != "$lastupdated" ] 
       then 
   	  modswithupdates[${#modswithupdates[@]}]="$i"
	  modupdateavaliable="true"	 
   fi
done


NEWLINE=$'\n'
if [ $updateavaliable = "true" ] && [ $modupdateavaliable = "false" ]; then
   echo "${ARKUpdate}" | mail -s "Ark Server Update Reminder" $emails
elif [ $updateavaliable = "true" ] || [ $modupdateavaliable = "true" ]; then
  echo "${ARKUpdate}${NEWLINE}Mod ${modswithupdates[*]} update avaliable." | mail -s "Ark Server Update Reminder" $emails
fi
