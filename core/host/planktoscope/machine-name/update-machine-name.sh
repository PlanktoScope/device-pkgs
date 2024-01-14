#!/bin/bash -eux

serial_number="$(tr -d '\0' < /sys/firmware/devicetree/base/serial-number | cut -c 9-)"
machine_name="$(/usr/bin/machine-name name --format=hex --sn="$serial_number")"

# Update /var/lib/planktoscope/machine-name
# Note: this assumes that the script is run with root permissions
mkdir -p /var/lib/planktoscope
printf "%s" "$machine_name" > /var/lib/planktoscope/machine-name
