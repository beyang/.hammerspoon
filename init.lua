local chooser = hs.chooser.new(function(choice)
    -- Capture current workspace before doing anything
    local targetWorkspace = hs.execute("/opt/homebrew/bin/aerospace list-workspaces --focused --format %{workspace}")
    targetWorkspace = targetWorkspace:gsub("%s+", "")
    print("Target workspace: '" .. targetWorkspace .. "'")
    
    local chromeApp = hs.application.get("Google Chrome")
    local hasExistingWindows = chromeApp and #chromeApp:allWindows() > 0
    
    hs.application.launchOrFocus("Google Chrome")
    
    if hasExistingWindows then
        -- Chrome already has windows, so we need to create a new one and move it
        hs.timer.doAfter(0.1, function()
            local chromeApp = hs.application.get("Google Chrome")
            local existingWindows = chromeApp:allWindows()
            
            chromeApp:selectMenuItem({"File", "New Window"})
            hs.timer.doAfter(0.2, function()
                -- Find the new window by comparing with existing ones
                local newWindows = chromeApp:allWindows()
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
end)
chooser:choices({{["text"] = "New Chrome Window"}})
hs.hotkey.bind({"ctrl", "shift"}, "space", function() chooser:show() end)
