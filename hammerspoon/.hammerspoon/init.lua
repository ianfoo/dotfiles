-- Auto-reload Hammerspoon config
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Switch to these apps with Cmd+Ctrl+Shift+<key>
appNameHotKeys = {
    ["Brave Browser"] = "B",
    ["Dash"] = "D",
    ["GoLand"] = "G",
    ["Google Chrome"] = "C",
    ["TablePlus"] = "L",
    ["Spotify"] = "P",
    ["Relisten"] = "R",
    ["Slack"] = "S",
    ["iTerm"] = "T",
    ["Visual Studio Code"] = "V"
}

for app, key in pairs(appNameHotKeys) do
    hs.hotkey.bind({"cmd", "shift", "ctrl"}, key, function()
        switchToApp(app)
    end)
end

-- lastActiveApp tracks the app that was most recently in focus before the
-- current one, so that it can be switched back to with the same key combo that
-- was used to switch to another app. This is useful for quick operations, like,
-- for example, switching to Spotify with Ctrl+Shift+S and then hitting space to
-- play or pause the music, and then hitting Ctrl+Shift+S again to go back to
-- the most recent application. (This is a contrived example if your media keys
-- work properly, but you get the point.) Ideally this should have some timeout
-- around 3 to 5 seconds, because past that it's not going to make as much sense
-- to change to a different app using the hotkeys used to focus the current app.
--
-- FIXME This is not working in the case when the menu bar name (e.g, "Code")
-- does not match the bundle name (e.g., "Visual Studio Code"). Enabling
-- Spotlight search in hs.application does not seem to have any effect.
lastActiveApp = hs.application.frontmostApplication()

-- Automatically record the most recent application that lost focus into
-- lastActiveApp.
hs.application.watcher.new(function(name, event, app)
    if event ~= hs.application.watcher.deactivated then
        return
    end
    if hsAppSwitchHappening then
        lastActiveApp = app
        hsAppSwitchHappening = false
    else
        lastActiveApp = nil
    end
end):start()

-- hsAppSwitchHappening helps maintain proper state when the user has switched
-- to an app without using Hammerspoon. In this case, a hotkey combo should
-- always give focus to its associated application, because taking a user back
-- to lastActiveApp really only makes sense if the current app was switched to
-- with Hammerspoon.
hsAppSwitchHappening = false

-- Switch to the selected app if it's not already active. If it's already
-- active, then switch back to the most recent application, but only if current
-- app was switched to using Hammerspoon.
function switchToApp(app)
    -- Signal to application.watcher that last app switch was done with
    -- Hammerspoon, to allow "toggling" back and forth to most recent apps with
    -- trigger hotkey. Probably a better way to do this with closures.
    hsAppSwitchHappening = true
    current = hs.application.frontmostApplication()
    if current:name() ~= app or lastActiveApp == nil then
        setFocus(app)
    else
        print("info: setting focus back to previous app: " .. lastActiveApp:name())
        setFocus(lastActiveApp)
    end
end

-- Set the focus to the passed application, which can be a string representing
-- the name of the application, or a Hammerspoon application object, in which
-- case the bundle ID will be used to switch apps.
function setFocus(app)
    function notify(name)
        hs.alert(name .. "!", 0.5)
    end
    if app.bundleID ~= nil then
        hs.application.launchOrFocusByBundleID(app:bundleID())
        notify(app:name())
        return
    end
    if hs.application.launchOrFocus(app) then
        notify(app)
    else
        hs.alert(app .. " could not be found")
    end
end
