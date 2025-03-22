return function(Config, ESP, Aimbot, Gunmod)
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/Roblox/refs/heads/main/The%20Red%20Lake/UI/Main", true))()
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Loop
    local UI = library:CreateWindow({ text = "Railed" })
    
    UI:AddToggle("ESP Enable", Config.Enabled, function(state)
        Config.Enabled = state
        if state then
            ESP.Initialize()
            ESP.Update()
        else
            ESP.Cleanup()
        end
    end)

    UI:AddSlider("Max Distance", 100, 2000, Config.MaxDistance, function(value)
        Config.MaxDistance = value
    end)
    
    -- Aimbot Toggle (with safe access and debug)
    local aimbotEnabled = (Aimbot and Aimbot.Enabled ~= nil) and Aimbot.Enabled or false
    UI:AddToggle("Aimbot", aimbotEnabled, function(state)
        if Aimbot and Aimbot.Enabled ~= nil then
            Aimbot.Enabled = state
            print("Aimbot toggled to:", state)
        else
            warn("Aimbot module not loaded or Enabled property missing")
        end
    end)

    UI:AddButton("Aimbot Button", function()
        Aimbot.AddMobileAimbotButton()
    end)

    UI:AddButton("Destroy Aimbot Button", function()
        local virtualInputManager = game:GetService("VirtualInputManager")
        task.wait(2)
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Home, false, game)
        task.wait(0.1)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.Home, false, game)
    end)

    local UI1 = library:CreateWindow({ text = "Skibidi" })

    UI1:AddButton("Instant Win", function()
        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(-346, -69, -49060))
    end)
    
    UI1:AddToggle("FullBrightness", function(state)
        if state then
            if Loop then
                Loop:Disconnect()
            end
    
            local function brightFunc()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end
    
            Loop = RunService.RenderStepped:Connect(brightFunc)
            brightFunc()
        else
            if Loop then
                Loop:Disconnect()
                Loop = nil
            end
        end
    end)

    UI1:AddButton("Turn On GunMode", function()
        Gunmod.ToggleGunMods()
    end)

    return UI
end