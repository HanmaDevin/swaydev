#!/bin/bash

wireguard=$(ifconfig | rg "wg0")
proton=$(nmcli c | rg "Proton" | awk -F' ' '{printf "%s %s", $1, $2}')
openvpn=$(ifconfig | rg "tun0")

if [[ ! -z "$proton" ]]; then
  echo "$proton"
elif [[ ! -z "$wireguard" || ! -z "$openvpn" ]]; then
  echo " VPN"
else
  echo " Off"
fi
