-- Locals
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local GunMods = false
local ValidGuns = {
    ["NavyRevolver"] = true,
    ["Shotgun"] = true,
    ["Rifle"] = true,
    ["Sawed-Off Shotgun"] = true,
    ["Revolver"] = true,
    ["Mauser"] = true,
    ["Electrocutioner"] = true,
    ["Bot Action Rifle"] = true
}
-- Continuous check for gun modifications
RunService.RenderStepped:Connect(function()
    if not GunMods then return end -- Skip if GunMods is disabled

    local Character = Player.Character
    if not Character then return end -- Skip if Character doesn't exist

    local Tool = Character:FindFirstChildWhichIsA("Tool")
    if Tool and ValidGuns[Tool.Name] then
        local Config = Tool:FindFirstChildWhichIsA("Configuration")

        if Config then
            local FireDelay = Config:FindFirstChild("FireDelay")
            local SpreadAngle = Config:FindFirstChild("SpreadAngle")
            local ReloadDuration = Config:FindFirstChild("ReloadDuration")

            if FireDelay then FireDelay.Value = 0.1 end
            if SpreadAngle then SpreadAngle.Value = 0.5 end
            if ReloadDuration then ReloadDuration.Value = 0.1 end
        end
    end
end)

local function ToggleGunMods()
    GunMods = not GunMods
    print("GunMods:", GunMods and "Enabled" or "Disabled")
end

local Gunmod = {
    ToggleGunMods = ToggleGunMods
}

return Gunmod