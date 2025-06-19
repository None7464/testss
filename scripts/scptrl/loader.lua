--[[
    Utility Loader (Remade)
    - Loads main script and notification UI
    - Disables idle kick
    - Sets all ProximityPrompt HoldDuration to 0
    - Checks for executor compatibility and notifies user if issues are found
    - Copies error info to clipboard if needed
--]]

--// UTILS

local function safeGetFunction(...)
    for _, fn in ipairs({...}) do
        if type(fn) == "function" then
            return fn
        end
    end
    return nil
end

local function getQueueOnTeleport()
    return safeGetFunction(queue_on_teleport, syn and syn.queue_on_teleport, queueonteleport)
end

local function copyToClipboard(text)
    local setclip = safeGetFunction(setclipboard, writeclipboard, set_clipboard, write_clipboard)
    if setclip then
        setclip(text)
    end
end

--// NOTIFICATION

local Notify = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/Ui-Lib/Notification.lua", true))()

local function notifyError(msg)
    Notify:Create({
        Type = "Error",
        Message = msg,
        Duration = 5
    })
end

--// ANTI-IDLE

for _, conn in ipairs(getconnections(game.Players.LocalPlayer.Idled)) do
    conn:Disable()
end

--// PROXIMITY PROMPT

local function patchPrompts()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end

patchPrompts()
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        desc.HoldDuration = 0
    end
end)

--// EXECUTOR CHECK

local function checkExecutor()
    local issues = {}
    local required = {
        getrawmetatable = safeGetFunction(getrawmetatable, get_raw_metatable),
        setrawmetatable = safeGetFunction(setrawmetatable, set_raw_metatable),
        setreadonly = safeGetFunction(setreadonly, make_readonly, makereadonly),
        getconnections = safeGetFunction(getconnections, get_connections, get_signal_cons),
        hookfunction = safeGetFunction(hookfunction, hookfunc, detour_function),
        http_request = safeGetFunction(http_request, request, httprequest),
        queue_on_teleport = getQueueOnTeleport(),
        setclipboard = safeGetFunction(setclipboard, writeclipboard, set_clipboard, write_clipboard),
    }
    for name, fn in pairs(required) do
        if type(fn) ~= "function" then
            table.insert(issues, name .. " is missing or not a function.")
        end
    end
    return issues
end

local function loadMainScript()
    local url = "https://raw.githubusercontent.com/None7464/testss/refs/heads/main/scripts/scptrl/loader.lua"
    loadstring(game:HttpGet(url))()
    if type(queue_on_teleport) == "function" then
        queue_on_teleport(('loadstring(game:HttpGet("%s"))()'):format(url))
    elseif type(queueonteleport) == "function" then
        queueonteleport(('loadstring(game:HttpGet("%s"))()'):format(url))
    end
end

local function main()
    local issues = checkExecutor()
    if #issues > 0 then
        local msg = "Environment error detected:\n" .. table.concat(issues, "\n") .. "\nPlease contact the developer and paste the copied info."
        copyToClipboard(msg)
        notifyError("Executor issue! Info copied for developer.")
    else
        loadMainScript()
    end
end

main()
