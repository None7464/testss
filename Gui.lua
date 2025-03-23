local library = {
    windowcount = 0
}

local dragger = {}
local resizer = {}

do
    local inputService = game:GetService("UserInputService")

    function dragger.new(frame)
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

        inputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end    

    function resizer.new(p, s)
        p:GetPropertyChangedSignal("AbsoluteSize"):Connect(
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

-- Function to delete the UI
function library:KillUI()
    if game:GetService("CoreGui"):FindFirstChild("SkibidiGUI") then
        game:GetService("CoreGui"):FindFirstChild("SkibidiGUI"):Destroy()
    end
end

function library:CreateWindow(options)
    assert(options.text, "No name provided for window")
    local window = {
        count = 0,
        toggles = {},
        closed = false
    }

    local options = options or {}
    setmetatable(options, {__index = defaults})

    self.windowcount = self.windowcount + 1

    -- Remove existing UI with the same name
    self:KillUI()

    library.gui = library.gui or self:Create("ScreenGui", {Name = "SkibidiGUI", Parent = game:GetService("CoreGui")})
    
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

    dragger.new(window.frame)
    resizer.new(window.frame, window.container)

    function window:Resize()
        local ySize = 0
        for _, object in ipairs(window.container:GetChildren()) do
            if not object:IsA("UIListLayout") and not object:IsA("UIPadding") then
                ySize = ySize + object.AbsoluteSize.Y
            end
        end
        window.container.Size = UDim2.new(1, 0, 0, ySize + 10)
    end

    function window:AddButton(text, callback)
        self.count = self.count + 1
        callback = callback or function() end

        local button = library:Create("TextButton", {
            Text = text,
            Size = UDim2.new(1, -10, 0, 30),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.SourceSansSemibold,
            BorderSizePixel = 2,
            BorderColor3 = Color3.fromRGB(0, 255, 140),
            LayoutOrder = self.count,
            Parent = self.container
        })

        local uiCorner = Instance.new("UICorner", button)
        uiCorner.CornerRadius = UDim.new(0, 5)

        button.MouseButton1Click:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
            wait(0.1)
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            callback()
        end)

        self:Resize()
        return button
    end

    return window
end

return library
