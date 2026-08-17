-- Helper function to check DRM connection status (matches 'connected' strictly)
local function is_any_connected(outputs)
    for _, name in ipairs(outputs) do
        local handle = io.popen("cat /sys/class/drm/*" .. name .. "/status 2>/dev/null")
        if handle then
            local result = handle:read("*a")
            handle:close()
            if result:match("^connected") then
                return true
            end
        end
    end
    return false
end

-- Helper function to configure a group of monitors
local function configure_monitors(outputs, config)
    for _, name in ipairs(outputs) do
        local cfg = {}
        for k, v in pairs(config) do cfg[k] = v end
        cfg.output = name
        hl.monitor(cfg)
    end
end

-- Core monitor layout handler
local function update_monitors()
    local external_displays = { "DP-1", "DP-2" }
    local laptop_displays   = { "eDP-1", "eDP-2" }

    local external_connected = is_any_connected(external_displays)

    -- Configure external monitors
    configure_monitors(external_displays, {
        mode = "3840x2160@240",
        position = "auto",
        scale = 1.666,
    })

    -- Configure laptop monitors (Disabled if an external monitor is plugged in)
    configure_monitors(laptop_displays, {
        mode = "2560x1600@120",
        disabled = external_connected,
        position = "auto",
        scale = 1.666,
    })

    -- Fallback
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
end

-- Executed when script/config loads
update_monitors()

-- Dynamic hotplug event listeners with timer-delayed reload
hl.on("monitor.added", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl reload"))
    end, { timeout = 10, type = "oneshot" })
end)

hl.on("monitor.removed", function()
    -- 250ms allows the kernel sysfs to update state to 'disconnected' before reloading
    hl.timer(function()
        hl.dispatch(hl.dsp.exec_cmd("hyprctl reload"))
    end, { timeout = 10, type = "oneshot" })
end)
