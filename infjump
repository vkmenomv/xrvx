local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local env = getgenv()
local infJumpModule = {
    name = "infjump",
    gui = nil,
    isOpen = false,
    api = env.API,
    infJumpEnabled = false,
    isMinimized = false,
    jumpPower = 40,
    lastJumpTime = 0,
    createElement = function(self, className, parent, properties)
        local element = Instance.new(className, parent)
        for property, value in pairs(properties) do
            element[property] = value
        end
        return element
    end,
    createGUI = function(self)
        if self.gui then
            self.gui:Destroy()
        end
        local gui =
            self:createElement(
            "ScreenGui",
            game:GetService("CoreGui"),
            {
                Name = "InfiniteJumpGui",
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                ResetOnSpawn = false
            }
        )
        local main =
            self:createElement(
            "Frame",
            gui,
            {
                Size = UDim2.new(0, 250, 0, 85),
                Position = UDim2.new(0.5, -125, 0.5, -42),
                BackgroundColor3 = Color3.fromRGB(15, 15, 20),
                BorderSizePixel = 0
            }
        )
        self:createElement("UICorner", main, {CornerRadius = UDim.new(0, 12)})
        local stroke =
            self:createElement(
            "UIStroke",
            main,
            {
                Color = Color3.fromRGB(100, 150, 255),
                Thickness = 2,
                Transparency = 0.3
            }
        )
        local titleBar =
            self:createElement(
            "Frame",
            main,
            {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Color3.fromRGB(20, 20, 30),
                BorderSizePixel = 0
            }
        )
        self:createElement("UICorner", titleBar, {CornerRadius = UDim.new(0, 12)})
        local title =
            self:createElement(
            "TextLabel",
            titleBar,
            {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = "INFINITE JUMP",
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left
            }
        )
        local minimizeButton =
            self:createElement(
            "TextButton",
            titleBar,
            {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -70, 0, 5),
                BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                Text = "−",
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0
            }
        )
        self:createElement("UICorner", minimizeButton, {CornerRadius = UDim.new(0, 6)})
        local closeButton =
            self:createElement(
            "TextButton",
            titleBar,
            {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -35, 0, 5),
                BackgroundColor3 = Color3.fromRGB(255, 100, 120),
                Text = "×",
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0
            }
        )
        self:createElement("UICorner", closeButton, {CornerRadius = UDim.new(0, 6)})
        local toggle =
            self:createElement(
            "TextButton",
            main,
            {
                Size = UDim2.new(1, -20, 0, 35),
                Position = UDim2.new(0, 10, 0, 45),
                BackgroundColor3 = Color3.fromRGB(80, 100, 200),
                Text = "DISABLED",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                BorderSizePixel = 0
            }
        )
        self:createElement("UICorner", toggle, {CornerRadius = UDim.new(0, 6)})
        self.gui = gui
        self.main = main
        self.toggle = toggle
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton
        self:setupEvents()
        self.api:addToActive("infjump_gui", gui)
    end,
    setupEvents = function(self)
        self.toggle.MouseButton1Click:Connect(
            function()
                self:toggleInfJump()
            end
        )
        self.toggle.MouseEnter:Connect(
            function()
                TweenService:Create(self.toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 120, 255)}):Play()
            end
        )
        self.toggle.MouseLeave:Connect(
            function()
                local color = self.infJumpEnabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 100, 200)
                TweenService:Create(self.toggle, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
            end
        )
        self.closeButton.MouseButton1Click:Connect(
            function()
                self:closeGUI()
            end
        )
        self.minimizeButton.MouseButton1Click:Connect(
            function()
                self:minimizeToggle()
            end
        )
        self:makeDraggable(self.main, self.titleBar)
    end,
    makeDraggable = function(self, frame, dragHandle)
        local dragging = false
        local dragStart = nil
        local startPos = nil
        dragHandle.InputBegan:Connect(
            function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                end
            end
        )
        UserInputService.InputChanged:Connect(
            function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input.Position - dragStart
                    frame.Position =
                        UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                end
            end
        )
        UserInputService.InputEnded:Connect(
            function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end
        )
    end,
    minimizeToggle = function(self)
        self.isMinimized = not self.isMinimized
        if self.isMinimized then
            if not self.squareIcon then
                self.squareIcon = Instance.new("Frame")
                self.squareIcon.Size = UDim2.new(0, 50, 0, 50)
                self.squareIcon.Position = self.main.Position
                self.squareIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
                self.squareIcon.BorderSizePixel = 0
                self.squareIcon.ZIndex = 100
                self.squareIcon.Visible = false
                self.squareIcon.Parent = self.main.Parent
                self:createElement("UICorner", self.squareIcon, {CornerRadius = UDim.new(0, 12)})
                self:createElement("UIStroke", self.squareIcon, {Color = Color3.fromRGB(100, 150, 255), Thickness = 2, Transparency = 0.3})
                local iconLabel = Instance.new("TextLabel")
                iconLabel.Size = UDim2.new(1, 0, 1, 0)
                iconLabel.BackgroundTransparency = 1
                iconLabel.Text = "IJ"
                iconLabel.Font = Enum.Font.GothamBold
                iconLabel.TextSize = 20
                iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                iconLabel.TextXAlignment = Enum.TextXAlignment.Center
                iconLabel.TextYAlignment = Enum.TextYAlignment.Center
                iconLabel.ZIndex = 101
                iconLabel.Parent = self.squareIcon
                local dragging = false
                local dragStart = nil
                local startPos = nil
                self.squareIcon.InputBegan:Connect(
                    function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            dragStart = input.Position
                            startPos = self.squareIcon.Position
                        end
                    end
                )
                UserInputService.InputChanged:Connect(
                    function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local delta = input.Position - dragStart
                            self.squareIcon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                        end
                    end
                )
                UserInputService.InputEnded:Connect(
                    function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end
                )
                local clickConnection
                clickConnection = self.squareIcon.InputBegan:Connect(
                    function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
                            task.wait(0.1)
                            if not dragging then
                                self:minimizeToggle()
                            end
                        end
                    end
                )
            end
            self.toggle.Visible = false
            self.minimizeButton.Visible = false
            self.titleBar.Visible = false
            self.squareIcon.Position = self.main.Position
            self.squareIcon.Size = self.main.Size
            self.squareIcon.Visible = true
            local mainTween = TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)})
            local squareTween = TweenService:Create(self.squareIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)})
            mainTween:Play()
            squareTween:Play()
            task.spawn(function()
                task.wait(0.4)
                self.main.Visible = false
            end)
        else
            if self.squareIcon then
                self.main.Position = self.squareIcon.Position
                self.main.Size = UDim2.new(0, 50, 0, 50)
                self.squareIcon.Visible = false
            end
            self.main.Visible = true
            local expandTween = TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 250, 0, 85)})
            expandTween:Play()
            expandTween.Completed:Connect(function()
                self.toggle.Visible = true
                self.minimizeButton.Visible = true
                self.titleBar.Visible = true
            end)
        end
    end,
    closeGUI = function(self)
        if self.infJumpEnabled then
            self:stopInfJump()
        end
        if self.gui then
            self.gui:Destroy()
            self.gui = nil
        end
    end,
    startInfJump = function(self)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid then
            return
        end
        humanoid.JumpPower = 0
        humanoid.UseJumpPower = true
        self.jumpInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and (input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch) then
                if os.clock() - self.lastJumpTime > 0.1 then
                    self.lastJumpTime = os.clock()
                    local jumpVelocity = Instance.new("BodyVelocity")
                    jumpVelocity.MaxForce = Vector3.new(0, math.huge, 0)
                    jumpVelocity.Velocity = Vector3.new(0, self.jumpPower, 0)
                    jumpVelocity.Parent = humanoidRootPart
                    game:GetService("Debris"):AddItem(jumpVelocity, 0.1)
                end
            end
        end)
        self.infJumpEnabled = true
        self.toggle.Text = "ENABLED"
        self.toggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
    end,
    stopInfJump = function(self)
        if self.jumpInputConnection then
            pcall(function()
                self.jumpInputConnection:Disconnect()
            end)
            self.jumpInputConnection = nil
        end
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.JumpPower = 50
            end)
        end
        self.infJumpEnabled = false
        self.toggle.Text = "DISABLED"
        self.toggle.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
    end,
    toggleInfJump = function(self)
        if self.infJumpEnabled then
            self:stopInfJump()
        else
            self:startInfJump()
        end
    end,
    execute = function(self, args)
        if not self.gui then
            self:createGUI()
        else
            self:toggleInfJump()
        end
    end,
    onUnload = function(self)
        if self.infJumpEnabled then
            self:stopInfJump()
        end
        if self.gui then
            self.gui:Destroy()
        end
    end
}
infJumpModule:createGUI()
return infJumpModule
