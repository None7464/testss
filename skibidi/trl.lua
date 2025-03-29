local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local autoFarm = false
local randomEnemyFarm = true
local focusEnemy = false
local enemyEsp = false
local stat = false

-- ui lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/refs/heads/main/Gui.lua", true))()
local example = library:CreateWindow({ text = "The Red Lake" })

-- functions 
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
    while true do
        task.wait(1)
        local damageFrame = player.PlayerGui:FindFirstChild("Crosshair") and player.PlayerGui.Crosshair.Main.Frame:FindFirstChild("DamageStack")
        if damageFrame and damageFrame:FindFirstChild("damage") then
            local damageObject = damageFrame.damage
            local currentDamage = damageObject:IsA("NumberValue") and damageObject.Value or tonumber(damageObject.Text) or 0
            
            if currentDamage ~= lastDamage then
                lastDamage = currentDamage
                lastDamageTime = tick()
            elseif tick() - lastDamageTime >= 2 then
                autoFarm = false
                task.wait(1)
                autoFarm = true
                spawn(autoFarm)
            end
        end
    end
end

local NPCsFolder = game:GetService("Workspace"):FindFirstChild("NPCs")
local enemies = {}
local highlights = {}
local bosses = {"Brute", "Bolty", "Titan", "Kraken", "Corrupted Titan", "Corrupted Brute", "Corrupted Bolty"}

local function AddESP(enemy, isBoss)
    if not highlights[enemy] then
        local highlight = Instance.new("Highlight")
        highlight.Parent = enemy
        highlight.FillColor = isBoss and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(255, 0, 0) -- Orange for bosses, Red for normal enemies
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

local function IsBoss(name)
    for _, bossName in ipairs(bosses) do
        if name == bossName then
            return true
        end
    end
    return false
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
            
            if (parentName == "Tango" or parentName == "Monsters" or IsBoss(parentName)) and humanoid and humanoid.Health > 0 then
                table.insert(enemies, {entity = v.Parent, isBoss = IsBoss(parentName)})
                AddESP(v.Parent, IsBoss(parentName))
            end
        end
    end
end

function getRandomEnemy()
    local validEnemies = {}
    local validBosses = {}
    
    for _, v in pairs(game:GetService("Workspace").NPCs:GetDescendants()) do
        if v.Name == "Head" and v.Parent and v.Parent.Parent then
            local parentName = v.Parent.Parent.Name
            if (parentName == "Tango" or parentName == "Monsters" or IsBoss(parentName)) and v.Parent:FindFirstChild("Humanoid") and v.Parent.Humanoid.Health > 0 then
                if IsBoss(parentName) then
                    table.insert(validBosses, v)
                else
                    table.insert(validEnemies, v)
                end
            end
        end
    end
    return #validBosses > 0 and validBosses[math.random(1, #validBosses)] or (#validEnemies > 0 and validEnemies[math.random(1, #validEnemies)] or nil)
end

function focusOneEnemy()
    local validEnemies = {}
    local validBosses = {}
    
    for _, v in pairs(game:GetService("Workspace").NPCs:GetDescendants()) do
        if v.Name == "Head" and v.Parent and v.Parent.Parent then
            local parentName = v.Parent.Parent.Name
            if (parentName == "Tango" or parentName == "Monsters" or IsBoss(parentName)) and v.Parent:FindFirstChild("Humanoid") and v.Parent.Humanoid.Health > 0 then
                if IsBoss(parentName) then
                    table.insert(validBosses, v)
                else
                    table.insert(validEnemies, v)
                end
            end
        end
    end
    return #validBosses > 0 and validBosses[1] or (#validEnemies > 0 and validEnemies[1] or nil)
end

function attackTarget(target)
    while target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 and autoFarm do
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
    while true do
        wait(0.1)

        if randomEnemyFarm and focusEnemy then
            warn("AutoFarm will not work because both Random Enemy Farm and Focus Enemy are enabled!")
            return
        end

        local target = nil
        if randomEnemyFarm then
            target = getRandomEnemy()
        elseif focusEnemy then
            target = focusOneEnemy()
        end

        if target then 
            attackTarget(target) 
        end
    end
end

local workspace = game:GetService("Workspace")

local function updatePrompts()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end

if #workspace:GetDescendants() > 0 then
    updatePrompts()
end

workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
    end
end)

-- UI
example:AddToggle("Auto Farm", function(state)
    autoFarm = state
    if autoFarm then
        spawn(monitorDamage)
        spawn(autoFarm)
    end
end)

example:AddToggle("Random Enemy Farm", function(state)
    randomEnemyFarm = state
    if randomEnemyFarm then
        focusEnemy = false
    end
end)

example:AddToggle("Focus Enemy", function(state)
    focusEnemy = state
    if focusEnemy then
        randomEnemyFarm = false
    end
end)

example:AddToggle("Enemy Esp", function(state)
    enemyEsp = state
    if enemyEsp then
        spawn(function()
            while enemyEsp do
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

example:AddToggle("Stats UI", function(state)
    stat = state 

    if stat then
        example1 = library:CreateWindow({ text = "Stats" })

        local characterLabel = example1:AddLabel("Character: " .. player.Appearance.Outfits.Value)
        local killStreakLabel = example1:AddLabel("KillStreak: " .. player.leaderstats.Streak.Value)
        local cashLabel = example1:AddLabel("Cash: " .. player.leaderstats.Points.Value)

        player.Appearance.Outfits.Changed:Connect(function()
            characterLabel.Text = "Character: " .. player.Appearance.Outfits.Value
        end)

        player.leaderstats.Streak.Changed:Connect(function()
            killStreakLabel.Text = "KillStreak: " .. player.leaderstats.Streak.Value
        end)

        player.leaderstats.Points.Changed:Connect(function()
            cashLabel.Text = "Cash: " .. player.leaderstats.Points.Value
        end)
    else
        if example1 then
            example1:Destroy()
            example1 = nil
        end
    end
end)

example:AddButton("Kill Ui", function()
    library:DestroyUI()
end)
