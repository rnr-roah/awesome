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

#run "nitrogen --restore"

#starting transparency tool

run "picom"

#starting volume icon
run "volumeicon"

#starting pulse audio manager

##run "pavucontrol &&"

#starting brave in background

##run "brave &&"

