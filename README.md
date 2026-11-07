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

- irm https://raw.githubusercontent.com/delebete/ccdc_scripts/main/inventory.ps1 | iex

Admin/AD User:
:: Change local Administrator password
- net user Administrator NewSecurePassword123!

:: Change a Domain User password
- net user targetuser CompHardenedPass2026! /domain

:: Change Domain Administrator password
- net user Administrator CompHardenedPass2026! /domain

:: Disable a domain account
- net user bad_actor /active:no /domain

:: Disable a local account
- net user Guest /active:no

:: Re-enable an account if needed
- net user svc_scoring /active:yes /domain

:: View details of a specific domain user (groups, last logon, password set)
- net user targetuser /domain

:: Add a new emergency backup admin account to the domain
- net user ccdc_admin BackupPass2026! /add /domain

:: List all members in Domain Admins
- net group "Domain Admins" /domain

:: List members in local Administrators
- net localgroup Administrators

:: Strip Domain Admin privileges from an unauthorized account
- net group "Domain Admins" unauthorized_user /delete /domain

:: Strip Domain Admin from another user
- net group "Domain Admins" john_doe /delete /domain

:: Add an emergency or IT account to Domain Admins
- net group "Domain Admins" it_admin /add /domain

:: Add to local Administrators
- net localgroup Administrators ccdc_admin /add

:: View current password and lockout policy
- net accounts /domain

:: Enforce minimum password length of 14 characters
- net accounts /minpwlen:14 /domain

:: Enforce account lockout after 5 failed attempts within 30 minutes
- net accounts /lockoutthreshold:5 /lockoutwindow:30 /lockoutduration:30 /domain

:: Prevent password reuse (remember last 5 passwords)
- net accounts /uniquepw:5 /domain

:: View active SMB sessions to this box (see who is connected)
- net session

:: Drop all open sessions immediately
- net session /delete /y

:: View local network shares (look for unauthorized hidden shares with $)
- net share

:: Delete an unauthorized share
- net share ShareName /delete
