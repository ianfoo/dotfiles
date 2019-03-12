appNameHotkeys = {
    ["Brave Browser"] = "B",
    ["GoLand"] = "G",
    ["Google Chrome"] = "C",
    ["TablePlus"] = "D",
    ["Spotify"] = "P",
    ["Relisten"] = "R",
    ["Slack"] = "S",
    ["iTerm2"] = "T",
    ["Code"] = "V"
}

appHotkeys = {}
for appName, key in pairs(appNameHotkeys) do
    app = hs.application.get(appName)
    if app == nil then
        hs.alert("ERROR: " .. appName .. " is not a valid application", 5)
    else
        appHotkeys[app] = key
    end
end

for app, key in pairs(appHotkeys) do
    hs.hotkey.bind({"cmd", "shift"}, key, function()
        switchToApp(app)
    end)
end

lastActiveApp = hs.application.frontmostApplication()

hsPerformedAppSwitch = false
hsAppSwitchHappening = false

-- Record the most recent application that lost focus.
hs.application.watcher.new(function(name, event, app)
    if event ~= hs.application.watcher.deactivated then
        return
    end
    lastActiveApp = app
    hsPerformedAppSwitch = hsAppSwitchHappening
    print(string.format(
        "hsPerformedAppSwitch: %s hsAppSwitchHappening: %s",
        hsPerformedAppSwitch, hsAppSwitchHappening))
    hsAppSwitchHappening = false
end):start()

-- Switch to the selected app if it's not already active. If it's
-- already active, then switch back to the most recent application,
-- unless current app was switched to without using Hammerspoon.
function switchToApp(app)
    print("lastActiveApp: ".. lastActiveApp:name())
    -- Signal to application.watcher that last app switch was done with
    -- Hammerspoon, to allow "toggling" back and forth to most recent apps with
    -- trigger hotkey. Probably a better way to do this with closures.
    hsAppSwitchHappening = true
    current = hs.application.frontmostApplication()
    if current ~= app or not hsPerformedAppSwitch then
        print("switching to " .. app:name())
        setFocus(app)
    else
        print("switching back to last app " .. lastActiveApp:name())
        setFocus(lastActiveApp)
    end
end

function setFocus(app)
    if hs.application.launchOrFocusByBundleID(app:bundleID()) then
        hs.alert(app:name() .. "!", 0.5)
    else
        hs.alert(app:name() .. " could not be found")
    end
end
