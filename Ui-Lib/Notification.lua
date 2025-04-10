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
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Position = UDim2.new(0, 0, 0, 0)
	container.Parent = screenGui

	return container
end

local function buildNotificationFrame(alertType, message)
	local container = getContainer()

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 50)
	frame.Position = UDim2.new(1, 20, 1, -80)
	frame.BackgroundColor3 = alertType.Color
	frame.BorderSizePixel = 0
	frame.Name = "Notification"
	frame.AnchorPoint = Vector2.new(1, 1)
	frame.ClipsDescendants = true
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.Parent = container

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	-- Layout and padding
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = frame

	local icon = Instance.new("TextLabel")
	icon.Text = alertType.Emoji
	icon.Font = Enum.Font.Gotham
	icon.TextSize = 20
	icon.TextColor3 = Color3.new(1, 1, 1)
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(0, 24, 0, 24)
	icon.LayoutOrder = 1
	icon.TextXAlignment = Enum.TextXAlignment.Center
	icon.TextYAlignment = Enum.TextYAlignment.Center
	icon.Parent = frame	

	local label = Instance.new("TextLabel")
	label.Text = message
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -120, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = 2
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Parent = frame

	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.Gotham
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.BackgroundTransparency = 1
	closeBtn.LayoutOrder = 3
	closeBtn.Parent = frame

	closeBtn.MouseButton1Click:Connect(function()
		frame:Destroy()
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
