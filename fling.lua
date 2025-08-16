local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local env = getgenv()

local flingModule = {
    name = "fling",
    gui = nil,
    isOpen = false,
    api = env.API,
    flingEnabled = false,
    isMinimized = false,
    flingConnection = nil,
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
                Name = "FlingGui",
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                ResetOnSpawn = false
            }
        )

        local main =
            self:createElement(
            "Frame",
            gui,
            {
                Size = UDim2.new(0, 250, 0, 100),
                Position = UDim2.new(0.5, -125, 0.5, -50),
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
                Text = "FLING",
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left
            }
        )

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

        self.gui = gui
        self.main = main
        self.toggle = toggle
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton

        self:setupEvents()
        self.api:addToActive("fling_gui", gui)
    end,
    setupEvents = function(self)
        self.toggle.MouseButton1Click:Connect(
            function()
                self:toggleFling()
            end
        )

        self.toggle.MouseEnter:Connect(
            function()
                TweenService:Create(self.toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 120, 255)}):Play(

                )
            end
        )

        self.toggle.MouseLeave:Connect(
            function()
                local color = self.flingEnabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 100, 200)
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

        self.closeButton.MouseEnter:Connect(
            function()
                TweenService:Create(
                    self.closeButton,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(255, 130, 150)}
                ):Play()
            end
        )

        self.closeButton.MouseLeave:Connect(
            function()
                TweenService:Create(
                    self.closeButton,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(255, 100, 120)}
                ):Play()
            end
        )

        self.minimizeButton.MouseEnter:Connect(
            function()
                TweenService:Create(
                    self.minimizeButton,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(130, 170, 255)}
                ):Play()
            end
        )

        self.minimizeButton.MouseLeave:Connect(
            function()
                TweenService:Create(
                    self.minimizeButton,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = Color3.fromRGB(100, 150, 255)}
                ):Play()
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
    startFling = function(self)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        self.flingEnabled = true
        self.toggle.Text = "ON"
        self.toggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)

        local lp = Players.LocalPlayer
        local movel = 0.1

        local humanoid = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end

        self.flingConnection =
            RunService.Heartbeat:Connect(
            function()
                if not self.flingEnabled then
                    return
                end

                local c = lp.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                local humanoid = c and c:FindFirstChild("Humanoid")

                if humanoid then
                    humanoid.Health = math.huge
                end

                if hrp then
                    for _, obj in pairs(hrp:GetChildren()) do
                        if
                            obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyPosition") or
                                obj:IsA("BodyThrust")
                         then
                            if obj.Name ~= "FlingVelocity" then
                                obj:Destroy()
                            end
                        end
                    end

                    local vel = hrp.Velocity
                    hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                    RunService.RenderStepped:Wait()
                    hrp.Velocity = vel
                    RunService.Stepped:Wait()
                    hrp.Velocity = vel + Vector3.new(0, movel, 0)
                    movel = -movel
                end
            end
        )
    end,
    stopFling = function(self)
        if self.flingConnection then
            self.flingConnection:Disconnect()
            self.flingConnection = nil
        end

        self.flingEnabled = false
        self.toggle.Text = "OFF"
        self.toggle.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
    end,
    toggleFling = function(self)
        if self.flingEnabled then
            self:stopFling()
        else
            self:startFling()
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
                    Size = UDim2.new(0, 250, 0, 100)
                }
            )
            expandTween:Play()

            expandTween.Completed:Connect(
                function()
                    self.toggle.Visible = true
                    self.minimizeButton.Visible = true
                    self.titleBar.Visible = true
                end
            )
        end
    end,
    closeGUI = function(self)
        if self.flingEnabled then
            self:stopFling()
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
            self:toggleFling()
        end
    end,
    onUnload = function(self)
        if self.flingEnabled then
            self:stopFling()
        end
        if self.gui then
            self.gui:Destroy()
        end
    end
}

flingModule:createGUI()
return flingModule
