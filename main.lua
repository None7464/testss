local baseUrl = "https://raw.githubusercontent.com/None7464/testss/main/skibidi/"

local Config = loadstring(game:HttpGet(baseUrl .. "Config.lua"))()
local Utilities = loadstring(game:HttpGet(baseUrl .. "Utilities.lua"))()
local ESP = loadstring(game:HttpGet(baseUrl .. "ESP/ESP.lua"))()(Config, Utilities)
local Gunmod = loadstring(game:HttpGet(baseUrl .. "Gunmod.lua"))()
local Aimbot = loadstring(game:HttpGet(baseUrl .. "Aimbot.lua"))()
local UI = loadstring(game:HttpGet(baseUrl .. "UI.lua"))()(Config, ESP, Aimbot, Gunmod)

ESP.Initialize()
Aimbot.Initialize()

local function ModifyPrompts()
    for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end

ModifyPrompts()

print("Railed Script Loaded!")
