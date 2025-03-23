local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

local Aimbot = {
    Enabled = false, -- Toggle with 'Y' key
    Target = nil,    -- The NPC currently being aimed at
    RenderConnection = nil,
    Settings = {
        ToggleKey = Enum.KeyCode.Y -- Press 'Y' to toggle aimbot
    }
}

-- Utility function to get NPCs (excluding players)
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

-- Find the closest NPC to the crosshair
local function findClosestNPC()
    local mouse = UserInputService:GetMouseLocation()
    local ray = Camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Player.Character, unpack(getNPCs())}
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

    -- Fallback: Check all NPCs manually
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

local function smoothAim(targetPos)
    local currentPos = Camera.CFrame.Position
    local direction = (targetPos - currentPos).Unit
    local newPos = currentPos + direction * 0.1  -- Adjust this for a smoother aim
    Camera.CFrame = CFrame.lookAt(currentPos, newPos)
end

local function aimAtTarget()
    if not Aimbot.Enabled then return end
    local newTarget = findClosestNPC()

    if newTarget and newTarget ~= Aimbot.Target then
        Aimbot.Target = newTarget
    end

    if Aimbot.Target and Aimbot.Target.PrimaryPart then
        local head = Aimbot.Target:FindFirstChild("Head") or Aimbot.Target.PrimaryPart
        if head then
            smoothAim(head.Position)
        end
    end
end
function Aimbot.AddMobileAimbotButton()
    local UserInputService = game:GetService("UserInputService")

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
    aimbotButton.Text = "Aimbot OFF"
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

    aimbotButton.MouseButton1Click:Connect(function()
        Aimbot.Enabled = not Aimbot.Enabled
        aimbotButton.Text = Aimbot.Enabled and "Aimbot ON" or "Aimbot OFF"
    end)
end

local function notify(message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Skibdi",
        Text = message,
        Duration = 2
    })
end

if Aimbot.Enabled then
    notify("Aimbot Enabled")
else
    notify("Aimbot Disabled")
end

function Aimbot.Initialize()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Aimbot.Settings.ToggleKey then
            Aimbot.Enabled = not Aimbot.Enabled
            notify(Aimbot.Enabled and "Aimbot Activated" or "Aimbot Deactivated")

            if Aimbot.Enabled then
                if not Aimbot.RenderConnection then
                    Aimbot.RenderConnection = RunService.RenderStepped:Connect(aimAtTarget)
                end
            else
                if Aimbot.RenderConnection then
                    Aimbot.RenderConnection:Disconnect()
                    Aimbot.RenderConnection = nil
                end
                Aimbot.Target = nil
            end
        end
    end)
end

return Aimbot
