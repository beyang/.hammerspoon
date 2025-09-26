local function createNewWindow(appName, menuPaths)
    -- Capture current workspace before doing anything
    local targetWorkspace = hs.execute("/opt/homebrew/bin/aerospace list-workspaces --focused --format %{workspace}")
    targetWorkspace = targetWorkspace:gsub("%s+", "")
    print("Target workspace: '" .. targetWorkspace .. "'")
    
    local app = hs.application.get(appName)
    local hasExistingWindows = app and #app:allWindows() > 0
    
    hs.application.launchOrFocus(appName)
    
    if hasExistingWindows then
        -- App already has windows, so we need to create a new one and move it
        hs.timer.doAfter(0.1, function()
            local app = hs.application.get(appName)
            local existingWindows = app:allWindows()
            
            -- Try menu paths or fallback to Cmd+N
            local success = false
            for _, menuPath in ipairs(menuPaths) do
                if app:selectMenuItem(menuPath) then
                    success = true
                    break
                end
            end
            
            if not success then
                -- Fallback: use keyboard shortcut Cmd+N
                hs.eventtap.keyStroke({"cmd"}, "n")
            end
            
            hs.timer.doAfter(0.2, function()
                -- Find the new window by comparing with existing ones
                local newWindows = app:allWindows()
                local newWindow = nil
                for _, window in ipairs(newWindows) do
                    local isNew = true
                    for _, existing in ipairs(existingWindows) do
                        if window:id() == existing:id() then
                            isNew = false
                            break
                        end
                    end
                    if isNew then
                        newWindow = window
                        break
                    end
                end
                
                -- Move the new window to the workspace we captured initially
                hs.execute("/opt/homebrew/bin/aerospace move-node-to-workspace " .. targetWorkspace)
                hs.timer.doAfter(0.1, function()
                    -- Focus the specific new window
                    if newWindow then
                        newWindow:focus()
                    end
                end)
            end)
        end)
    end
    -- If no existing windows, launchOrFocus already created one in the current workspace
end

local chooser = hs.chooser.new(function(choice)
    if choice.app == "Google Chrome" then
        createNewWindow("Google Chrome", {{"File", "New Window"}})
    elseif choice.app == "Ghostty" then
        createNewWindow("Ghostty", {{"File", "New Window"}, {"Window", "New Window"}, {"Shell", "New Window"}})
    end
end)

chooser:choices({
    {["text"] = "New Chrome Window", ["app"] = "Google Chrome"},
    {["text"] = "New Ghostty Window", ["app"] = "Ghostty"}
})

hs.hotkey.bind({"ctrl", "shift"}, "space", function() chooser:show() end)
