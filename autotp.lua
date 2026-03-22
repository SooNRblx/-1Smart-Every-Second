-- 1. SERVICES
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Nettoyage
if playerGui:FindFirstChild("AppleAutoFarmGui") then
    playerGui.AppleAutoFarmGui:Destroy()
end

-- 2. VARIABLES
local farmActive = {f1 = false, f5 = false, f15 = false, f50 = false}
local antiAfkActive = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local farmWaitTime = 0.30

local positions = {
    f1 = Vector3.new(225.466, 8, 8.099),
    f5 = Vector3.new(225.78, 8, -71.401),
    f15 = Vector3.new(244.28, 8, -152.901),
    f50 = Vector3.new(90.266, 248.78, -232.776)
}

-- 3. INTERFACE
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AppleAutoFarmGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local logo = Instance.new("TextButton", screenGui)
logo.Size = UDim2.new(0, 60, 0, 60)
logo.Position = UDim2.new(0, 20, 0, 150)
logo.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
logo.Text = "🍎"
logo.TextSize = 35
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 350, 0, 300)
frame.Position = UDim2.new(0.5, -175, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "Apple Incremental"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.BackgroundTransparency = 1; title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -34, 0, 6)
close.Text = "X"; close.BackgroundColor3 = Color3.fromRGB(180, 40, 40); close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -85)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.CanvasSize = UDim2.new(0, 0, 0, 550); scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Fonctions utilitaires
local function makeDraggable(obj, target)
    target = target or obj
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function setupSlider(name, min, max, parent, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -20, 0, 60); container.BackgroundTransparency = 1
    
    local lab = Instance.new("TextLabel", container)
    lab.Size = UDim2.new(1, 0, 0, 20); lab.Text = name..": "..min; lab.Font = Enum.Font.Gotham; lab.TextSize = 14; lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1; lab.TextXAlignment = Enum.TextXAlignment.Left
    
    local back = Instance.new("Frame", container)
    back.Size = UDim2.new(1, -20, 0, 6); back.Position = UDim2.new(0, 10, 0, 35); back.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", back)
    
    local dot = Instance.new("Frame", back)
    dot.Size = UDim2.new(0, 18, 0, 18); dot.Position = UDim2.new(0, 0, 0.5, -9); dot.BackgroundColor3 = Color3.fromRGB(100, 200, 255); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local isSliding = false
    local function update(input)
        local rel = math.clamp((input.Position.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
        dot.Position = UDim2.new(rel, -9, 0.5, -9)
        local val = math.floor(min + (rel * (max - min)))
        lab.Text = name..": "..val
        callback(val)
    end
    back.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true scroll.ScrollingEnabled = false update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false scroll.ScrollingEnabled = true end
    end)
end

-- SECTION AUTO FARM
local farmSection = Instance.new("Frame", scroll)
farmSection.Size = UDim2.new(0, 310, 0, 190); farmSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Instance.new("UICorner", farmSection)
local farmTitle = Instance.new("TextLabel", farmSection)
farmTitle.Size = UDim2.new(0, 100, 0, 25); farmTitle.Position = UDim2.new(0, 10, 0, 5); farmTitle.Text = "Auto Farm"; farmTitle.Font = Enum.Font.GothamBold; farmTitle.TextSize = 12; farmTitle.TextColor3 = Color3.fromRGB(150, 150, 150); farmTitle.BackgroundTransparency = 1; farmTitle.TextXAlignment = Enum.TextXAlignment.Left

local listFarm = Instance.new("Frame", farmSection)
listFarm.Size = UDim2.new(1, 0, 1, -30); listFarm.Position = UDim2.new(0, 0, 0, 30); listFarm.BackgroundTransparency = 1
local listL = Instance.new("UIListLayout", listFarm); listL.Padding = UDim.new(0, 5); listL.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createBtn(name, key, parent)
    local cont = Instance.new("Frame", parent); cont.Size = UDim2.new(1, -20, 0, 35); cont.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", cont); l.Size = UDim2.new(0, 150, 1, 0); l.Text = name; l.Font = Enum.Font.Gotham; l.TextSize = 16; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", cont); b.Size = UDim2.new(0, 70, 0, 28); b.Position = UDim2.new(1, -75, 0.5, -14); b.Text = "OFF"; b.BackgroundColor3 = Color3.fromRGB(70,70,70); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        farmActive[key] = not farmActive[key]
        b.Text = farmActive[key] and "ON" or "OFF"
        b.BackgroundColor3 = farmActive[key] and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(70,70,70)
    end)
end

createBtn("+1 Wins", "f1", listFarm)
createBtn("+5 Wins", "f5", listFarm)
createBtn("+15 Wins", "f15", listFarm)
createBtn("+50 Wins", "f50", listFarm)

-- SECTION MOVEMENT
local moveSection = Instance.new("Frame", scroll)
moveSection.Size = UDim2.new(0, 310, 0, 150); moveSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Instance.new("UICorner", moveSection)
local moveL = Instance.new("UIListLayout", moveSection); moveL.Padding = UDim.new(0, 5); moveL.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("Frame", moveSection).Size = UDim2.new(0,0,0,5) -- Spacer

setupSlider("WalkSpeed", 16, 250, moveSection, function(v) walkSpeedValue = v end)
setupSlider("JumpPower", 50, 350, moveSection, function(v) jumpPowerValue = v end)

-- SECTION MISC
local miscSection = Instance.new("Frame", scroll)
miscSection.Size = UDim2.new(0, 310, 0, 60); miscSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Instance.new("UICorner", miscSection)
local labAA = Instance.new("TextLabel", miscSection); labAA.Size = UDim2.new(0, 150, 1, 0); labAA.Position = UDim2.new(0, 10, 0, 0); labAA.Text = "Anti-AFK"; labAA.Font = Enum.Font.Gotham; labAA.TextSize = 16; labAA.TextColor3 = Color3.new(1,1,1); labAA.BackgroundTransparency = 1; labAA.TextXAlignment = Enum.TextXAlignment.Left
local btnAA = Instance.new("TextButton", miscSection); btnAA.Size = UDim2.new(0, 70, 0, 28); btnAA.Position = UDim2.new(1, -85, 0.5, -14); btnAA.Text = "OFF"; btnAA.BackgroundColor3 = Color3.fromRGB(70,70,70); btnAA.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnAA)

-- Activation Drag & Boutons
makeDraggable(logo); makeDraggable(header, frame)
logo.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
close.MouseButton1Click:Connect(function() frame.Visible = false end)
btnAA.MouseButton1Click:Connect(function() antiAfkActive = not antiAfkActive btnAA.Text = antiAfkActive and "ON" or "OFF" btnAA.BackgroundColor3 = antiAfkActive and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(70,70,70) end)

-- LOOP
RunService.Stepped:Connect(function()
    pcall(function()
        player.Character.Humanoid.WalkSpeed = walkSpeedValue
        player.Character.Humanoid.JumpPower = jumpPowerValue
    end)
end)

task.spawn(function()
    while true do
        local target = nil
        if farmActive.f1 then target = positions.f1
        elseif farmActive.f5 then target = positions.f5
        elseif farmActive.f15 then target = positions.f15
        elseif farmActive.f50 then target = positions.f50 end
        if target then
            pcall(function() player.Character.HumanoidRootPart.CFrame = CFrame.new(target) end)
            task.wait(farmWaitTime)
        else task.wait(0.5) end
    end
end)

player.Idled:Connect(function()
    if antiAfkActive then pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end
end)
