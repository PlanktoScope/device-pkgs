#!/bin/bash -eux

script_dir="$(dirname $(realpath "$BASH_SOURCE"))"

serial_number="$(tr -d '\0' < /sys/firmware/devicetree/base/serial-number | cut -c 9-)"
machine_name="$(/usr/bin/machine-name name --format=hex --sn="$serial_number")"

# Update /var/run/planktoscope/cockpit-origins
mkdir -p /var/run/planktoscope
cp "$script_dir/cockpit-origins-base" /var/run/cockpit-origins
sed "s/{machine-name}/$machine_name/g" "$script_dir/cockpit-origins-machine-name" \
  >> /var/run/planktoscope/cockpit-origins
if [ -f "/etc/planktoscope/cockpit-origins" ]; then
  sed "s/{machine-name}/$machine_name/g" /etc/planktoscope/cockpit-origins \
    >> /var/run/planktoscope/cockpit-origins
fi

# Update /etc/cockpit/cockpit.conf
origins="$(sed 's/#.*$//g' /var/run/planktoscope/cockpit-origins | sed '/^$/d' | paste -s -d ' ')"
sed -i "s~^Origins = .*$~Origins = ${origins}~g" /etc/cockpit/cockpit.conf
