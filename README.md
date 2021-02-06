# Elastic Agent

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
