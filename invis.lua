local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local env = getgenv()

local invModule = {
    name = "inv",
    gui = nil,
    isOpen = false,
    api = env.API,
    
    invis_on = false,
    isMinimized = false,
    savedPosition = nil,
    currentSeat = nil,
    
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
            Name = "InvisibleGui",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false
        })
        
        local main = self:createElement("Frame", gui, {
            Size = UDim2.new(0, 250, 0, 100),
            Position = UDim2.new(0.5, -125, 0.5, -50),
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
            Text = "INVISIBLE",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local minimizeButton = self:createElement("TextButton", titleBar, {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -70, 0, 5),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            Text = "−",
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
            Text = "×",
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
        
        self.gui = gui
        self.main = main
        self.toggle = toggle
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton
        
        self:setupEvents()
        self.api:addToActive("inv_gui", gui)
    end,
    
    setupEvents = function(self)
        self.toggle.MouseButton1Click:Connect(function()
            self:toggleInvisibility()
        end)
        
        self.toggle.MouseEnter:Connect(function()
            TweenService:Create(self.toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 120, 255)}):Play()
        end)
        
        self.toggle.MouseLeave:Connect(function()
            local color = self.invis_on and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 100, 200)
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
        
        self:makeDraggable(self.main, self.titleBar)
        self:setupKeyboard()
    end,
    
    makeDraggable = function(self, frame, dragHandle)
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
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
    
    setupKeyboard = function(self)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed then
                if input.KeyCode == Enum.KeyCode.X then
                    self:toggleInvisibility()
                end
            end
        end)
    end,
    
    cleanupSeat = function(self)
        if self.currentSeat and self.currentSeat.Parent then
            self.currentSeat:Destroy()
        end
        self.currentSeat = nil
        
        local existingSeat = workspace:FindFirstChild('invischair')
        if existingSeat then
            existingSeat:Destroy()
        end
    end,
    
    findExistingSeat = function(self)
        return workspace:FindFirstChild('invischair')
    end,
    
    setTransparency = function(self, character, transparency, duration)
        if not character then return end
        
        duration = duration or 0
        
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if duration > 0 then
                    local tween = TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Transparency = transparency
                    })
                    tween:Play()
                else
                    part.Transparency = transparency
                end
            elseif part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then
                    if duration > 0 then
                        local tween = TweenService:Create(handle, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Transparency = transparency
                        })
                        tween:Play()
                    else
                        handle.Transparency = transparency
                    end
                end
            end
        end
    end,
    
    toggleInvisibility = function(self)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        self.invis_on = not self.invis_on
        
        if self.invis_on then
            self.savedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            
            self.toggle.Text = "ON"
            self.toggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
            
            local existingSeat = self:findExistingSeat()
            if existingSeat then
                existingSeat:Destroy()
                wait(0.1)
            end
            
            LocalPlayer.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            wait(0.15)
            
            self.currentSeat = Instance.new('Seat', game.Workspace)
            self.currentSeat.Anchored = false
            self.currentSeat.CanCollide = false
            self.currentSeat.Name = 'invischair'
            self.currentSeat.Transparency = 1
            self.currentSeat.Position = Vector3.new(-25.95, 84, 3537.55)
            
            local Weld = Instance.new("Weld", self.currentSeat)
            Weld.Part0 = self.currentSeat
            Weld.Part1 = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character.UpperTorso
            
            wait(0.1)
            
            if self.savedPosition then
                self.currentSeat.CFrame = self.savedPosition
            end
            
            self:setTransparency(LocalPlayer.Character, 0.5, 0.5)
        else
            self.toggle.Text = "OFF"
            self.toggle.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
            
            self:cleanupSeat()
            self:setTransparency(LocalPlayer.Character, 0, 0.3)
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
                iconLabel.Text = "I"
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
                        dragging = true
                        dragStart = input.Position
                        startPos = self.squareIcon.Position
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
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
            self.minimizeButton.Visible = false
            self.titleBar.Visible = false

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
                Size = UDim2.new(0, 250, 0, 100)
            })
            expandTween:Play()
            
            expandTween.Completed:Connect(function()
                self.toggle.Visible = true
                self.minimizeButton.Visible = true
                self.titleBar.Visible = true
            end)
        end
    end,
    
    closeGUI = function(self)
        if self.invis_on then
            self:setTransparency(LocalPlayer.Character, 0, 0)
            self:cleanupSeat()
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
            self:toggleInvisibility()
        end
    end,
    
    onUnload = function(self)
        if self.invis_on then
            self:setTransparency(LocalPlayer.Character, 0, 0)
            self:cleanupSeat()
        end
        if self.gui then
            self.gui:Destroy()
        end
    end
}

invModule:createGUI()
return invModule
