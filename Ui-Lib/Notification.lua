local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Notify = {}
local queue = {}
local isDisplaying = false
local padding = 10
local container

local AlertStyles = {
	Info = { -- ℹ️ Info
		Color = Color3.fromRGB(59, 130, 246),
		Emoji = "ℹ️"
	},
	Error = { -- ❗ Error
		Color = Color3.fromRGB(239, 68, 68),
		Emoji = "❗"
	},
	Success = { -- ✔️ Success
		Color = Color3.fromRGB(34, 197, 94),
		Emoji = "✔️"
	}
}

local function getContainer()
	if container then return container end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = playerGui:FindFirstChild("NotifyGui") or Instance.new("ScreenGui")
	screenGui.Name = "NotifyGui"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	container = Instance.new("Frame")
	container.Name = "NotificationContainer"
	container.Size = UDim2.new(0, 320, 1, 0)
	container.Position = UDim2.new(1, -330, 0, 60) -- top right, under the top bar
	container.BackgroundTransparency = 1
	container.AnchorPoint = Vector2.new(0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 6)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = container

	return container
end

local function buildNotificationFrame(alertType, message)
	local container = getContainer()

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 60)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	frame.BorderSizePixel = 0
	frame.Name = "Notification"
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.ClipsDescendants = true
	frame.LayoutOrder = os.clock() -- newer ones on bottom
	frame.Parent = container

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = frame

	local emoji = Instance.new("TextLabel")
	emoji.Text = alertType.Emoji
	emoji.Font = Enum.Font.GothamBold
	emoji.TextSize = 24
	emoji.TextColor3 = alertType.Color
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.new(0, 30, 0, 30)
	emoji.LayoutOrder = 1
	emoji.Parent = frame

	local label = Instance.new("TextLabel")
	label.Text = message
	label.Font = Enum.Font.Gotham
	label.TextWrapped = true
	label.TextSize = 14
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -80, 0, 30)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.LayoutOrder = 2
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Parent = frame

	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.Gotham
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.BackgroundTransparency = 1
	closeBtn.LayoutOrder = 3
	closeBtn.Parent = frame

	closeBtn.MouseButton1Click:Connect(function()
		frame:Destroy()
	end)

	-- Optional auto-remove after 5 seconds
	task.delay(5, function()
		if frame and frame.Parent then
			frame:Destroy()
		end
	end)

	return frame
end

local function animateAndWait(frame, duration)
	local index = #container:GetChildren()
	local finalY = -80 - (index - 1) * (frame.AbsoluteSize.Y + padding)

	local showTween = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -320, 1, finalY)
	})
	showTween:Play()
	showTween.Completed:Wait()

	-- Wait for duration or until destroyed manually
	local startTime = tick()
	while tick() - startTime < duration do
		if not frame or not frame.Parent then
			return
		end
		task.wait(0.1)
	end

	local hideTween = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 20, 1, finalY)
	})
	hideTween:Play()
	hideTween.Completed:Wait()

	if frame and frame.Parent then
		frame:Destroy()
	end
end

local function handleQueue()
	if isDisplaying or #queue == 0 then return end
	isDisplaying = true

	while #queue > 0 do
		local data = table.remove(queue, 1)
		local frame = buildNotificationFrame(data.alertType, data.message)
		animateAndWait(frame, data.duration)
	end

	isDisplaying = false
end

function Notify:Create(config)
	local alertType = AlertStyles[config.Type] or AlertStyles.Info
	local message = config.Message or "Notification"
	local duration = config.Duration or 3

	table.insert(queue, {
		alertType = alertType,
		message = message,
		duration = duration
	})

	handleQueue()
end

return Notify
