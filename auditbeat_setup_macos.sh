#!/bin/bash
#
# Author: Jeff Starke (Starke427)
# Updated: 2021May03

version=7.12.0
cloudID=
cloudAuthUser=elastic
cloudAuthPass=

########## Check for existing installation
oldVersion=$(head -n1 /usr/local/auditbeat/README.md | cut -d" " -f5)
if [[ ! -f /usr/local/auditbeat/README.md ]]; then
  echo "Preparing to install Auditbeat $version."
elif [ $oldVersion == $version ]; then
  echo "Auditbeat is already installed on version $oldVersion."
  read -p "Would you like to delete the old version (y/n)?" choice
  case "$choice" in
    y|Y )
      echo "Preparing to remove Auditbeat $oldVersion."
      sudo launchctl unload /Library/LaunchAgents/co.elastic.auditbeat.plist
      sudo rm -f /Library/LaunchAgents/co.elastic.auditbeat.plist
      sudo rm -rf /usr/local/auditbeat
      exit 1
    ;;
    n|N )
      echo "Cancelling installation."
      exit 1
    ;;
    * )
      echo "Invalid response."
      exit 1
    ;;
  esac
elif [ $oldVersion != $version ]; then
  echo "Auditbeat is already installed on version $oldVersion."
  echo "You are attempting to install Auditbeat $version."
  read -p "Would you like to delete the old version (y/n)?" choice
  case "$choice" in
    y|Y )
      echo "Preparing to remove Auditbeat $oldVersion."
      sudo launchctl unload /Library/LaunchAgents/co.elastic.auditbeat.plist
      sudo rm -f /Library/LaunchAgents/co.elastic.auditbeat.plist
      sudo rm -rf /usr/local/auditbeat
    ;;
    n|N )
      echo "Cancelling installation."
      exit 1
    ;;
    * )
      echo "Invalid response."
      exit 1
    ;;
  esac
else
  echo "Preparing to install Auditbeat $version."
fi

echo ""
echo "Starting Auditbeat $version installation..."a

########## Download and configure auditbeat
curl -L -O https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-$version-darwin-x86_64.tar.gz
tar xzvf auditbeat-$version-darwin-x86_64.tar.gz
rm -f auditbeat-$version-darwin-x86_64.tar.gz
sudo mv auditbeat-$version-* /usr/local/auditbeat

########## Configure Elastic connection
#cloudID=$(echo 'cloud.id: "'$cloudID'"')
sudo echo 'cloud.id: "'$cloudID'"' >> /usr/local/auditbeat/auditbeat.yml
sudo echo 'cloud.auth: "'$cloudAuthUser':'$cloudAuthPass'"' >> /usr/local/auditbeat/auditbeat.yml
sudo chown -R root:wheel /usr/local/auditbeat


########## Configure collection modules


########## Configure autostart plist
cat > co.elastic.auditbeat.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>co.elastic.auditbeat</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/auditbeat/auditbeat</string>
	<string>-c</string>
	<string>/usr/local/auditbeat/auditbeat.yml</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
sudo mv co.elastic.auditbeat.plist /Library/LaunchAgents/
sudo chown -R root:wheel /Library/LaunchAgents/co.elastic.auditbeat.plist

########## Start auditbeat
sudo launchctl load /Library/LaunchAgents/co.elastic.auditbeat.plist
