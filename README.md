# ccdc_scripts
LIST
Nmap:
-  nmap -T5 -Pn --open -v -sV -p 22,3389 10.100.27.0/24 --unprivileged
Inventory:
- ipconfig | findstr /i "IPv4"
- hostname
- systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
- netstat -anob -p tcp | findstr /v "TIME_WAIT CLOSE_WAIT"
- tasklist /svc /fi "PID eq <PID>"
- 
- 

- irm https://raw.githubusercontent.com/delebete/ccdc_scripts/main/inventory.ps1 | iex
