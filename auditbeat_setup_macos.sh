#!/bin/bash
#
# Author: Jeff Starke (Starke427)
# Updated: 2021 May 03

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

########## Configure auditbeat
sudo cat > /usr/local/auditbeat/auditbeat.yml << EOF
auditbeat.modules:
- module: file_integrity
  paths:
  - /bin
  - /usr/bin
  - /usr/local/bin
  - /sbin
  - /usr/sbin
  - /usr/local/sbin
- module: system
  datasets:
    - process # Started and stopped processes
  period: 5m # The frequency at which the datasets check for changes
- module: system
  datasets:
    - package # Installed, updated, and removed packages
  period: 1h
  datasets:
    - host    # General host information, e.g. uptime, IPs
  state.period: 24h
setup.template.settings:
  index.number_of_shards: 1
setup.kibana:
output.elasticsearch:
  hosts: ["localhost:9200"]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
cloud.id: "$cloudID"
cloud.auth: "$cloudAuthUser:$cloudAuthPass"
EOF

sudo chown -R root:wheel /usr/local/auditbeat

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
