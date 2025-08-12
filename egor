local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local env = getgenv()
env.XORVEX_ACTIVE = env.XORVEX_ACTIVE or {}

if env.XORVEX_EGOR_CLEANUP then
    env.XORVEX_EGOR_CLEANUP()
end

env.XORVEX_ACTIVE["egor"] = {}

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local egorMode = false
local defspeed = 16
local egorspeed = 3

local function createElement(className, parent, properties)
    local element = Instance.new(className, parent)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

local gui = createElement("ScreenGui", game:GetService("CoreGui"), {
    Name = "gui",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false
})

table.insert(env.XORVEX_ACTIVE["egor"], gui)

local main = createElement("Frame", gui, {
    Size = UDim2.new(0, 320, 0, 150),
    Position = UDim2.new(0.5, -160, 0.5, -100),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0
})

createElement("UICorner", main, {CornerRadius = UDim.new(0, 12)})

local innerFrame = createElement("Frame", main, {
    Size = UDim2.new(1, -4, 1, -4),
    Position = UDim2.new(0, 2, 0, 2),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0
})

createElement("UICorner", innerFrame, {CornerRadius = UDim.new(0, 10)})

local titleBar = createElement("Frame", innerFrame, {
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 0,
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    Position = UDim2.new(0, 0, 0, 0)
})

createElement("UICorner", titleBar, {CornerRadius = UDim.new(0, 10)})

local title = createElement("TextLabel", titleBar, {
    Size = UDim2.new(1, -160, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "Roblox Egor",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(230, 230, 255),
    TextXAlignment = Enum.TextXAlignment.Left
})

local function WButton(txt, offset, callback)
    local btn = createElement("TextButton", titleBar, {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, offset, 0, 3),
        BackgroundColor3 = Color3.fromRGB(60, 60, 80),
        BackgroundTransparency = 0.7,
        Text = txt,
        TextColor3 = Color3.fromRGB(230, 230, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false
    })

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(80, 100, 200)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.7, BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)

    createElement("UICorner", btn, {CornerRadius = UDim.new(0, 6)})
    return btn
end

WButton("X", -35, function()
    local function cleanupScript()
        if rgbConnection then
            rgbConnection:Disconnect()
            rgbConnection = nil
        end

        RunService:UnbindFromRenderStep("EgorRun")

        if Humanoid then
            Humanoid.WalkSpeed = defspeed
            for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(1)
            end
        end
        gui:Destroy()
    end
    cleanupScript()
end)

local toggle = createElement("TextButton", innerFrame, {
    Size = UDim2.new(1, -40, 0, 45),
    Position = UDim2.new(0, 20, -0.2, 90),
    BackgroundColor3 = Color3.fromRGB(80, 100, 200),
    BackgroundTransparency = 0.4,
    TextColor3 = Color3.fromRGB(240, 240, 255),
    Text = "OFF",
    TextSize = 16,
    Font = Enum.Font.GothamSemibold,
    AutoButtonColor = false
})

toggle.MouseEnter:Connect(function()
    TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(100, 120, 255)}):Play()
end)
toggle.MouseLeave:Connect(function()
    TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundTransparency = 0.4, BackgroundColor3 = Color3.fromRGB(80, 100, 200)}):Play()
end)

createElement("UICorner", toggle, {CornerRadius = UDim.new(0, 10)})

local credits = createElement("TextLabel", innerFrame, {
    Size = UDim2.new(1, -40, 0, 30),
    Position = UDim2.new(0, 110, 0.3, -37),
    BackgroundTransparency = 1,
    Text = "by n0mvi",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(180, 180, 220),
    TextXAlignment = Enum.TextXAlignment.Left
})

local function toggleEgorMode()
    egorMode = not egorMode
    if egorMode then
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)

        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = true end
        RunService:BindToRenderStep("EgorRun", Enum.RenderPriority.Character.Value + 1, function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local walkSpeed = hum.WalkSpeed
                local animationSpeed = 10
                for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(animationSpeed)
                end
            end
        end)
    else
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(80, 100, 200)

        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum then hum.WalkSpeed = defspeed end
        if hrp then hrp.Anchored = false end

        RunService:UnbindFromRenderStep("EgorRun")

        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(1)
            end
        end
    end
end

toggle.MouseButton1Click:Connect(toggleEgorMode)

local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

main.BackgroundTransparency = 1
innerFrame.BackgroundTransparency = 1
titleBar.BackgroundTransparency = 1
toggle.BackgroundTransparency = 1

TweenService:Create(main, TweenInfo.new(0.5), {BackgroundTransparency = 0.2}):Play()
TweenService:Create(innerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {BackgroundTransparency = 0.3}):Play()
TweenService:Create(titleBar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.2), {BackgroundTransparency = 0.8}):Play()
TweenService:Create(toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3), {BackgroundTransparency = 0.4}):Play()

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if egorMode then
        RunService:BindToRenderStep("EgorRun", Enum.RenderPriority.Character.Value + 1, function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local walkSpeed = hum.WalkSpeed
                local animationSpeed = 10
                for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(animationSpeed)
                end
            end
        end)
    end
end)

env.XORVEX_EGOR_CLEANUP = function()
    if env.XORVEX_ACTIVE["egor"] then
        for _, obj in pairs(env.XORVEX_ACTIVE["egor"]) do
            if typeof(obj) == "RBXScriptConnection" then
                obj:Disconnect()
            elseif typeof(obj) == "Instance" then
                obj:Destroy()
            end
        end
        env.XORVEX_ACTIVE["egor"] = {}
    end
    
    RunService:UnbindFromRenderStep("EgorRun")
    
    if egorMode then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = defspeed
        end
        egorMode = false
    end
end
