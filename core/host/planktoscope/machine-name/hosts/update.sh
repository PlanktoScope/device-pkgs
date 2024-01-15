#!/bin/bash -eux

script_dir="$(dirname $(realpath "$BASH_SOURCE"))"
templates_dir="$script_dir/templates"

serial_number="$(tr -d '\0' < /sys/firmware/devicetree/base/serial-number | cut -c 9-)"
machine_name="$(/usr/bin/machine-name name --format=hex --sn="$serial_number")"

# Update /var/lib/planktoscope/hosts
cp "$templates_dir/base" /var/lib/planktoscope/hosts
sed "s/{machine-name}/$machine_name/g" "$templates_dir/machine-name" \
  >> /var/lib/planktoscope/hosts
if [ -f "/etc/planktoscope/hosts" ]; then
  sed "s/{machine-name}/$machine_name/g" /etc/planktoscope/hosts \
    >> /var/lib/planktoscope/hosts
fi
