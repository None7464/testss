return function(Config, ESP, Aimbot, Gunmod)
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/Gui.lua"))()
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

    UI:AddLabel("Aimbot: Press F For PC")

    UI:AddButton("Aimbot Button", function()
        Aimbot.AddMobileAimbotButton()
    end)

    local UI1 = library:CreateWindow({ text = "Skibidi" })

    UI1:AddButton("Instant Win", function()
        -- Next Update make a timer so when they can press the lever
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

    local timeFuelLabel = UI1:AddLabel("Loading...")
    
    local function updateLabel()
        while true do
            local time = workspace.Train.TrainControls.TimeDial.SurfaceGui.TextLabel.Text -- Time
            local fuel = workspace.Train.Fuel.Value -- Fuel Value
            

            timeFuelLabel.Text = "Time: " .. time .. " | Fuel: " .. fuel
            
            wait(0.1)
        end
    end

    task.spawn(updateLabel)

    UI1:AddLabel("Auto Farm Bonds Soon!")

    return UI
end
