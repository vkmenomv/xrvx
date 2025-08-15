local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local env = getgenv()

-- Module for toggling between default and "fish" animations.
local FishModule = {
    name = "Fish",
    gui = nil,
    isOpen = false,
    api = env.API,
    isMinimized = false,
    
    isFishModeActive = false,
    
    characterConnection = nil,
    originalAnimations = {}, -- Table to store the original animation IDs
    originalJumpPower = nil, -- Variable to store the original Humanoid jump value

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
                Name = "FishGui",
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
                Text = "FISH ANIMATION",
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
        
        local toggleButton = 
            self:createElement(
            "TextButton",
            main,
            {
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, 55),
                BackgroundColor3 = Color3.fromRGB(255, 100, 120),
                Text = "Toggle Fish Mode",
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", toggleButton, {CornerRadius = UDim.new(0, 10)})

        self.gui = gui
        self.main = main
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton
        self.toggleButton = toggleButton

        self:setupEvents()
        self.api:addToActive("fish_gui", gui)
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

        self.toggleButton.MouseButton1Click:Connect(
            function()
                self:toggleFishMode()
            end
        )

        self:makeDraggable(self.main, self.titleBar)
        self:connectToCharacter()
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
                iconLabel.Text = "FM"
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
                self.toggleButton.Visible = true
                self.titleBar.Visible = true
            end)
        end
    end,

    closeGUI = function(self)
        self:onUnload()
    end,
    
    toggleFishMode = function(self)
        self.isFishModeActive = not self.isFishModeActive
        self:applyAnimations()
    end,

    getOriginalAnimations = function(self, Animate, Humanoid)
        if not self.originalAnimations.walk then
            self.originalAnimations.walk = Animate.walk.WalkAnim.AnimationId
            self.originalAnimations.run = Animate.run.RunAnim.AnimationId
            self.originalAnimations.idle1 = Animate.idle.Animation1.AnimationId
            self.originalAnimations.idle2 = Animate.idle.Animation2.AnimationId
            self.originalAnimations.jump = Animate.jump.JumpAnim.AnimationId
            self.originalAnimations.fall = Animate.fall.FallAnim.AnimationId
            self.originalAnimations.climb = Animate.climb.ClimbAnim.AnimationId
        end
        if self.originalJumpPower == nil then
            self.originalJumpPower = Humanoid.Jump
        end
    end,

    applyAnimations = function(self)
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("Animate") or not character:FindFirstChild("Humanoid") then
            -- Reconnect to the character if it doesn't exist
            self:connectToCharacter()
            return
        end
        
        local Animate = character.Animate
        local Humanoid = character.Humanoid

        self:getOriginalAnimations(Animate, Humanoid)
        
        if self.isFishModeActive then
            -- Apply "fish" animations
            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=102583205412686"
            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=102583205412686"
            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=102583205412686"
            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=102583205412686"
            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=102583205412686"
            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=102583205412686"
            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=102583205412686"
            
            Humanoid.Jump = false
            self.toggleButton.Text = "Fish Mode: ON"
            self.toggleButton.BackgroundColor3 = Color3.fromRGB(100, 255, 120)
        else
            -- Apply original animations
            Animate.walk.WalkAnim.AnimationId = self.originalAnimations.walk
            Animate.run.RunAnim.AnimationId = self.originalAnimations.run
            Animate.idle.Animation1.AnimationId = self.originalAnimations.idle1
            Animate.idle.Animation2.AnimationId = self.originalAnimations.idle2
            Animate.jump.JumpAnim.AnimationId = self.originalAnimations.jump
            Animate.fall.FallAnim.AnimationId = self.originalAnimations.fall
            Animate.climb.ClimbAnim.AnimationId = self.originalAnimations.climb
            
            Humanoid.Jump = self.originalJumpPower
            self.toggleButton.Text = "Fish Mode: OFF"
            self.toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 120)
        end
    end,

    connectToCharacter = function(self)
        if self.characterConnection then
            pcall(function() self.characterConnection:Disconnect() end)
            self.characterConnection = nil
        end
        
        self.characterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
            -- Wait for the 'Animate' script to be in the new character model
            character:WaitForChild("Animate")
            self:applyAnimations()
        end)
        
        -- Also apply to the current character if it exists
        if LocalPlayer.Character then
            self:applyAnimations()
        end
    end,

    onUnload = function(self)
        if self.characterConnection then
            pcall(function() self.characterConnection:Disconnect() end)
            self.characterConnection = nil
        end
        -- Reset animations to default when the script is unloaded
        self.isFishModeActive = false
        self:applyAnimations()
        if self.gui then
            self.gui:Destroy()
            self.gui = nil
        end
    end
}

FishModule:createGUI()
return FishModule
