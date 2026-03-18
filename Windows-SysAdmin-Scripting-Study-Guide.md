# Windows SysAdmin Scripting Study Guide
## PowerShell from Zero to Job-Ready

---

## WHAT IS POWERSHELL?

PowerShell is Windows' command-line shell and scripting language. Think of it as Command Prompt's way smarter older sibling — it can manage users, services, files, networks, security policies, and entire fleets of servers all from a script.

**Real world analogy:**
- CMD = a basic calculator
- PowerShell = a full spreadsheet app with formulas, macros, and automation

**Why it matters for your job:**
- Every Windows server in DoD/IC environments is managed with PowerShell
- Security auditing, incident response, and compliance checks are scripted in PS
- It's on the DeNOVO job description as a desired skill

---

## POWERSHELL BASICS

### Opening PowerShell
```
Start Menu → search "PowerShell" → Run as Administrator
```

Or on any Windows machine:
```
Win + R → type: powershell → Enter
```

### Your First Commands
```powershell
# Print something
Write-Host "Hello, World!"

# Get current directory
Get-Location

# List files
Get-ChildItem          # like ls or dir
Get-ChildItem -Force   # show hidden files too
ls                     # alias that works too

# Navigate
Set-Location C:\Users  # like cd
cd C:\Windows          # alias works

# Clear screen
Clear-Host             # or just: cls
```

---

## THE POWERSHELL WAY — OBJECTS NOT TEXT

This is what makes PowerShell different from bash. **Everything is an object**, not just text.

```powershell
# Get processes — returns OBJECTS with properties
Get-Process

# Filter to just Chrome
Get-Process | Where-Object {$_.Name -eq "chrome"}

# Get only specific properties
Get-Process | Select-Object Name, CPU, WorkingSet

# Sort by CPU usage
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
```

The `|` (pipe) passes objects from one command to the next — same concept as Linux but with full objects instead of text strings.

---

## VARIABLES & DATA TYPES

```powershell
# Variables start with $
$name = "Justin"
$age = 28
$isAdmin = $true

# String interpolation
Write-Host "Hello, $name"

# Arrays
$servers = @("server1", "server2", "server3")
$servers[0]           # "server1"
$servers.Count        # 3

# Hash tables (like dictionaries)
$user = @{
    Name = "Justin"
    Role = "Admin"
    Active = $true
}
$user["Name"]         # "Justin"
$user.Role            # "Admin"
```

---

## IF / ELSE / LOOPS

```powershell
# If/Else
$score = 85
if ($score -ge 90) {
    Write-Host "A"
} elseif ($score -ge 80) {
    Write-Host "B"
} else {
    Write-Host "C or below"
}

# Comparison operators (different from bash!)
# -eq   equal
# -ne   not equal
# -gt   greater than
# -lt   less than
# -ge   greater than or equal
# -le   less than or equal
# -like wildcard match ("Justin" -like "Jus*")
# -match regex match

# ForEach loop
$servers = @("web01", "web02", "db01")
foreach ($server in $servers) {
    Write-Host "Checking $server..."
}

# While loop
$count = 0
while ($count -lt 5) {
    Write-Host "Count: $count"
    $count++
}

# ForEach-Object (pipeline version)
1..10 | ForEach-Object { Write-Host "Number: $_" }
```

---

## FUNCTIONS

```powershell
function Get-SystemInfo {
    param(
        [string]$ComputerName = "localhost"
    )

    $os = Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName
    $cpu = Get-CimInstance Win32_Processor -ComputerName $ComputerName

    [PSCustomObject]@{
        Computer = $ComputerName
        OS       = $os.Caption
        RAM_GB   = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        CPU      = $cpu.Name
    }
}

# Call it
Get-SystemInfo
Get-SystemInfo -ComputerName "server01"
```

---

## ACTIVE DIRECTORY — THE BIG ONE FOR SYSADMINS

Active Directory (AD) is how Windows manages users, computers, and permissions in an organization. PowerShell is THE way to manage it at scale.

```powershell
# Import the AD module
Import-Module ActiveDirectory

# USER MANAGEMENT
# Get a user
Get-ADUser -Identity "jyoungs"
Get-ADUser -Identity "jyoungs" -Properties *   # all properties

# Search for users
Get-ADUser -Filter {Department -eq "IT"} -Properties Department, Title

# Create a user
New-ADUser `
    -Name "John Smith" `
    -GivenName "John" `
    -Surname "Smith" `
    -SamAccountName "jsmith" `
    -UserPrincipalName "jsmith@company.com" `
    -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) `
    -Enabled $true `
    -Path "OU=Users,DC=company,DC=com"

# Disable a user (termination procedure)
Disable-ADAccount -Identity "jsmith"

# Unlock a locked account
Unlock-ADAccount -Identity "jsmith"

# Reset password
Set-ADAccountPassword -Identity "jsmith" `
    -NewPassword (ConvertTo-SecureString "NewP@ss!" -AsPlainText -Force) `
    -Reset

# Find locked out accounts (security audit)
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName

# Find disabled accounts
Search-ADAccount -AccountDisabled | Select-Object Name, LastLogonDate

# Find accounts that haven't logged in for 90 days
$cutoff = (Get-Date).AddDays(-90)
Get-ADUser -Filter {LastLogonDate -lt $cutoff -and Enabled -eq $true} `
    -Properties LastLogonDate | Select-Object Name, LastLogonDate
```

```powershell
# GROUP MANAGEMENT
Get-ADGroup -Identity "Domain Admins"
Get-ADGroupMember -Identity "Domain Admins"   # who's in a group

# Add user to group
Add-ADGroupMember -Identity "IT-Staff" -Members "jsmith"

# Remove user from group
Remove-ADGroupMember -Identity "IT-Staff" -Members "jsmith" -Confirm:$false

# COMPUTER MANAGEMENT
Get-ADComputer -Filter * | Select-Object Name, OperatingSystem
Get-ADComputer -Identity "WORKSTATION01" -Properties *
```

---

## SECURITY SCRIPTING — THE JOB-RELEVANT STUFF

### Audit Local Admins on Remote Machines
```powershell
$computers = @("PC01", "PC02", "SERVER01")

foreach ($computer in $computers) {
    $admins = Invoke-Command -ComputerName $computer -ScriptBlock {
        Get-LocalGroupMember -Group "Administrators"
    }
    Write-Host "`n=== $computer ===" -ForegroundColor Cyan
    $admins | Select-Object Name, ObjectClass
}
```

### Find Users with Password Never Expires
```powershell
# Security risk — should be reviewed regularly
Get-ADUser -Filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} `
    -Properties PasswordNeverExpires, PasswordLastSet |
    Select-Object Name, SamAccountName, PasswordLastSet |
    Export-Csv -Path "C:\Reports\PasswordNeverExpires.csv" -NoTypeInformation

Write-Host "Report saved."
```

### Check for Failed Login Attempts (Incident Response)
```powershell
# Event ID 4625 = failed logon
Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4625
    StartTime = (Get-Date).AddHours(-24)
} | Select-Object TimeCreated, Message | Format-List
```

### Check Running Services
```powershell
# All running services
Get-Service | Where-Object {$_.Status -eq "Running"} | Sort-Object DisplayName

# Find suspicious services (not signed by Microsoft)
Get-WmiObject Win32_Service |
    Where-Object {$_.State -eq "Running"} |
    Select-Object Name, PathName, StartName |
    Where-Object {$_.StartName -ne "LocalSystem" -and $_.StartName -ne "LocalService"}
```

### Firewall Management
```powershell
# Check firewall status
Get-NetFirewallProfile | Select-Object Name, Enabled

# List all firewall rules
Get-NetFirewallRule | Select-Object DisplayName, Direction, Action, Enabled

# Add a rule
New-NetFirewallRule `
    -DisplayName "Block Telnet" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 23 `
    -Action Block

# Enable firewall on all profiles
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

### Check Open Network Connections
```powershell
# See all connections (like netstat)
Get-NetTCPConnection | Where-Object {$_.State -eq "Established"} |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State |
    Sort-Object RemoteAddress
```

---

## FILE & REGISTRY OPERATIONS

```powershell
# FILE OPERATIONS
New-Item -Path "C:\Logs" -ItemType Directory          # mkdir
New-Item -Path "C:\Logs\audit.log" -ItemType File     # touch
Copy-Item "C:\source.txt" "C:\backup\source.txt"      # cp
Move-Item "C:\old.txt" "C:\new.txt"                   # mv
Remove-Item "C:\temp\*" -Recurse -Force               # rm -rf

# Read/Write files
Get-Content "C:\Logs\audit.log"                       # cat
Get-Content "C:\Logs\audit.log" | Select-Object -Last 20  # tail
Add-Content "C:\Logs\audit.log" "New log entry"       # append
Set-Content "C:\config.txt" "New content"             # overwrite

# Search file contents
Select-String -Path "C:\Logs\*.log" -Pattern "ERROR"  # like grep

# REGISTRY (Windows config database)
# View a key
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

# Check startup programs (persistence check — attacker technique)
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
```

---

## REMOTE MANAGEMENT — PSREMOTING

Manage remote machines without touching them physically.

```powershell
# Enable remoting (run on target machine once)
Enable-PSRemoting -Force

# Run a single command on remote machine
Invoke-Command -ComputerName "SERVER01" -ScriptBlock {
    Get-Service | Where-Object {$_.Status -eq "Stopped"}
}

# Run on multiple machines at once
Invoke-Command -ComputerName "WEB01","WEB02","WEB03" -ScriptBlock {
    Restart-Service -Name "W3SVC"
}

# Open interactive remote session
Enter-PSSession -ComputerName "SERVER01"
# Now you're working ON server01
Exit-PSSession

# Run a script file on remote machine
Invoke-Command -ComputerName "SERVER01" -FilePath "C:\scripts\audit.ps1"
```

---

## SCHEDULED TASKS (AUTOMATION)

```powershell
# Create a scheduled task to run a script daily at 2am
$action  = New-ScheduledTaskAction -Execute "PowerShell.exe" `
               -Argument "-File C:\scripts\daily-audit.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "2:00AM"
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "Daily Security Audit" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -RunLevel Highest
```

---

## ERROR HANDLING

```powershell
try {
    # Try something that might fail
    Get-ADUser -Identity "nonexistent_user" -ErrorAction Stop
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    # Log the error
    Add-Content "C:\Logs\errors.log" "$(Get-Date): $($_.Exception.Message)"
}
finally {
    # Always runs — cleanup code
    Write-Host "Done."
}
```

---

## REAL SYSADMIN SCRIPTS

### Script 1: New Employee Onboarding
```powershell
function New-EmployeeSetup {
    param(
        [string]$FirstName,
        [string]$LastName,
        [string]$Department,
        [string]$Manager
    )

    $username = ($FirstName[0] + $LastName).ToLower()
    $email    = "$username@company.com"
    $tempPass = ConvertTo-SecureString "Welcome2024!" -AsPlainText -Force

    # Create AD account
    New-ADUser `
        -Name "$FirstName $LastName" `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName $username `
        -UserPrincipalName $email `
        -AccountPassword $tempPass `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -Department $Department `
        -Manager $Manager

    # Add to department group
    Add-ADGroupMember -Identity $Department -Members $username

    # Add to standard groups
    Add-ADGroupMember -Identity "All-Staff" -Members $username

    Write-Host "Created account: $username ($email)" -ForegroundColor Green
}

# Usage
New-EmployeeSetup -FirstName "Jane" -LastName "Doe" -Department "IT" -Manager "jyoungs"
```

### Script 2: Security Audit Report
```powershell
$report = @()

# Locked accounts
$locked = Search-ADAccount -LockedOut
$report += "LOCKED ACCOUNTS: $($locked.Count)"
$locked | ForEach-Object { $report += "  - $($_.Name)" }

# Password never expires
$noExpire = Get-ADUser -Filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} `
    -Properties PasswordNeverExpires
$report += "`nPASSWORD NEVER EXPIRES: $($noExpire.Count)"
$noExpire | ForEach-Object { $report += "  - $($_.Name)" }

# Inactive users (90 days)
$cutoff = (Get-Date).AddDays(-90)
$inactive = Get-ADUser -Filter {LastLogonDate -lt $cutoff -and Enabled -eq $true} `
    -Properties LastLogonDate
$report += "`nINACTIVE USERS (90+ days): $($inactive.Count)"

# Save and display
$report | Out-File "C:\Reports\SecurityAudit-$(Get-Date -Format 'yyyy-MM-dd').txt"
$report | ForEach-Object { Write-Host $_ }
```

---

## HANDS-ON PRACTICE

```powershell
# Lab 1: Explore your own system
Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, CsTotalPhysicalMemory
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5
Get-Service | Where-Object {$_.Status -eq "Running"} | Measure-Object

# Lab 2: File system practice
New-Item -Path "$env:TEMP\PSLab" -ItemType Directory
1..5 | ForEach-Object { New-Item "$env:TEMP\PSLab\file$_.txt" -ItemType File }
Get-ChildItem "$env:TEMP\PSLab"
Remove-Item "$env:TEMP\PSLab" -Recurse

# Lab 3: Network info
Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4"}
Get-NetTCPConnection | Where-Object {$_.State -eq "Established"} | Select-Object -First 10
Test-NetConnection -ComputerName "google.com" -Port 443
```

---

## MOCK INTERVIEW Q&A

**Q: How would you find all users in Active Directory who haven't logged in for 90 days?**
> "I'd use Get-ADUser with a filter on LastLogonDate — something like `Get-ADUser -Filter {LastLogonDate -lt $cutoff -and Enabled -eq $true} -Properties LastLogonDate` where cutoff is today minus 90 days. I'd pipe that to Export-Csv to generate a report for review. Inactive accounts are a security risk — they should be disabled or removed."

**Q: How would you script the offboarding of a terminated employee?**
> "I'd disable the account immediately with Disable-ADAccount, remove them from all security groups, reset their password, move the account to a Disabled OU, and set an account expiration date. I'd also check for any shared mailboxes or resources they owned and transfer ownership. All steps would be logged."

**Q: What's the difference between PowerShell remoting and RDP?**
> "RDP gives you a full graphical desktop session — it's interactive but resource-heavy and harder to automate. PowerShell remoting via Invoke-Command lets you run scripts and commands on remote machines without a GUI — it's lightweight, scriptable, and can target dozens of machines simultaneously. For sysadmin automation, PSRemoting is far more powerful."

**Q: How do you use PowerShell for security monitoring?**
> "I'd use Get-WinEvent to query the Security event log for specific Event IDs — 4625 for failed logons, 4720 for account creation, 4732 for group membership changes. These can be piped to a report or alerts. Combined with scheduled tasks, you can have automated daily security audit scripts that flag anomalies."

---

## KEY TERMS CHEAT SHEET

| Term | Meaning |
|------|---------|
| Cmdlet | A PowerShell command (Get-Process, Set-ADUser, etc.) |
| Pipeline | `\|` passes output of one cmdlet as input to next |
| Object | Everything in PS is an object with properties and methods |
| Module | A package of cmdlets (ActiveDirectory, NetSecurity, etc.) |
| PSRemoting | Running PS commands on remote machines |
| WMI/CIM | Windows Management Instrumentation — query hardware/OS info |
| Event ID | Windows event log code (4625 = failed login, etc.) |
| OU | Organizational Unit — folder structure in Active Directory |
| GPO | Group Policy Object — enforces settings across machines |
| SID | Security Identifier — unique ID for every user/group |

---

## RESOURCES

- **Microsoft Learn** — learn.microsoft.com/powershell (free, official)
- **TryHackMe** — "Hacking with PowerShell" room
- **PowerShell Gallery** — powershellgallery.com (community scripts)
- **SS64.com** — quick reference for all PS cmdlets

## CERT ROADMAP
1. **Microsoft MD-102** — Endpoint Administrator (covers PS + AD heavily)
2. **AZ-104** — Azure Administrator (cloud AD, PS automation)
3. **SC-300** — Identity and Access Administrator (AD security focused)

---
*Part of the DeNOVO Cybersecurity Specialist 1 Job Prep Series*
*Justin Youngs | Jyoungs42433@gmail.com*
