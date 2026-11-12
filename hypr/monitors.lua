-- Returns the names of all connected external outputs (anything that isn't eDP/Writeback)
local function connected_externals()
    local found = {}
    local handle = io.popen("grep -l '^connected' /sys/class/drm/card*-*/status 2>/dev/null")
    if not handle then return found end
    for path in handle:lines() do
        local name = path:match("/card%d+%-(.-)/status$")
        if name and not name:match("^eDP") and not name:match("^Writeback") then
            table.insert(found, name)
        end
    end
    handle:close()
    return found
end

-- Per-output scale overrides for external monitors (default 1)
local external_scales = {
    ["DP-1"] = 1.666,
    ["DP-2"] = 1.666,
}

-- Core monitor layout handler
local function update_monitors()
    local laptop_displays = { "eDP-1", "eDP-2" }
    local externals = connected_externals()

    -- External monitors: highest resolution, then highest refresh rate
    for _, name in ipairs(externals) do
        hl.monitor({
            output = name,
            mode = "highres",
            position = "auto",
            scale = external_scales[name] or 1,
        })
    end

    -- Laptop monitors: disabled whenever an external monitor is plugged in
    for _, name in ipairs(laptop_displays) do
        hl.monitor({
            output = name,
            mode = "2560x1600@120",
            disabled = #externals > 0,
            position = "auto",
            scale = 1.666,
        })
    end

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
