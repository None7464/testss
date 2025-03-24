local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

local Aimbot = {
    Enabled = false, -- Controlled by UI
    Aiming = false, -- Tracks right-click state
    Target = nil,   -- Current NPC target
    RenderConnection = nil, -- Store RenderStepped connection
    Settings = {
        AimKey = Enum.UserInputType.MouseButton2, -- RightClick
    }
}

-- Utility function to get NPC models (non-player humanoids)
local function getNPCs()
    local npcs = {}
    for _, humanoid in pairs(workspace:GetDescendants()) do
        if humanoid:IsA("Model") and humanoid:FindFirstChildOfClass("Humanoid") and humanoid ~= Player.Character then
            local isPlayer = Players:GetPlayerFromCharacter(humanoid)
            if not isPlayer and humanoid:FindFirstChildOfClass("Humanoid").Health > 0 then
                table.insert(npcs, humanoid)
            end
        end
    end
    return npcs
end

-- Find closest NPC to crosshair (excluding players)
local function findClosestNPC()
    local mouse = UserInputService:GetMouseLocation()
    local ray = Camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local closestNPC, closestDistance = nil, math.huge
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    
    if raycastResult and raycastResult.Instance then
        local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") and model ~= Player.Character then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local isPlayer = Players:GetPlayerFromCharacter(model)
            if hum and hum.Health > 0 and not isPlayer then
                closestNPC = model
                closestDistance = (Camera.CFrame.Position - raycastResult.Position).Magnitude
            end
        end
    end

    -- Fallback: Check all NPCs for closest to crosshair
    for _, npc in pairs(getNPCs()) do
        local head = npc:FindFirstChild("Head") or npc.PrimaryPart
        if head then
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
                if distance < closestDistance then
                    closestNPC = npc
                    closestDistance = distance
                end
            end
        end
    end
    
    return closestNPC
end

-- Aim at target’s head instantly
local function aimAtTarget()
    if not Aimbot.Target or not Aimbot.Target.PrimaryPart then return end
    
    local head = Aimbot.Target:FindFirstChild("Head") or Aimbot.Target.PrimaryPart
    if not head then return end
    
    local targetPos = head.Position
    local lookVector = (targetPos - Camera.CFrame.Position).Unit
    local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
    
    Camera.CFrame = newCFrame
end

local function AddMobileAimbotButton()
    local UserInputService = game:GetService("UserInputService")

    if not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then
        if game:GetService("StarterGui"):FindFirstChild("SetCore") then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Aimbot",
                Text = "This function only works on mobile devices!",
                Duration = 3
            })
        else
            warn("This function only works on mobile devices!")
        end
        return
    end

    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")

    if not playerGui then
        warn("PlayerGui not found!")
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local aimbotButton = Instance.new("TextButton")
    aimbotButton.Size = UDim2.new(0, 80, 0, 80)
    aimbotButton.Position = UDim2.new(0.85, 0, 0.8, 0)
    aimbotButton.BackgroundColor3 = Color3.new(0, 0, 0)
    aimbotButton.BackgroundTransparency = 0.3
    aimbotButton.Text = "Hold to Aim"
    aimbotButton.TextColor3 = Color3.new(1, 1, 1)
    aimbotButton.Font = Enum.Font.SourceSansBold
    aimbotButton.TextSize = 16
    aimbotButton.Parent = screenGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(1, 0)
    uicorner.Parent = aimbotButton

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 2
    uiStroke.Color = Color3.new(1, 1, 1)
    uiStroke.Parent = aimbotButton

    -- Hold to aim
    aimbotButton.MouseButton1Down:Connect(function()
        Aimbot.Aiming = true
        Aimbot.Target = findClosestNPC()
        if Aimbot.Target then
            Aimbot.RenderConnection = game:GetService("RunService").RenderStepped:Connect(aimAtTarget)
        end
    end)

    -- Release to stop aiming
    aimbotButton.MouseButton1Up:Connect(function()
        Aimbot.Aiming = false
        Aimbot.Target = nil
        if Aimbot.RenderConnection then
            Aimbot.RenderConnection:Disconnect()
            Aimbot.RenderConnection = nil
        end
    end)
end

AddMobileAimbotButton()

-- Handle input for aimbot
function Aimbot.Initialize()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not Aimbot.Enabled then return end
        if input.UserInputType == Aimbot.Settings.AimKey then
            Aimbot.Aiming = true
            Aimbot.Target = findClosestNPC()
            if Aimbot.Target then
                Aimbot.RenderConnection = RunService.RenderStepped:Connect(aimAtTarget)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed or not Aimbot.Enabled then return end
        if input.UserInputType == Aimbot.Settings.AimKey then
            Aimbot.Aiming = false
            Aimbot.Target = nil
            if Aimbot.RenderConnection then
                Aimbot.RenderConnection:Disconnect()
                Aimbot.RenderConnection = nil
            end
        end
    end)
end

return Aimbot
