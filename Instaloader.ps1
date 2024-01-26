<#
Script Name: Instaloader Remote Server script
Description: This script automates Instagram session import, WinSCP file transfer, and profile list updates.
Requirements: 
  - Firefox browser
  - 615_import_firefox_session.py
  - Instaloader installed on remove server
  - WinSCP installed and available in PATH
  - SFTP server with ssh key setup
#>

Write-Host @"
 _____           _        _                 _           
|_   _|         | |      | |               | |          
  | |  _ __  ___| |_ __ _| | ___   __ _  __| | ___ _ __ 
  | | | '_ \/ __| __/ _`  | |/ _ \ / _`  |/ _`  |/ _ \ '__|
 _| |_| | | \__ \ || (_| | | (_) | (_| | (_| |  __/ |   
|_____|_| |_|___/\__\__,_|_|\___/ \__,_|\__,_|\___|_|   

                                        by Jarsky  

"@

# Variables
$firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
$sessionFilePath = "C:\Users\User\AppData\Local\Instaloader\session-filename"
$pythonFirefoxSessionImport = "C:\Users\User\AppData\Local\Instaloader\615_import_firefox_session.py"
$timeThreshold = 300 # seconds
$privateKeyPath = "C:\Users\User\Keys\mysshkey.ppk"
$hostKey = "ssh-ed25519 255 myhosthash"
$logFilePath = "C:\temp\winscp.log"
$remotePath = "/opt/instaloader/config"
$sftpUrl = "sftp://user@myftpserver.com"
$profilesFile = "profiles.txt"

# Functions
function Start-Firefox {
    if (Get-Process -name "firefox" -ErrorAction SilentlyContinue) {
        Write-Host "[INFO] Firefox is running."
    } else {
        Write-Host "[INFO] Firefox is not running. Starting Firefox..."
        Start-Process $firefoxPath "https://www.instagram.com"
        Start-Sleep -Seconds 3
        Start-Firefox
    }
}

function Invoke-FireFoxImport {
		Write-Host "[INFO] Starting Firefox session import..."
			$process = Start-Process -FilePath "python" -ArgumentList "$pythonFirefoxSessionImport" -Wait -PassThru

			if ($process.ExitCode -eq 0) {
				Write-Host "[INFO] Firefox session import completed successfully."
			} else {
				Write-Host "[ERROR] Firefox session import encountered an error. Please check and try again."
				Pause
				Exit 1
        }
}

function Invoke-WinSCPTransfer {
	Write-Host "[INFO] Checking if WinSCP is available..."

	$winscpPath = Get-Command -Name "winscp.com" -ErrorAction SilentlyContinue
	if ($winscpPath) {
		Write-Host "[INFO] WinSCP is available."
	} else {
		Write-Host "[ERROR] WinSCP (winscp.com) is not in your PATH environment variable."
		Write-Host "Please make sure WinSCP is installed and added to your PATH."
		Pause
		Exit 1
	}
	Write-Host "[INFO] Transferring session file..."

	if (-Not (Test-Path -Path $sessionFilePath)) {
		Write-Host "[ERROR] Session file not found at: $sessionFilePath"
		Pause
		Exit 1
	}

	$winscpScript = @"
	option batch abort
	option confirm off
	open $sftpUrl -privatekey="$privateKeyPath" -hostkey="$hostKey"
	put "$sessionFilePath" $remotePath
	exit
"@

	$winscpScriptPath = [System.IO.Path]::GetTempFileName()
	$winscpScript | Out-File -FilePath $winscpScriptPath -Encoding utf8

	Start-Process -FilePath "winscp.com" -ArgumentList "/ini=nul /log=`"$logFilePath`" /script=`"$winscpScriptPath`"" -Wait

	if ($?) {
		Write-Host "[INFO] File transfer completed successfully."
	} else {
		Write-Host "[ERROR] There was an error during the file transfer. Check the log at $logFilePath"
		Pause
		Exit 1
	}
}

function Invoke-ProfileUpdate {
        $winscpScript = @"
        option batch abort
        option confirm off
        open $sftpUrl -privatekey="$privateKeyPath" -hostkey="$hostKey"
        put "$localProfilesPath" "$remotePath/$profilesFile"
        exit
"@

        $winscpScriptPath = [System.IO.Path]::GetTempFileName()
        $winscpScript | Out-File -FilePath $winscpScriptPath -Encoding utf8

        Start-Process -FilePath "winscp.com" -ArgumentList "/ini=nul /log=`"$logFilePath`" /script=`"$winscpScriptPath`"" -Wait

        if (-not $?) {
            Write-Host "[ERROR] There was an error while updating the profiles list on the server. Check the log at $logFilePath"
            Pause
            Exit 1
        }

        Remove-Item -Path $localProfilesPath -Force
        Write-Host "[INFO] Profiles list updated successfully."
        $updateProfiles = Read-Host "Do you want to update the list of profiles (Y/n)?"
		Write-Host "[INFO] No more updates to profiles list."
}

function Update-ProfilesList {
    $updateProfiles = "Y"

    while ($updateProfiles -eq "Y" -or $updateProfiles -eq "y") {
        Write-Host "[INFO] Updating profiles list..."
        
        $localProfilesPath = "$env:TEMP\$profilesFile"
        $winscpScript = @"
        option batch abort
        option confirm off
        open $sftpUrl -privatekey="$privateKeyPath" -hostkey="$hostKey"
        get "$remotePath/$profilesFile" "$localProfilesPath"
        exit
"@

        $winscpScriptPath = [System.IO.Path]::GetTempFileName()
        $winscpScript | Out-File -FilePath $winscpScriptPath -Encoding utf8

        Start-Process -FilePath "winscp.com" -ArgumentList "/ini=nul /log=`"$logFilePath`" /script=`"$winscpScriptPath`"" -Wait

        if (-not $?) {
            Write-Host "[ERROR] There was an error while updating the profiles list. Check the log at $logFilePath"
            Pause
            Exit 1
        }

        $profiles = Get-Content -Path $localProfilesPath
        $profiles | ForEach-Object { Write-Host "$($_.ReadCount). $_" }

        $action = Read-Host "Do you want to (1) Add or (2) Remove profiles? (Press Enter to skip)"

        if ($action -eq "1") {
            $newProfile = Read-Host "Enter the new profile name"
            Add-Content -Path $localProfilesPath -Value "$newProfile"
			Invoke-ProfileUpdate
            Write-Host "[INFO] Profile '$newProfile' added successfully."
        }
        elseif ($action -eq "2") {
            $indexToRemove = Read-Host "Enter the number of the profile to remove"
            if ($indexToRemove -ge 1 -and $indexToRemove -le $profiles.Count) {
                $profiles = $profiles | Where-Object { $_.ReadCount -ne $indexToRemove }
                Set-Content -Path $localProfilesPath -Value ($profiles -join "`n")
				Invoke-ProfileUpdate
                Write-Host "[INFO] Profile at position $indexToRemove removed successfully."
            } else {
                Write-Host "[ERROR] Invalid selection. Please choose a valid number."
                Pause
                Exit 1
            }
        } else {
            Write-Host "[INFO] No action taken."
			Pause
			Exit 1
        }
	}
}


# Main Script

Start-Firefox
Write-Host "[INFO] Please login to Instagram.."
Start-Process $firefoxPath -ArgumentList "https://www.instagram.com/accounts/login", "-new-tab"
Start-Sleep -Seconds 10
Write-Host "[INFO] Triggering Firefox session import..."

if (-Not (Test-Path -Path $sessionFilePath)) {
    Write-Host "[ERROR] Session file not found at: $sessionFilePath"
    Pause
    Exit 1
}

$fileTime = (Get-Item $sessionFilePath).LastWriteTime
$currentTime = Get-Date

$timeDiff = ($currentTime - $fileTime).TotalSeconds

if ($timeDiff -le $timeThreshold) {
    Write-Host "[WARNING] Session file modified in the last $timeThreshold seconds."

    $choice = Read-Host "Do you want to continue (Y/n)?"

    if ($choice -ne "Y" -and $choice -ne "y") {
        Write-Host "[INFO] Skipping session import. Proceeding to profile list update."
    } else {
        Write-Host "[INFO] Continuing with session import..."
        Start-Sleep -Seconds 5
    try {
		Invoke-FireFoxImport
		Invoke-WinSCPTransfer
        }
    catch {
            Write-Host "[ERROR] An error occurred while running the Python script: $_"
            Pause
            Exit 1
        }
    }
	} else {
		Write-Host "[WARNING] Session file has not been modified in the last $timeThreshold seconds."
		
		Write-Host "[INFO] Continuing automatically..."
		Start-Sleep -Seconds 5
	try {
		Invoke-FireFoxImport
		Invoke-WinSCPTransfer
		}
	catch {
			Write-Host "[ERROR] An error occurred while running the Python script: $_"
			Pause
			Exit 1
    }
}

$updateProfiles = Read-Host "Do you want to update the list of profiles (Y/n)?"

if ($updateProfiles -eq "Y" -or $updateProfiles -eq "y") {
    Update-ProfilesList
}

Write-Host "[INFO] Closing Firefox."
Stop-Process -Name "firefox" -Force
Write-Host "[INFO] Done."
Start-Sleep -Seconds 5