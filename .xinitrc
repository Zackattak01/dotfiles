#!/bin/sh
# Boilerplate
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi


if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# My config

# set the environment
export IS_DESKTOP=true
graphics="$(envycontrol --query)"
if [[ $graphics == "nvidia" ]]; then
	xrandr --setprovideroutputsource modesetting NVIDIA-0
	xrandr --auto
	~/.screenlayout/layout-nvidia.sh
	#~/.screenlayout/layout-home.sh
elif [[ $graphics == "integrated" ]]; then
	~/.screenlayout/layout-integrated.sh
    IS_DESKTOP=false
else
	~/.screenlayout/layout.sh
fi


# start some nice programs
cbatticon &
udiskie &
polkit-dumb-agent &

# awesome session
picom &
exec awesome

# gnome session
#export XDG_SESSION_TYPE=x11
#export GDK_BACKEND=x11
#exec gnome-session
