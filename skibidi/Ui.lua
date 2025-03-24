return function(Config, ESP, Aimbot, Gunmod)
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
    
    UI:AddLabel("Aimbot: Press Q to Enable (PC)")

    UI:AddButton("Aimbot Button", function()
        Aimbot.AddMobileAimbotButton()
    end)

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
        local RunService = game:GetService("RunService")
        local StarterGui = game:GetService("StarterGui")
        
        local Player = Players.LocalPlayer
    
        -- Ensure the player's character is fully loaded
        if not Player.Character or not Player.Character.Parent then
            Player.CharacterAdded:Wait() -- Wait until the character is added
        end
    
        local Character = Player.Character -- Re-fetch the character after waiting
        local Head = Character:WaitForChild("Head")

        local function notify(msg, duration)
            StarterGui:SetCore("SendNotification", {
                Title = "Instant Win",
                Text = msg,
                Duration = duration or 3
            })
        end
        CFspeed = 50
        Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
        Head.Anchored = true
        
        if CFloop then CFloop:Disconnect() end
        CFloop = RunService.Heartbeat:Connect(function(deltaTime)
            local moveDirection = Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
            local headCFrame = Head.CFrame
            local cameraCFrame = workspace.CurrentCamera.CFrame
            local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
            cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
            local cameraPosition = cameraCFrame.Position
            local headPosition = headCFrame.Position
    
            local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
            Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
        end)
    
        -- Move the character safely
        Character:PivotTo(CFrame.new(-346, -40, -49060))
        
        notify("You have 20 seconds left until you go back to the train.", 5)
        task.wait(10)
        notify("10 seconds left!", 5)
        task.wait(10)
        notify("Returning to the train...", 3)
        task.wait(3)
    
        if CFloop then
            wait(1)
            CFloop:Disconnect()
            CFloop = nil
        else
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
    UI1:AddButton("💀 Kill UI 💀", function()
         library:DestroyUI()
     end)
    return UI
end
