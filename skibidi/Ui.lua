return function(Config, ESP, Aimbot, Gunmod)
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/Gui.lua"))()
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Loop
    local UI = library:CreateWindow({ text = "Railed" })
    
    UI:AddToggle("ESP Enable", function(state)
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
    
    UI:AddLabel("Aimbot: Press F to Enable or Disable! (PC)")

    UI:AddButton("Aimbot Button", function()
        Aimbot.AddMobileAimbotButton()
    end)

    local UI1 = library:CreateWindow({ text = "Skibidi" })

    UI1:AddButton("Instant Win", function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local StarterGui = game:GetService("StarterGui")
        
        local Player = Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
    
        if not RootPart or not Humanoid then
            warn("Could not find essential character parts!")
            return
        end
    
        -- Disable movement and anchor player
        Humanoid.PlatformStand = true
        RootPart.Anchored = true
        
        -- If already moving, stop the previous loop
        if CFloop then CFloop:Disconnect() end
    
        -- Movement settings
        local CFspeed = 50
        CFloop = RunService.Heartbeat:Connect(function(deltaTime)
            local moveDirection = Humanoid.MoveDirection * (CFspeed * deltaTime)
            RootPart.CFrame = RootPart.CFrame * CFrame.new(moveDirection)
        end)

        Character:PivotTo(CFrame.new(-346, -69, -49060))
    
        -- Notifications
        local function notify(msg, duration)
            StarterGui:SetCore("SendNotification", {
                Title = "Instant Win",
                Text = msg,
                Duration = duration or 3
            })
        end
    
        notify("You have 20 seconds left until you go back to the train.", 5)
        wait(10)
        notify("10 seconds left!", 5)
        wait(10)
        notify("Returning to the train...", 3)
        wait(3)
    
        if CFloop then
            CFloop:Disconnect()
            CFloop = nil
        end
    
        Humanoid.PlatformStand = false
        RootPart.Anchored = false
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

    UI:AddLabel("Auto Farm Bonds Soon!")

    return UI
end
