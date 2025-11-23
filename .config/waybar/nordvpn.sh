#!/bin/bash

CONNECTED=$(nordvpn status | grep Status | awk -F ": " '{ print $2 }') 

if [[ "$CONNECTED" == "Connected" ]]; then
  city=$(nordvpn status | grep City | awk -F ": " '{ print $2 }')
  echo " $city"
else
  echo "  $CONNECTED"
fi

