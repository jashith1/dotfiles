-- home monitor
hl.monitor({
    output = "DP-1",
    mode = "3840x2160@240",
    position = "auto",
    scale = 1.666,
})

-- laptop monitor
hl.monitor({
    output = "eDP-1",
    mode = "2560x1600@120", -- NOTE: full laptop resolution + refresh rate
    -- mode = "1920x1200@60", -- NOTE: Reduced laptop resolution + refresh rate
    disabled = true, -- NOTE: Disable laptop screen
    position = "auto",
    scale = 1.666,
})


--generic monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
