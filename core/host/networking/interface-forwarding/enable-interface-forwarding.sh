#!/bin/bash -eux

route_between() {
  local interface_a="$1"
  local interface_b="$2"

  iptables -t nat -A POSTROUTING -o "$1" -j MASQUERADE
  iptables -A FORWARD -i "$1" -o "$2" -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A FORWARD -i "$2" -o "$1" -j ACCEPT
  iptables -t nat -A POSTROUTING -o "$2" -j MASQUERADE
  iptables -A FORWARD -i "$2" -o "$1" -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A FORWARD -i "$1" -o "$2" -j ACCEPT
}

redirect_inbound() {
  local interface="$1"
  local ipaddr="$2"

  iptables -t nat -A PREROUTING -i "$interface" -d "$ipaddr" -j DNAT --to-destination 127.0.0.1
}

# Route packets between network interfaces
# Note: system performance degrades too much if we add too many interfaces here
joined_interfaces=(wlan0 wlan1 eth0 eth1 usb0)
for i in ${!joined_interfaces[@]}; do
  for j in ${!joined_interfaces[@]}; do
    if [ "$j" -le "$i" ]; then
      continue
    fi
    route_between "${joined_interfaces[$i]}" "${joined_interfaces[$j]}"
  done
done

# Redirect external incoming traffic bound for the device to 127.0.0.1
redirect_inbound wlan1 192.168.3.1
redirect_inbound wlan0 192.168.4.1
redirect_inbound eth0 192.168.5.1
redirect_inbound usb0 192.168.6.1
redirect_inbound eth1 192.168.7.1
