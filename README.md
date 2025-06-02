# USB Security Monitoring with Twilio SMS Alerts

## Problem Statement

In many academic or workplace environments, sensitive data and system integrity are at risk when unauthorized USB devices are connected to a computer. USB drives can be a major threat vector introducing malware, stealing data, or bypassing system policies. This is especially critical in shared systems or personal laptops in public settings.

Often, users forget or are unaware when a new USB device is connected to their machines and there's no default OS-level alert or restriction system for this.

### So how do we make our machine alert-aware and secure ?

## Solution for this we created a lightweight **USB Monitoring and Intrusion Detection System** that:
- Monitors new USB connections in real-time
- Checks if the device is whitelisted
- Prompts for a password if it's unknown
- Sends **SMS alerts via Twilio** if an unauthorized device is detected
- Disables the device if the correct password is not provided

## Why PowerShell?

PowerShell is built into all modern Windows systems, giving direct access to system-level components like USB devices through commands like `Get-PnpDevice`. It's also:
- Scriptable and lightweight
- Does not require external runtime environments and dependencies
- Capable of making REST API calls (like Twilio)
- Perfect for quick automation and real-time monitoring

---

## Features
- Built using native PowerShell - no external dependencies
- Whitelisting of approved USB devices  
- Real-time USB monitoring  
- Automatic SMS alert via Twilio for unauthorized devices  
- Manual password prompt to allow/block new devices  
- Stores approved devices in a local file for future runs  
- CLI-based interactive experience  


---

##  Requirements
```
 Requirements                   Version / Note   

 **Windows OS**            -    Windows 10 or later                        
 **PowerShell**            -    Version 5.1+ (Default in Win10+)           
 **Administrator Mode**    -    Required (for blocking USB devices)        
 **Twilio Account**        -    For sending SMS                            
```
---

##  Must Enable These on Android before using:

If you're testing this using your **Android device as a USB device**, please ensure the following:

1. **Developer Mode** is enabled  
    *Settings > About phone > Tap "Build number" 7 times*

2. **USB Debugging** is turned on  
    *Settings > Developer options > Enable "USB debugging"*

These settings ensure that the phone shows up as a USB device on Windows and can be monitored by the PowerShell script.

---

## 📁 Project Structure
```
USB-Monitor/
│
├── MonitorUSB.ps1 # main .ps1 script
├── .env # Twilio credentials, The recipient number where SMS alerts will be sent.
├── approved_usb.txt # Automatically created file to store allowed USBs
├── README.md 

```


---

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Beno-Jeffry-B/USB-Security-Monitoring-Twilio-Alerts.git
cd usb-monitor
```

### 2. Setup Environment Variables
    Note: Make sure your Twilio number is SMS-capable and verified.
```
TWILIO_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=+1234567890
YOUR_PHONE_NUMBER=+0987654321

```

### 3. Run the Script

Open PowerShell as Administrator (This is mandatory to allow blocking USB devices.)

Run the Script

```
.\monitor.ps1

```


### What Happens on Detection?

A new USB device is detected.

If it's not in the whitelist or previously approved list:

You're asked to enter a password to allow it.

If wrong: The device is disabled and an SMS alert is sent to your phone.

If correct: The device is approved for this and future sessions.

### Note on Monitoring Behavior
Once the monitoring starts, the script continuously scans all USB ports. If a whitelisted device is already connected, you may see repeated messages indicating that the device is "already approved." This is expected behavior as the script checks all ports in real-time. Don't be alarmed  it's simply confirming that your secured device remains connected.


### Approved Devices Persistence
Once a device is approved: Its ID is saved in approved_usb.txt . On the next script run, it will automatically allow it .No need to re-approve manually every time.

### ⚠️Security Note
This is a lightweight client-side script for educational or personal use. Do not rely on it for enterprise-grade USB control. 



### 🤝 Contribution
Feel free to fork this repo, suggest features (e.g., email alerts, GUI support), or raise issues!
Built with 💙 to protect your system from sneaky USB attacks.