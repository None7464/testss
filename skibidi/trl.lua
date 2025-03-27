local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

for i,v in ipairs(game:GetService("Workspace"):GetDescendants()) do -- insta prompt
    if v.ClassName == "ProximityPrompt" then
        v.HoldDuration = 0
    end
end

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/refs/heads/main/Gui.lua", true))()
local example = library:CreateWindow({ text = "SCP: The Red Lake" })

local lastDamage = 0
local lastDamageTime = tick()

spawn(function()
    local lastAmmoNotification = 0
    while true do
        wait(1)
        pcall(function()
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool and tool:GetAttribute("TotalAmmo") and tool:GetAttribute("TotalAmmo") < 1 then
                local closestAmmoBox, shortestDistance = nil, math.huge
                local ammoSources = {
                    game:GetService("Workspace").Maps.Classic.Interactable.AmmoBoxes,
                    game:GetService("Workspace").permObjects:GetChildren()[5],
                    game:GetService("Workspace").permObjects:GetChildren()[4],
                    game:GetService("Workspace").permObjects:GetChildren()[3],
                    game:GetService("Workspace").permObjects:GetChildren()[2],
                    game:GetService("Workspace").permObjects:GetChildren()[1],
                    game:GetService("Workspace").permObjects:GetChildren()[6]
                }

                for _, source in pairs(ammoSources) do
                    if source then
                        for _, v in pairs(source:GetDescendants()) do
                            if v:IsA("ProximityPrompt") then
                                local distance = (player.Character.HumanoidRootPart.Position - v.Parent.Position).Magnitude
                                if distance < shortestDistance then
                                    closestAmmoBox, shortestDistance = v, distance
                                end
                            end
                        end
                    end
                end

                if closestAmmoBox then
                    if shortestDistance > 5 then
                        if tick() - lastAmmoNotification > 5 then
                            lastAmmoNotification = tick()
                            local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                            local popupClient = remotes:WaitForChild("PopupClient")
                            popupClient:Fire("How to Use Auto Refill Ammo", "<font color=\"rgb(85, 255, 0)\">Go Near to the AmmoBox</font>")
                        end
                    else
                        closestAmmoBox.HoldDuration = 0
                        repeat
                            fireproximityprompt(closestAmmoBox)
                            wait()
                        until tool:GetAttribute("TotalAmmo") > 1
                    end
                end
            end
        end)
    end
end)

function monitorDamage()
    while _G.autoFarm do
        task.wait(1)
        local damageFrame = player.PlayerGui:FindFirstChild("Crosshair") and player.PlayerGui.Crosshair.Main.Frame:FindFirstChild("DamageStack")
        if damageFrame and damageFrame:FindFirstChild("damage") then
            local currentDamage = damageFrame.damage.Value
            if currentDamage ~= lastDamage then
                lastDamage = currentDamage
                lastDamageTime = tick()
            elseif tick() - lastDamageTime >= 2 then
                _G.autoFarm = false
                task.wait(0.5)
                _G.autoFarm = true
            end
        end
    end
end

local NPCsFolder = game:GetService("Workspace"):FindFirstChild("NPCs")
local enemies = {}
local highlights = {}

local function AddESP(enemy)
    if not highlights[enemy] then
        local highlight = Instance.new("Highlight")
        highlight.Parent = enemy
        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red for enemies
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlights[enemy] = highlight
    end
end

local function RemoveESP(enemy)
    if highlights[enemy] then
        highlights[enemy]:Destroy()
        highlights[enemy] = nil
    end
end

local function UpdateEnemies()
    for enemy, _ in pairs(highlights) do
        RemoveESP(enemy)
    end

    table.clear(enemies)
    
    for _, v in pairs(NPCsFolder:GetDescendants()) do
        if v:IsA("Part") and v.Name == "Head" and v.Parent and v.Parent.Parent then
            local parentName = v.Parent.Parent.Name
            local humanoid = v.Parent:FindFirstChildOfClass("Humanoid")
            
            if (parentName == "Tango" or parentName == "Monsters") and humanoid and humanoid.Health > 0 then
                table.insert(enemies, v.Parent)
                AddESP(v.Parent)
            end
        end
    end
end

function getRandomEnemy()
    local enemies = {}
    for _, v in pairs(game:GetService("Workspace").NPCs:GetDescendants()) do
        if v.Name == "Head" and v.Parent and v.Parent.Parent then
            local parentName = v.Parent.Parent.Name
            if (parentName == "Tango" or parentName == "Monsters") and v.Parent:FindFirstChild("Humanoid") and v.Parent.Humanoid.Health > 0 then
                table.insert(enemies, v)
            end
        end
    end
    return #enemies > 0 and enemies[math.random(1, #enemies)] or nil
end

function focusOneEnemy()
    local enemies = {}
    for _, v in pairs(game:GetService("Workspace").NPCs:GetDescendants()) do
        if v.Name == "Head" and v.Parent and v.Parent.Parent then
            local parentName = v.Parent.Parent.Name
            if (parentName == "Tango" or parentName == "Monsters") and v.Parent:FindFirstChild("Humanoid") and v.Parent.Humanoid.Health > 0 then
                table.insert(enemies, v)
            end
        end
    end
    return #enemies > 0 and enemies[1] or nil
end

function attackTarget(target)
    while target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 and _G.autoFarm do
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool and tool.Handle then
            local barrel = tool.Handle:FindFirstChild("Barrel")
            if barrel then
                game:GetService("ReplicatedStorage").BulletReplication.ReplicateClient:Fire("MUZZLE", barrel)
                game:GetService("ReplicatedStorage").BulletReplication.ReplicateClient:Fire("HIT", barrel, {[1] = target.Position, [3] = false, [4] = "Plastic"})
                tool.Main:FireServer("MUZZLE", barrel)
                tool.Main:FireServer("DAMAGE", {[1] = target, [2] = target.Position, [3] = 10})
                tool.Main:FireServer("AMMO")
            end
        end
        wait(0.1)
    end
end

function autoFarm()
    while _G.autoFarm do
        wait(0.1)
        local target = _G.randomEnemyFarm and getRandomEnemy() or focusOneEnemy()
        if target then attackTarget(target) end
    end
end

example:AddToggle("Auto Farm", function(state)
    _G.autoFarm = state
    if _G.autoFarm then
        spawn(monitorDamage)
        spawn(autoFarm)
    end
end)

example:AddToggle("Random Enemy Farm", function(state)
    _G.randomEnemyFarm = state
    _G.focusEnemy = false
end)

example:AddToggle("Focus Enemy", function(state)
    _G.focusEnemy = state
    _G.randomEnemyFarm = false
end)

example:AddToggle("Enemy Esp", function(state)
    _G.enemyEsp = state
    if state then
        spawn(function()
            while _G.enemyEsp do
                UpdateEnemies()
                task.wait(1)
            end
        end)
    else
        for _, v in pairs(highlights) do
            v:Destroy()
        end
        highlights = {}
    end
end)

stats = false

local example1 = library:CreateWindow({ text = "Stats" })

local characterLabel = example1:AddLabel("Character:", player.Appearance.Outfits.Value)
local killStreakLabel = example1:AddLabel("KillStreak:", player.leaderstats.Streak.Value)
local cashLabel = example1:AddLabel("Cash:", player.leaderstats.Points.Value)

if stats then
    player.Appearance.Outfits.Changed:Connect(function()
        characterLabel.Text = "Character: " .. player.Appearance.Outfits.Value
    end)

    player.leaderstats.Streak.Changed:Connect(function()
        killStreakLabel.Text = "KillStreak: " .. player.leaderstats.Streak.Value
    end)

    player.leaderstats.Points.Changed:Connect(function()
        cashLabel.Text = "Cash: " .. player.leaderstats.Points.Value
    end)
end
