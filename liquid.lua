--[[
    KEYSER UI V8.5 - FIVEM & IMGUI EDITION (OPTIMIZED by AI)
    Structure: Intro -> Sidebar/Topbar (#131217) -> Content Canvas (#0e0d12) -> Section Cards (#131217 / Header #1c1b22)
    
    Features:
    - FiveM Style Layout (Floating sections over dark canvas).
    - Reduced padding for tighter, professional spacing.
    - Two-tone Section Cards (Header differs from body).
    - Independent Section Scrolling (Pass Height in Section Config).
    - Keybind System (Standalone & Embedded in Toggles).
    - Nested Options (Gear Icon / Flyout Menus).
    - Premium Animations (Quint Easing).
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}

--[ THEME - FIVEM / IMGUI STYLE ]
local Keyser = {
    Colors = {
        Main          = Color3.fromRGB(19, 18, 23),     -- #131217 (Fundo da Sidebar e Topbar)
        Canvas        = Color3.fromRGB(14, 13, 18),     -- #0e0d12 (Fundo do Quadro/Canvas)
        SectionHeader = Color3.fromRGB(28, 27, 34),     -- #1c1b22 (Fundo do Título da Seção)
        SectionBg     = Color3.fromRGB(19, 18, 23),     -- #131217 (Fundo dos Cards das Seções)
        Divider       = Color3.fromRGB(35, 34, 40),     -- Linhas sutis
        Element       = Color3.fromRGB(28, 27, 33),     -- Fundo das caixas de input e binds
        Stroke        = Color3.fromRGB(40, 38, 45),     -- Bordas 
        Text          = Color3.fromRGB(240, 240, 245),  -- Texto claro
        TextDark      = Color3.fromRGB(120, 120, 130),  -- Texto apagado (inativo)
        Accent        = Color3.fromRGB(255, 255, 255),  -- Cor principal ativa
        Hover         = Color3.fromRGB(45, 43, 50),     -- Efeito Hover
        ValueBox      = Color3.fromRGB(16, 15, 20)      -- Fundo de valores de slider
    },
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold
}

--[ UTILS ]
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function MakeDraggable(dragObj, moveObj)
    local dragging = false
    local dragStart, startPos
    local inputChanged, inputEnded

    dragObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = moveObj.Position

            inputChanged = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local delta = input.Position - dragStart
                    moveObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)

            inputEnded = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    inputChanged:Disconnect()
                    inputEnded:Disconnect()
                end
            end)
        end
    end)
end

function Library:Window(Config)
    local WindowName = Config.Name or "Keyser"
    local WindowScale = Config.Scale or UDim2.new(0, 800, 0, 550)
    local ToggleKey = Config.Keybind or Enum.KeyCode.RightControl

    local Screen = Create("ScreenGui", {Name = "Keyser", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true})
    
    -- [ INTRO SEQUENCE ]
    local IntroFrame = Create("Frame", {
        Name = "Intro", Parent = Screen, BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        Position = UDim2.new(0.5, -175, 0.5, -100), Size = UDim2.new(0, 350, 0, 200),
        BorderSizePixel = 0, Active = true
    })
    Create("UICorner", {Parent = IntroFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = IntroFrame, Color = Keyser.Colors.Stroke, Thickness = 1})
    
    local IntroHolder = Create("Frame", {Parent = IntroFrame, BackgroundColor3 = Keyser.Colors.Main, Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true, BorderSizePixel = 0})
    Create("UICorner", {Parent = IntroHolder, CornerRadius = UDim.new(0, 6)})
    Create("UIGradient", {Parent = IntroHolder, Rotation = 30, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.5)})})
    
    local IntroTitle = Create("TextLabel", {Parent = IntroHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 0, 50), Font = Enum.Font.GothamBlack, Text = WindowName, TextColor3 = Color3.new(1,1,1), TextSize = 40, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1})
    local StatusText = Create("TextLabel", {Parent = IntroHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 110), Size = UDim2.new(1, -40, 0, 25), Font = Keyser.Font, Text = "Fetching API...", TextColor3 = Color3.new(1,1,1), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1})
    
    local ProgressBarBg = Create("Frame", {Parent = IntroHolder, BackgroundColor3 = Keyser.Colors.Canvas, Position = UDim2.new(0, 20, 0, 145), Size = UDim2.new(1, -40, 0, 4), BorderSizePixel = 0})
    Create("UICorner", {Parent = ProgressBarBg, CornerRadius = UDim.new(1, 0)})
    local ProgressBar = Create("Frame", {Parent = ProgressBarBg, BackgroundColor3 = Keyser.Colors.Accent, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0})
    Create("UICorner", {Parent = ProgressBar, CornerRadius = UDim.new(1, 0)})

    Tween(IntroTitle, {TextTransparency = 0}, 0.5)
    Tween(StatusText, {TextTransparency = 0}, 0.5)
    task.wait(0.5)
    
    local loadingSteps = {{0.2, "Bypassing Anticheat..."}, {0.5, "Loading Assets..."}, {0.8, "Building User Interface..."}, {1.0, "Ready!"}}
    for _, step in ipairs(loadingSteps) do
        StatusText.Text = step[2]
        Tween(ProgressBar, {Size = UDim2.new(step[1], 0, 1, 0)}, 0.4)
        task.wait(math.random(4, 8) / 10)
    end
    
    task.wait(0.3)
    Tween(IntroFrame, {BackgroundTransparency = 1}, 0.5)
    Tween(IntroHolder, {BackgroundTransparency = 1}, 0.5)
    for _, v in pairs(IntroFrame:GetDescendants()) do
        if v:IsA("TextLabel") then Tween(v, {TextTransparency = 1}, 0.5) end
        if v:IsA("Frame") then Tween(v, {BackgroundTransparency = 1}, 0.5) end
    end
    task.wait(0.5)
    IntroFrame:Destroy()

    -- [ MAIN WINDOW ]
    local MainFrame = Create("Frame", {
        Name = "Main", Parent = Screen, BackgroundColor3 = Keyser.Colors.Main,
        Position = UDim2.new(0.5, -WindowScale.X.Offset/2, 0.5, -WindowScale.Y.Offset/2), 
        Size = WindowScale, ClipsDescendants = true, BackgroundTransparency = 1
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})
    local MainStroke = Create("UIStroke", {Parent = MainFrame, Color = Keyser.Colors.Stroke, Thickness = 1, Transparency = 1})

    MakeDraggable(MainFrame, MainFrame)
    Tween(MainFrame, {BackgroundTransparency = 0}, 0.5)
    Tween(MainStroke, {Transparency = 0}, 0.5)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ToggleKey then
            Screen.Enabled = not Screen.Enabled
        end
    end)

    --[ LAYOUT STRUCTURE - FIVEM STYLE ]
    local Header = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 65), ZIndex = 2})
    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 65), Size = UDim2.new(0, 200, 1, -65), BorderSizePixel = 0})
    
    local LogoArea = Create("Frame", {Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0)})
    Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 14), Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBlack, Text = WindowName, TextColor3 = Color3.fromRGB(150, 150, 160), TextSize = 22})
    Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 14), Font = Keyser.Font, Text = "discord.gg/keyser", TextColor3 = Keyser.Colors.TextDark, TextSize = 11})

    local NavContainer = Create("Frame", {Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 200, 0, 0), Size = UDim2.new(1, -200, 1, 0)})
    
    local SideContainer = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)})
    Create("UIListLayout", {Parent = SideContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
    Create("UIPadding", {Parent = SideContainer, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})

    -- THE CANVAS (Quadro no meio)
    local PageContainer = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Keyser.Colors.Canvas,
        Position = UDim2.new(0, 200, 0, 65), Size = UDim2.new(1, -200, 1, -65), ClipsDescendants = true
    })
    
    -- Subtis linhas divisórias entre Canvas e as Barras
    Create("Frame", {Parent = PageContainer, BackgroundColor3 = Keyser.Colors.Stroke, Size = UDim2.new(1,0,0,1), BorderSizePixel = 0}) -- Top divider
    Create("Frame", {Parent = PageContainer, BackgroundColor3 = Keyser.Colors.Stroke, Size = UDim2.new(0,1,1,0), BorderSizePixel = 0}) -- Left divider

    local WinData = {ActiveSidebar = nil}
    local AllSidebarTabs = {}
    
    -- Function to Handle Floating "Option" Menus
    local function CreateOptionFlyout(AnchorButton)
        local Flyout = Create("Frame", {
            Parent = Screen, BackgroundColor3 = Keyser.Colors.SectionBg,
            Size = UDim2.new(0, 180, 0, 0), Position = UDim2.new(0,0,0,0),
            ClipsDescendants = true, ZIndex = 100, Visible = false
        })
        Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = Flyout, Color = Keyser.Colors.Stroke, Thickness = 1})
        
        local Scroll = Create("ScrollingFrame", {
            Parent = Flyout, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0,0,0,5),
            ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
        })
        local List = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        Create("UIPadding", {Parent = Scroll, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 5)})
        
        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10) end)
        
        local updater; local isOpen = false
        
        local function ToggleFlyout(state)
            isOpen = state
            if isOpen then
                Flyout.Visible = true
                local targetHeight = math.clamp(List.AbsoluteContentSize.Y + 20, 0, 250)
                Tween(Flyout, {Size = UDim2.new(0, 180, 0, targetHeight)})
                
                updater = RunService.RenderStepped:Connect(function()
                    Flyout.Position = UDim2.new(0, AnchorButton.AbsolutePosition.X + AnchorButton.AbsoluteSize.X + 10, 0, AnchorButton.AbsolutePosition.Y - (Flyout.AbsoluteSize.Y/2) + 10)
                end)
            else
                Tween(Flyout, {Size = UDim2.new(0, 180, 0, 0)})
                task.delay(0.25, function() if not isOpen then Flyout.Visible = false end end)
                if updater then updater:Disconnect(); updater = nil end
            end
        end
        
        AnchorButton.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)
        
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mx, my = input.Position.X, input.Position.Y
                local fx, fy = Flyout.AbsolutePosition.X, Flyout.AbsolutePosition.Y
                local bx, by = AnchorButton.AbsolutePosition.X, AnchorButton.AbsolutePosition.Y
                
                local inFlyout = mx >= fx and mx <= fx + Flyout.AbsoluteSize.X and my >= fy and my <= fy + Flyout.AbsoluteSize.Y
                local inButton = mx >= bx and mx <= bx + AnchorButton.AbsoluteSize.X and my >= by and my <= by + AnchorButton.AbsoluteSize.Y
                
                if isOpen and not inFlyout and not inButton then ToggleFlyout(false) end
            end
        end)
        return Scroll
    end

    -- Element Builder Factory (Recursive for Sections and Options)
    local function BuildElements(TargetParent)
        local Elements = {}
        
        function Elements:Keybind(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local BindBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Keyser.Colors.Element, Position = UDim2.new(1, -70, 0.5, -11), Size = UDim2.new(0, 70, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = BindBtn, Color = Keyser.Colors.Stroke, Thickness = 1})
            local BindText = Create("TextLabel", {Parent = BindBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = Cfg.Default and Cfg.Default.Name or "None", TextColor3 = Keyser.Colors.Text, TextSize = 11})
            
            local currentKey = Cfg.Default
            local binding = false
            
            BindBtn.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true; BindText.Text = "..."
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            currentKey = nil; BindText.Text = "None"
                        else
                            currentKey = input.KeyCode; BindText.Text = input.KeyCode.Name
                        end
                        binding = false; if Cfg.Callback then pcall(Cfg.Callback, currentKey) end
                        connection:Disconnect()
                    end
                end)
            end)
        end
        
        function Elements:Toggle(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local CheckBg = Create("TextButton", {Parent = Frame, BackgroundColor3 = Keyser.Colors.Element, Position = UDim2.new(1, -22, 0.5, -11), Size = UDim2.new(0, 22, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = CheckBg, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = CheckBg, Color = Keyser.Colors.Stroke, Thickness = 1})
            local CheckIcon = Create("ImageLabel", {Parent = CheckBg, BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 4), Size = UDim2.new(1, -8, 1, -8), Image = "rbxassetid://10709790644", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 1})
            
            local rightOffset = 30
            local OptionBtn
            if Cfg.Option then
                OptionBtn = Create("ImageButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -(rightOffset + 16), 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://10734950309", ImageColor3 = Keyser.Colors.TextDark, ImageTransparency = 0.5})
                OptionBtn.MouseEnter:Connect(function() Tween(OptionBtn, {ImageTransparency = 0}) end)
                OptionBtn.MouseLeave:Connect(function() Tween(OptionBtn, {ImageTransparency = 0.5}) end)
                rightOffset = rightOffset + 22
            end

            local boundKey = Cfg.Keybind
            if boundKey ~= nil then
                local BindBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Keyser.Colors.Main, Position = UDim2.new(1, -(rightOffset + 40), 0.5, -10), Size = UDim2.new(0, 40, 0, 20), Text = "", AutoButtonColor = false})
                Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = BindBtn, Color = Keyser.Colors.Stroke, Thickness = 1})
                local BindText = Create("TextLabel", {Parent = BindBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = typeof(boundKey)=="EnumItem" and boundKey.Name or "None", TextColor3 = Keyser.Colors.TextDark, TextSize = 10})
                
                local binding = false
                BindBtn.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true; BindText.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then boundKey = nil; BindText.Text = "None"
                            else boundKey = input.KeyCode; BindText.Text = boundKey.Name end
                            binding = false; conn:Disconnect()
                        end
                    end)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == boundKey and boundKey ~= nil then
                        CheckBg.BackgroundColor3 = Keyser.Colors.Hover
                        task.delay(0.1, function()
                            local t = not (CheckIcon.ImageTransparency == 0)
                            if t then Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Accent}); Tween(CheckIcon, {ImageTransparency = 0}) else Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Element}); Tween(CheckIcon, {ImageTransparency = 1}) end
                            if Cfg.Callback then pcall(Cfg.Callback, t) end
                        end)
                    end
                end)
            end

            local Toggled = Cfg.Default or false
            local function Update()
                if Toggled then 
                    Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Accent})
                    Tween(CheckIcon, {ImageTransparency = 0}) 
                else 
                    Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Element})
                    Tween(CheckIcon, {ImageTransparency = 1}) 
                end
                if Cfg.Callback then pcall(Cfg.Callback, Toggled) end 
            end
            
            CheckBg.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end); Update()
            
            local ReturnAPI = {}
            if Cfg.Option then ReturnAPI.Option = BuildElements(CreateOptionFlyout(OptionBtn)) end
            return ReturnAPI
        end

        function Elements:Slider(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local ValBox = Create("Frame", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -40, 0, 0), Size = UDim2.new(0, 40, 0, 20)})
            local ValLabel = Create("TextLabel", {Parent = ValBox, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = "0.00", TextColor3 = Keyser.Colors.TextDark, TextSize = 11})
            
            local Rail = Create("Frame", {Parent = Frame, BackgroundColor3 = Keyser.Colors.Element, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 4)}); Create("UICorner", {Parent = Rail, CornerRadius = UDim.new(1, 0)})
            local Fill = Create("Frame", {Parent = Rail, BackgroundColor3 = Keyser.Colors.TextDark, Size = UDim2.new(0, 0, 1, 0)}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            local Knob = Create("Frame", {Parent = Fill, BackgroundColor3 = Keyser.Colors.TextDark, Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0)}); Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
            
            local Trigger = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,20), Size = UDim2.new(1,0,0,25), Text = ""})
            
            local OptionBtn
            if Cfg.Option then
                OptionBtn = Create("ImageButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -65, 0, 2), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://10734950309", ImageColor3 = Keyser.Colors.TextDark, ImageTransparency = 0.5})
            end

            local Min, Max, Val = Cfg.Min or 0, Cfg.Max or 100, Cfg.Default or Min
            local function Set(v) 
                Val = math.clamp(v, Min, Max); local P = (Val - Min) / (Max - Min); 
                Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}); 
                ValLabel.Text = string.format("%."..(Cfg.Decimals or 0).."f", Val); 
                if Cfg.Callback then pcall(Cfg.Callback, Val) end 
            end
            
            Trigger.InputBegan:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    local Dragging = true; local x = math.clamp((i.Position.X - Rail.AbsolutePosition.X)/Rail.AbsoluteSize.X,0,1); Set(Min + (Max-Min)*x); 
                    local changed, ended; 
                    changed = UserInputService.InputChanged:Connect(function(i2) 
                        if Dragging and i2.UserInputType == Enum.UserInputType.MouseMovement then Set(Min + (Max-Min)*math.clamp((i2.Position.X - Rail.AbsolutePosition.X)/Rail.AbsoluteSize.X,0,1)) end 
                    end); 
                    ended = UserInputService.InputEnded:Connect(function(i3) 
                        if i3.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false; changed:Disconnect(); ended:Disconnect() end 
                    end) 
                end 
            end); Set(Val)

            local ReturnAPI = {}
            if Cfg.Option then ReturnAPI.Option = BuildElements(CreateOptionFlyout(OptionBtn)) end
            return ReturnAPI
        end
        
        function Elements:ColorPicker(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local ColorBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Cfg.Default or Color3.new(1,1,1), Position = UDim2.new(1, -30, 0.5, -10), Size = UDim2.new(0, 30, 0, 20), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = ColorBtn, Color = Keyser.Colors.Stroke})
            
            local Flyout = Create("Frame", {Parent = Screen, BackgroundColor3 = Keyser.Colors.SectionBg, Size = UDim2.new(0, 180, 0, 160), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 110, Visible = false})
            Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = Keyser.Colors.Stroke, Thickness = 1})

            local SatValMap = Create("ImageButton", {Parent = Flyout, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 140, 0, 110), BackgroundColor3 = ColorBtn.BackgroundColor3, AutoButtonColor = false}); Create("UICorner", {Parent = SatValMap, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = SatValMap, Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})})
            local VMap = Create("Frame", {Parent = SatValMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0)}); Create("UICorner", {Parent = VMap, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = VMap, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})})
            local CursorSV = Create("Frame", {Parent = SatValMap, Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(1, -2, 0, -2), BackgroundColor3 = Color3.new(1,1,1)}); Create("UICorner", {Parent = CursorSV, CornerRadius = UDim.new(1,0)})

            local HueRail = Create("ImageButton", {Parent = Flyout, Position = UDim2.new(0, 155, 0, 10), Size = UDim2.new(0, 15, 0, 110), BackgroundColor3 = Color3.new(1,1,1), AutoButtonColor = false}); Create("UICorner", {Parent = HueRail, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = HueRail, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
            local CursorH = Create("Frame", {Parent = HueRail, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.new(0,0,0)})
            
            local HexBox = Create("TextBox", {Parent = Flyout, Position = UDim2.new(0, 10, 0, 130), Size = UDim2.new(0, 160, 0, 20), BackgroundColor3 = Keyser.Colors.ValueBox, Font = Keyser.Font, Text = "#FFFFFF", TextColor3 = Keyser.Colors.Text, TextSize = 12})
            Create("UICorner", {Parent = HexBox, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = HexBox, Color = Keyser.Colors.Stroke})

            local Hue, Sat, Val = ColorBtn.BackgroundColor3:ToHSV(); local updater, isOpen = nil, false
            local function UpdateColor()
                local newColor = Color3.fromHSV(Hue, Sat, Val); ColorBtn.BackgroundColor3 = newColor; SatValMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1); HexBox.Text = "#" .. newColor:ToHex():upper()
                if Cfg.Callback then pcall(Cfg.Callback, newColor) end
            end

            local function ToggleFlyout(state)
                isOpen = state; Flyout.Visible = state
                if state then updater = RunService.RenderStepped:Connect(function() Flyout.Position = UDim2.new(0, ColorBtn.AbsolutePosition.X - 150, 0, ColorBtn.AbsolutePosition.Y + 25) end)
                else if updater then updater:Disconnect(); updater = nil end end
            end
            ColorBtn.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)

            local function HandleDrag(btn, type)
                local dragging = false
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true; local changed, ended
                        local function upd(inp)
                            local y = math.clamp((inp.Position.Y - btn.AbsolutePosition.Y)/btn.AbsoluteSize.Y, 0, 1)
                            if type == "Hue" then Hue = 1 - y; CursorH.Position = UDim2.new(0,0,y,0) else local x = math.clamp((inp.Position.X - btn.AbsolutePosition.X)/btn.AbsoluteSize.X, 0, 1); Sat = x; Val = 1 - y; CursorSV.Position = UDim2.new(x, -2, y, -2) end
                            UpdateColor()
                        end; upd(input)
                        changed = UserInputService.InputChanged:Connect(function(inp) if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then upd(inp) end end)
                        ended = UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; changed:Disconnect(); ended:Disconnect() end end)
                    end
                end)
            end
            HandleDrag(HueRail, "Hue"); HandleDrag(SatValMap, "SV")
            
            UserInputService.InputBegan:Connect(function(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mx, my, fx, fy, bx, by = input.Position.X, input.Position.Y, Flyout.AbsolutePosition.X, Flyout.AbsolutePosition.Y, ColorBtn.AbsolutePosition.X, ColorBtn.AbsolutePosition.Y
                    if not (mx >= fx and mx <= fx + Flyout.AbsoluteSize.X and my >= fy and my <= fy + Flyout.AbsoluteSize.Y) and not (mx >= bx and mx <= bx + ColorBtn.AbsoluteSize.X and my >= by and my <= by + ColorBtn.AbsoluteSize.Y) then ToggleFlyout(false) end
                end
            end); UpdateColor()
        end

        function Elements:Input(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 55)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = Keyser.Colors.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local InputContainer = Create("Frame", {Parent = Frame, BackgroundColor3 = Keyser.Colors.ValueBox, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30)}); Create("UICorner", {Parent = InputContainer, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = InputContainer, Color = Keyser.Colors.Stroke, Thickness = 1})
            local Box = Create("TextBox", {Parent = InputContainer, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), Font = Keyser.Font, Text = "", PlaceholderText = Cfg.Placeholder or "Search...", TextColor3 = Keyser.Colors.Text, PlaceholderColor3 = Keyser.Colors.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            Box:GetPropertyChangedSignal("Text"):Connect(function() if Cfg.Callback then pcall(Cfg.Callback, Box.Text) end end)
        end

        function Elements:List(Cfg)
            local ListObj = {}
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Cfg.Height or 150)})
            local Scroll = Create("ScrollingFrame", {Parent = Frame, BackgroundColor3 = Keyser.Colors.ValueBox, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = Keyser.Colors.Stroke, CanvasSize = UDim2.new(0,0,0,0)}); Create("UICorner", {Parent = Scroll, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = Scroll, Color = Keyser.Colors.Stroke, Thickness = 1})
            local ListLayout = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder}); Create("UIPadding", {Parent = Scroll, PaddingLeft = UDim.new(0, 5)})
            local Items = {}; ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y) end)
            for _, v in pairs(Cfg.Items) do
                local Btn = Create("TextButton", {Parent = Scroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Font = Keyser.Font, Text = "  "..v, TextColor3 = Keyser.Colors.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                Btn.MouseButton1Click:Connect(function() for _, b in pairs(Items) do b.Obj.TextColor3 = Keyser.Colors.TextDark end; Btn.TextColor3 = Keyser.Colors.Text; if Cfg.Callback then pcall(Cfg.Callback, v) end end)
                table.insert(Items, {Obj = Btn, Val = v})
            end
            function ListObj:Filter(txt) for _, item in pairs(Items) do item.Obj.Visible = string.find(string.lower(item.Val), string.lower(txt or "")) ~= nil end end
            return ListObj
        end

        function Elements:Button(Cfg)
            local Btn = Create("TextButton", {Parent = TargetParent, BackgroundColor3 = Keyser.Colors.Element, Size = UDim2.new(1, 0, 0, 32), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 12, AutoButtonColor = false}); Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = Btn, Color = Keyser.Colors.Stroke, Thickness = 1})
            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Keyser.Colors.Hover, TextColor3 = Keyser.Colors.Text}) end); Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Keyser.Colors.Element, TextColor3 = Keyser.Colors.TextDark}) end)
            Btn.MouseButton1Click:Connect(function() if Cfg.Callback then pcall(Cfg.Callback) end end)
        end
        
        return Elements
    end

    --[ 1. TAB (SIDEBAR BUTTON) ]
    function WinData:Tab(Config)
        local TabObj = {}
        local TopButtonsFrame = Create("Frame", {Parent = NavContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
        Create("UIListLayout", {Parent = TopButtonsFrame, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 15)})

        local SideBtn = Create("TextButton", {Parent = SideContainer, BackgroundColor3 = Keyser.Colors.Element, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Text = "", AutoButtonColor = false})
        Create("UICorner", {Parent = SideBtn, CornerRadius = UDim.new(0, 4)})

        local Icon = Create("ImageLabel", {Parent = SideBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), Image = Config.Icon or "", ImageColor3 = Keyser.Colors.TextDark})
        local Label = Create("TextLabel", {Parent = SideBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -40, 1, 0), Font = Keyser.FontBold, Text = Config.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        
        TabObj.TopTabs = {}; TabObj.ActiveTop = nil

        local function ActivateSidebar()
            if WinData.ActiveSidebar == TabObj then return end
            if WinData.ActiveSidebar then
                Tween(WinData.ActiveSidebar.Btn, {BackgroundTransparency = 1})
                Tween(WinData.ActiveSidebar.Label, {TextColor3 = Keyser.Colors.TextDark})
                Tween(WinData.ActiveSidebar.Icon, {ImageColor3 = Keyser.Colors.TextDark})
                WinData.ActiveSidebar.TopButtonsFrame.Visible = false
                if WinData.ActiveSidebar.ActiveTop then WinData.ActiveSidebar.ActiveTop.Page.Visible = false end
            end
            WinData.ActiveSidebar = TabObj
            Tween(SideBtn, {BackgroundTransparency = 0}) 
            Tween(Label, {TextColor3 = Keyser.Colors.Text})
            Tween(Icon, {ImageColor3 = Keyser.Colors.Text})
            TopButtonsFrame.Visible = true
            if TabObj.ActiveTop then TabObj.ActiveTop:Activate() elseif #TabObj.TopTabs > 0 then TabObj.TopTabs[1]:Activate() end
        end

        SideBtn.MouseButton1Click:Connect(ActivateSidebar)
        TabObj.Activate = ActivateSidebar; TabObj.Btn = SideBtn; TabObj.Label = Label; TabObj.Icon = Icon; TabObj.TopButtonsFrame = TopButtonsFrame

        --[ 2. PAGE (TOPBAR BUTTON) ]
        function TabObj:Page(Name)
            local PageObj = {}
            local TopBtn = Create("TextButton", {Parent = TopButtonsFrame, BackgroundColor3 = Keyser.Colors.Element, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, -20), Font = Keyser.FontBold, Text = Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, AutomaticSize = Enum.AutomaticSize.X})
            Create("UICorner", {Parent = TopBtn, CornerRadius = UDim.new(0, 4)}); Create("UIPadding", {Parent = TopBtn, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)})

            local PageFrame = Create("Frame", {Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
            Create("UIPadding", {Parent = PageFrame, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})

            local LeftCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.485, 0, 1, 0)})
            local RightCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.485, 0, 1, 0), Position = UDim2.new(0.515, 0, 0, 0)})
            Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})
            Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})

            function PageObj:Activate()
                if TabObj.ActiveTop and TabObj.ActiveTop ~= PageObj then
                    Tween(TabObj.ActiveTop.Btn, {BackgroundTransparency = 1, TextColor3 = Keyser.Colors.TextDark})
                    TabObj.ActiveTop.Page.Visible = false
                end
                TabObj.ActiveTop = PageObj
                Tween(TopBtn, {BackgroundTransparency = 0, TextColor3 = Keyser.Colors.Text})
                PageFrame.Visible = true
            end

            TopBtn.MouseButton1Click:Connect(function() PageObj:Activate() end)
            PageObj.Btn = TopBtn; PageObj.Page = PageFrame
            table.insert(TabObj.TopTabs, PageObj)

            --[ 3. SECTION (GROUPBOX) - FIVEM STYLE (Header differs from body) ]
            local SectionLib = {}
            function SectionLib:Section(SecConfig)
                local Col = (SecConfig.Side == "Right" and RightCol) or LeftCol
                local fixHeight = SecConfig.Height
                
                -- The Card Base (Floating inside Canvas)
                local Groupbox = Create("Frame", {Parent = Col, BackgroundColor3 = Keyser.Colors.SectionBg, Size = UDim2.new(1, 0, 0, fixHeight or 0), AutomaticSize = fixHeight and Enum.AutomaticSize.None or Enum.AutomaticSize.Y})
                Create("UICorner", {Parent = Groupbox, CornerRadius = UDim.new(0, 6)})
                Create("UIStroke", {Parent = Groupbox, Color = Keyser.Colors.Stroke, Thickness = 1})

                -- Header Frame (#1c1b22)
                local HeaderFrame = Create("Frame", {Parent = Groupbox, BackgroundColor3 = Keyser.Colors.SectionHeader, Size = UDim2.new(1, 0, 0, 38), BorderSizePixel = 0})
                Create("UICorner", {Parent = HeaderFrame, CornerRadius = UDim.new(0, 6)})
                -- Fill bottom corners to merge with body
                Create("Frame", {Parent = HeaderFrame, BackgroundColor3 = Keyser.Colors.SectionHeader, Position = UDim2.new(0,0,1,-6), Size = UDim2.new(1,0,0,6), BorderSizePixel = 0}) 

                Create("TextLabel", {Parent = HeaderFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -15, 1, 0), Font = Keyser.FontBold, Text = SecConfig.Name, TextColor3 = Keyser.Colors.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                
                -- Content Container (Starts exactly after the 38px header)
                local ContentFrame
                if fixHeight then
                    ContentFrame = Create("ScrollingFrame", {Parent = Groupbox, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 1, -38), ScrollBarThickness = 2, ScrollBarImageColor3 = Keyser.Colors.Stroke, CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel = 0})
                else
                    ContentFrame = Create("Frame", {Parent = Groupbox, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
                end
                
                -- Tighter Paddings inside the Section
                local CList = Create("UIListLayout", {Parent = ContentFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
                Create("UIPadding", {Parent = ContentFrame, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10)})
                
                if fixHeight then CList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() ContentFrame.CanvasSize = UDim2.new(0, 0, 0, CList.AbsoluteContentSize.Y + 20) end) end
                
                return BuildElements(ContentFrame)
            end
            return SectionLib
        end
        
        table.insert(AllSidebarTabs, TabObj)
        return TabObj
    end
    
    task.defer(function() if not WinData.ActiveSidebar and #AllSidebarTabs > 0 then AllSidebarTabs[1]:Activate() end end)
    return WinData
end

return Library
