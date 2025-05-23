local library = {
    windowcount = 0
}

library.settingsFile = "Skibidi.json"
local http = game:GetService("HttpService")

library.settings = {}

local dragger = {}
local resizer = {}

do -- still a bit off in mobile but if it works, never touch it
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local inputService = game:GetService("UserInputService")
    local heartbeat = game:GetService("RunService").Heartbeat
    function dragger.new(frame)
        local UserInputService = game:GetService("UserInputService")
        local dragging, dragInput, dragStart, startPos
    
        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
    
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
    
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end    

    function resizer.new(p, s)
        p:GetPropertyChangedSignal("AbsoluteSize"):connect(
            function()
                s.Size = UDim2.new(s.Size.X.Scale, s.Size.X.Offset, s.Size.Y.Scale, p.AbsoluteSize.Y)
            end
        )
    end
end

local defaults = {
    txtcolor = Color3.fromRGB(255, 255, 255),
    underline = Color3.fromRGB(0, 255, 140),
    barcolor = Color3.fromRGB(40, 40, 40),
    bgcolor = Color3.fromRGB(30, 30, 30)
}

function library:Create(class, props)
    local object = Instance.new(class)

    for i, prop in next, props do
        if i ~= "Parent" then
            object[i] = prop
        end
    end

    object.Parent = props.Parent
    return object
end

function library:LoadSettings()
    if isfile(self.settingsFile) then
        local success, data = pcall(readfile, self.settingsFile)
        if success then
            local successDecode, decoded = pcall(http.JSONDecode, http, data)
            if successDecode and type(decoded) == "table" then
                self.settings = decoded
            else
                warn("Failed to decode settings. Using default.")
                self.settings = {}
            end
        else
            warn("Failed to read settings file.")
            self.settings = {}
        end
    else
        self.settings = {}
    end
end

function library:SaveSettings()
    local mergedSettings = {}

    -- Safely read existing settings if the file exists
    if isfile(self.settingsFile) then
        local success, data = pcall(readfile, self.settingsFile)
        if success then
            local successDecode, decoded = pcall(http.JSONDecode, http, data)
            if successDecode and type(decoded) == "table" then
                mergedSettings = decoded
            end
        end
    end

    -- Merge the current settings
    for key, value in pairs(self.settings) do
        mergedSettings[key] = value
    end

    -- Encode and write the final result
    local success, encoded = pcall(http.JSONEncode, http, mergedSettings)
    if success then
        pcall(writefile, self.settingsFile, encoded)
    else
        warn("Failed to encode settings.")
    end
end

function library:CreateWindow(options)
    assert(options.text, "no name")
    local window = {
        count = 0,
        toggles = {},
        closed = false
    }

    local options = options or {}
    setmetatable(options, {__index = defaults})

    self.windowcount = self.windowcount + 1

    library.gui = library.gui or self:Create("ScreenGui", {Name = "UILibrary", Parent = game:GetService("CoreGui")})
    window.frame =
        self:Create(
        "Frame",
        {
            Name = options.text,
            Parent = self.gui,
            Active = true,
            BackgroundTransparency = 0,
            Size = UDim2.new(0, 190, 0, 30),
            Position = UDim2.new(0, (15 + ((200 * self.windowcount) - 200)), 0, 15),
            BackgroundColor3 = options.barcolor,
            BorderSizePixel = 0
        }
    )

    window.background =
        self:Create(
        "Frame",
        {
            Name = "Background",
            Parent = window.frame,
            BorderSizePixel = 0,
            BackgroundColor3 = options.bgcolor,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 25),
            ClipsDescendants = true
        }
    )

    window.container =
        self:Create(
        "Frame",
        {
            Name = "Container",
            Parent = window.frame,
            BorderSizePixel = 0,
            BackgroundColor3 = options.bgcolor,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 25),
            ClipsDescendants = true
        }
    )

    window.organizer =
        self:Create(
        "UIListLayout",
        {
            Name = "Sorter",
            --Padding = UDim.new(0, 0);
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = window.container
        }
    )

    window.padder =
        self:Create(
        "UIPadding",
        {
            Name = "Padding",
            PaddingLeft = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 5),
            Parent = window.container
        }
    )

    self:Create(
        "Frame",
        {
            Name = "Underline",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BorderSizePixel = 0,
            BackgroundColor3 = options.underline,
            Parent = window.frame
        }
    )

    local togglebutton =
        self:Create(
        "TextButton",
        {
            Name = "Toggle",
            ZIndex = 2,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -25, 0, 0),
            Size = UDim2.new(0, 25, 1, 0),
            Text = "-",
            TextSize = 17,
            TextColor3 = options.txtcolor,
            Font = Enum.Font.SourceSans,
            Parent = window.frame
        }
    )

    togglebutton.MouseButton1Click:connect(
        function()
            window.closed = not window.closed
            togglebutton.Text = (window.closed and "+" or "-")
            if window.closed then
                window:Resize(true, UDim2.new(1, 0, 0, 0))
            else
                window:Resize(true)
            end
        end
    )

    self:Create(
        "TextLabel",
        {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextColor3 = options.txtcolor,
            TextColor3 = (options.bartextcolor or Color3.fromRGB(255, 255, 255)),
            TextSize = 17,
            Font = Enum.Font.SourceSansSemibold,
            Text = options.text or "window",
            Name = "Window",
            Parent = window.frame
        }
    )

    do
        dragger.new(window.frame)
        resizer.new(window.background, window.container)
    end

    local function getSize()
        local ySize = 0
        for i, object in next, window.container:GetChildren() do
            if (not object:IsA("UIListLayout")) and (not object:IsA("UIPadding")) then
                ySize = ySize + object.AbsoluteSize.Y
            end
        end
        return UDim2.new(1, 0, 0, ySize + 10)
    end

    function window:Resize(tween, change)
        local size = change or getSize()
        self.container.ClipsDescendants = true

        if tween then
            self.background:TweenSize(size, "Out", "Sine", 0.5, true)
        else
            self.background.Size = size
        end
    end
    
    function window:AddToggle(text, callback, defaultState)
        self.count = self.count + 1
        defaultState = defaultState or false
    
        local label = library:Create("TextLabel", {
            Text = text,
            Size = UDim2.new(1, -10, 0, 20),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = self.count,
            TextSize = 16,
            Font = Enum.Font.SourceSans,
            Parent = self.container
        })
    
        local button = library:Create("TextButton", {
            Text = defaultState and "ON" or "OFF",
            TextColor3 = defaultState and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(255, 25, 25),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -25, 0, 0),
            Size = UDim2.new(0, 25, 1, 0),
            TextSize = 17,
            Font = Enum.Font.SourceSansSemibold,
            Parent = label
        })
    
        self.toggles[text] = defaultState
    
        button.MouseButton1Click:Connect(function()
            local state = not self.toggles[text]
            self.toggles[text] = state
            button.Text = state and "ON" or "OFF"
            button.TextColor3 = state and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(255, 25, 25)
    
            if callback then
                callback(state)
            end
        end)
    
        self:Resize()
        return button
    end

    function window:AddBox(text, callback)
        self.count = self.count + 1
        callback = callback or function()
            end

        local box =
            library:Create(
            "TextBox",
            {
                PlaceholderText = text,
                Size = UDim2.new(1, -10, 0, 20),
                --Position = UDim2.new(0, 5, 0, ((20 * self.count) - 20) + 5),
                BackgroundTransparency = 0.75,
                BackgroundColor3 = options.boxcolor,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextSize = 16,
                Text = "",
                Font = Enum.Font.SourceSans,
                LayoutOrder = self.count,
                BorderSizePixel = 0,
                Parent = self.container
            }
        )

        box.FocusLost:connect(
            function(...)
                callback(box, ...)
            end
        )

        self:Resize()
        return box
    end

    function window:AddButton(text, callback)
        self.count = self.count + 1
        callback = callback or function() end
    
        local button = library:Create("TextButton", {
            Text = text,
            Size = UDim2.new(1, -10, 0, 25),
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.SourceSansBold,
            LayoutOrder = self.count,
            Parent = self.container
        })
    
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
    
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end)
    
        button.MouseButton1Down:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end)
    
        button.MouseButton1Up:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
    
        button.MouseButton1Click:Connect(callback)
        self:Resize()
        return button
    end    

    function window:AddLabel(text)
        self.count = self.count + 1

        local tSize =
            game:GetService("TextService"):GetTextSize(
            text,
            16,
            Enum.Font.SourceSans,
            Vector2.new(math.huge, math.huge)
        )

        local button =
            library:Create(
            "TextLabel",
            {
                Text = text,
                Size = UDim2.new(1, -10, 0, tSize.Y + 5),
                TextScaled = false,
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 16,
                Font = Enum.Font.SourceSans,
                LayoutOrder = self.count,
                Parent = self.container
            }
        )

        self:Resize()
        return button
    end

    function window:AddDropdown(options, callback)
        self.count = self.count + 1
        local default = options[1] or ""

        callback = callback or function()
            end
        local dropdown =
            library:Create(
            "TextLabel",
            {
                Size = UDim2.new(1, -10, 0, 20),
                BackgroundTransparency = 0.75,
                BackgroundColor3 = options.boxcolor,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextSize = 16,
                Text = default,
                Font = Enum.Font.SourceSans,
                BorderSizePixel = 0,
                LayoutOrder = self.count,
                Parent = self.container
            }
        )

        local button =
            library:Create(
            "ImageButton",
            {
                BackgroundTransparency = 1,
                Image = "rbxassetid://3234893186",
                Size = UDim2.new(0, 18, 1, 0),
                Position = UDim2.new(1, -20, 0, 0),
                Parent = dropdown
            }
        )

        local frame

        local function isInGui(frame)
            local mloc = game:GetService("UserInputService"):GetMouseLocation()
            local mouse = Vector2.new(mloc.X, mloc.Y - 36)

            local x1, x2 = frame.AbsolutePosition.X, frame.AbsolutePosition.X + frame.AbsoluteSize.X
            local y1, y2 = frame.AbsolutePosition.Y, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y

            return (mouse.X >= x1 and mouse.X <= x2) and (mouse.Y >= y1 and mouse.Y <= y2)
        end

        local function count(t)
            local c = 0
            for i, v in next, t do
                c = c + 1
            end
            return c
        end

        button.MouseButton1Click:connect(
            function()
                if count(options) == 0 then
                    return
                end

                if frame then
                    frame:Destroy()
                    frame = nil
                end

                self.container.ClipsDescendants = false

                frame =
                    library:Create(
                    "Frame",
                    {
                        Position = UDim2.new(0, 0, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Size = UDim2.new(0, dropdown.AbsoluteSize.X, 0, (count(options) * 21)),
                        BorderSizePixel = 0,
                        Parent = dropdown,
                        ClipsDescendants = true,
                        ZIndex = 2
                    }
                )

                library:Create(
                    "UIListLayout",
                    {
                        Name = "Layout",
                        Parent = frame
                    }
                )

                for i, option in next, options do
                    local selection =
                        library:Create(
                        "TextButton",
                        {
                            Text = option,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            BorderSizePixel = 0,
                            TextSize = 16,
                            Font = Enum.Font.SourceSans,
                            Size = UDim2.new(1, 0, 0, 21),
                            Parent = frame,
                            ZIndex = 2
                        }
                    )

                    selection.MouseButton1Click:connect(
                        function()
                            dropdown.Text = option
                            callback(option)
                            frame.Size = UDim2.new(1, 0, 0, 0)
                            game:GetService("Debris"):AddItem(frame, 0.1)
                        end
                    )
                end
            end
        )

        game:GetService("UserInputService").InputBegan:connect(
            function(m)
                if m.UserInputType == Enum.UserInputType.MouseButton1 then
                    if frame and (not isInGui(frame)) then
                        game:GetService("Debris"):AddItem(frame)
                    end
                end
            end
        )

        callback(default)
        self:Resize()
        return {
            Refresh = function(self, array)
                game:GetService("Debris"):AddItem(frame)
                options = array
                dropdown.Text = options[1]
            end
        }
    end

    function window:AddSlider(text, min, max, default, callback)
        self.count = self.count + 1
        callback = callback or function() end
    
        local sliderFrame = library:Create("Frame", {
            Size = UDim2.new(1, -10, 0, 30),
            BackgroundTransparency = 1,
            Parent = self.container,
            LayoutOrder = self.count
        })
    
        local label = library:Create("TextLabel", {
            Text = text .. ": " .. tostring(default),
            Size = UDim2.new(1, -10, 0, 20),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 16,
            Font = Enum.Font.SourceSans,
            Parent = sliderFrame
        })
    
        local sliderBar = library:Create("Frame", {
            Size = UDim2.new(1, -10, 0, 8),
            Position = UDim2.new(0, 5, 1, -10),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 0,
            Parent = sliderFrame
        })
    
        local sliderButton = library:Create("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = sliderBar
        })
    
        local UICorner = Instance.new("UICorner", sliderButton)
        UICorner.CornerRadius = UDim.new(1, 0) -- Makes it round
    
        local dragging = false
        local function update(input)
            local sizeX = sliderBar.AbsoluteSize.X
            local deltaX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sizeX, 0, 1)
            local newValue = math.floor((deltaX * (max - min)) + min)
    
            sliderButton.Position = UDim2.new(deltaX, -6, 0.5, -6)
            label.Text = text .. ": " .. tostring(newValue)
            callback(newValue)
        end
    
        sliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
    
        sliderButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then update(input) end
            end
        end)
    
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    
        self:Resize()
        return sliderButton
    end

    function library:DestroyUI()
        if library.gui then
            library.gui:Destroy()
            library.gui = nil
        end
    end

    function window:Destroy()
        if self.frame then
            self.frame:Destroy()
            self.frame = nil
        end
    end

    return window
end
return library
