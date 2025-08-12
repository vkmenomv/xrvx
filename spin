local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local env = getgenv()

local spinModule = {
    name = "spin",
    gui = nil,
    isOpen = false,
    api = env.API,
    
    spinEnabled = false,
    spinSpeed = 50,
    isMinimized = false,
    isDraggingSlider = false,
    humanoidRootPart = nil,
    bodyAngularVelocity = nil,
    
    createElement = function(self, className, parent, properties)
        local element = Instance.new(className, parent)
        for property, value in pairs(properties) do
            element[property] = value
        end
        return element
    end,
    
    createGUI = function(self)
        if self.gui then self.gui:Destroy() end
        
        local gui = self:createElement("ScreenGui", game:GetService("CoreGui"), {
            Name = "SpinGui",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false
        })
        
        local main = self:createElement("Frame", gui, {
            Size = UDim2.new(0, 250, 0, 130),
            Position = UDim2.new(0.5, -125, 0.5, -75),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BorderSizePixel = 0
        })
        
        self:createElement("UICorner", main, {CornerRadius = UDim.new(0, 12)})
        
        local stroke = self:createElement("UIStroke", main, {
            Color = Color3.fromRGB(100, 150, 255),
            Thickness = 2,
            Transparency = 0.3
        })
        
        local titleBar = self:createElement("Frame", main, {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Color3.fromRGB(20, 20, 30),
            BorderSizePixel = 0
        })
        
        self:createElement("UICorner", titleBar, {CornerRadius = UDim.new(0, 12)})
        
        local title = self:createElement("TextLabel", titleBar, {
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = "SPIN",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local minimizeButton = self:createElement("TextButton", titleBar, {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -70, 0, 5),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            Text = "âˆ’",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0
        })
        
        self:createElement("UICorner", minimizeButton, {CornerRadius = UDim.new(0, 6)})
        
        local closeButton = self:createElement("TextButton", titleBar, {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -35, 0, 5),
            BackgroundColor3 = Color3.fromRGB(255, 100, 120),
            Text = "Ã—",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0
        })
        
        self:createElement("UICorner", closeButton, {CornerRadius = UDim.new(0, 6)})
        
        local toggle = self:createElement("TextButton", main, {
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 0, 50),
            BackgroundColor3 = Color3.fromRGB(80, 100, 200),
            Text = "OFF",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0
        })
        
        self:createElement("UICorner", toggle, {CornerRadius = UDim.new(0, 6)})
        
        local speedSlider = self:createElement("Frame", main, {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 95),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BorderSizePixel = 0
        })
        
        self:createElement("UICorner", speedSlider, {CornerRadius = UDim.new(0, 4)})
        
        local speedTrack = self:createElement("Frame", speedSlider, {
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 0.5, -3),
            BackgroundColor3 = Color3.fromRGB(60, 60, 70),
            BorderSizePixel = 0
        })
        
        self:createElement("UICorner", speedTrack, {CornerRadius = UDim.new(0, 3)})
        
        local speedFill = self:createElement("Frame", speedTrack, {
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            BorderSizePixel = 0
        })
        
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
        self.api:addToActive("spin_gui", gui)
    end,
    
    setupEvents = function(self)
        self.toggle.MouseButton1Click:Connect(function()
            self:toggleSpin()
        end)
        
        self.toggle.MouseEnter:Connect(function()
            TweenService:Create(self.toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 120, 255)}):Play()
        end)
        
        self.toggle.MouseLeave:Connect(function()
            local color = self.spinEnabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 100, 200)
            TweenService:Create(self.toggle, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        end)
        
        self.closeButton.MouseButton1Click:Connect(function()
            self:closeGUI()
        end)
        
        self.minimizeButton.MouseButton1Click:Connect(function()
            self:minimizeToggle()
        end)
        
        self.closeButton.MouseEnter:Connect(function()
            TweenService:Create(self.closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 130, 150)}):Play()
        end)
        
        self.closeButton.MouseLeave:Connect(function()
            TweenService:Create(self.closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 120)}):Play()
        end)
        
        self.minimizeButton.MouseEnter:Connect(function()
            TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 170, 255)}):Play()
        end)
        
        self.minimizeButton.MouseLeave:Connect(function()
            TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 150, 255)}):Play()
        end)
        
        self.speedSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.isDraggingSlider = true
                local percentage = math.clamp((input.Position.X - self.speedTrack.AbsolutePosition.X) / self.speedTrack.AbsoluteSize.X, 0, 1)
                self:updateSpeedSlider(percentage)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if self.isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percentage = math.clamp((input.Position.X - self.speedTrack.AbsolutePosition.X) / self.speedTrack.AbsoluteSize.X, 0, 1)
                self:updateSpeedSlider(percentage)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.isDraggingSlider = false
            end
        end)
        
        self:makeDraggable(self.main, self.titleBar)
    end,
    
    makeDraggable = function(self, frame, dragHandle)
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.isDraggingSlider then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and not self.isDraggingSlider then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end,
    
    updateSpeedSlider = function(self, percentage)
        percentage = math.clamp(percentage, 0, 1)
        self.spinSpeed = math.floor(1 + percentage * 99)
        self.speedFill.Size = UDim2.new(percentage, 0, 1, 0)
        
        if self.bodyAngularVelocity then
            self.bodyAngularVelocity.AngularVelocity = Vector3.new(0, self.spinSpeed, 0)
        end
    end,
    
    startSpin = function(self)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        self.humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
        
        self.bodyAngularVelocity = self:createElement("BodyAngularVelocity", self.humanoidRootPart, {
            MaxTorque = Vector3.new(0, math.huge, 0),
            AngularVelocity = Vector3.new(0, self.spinSpeed, 0)
        })
        
        self.spinEnabled = true
        self.toggle.Text = "ON"
        self.toggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
    end,
    
    stopSpin = function(self)
        if self.bodyAngularVelocity then
            self.bodyAngularVelocity:Destroy()
            self.bodyAngularVelocity = nil
        end
        
        self.spinEnabled = false
        self.toggle.Text = "OFF"
        self.toggle.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
    end,
    
    toggleSpin = function(self)
        if self.spinEnabled then
            self:stopSpin()
        else
            self:startSpin()
        end
    end,

    addCorner = function(self, element, radius)
        self:createElement("UICorner", element, {CornerRadius = UDim.new(0, radius or 10)})
    end,

    addBorder = function(self, element, color, thickness, transparency)
        self:createElement("UIStroke", element, {Color = color or Color3.fromRGB(100, 150, 255), Thickness = thickness or 2, Transparency = transparency or 0.3})
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
                iconLabel.Text = "S"
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
                
                self.squareIcon.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if not self.isDraggingSlider then
                            dragging = true
                            dragStart = input.Position
                            startPos = self.squareIcon.Position
                        end
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and not self.isDraggingSlider then
                        local delta = input.Position - dragStart
                        self.squareIcon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                local clickConnection
                clickConnection = self.squareIcon.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
                        task.wait(0.1)
                        if not dragging then
                            self:minimizeToggle()
                        end
                    end
                end)
            end

            self.toggle.Visible = false
            self.speedSlider.Visible = false
            self.titleBar.Visible = false
            self.minimizeButton.Visible = false

            self.squareIcon.Position = self.main.Position
            self.squareIcon.Size = self.main.Size
            self.squareIcon.Visible = true
            local mainTween = TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 50)
            })
            
            local squareTween = TweenService:Create(self.squareIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 50)
            })
            
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
            local expandTween = TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 250, 0, 130)
            })
            expandTween:Play()
            
            expandTween.Completed:Connect(function()
                self.toggle.Visible = true
                self.speedSlider.Visible = true
                self.minimizeButton.Visible = true
                self.titleBar.Visible = true
            end)
        end
    end,
    
    closeGUI = function(self)
        if self.spinEnabled then
            self:stopSpin()
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
            self:toggleSpin()
        end
    end,
    
    onUnload = function(self)
        if self.spinEnabled then
            self:stopSpin()
        end
        if self.gui then
            self.gui:Destroy()
        end
    end
}

spinModule:createGUI()
return spinModule
