local mainMod = "SUPER"
local terminal = "kitty"
local forceWayland = "--enable-features=UseOzonePlatform --ozone-platform=wayland"
local browser = "firefox"
local altBrowser = "chromium " .. forceWayland

-- Shell / Environment Toggles
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("pkill quickshell; pkill hyprpaper; pkill waybar; caelestia-shell"))
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd("pkill quickshell; pkill waybar; waybar & pkill hyprpaper; hyprpaper"))

-- Launching Applications
hl.bind(mainMod .. " + space", hl.dsp.global("caelestia:launcher"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(altBrowser))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("spotify " .. forceWayland))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus -w"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("tor-browser"))

-- Changing Focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())

-- Swapping Windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

-- Fullscreen and Maximize
hl.bind("F11", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Resize Window (binde -> repeating = true)
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

-- Switch Workspaces & Move Windows (Keys 1-9, 0)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace Relative Bracket Navigation
hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1" }))

-- Media & Audio Control
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })

-- 60% Keyboard Media Binds
hl.bind("CTRL + SHIFT + L", hl.dsp.exec_cmd("playerctl next"))
hl.bind("CTRL + SHIFT + K", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("CTRL + SHIFT + J", hl.dsp.exec_cmd("playerctl previous"))

-- Screenshots (NixOS)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("grimblast copysave area"))

-- Screen Locking
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("test-sddm-silent"))

-- Laptop Screen Toggle
--hl.bind(mainMod .. " + ALT + 1", hl.dsp.exec_cmd("hyprctl keyword monitor 'eDP-1,1920x1200@120,auto,1.2' && hyprctl keyword monitor 'eDP-2,1920x1200@120,auto,1.2'"))
hl.bind(mainMod .. " + ALT + 1", function()
    hl.monitor({ output = "eDP-1", mode = "1920x1200@120", position = "auto", scale = 1.2 })
    hl.monitor({ output = "eDP-2", mode = "1920x1200@120", position = "auto", scale = 1.2 })
end)
hl.bind(mainMod .. " + ALT + 2", function()
    hl.monitor({ output = "eDP-1", disabled = true })
    hl.monitor({ output = "eDP-2", disabled = true })
end)

-- Brightness
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
