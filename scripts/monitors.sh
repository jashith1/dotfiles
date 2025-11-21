# just using kanshi since this is worse but still could be useful in the future

# detect laptop display name (eDP-1 or eDP-2)
LAPTOP=$(hyprctl monitors all | grep -Eo 'eDP-[0-9]')

# check if ANY external monitor is connected
EXT=$(hyprctl monitors all | grep -Eo '(^| )DP-[0-9]|(^| )HDMI-A-[0-9]')

if [ -n "$EXT" ]; then
    # external monitor exists so disable laptop screen
    hyprctl keyword monitor "$EXT, 3840x2160@240, 0x0, 1.5"
    hyprctl keyword monitor "$LAPTOP, disable"
else
    # no external monitors so enable laptop screen
    hyprctl keyword monitor "$LAPTOP, 1920x1200@120, 0x0, 1"
fi

