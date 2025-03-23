local baseUrl = "https://raw.githubusercontent.com/None7464/testss/main/skibidi/"

print("Loading....")
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
        warn("Failed to load:", url, "Error:", result)
        return nil
    end
end

local Config = SafeLoad(baseUrl .. "Config.lua")
local Utilities = SafeLoad(baseUrl .. "Utilities.lua")
local ESP = SafeLoad(baseUrl .. "ESP/ESP.lua")(Config, Utilities)
local Gunmod = SafeLoad(baseUrl .. "Gunmod.lua")
local Aimbot = SafeLoad(baseUrl .. "Aimbot.lua")(Config, ESP, Gunmod, Aimbot)

ESP.Initialize()

local UI = SafeLoad(baseUrl .. "Ui.lua") -- Check if it loads correctly
if UI then
    UI(Config, ESP, Aimbot, Gunmod)
else
    warn("UI failed to load!")
end

local function ModifyPrompts()
    for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end

ModifyPrompts()
print("Railed Script Loaded!")
