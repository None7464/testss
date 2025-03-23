return function(Config, Utilities)
    local ESPConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/skibidi/ESP/ESPConfig.lua"))()
    local ESPObject = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/skibidi/ESP/ESPManager.lua"))()(Config, Utilities, ESPConfig)
    local ESPManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/refs/heads/main/skibidi/ESP/ESPObject.lua"))()(Config, Utilities, ESPObject, ESPConfig)
    
    local ESP = {}
    
    ESP.Initialize = ESPManager.Initialize
    ESP.Cleanup = ESPManager.Cleanup
    ESP.Update = ESPManager.Update
    ESP.SetEnabled = ESPManager.SetEnabled
    ESP.IsEnabled = ESPManager.IsEnabled
    ESP.HandleToggleKey = ESPManager.HandleToggleKey
    
    return ESP
end
