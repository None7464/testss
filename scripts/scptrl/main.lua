local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/Ui-Lib/Gui.lua", true))()

local UI = library:CreateWindow({ text = "The Red Lake Script" })

UI:AddToggle("Public Server Version", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/scripts/scptrl/public.lua", true))()
    wait()
    library:DestroyUI()
end)

UI:AddToggle("Private Server Version", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/scripts/scptrl/ps.lua", true))()
    wait()
    library:DestroyUI()
end)
