-- Helper function: Returns true if ANY output in the list is connected
local function is_any_connected(outputs)
    for _, name in ipairs(outputs) do
        local handle = io.popen("cat /sys/class/drm/*" .. name .. "/status 2>/dev/null")
        if handle then
            local result = handle:read("*a")
            handle:close()
            if result:find("connected") then
                return true
            end
        end
    end
    return false
end

-- Helper function: Applies a monitor config table to multiple outputs
local function configure_monitors(outputs, config)
    for _, name in ipairs(outputs) do
        local cfg = {}
        for k, v in pairs(config) do cfg[k] = v end -- shallow copy
        cfg.output = name
        hl.monitor(cfg)
    end
end

-- Monitor groups
local external_displays = { "DP-1", "DP-2" }
local laptop_displays   = { "eDP-1", "eDP-2" }

-- Check if any external monitor is plugged in
local external_connected = is_any_connected(external_displays)

-- Configure external monitors
configure_monitors(external_displays, {
    mode = "3840x2160@240",
    position = "auto",
    scale = 1.666,
})

-- Configure internal laptop monitors (Disabled IF an external monitor is connected)
configure_monitors(laptop_displays, {
    mode = "2560x1600@120",
    disabled = external_connected,
    position = "auto",
    scale = 1.666,
})

-- Fallback for any unhandled outputs
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
