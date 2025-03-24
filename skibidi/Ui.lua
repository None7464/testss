return function(Config, ESP, Aimbot)
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/Gui.lua"))()
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Loop
    local UI = library:CreateWindow({ text = "Railed" })
    
    UI:AddToggle("ESP Enable", function(state)
        if state then
            ESP.Initialize()
            ESP.Update()
        else
            ESP.Cleanup()
        end
        Config.Enabled = state
    end, Config.Enabled)

    UI:AddSlider("Max Distance", 100, 2000, Config.MaxDistance, function(value)
        Config.MaxDistance = value
    end)
    
    UI:AddLabel("Aimbot: Press RightClick to Aim")

    local UI1 = library:CreateWindow({ text = "Skibidi" })

    local timeFuelLabel = UI1:AddLabel("Loading...")

    local function updateLabel()
        while true do
            local time = workspace.Train.TrainControls.TimeDial.SurfaceGui.TextLabel.Text
            local fuel = workspace.Train.Fuel.Value
            
            timeFuelLabel.Text = "Time: " .. time .. " | Fuel: " .. fuel
            
            wait(1)
        end
    end

    task.spawn(updateLabel)

    UI1:AddButton("Instant Win", function()
        local Players = game:GetService("Players")        
        local Player = Players.LocalPlayer
        if not Player.Character or not Player.Character.Parent then
            Player.CharacterAdded:Wait()
        end
        local Character = Player.Character 
        Character:PivotTo(CFrame.new(-346, -40, -49060))
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
    
    UI:AddLabel("Auto Farm Bonds Soon!")

    UI1:AddButton("💀 Kill UI 💀", function()
         library:DestroyUI()
    end)

    return UI
end
