hl.on("hyprland.start", function()
    hl.exec_cmd("[workspace 1 silent] " .. Terminal)
    hl.exec_cmd("[workspace 2 silent] " .. Browser)
    hl.exec_cmd("[workspace 4 silent] sleep 1 && " .. MusicPlayer)

    -- TODO: find out why this is using sleep lol
    hl.exec_cmd("sleep 1 && caelestia-shell")
end)
