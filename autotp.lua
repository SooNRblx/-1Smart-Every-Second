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
screenGui.DisplayOrder = 999999999 
screenGui.IgnoreGuiInset = true    

local logo = Instance.new("TextButton", screenGui)
logo.Size = UDim2.new(0, 60, 0, 60)
logo.Position = UDim2.new(0, 20, 0, 150)
logo.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
logo.Text = "🍎"
logo.TextSize = 35
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 350, 0, 400) 
frame.Position = UDim2.new(0.5, -175, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "Apple Incremental"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -34, 0, 6)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -55)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 650)
scroll.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 12)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Fonctions utilitaires UI
local function createSection(titleText, height, parent)
    local sec = Instance.new("Frame", parent)
    sec.Size = UDim2.new(0, 320, 0, height)
    sec.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", sec)
    
    local lab = Instance.new("TextLabel", sec)
    lab.Size = UDim2.new(0, 100, 0, 25)
    lab.Position = UDim2.new(0, 10, 0, 5)
    lab.Text = titleText
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 12
    lab.TextColor3 = Color3.fromRGB(180, 180, 180)
    lab.BackgroundTransparency = 1
    lab.TextXAlignment = Enum.TextXAlignment.Left
    
    return sec
end

local function createToggle(name, yPos, parent)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -20, 0, 35)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    
    local lab = Instance.new("TextLabel", container)
    lab.Size = UDim2.new(0, 150, 1, 0)
    lab.Text = name
    lab.Font = Enum.Font.Gotham
    lab.TextSize = 15
    lab.TextColor3 = Color3.new(1, 1, 1)
    lab.BackgroundTransparency = 1
    lab.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0, 70, 0, 28)
    btn.Position = UDim2.new(1, -70, 0.5, -14)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    
    return btn
end

-- SECTION AUTO FARM
local farmSec = createSection("Auto Farm", 180, scroll)
local btn1 = createToggle("+1 Wins", 35, farmSec)
local btn5 = createToggle("+5 Wins", 70, farmSec)
local btn15 = createToggle("+15 Wins", 105, farmSec)
local btn50 = createToggle("+50 Wins", 140, farmSec)

-- SECTION MOVEMENT
local moveSec = createSection("Movement", 150, scroll)

local function setupSlider(name, yPos, min, max, default, parent, callback)
    local lab = Instance.new("TextLabel", parent)
    lab.Size = UDim2.new(1, -20, 0, 20)
    lab.Position = UDim2.new(0, 10, 0, yPos)
    lab.Text = name..": "..default
    lab.Font = Enum.Font.Gotham; lab.TextSize = 14; lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1; lab.TextXAlignment = Enum.TextXAlignment.Left
    
    local slideBack = Instance.new("Frame", parent)
    slideBack.Size = UDim2.new(1, -40, 0, 4)
    slideBack.Position = UDim2.new(0, 20, 0, yPos + 25)
    slideBack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local dot = Instance.new("Frame", slideBack)
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, 0, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local isSliding = false
    local function update(input)
        local rel = math.clamp((input.Position.X - slideBack.AbsolutePosition.X) / slideBack.AbsoluteSize.X, 0, 1)
        dot.Position = UDim2.new(rel, -8, 0.5, -8)
        local val = math.floor(min + (rel * (max - min)))
        lab.Text = name..": "..val
        callback(val)
    end
    slideBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true scroll.ScrollingEnabled = false update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function() isSliding = false scroll.ScrollingEnabled = true end)
end

setupSlider("WalkSpeed", 30, 16, 300, 16, moveSec, function(v) walkSpeedValue = v end)
setupSlider("JumpPower", 85, 50, 500, 50, moveSec, function(v) jumpPowerValue = v end)

-- SECTION MISC
local miscSec = createSection("Misc", 70, scroll)
local btnAntiAfk = createToggle("Anti-AFK", 30, miscSec)

-- 4. LOGIQUE DRAG
local function makeDraggable(obj, target)
    target = target or obj
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = target.Position end
    end)
    obj.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function() dragging = false end)
end
makeDraggable(logo); makeDraggable(header, frame)

-- 5. INTERACTIONS BOUTONS
local function updateBtnStyle(btn, active)
    btn.Text = active and "ON" or "OFF"
    btn.BackgroundColor3 = active and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(70, 70, 70)
end

logo.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
close.MouseButton1Click:Connect(function() frame.Visible = false end)

btn1.MouseButton1Click:Connect(function() farmActive.f1 = not farmActive.f1 updateBtnStyle(btn1, farmActive.f1) end)
btn5.MouseButton1Click:Connect(function() farmActive.f5 = not farmActive.f5 updateBtnStyle(btn5, farmActive.f5) end)
btn15.MouseButton1Click:Connect(function() farmActive.f15 = not farmActive.f15 updateBtnStyle(btn15, farmActive.f15) end)
btn50.MouseButton1Click:Connect(function() farmActive.f50 = not farmActive.f50 updateBtnStyle(btn50, farmActive.f50) end)
btnAntiAfk.MouseButton1Click:Connect(function() antiAfkActive = not antiAfkActive updateBtnStyle(btnAntiAfk, antiAfkActive) end)

-- BOUCLES DE FONCTIONNEMENT
RunService.Stepped:Connect(function()
    pcall(function()
        local hum = player.Character.Humanoid
        hum.WalkSpeed = walkSpeedValue
        hum.JumpPower = jumpPowerValue
    end)
end)

task.spawn(function()
    while true do
        local pos = nil
        if farmActive.f1 then pos = positions.f1
        elseif farmActive.f5 then pos = positions.f5
        elseif farmActive.f15 then pos = positions.f15
        elseif farmActive.f50 then pos = positions.f50 end
        
        if pos then
            pcall(function() player.Character.HumanoidRootPart.CFrame = CFrame.new(pos) end)
            task.wait(farmWaitTime)
        else
            task.wait(0.5)
        end
    end
end)

-- Anti-AFK
player.Idled:Connect(function()
    if antiAfkActive then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)
