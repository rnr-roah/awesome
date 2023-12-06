#!/usr/bin/env bash
function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}
#starting power manager

run "xfce4-power-manager"

#restoring wallpaper

run "nitrogen --restore"
#run "variety"
#starting transparency tool

#run "picom"
#run "compton"
run "xcompmgr"

#starting volume icon
run "volumeicon"

#starting kdeconnect indicator
run "kdeconnect-indicator"

#starting thunderbird in bg
run "thunderbird --headless"

##run "pavucontrol &&"

#starting brave in background

##run "brave &&"

