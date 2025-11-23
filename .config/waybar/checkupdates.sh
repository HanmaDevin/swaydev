#!/bin/bash

icon="󰚰"
updates=$(checkupdates | wc -l)
aur=$(yay -Qu | wc -l)
echo $icon $(($updates + $aur))
