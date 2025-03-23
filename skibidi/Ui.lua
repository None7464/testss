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

        CFspeed = 50
        Player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
        local Head = Player.Character:WaitForChild("Head")
        Head.Anchored = true
        if CFloop then CFloop:Disconnect() end
        CFloop = RunService.Heartbeat:Connect(function(deltaTime)
            local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
            local headCFrame = Head.CFrame
            local cameraCFrame = workspace.CurrentCamera.CFrame
            local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
            cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
            local cameraPosition = cameraCFrame.Position
            local headPosition = headCFrame.Position
    
            local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
            Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
        end)

        Character:PivotTo(CFrame.new(-346, -40, -49060))
    
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
