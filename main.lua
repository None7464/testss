local baseUrl = "https://raw.githubusercontent.com/None7464/testss/main/skibidi/"

local function SafeLoad(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result and result ~= "" then
        local func, loadErr = loadstring(result)
        if func then
            return func()
        else
            warn("Loadstring error:", loadErr)
            return nil
        end
    else
        warn("Failed to load:", url, result)
        return nil
    end
end

local Config = SafeLoad(baseUrl .. "Config.lua") or {}
local Utilities = SafeLoad(baseUrl .. "Utilities.lua") or {}
local ESP = SafeLoad(baseUrl .. "ESP/ESP.lua") or function() return {} end
local Gunmod = SafeLoad(baseUrl .. "Gunmod.lua") or {}
local Aimbot = SafeLoad(baseUrl .. "Aimbot.lua") or {}

local UI = SafeLoad(baseUrl .. "UI.lua")
if type(UI) == "function" then
    UI(Config, ESP, Aimbot, Gunmod)
else
    warn("UI.lua did not return a valid function")
end

if ESP.Initialize then ESP.Initialize() end
if Aimbot.Initialize then Aimbot.Initialize() end

local function ModifyPrompts()
    for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end

ModifyPrompts()
print("Railed Script Loaded!")
