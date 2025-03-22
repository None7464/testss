return function(Config, Utilities)
    local ESPConfig = loadstring(game:HttpGet(" "))()
    local ESPObject = loadstring(game:HttpGet(" "))()(Config, Utilities, ESPConfig)
    local ESPManager = loadstring(game:HttpGet(" "))()(Config, Utilities, ESPObject, ESPConfig)
    
    local ESP = {}
    
    ESP.Initialize = ESPManager.Initialize
    ESP.Cleanup = ESPManager.Cleanup
    ESP.Update = ESPManager.Update
    ESP.SetEnabled = ESPManager.SetEnabled
    ESP.IsEnabled = ESPManager.IsEnabled
    ESP.HandleToggleKey = ESPManager.HandleToggleKey
    
    return ESP
end