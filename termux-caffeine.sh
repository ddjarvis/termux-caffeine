#!/usr/bin/env bash

# Check if ADB is installed. Install if not.
which adb &>/dev/null || {
  pkg update && pkg upgrade -y
  pkg install android-tools termux-am -y
}

# Prompt User to Enable Wireless Debugging
printf "\n%$((($(tput cols)-53)/2))s\033[1;93m%s\033[4m%s\033[0m\n\n" "" "Go to Developer Options and enable " "WIRELESS DEBUGGING"
printf "%$((($(tput cols)-27)/2))s\033[1;97m%s\033[0m\n\n" "" "once it has been enabled..."
printf "%$((($(tput cols)-25)/2))s\033[1;92m%s\033[0m\n\n" "" "Press [Enter] to continue"
sleep 1s
am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS &>/dev/null
read -s

#Connect to ADB
adb connect localhost:$(nmap localhost -p 37000-44000 | grep -Po "\d{5}(?=\/tcp)") &>/dev/null

#Run Commands
if (adb devices | grep -q "\bdevice\b"); then

  # Prevents config reset on reboots
  adb shell device_config set_sync_disabled_for_tests persistent

  # Increase.limit for app child process -- this is a huge Termux killer
  adb shell device_config put activity_manager max_phantom_processes 2147483647

  # Disable monitoring of phantom processees (child process running in bg, still related to previous command)
  adb shell settings put global settings_enable_monitor_phantom_procs false

  # Disable battery optimization for termux
  adb shell cmd deviceidle whitelist +com.termux

  # Various permissions that allow termux and child processes to run in the background
  adb shell cmd appops set com.termux RUN_IN_BACKGROUND allow
  adb shell cmd appops set com.termux RUN_ANY_IN_BACKGROUND allow
  adb shell cmd appops set com.termux SYSTEM_EXEMPT_FROM_ACTIVITY_BG_START_RESTRICTION allow
  adb shell cmd appops set com.termux SYSTEM_EXEMPT_FROM_HIBERNATION allow
  adb shell cmd appops set com.termux SYSTEM_EXEMPT_FROM_POWER_RESTRICTIONS allow
  adb shell cmd appops set com.termux SYSTEM_EXEMPT_FROM_SUSPENSION allow
  adb shell cmd appops set com.termux WAKE_LOCK allow
else
  echo "Failed to connect to ADB. Please try connecting manually and re-run this section of the script."
fi
