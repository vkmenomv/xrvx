local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local env = getgenv()

local cbModule = {
    name = "cb",
    gui = nil,
    isOpen = false,
    isMinimized = false,
    api = env.API,
    
    settings = {
        espEnabled = false,
        espEnemyColor = Color3.fromRGB(255, 100, 120),
        espTeammateColor = Color3.fromRGB(100, 255, 150),
        espThickness = 2,
        espShowTeammates = false,
        espShowNames = true,
        aimbotEnabled = false,
        aimbotAiming = false,
        aimbotTeamCheck = true,
        aimbotDrawFOV = true,
        aimbotFOVRadius = 150,
        aimbotFOVColor = Color3.fromRGB(255, 255, 255),
        aimbotSmoothing = 3,
        noClipEnabled = false,
        noRecoilEnabled = false,
        flightEnabled = false,
        bhopEnabled = false,
        fullBrightEnabled = false
    },
    
    connections = {},
    espBoxes = {},
    fovcircle = nil,
    bodyVelocity = nil,
    originalLighting = {},
    originalSpreadValues = {},
    holdingSpace = false,
    isDragEnabled = true,
    
    createElement = function(self, className, properties)
        local element = Instance.new(className)
        for prop, value in pairs(properties or {}) do
            pcall(function() element[prop] = value end)
        end
        return element
    end,
    
    addCorner = function(self, element, radius)
        self:createElement("UICorner", {CornerRadius = UDim.new(0, radius or 10), Parent = element})
    end,
    
    addBorder = function(self, element, color, thickness, transparency)
        self:createElement("UIStroke", {Color = color or Color3.fromRGB(100, 150, 255), Thickness = thickness or 2, Transparency = transparency or 0.3, Parent = element})
    end,
    
    addGradient = function(self, element, colors, rotation)
        self:createElement("UIGradient", {Color = ColorSequence.new(colors), Rotation = rotation or 90, Parent = element})
    end,
    
    saveConfig = function(self)
        local config = {
            esp = {
                enabled = self.settings.espEnabled,
                showTeammates = self.settings.espShowTeammates,
                showNames = self.settings.espShowNames,
                enemyColor = {self.settings.espEnemyColor.R, self.settings.espEnemyColor.G, self.settings.espEnemyColor.B},
                teammateColor = {self.settings.espTeammateColor.R, self.settings.espTeammateColor.G, self.settings.espTeammateColor.B},
                thickness = self.settings.espThickness
            },
            aimbot = {
                enabled = self.settings.aimbotEnabled,
                teamCheck = self.settings.aimbotTeamCheck,
                drawFOV = self.settings.aimbotDrawFOV,
                fovRadius = self.settings.aimbotFOVRadius,
                fovColor = {self.settings.aimbotFOVColor.R, self.settings.aimbotFOVColor.G, self.settings.aimbotFOVColor.B},
                smoothing = self.settings.aimbotSmoothing
            },
            visual = {
                noClip = self.settings.noClipEnabled,
                noRecoil = self.settings.noRecoilEnabled,
                fullBright = self.settings.fullBrightEnabled
            },
            movement = {
                flight = self.settings.flightEnabled,
                bhop = self.settings.bhopEnabled
            }
        }
        
        pcall(function()
            if not isfolder("ASTRALIX") then
                makefolder("ASTRALIX")
            end
            if not isfolder("ASTRALIX/cb") then
                makefolder("ASTRALIX/cb")
            end
            writefile("ASTRALIX/cb/config.json", HttpService:JSONEncode(config))
        end)
    end,
    
    loadConfig = function(self)
        local success, config = pcall(function()
            if isfile("ASTRALIX/cb/config.json") then
                return HttpService:JSONDecode(readfile("ASTRALIX/cb/config.json"))
            end
            return nil
        end)
        
        if success and config then
            if config.esp then
                self.settings.espEnabled = config.esp.enabled or false
                self.settings.espShowTeammates = config.esp.showTeammates or false
                self.settings.espShowNames = config.esp.showNames or true
                self.settings.espThickness = config.esp.thickness or 2
                if config.esp.enemyColor then
                    self.settings.espEnemyColor = Color3.fromRGB(config.esp.enemyColor[1], config.esp.enemyColor[2], config.esp.enemyColor[3])
                end
                if config.esp.teammateColor then
                    self.settings.espTeammateColor = Color3.fromRGB(config.esp.teammateColor[1], config.esp.teammateColor[2], config.esp.teammateColor[3])
                end
            end
            
            if config.aimbot then
                self.settings.aimbotEnabled = config.aimbot.enabled or false
                self.settings.aimbotTeamCheck = config.aimbot.teamCheck or true
                self.settings.aimbotDrawFOV = config.aimbot.drawFOV or true
                self.settings.aimbotFOVRadius = config.aimbot.fovRadius or 150
                self.settings.aimbotSmoothing = config.aimbot.smoothing or 3
                if config.aimbot.fovColor then
                    self.settings.aimbotFOVColor = Color3.fromRGB(config.aimbot.fovColor[1], config.aimbot.fovColor[2], config.aimbot.fovColor[3])
                end
            end
            
            if config.visual then
                self.settings.noClipEnabled = config.visual.noClip or false
                self.settings.noRecoilEnabled = config.visual.noRecoil or false
                self.settings.fullBrightEnabled = config.visual.fullBright or false
            end
            
            if config.movement then
                self.settings.flightEnabled = config.movement.flight or false
                self.settings.bhopEnabled = config.movement.bhop or false
            end
        end
    end,
    
    getPlayerTeam = function(self, player)
        if player.Team then return player.Team end
        
        local teamFolder = player:FindFirstChild("Team")
        if teamFolder and teamFolder.Value then return teamFolder.Value end
        
        if player.Character then
            for _, item in pairs(player.Character:GetChildren()) do
                if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") then
                    local name = item.Name:lower()
                    if name:find("terrorist") or name:find("t") then
                        return "Terrorists"
                    elseif name:find("counter") or name:find("ct") then
                        return "Counter-Terrorists"
                    end
                end
            end
        end
        
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local team = leaderstats:FindFirstChild("Team")
            if team then return team.Value end
        end
        
        return "Unknown"
    end,
    
    isPlayerEnemy = function(self, player)
        if not LocalPlayer or not player then return false end
        if player == LocalPlayer then return false end
        
        local myTeam = self:getPlayerTeam(LocalPlayer)
        local theirTeam = self:getPlayerTeam(player)
        
        if myTeam == "Unknown" or theirTeam == "Unknown" then
            return true
        end
        
        return myTeam ~= theirTeam
    end,
    
    createESPBox = function(self, player)
        if self.espBoxes[player] then return end
        
        local BoxOutline = Drawing.new("Square")
        BoxOutline.Visible = false
        BoxOutline.Color = self.settings.espEnemyColor
        BoxOutline.Thickness = self.settings.espThickness
        BoxOutline.Transparency = 1
        BoxOutline.Filled = false
        
        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Color3.new(1, 1, 1)
        Box.Thickness = 1
        Box.Transparency = 1
        Box.Filled = false
        
        local NameTag = Drawing.new("Text")
        NameTag.Visible = false
        NameTag.Color = Color3.new(1, 1, 1)
        NameTag.Size = 14
        NameTag.Center = true
        NameTag.Outline = true
        NameTag.OutlineColor = Color3.new(0, 0, 0)
        NameTag.Font = Drawing.Fonts.Plex
        NameTag.Text = player.Name
        
        self.espBoxes[player] = {BoxOutline, Box, NameTag}
        
        local connection = RunService.RenderStepped:Connect(function()
            if not self.settings.espEnabled then
                BoxOutline.Visible = false
                Box.Visible = false
                NameTag.Visible = false
                return
            end
            
            local isEnemy = self:isPlayerEnemy(player)
            local isTeammate = not isEnemy and player ~= LocalPlayer
            
            local shouldShow = false
            if isEnemy then
                shouldShow = true
                BoxOutline.Color = self.settings.espEnemyColor
                NameTag.Color = self.settings.espEnemyColor
            elseif isTeammate and self.settings.espShowTeammates then
                shouldShow = true
                BoxOutline.Color = self.settings.espTeammateColor
                NameTag.Color = self.settings.espTeammateColor
            end
            
            if not shouldShow then
                BoxOutline.Visible = false
                Box.Visible = false
                NameTag.Visible = false
                return
            end
            
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
               player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                
                local RootPart = player.Character.HumanoidRootPart
                local Head = player.Character:FindFirstChild("Head")
                if not Head then return end
                
                local camera = Workspace.CurrentCamera
                local RootPosition, onScreen = camera:WorldToViewportPoint(RootPart.Position)
                local HeadPosition = camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegPosition = camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0))
                
                if onScreen then
                    local size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                    local pos = Vector2.new(RootPosition.X - size.X / 2, RootPosition.Y - size.Y / 2)
                    
                    BoxOutline.Size = size
                    BoxOutline.Position = pos
                    BoxOutline.Visible = true
                    
                    Box.Size = size
                    Box.Position = pos
                    Box.Visible = true
                    
                    if self.settings.espShowNames then
                        NameTag.Position = Vector2.new(RootPosition.X, pos.Y - 20)
                        NameTag.Visible = true
                    else
                        NameTag.Visible = false
                    end
                else
                    BoxOutline.Visible = false
                    Box.Visible = false
                    NameTag.Visible = false
                end
            else
                BoxOutline.Visible = false
                Box.Visible = false
                NameTag.Visible = false
            end
        end)
        
        table.insert(self.connections, connection)
    end,
    
    initESP = function(self)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                self:createESPBox(player)
            end
        end
        
        local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                self:createESPBox(player)
            end
        end)
        
        table.insert(self.connections, playerAddedConnection)
    end,
    
    initAimbot = function(self)
        self.fovcircle = Drawing.new("Circle")
        self.fovcircle.Visible = self.settings.aimbotDrawFOV
        self.fovcircle.Radius = self.settings.aimbotFOVRadius
        self.fovcircle.Color = self.settings.aimbotFOVColor
        self.fovcircle.Thickness = 2
        self.fovcircle.Filled = false
        self.fovcircle.Transparency = 1
        
        local function updateFOVPosition()
            if self.fovcircle then
                local camera = Workspace.CurrentCamera
                self.fovcircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                self.fovcircle.Radius = self.settings.aimbotFOVRadius
                self.fovcircle.Visible = self.settings.aimbotDrawFOV
            end
        end
        
        local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                if self.settings.aimbotEnabled then
                    self.settings.aimbotAiming = true
                end
            end
        end)
        
        local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                self.settings.aimbotAiming = false
            end
        end)
        
        local aimbotConnection = RunService.RenderStepped:Connect(function()
            updateFOVPosition()
            
            local dist = math.huge
            local closestChar = nil
            
            if self.settings.aimbotEnabled and self.settings.aimbotAiming then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and 
                       player.Character:FindFirstChild("HumanoidRootPart") and
                       player.Character:FindFirstChild("Humanoid") and
                       player.Character.Humanoid.Health > 0 then
                        
                        if (self.settings.aimbotTeamCheck and self:isPlayerEnemy(player)) or not self.settings.aimbotTeamCheck then
                            local char = player.Character
                            local targetPart = char:FindFirstChild("Head")
                            
                            if targetPart then
                                local camera = Workspace.CurrentCamera
                                local charPartPos, isOnScreen = camera:WorldToViewportPoint(targetPart.Position)
                                
                                if isOnScreen then
                                    local mouse = LocalPlayer:GetMouse()
                                    local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(charPartPos.X, charPartPos.Y)).Magnitude
                                    
                                    if mag < dist and mag < self.settings.aimbotFOVRadius then
                                        dist = mag
                                        closestChar = char
                                    end
                                end
                            end
                        end
                    end
                end
                
                if closestChar and closestChar:FindFirstChild("HumanoidRootPart") and
                   closestChar:FindFirstChild("Humanoid") and closestChar.Humanoid.Health > 0 then
                    local camera = Workspace.CurrentCamera
                    local targetPart = closestChar:FindFirstChild("Head")
                    if targetPart then
                        if self.settings.aimbotSmoothing > 1 then
                            local targetCFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
                            camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / self.settings.aimbotSmoothing)
                        else
                            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
                        end
                    end
                end
            end
        end)
        
        table.insert(self.connections, inputBeganConnection)
        table.insert(self.connections, inputEndedConnection)
        table.insert(self.connections, aimbotConnection)
    end,
    
    initFullBright = function(self)
        self.originalLighting = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient,
        }
    end,
    
    setFullBright = function(self, enabled)
        if enabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.new(1, 1, 1)
        else
            for prop, value in pairs(self.originalLighting) do
                Lighting[prop] = value
            end
        end
    end,
    
    initNoClip = function(self)
        local noClipConnection = RunService.Stepped:Connect(function()
            if self.settings.noClipEnabled then
                pcall(function()
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end)
            end
        end)
        
        table.insert(self.connections, noClipConnection)
    end,
    
    applyNoRecoil = function(self)
        local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
        if weaponsFolder then
            for _, weapon in pairs(weaponsFolder:GetChildren()) do
                local spreadFolder = weapon:FindFirstChild("Spread")
                if spreadFolder then
                    for _, val in pairs(spreadFolder:GetChildren()) do
                        if val:IsA("NumberValue") then
                            local key = weapon.Name .. "/" .. val.Name
                            if self.originalSpreadValues[key] == nil then
                                self.originalSpreadValues[key] = val.Value
                            end
                            val.Value = 0
                        end
                    end
                end
            end
        end
    end,
    
    restoreSpread = function(self)
        local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
        if weaponsFolder then
            for _, weapon in pairs(weaponsFolder:GetChildren()) do
                local spreadFolder = weapon:FindFirstChild("Spread")
                if spreadFolder then
                    for _, val in pairs(spreadFolder:GetChildren()) do
                        if val:IsA("NumberValue") then
                            local key = weapon.Name .. "/" .. val.Name
                            local original = self.originalSpreadValues[key]
                            if original then
                                val.Value = original
                            end
                        end
                    end
                end
            end
        end
    end,
    
    initFlight = function(self)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
        
        self.bodyVelocity = Instance.new("BodyVelocity")
        self.bodyVelocity.Name = "FlightVelocity"
        self.bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        self.bodyVelocity.Velocity = Vector3.zero
        self.bodyVelocity.Parent = humanoidRootPart
        
        local flightConnection = RunService.RenderStepped:Connect(function()
            local camera = Workspace.CurrentCamera
            local moveVec = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVec = moveVec + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVec = moveVec - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVec = moveVec - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVec = moveVec + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVec = moveVec + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveVec = moveVec - Vector3.new(0, 1, 0)
            end
            
            if moveVec.Magnitude > 0 then
                self.bodyVelocity.Velocity = moveVec.Unit * 50
            else
                self.bodyVelocity.Velocity = Vector3.zero
            end
        end)
        
        table.insert(self.connections, flightConnection)
    end,
    
    removeFlight = function(self)
        if self.bodyVelocity then
            self.bodyVelocity:Destroy()
            self.bodyVelocity = nil
        end
    end,
    
    initBunnyHop = function(self)
        local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
                self.holdingSpace = true
            end
        end)
        
        local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                self.holdingSpace = false
            end
        end)
        
        local bhopConnection = RunService.RenderStepped:Connect(function()
            if not self.settings.bhopEnabled then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local humanoid = char:FindFirstChildWhichIsA("Humanoid")
            if not humanoid then return end
            
            if self.holdingSpace and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        
        table.insert(self.connections, inputBeganConnection)
        table.insert(self.connections, inputEndedConnection)
        table.insert(self.connections, bhopConnection)
    end,
    
    createToggle = function(self, parent, name, settingKey, callback)
        local toggleFrame = self:createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Color3.fromRGB(20, 20, 30),
            BackgroundTransparency = 0.2,
            Parent = parent
        })
        
        self:addCorner(toggleFrame, 8)
        
        local label = self:createElement("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = toggleFrame
        })
        
        local toggle = self:createElement("TextButton", {
            Size = UDim2.new(0, 35, 0, 18),
            Position = UDim2.new(1, -40, 0.5, -9),
            BackgroundColor3 = self.settings[settingKey] and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(80, 80, 100),
            Text = self.settings[settingKey] and "ON" or "OFF",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 0.1,
            Parent = toggleFrame
        })
        
        self:addCorner(toggle, 4)
        
        toggle.MouseButton1Click:Connect(function()
            self.settings[settingKey] = not self.settings[settingKey]
            toggle.Text = self.settings[settingKey] and "ON" or "OFF"
            toggle.BackgroundColor3 = self.settings[settingKey] and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(80, 80, 100)
            if callback then callback(self.settings[settingKey]) end
            self:saveConfig()
        end)
        
        toggle.MouseEnter:Connect(function()
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        toggle.MouseLeave:Connect(function()
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        end)
        
        return toggleFrame
    end,
    
    createSlider = function(self, parent, name, settingKey, minValue, maxValue, callback)
        local sliderFrame = self:createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Color3.fromRGB(20, 20, 30),
            BackgroundTransparency = 0.2,
            Parent = parent
        })
        
        self:addCorner(sliderFrame, 8)
        
        local label = self:createElement("TextLabel", {
            Size = UDim2.new(1, -15, 0, 18),
            Position = UDim2.new(0, 12, 0, 5),
            BackgroundTransparency = 1,
            Text = name .. ": " .. self.settings[settingKey],
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sliderFrame
        })
        
        local sliderBg = self:createElement("Frame", {
            Size = UDim2.new(1, -24, 0, 18),
            Position = UDim2.new(0, 12, 0, 26),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BackgroundTransparency = 0.3,
            Parent = sliderFrame
        })
        
        self:addCorner(sliderBg, 4)
        
        local sliderFill = self:createElement("Frame", {
            Size = UDim2.new((self.settings[settingKey] - minValue) / (maxValue - minValue), 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            BackgroundTransparency = 0,
            Parent = sliderBg
        })
        
        self:addCorner(sliderFill, 4)
        
        local isDragging = false
        
        local function updateSlider(percentage)
            percentage = math.clamp(percentage, 0, 1)
            self.settings[settingKey] = math.floor(minValue + percentage * (maxValue - minValue))
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            label.Text = name .. ": " .. self.settings[settingKey]
            if callback then callback(self.settings[settingKey]) end
            self:saveConfig()
        end
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                self.isDragEnabled = false
                local percentage = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                updateSlider(percentage)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percentage = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                updateSlider(percentage)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
                self.isDragEnabled = true
            end
        end)
        
        return sliderFrame
    end,
    
    createTab = function(self, parent, tabName, tabContent)
        local tabFrame = self:createElement("Frame", {
            Size = UDim2.new(1, 0, 1, -100),
            Position = UDim2.new(0, 0, 0, 100),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = parent
        })
        
        local scrollFrame = self:createElement("ScrollingFrame", {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = tabFrame
        })
        
        local layout = self:createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = scrollFrame
        })
        
        self:createElement("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            Parent = scrollFrame
        })
        
        for _, item in ipairs(tabContent) do
            item.create(scrollFrame)
        end
        
        return tabFrame
    end
}

function cbModule:createGUI()
    if self.gui then self.gui:Destroy() end
    
    local screenGui = self:createElement("ScreenGui", {
        Name = "AstralixCB",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (syn and syn.protect_gui and game:GetService("CoreGui")) or (gethui and gethui()) or LocalPlayer.PlayerGui
    })
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end
    
    self.gui = screenGui
    
    local mainFrame = self:createElement("Frame", {
        Size = UDim2.new(0, 450, 0, 500),
        Position = UDim2.new(0.5, -225, 0.5, -250),
        BackgroundColor3 = Color3.fromRGB(12, 12, 18),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = screenGui
    })
    
    self:addCorner(mainFrame, 18)
    self:addBorder(mainFrame, Color3.fromRGB(100, 150, 255), 2, 0.3)
    
    self:addGradient(mainFrame, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 22)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(25, 25, 35)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 22))
    }, 135)
    
    local titleBar = self:createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(20, 20, 30),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = mainFrame
    })
    
    self:addCorner(titleBar, 18)
    self:addBorder(titleBar, Color3.fromRGB(80, 120, 200), 1, 0.4)
    
    local titleLabel = self:createElement("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = "CB/AL | ASTRALIX",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = titleBar
    })
    
    local minimizeButton = self:createElement("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -75, 0, 10),
        BackgroundColor3 = Color3.fromRGB(60, 60, 80),
        BackgroundTransparency = 0.3,
        Text = "-",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        ZIndex = 3,
        Parent = titleBar
    })
    
    self:addCorner(minimizeButton, 8)
    
    local closeButton = self:createElement("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        BackgroundTransparency = 0.3,
        Text = "Ã—",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        ZIndex = 3,
        Parent = titleBar
    })
    
    self:addCorner(closeButton, 8)
    
    local tabContainer = self:createElement("Frame", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = mainFrame
    })
    
    local currentTab = "Combat"
    local tabButtons = {}
    local tabFrames = {}
    
    local function createTabButton(name, position)
        local tabButton = self:createElement("TextButton", {
            Size = UDim2.new(0, 140, 1, 0),
            Position = UDim2.new(0, position, 0, 0),
            BackgroundColor3 = name == currentTab and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(40, 40, 60),
            BackgroundTransparency = name == currentTab and 0.2 or 0.6,
            Text = name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            ZIndex = 3,
            Parent = tabContainer
        })
        
        self:addCorner(tabButton, 8)
        
        tabButton.MouseButton1Click:Connect(function()
            for _, frame in pairs(tabFrames) do
                frame.Visible = false
            end
            
            for _, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                btn.BackgroundTransparency = 0.6
            end
            
            if tabFrames[name] then
                tabFrames[name].Visible = true
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            tabButton.BackgroundTransparency = 0.2
            currentTab = name
        end)
        
        tabButton.MouseEnter:Connect(function()
            if name ~= currentTab then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if name ~= currentTab then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
            end
        end)
        
        tabButtons[name] = tabButton
        return tabButton
    end
    
    createTabButton("Combat", 0)
    createTabButton("Visual", 150)
    createTabButton("Movement", 300)
    
    local combatTab = self:createTab(mainFrame, "Combat", {
        {
            create = function(parent)
                return self:createToggle(parent, "Enable Aimbot", "aimbotEnabled", function(enabled)
                    if not enabled then
                        self.settings.aimbotAiming = false
                    end
                end)
            end
        },
        {
            create = function(parent)
                return self:createToggle(parent, "Team Check", "aimbotTeamCheck")
            end
        },
        {
            create = function(parent)
                return self:createToggle(parent, "Show FOV Circle", "aimbotDrawFOV", function(enabled)
                    if self.fovcircle then
                        self.fovcircle.Visible = enabled
                    end
                end)
            end
        },
        {
            create = function(parent)
                return self:createSlider(parent, "FOV Radius", "aimbotFOVRadius", 50, 400, function(value)
                    if self.fovcircle then
                        self.fovcircle.Radius = value
                    end
                end)
            end
        },
        {
            create = function(parent)
                return self:createSlider(parent, "Smoothing", "aimbotSmoothing", 1, 10)
            end
        },
        {
            create = function(parent)
                return self:createToggle(parent, "No Recoil", "noRecoilEnabled", function(enabled)
                    if enabled then
                        self:applyNoRecoil()
                    else
                        self:restoreSpread()
                    end
                end)
            end
        }
    })
    
    local visualTab = self:createTab(mainFrame, "Visual", {
        {
            create = function(parent)
                return self:createToggle(parent, "Enable ESP", "espEnabled")
            end
        },
        {
            create = function(parent)
                return self:createToggle(parent, "Show Teammates", "espShowTeammates")
            end
        },
        {
            create = function(parent)
                return self:createToggle(parent, "Show Names", "espShowNames")
            end
        },
        {
            create = function(parent)
                return self:createToggle(parent, "Full Bright", "fullBrightEnabled", function(enabled)
                    self:setFullBright(enabled)
                end)
            end
        }
    })
    
    local movementTab = self:createTab(mainFrame, "Movement", {
        {
            create = function(parent)
                return self:createToggle(parent, "Flight", "flightEnabled", function(enabled)
                    if enabled then
                        self:initFlight()
                    else
                        self:removeFlight()
                    end
                end)
            end
        },
        {
            create = function(parent)
                return self:createToggle(parent, "No Clip", "noClipEnabled")
            end
        },
        {
            create = function(parent)
                return self:createToggle(parent, "Bunny Hop", "bhopEnabled")
            end
        }
    })
    
    tabFrames["Combat"] = combatTab
    tabFrames["Visual"] = visualTab
    tabFrames["Movement"] = movementTab
    
    combatTab.Visible = true
    
    self.mainFrame = mainFrame
    self.minimizeButton = minimizeButton
    self.closeButton = closeButton
    self.titleBar = titleBar
    
    return screenGui
end

function cbModule:setupEvents()
    self.minimizeButton.MouseButton1Click:Connect(function()
        self:minimizeToggle()
    end)
    
    self.minimizeButton.MouseEnter:Connect(function()
        TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 120)}):Play()
    end)
    self.minimizeButton.MouseLeave:Connect(function()
        TweenService:Create(self.minimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    end)
    
    self.closeButton.MouseButton1Click:Connect(function()
        self:closeGUI()
    end)
    
    self.closeButton.MouseEnter:Connect(function()
        TweenService:Create(self.closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 120, 120)}):Play()
    end)
    self.closeButton.MouseLeave:Connect(function()
        TweenService:Create(self.closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    
    self:makeDraggable(self.mainFrame, self.titleBar)
end

function cbModule:makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.isDragEnabled then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and self.isDragEnabled then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function cbModule:minimizeToggle()
    self.isMinimized = not self.isMinimized
    
    if self.isMinimized then
        if not self.squareIcon then
            self.squareIcon = Instance.new("Frame")
            self.squareIcon.Size = UDim2.new(0, 50, 0, 50)
            self.squareIcon.Position = self.mainFrame.Position
            self.squareIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
            self.squareIcon.BorderSizePixel = 0
            self.squareIcon.ZIndex = 100
            self.squareIcon.Visible = false
            self.squareIcon.Parent = self.mainFrame.Parent
            
            self:addCorner(self.squareIcon, 12)
            self:addBorder(self.squareIcon, Color3.fromRGB(100, 150, 255), 2, 0.3)
            
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(1, 0, 1, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = "C"
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
                    if not self.isDragEnabled then
                        dragging = true
                        dragStart = input.Position
                        startPos = self.squareIcon.Position
                    end
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and not self.isDragEnabled then
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

        self.tabContainer.Visible = false
        self.minimizeButton.Visible = false
        self.titleBar.Visible = false

        self.squareIcon.Position = self.mainFrame.Position
        self.squareIcon.Size = self.mainFrame.Size
        self.squareIcon.Visible = true
        local mainTween = TweenService:Create(self.mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 50, 0, 50)
        })
        
        local squareTween = TweenService:Create(self.squareIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 50, 0, 50)
        })
        
        mainTween:Play()
        squareTween:Play()
        
        task.spawn(function()
            task.wait(0.4)
            self.mainFrame.Visible = false
        end)
    else
        if self.squareIcon then
            self.mainFrame.Position = self.squareIcon.Position
            self.mainFrame.Size = UDim2.new(0, 50, 0, 50)
            self.squareIcon.Visible = false
        end

        self.mainFrame.Visible = true
        local expandTween = TweenService:Create(self.mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 450, 0, 500)
        })
        expandTween:Play()
        
        expandTween.Completed:Connect(function()
            self.tabContainer.Visible = true
            self.minimizeButton.Visible = true
            self.titleBar.Visible = true
        end)
    end
end

function cbModule:closeGUI()
    self:cleanup()
    
    if self.gui then
        TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        task.spawn(function()
            task.wait(0.3)
            if self.gui then
                self.gui:Destroy()
                self.gui = nil
            end
        end)
    end
    
    self.isOpen = false
end

function cbModule:cleanup()
    for _, connection in pairs(self.connections) do
        if typeof(connection) == "RBXScriptConnection" then
            pcall(function() connection:Disconnect() end)
        end
    end
    self.connections = {}
    
    for _, boxPair in pairs(self.espBoxes) do
        pcall(function() 
            if boxPair[1] then boxPair[1]:Remove() end
            if boxPair[2] then boxPair[2]:Remove() end
            if boxPair[3] then boxPair[3]:Remove() end
        end)
    end
    self.espBoxes = {}
    
    if self.fovcircle then
        pcall(function() self.fovcircle:Remove() end)
        self.fovcircle = nil
    end
    
    self:setFullBright(false)
    self:restoreSpread()
    self:removeFlight()
    
    if self.api then
        self.api:removeFromActive("cb")
    end
end

function cbModule:execute()
    if self.isOpen then
        self:closeGUI()
        return
    end
    
    self:loadConfig()
    self:createGUI()
    self:setupEvents()
    
    self:initESP()
    self:initAimbot()
    self:initFullBright()
    self:initNoClip()
    self:initBunnyHop()
    
    if self.api then
        self.api:addToActive("cb", self.gui)
    end
    
    self.isOpen = true
    
    local notification = self.api and self.api:showNotification("ASTRALIX", "CB/AL loaded successfully", 3, "success")
    if not notification then
        print("ASTRALIX CB: Module loaded")
    end
end

function cbModule:onUnload()
    self:cleanup()
end

return cbModule
