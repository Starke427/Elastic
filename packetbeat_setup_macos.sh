#!/bin/bash
#
# Author: Jeff Starke (Starke427)
# Updated: 2021 May 03

version=7.12.0
cloudID=
cloudAuthUser=elastic
cloudAuthPass=

########## Check for existing installation
oldVersion=$(head -n1 /usr/local/packetbeat/README.md | cut -d" " -f5)
if [[ ! -f /usr/local/packetbeat/README.md ]]; then
  echo "Preparing to install Packetbeat $version."
elif [ $oldVersion == $version ]; then
  echo "Packetbeat is already installed on version $oldVersion."
  read -p "Would you like to delete the old version (y/n)?" choice
  case "$choice" in
    y|Y )
      echo "Preparing to remove Packetbeat $oldVersion."
      sudo launchctl unload /Library/LaunchAgents/co.elastic.packetbeat.plist
      sudo rm -f /Library/LaunchAgents/co.elastic.packetbeat.plist
      sudo rm -rf /usr/local/packetbeat
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
  echo "Packetbeat is already installed on version $oldVersion."
  echo "You are attempting to install Packetbeat $version."
  read -p "Would you like to delete the old version (y/n)?" choice
  case "$choice" in
    y|Y )
      echo "Preparing to remove Packetbeat $oldVersion."
      sudo launchctl unload /Library/LaunchAgents/co.elastic.packetbeat.plist
      sudo rm -f /Library/LaunchAgents/co.elastic.packetbeat.plist
      sudo rm -rf /usr/local/packetbeat
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
  echo "Preparing to install Packetbeat $version."
fi

echo ""
echo "Starting Packetbeat $version installation..."a

########## Download and configure packetbeat
curl -L -O https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-$version-darwin-x86_64.tar.gz
tar xzvf packetbeat-$version-darwin-x86_64.tar.gz
rm -f packetbeat-$version-darwin-x86_64.tar.gz
sudo mv packetbeat-$version-* /usr/local/packetbeat

########## Configure packetbeat
sudo cat >> /usr/local/packetbeat/packetbeat.yml << EOF
cloud.id: "$cloudID"
cloud.auth: "$cloudAuthUser:$cloudAuthPass"
EOF

sudo chown -R root:wheel /usr/local/packetbeat

########## Configure autostart plist
cat > co.elastic.packetbeat.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>co.elastic.packetbeat</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/packetbeat/packetbeat</string>
	<string>-c</string>
	<string>/usr/local/packetbeat/packetbeat.yml</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
sudo mv co.elastic.packetbeat.plist /Library/LaunchAgents/
sudo chown -R root:wheel /Library/LaunchAgents/co.elastic.packetbeat.plist

########## Start packetbeat
sudo launchctl load /Library/LaunchAgents/co.elastic.packetbeat.plist
