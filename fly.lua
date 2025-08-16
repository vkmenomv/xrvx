local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local env = getgenv()

local flyModule = {
    name = "fly",
    gui = nil,
    isOpen = false,
    api = env.API,
    flyEnabled = false,
    flySpeed = 50,
    isMinimized = false,
    bodyVelocity = nil,
    bodyGyro = nil,
    flyConnection = nil,
    inputFlags = {forward = false, back = false, left = false, right = false, up = false, down = false},
    forwardHold = 0,
    animations = {},
    tracks = {},
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
                Name = "FlyGui",
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                ResetOnSpawn = false
            }
        )

        local main =
            self:createElement(
            "Frame",
            gui,
            {
                Size = UDim2.new(0, 250, 0, 130),
                Position = UDim2.new(0.5, -125, 0.5, -75),
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
                Text = "FLY",
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
                Position = UDim2.new(0, 10, 0, 50),
                BackgroundColor3 = Color3.fromRGB(80, 100, 200),
                Text = "OFF",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", toggle, {CornerRadius = UDim.new(0, 6)})

        local speedSlider =
            self:createElement(
            "Frame",
            main,
            {
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 95),
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", speedSlider, {CornerRadius = UDim.new(0, 4)})

        local speedTrack =
            self:createElement(
            "Frame",
            speedSlider,
            {
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 0.5, -3),
                BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", speedTrack, {CornerRadius = UDim.new(0, 3)})

        local speedFill =
            self:createElement(
            "Frame",
            speedTrack,
            {
                Size = UDim2.new(self.flySpeed / 100, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", speedFill, {CornerRadius = UDim.new(0, 3)})

        self.gui = gui
        self.main = main
        self.toggle = toggle
        self.speedSlider = speedSlider
        self.speedTrack = speedTrack
        self.speedFill = speedFill
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton

        self:setupEvents()
        self.api:addToActive("fly_gui", gui)
    end,
    setupEvents = function(self)
        self.isDraggingSlider = false

        self.toggle.MouseButton1Click:Connect(
            function()
                self:toggleFly()
            end
        )

        self.toggle.MouseEnter:Connect(
            function()
                TweenService:Create(self.toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 120, 255)}):Play()
            end
        )

        self.toggle.MouseLeave:Connect(
            function()
                local color = self.flyEnabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 100, 200)
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

        self.speedSlider.InputBegan:Connect(
            function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    self.isDraggingSlider = true
                    local percentage =
                        math.clamp(
                        (input.Position.X - self.speedTrack.AbsolutePosition.X) / self.speedTrack.AbsoluteSize.X,
                        0,
                        1
                    )
                    self:updateSpeedSlider(percentage)
                end
            end
        )

        UserInputService.InputChanged:Connect(
            function(input)
                if self.isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percentage =
                        math.clamp(
                        (input.Position.X - self.speedTrack.AbsolutePosition.X) / self.speedTrack.AbsoluteSize.X,
                        0,
                        1
                    )
                    self:updateSpeedSlider(percentage)
                end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    self.isDraggingSlider = false
                end
            end
        )

        self:makeDraggable(self.main, self.titleBar)
        self:setupKeyboard()
    end,
    makeDraggable = function(self, frame, dragHandle)
        local dragging = false
        local dragStart = nil
        local startPos = nil

        dragHandle.InputBegan:Connect(
            function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.isDraggingSlider then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                end
            end
        )

        UserInputService.InputChanged:Connect(
            function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and not self.isDraggingSlider then
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
    setupKeyboard = function(self)
        UserInputService.InputBegan:Connect(
            function(input, gameProcessed)
                if gameProcessed or not self.flyEnabled then
                    return
                end

                if input.KeyCode == Enum.KeyCode.W then self.inputFlags.forward = true end
                if input.KeyCode == Enum.KeyCode.S then self.inputFlags.back = true end
                if input.KeyCode == Enum.KeyCode.A then self.inputFlags.left = true end
                if input.KeyCode == Enum.KeyCode.D then self.inputFlags.right = true end
                if input.KeyCode == Enum.KeyCode.E then self.inputFlags.up = true end
                if input.KeyCode == Enum.KeyCode.Q then self.inputFlags.down = true end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input, gameProcessed)
                if gameProcessed then
                    return
                end

                if input.KeyCode == Enum.KeyCode.W then self.inputFlags.forward = false end
                if input.KeyCode == Enum.KeyCode.S then self.inputFlags.back = false end
                if input.KeyCode == Enum.KeyCode.A then self.inputFlags.left = false end
                if input.KeyCode == Enum.KeyCode.D then self.inputFlags.right = false end
                if input.KeyCode == Enum.KeyCode.E then self.inputFlags.up = false end
                if input.KeyCode == Enum.KeyCode.Q then self.inputFlags.down = false end
            end
        )
    end,
    updateSpeedSlider = function(self, percentage)
        percentage = math.clamp(percentage, 0, 1)
        self.flySpeed = math.floor(10 + percentage * 90)
        self.speedFill.Size = UDim2.new(percentage, 0, 1, 0)
    end,
    newAnim = function(self, id)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. id
        return anim
    end,
    stopAll = function(self)
        for _, track in pairs(self.tracks) do
            track:Stop()
        end
    end,
    updateFlyMovement = function(self, dt)
        if not self.bodyVelocity or not self.bodyGyro or not LocalPlayer.Character then
            return
        end

        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return
        end

        local camera = Workspace.CurrentCamera
        if not self.inputFlags.forward then self.forwardHold = 0 end

        local dir = Vector3.zero
        local camCF = camera.CFrame

        if self.inputFlags.forward then dir += camCF.LookVector end
        if self.inputFlags.back then dir -= camCF.LookVector end
        if self.inputFlags.left then dir -= camCF.RightVector end
        if self.inputFlags.right then dir += camCF.RightVector end
        if self.inputFlags.up then dir += Vector3.yAxis end
        if self.inputFlags.down then dir -= Vector3.yAxis end

        if dir.Magnitude > 0 then dir = dir.Unit end

        local currentSpeed = self.flySpeed
        
        -- Animation and speed logic
        if self.inputFlags.up then
            if not self.tracks.up.IsPlaying then self:stopAll(); self.tracks.up:Play() end
        elseif self.inputFlags.down then
            if not self.tracks.down.IsPlaying then self:stopAll(); self.tracks.down:Play() end
        elseif self.inputFlags.left then
            if not self.tracks.left1.IsPlaying then
                self:stopAll()
                self.tracks.left1:Play(); self.tracks.left1.TimePosition = 2.0; self.tracks.left1:AdjustSpeed(0)
                self.tracks.left2:Play(); self.tracks.left2.TimePosition = 0.5; self.tracks.left2:AdjustSpeed(0)
            end
        elseif self.inputFlags.right then
            if not self.tracks.right1.IsPlaying then
                self:stopAll()
                self.tracks.right1:Play(); self.tracks.right1.TimePosition = 1.1; self.tracks.right1:AdjustSpeed(0)
                self.tracks.right2:Play(); self.tracks.right2.TimePosition = 0.5; self.tracks.right2:AdjustSpeed(0)
            end
        elseif self.inputFlags.back then
            if not self.tracks.back1.IsPlaying then
                self:stopAll()
                self.tracks.back1:Play(); self.tracks.back1.TimePosition = 5.3; self.tracks.back1:AdjustSpeed(0)
                self.tracks.back2:Play(); self.tracks.back2:AdjustSpeed(0)
                self.tracks.back3:Play(); self.tracks.back3.TimePosition = 0.8; self.tracks.back3:AdjustSpeed(0)
                self.tracks.back4:Play(); self.tracks.back4.TimePosition = 1; self.tracks.back4:AdjustSpeed(0)
            end
        elseif self.inputFlags.forward then
            self.forwardHold += dt
            if self.forwardHold >= 3 then
                if not self.tracks.flyFast.IsPlaying then
                    self:stopAll()
                    currentSpeed = self.flySpeed * 1.3
                    self.tracks.flyFast:Play(); self.tracks.flyFast:AdjustSpeed(0.05)
                end
            else
                if not self.tracks.flyLow1.IsPlaying then
                    self:stopAll()
                    currentSpeed = self.flySpeed
                    self.tracks.flyLow1:Play()
                    self.tracks.flyLow2:Play()
                end
            end
        else
            if not self.tracks.idle1.IsPlaying then
                self:stopAll()
                self.tracks.idle1:Play(); self.tracks.idle1:AdjustSpeed(0)
            end
        end

        self.bodyVelocity.Velocity = dir * currentSpeed
        self.bodyGyro.CFrame = camCF
    end,
    startFly = function(self)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid then
            return
        end

        -- Animation Loading
        self.animations = {
            forward = self:newAnim(90872539),
            up = self:newAnim(90872539),
            right1 = self:newAnim(136801964),
            right2 = self:newAnim(142495255),
            left1 = self:newAnim(136801964),
            left2 = self:newAnim(142495255),
            flyLow1 = self:newAnim(97169019),
            flyLow2 = self:newAnim(282574440),
            flyFast = self:newAnim(282574440),
            back1 = self:newAnim(136801964),
            back2 = self:newAnim(106772613),
            back3 = self:newAnim(42070810),
            back4 = self:newAnim(214744412),
            down = self:newAnim(233322916),
            idle1 = self:newAnim(97171309)
        }

        for name, anim in pairs(self.animations) do
            self.tracks[name] = humanoid:LoadAnimation(anim)
        end

        local success =
            pcall(
            function()
                self.bodyVelocity =
                    self:createElement(
                    "BodyVelocity",
                    humanoidRootPart,
                    {
                        MaxForce = Vector3.new(1e5, 1e5, 1e5),
                        Velocity = Vector3.new(0, 0, 0)
                    }
                )

                self.bodyGyro =
                    self:createElement(
                    "BodyGyro",
                    humanoidRootPart,
                    {
                        MaxTorque = Vector3.new(1e5, 1e5, 1e5),
                        CFrame = humanoidRootPart.CFrame
                    }
                )
                
                humanoid.PlatformStand = true

                self.flyConnection =
                    RunService.RenderStepped:Connect(
                    function(dt)
                        self:updateFlyMovement(dt)
                    end
                )
            end
        )

        if success and self.bodyVelocity then
            self.flyEnabled = true
            self.toggle.Text = "ON"
            self.toggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        end
    end,
    stopFly = function(self)
        self:stopAll()

        if self.bodyVelocity then
            pcall(
                function()
                    self.bodyVelocity:Destroy()
                end
            )
            self.bodyVelocity = nil
        end

        if self.bodyGyro then
            pcall(
                function()
                    self.bodyGyro:Destroy()
                end
            )
            self.bodyGyro = nil
        end

        if self.flyConnection then
            pcall(
                function()
                    self.flyConnection:Disconnect()
                end
            )
            self.flyConnection = nil
        end

        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            pcall(
                function()
                    humanoid.PlatformStand = false
                end
            )
        end
        
        self.flyEnabled = false
        self.toggle.Text = "OFF"
        self.toggle.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
        self.inputFlags = {forward = false, back = false, left = false, right = false, up = false, down = false}
    end,
    toggleFly = function(self)
        if self.flyEnabled then
            self:stopFly()
        else
            self:startFly()
        end
    end,
    addCorner = function(self, element, radius)
        self:createElement("UICorner", element, {CornerRadius = UDim.new(0, radius or 10)})
    end,
    addBorder = function(self, element, color, thickness, transparency)
        self:createElement(
            "UIStroke",
            element,
            {
                Color = color or Color3.fromRGB(100, 150, 255),
                Thickness = thickness or 2,
                Transparency = transparency or 0.3
            }
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
                self:addCorner(self.squareIcon, 12)
                self:addBorder(self.squareIcon, Color3.fromRGB(100, 150, 255), 2, 0.3)
                local iconLabel = Instance.new("TextLabel")
                iconLabel.Size = UDim2.new(1, 0, 1, 0)
                iconLabel.BackgroundTransparency = 1
                iconLabel.Text = "F"
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
                            if not self.isDraggingSlider then
                                dragging = true
                                dragStart = input.Position
                                startPos = self.squareIcon.Position
                            end
                        end
                    end
                )

                UserInputService.InputChanged:Connect(
                    function(input)
                        if
                            dragging and input.UserInputType == Enum.UserInputType.MouseMovement and
                                not self.isDraggingSlider
                         then
                            local delta = input.Position - dragStart
                            self.squareIcon.Position =
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

                local clickConnection
                clickConnection =
                    self.squareIcon.InputBegan:Connect(
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
            self.speedSlider.Visible = false
            self.minimizeButton.Visible = false
            self.titleBar.Visible = false
            self.squareIcon.Position = self.main.Position
            self.squareIcon.Size = self.main.Size
            self.squareIcon.Visible = true

            local mainTween =
                TweenService:Create(
                self.main,
                TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(0, 50, 0, 50)
                }
            )

            local squareTween =
                TweenService:Create(
                self.squareIcon,
                TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(0, 50, 0, 50)
                }
            )

            mainTween:Play()
            squareTween:Play()

            task.spawn(
                function()
                    task.wait(0.4)
                    self.main.Visible = false
                end
            )
        else
            if self.squareIcon then
                self.main.Position = self.squareIcon.Position
                self.main.Size = UDim2.new(0, 50, 0, 50)
                self.squareIcon.Visible = false
            end

            self.main.Visible = true
            local expandTween =
                TweenService:Create(
                self.main,
                TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(0, 250, 0, 130)
                }
            )
            expandTween:Play()

            expandTween.Completed:Connect(
                function()
                    self.toggle.Visible = true
                    self.speedSlider.Visible = true
                    self.minimizeButton.Visible = true
                    self.titleBar.Visible = true
                end
            )
        end
    end,
    closeGUI = function(self)
        if self.flyEnabled then
            self:stopFly()
        end
        if self.gui then
            self.gui:Destroy()
            self.gui = nil
        end
    end,
    execute = function(self, args)
        if not self.gui then
            self:createGUI()
        else
            self:toggleFly()
        end
    end,
    onUnload = function(self)
        if self.flyEnabled then
            self:stopFly()
        end
        if self.gui then
            self.gui:Destroy()
        end
    end
}

flyModule:createGUI()
return flyModule
