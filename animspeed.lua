local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local env = getgenv()

local AnimSpeedModule = {
    name = "AnimSpeed",
    gui = nil,
    isOpen = false,
    api = env.API,
    isMinimized = false,
    
    currentSpeed = 1,
    
    animatorConnection = nil,
    heartbeatConnection = nil,

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
                Name = "AnimSpeedGui",
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                ResetOnSpawn = false
            }
        )

        local main =
            self:createElement(
            "Frame",
            gui,
            {
                Size = UDim2.new(0, 250, 0, 115),
                Position = UDim2.new(0.5, -125, 0.5, -57),
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
                Text = "ANIMATION SPEED",
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

        local speedLabel =
            self:createElement(
            "TextLabel",
            main,
            {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 45),
                BackgroundTransparency = 1,
                Text = "Speed: 1.00",
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left
            }
        )

        local sliderBackground =
            self:createElement(
            "Frame",
            main,
            {
                Size = UDim2.new(1, -20, 0, 10),
                Position = UDim2.new(0, 10, 0, 75),
                BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", sliderBackground, {CornerRadius = UDim.new(0, 5)})

        local sliderThumb =
            self:createElement(
            "TextButton",
            sliderBackground,
            {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0.5, -10, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                Text = "",
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", sliderThumb, {CornerRadius = UDim.new(0, 10)})

        self.gui = gui
        self.main = main
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton
        self.speedLabel = speedLabel
        self.sliderBackground = sliderBackground
        self.sliderThumb = sliderThumb

        self:setupEvents()
        self:startAnimSpeedControl()
        self.api:addToActive("animspeed_gui", gui)
    end,

    setupEvents = function(self)
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
        self:setupSlider()
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
                iconLabel.Text = "AS"
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

            self.main.Visible = false
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
            local expandTween = TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 250, 0, 115)})
            expandTween:Play()

            expandTween.Completed:Connect(function()
                self.speedLabel.Visible = true
                self.sliderBackground.Visible = true
                self.titleBar.Visible = true
            end)
        end
    end,

    closeGUI = function(self)
        self:stopAnimSpeedControl()
        if self.gui then
            self.gui:Destroy()
            self.gui = nil
        end
    end,

    setupSlider = function(self)
        local dragging = false
        local slider = self.sliderBackground
        local thumb = self.sliderThumb

        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local relativePosition = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                if relativePosition >= 0 and relativePosition <= 1 then
                    dragging = true
                    local newX = math.clamp(relativePosition, 0, 1)
                    thumb.Position = UDim2.new(newX, -thumb.Size.X.Offset / 2, 0.5, -thumb.Size.Y.Offset / 2)
                    local speed = newX * 4.9 + 0.1
                    self.currentSpeed = math.round(speed * 100) / 100
                    self.speedLabel.Text = string.format("Speed: %.2f", self.currentSpeed)
                end
            end
        end

        local function onInputChanged(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relativePosition = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                local newX = math.clamp(relativePosition, 0, 1)
                thumb.Position = UDim2.new(newX, -thumb.Size.X.Offset / 2, 0.5, -thumb.Size.Y.Offset / 2)
                local speed = newX * 4.9 + 0.1
                self.currentSpeed = math.round(speed * 100) / 100
                self.speedLabel.Text = string.format("Speed: %.2f", self.currentSpeed)
            end
        end

        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end

        slider.InputBegan:Connect(onInputBegan)
        UserInputService.InputChanged:Connect(onInputChanged)
        UserInputService.InputEnded:Connect(onInputEnded)
    end,

    updateAnimSpeed = function(self, speed)
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then return end

        for _, animTrack in pairs(animator:GetPlayingAnimationTracks()) do
            animTrack:AdjustSpeed(speed)
        end
    end,

    startAnimSpeedControl = function(self)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        self.heartbeatConnection = RunService.Heartbeat:Connect(function()
            if not self.gui then return end
            
            -- If the character is not moving, reset animation speed to 1.0
            if humanoid.MoveDirection.Magnitude == 0 then
                self:updateAnimSpeed(1.0)
            else
                -- Otherwise, apply the slider's speed
                self:updateAnimSpeed(self.currentSpeed)
            end
        end)
    end,

    stopAnimSpeedControl = function(self)
        if self.heartbeatConnection then
            pcall(function() self.heartbeatConnection:Disconnect() end)
            self.heartbeatConnection = nil
        end

        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChild("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not animator then return end

        for _, animTrack in pairs(animator:GetPlayingAnimationTracks()) do
            animTrack:AdjustSpeed(1)
        end
    end,

    execute = function(self, args)
        if not self.gui then
            self:createGUI()
        end
    end,

    onUnload = function(self)
        self:stopAnimSpeedControl()
        if self.gui then
            self.gui:Destroy()
        end
    end
}

AnimSpeedModule:createGUI()
return AnimSpeedModule
