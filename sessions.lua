local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local crequest = syn and syn.request or request or fluxus and fluxus.request or http and http.request or http_request or sentinel and sentinel.request  or http_request or http.request or http and http.request or http_request or (crypt and crypt.request) or request or (SENTINEL_LOADED and request) or (syn and syn.request)  or (typeof(request) == "function" and request) or (typeof(http) == "table" and http.request)
local plr = Players.LocalPlayer
local JSON_URL = "https://pastebin.com/raw/6L28gcbH"
local MAX_RETRIES = 3

local function fetchList(url2, maxRetries)
    local retries = 0
    while retries < maxRetries do
        local success, result = pcall(function()
            return crequest({
                Url = url2,
                method = "GET"
            })
        end)
        if success then
            return true, result.Body
        end
        retries = retries + 1
        if retries < maxRetries then
            local delay = 2 ^ (retries - 1)
            task.wait(delay)
        end
    end
    return false, ""
end

local function loadTagsFromJSON()
    local success, tagConfigRaw = fetchList(JSON_URL, MAX_RETRIES)
    local tagConfig = {}
    if success and tagConfigRaw then
        local parseSuccess, parsedData = pcall(function()
            return HttpService:JSONDecode(tagConfigRaw)
        end)
        if parseSuccess and parsedData then
            tagConfig = parsedData
        end
    end

    local tagOrder = {"AL DEV", "AL BOOSTER", "AL SWASTIKA", "AL CHIPS", "AL RONALDU", "AL USER"}
    local playerToTag = {}
    for _, tag in ipairs(tagOrder) do
        local users = tagConfig[tag]
        if users then
            for _, user in ipairs(users) do
                local userLower = user:lower()
                if not playerToTag[userLower] then
                    playerToTag[userLower] = tag
                end
            end
        end
    end

    local RankData = {
        ["AL DEV"] = {
            primary = Color3.fromRGB(20, 20, 20),
            accent = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 191, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
            },
            emoji = "",
            priority = 1
        },
        ["AL BOOSTER"] = {
            primary = Color3.fromRGB(20, 20, 20),
            accent = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(135, 206, 250)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(173, 216, 230)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 182, 193))
            },
            emoji = "",
            priority = 2
        },
        ["AL RONALDU"] = {
            primary = Color3.fromRGB(20, 20, 20),
            accent = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 50, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 128))
            },
            emoji = "",
            priority = 3
        },
        ["AL SWASTIKA"] = {
            primary = Color3.fromRGB(0, 0, 0),
            accent = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 0, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(139, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
            },
            emoji = "卐",
            priority = 4
        },
        ["AL CHIPS"] = {
            primary = Color3.fromRGB(20, 20, 20),
            accent = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 128)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(186, 85, 211)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            },
            emoji = "",
            priority = 5
        },
        ["AL USER"] = {
            primary = Color3.fromRGB(20, 20, 20),
            accent = Color3.fromRGB(0, 150, 255),
            emoji = "",
            priority = 6
        }
    }

    _G.playerToTag = playerToTag
    _G.RankData = RankData
    _G.ChatWhitelist = _G.ChatWhitelist or {}

    return playerToTag, _G.ChatWhitelist, RankData
end

local function getGlobalData()
    if not _G.playerToTag or not _G.RankData then
        return loadTagsFromJSON()
    end
    return _G.playerToTag or {}, _G.ChatWhitelist or {}, _G.RankData or {}
end

local function getPlayerRank(player)
    if not player then return nil end
    local playerNameLower = player.Name:lower()
    local playerToTag, ChatWhitelist = getGlobalData()
    if playerToTag[playerNameLower] then
        return playerToTag[playerNameLower]
    elseif ChatWhitelist[playerNameLower] then
        return "AL USER"
    end
    return nil
end

local function getPlayerAvatar(userId)
    return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
end

local sessionsModule = {
    name = "sessions",
    gui = nil,
    squareButton = nil,
    sessionFrame = nil,
    isOpen = false,
    isAnimating = false,
    squarePosition = nil,
    api = nil,
    playerCards = {},

    UI = function(className, properties, parent)
        local element = Instance.new(className)
        for prop, value in pairs(properties) do
            element[prop] = value
        end
        if parent then element.Parent = parent end
        return element
    end,

    Corner = function(element, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 6)
        corner.Parent = element
        return corner
    end,

    createSquareButton = function(self)
        local squareButton = self.UI("TextButton", {
            Name = "SessionsSquareButton",
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(1, -285, -0.01, 20),
            BackgroundColor3 = Color3.fromRGB(8, 8, 8),
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 10,
            Parent = self.gui
        })
        self.Corner(squareButton, 12)

        local squareIcon = self.UI("TextLabel", {
            Size = UDim2.new(0.8, 0, 0.8, 0),
            Position = UDim2.new(0.1, 0, 0.1, 0),
            BackgroundTransparency = 1,
            Text = "📡",
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = squareButton
        })

        local gradient = Instance.new("UIGradient", squareIcon)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
        })

        task.spawn(function()
            while squareButton.Parent do
                for i = 0, 360, 3 do
                    if not squareButton.Parent then break end
                    gradient.Rotation = i
                    task.wait(0.03)
                end
            end
        end)

        self.squareButton = squareButton
        self:setupSquareEvents()
        return squareButton
    end,

    setupSquareEvents = function(self)
        local dragging, dragStart, startPos, isDragThresholdMet = false, nil, nil, false

        self.squareButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragStart, startPos, isDragThresholdMet, dragging = input.Position, self.squareButton.Position, false, true
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                if math.sqrt(delta.X ^ 2 + delta.Y ^ 2) > 5 then isDragThresholdMet = true end
                if isDragThresholdMet then
                    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    self.squareButton.Position = newPos
                    self.squarePosition = newPos
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if dragging and not isDragThresholdMet then
                    task.spawn(function()
                        if self.isOpen then
                            self:animateClose()
                        else
                            self:animateOpen()
                        end
                    end)
                end
                dragging, isDragThresholdMet = false, false
            end
        end)
    end,

    createSessionFrame = function(self)
        local sessionFrame = self.UI("Frame", {
            Name = "SessionFrame",
            Size = UDim2.new(0, 50, 0, 50),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BackgroundTransparency = 0.3,
            Visible = false,
            ZIndex = 15,
            Parent = self.gui
        })
        self.Corner(sessionFrame, 15)

        local gradient = Instance.new("UIGradient", sessionFrame)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 40, 70)), 
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(40, 80, 140)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 120, 200)), 
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(40, 80, 140)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 70))
        })
        gradient.Rotation = 45

        task.spawn(function()
            while sessionFrame.Parent do
                for i = 0, 360, 2 do
                    if not sessionFrame.Parent then break end
                    gradient.Rotation = i
                    task.wait(0.05)
                end
            end
        end)

        local topBar = self.UI("Frame", {
            Name = "TopBar",
            Size = UDim2.new(1, -2, 0, 50),
            Position = UDim2.new(0, 1, 0, 0),
            BackgroundTransparency = 1,
            Parent = sessionFrame
        })

        local titleLabel = self.UI("TextLabel", {
            Size = UDim2.new(1, -50, 0, 50),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "ASTRALIX SESSIONS",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = topBar
        })

        local titleGradient = Instance.new("UIGradient", titleLabel)
        titleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), 
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(135, 206, 250)), 
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(135, 206, 250)), 
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
        titleGradient.Rotation = 15
        RunService.Heartbeat:Connect(function()
            local t = tick() * 1.5
            titleGradient.Offset = Vector2.new(math.sin(t) * 0.3, 0)
        end)

        local closeButton = self.UI("TextButton", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -10, 0, 10),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            Parent = topBar
        })

        local contentFrame = self.UI("Frame", {
            Name = "ContentFrame",
            Size = UDim2.new(1, -20, 1, -70),
            Position = UDim2.new(0, 10, 0, 60),
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BackgroundTransparency = 0.5,
            Parent = sessionFrame
        })
        self.Corner(contentFrame, 12)

        local scrollFrame = self.UI("ScrollingFrame", {
            Name = "PlayersScroll",
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255),
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = contentFrame
        })

        local listLayout = Instance.new("UIListLayout")
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 8)
        listLayout.Parent = scrollFrame

        local scrollPadding = Instance.new("UIPadding")
        scrollPadding.PaddingTop = UDim.new(0, 10)
        scrollPadding.PaddingBottom = UDim.new(0, 10)
        scrollPadding.PaddingLeft = UDim.new(0, 8)
        scrollPadding.PaddingRight = UDim.new(0, 8)
        scrollPadding.Parent = scrollFrame

        self.sessionFrame = sessionFrame
        self.topBar = topBar
        self.closeButton = closeButton
        self.scrollFrame = scrollFrame
        self.listLayout = listLayout

        self:setupSessionEvents()
        return sessionFrame
    end,

    setupSessionEvents = function(self)
        self.closeButton.MouseButton1Click:Connect(function()
            task.spawn(function()
                self:animateClose()
            end)
        end)
    end,

    createPlayerCard = function(self, player, rank, layoutOrder)
        local _, _, RankData = getGlobalData()
        local rankData = RankData[rank] or RankData["AL USER"]

        local playerCard = self.UI("Frame", {
            Name = "PlayerCard_" .. player.Name,
            Size = UDim2.new(1, -16, 0, 65),
            BackgroundColor3 = rankData.primary,
            BackgroundTransparency = 0.15,
            LayoutOrder = layoutOrder,
            Parent = self.scrollFrame
        })
        self.Corner(playerCard, 8)

        if typeof(rankData.accent) == "ColorSequence" then
            local cardGradient = Instance.new("UIGradient", playerCard)
            cardGradient.Color = rankData.accent
            cardGradient.Rotation = 45
            cardGradient.Transparency = NumberSequence.new(0.85)
        end

        local cardStroke = Instance.new("UIStroke", playerCard)
        cardStroke.Color = typeof(rankData.accent) == "ColorSequence" and Color3.fromRGB(100, 150, 255) or rankData.accent
        cardStroke.Thickness = 1
        cardStroke.Transparency = 0.6

        local avatarFrame = self.UI("Frame", {
            Name = "AvatarFrame",
            Size = UDim2.new(0, 45, 0, 45),
            Position = UDim2.new(0, 10, 0.5, -22.5),
            BackgroundColor3 = Color3.fromRGB(30, 30, 40),
            BackgroundTransparency = 0.4,
            Parent = playerCard
        })
        self.Corner(avatarFrame, 22)

        local avatarImage = self.UI("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundTransparency = 1,
            Image = getPlayerAvatar(player.UserId),
            ScaleType = Enum.ScaleType.Crop,
            Parent = avatarFrame
        })
        self.Corner(avatarImage, 20)

        local nameLabel = self.UI("TextLabel", {
            Name = "NameLabel",
            Size = UDim2.new(0, 150, 0, 20),
            Position = UDim2.new(0, 65, 0, 8),
            BackgroundTransparency = 1,
            Text = player.DisplayName,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = playerCard
        })

        local usernameLabel = self.UI("TextLabel", {
            Name = "UsernameLabel",
            Size = UDim2.new(0, 150, 0, 15),
            Position = UDim2.new(0, 65, 0, 25),
            BackgroundTransparency = 1,
            Text = "@" .. player.Name,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = playerCard
        })

        local rankLabel = self.UI("TextLabel", {
            Name = "RankLabel",
            Size = UDim2.new(0, 80, 0, 15),
            Position = UDim2.new(0, 65, 0, 42),
            BackgroundTransparency = 1,
            Text = (rankData.emoji or "") .. " " .. rank,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = playerCard
        })

        local actionsFrame = self.UI("Frame", {
            Name = "ActionsFrame",
            Size = UDim2.new(0, 50, 1, -10),
            Position = UDim2.new(1, -55, 0, 5),
            BackgroundTransparency = 1,
            Parent = playerCard
        })

        local teleportButton = self.UI("TextButton", {
            Name = "TeleportButton",
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0, 0, 0, 2),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            BackgroundTransparency = 0.4,
            Text = "🚀",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Parent = actionsFrame
        })
        self.Corner(teleportButton, 4)

        local profileButton = self.UI("TextButton", {
            Name = "ProfileButton",
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0, 26, 0, 2),
            BackgroundColor3 = Color3.fromRGB(150, 100, 255),
            BackgroundTransparency = 0.4,
            Text = "👤",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Parent = actionsFrame
        })
        self.Corner(profileButton, 4)

        local copyButton = self.UI("TextButton", {
            Name = "CopyButton",
            Size = UDim2.new(0, 45, 0, 18),
            Position = UDim2.new(0, 2.5, 0, 27),
            BackgroundColor3 = Color3.fromRGB(255, 150, 100),
            BackgroundTransparency = 0.4,
            Text = "📋",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            Parent = actionsFrame
        })
        self.Corner(copyButton, 4)

        teleportButton.MouseButton1Click:Connect(function()
            if player ~= Players.LocalPlayer then
                self:teleportToPlayer(player)
            end
        end)

        profileButton.MouseButton1Click:Connect(function()
            self:showPlayerProfile(player, rank)
        end)

        copyButton.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(player.Name)
                if self.api then 
                    self.api:showNotification("SESSIONS", "Username copied: " .. player.Name, 2, "success")
                end
            end
        end)

        local function onHover()
            TweenService:Create(playerCard, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
            TweenService:Create(cardStroke, TweenInfo.new(0.2), {
                Transparency = 0.3,
                Thickness = 2
            }):Play()
        end

        local function onLeave()
            TweenService:Create(playerCard, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.15
            }):Play()
            TweenService:Create(cardStroke, TweenInfo.new(0.2), {
                Transparency = 0.6,
                Thickness = 1
            }):Play()
        end

        playerCard.MouseEnter:Connect(onHover)
        playerCard.MouseLeave:Connect(onLeave)

        return playerCard
    end,

    populatePlayers = function(self)
        for _, card in pairs(self.playerCards) do
            if card and card.Parent then
                card:Destroy()
            end
        end
        self.playerCards = {}

        local _, _, RankData = getGlobalData()
        local astralixPlayers = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            local rank = getPlayerRank(player)
            if rank then
                table.insert(astralixPlayers, {
                    player = player,
                    rank = rank,
                    priority = RankData[rank] and RankData[rank].priority or 999
                })
            end
        end

        table.sort(astralixPlayers, function(a, b)
            return a.priority < b.priority
        end)

        for i, data in ipairs(astralixPlayers) do
            local card = self:createPlayerCard(data.player, data.rank, i)
            table.insert(self.playerCards, card)
            task.wait(0.05) 
        end

        task.wait(0.3)
        if self.scrollFrame and self.listLayout then
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.listLayout.AbsoluteContentSize.Y + 20)
        end

        if #astralixPlayers == 0 then
            local noPlayersLabel = self.UI("TextLabel", {
                Name = "NoPlayersLabel",
                Size = UDim2.new(1, 0, 0, 80),
                Position = UDim2.new(0, 0, 0.5, -40),
                BackgroundTransparency = 1,
                Text = "🌟\n\nNo Astralix users found\n\nRefresh the list",
                TextColor3 = Color3.fromRGB(150, 150, 150),
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = self.scrollFrame
            })
            table.insert(self.playerCards, noPlayersLabel)
        end
    end,

    teleportToPlayer = function(self, targetPlayer)
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character
        local targetCharacter = targetPlayer.Character

        if not (character and targetCharacter) then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart") or targetCharacter:FindFirstChild("UpperTorso")

        if not (hrp and targetHRP) then return end
        local env = getgenv()
        local twistieModule = env.ASTRALIX_MODULES and env.ASTRALIX_MODULES.twistie
        local canTeleport = true
        
        if twistieModule and twistieModule.canTeleport then
            local success, canTp = pcall(twistieModule.canTeleport, twistieModule)
            if success then
                canTeleport = canTp
            end
        end
        
        if not canTeleport then
            if self.api then
                self.api:showNotification("SESSIONS", "Cannot teleport during reanimation", 3, "warning")
            end
            return
        end
        
        local fadeTime = 0.1
        local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad)
        
        local meshParts = {}
        for _, part in ipairs(character:GetDescendants()) do
            if (part:IsA("MeshPart") or part:IsA("Part")) and part.Name ~= "HumanoidRootPart" then
                table.insert(meshParts, part)
            end
        end
        
        for _, part in ipairs(meshParts) do
            TweenService:Create(part, tweenInfo, {Transparency = 1}):Play()
        end
        
        task.wait(fadeTime)
        
        local targetCFrame = targetHRP.CFrame
        local teleportPosition = targetCFrame.Position - (targetCFrame.LookVector * 4)
        teleportPosition = teleportPosition + Vector3.new(0, 1, 0)
        hrp.CFrame = CFrame.new(teleportPosition, targetHRP.Position)
        
        for _, part in ipairs(meshParts) do
            TweenService:Create(part, tweenInfo, {Transparency = 0}):Play()
        end
        
        if self.api then 
            self.api:showNotification("SESSIONS", "Teleported to " .. targetPlayer.DisplayName, 2, "info")
        end
    end,

    showPlayerProfile = function(self, player, rank)
        if self.api then
            local message = string.format(
                "👤 %s (@%s)\n🎯 Rank: %s\n🆔 ID: %d\n⏰ Account age: %s",
                player.DisplayName,
                player.Name,
                rank,
                player.UserId,
                player.AccountAge
            )
            self.api:showNotification("Player Profile", message, 5, "info")
        end
    end,

    animateOpen = function(self)
        if self.isOpen or self.isAnimating then return end

        self.isOpen = true
        self.isAnimating = true

        if not self.sessionFrame then self:createSessionFrame() end

        for _, child in pairs(self.sessionFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "UICorner" and child.Name ~= "UIGradient" then
                child.Visible = false
            end
        end

        self.squarePosition = self.squareButton.Position
        self.squareButton.Visible = false
        self.sessionFrame.Visible = true
        self.sessionFrame.Size = UDim2.new(0, 50, 0, 50)
        self.sessionFrame.Position = self.squarePosition
        self.sessionFrame.BackgroundTransparency = 1

        TweenService:Create(self.sessionFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.3
                }):Play()

        task.wait(0.1)

        TweenService:Create(self.sessionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 50, 0, 300)
                }):Play()

        task.wait(0.2)

        TweenService:Create(self.sessionFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 400, 0, 400),
            Position = UDim2.new(self.squarePosition.X.Scale, self.squarePosition.X.Offset - 350, self.squarePosition.Y.Scale, self.squarePosition.Y.Offset)
        }):Play()

        task.wait(0.25)

        local function showAllChildren(parent)
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("GuiObject") and child.Name ~= "UICorner" and child.Name ~= "UIGradient" then
                    child.Visible = true
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.TextTransparency = 1
                        child.BackgroundTransparency = 1
                        TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            TextTransparency = 0,
                            BackgroundTransparency = 1
                        }):Play()
                    else
                        child.BackgroundTransparency = 1
                        TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                    showAllChildren(child)
                end
            end
        end

        showAllChildren(self.sessionFrame)
        task.wait(0.1)
        self:populatePlayers()
        self.isAnimating = false
    end,

    animateClose = function(self)
        if not self.isOpen or self.isAnimating or not self.sessionFrame then return end
        self.isOpen = false
        self.isAnimating = true
        local function hideAllChildren(parent)
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("GuiObject") and child.Name ~= "UICorner" and child.Name ~= "UIGradient" then
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        TweenService:Create(child, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                            BackgroundTransparency = 1,
                            TextTransparency = 1
                        }):Play()
                    else
                        TweenService:Create(child, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                    hideAllChildren(child)
                end
            end
        end
        hideAllChildren(self.sessionFrame)
        task.wait(0.1)
        TweenService:Create(self.sessionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 50, 0, 300),
            Position = self.squarePosition
        }):Play()
    
        task.wait(0.2)
    
        TweenService:Create(self.sessionFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 50, 0, 50)
        }):Play()
    
        task.wait(0.1)
    
        TweenService:Create(self.sessionFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
    
        task.wait(0.15)
    
        self.sessionFrame.Visible = false
        self.squareButton.Visible = true
        self.squareButton.Size = UDim2.new(0, 50, 0, 50)
        self.squareButton.Position = self.squarePosition
        self.squareButton.BackgroundTransparency = 0.4
    
        self.isAnimating = false
    end,

    createGUI = function(self)
        if self.gui then self.gui:Destroy() end

        local playerGui = plr:WaitForChild("PlayerGui")
        self.gui = self.UI("ScreenGui", {
            Name = "SessionsGUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = (syn and syn.protect_gui and game:GetService("CoreGui")) or playerGui
        })

        if syn and syn.protect_gui then syn.protect_gui(self.gui) end

        self:createSquareButton()
        self:createSessionFrame()

        if self.api then self.api:addToActive("sessions_gui", self.gui) end
    end,

    fullUnload = function(self)
        if self.gui then
            self.gui:Destroy()
            self.gui = nil
        end

        self.playerCards = {}
        self.isOpen = false
        self.isAnimating = false

        if self.api then 
            self.api:removeFromActive("sessions_gui")
        end
    end,

    execute = function(self, args)
        if not self.gui then
            self:createGUI()
        end
    end,

    onUnload = function(self)
        self:fullUnload()
    end
}

local function updateTagsFromJSON()
    pcall(function()
        loadTagsFromJSON()
    end)
end

task.spawn(function()
    loadTagsFromJSON()
end)

local env = getgenv()
if env.API then
    sessionsModule.api = env.API
end

env.ASTRALIX_MODULES = env.ASTRALIX_MODULES or {}
env.ASTRALIX_MODULES["sessions"] = sessionsModule

task.spawn(function()
    task.wait(1)
    if not sessionsModule.gui then
        sessionsModule:execute()
    end
end)

task.spawn(function()
    while true do
        task.wait(30)
        updateTagsFromJSON()
    end
end)

return sessionsModule