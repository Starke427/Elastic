# Elastic Agent for Windows

```
$args = 
$version = 7.10.2

$url1 = https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$version-windows-x86_64.zip
$file1 = "$env:temp\elastic-agent.zip"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url1, $file1)
Set-ExecutionPolicy -ExecutionPolicy Bypass -force
Expand-Archive -LiteralPath "$env:temp\elastic-agent.zip" -DestinationPath "C:\Program Files\"
& C:\Program Files\Elastic\Agent\elastic-agent.exe $args
```

# Auditbeat for MacOS

auditbeat_setup_macos.sh will verify current installation and give you options to download, update or remove a launchpad registered auditbeat service for Elastic Cloud.

You'll need to modify the values at the start of the script to reflect your cloudID and cloudAuth.

```
curl -o auditbeat_setup_macos.sh https://raw.githubusercontent.com/Starke427/Elastic/master/auditbeat_setup_macos.sh
chmod 750 auditbeat_setup_macos.sh
./auditbeat_setup_macos.sh
```
