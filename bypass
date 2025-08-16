local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local env = getgenv()

local bypassModule = {
    name = "bypass",
    gui = nil,
    isOpen = false,
    api = env.API,
    isMinimized = false,
    prefixCharacter = "  ",
    suffixCharacter = "  ",
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
                Name = "BypassGui",
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
                Text = "CHAT BYPASSER",
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

        local inputBox =
            self:createElement(
            "TextBox",
            main,
            {
                Size = UDim2.new(1, -20, 0, 35),
                Position = UDim2.new(0, 10, 0, 50),
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                PlaceholderText = "Enter message...",
                Text = "",
                TextSize = 14,
                Font = Enum.Font.Gotham,
                ClearTextOnFocus = true,
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", inputBox, {CornerRadius = UDim.new(0, 6)})

        local sendButton =
            self:createElement(
            "TextButton",
            main,
            {
                Size = UDim2.new(1, -20, 0, 35),
                Position = UDim2.new(0, 10, 0, 90),
                BackgroundColor3 = Color3.fromRGB(80, 100, 200),
                Text = "Send",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                BorderSizePixel = 0
            }
        )

        self:createElement("UICorner", sendButton, {CornerRadius = UDim.new(0, 6)})

        self.gui = gui
        self.main = main
        self.titleBar = titleBar
        self.closeButton = closeButton
        self.minimizeButton = minimizeButton
        self.inputBox = inputBox
        self.sendButton = sendButton

        self:setupEvents()
        self.api:addToActive("bypass_gui", gui)
        return gui
    end,

    setupEvents = function(self)

        local function processText()
            local inputText = self.inputBox.Text
            if inputText ~= "" then
                self:sendChat(inputText)
                self.inputBox.Text = ""
            end
        end

        self.sendButton.MouseButton1Click:Connect(function()
            processText()
        end)

        self.inputBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                processText()
            end
        end)

        self.sendButton.MouseEnter:Connect(function()
            TweenService:Create(self.sendButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 120, 255)}):Play()
        end)

        self.sendButton.MouseLeave:Connect(function()
            TweenService:Create(self.sendButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 100, 200)}):Play()
        end)

        self.closeButton.MouseButton1Click:Connect(function()
            self:closeGUI()
        end)

        self.minimizeButton.MouseButton1Click:Connect(function()
            self:minimizeToggle()
        end)

        self:makeDraggable(self.main, self.titleBar)
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
                iconLabel.Text = "BP"
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

            self.inputBox.Visible = false
            self.sendButton.Visible = false
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
            local expandTween = TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 250, 0, 130)})
            expandTween:Play()

            expandTween.Completed:Connect(function()
                self.inputBox.Visible = true
                self.sendButton.Visible = true
                self.minimizeButton.Visible = true
                self.titleBar.Visible = true
            end)
        end
    end,

    letters = {
    ["A"] = "Ḁַ",
    ["B"] = "Ḃַ",
    ["C"] = "Ḉַ",
    ["D"] = "Ḍַ",
    ["E"] = "Ẹַ",
    ["F"] = "Ḟַ",
    ["G"] = "Ḡַ",
    ["H"] = "Ḥַ",
    ["I"] = "Ịַ",
    ["J"] = "J",
    ["K"] = "Ḳַ",
    ["L"] = "Ḷַ",
    ["M"] = "Ṃַ",
    ["N"] = "Ṇַ",
    ["O"] = "Ọַ",
    ["P"] = "Ṗַ",
    ["Q"] = "Q",
    ["R"] = "Ṛַ",
    ["S"] = "Ṣַ",
    ["T"] = "Ṭַ",
    ["U"] = "Ụַ",
    ["V"] = "Ṿַ",
    ["W"] = "Ẉַ",
    ["X"] = "Ẋַ",
    ["Y"] = "Ỵַ",
    ["Z"] = "Ẓַ",

    ["a"] = "ạַ",
    ["b"] = "ḃַ",
    ["c"] = "ċַ",
    ["d"] = "ḋַ",
    ["e"] = "ẹַ",
    ["f"] = "ḟַ",
    ["g"] = "ġַ",
    ["h"] = "ḥַ",
    ["i"] = "ịַ",
    ["j"] = "j",
    ["k"] = "ḳַ",
    ["l"] = "ḷַ",
    ["m"] = "ṃַ",
    ["n"] = "ṇַ",
    ["o"] = "ọַ",
    ["p"] = "ṗַ",
    ["q"] = "q",
    ["r"] = "ṛַ",
    ["s"] = "ṣַ",
    ["t"] = "ṭַ",
    ["u"] = "ụַ",
    ["v"] = "ṿַ",
    ["w"] = "ẉַ",
    ["x"] = "ẋַ",
    ["y"] = "ỵַ",
    ["z"] = "ẓַ",
    [" "] = "  "
    },

    wordReplacements = {
    ["fuck"] = "ḞַỤַḈַḲַ",
    ["FUCK"] = "ḞַỤַḈַḲַ",
    ["Fuck"] = "ḞַỤַḈַḲַ",
    ["fucking"] = "ḞַỤַḈַḲַỊַṄַḠַ",
    ["FUCKING"] = "ḞַỤַḈַḲַỊַṄַḠַ",
    ["Fucking"] = "ḞַỤַḈַḲַỊַṄַḠַ",
    ["fucked"] = "ḞַỤַḈַḲַḚַḊַ",
    ["FUCKED"] = "ḞַỤַḈַḲַḚַḊַ",
    ["Fucked"] = "ḞַỤַḈַḲַḚַḊַ",
    ["fucker"] = "ḞַỤַḈַḲַḚַṘַ",
    ["FUCKER"] = "ḞַỤַḈַḲַḚַṘַ",
    ["Fucker"] = "ḞַỤַḈַḲַḚַṘַ",

    ["nigger"] = "ṄַỊַḠַḠַḚַṘַ",
    ["NIGGER"] = "ṄַỊַḠַḠַḚַṘַ",
    ["Nigger"] = "ṄַỊַḠַḠַḚַṘַ",
    ["nigga"] = "ṄַỊַḠַḠַḀַ",
    ["NIGGA"] = "ṄַỊַḠַḠַḀַ",
    ["Nigga"] = "ṄַỊַḠַḠַḀַ",

    ["bitch"] = "ḂַỊַṬַḈַḤַ",
    ["BITCH"] = "ḂַỊַṬַḈַḤַ",
    ["Bitch"] = "ḂַỊַṬַḈַḤַ",
    ["bitches"] = "ḂַỊַṬַḈַḤַḚַṠַ",
    ["BITCHES"] = "ḂַỊַṬַḈַḤַḚַṠַ",
    ["Bitches"] = "ḂַỊַṬַḈַḤַḚַṠַ",
    ["slut"] = "ṠַḺַỤַṬַ",
    ["SLUT"] = "ṠַḺַỤַṬַ",
    ["Slut"] = "ṠַḺַỤַṬַ",
    ["sluts"] = "ṠַḺַỤַṬַṠַ",
    ["SLUTS"] = "ṠַḺַỤַṬַṠַ",
    ["Sluts"] = "ṠַḺַỤַṬַṠַ",
    ["whore"] = "ẈַḤַỌַṘַḚַ",
    ["WHORE"] = "ẈַḤַỌַṘַḚַ",
    ["Whore"] = "ẈַḤַỌַṘַḚַ",
    ["whores"] = "ẈַḤַỌַṘַḚַṠַ",
    ["WHORES"] = "ẈַḤַỌַṘַḚַṠַ",
    ["Whores"] = "ẈַḤַỌַṘַḚַṠַ",

    ["pussy"] = "ṖַỤַṠַṠַỴַ",
    ["PUSSY"] = "ṖַỤַṠַṠַỴַ",
    ["Pussy"] = "ṖַỤַṠַṠַỴַ",
    ["dick"] = "ḊַỊַḈַḲַ",
    ["DICK"] = "ḊַỊַḈַḲַ",
    ["Dick"] = "ḊַỊַḈַḲַ",
    ["cock"] = "ḈַỌַḈַḲַ",
    ["COCK"] = "ḈַỌַḈַḲַ",
    ["Cock"] = "ḈַỌַḈַḲַ",
    ["penis"] = "ṖַḚַṄַỊַṠַ",
    ["PENIS"] = "ṖַḚַṄַỊַṠַ",
    ["Penis"] = "ṖַḚַṄַỊַṠַ",
    ["vagina"] = "ṾַḀַḠַỊַṄַḀַ",
    ["VAGINA"] = "ṾַḀַḠַỊַṄַḀַ",
    ["Vagina"] = "ṾַḀַḠַỊַṄַḀַ",
    ["tits"] = "ṬַỊַṬַṠַ",
    ["TITS"] = "ṬַỊַṬַṠַ",
    ["Tits"] = "ṬַỊַṬַṠַ",
    ["boobs"] = "ḂַỌַỌַḂַṠַ",
    ["BOOBS"] = "ḂַỌַỌַḂַṠַ",
    ["Boobs"] = "ḂַỌַỌַḂַṠַ",
    ["ass"] = "ḀַṠַṠַ",
    ["ASS"] = "ḀַṠַṠַ",
    ["Ass"] = "ḀַṠַṠַ",

    ["damn"] = "ḊַḀַṀַṆַ",
    ["DAMN"] = "ḊַḀַṀַṆַ",
    ["Damn"] = "ḊַḀַṀַṆַ",
    ["shit"] = "ṠַḤַỊַṬַ",
    ["SHIT"] = "ṠַḤַỊַṬַ",
    ["Shit"] = "ṠַḤַỊַṬַ",
    ["crap"] = "ḈַṘַḀַṖַ",
    ["CRAP"] = "ḈַṘַḀַṖַ",
    ["Crap"] = "ḈַṘַḀַṖַ",
    ["hell"] = "ḤַḚַḺַḺַ",
    ["HELL"] = "ḤַḚַḺַḺַ",
    ["Hell"] = "ḤַḚַḺַḺַ",
    ["bastard"] = "ḂַḀַṠַṬַḀַṘַḊַ",
    ["BASTARD"] = "ḂַḀַṠַṬַḀַṘַḊַ",
    ["Bastard"] = "ḂַḀַṠַṬַḀַṘַḊַ",

    ["noob"] = "ṄַỌַỌַḂַ",
    ["NOOB"] = "ṄַỌַỌַḂַ",
    ["Noob"] = "ṄַỌַỌַḂַ",
    ["scrub"] = "ṠַḈַṘַỤַḂַ",
    ["SCRUB"] = "ṠַḈַṘַỤַḂַ",
    ["Scrub"] = "ṠַḈַṘַỤַḂַ",
    ["trash"] = "ṬַṘַḀַṠַḤַ",
    ["TRASH"] = "ṬַṘַḀַṠַḤַ",
    ["Trash"] = "ṬַṘַḀַṠַḤַ",
    ["toxic"] = "ṬַỌַẌַỊַḈַ",
    ["TOXIC"] = "ṬַỌַẌַỊַḈַ",
    ["Toxic"] = "ṬַỌַẌַỊַḈַ",

    ["idiot"] = "ỊַḊַỊַỌַṬַ",
    ["IDIOT"] = "ỊַḊַỊַỌַṬַ",
    ["Idiot"] = "ỊַḊַỊַỌַṬַ",
    ["stupid"] = "ṠַṬַỤַṖַỊַḊַ",
    ["STUPID"] = "ṠַṬַỤַṖַỊַḊַ",
    ["Stupid"] = "ṠַṬַỤַṖַỊַḊַ",
    ["dumb"] = "ḊַỤַṀַḂַ",
    ["DUMB"] = "ḊַỤַṀַḂַ",
    ["Dumb"] = "ḊַỤַṀַḂַ",
    ["retard"] = "ṘַḚַṬַḀַṘַḊַ",
    ["RETARD"] = "ṘַḚַṬַḀַṘַḊַ",
    ["Retard"] = "ṘַḚַṬַḀַṘַḊַ",
    ["moron"] = "ṀַỌַṘַỌַṆַ",
    ["MORON"] = "ṀַỌַṘַỌַṆַ",
    ["Moron"] = "ṀַỌַṘַỌַṆַ",

    ["kill"] = "ḲַỊַḺַḺַ",
    ["KILL"] = "ḲַỊַḺַḺַ",
    ["Kill"] = "ḲַỊַḺַḺַ",
    ["die"] = "ḊַỊַḚַ",
    ["DIE"] = "ḊַỊַḚַ",
    ["Die"] = "ḊַỊַḚַ",
    ["hate"] = "ḤַḀַṬַḚַ",
    ["HATE"] = "ḤַḀַṬַḚַ",
    ["Hate"] = "ḤַḀַṬַḚַ",

    ["rape"] = "ṘַḀַṖַḚַ",
    ["RAPE"] = "ṘַḀַṖַḚַ",
    ["Rape"] = "ṘַḀַṖַḚַ",
    ["ill"] = "Ịַ'ḺַḺַ",
    ["I'll"] = "Ịַ'ḺַḺַ",
    ["the"] = "ṬַḤַḚַ",
    ["THE"] = "ṬַḤַḚַ",
    ["The"] = "ṬַḤַḚַ",
    ["out"] = "ỌַỤַṬַ",
    ["OUT"] = "ỌַỤַṬַ",
    ["Out"] = "ỌַỤַṬַ",
    ["of"] = "ỌַḞַ",
    ["OF"] = "ỌַḞַ",
    ["Of"] = "ỌַḞַ",
    ["you"] = "ỴַỌַỤַ",
    ["YOU"] = "ỴַỌַỤַ",
    ["You"] = "ỴַỌַỤַ",

    ["go to hell"] = "ḠַỌַ ṬַỌַ ḤַḚַḺַḺַ",
    ["GO TO HELL"] = "ḠַỌַ ṬַỌַ ḤַḚַḺַḺַ",
    ["Go to hell"] = "ḠַỌַ ṬַỌַ ḤַḚַḺַḺַ",
    ["fuck you"] = "ḞַỤַḈַḲַ ỴַỌַỤַ",
    ["FUCK YOU"] = "ḞַỤַḈַḲַ ỴַỌַỤַ",
    ["Fuck you"] = "ḞַỤַḈַḲַ ỴַỌַỤַ",
    ["shut up"] = "ṠַḤַỤַṬַ ỤַṖַ",
    ["SHUT UP"] = "ṠַḤַỤַṬַ ỤַṖַ",
    ["Shut up"] = "ṠַḤַỤַṬַ ỤַṖַ",
    ["piece of shit"] = "ṖַỊַḚַḈַḚַ ỌַḞַ ṠַḤַỊַṬַ",
    ["PIECE OF SHIT"] = "ṖַỊַḚַḈַḚַ ỌַḞַ ṠַḤַỊַṬַ",
    ["Piece of shit"] = "ṖַỊַḚַḈַḚַ ỌַḞ� ṠַḤַỊַṬַ",
    ["son of a bitch"] = "ṠַỌַṆַ ỌַḞַ Ḁַ ḂַỊַṬַḈַḤַ",
    ["SON OF A BITCH"] = "ṠַỌַṆַ ỌַḞַ Ḁַ ḂַỊַṬַḈַḤַ",
    ["Son of a bitch"] = "ṠַỌַṆַ ỌַḞַ Ḁַ ḂַỊַṬַḈַḤַ",
    ["kill yourself"] = "ḲַỊַḺַḺַ ỴַỌַỤַṘַṠַḚַḺַḞַ",
    ["KILL YOURSELF"] = "ḲַỊַḺַḺַ ỴַỌַỤַṘַṠַḚַḺַḞַ",
    ["Kill yourself"] = "ḲַỊַḺַḺַ ỴַỌַỤַṘַṠַḚַḺ�Ḟַ",
    ["i hate you"] = "Ịַ ḤַḀַṬַḚַ ỴַỌַỤַ",
    ["I HATE YOU"] = "Ịַ ḤַḀַṬַḚַ ỴַỌַỤַ",
    ["I hate you"] = "Ịַ ḤַḀַṬַḚַ ỴַỌַỤַ",
    ["what the fuck"] = "ẈַḤַḀַṬַ ṬַḤַḚַ ḞַỤַḈַḲַ",
    ["WHAT THE FUCK"] = "ẈַḤַḀַṬַ ṬַḤַḚַ ḞַỤַḈַḲַ",
    ["What the fuck"] = "ẈַḤַḀַṬַ ṬַḤַḚַ ḞַỤַḈַḲַ",
    ["get fucked"] = "ḠַḚַṬַ ḞַỤַḈַḲַḚַḊַ",
    ["GET FUCKED"] = "ḠַḚַṬַ ḞַỤַḈַḲַḚַḊַ",
    ["Get fucked"] = "ḠַḚַṬַ ḞַỤַḈַḲַḚַḊַ",
    ["you suck"] = "ỴַỌַỤַ ṠַỤַḈַḲַ",
    ["YOU SUCK"] = "ỴַỌַỤַ ṠַỤַḈַḲַ",
    ["You suck"] = "ỴַỌַỤַ ṠַỤַḈַḲַ",
    ["go die"] = "ḠַỌַ ḊַỊַḚַ",
    ["GO DIE"] = "ḠַỌַ ḊַỊַḚ�",
    ["Go die"] = "ḠַỌַ ḊַỊַḚַ",
    ["your mom"] = "ỴַỌַỤַṘַ ṀַỌַṀַ",
    ["YOUR MOM"] = "ỴַỌַỤַṘַ ṀַỌַṀַ",
    ["Your mom"] = "ỴַỌַỤַṘַ ṀַỌַṀַ",
    ["stupid ass"] = "ṠַṬַỤַṖַỊַḊַ ḀַṠַṠַ",
    ["STUPID ASS"] = "ṠַṬַỤַṖַỊַḊַ ḀַṠַṠַ",
    ["Stupid ass"] = "ṠַṬַỤַṖַỊַḊַ ḀַṠַṠַ",
    ["dumb fuck"] = "ḊַỤַṀַḂַ ḞַỤַḈַḲַ",
    ["DUMB FUCK"] = "ḊַỤַṀַḂַ ḞַỤַḈַḲַ",
    ["Dumb fuck"] = "ḊַỤַṀַḂַ ḞַỤַḈַḲַ"
    },

    replace = function(self, str, find_str, replace_str)
        local escaped_find_str = find_str:gsub("[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
        return str:gsub(escaped_find_str, replace_str)
    end,

    applyWordReplacements = function(self, message)
        local convertedMessage = message
        for word, replacement in pairs(self.wordReplacements) do
            convertedMessage = convertedMessage:gsub("%f[%w]" .. word:gsub("[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0") .. "%f[%W]", replacement)
        end
        return convertedMessage
    end,

    closeGUI = function(self)
        if self.ballModeEnabled then
            self:stopBallMode()
        end
        if self.gui then
            self.gui:Destroy()
            self.gui = nil
        end
    end,

    filter = function(self, message)
        local convertedMessage = self:applyWordReplacements(message)

        for letter, replacement in pairs(self.letters) do
            convertedMessage = self:replace(convertedMessage, letter, replacement)
        end
        return self.prefixCharacter .. convertedMessage .. self.suffixCharacter
    end,
    sendChat = function(self, msg)
        local converted = self:filter(msg)
        pcall(function()
            if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
                local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                    chatEvents.SayMessageRequest:FireServer(converted, "All")
                end
            else
                if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                    TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(converted)
                end
            end
        end)
    end,

    init = function(self)
        return self
    end,

    open = function(self)
        if not self.isOpen then
            self.isOpen = true
            self:createGUI()
        end
    end,

    close = function(self)
        if self.isOpen and self.gui then
            self.gui:Destroy()
            self.gui = nil
            self.isOpen = false
        end
    end,

    toggle = function(self)
        if self.isOpen then
            self:close()
        else
            self:open()
        end
    end
}

bypassModule:createGUI()
return bypassModule
