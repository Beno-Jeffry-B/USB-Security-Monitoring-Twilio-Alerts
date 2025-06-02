
function Load-EnvVars {
    $envPath = Join-Path -Path $PSScriptRoot -ChildPath ".env"
    if (Test-Path $envPath) {
        Get-Content $envPath | ForEach-Object {
            if ($_ -match "^\s*([^#][^=]+?)\s*=\s*(.+)\s*$") {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim()
                [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
    }
}
Load-EnvVars

# API Credentials
$twilioSID = $env:TWILIO_SID
$twilioAuthToken = $env:TWILIO_AUTH_TOKEN
$twilioPhoneNumber = $env:TWILIO_PHONE_NUMBER
$yourPhoneNumber = $env:YOUR_PHONE_NUMBER

# whitelisted USB devices
$whitelistedUSBs = @("USB\VID_1234&PID_5678")  # Add allowed USB IDs
$password = "Secure123"  # Your desired password

# approved USBs (used file handling for persistance)
$approvedUSBsPath = Join-Path -Path $PSScriptRoot -ChildPath "approvedUSBs.txt"
$approvedUSBs = @()

# load approved USBs from file if it exists
if (Test-Path $approvedUSBsPath) {
    $approvedUSBs = Get-Content $approvedUSBsPath | Where-Object { $_ -ne "" }
}

# save approved USBs to file
function Save-ApprovedUSB($usbID) {
    if ($usbID -notin $approvedUSBs) {
        Add-Content -Path $approvedUSBsPath -Value $usbID
        $approvedUSBs += $usbID
    }
}

# get connected USB devices
function Get-USBDevices {
    Get-PnpDevice -Class USB -Status OK | Select-Object InstanceId, FriendlyName
}

# display approved USB devices
function Show-ApprovedUSBs {
    $connectedUSBs = Get-USBDevices
    $approvedList = $connectedUSBs | Where-Object { $_.InstanceId -in $whitelistedUSBs -or $_.InstanceId -in $approvedUSBs }

    if ($approvedList.Count -eq 0) {
        Write-Host "No approved USB devices found."
    } else {
        Write-Host "`n[+] Approved USB Devices (Currently Connected):"
        foreach ($usb in $approvedList) {
            Write-Host " - $($usb.FriendlyName) ($($usb.InstanceId))"
        }
    }
}

# send SMS using Twilio
function Send-SMSNotification {
    $twilioAuthHeader = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${twilioSID}:${twilioAuthToken}"))
    $messageBody = @{
        To = $yourPhoneNumber
        From = $twilioPhoneNumber
        Body = "Unauthorized USB device detected! Please check your laptop."
    }

    Invoke-RestMethod -Uri "https://api.twilio.com/2010-04-01/Accounts/${twilioSID}/Messages.json" `
        -Method Post `
        -Headers @{Authorization=("Basic {0}" -f $twilioAuthHeader)} `
        -ContentType "application/x-www-form-urlencoded" `
        -Body $messageBody
}

# block unauthorized USB device
function Disable-USBDevice($deviceID) {
    Write-Host "Disabling USB Device: $deviceID"
    Get-PnpDevice | Where-Object { $_.InstanceId -eq $deviceID } | Disable-PnpDevice -Confirm:$false
}

# monitor USB devices continuously
function Monitor-USB {
    Write-Host "`nMonitoring USB devices..."
    $initialUSBs = Get-USBDevices

    while ($true) {
        Start-Sleep -Seconds 2
        $currentUSBs = Get-USBDevices
        $newUSBs = Compare-Object -ReferenceObject $initialUSBs -DifferenceObject $currentUSBs -Property InstanceId | Where-Object { $_.SideIndicator -eq "=>" }

        if ($newUSBs) {
            foreach ($usb in $newUSBs) {
                $usbID = $usb.InstanceId
                $usbName = $usb.FriendlyName

                if ($usbID -in $approvedUSBs) {
                    Write-Host "Already Approved: $usbName"
                    continue
                }

                Write-Host "`n[+] New USB Inserted: $usbName ($usbID)"

                if ($whitelistedUSBs -contains $usbID) {
                    Write-Host "Whitelisted USB detected: $usbName"
                } else {
                    Write-Host "Unauthorized USB detected!"
                    $userInput = Read-Host "Enter Password to Allow Access"

                    if ($userInput.Trim() -eq $password) {
                        Write-Host "Access Granted!"
                        Save-ApprovedUSB $usbID
                    } else {
                        Write-Host "Incorrect Password! Blocking USB..."
                        Disable-USBDevice $usbID
                        Send-SMSNotification
                    }
                }
            }
        }
    }
}

# show approved USBs if user wants
$userChoice = Read-Host "Do you want to see the already approved USB devices? (yes/no)"
if ($userChoice -match "^(y|yes)$") {
    Show-ApprovedUSBs
}

# Start monitoring
Monitor-USB
