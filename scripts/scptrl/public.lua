if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()


-- Var
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")
local choosengun = nil
local autoFarmRunning = false
local autoFarmThread = nil
local riskAutoFarmRunning = false
local riskAutoFarmThread

local version = 3
local Window =
    Fluent:CreateWindow(
    {
        Title = "Karmapanda's The Red Lake Script Version: " .. version,
        SubTitle = "by Dev-Jay",
        TabWidth = 160,
        Size = UDim2.fromOffset(460, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Home
    }
)
local Options = Fluent.Options

local tabs = {}
tabs.main = Window:AddTab({Title = "Main"})
tabs.classic = Window:AddTab({Title = "Classic"})

-- local functions and stuff
-- main functions

-- auto ammo
spawn(
    function()
        local lastAmmoNotification = 0
        while true do
            wait(1)
            pcall(
                function()
                    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:GetAttribute("TotalAmmo") and tool:GetAttribute("TotalAmmo") < 1 then
                        local closestAmmoBox, shortestDistance = nil, math.huge
                        local ammoSources = {
                            workspace.Maps.Forest.Interactable.AmmoBoxes,
                            workspace.Maps["Shadow War"].Interactable.AmmoBoxes,
                            workspace.Maps.Extraction.Interactable.AmmoBoxes,
                            workspace.Maps.Classic.Interactable.AmmoBoxes,
                            workspace.Maps["Chaos Facility"].Interactable.AmmoBoxes,
                            workspace.Maps.Forest.Interactable.Temp["Ammo Box"],
                            workspace.Maps.Classic.Interactable.Temp["Ammo Box"],
                            workspace.Maps.Extraction.Interactable.Temp["Ammo Box"],
                            workspace.Maps["Chaos Facility"].Interactable.Temp["Ammo Box"],
                            workspace.permObjects:GetChildren()[5],
                            workspace.permObjects:GetChildren()[4],
                            workspace.permObjects:GetChildren()[3],
                            workspace.permObjects:GetChildren()[2],
                            workspace.permObjects:GetChildren()[1],
                            workspace.permObjects:GetChildren()[6]
                        }

                        for _, source in pairs(ammoSources) do
                            if source then
                                for _, v in pairs(source:GetDescendants()) do
                                    if v:IsA("ProximityPrompt") then
                                        local distance =
                                            (player.Character.HumanoidRootPart.Position - v.Parent.Position).Magnitude
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
                                    popupClient:Fire(
                                        "How to Use Auto Refill Ammo",
                                        '<font color="rgb(85, 255, 0)">Go Near to the AmmoBox</font>'
                                    )
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
                end
            )
        end
    end
)

local abilityData =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/scripts/scptrl/Ability.lua"))()

local abilityGui, manaLabel, mainFrame

local function GetAbilityGui()
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name:match("^Ability") then
            abilityGui = gui
            manaLabel = gui:WaitForChild("Bottom", 5):WaitForChild("Mana", 5):WaitForChild("TextLabel", 5)
            mainFrame = gui:WaitForChild("Main", 5)

            if manaLabel and mainFrame then
                return true
            end
        end
    end
    abilityGui = nil
    manaLabel = nil
    mainFrame = nil
    return false
end

GetAbilityGui()

if not abilityGui then
    warn("No Ability GUI found!")
    Fluent:Notify(
        {
            Title = "Ability GUI Not Found",
            Content = "Auto Ability features will be disabled",
            Duration = 8,
            Type = "warning"
        }
    )
end

-- detection for when GUI appears
playerGui.ChildAdded:Connect(
    function(child)
        if child:IsA("ScreenGui") and child.Name:match("^Ability") then
            GetAbilityGui()
            refreshAbilities()
            Fluent:Notify(
                {
                    Title = "New Abilities Detected!",
                    Content = "Ability list has been updated",
                    Duration = 5
                }
            )
        end
    end
)

local cooldowns = {}

local function getCurrentMana()
    local manaText = manaLabel.Text
    manaText = manaText:gsub(",", "")
    local manaNumber = tonumber(manaText)
    return manaNumber
end

local function useAbility(abilityName)
    local args = {
        [1] = abilityName,
        [2] = {}
    }
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Abilities"):WaitForChild("Use"):FireServer(unpack(args))
end

local function getBackpackTools()
    local tools = {}
    if not backpack then
        return tools
    end

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(tools, tool.Name)
        end
    end
    return tools
end

local gunList = {}
local chosenGunName = nil

-- Classic functions
local npcFolder = workspace:FindFirstChild("NPCs")
if not npcFolder then
    warn("No NPCs folder found!")
end

local defaultBossList = {
    "Mutant Blaze",
    "Brute",
    "Bolty",
    "Titan",
    "Kraken",
    "Corrupted Titan",
    "Corrupted Brute",
    "Corrupted Bolty",
    "Kraken Tentacles"
}

local bannedBosses = {}
for _, name in ipairs(defaultBossList) do
    bannedBosses[name] = false
end


function getAliveHeadsFrom(folder, isBoss)
    local targets = {}
    if not folder then return targets end

    for _, v in ipairs(folder:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Head" then
            local model = v:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChild("Humanoid") then
                local humanoid = model.Humanoid
                if humanoid.Health > 0 then
                    local grandparent = model.Parent
                    if grandparent and (grandparent.Name == "Tango" or grandparent.Name == "Monsters") then
                        if not bannedBosses[model.Name] then
                            table.insert(targets, v)
                        end
                    end
                end
            end
        end
    end

    return targets
end

function getboss()
    local bosses = getAliveHeadsFrom(npcFolder, true)
    return #bosses > 0 and bosses[math.random(1, #bosses)] or nil
end

function getRandomEnemy()
    local enemies = {}
    for _, part in ipairs(workspace.NPCs:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Head" then
            local model = part:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 then
                local groupName = model.Parent and model.Parent.Name
                if groupName == "Monsters" or model.Name == "Tango" then
                    table.insert(enemies, part)
                end
            end
        end
    end
    return #enemies > 0 and enemies[math.random(1, #enemies)] or nil
end

function focusOneEnemy()
    for _, part in ipairs(workspace.NPCs:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Head" then
            local model = part:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 then
                local groupName = model.Parent and model.Parent.Name
                if groupName == "Monsters" or model.Name == "Tango" then
                    return part
                end
            end
        end
    end
    return nil
end

local bossSpawnTime = nil
local lastBossName = ""

function getTargetEnemy()
    local enemy = getboss()
    local isBoss = false

    if enemy then
        isBoss = true
        local bossName = enemy.Parent and enemy.Parent.Name or "Unknown"

        if bossName ~= lastBossName then
            lastBossName = bossName
            bossSpawnTime = tick()
            Fluent:Notify(
                {
                    Title = "Attacking Boss",
                    Content = bossName,
                    Duration = 3
                }
            )
        else
            if bossSpawnTime and (tick() - bossSpawnTime) >= 240 then
                Fluent:Notify(
                    {
                        Title = "Bad DPS",
                        Content = "Your Team should consider kill themselves",
                        Duration = 5
                    }
                )
                bossSpawnTime = nil
            end
        end
    else
        if lastBossName ~= "" then
            Fluent:Notify(
                {
                    Title = "Boss Defeated",
                    Content = ("%s gone | Active: %s%s"):format(
                        lastBossName,
                        Options.FocusEnemyToggle.Value and "Focus " or "",
                        Options.RandomEnemyToggle.Value and "Random" or ""
                    ),
                    Duration = 5
                }
            )
            lastBossName = ""
            bossSpawnTime = nil
        end

        if Options.FocusEnemyToggle.Value then
            enemy = focusOneEnemy()
        end

        if not enemy and Options.RandomEnemyToggle.Value then
            enemy = getRandomEnemy()
        end
    end

    return enemy, isBoss
end

function pressRKey()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
end

function stopautofarm()
    autoFarmRunning = false
    if autoFarmThread then
        coroutine.close(autoFarmThread)
        autoFarmThread = nil
    end
end

function startautofarm()
    if autoFarmRunning then
        return
    end
    autoFarmRunning = true

    autoFarmThread = coroutine.create(function()
        while autoFarmRunning and Options.AutoFarmToggle.Value do
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local tool = character:FindFirstChildOfClass("Tool")

            if tool and tool:FindFirstChild("Handle") then
                local barrel = tool.Handle:FindFirstChild("Barrel")
                if barrel then
                    local reloadTime = tool:GetAttribute("ReloadTime") or 0.1
                    local damage = tool:GetAttribute("Damage") or 50
                    local ammo = tool:GetAttribute("Ammo") or {Min = 0, Max = 0}

                    local target = getTargetEnemy()

                    if target and target:IsA("BasePart") and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
                        local headPos = target.Position + Vector3.new(0, target.Size.Y / 2, 0)

                        game.ReplicatedStorage.BulletReplication.ReplicateClient:Fire("MUZZLE", barrel)
                        game.ReplicatedStorage.BulletReplication.ReplicateClient:Fire("HIT", barrel, {
                            [1] = headPos,
                            [3] = false,
                            [4] = "Plastic"
                        })
                        tool.Main:FireServer("MUZZLE", barrel)
                        tool.Main:FireServer("DAMAGE", {
                            [1] = target,
                            [2] = headPos,
                            [3] = damage
                        })
                    end

                    -- Reload logic that respects risk autofarm toggle
                    if ammo.Min <= 0 then
                        if Options.riskautofarm.Value then
                            tool.Main:FireServer("AMMO")
                        else
                            pressRKey()
                            task.wait(reloadTime)
                            tool.Main:FireServer("AMMO")
                        end
                    end
                end
            end
            task.wait(0.1)
        end
        autoFarmRunning = false
    end)

    coroutine.resume(autoFarmThread)
end

-- local functions and stuff ends

do
    --Main
    local UI = tabs.main:AddSection("Functions")

    local abilityList = {}
    local selectedAbilities = {}

    local MultiDropdown =
        UI:AddDropdown(
        "AbilitiesDropdown",
        {
            Title = "Select Abilities",
            Description = "Choose which abilities to auto-use (Projectiles doesnt work)",
            Values = abilityList,
            Multi = true,
            Default = {}
        }
    )

    -- Handle selection changes
    MultiDropdown:OnChanged(
        function(values)
            selectedAbilities = {}
            for _, name in ipairs(values) do
                selectedAbilities[name] = true
            end
        end
    )

    local function refreshAbilities()
        if not GetAbilityGui() then
            Fluent:Notify(
                {
                    Title = "No Abilities Detected",
                    Content = "Equip an operative with abilities first!",
                    Duration = 5,
                    Type = "warning"
                }
            )
            MultiDropdown:SetValue({})
            return
        end

        local newAbilityList = {}
        for _, abilityFrame in ipairs(mainFrame:GetChildren()) do
            if abilityFrame:IsA("Frame") and abilityFrame:FindFirstChild("ManaReq") then
                print("Detected ability:", abilityFrame.Name)
                table.insert(newAbilityList, abilityFrame.Name)
            end
        end

        MultiDropdown.Values = newAbilityList

        MultiDropdown:SetValue({})
    end

    refreshAbilities()

    -- Refresh button
    UI:AddButton(
        {
            Title = "Refresh Abilities",
            Callback = function()
                refreshAbilities()
                Fluent:Notify(
                    {
                        Title = "Abilities Refreshed",
                        Content = "Ability list has been updated",
                        Duration = 3
                    }
                )
            end
        }
    )

    -- Auto Ability toggle
    local AutoToggle =
        UI:AddToggle(
        "AutoAbilityToggle",
        {
            Title = "Auto Ability",
            Default = false
        }
    )

    AutoToggle:OnChanged(
        function()
            if Options.AutoAbilityToggle.Value then
                Fluent:Notify(
                    {
                        Title = "Auto Ability Enabled",
                        Content = "Selected abilities will auto-cast",
                        Duration = 3
                    }
                )
            else
                Fluent:Notify(
                    {
                        Title = "Auto Ability Disabled",
                        Content = "Auto-casting stopped",
                        Duration = 3
                    }
                )
            end
        end
    )

    task.spawn(
        function()
            while task.wait(0.5) do
                if Options.AutoAbilityToggle.Value and abilityGui then
                    local selectedAbilities = MultiDropdown.Value

                    for _, abilityFrame in ipairs(mainFrame:GetChildren()) do
                        if abilityFrame:IsA("Frame") and abilityFrame:FindFirstChild("ManaReq") then
                            local abilityName = abilityFrame.Name

                            -- Only process if selected
                            if selectedAbilities[abilityName] then
                                local manaRequirement = tonumber(abilityFrame.ManaReq.Text:gsub(",", "")) or 0
                                local currentMana = getCurrentMana()
                                local abilityInfo =
                                    abilityData and abilityData.Abilities and abilityData.Abilities[abilityName]

                                if abilityInfo then
                                    local cooldown = abilityInfo.Cooldown or 0
                                    local lastUse = cooldowns[abilityName] or 0
                                    local now = tick()

                                    local canUse = now - lastUse >= cooldown and currentMana >= manaRequirement
                                    local shouldSkip = false

                                    -- Special case for NineTailedFox
                                    if abilityName == "NineTailedFox" then
                                        local friendsUI = playerGui:FindFirstChild("FriendsUI")
                                        if
                                            friendsUI and friendsUI:FindFirstChild("Main") and
                                                friendsUI.Main:FindFirstChild("List")
                                         then
                                            for _, child in ipairs(friendsUI.Main.List:GetChildren()) do
                                                if child:IsA("Frame") and child.Name:sub(1, 3) == "E11" then
                                                    warn(
                                                        "Skipped NineTailedFox: Detected E11 unit (" ..
                                                            child.Name .. ")"
                                                    )
                                                    shouldSkip = true
                                                    break
                                                end
                                            end
                                        end
                                    end

                                    if canUse and not shouldSkip then
                                        useAbility(abilityName)
                                        cooldowns[abilityName] = now
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    )

    local GunDropdown =
        UI:AddDropdown(
        "GunDropdown",
        {
            Title = "Select Gun",
            Description = "Choose a gun to auto-equip",
            Values = gunList,
            Multi = false,
            Default = nil
        }
    )

    local function refreshGuns()
        local previousCount = #gunList
        local newGunList = getBackpackTools()

        local character = player.Character
        if character then
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Tool") and not table.find(newGunList, item.Name) then
                    table.insert(newGunList, item.Name)
                end
            end
        end

        gunList = newGunList
        GunDropdown:SetValues(gunList)

        if chosenGunName and not table.find(gunList, chosenGunName) then
            chosenGunName = nil
            GunDropdown:SetValue(nil)
            Fluent:Notify(
                {
                    Title = "Gun Removed",
                    Content = "Selected gun no longer in backpack or equipped",
                    Duration = 3,
                    Type = "warning"
                }
            )
        end

        if #gunList > previousCount then
            Fluent:Notify(
                {
                    Title = "New Guns Detected!",
                    Content = ("Found %d new weapons"):format(#gunList - previousCount),
                    Duration = 3
                }
            )
        end
    end

    backpack.ChildAdded:Connect(
        function(child)
            if child:IsA("Tool") then
                refreshGuns()
            end
        end
    )

    backpack.ChildRemoved:Connect(
        function(child)
            if child:IsA("Tool") then
                refreshGuns()
            end
        end
    )

    UI:AddButton(
        {
            Title = "Refresh Guns",
            Callback = function()
                refreshGuns()
                Fluent:Notify(
                    {
                        Title = "Guns Refreshed",
                        Content = ("Found %d weapons"):format(#gunList),
                        Duration = 3
                    }
                )
            end
        }
    )

    -- Auto Equip Toggle
    local AutoEquipToggle =
        UI:AddToggle(
        "AutoEquipToggle",
        {
            Title = "Auto Equip Gun",
            Default = false
        }
    )

    AutoEquipToggle:OnChanged(
        function()
            if Options.AutoEquipToggle.Value then
                Fluent:Notify(
                    {
                        Title = "Auto Equip Enabled",
                        Content = chosenGunName and "Auto-equipping " .. chosenGunName or "Select a gun first!",
                        Duration = 3
                    }
                )
            else
                Fluent:Notify(
                    {
                        Title = "Auto Equip Disabled",
                        Content = "Will not auto-equip guns",
                        Duration = 3
                    }
                )
            end
        end
    )

    -- Update chosen gun when dropdown changes
    GunDropdown:OnChanged(
        function(Value)
            chosenGunName = Value
        end
    )

    -- auto-equip
    task.spawn(
        function()
            while task.wait(0.5) do
                pcall(
                    function()
                        if Options.AutoEquipToggle.Value and chosenGunName then
                            local character = player.Character
                            if not character then
                                return
                            end

                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            local currentTool = character:FindFirstChildOfClass("Tool")
                            local backpack = player:FindFirstChild("Backpack")

                            if not (humanoid and backpack) then
                                return
                            end

                            -- Verify gun still exists before equipping
                            local gun = backpack:FindFirstChild(chosenGunName)
                            if gun and gun:IsA("Tool") then
                                -- Only equip if not already equipped
                                if not currentTool or currentTool.Name ~= chosenGunName then
                                    humanoid:EquipTool(gun)
                                end
                            end
                        end
                    end
                )
            end
        end
    )

    -- classic
    local UI2 = tabs.classic:AddSection("Main")

    local MultiDropdown = UI2:AddMultiDropdown("BannedBosses", {
        Title = "Ban Bosses From Autofarm",
        Values = defaultBossList,
        Default = {}
    })

    MultiDropdown:OnChanged(function(selected)
        for _, name in ipairs(defaultBossList) do
            bannedBosses[name] = false
        end
        for _, name in ipairs(selected) do
            bannedBosses[name] = true
        end
        warn("Updated banned bosses:", selected)
    end)

    local AutoFarmToggle = UI2:AddToggle("AutoFarmToggle", {
        Title = "Auto Farm",
        Default = false
    })
 
    AutoFarmToggle:OnChanged(function()
        if Options.AutoFarmToggle.Value then
            startautofarm()
        else
            stopautofarm()
        end
        warn("Auto Farm Toggle changed:", Options.AutoFarmToggle.Value)
    end)

    local RiskAutoFarmToggle = UI2:AddToggle("riskautofarm", {
        Title = "Risk Autofarm (has a chance to get banned)",
        Default = false
    })

    RiskAutoFarmToggle:OnChanged(function()
        if Options.riskautofarm.Value then
            if Options.AutoFarmToggle.Value then
                Options.AutoFarmToggle:SetValue(false)
                Fluent:Notify({
                    Title = "Auto Farm Disabled",
                    Content = "Auto Farm was turned off to prevent conflict with Risk Auto Farm.",
                    Duration = 6,
                    Type = "info"
                })
            end
    
            Fluent:Notify({
                Title = "Risk Auto Farm Enabled",
                Content = "Risk Auto Farm started. This may result in a ban.",
                Duration = 8,
                Type = "warning"
            })
    
            startautofarm()
        else
            stopautofarm()
            Fluent:Notify({
                Title = "Risk Auto Farm Disabled",
                Content = "Risk Auto Farm has been stopped.",
                Duration = 5,
                Type = "info"
            })
        end
    
        warn("Risk Auto Farm Toggle changed:", Options.riskautofarm.Value)
    end)

    local RandomEnemyToggle =
        UI2:AddToggle(
        "RandomEnemyToggle",
        {
            Title = "Get Random Enemy",
            Default = false
        }
    )

    RandomEnemyToggle:OnChanged(
        function()
            warn("Random Enemy Toggle changed:", Options.RandomEnemyToggle.Value)
        end
    )

    local FocusEnemyToggle =
        UI2:AddToggle(
        "FocusEnemyToggle",
        {
            Title = "Focus Enemy",
            Default = false
        }
    )

    FocusEnemyToggle:OnChanged(
        function()
            warn("Focus Enemy Toggle changed:", Options.FocusEnemyToggle.Value)
        end
    )

    -- local UI3 = tabs.extraction:AddSection("Main")
    -- Add Paragraph that it only works on your own private server and doing it solo
    -- Add Auto Turn on Auto Choose Map Toggle
    -- Add Auto PotFarm Toggle
end
