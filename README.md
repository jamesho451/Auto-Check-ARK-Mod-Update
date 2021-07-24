# Auto-Check-ARK-Mod_Update
Automatically check update of ark server and its mods and send out email reminder when an update is avaliable

## Prerequestities 
curl, jq, grep. A quick google search should give you how to install them


## Notes
For linux only, this instruction is made for both Debian/Ubuntu and CentOS/RHEL

The CheckUpdate-Reference is a filled out version of the script for your reference

I don't include commands for things like creating files and making a file executable because I use programs like WinSCP and Filezilla to access my server's files so if you're lost trying to follow this with only a shell just keep this in mind

The script does give false alarm from time to time, probably because steam's api doesn't have 100% uptime. The best practice is to wait till you get two emails in a row before you do anything.


### 1. Set up the email server
1.1  Run the commands below with root
```
CentOS/RHEL:
  yum install ca-certificates
  update-ca-trust enable
  update-ca-trust
  yum install msmtp
  yum install mailx
  
Debian/Ubuntu:
  apt-get install ca-certificates
  update-ca-certificates
  apt-get install msmtp-mta
  apt-get install bsd-mailx
```
  
1.2  go to /etc/msmtprc, create one if it's not there, it should include the following
```
------------------------------------------------Start copy below this line
defaults
auth           on
tls            on
tls_trust_file  *see below*
logfile        ~/.msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           xxx@gmail.com
user           xxx
password       ******

account default : gmail
--------------------------------------------------Stop copy above this line
```
```
for CentOS, replace *see below* with /etc/pki/tls/certs/ca-bundle.crt
for Debian/Ubuntu, replace *see below* with /etc/ssl/certs/ca-certificates.crt
user is the gmail address before the @, password is the password of the gmail account
```


1.3  turn on less secure apps in the gmail account you're using


1.4  Test msmtp by running the following command: 

echo "Hello this is sending email using msmtp" | msmtp <your email address>(don't include <>)
  
you should receive an email

  
1.5  go to /etc/mail.rc, if it's not there create one, and add this line:
```
-------------------------start copy below this line
set mta=/usr/bin/msmtp 
-------------------------end copy above this line
```

1.6  Test by running the following command:
  
echo "THIS IS A TEST EMAIL" | mail -s "Test" <your email address>
  
you should receive an email


### 2. Fill out the scipt
  the directions are included in the script, place the script in the ark server directory as defined in the script, and make it exeutable by root


### 3. Use systemd to run the script periodically
3.1 Create two files in /etc/systemd/system, one called checkarkupdate.timer, one called checkarkupdate.service

3.2 place the following in checkarkupdate.timer
 ```
-----------------------------------start copy below this line
[Unit]
Description=check for ARK version or mods update

[Timer]
OnUnitActiveSec=900
OnBootSec=10

[Install]
WantedBy=timers.target
-----------------------------------end copy above this line
  ```
*900 means to run the script every 15 minutes, change it as desired

3.3 place the following in checkarkupdate.service
  ```
-----------------------------------start copy below this line
[Unit]
Description=check for ARK version or mods update

[Service]
Type=forking
ExecStart=/bin/bash $arkserverpath/CheckUpdate.sh
----------------------------------end copy above this line
  ```
*replace $arkserverpath with your server path as defined in the script

3.4 run the following commands
  ```
  systemctl daemon-reload
  systemctl enable checkarkupdate.timer(this will make the timer start on boot, optional)
  systemctl start checkarkupdate.timer
  ```
