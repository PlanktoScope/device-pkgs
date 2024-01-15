#!/bin/bash -eux

script_dir="$(dirname $(realpath "$BASH_SOURCE"))"
templates_dir="$script_dir/templates"

serial_number="$(tr -d '\0' < /sys/firmware/devicetree/base/serial-number | cut -c 9-)"
machine_name="$(/usr/bin/machine-name name --format=hex --sn="$serial_number")"

if [ -f /etc/planktoscope/hostapd-ssid ]; then
  ssid="$(sed "s/{machine-name}/$machine_name/g" /etc/planktoscope/hostapd-ssid | sed 's/#.*$//g' | sed '/^$/d')"
else
  ssid="$(sed "s/{machine-name}/$machine_name/g" "$templates_dir/ssid" | sed 's/#.*$//g' | sed '/^$/d')"
fi
mkdir -p /var/lib/planktoscope
printf "%s" "$ssid" > /var/lib/planktoscope/hostapd-ssid
sed -i "s/^ssid=.*$/ssid=$ssid/g" /etc/hostapd/hostapd.conf
