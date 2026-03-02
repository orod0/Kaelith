--[[
    KEYSER UI V9.0 - FIVEM & IMGUI EDITION (OPTIMIZED by AI)
    Structure: Intro -> Sidebar/Topbar (#131217) -> Content Canvas (#0e0d12) -> Section Cards (#131217 / Header #1c1b22)
    
    [NEW V9.0 FEATURES]
    - Dynamic Theme Manager (Real-time updates via Library:SetThemeColor).
    - Global Search Engine (Filters Tabs, Sections, and Elements).
    - Tooltip System (Hover on any element).
    - Notification System (Toasts - Library:Notify).
    - Pro Widgets: Paragraph, Modern Dropdown, PlayerList, Pro Bind (Combinations), Line Plots (FPS/Ping Graphs).
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
        Main          = Color3.fromRGB(19, 18, 23),
        Canvas        = Color3.fromRGB(14, 13, 18),
        SectionHeader = Color3.fromRGB(28, 27, 34),
        SectionBg     = Color3.fromRGB(19, 18, 23),
        Divider       = Color3.fromRGB(35, 34, 40),
        Element       = Color3.fromRGB(28, 27, 33),
        Stroke        = Color3.fromRGB(40, 38, 45),
        Text          = Color3.fromRGB(240, 240, 245),
        TextDark      = Color3.fromRGB(120, 120, 130),
        Accent        = Color3.fromRGB(255, 255, 255),
        Hover         = Color3.fromRGB(45, 43, 50),
        ValueBox      = Color3.fromRGB(16, 15, 20)
    },
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold
}
Library.Keyser = Keyser

--[ THEME MANAGER SYSTEM ]
local ThemeRegistry = setmetatable({}, {__mode = "k"})

local function Theme(key) return {__isTheme = true, key = key} end

local function BindTheme(obj, prop, key)
    if not ThemeRegistry[obj] then ThemeRegistry[obj] = {} end
    ThemeRegistry[obj][prop] = key
end

function Library:SetThemeColor(key, color)
    if Keyser.Colors[key] then
        Keyser.Colors[key] = color
        for obj, props in pairs(ThemeRegistry) do
            for prop, cKey in pairs(props) do
                if cKey == key then pcall(function() obj[prop] = color end) end
            end
        end
    end
end

--[ UTILS ]
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do 
        if type(v) == "table" and v.__isTheme then
            obj[k] = Keyser.Colors[v.key]
            BindTheme(obj, k, v.key)
        else
            obj[k] = v 
        end
    end
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
            dragging = true; dragStart = input.Position; startPos = moveObj.Position

            inputChanged = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local delta = input.Position - dragStart
                    moveObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            inputEnded = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false; inputChanged:Disconnect(); inputEnded:Disconnect()
                end
            end)
        end
    end)
end

--[ NOTIFICATION SYSTEM ]
function Library:Notify(Cfg)
    if not Library.NotifContainer then
        local sg = CoreGui:FindFirstChild("Keyser") or Instance.new("ScreenGui", CoreGui)
        sg.Name = "Keyser"
        Library.NotifContainer = Create("Frame", {Parent = sg, BackgroundTransparency = 1, Position = UDim2.new(1, -320, 1, -20), Size = UDim2.new(0, 300, 1, 0), AnchorPoint = Vector2.new(0, 1)})
        Create("UIListLayout", {Parent = Library.NotifContainer, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 10)})
    end
    
    local Notif = Create("Frame", {Parent = Library.NotifContainer, BackgroundColor3 = Theme("SectionBg"), Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(1, 350, 0, 0), ClipsDescendants = true})
    Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Notif, Color = Theme("Stroke"), Thickness = 1})
    
    Create("TextLabel", {Parent = Notif, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,5), Size = UDim2.new(1,-20,0,20), Font = Keyser.FontBold, Text = Cfg.Title or "Notification", TextColor3 = Theme("Text"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Notif, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,25), Size = UDim2.new(1,-20,0,25), Font = Keyser.Font, Text = Cfg.Content or "", TextColor3 = Theme("TextDark"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
    
    local BarBg = Create("Frame", {Parent = Notif, BackgroundColor3 = Theme("Element"), Position = UDim2.new(0,0,1,-3), Size = UDim2.new(1,0,0,3), BorderSizePixel = 0})
    local Bar = Create("Frame", {Parent = BarBg, BackgroundColor3 = Theme("Accent"), Size = UDim2.new(0,0,1,0), BorderSizePixel = 0})
    
    Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
    local dur = Cfg.Duration or 3
    Tween(Bar, {Size = UDim2.new(1, 0, 1, 0)}, dur)
    
    task.delay(dur, function()
        Tween(Notif, {Position = UDim2.new(1, 350, 0, 0)}, 0.4)
        task.wait(0.4)
        Notif:Destroy()
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
        Position = UDim2.new(0.5, -175, 0.5, -100), Size = UDim2.new(0, 350, 0, 200), BorderSizePixel = 0
    })
    Create("UICorner", {Parent = IntroFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = IntroFrame, Color = Theme("Stroke"), Thickness = 1})
    
    local IntroHolder = Create("Frame", {Parent = IntroFrame, BackgroundColor3 = Theme("Main"), Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true})
    Create("UICorner", {Parent = IntroHolder, CornerRadius = UDim.new(0, 6)})
    Create("UIGradient", {Parent = IntroHolder, Rotation = 30, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.5)})})
    
    local IntroTitle = Create("TextLabel", {Parent = IntroHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 0, 50), Font = Enum.Font.GothamBlack, Text = WindowName, TextColor3 = Color3.new(1,1,1), TextSize = 40, TextTransparency = 1})
    local StatusText = Create("TextLabel", {Parent = IntroHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 110), Size = UDim2.new(1, -40, 0, 25), Font = Keyser.Font, Text = "Fetching API...", TextColor3 = Color3.new(1,1,1), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1})
    
    local ProgressBarBg = Create("Frame", {Parent = IntroHolder, BackgroundColor3 = Theme("Canvas"), Position = UDim2.new(0, 20, 0, 145), Size = UDim2.new(1, -40, 0, 4)})
    Create("UICorner", {Parent = ProgressBarBg, CornerRadius = UDim.new(1, 0)})
    local ProgressBar = Create("Frame", {Parent = ProgressBarBg, BackgroundColor3 = Theme("Accent"), Size = UDim2.new(0, 0, 1, 0)})
    Create("UICorner", {Parent = ProgressBar, CornerRadius = UDim.new(1, 0)})

    Tween(IntroTitle, {TextTransparency = 0}, 0.5); Tween(StatusText, {TextTransparency = 0}, 0.5)
    task.wait(0.5)
    
    local loadingSteps = {{0.2, "Bypassing Anticheat..."}, {0.5, "Loading Assets..."}, {0.8, "Building User Interface..."}, {1.0, "Ready!"}}
    for _, step in ipairs(loadingSteps) do
        StatusText.Text = step[2]
        Tween(ProgressBar, {Size = UDim2.new(step[1], 0, 1, 0)}, 0.4)
        task.wait(math.random(3, 6) / 10)
    end
    
    task.wait(0.3)
    Tween(IntroFrame, {BackgroundTransparency = 1}, 0.5); Tween(IntroHolder, {BackgroundTransparency = 1}, 0.5)
    for _, v in pairs(IntroFrame:GetDescendants()) do
        if v:IsA("TextLabel") then Tween(v, {TextTransparency = 1}, 0.5) elseif v:IsA("Frame") then Tween(v, {BackgroundTransparency = 1}, 0.5) end
    end
    task.wait(0.5); IntroFrame:Destroy()

    -- [ MAIN WINDOW ]
    local MainFrame = Create("Frame", {
        Name = "Main", Parent = Screen, BackgroundColor3 = Theme("Main"),
        Position = UDim2.new(0.5, -WindowScale.X.Offset/2, 0.5, -WindowScale.Y.Offset/2), Size = WindowScale, ClipsDescendants = true, BackgroundTransparency = 1
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})
    local MainStroke = Create("UIStroke", {Parent = MainFrame, Color = Theme("Stroke"), Thickness = 1, Transparency = 1})

    MakeDraggable(MainFrame, MainFrame)
    Tween(MainFrame, {BackgroundTransparency = 0}, 0.5); Tween(MainStroke, {Transparency = 0}, 0.5)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ToggleKey then Screen.Enabled = not Screen.Enabled end
    end)

    -- [ TOOLTIP SYSTEM ]
    local TooltipFrame = Create("Frame", {Parent = Screen, BackgroundColor3 = Theme("SectionBg"), Size = UDim2.new(0,0,0,0), AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 1000, Visible = false})
    Create("UICorner", {Parent = TooltipFrame, CornerRadius = UDim.new(0,4)}); Create("UIStroke", {Parent = TooltipFrame, Color = Theme("Stroke"), Thickness = 1})
    Create("UIPadding", {Parent = TooltipFrame, PaddingTop = UDim.new(0,5), PaddingBottom = UDim.new(0,5), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)})
    local TooltipText = Create("TextLabel", {Parent = TooltipFrame, BackgroundTransparency = 1, Font = Keyser.Font, Text = "", TextColor3 = Theme("Text"), TextSize = 12, AutomaticSize = Enum.AutomaticSize.XY})
    
    local currentTooltipObj, tooltipConn = nil, nil
    local function AttachTooltip(obj, text)
        if not text or text == "" then return end
        obj.MouseEnter:Connect(function()
            currentTooltipObj = obj
            task.delay(0.5, function()
                if currentTooltipObj == obj then
                    TooltipText.Text = text; TooltipFrame.Visible = true
                    tooltipConn = RunService.RenderStepped:Connect(function()
                        local pos = UserInputService:GetMouseLocation()
                        TooltipFrame.Position = UDim2.new(0, pos.X + 15, 0, pos.Y - 20)
                    end)
                end
            end)
        end)
        obj.MouseLeave:Connect(function()
            if currentTooltipObj == obj then
                currentTooltipObj = nil; TooltipFrame.Visible = false
                if tooltipConn then tooltipConn:Disconnect(); tooltipConn = nil end
            end
        end)
    end

    --[ LAYOUT STRUCTURE ]
    local Header = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 65), ZIndex = 2})
    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 65), Size = UDim2.new(0, 200, 1, -65)})
    
    local LogoArea = Create("Frame", {Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0)})
    Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 14), Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBlack, Text = WindowName, TextColor3 = Color3.fromRGB(150, 150, 160), TextSize = 22})
    Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 14), Font = Keyser.Font, Text = "discord.gg/keyser", TextColor3 = Theme("TextDark"), TextSize = 11})

    local NavContainer = Create("Frame", {Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 200, 0, 0), Size = UDim2.new(1, -200, 1, 0)})
    
    local PageContainer = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Theme("Canvas"), Position = UDim2.new(0, 200, 0, 65), Size = UDim2.new(1, -200, 1, -65), ClipsDescendants = true})
    Create("Frame", {Parent = PageContainer, BackgroundColor3 = Theme("Stroke"), Size = UDim2.new(1,0,0,1), BorderSizePixel = 0}) 
    Create("Frame", {Parent = PageContainer, BackgroundColor3 = Theme("Stroke"), Size = UDim2.new(0,1,1,0), BorderSizePixel = 0}) 

    local WinData = {ActiveSidebar = nil, SearchRegistry = {Tabs={}, Pages={}, Sections={}, Elements={}}}
    local AllSidebarTabs = {}

    --[ GLOBAL SEARCH LOGIC ]
    local SearchContainer = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
    local SearchBox = Create("TextBox", {Parent = SearchContainer, BackgroundColor3 = Theme("Element"), Position = UDim2.new(0, 15, 0, 5), Size = UDim2.new(1, -30, 0, 30), Font = Keyser.Font, PlaceholderText = "Search...", Text = "", TextColor3 = Theme("Text"), TextSize = 12, ClearTextOnFocus = false})
    Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = SearchBox, Color = Theme("Stroke"), Thickness = 1})
    
    local SideContainer = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,45), Size = UDim2.new(1, 0, 1, -45), ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)})
    Create("UIListLayout", {Parent = SideContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
    Create("UIPadding", {Parent = SideContainer, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = SearchBox.Text:lower()
        if text == "" then
            for _, el in ipairs(WinData.SearchRegistry.Elements) do el.Frame.Visible = true end
            for sec, _ in pairs(WinData.SearchRegistry.Sections) do sec.Visible = true end
            for pg, data in pairs(WinData.SearchRegistry.Pages) do data.Btn.Visible = true end
            for tab, data in pairs(WinData.SearchRegistry.Tabs) do data.Btn.Visible = true end
            return
        end

        local matchedTabs, matchedPages, matchedSections = {}, {}, {}

        for _, el in ipairs(WinData.SearchRegistry.Elements) do
            if string.find(el.Name, text) then
                el.Frame.Visible = true
                if el.Section then matchedSections[el.Section] = true end
                if el.Page then matchedPages[el.Page] = true end
                if el.Tab then matchedTabs[el.Tab] = true end
            else el.Frame.Visible = false end
        end

        for sec, data in pairs(WinData.SearchRegistry.Sections) do
            if string.find(data.Name:lower(), text) then
                matchedSections[sec] = true
                if data.Page then matchedPages[data.Page] = true end
                if data.Tab then matchedTabs[data.Tab] = true end
                sec.Visible = true
                for _, el in ipairs(WinData.SearchRegistry.Elements) do
                    if el.Section == sec then el.Frame.Visible = true end
                end
            else sec.Visible = matchedSections[sec] == true end
        end

        for pg, data in pairs(WinData.SearchRegistry.Pages) do data.Btn.Visible = matchedPages[pg] == true end
        for tab, data in pairs(WinData.SearchRegistry.Tabs) do data.Btn.Visible = matchedTabs[tab] == true end
    end)
    
    local function CreateOptionFlyout(AnchorButton)
        local Flyout = Create("Frame", {Parent = Screen, BackgroundColor3 = Theme("SectionBg"), Size = UDim2.new(0, 180, 0, 0), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 100, Visible = false})
        Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = Theme("Stroke"), Thickness = 1})
        
        local Scroll = Create("ScrollingFrame", {Parent = Flyout, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0,0,0,5), ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)})
        local List = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        Create("UIPadding", {Parent = Scroll, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 5)})
        
        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10) end)
        
        local updater, isOpen = nil, false
        local function ToggleFlyout(state)
            isOpen = state
            if isOpen then
                Flyout.Visible = true
                Tween(Flyout, {Size = UDim2.new(0, 180, 0, math.clamp(List.AbsoluteContentSize.Y + 20, 0, 250))})
                updater = RunService.RenderStepped:Connect(function() Flyout.Position = UDim2.new(0, AnchorButton.AbsolutePosition.X + AnchorButton.AbsoluteSize.X + 10, 0, AnchorButton.AbsolutePosition.Y - (Flyout.AbsoluteSize.Y/2) + 10) end)
            else
                Tween(Flyout, {Size = UDim2.new(0, 180, 0, 0)})
                task.delay(0.25, function() if not isOpen then Flyout.Visible = false end end)
                if updater then updater:Disconnect(); updater = nil end
            end
        end
        
        AnchorButton.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                local mx, my = input.Position.X, input.Position.Y
                local fx, fy = Flyout.AbsolutePosition.X, Flyout.AbsolutePosition.Y
                local bx, by = AnchorButton.AbsolutePosition.X, AnchorButton.AbsolutePosition.Y
                if not (mx >= fx and mx <= fx + Flyout.AbsoluteSize.X and my >= fy and my <= fy + Flyout.AbsoluteSize.Y) and not (mx >= bx and mx <= bx + AnchorButton.AbsoluteSize.X and my >= by and my <= by + AnchorButton.AbsoluteSize.Y) then ToggleFlyout(false) end
            end
        end)
        return Scroll
    end

    -- Element Builder Factory
    local function BuildElements(TargetParent, Context)
        local Elements = {}
        local function Register(cfgName, frame)
            if Context then table.insert(WinData.SearchRegistry.Elements, {Name = (cfgName or ""):lower(), Frame = frame, Tab = Context.Tab, Page = Context.Page, Section = Context.Section}) end
        end
        
        function Elements:Bind(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Register(Cfg.Name, Frame); AttachTooltip(Frame, Cfg.Description)
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Theme("TextDark"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local BindBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Theme("Element"), Position = UDim2.new(1, -90, 0.5, -11), Size = UDim2.new(0, 90, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = BindBtn, Color = Theme("Stroke"), Thickness = 1})
            local BindText = Create("TextLabel", {Parent = BindBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = "None", TextColor3 = Theme("Text"), TextSize = 11})
            
            local currentKeys = type(Cfg.Default) == "table" and Cfg.Default or (Cfg.Default and {Cfg.Default.Name} or {})
            local function UpdateText() BindText.Text = #currentKeys > 0 and table.concat(currentKeys, " + ") or "None" end; UpdateText()
            
            local binding = false
            BindBtn.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true; BindText.Text = "..."
                local keys, conn, conn2 = {}
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then keys = {}; binding = false; currentKeys = keys; UpdateText(); if Cfg.Callback then pcall(Cfg.Callback, currentKeys) end; conn:Disconnect(); conn2:Disconnect()
                        elseif not table.find(keys, input.KeyCode.Name) then table.insert(keys, input.KeyCode.Name) end
                    end
                end)
                conn2 = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard and binding then
                        binding = false; currentKeys = keys; UpdateText(); if Cfg.Callback then pcall(Cfg.Callback, currentKeys) end; conn:Disconnect(); conn2:Disconnect()
                    end
                end)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and #currentKeys > 0 and input.UserInputType == Enum.UserInputType.Keyboard then
                    local allPressed = true
                    for _, k in ipairs(currentKeys) do
                        local s, isDown = pcall(function() return UserInputService:IsKeyDown(Enum.KeyCode[k]) end)
                        if (not s or not isDown) and input.KeyCode.Name ~= k then allPressed = false; break end
                    end
                    if allPressed and Cfg.Callback then pcall(Cfg.Callback, currentKeys, true) end
                end
            end)
            return Frame
        end
        Elements.Keybind = Elements.Bind -- Alias
        
        function Elements:Toggle(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)})
            Register(Cfg.Name, Frame); AttachTooltip(Frame, Cfg.Description)
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Theme("TextDark"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local CheckBg = Create("TextButton", {Parent = Frame, BackgroundColor3 = Theme("Element"), Position = UDim2.new(1, -22, 0.5, -11), Size = UDim2.new(0, 22, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = CheckBg, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = CheckBg, Color = Theme("Stroke"), Thickness = 1})
            local CheckIcon = Create("ImageLabel", {Parent = CheckBg, BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 4), Size = UDim2.new(1, -8, 1, -8), Image = "rbxassetid://10709790644", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 1})
            
            local OptionBtn; local rightOffset = 30
            if Cfg.Option then
                OptionBtn = Create("ImageButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -(rightOffset + 16), 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://10734950309", ImageColor3 = Theme("TextDark"), ImageTransparency = 0.5})
                OptionBtn.MouseEnter:Connect(function() Tween(OptionBtn, {ImageTransparency = 0}) end)
                OptionBtn.MouseLeave:Connect(function() Tween(OptionBtn, {ImageTransparency = 0.5}) end)
            end

            local Toggled = Cfg.Default or false
            local function Update()
                Tween(CheckBg, {BackgroundColor3 = Toggled and Theme("Accent") or Theme("Element")}); Tween(CheckIcon, {ImageTransparency = Toggled and 0 or 1}) 
                if Cfg.Callback then pcall(Cfg.Callback, Toggled) end 
            end
            CheckBg.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end); Update()
            
            local ReturnAPI = {}
            if Cfg.Option then ReturnAPI.Option = BuildElements(CreateOptionFlyout(OptionBtn), Context) end
            return ReturnAPI
        end

        function Elements:Slider(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
            Register(Cfg.Name, Frame); AttachTooltip(Frame, Cfg.Description)
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = Theme("TextDark"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local ValBox = Create("Frame", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -40, 0, 0), Size = UDim2.new(0, 40, 0, 20)})
            local ValLabel = Create("TextLabel", {Parent = ValBox, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = "0.00", TextColor3 = Theme("TextDark"), TextSize = 11})
            
            local Rail = Create("Frame", {Parent = Frame, BackgroundColor3 = Theme("Element"), Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 4)}); Create("UICorner", {Parent = Rail, CornerRadius = UDim.new(1, 0)})
            local Fill = Create("Frame", {Parent = Rail, BackgroundColor3 = Theme("TextDark"), Size = UDim2.new(0, 0, 1, 0)}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            local Knob = Create("Frame", {Parent = Fill, BackgroundColor3 = Theme("TextDark"), Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0)}); Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
            local Trigger = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,20), Size = UDim2.new(1,0,0,25), Text = ""})
            
            local OptionBtn
            if Cfg.Option then OptionBtn = Create("ImageButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -65, 0, 2), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://10734950309", ImageColor3 = Theme("TextDark"), ImageTransparency = 0.5}) end

            local Min, Max, Val = Cfg.Min or 0, Cfg.Max or 100, Cfg.Default or (Cfg.Min or 0)
            local function Set(v) 
                Val = math.clamp(v, Min, Max); Tween(Fill, {Size = UDim2.new((Val - Min) / (Max - Min), 0, 1, 0)})
                ValLabel.Text = string.format("%."..(Cfg.Decimals or 0).."f", Val); if Cfg.Callback then pcall(Cfg.Callback, Val) end 
            end
            Trigger.InputBegan:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    local Dragging = true; Set(Min + (Max-Min)*math.clamp((i.Position.X - Rail.AbsolutePosition.X)/Rail.AbsoluteSize.X,0,1))
                    local changed, ended; 
                    changed = UserInputService.InputChanged:Connect(function(i2) if Dragging and i2.UserInputType == Enum.UserInputType.MouseMovement then Set(Min + (Max-Min)*math.clamp((i2.Position.X - Rail.AbsolutePosition.X)/Rail.AbsoluteSize.X,0,1)) end end)
                    ended = UserInputService.InputEnded:Connect(function(i3) if i3.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false; changed:Disconnect(); ended:Disconnect() end end) 
                end 
            end); Set(Val)

            local ReturnAPI = {}
            if Cfg.Option then ReturnAPI.Option = BuildElements(CreateOptionFlyout(OptionBtn), Context) end
            return ReturnAPI
        end

        function Elements:ColorPicker(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Register(Cfg.Name, Frame); AttachTooltip(Frame, Cfg.Description)
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Theme("TextDark"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local ColorBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Cfg.Default or Color3.new(1,1,1), Position = UDim2.new(1, -30, 0.5, -10), Size = UDim2.new(0, 30, 0, 20), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = ColorBtn, Color = Theme("Stroke")})
            
            local Flyout = Create("Frame", {Parent = Screen, BackgroundColor3 = Theme("SectionBg"), Size = UDim2.new(0, 180, 0, 160), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 110, Visible = false})
            Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = Theme("Stroke"), Thickness = 1})

            local SatValMap = Create("ImageButton", {Parent = Flyout, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 140, 0, 110), BackgroundColor3 = ColorBtn.BackgroundColor3, AutoButtonColor = false}); Create("UICorner", {Parent = SatValMap, CornerRadius = UDim.new(0, 4)})
            local VMap = Create("Frame", {Parent = SatValMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0)}); Create("UICorner", {Parent = VMap, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = VMap, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})})
            local CursorSV = Create("Frame", {Parent = SatValMap, Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(1, -2, 0, -2), BackgroundColor3 = Color3.new(1,1,1)}); Create("UICorner", {Parent = CursorSV, CornerRadius = UDim.new(1,0)})

            local HueRail = Create("ImageButton", {Parent = Flyout, Position = UDim2.new(0, 155, 0, 10), Size = UDim2.new(0, 15, 0, 110), BackgroundColor3 = Color3.new(1,1,1), AutoButtonColor = false}); Create("UICorner", {Parent = HueRail, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = HueRail, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
            local CursorH = Create("Frame", {Parent = HueRail, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.new(0,0,0)})
            local HexBox = Create("TextBox", {Parent = Flyout, Position = UDim2.new(0, 10, 0, 130), Size = UDim2.new(0, 160, 0, 20), BackgroundColor3 = Theme("ValueBox"), Font = Keyser.Font, Text = "#FFFFFF", TextColor3 = Theme("Text"), TextSize = 12}); Create("UICorner", {Parent = HexBox, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = HexBox, Color = Theme("Stroke")})

            local Hue, Sat, Val = ColorBtn.BackgroundColor3:ToHSV(); local updater, isOpen = nil, false
            local function UpdateColor()
                local nc = Color3.fromHSV(Hue, Sat, Val); ColorBtn.BackgroundColor3 = nc; SatValMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1); HexBox.Text = "#" .. nc:ToHex():upper()
                if Cfg.Callback then pcall(Cfg.Callback, nc) end
            end
            local function ToggleFlyout(state)
                isOpen = state; Flyout.Visible = state
                if state then updater = RunService.RenderStepped:Connect(function() Flyout.Position = UDim2.new(0, ColorBtn.AbsolutePosition.X - 150, 0, ColorBtn.AbsolutePosition.Y + 25) end) else if updater then updater:Disconnect(); updater = nil end end
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
            HandleDrag(HueRail, "Hue"); HandleDrag(SatValMap, "SV"); UpdateColor()
        end

        function Elements:Dropdown(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 55)})
            Register(Cfg.Name, Frame); AttachTooltip(Frame, Cfg.Description)
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = Theme("TextDark"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local DropBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Theme("Element"), Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = DropBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = DropBtn, Color = Theme("Stroke"), Thickness = 1})
            local DropText = Create("TextLabel", {Parent = DropBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0), Font = Keyser.Font, Text = "Select...", TextColor3 = Theme("Text"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            
            local Flyout = Create("Frame", {Parent = Screen, BackgroundColor3 = Theme("SectionBg"), Size = UDim2.new(0, 200, 0, 0), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 110, Visible = false})
            Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = Theme("Stroke"), Thickness = 1})
            
            local SearchBox = Create("TextBox", {Parent = Flyout, BackgroundColor3 = Theme("ValueBox"), Position = UDim2.new(0, 5, 0, 5), Size = UDim2.new(1, -10, 0, 25), Font = Keyser.Font, PlaceholderText = "Search...", Text = "", TextColor3 = Theme("Text"), TextSize = 12})
            Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = SearchBox, Color = Theme("Stroke"), Thickness = 1})
            
            local Scroll = Create("ScrollingFrame", {Parent = Flyout, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 1, -35), ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0)})
            local List = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
            
            local selected = type(Cfg.Default) == "table" and Cfg.Default or (Cfg.Default and {Cfg.Default} or {})
            local itemBtns, isOpen, updater = {}, false, nil
            
            local function UpdateText()
                DropText.Text = #selected == 0 and "Select..." or table.concat(selected, ", ")
                if Cfg.Callback then pcall(Cfg.Callback, Cfg.MultiSelect and selected or selected[1]) end
            end; UpdateText()
            
            local function ToggleFlyout(state)
                isOpen = state
                if state then
                    Flyout.Visible = true; Tween(Flyout, {Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, math.clamp(List.AbsoluteContentSize.Y + 45, 0, 200))}, 0.2)
                    updater = RunService.RenderStepped:Connect(function() Flyout.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 5) end)
                else
                    Tween(Flyout, {Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, 0)}, 0.2); task.delay(0.2, function() if not isOpen then Flyout.Visible = false end end)
                    if updater then updater:Disconnect(); updater = nil end
                end
            end
            DropBtn.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)
            
            for _, v in ipairs(Cfg.Items) do
                local Btn = Create("TextButton", {Parent = Scroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Font = Keyser.Font, Text = "  "..v, TextColor3 = table.find(selected, v) and Theme("Accent") or Theme("TextDark"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                Btn.MouseButton1Click:Connect(function()
                    if Cfg.MultiSelect then
                        local idx = table.find(selected, v)
                        if idx then table.remove(selected, idx); Btn.TextColor3 = Theme("TextDark") else table.insert(selected, v); Btn.TextColor3 = Theme("Accent") end
                    else
                        selected = {v}; for _, ob in ipairs(itemBtns) do ob.TextColor3 = Theme("TextDark") end; Btn.TextColor3 = Theme("Accent"); ToggleFlyout(false)
                    end; UpdateText()
                end)
                table.insert(itemBtns, Btn)
            end
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0,0,0, List.AbsoluteContentSize.Y) end)
            
            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local t = SearchBox.Text:lower()
                for i, v in ipairs(Cfg.Items) do itemBtns[i].Visible = string.find(v:lower(), t) ~= nil end
            end)
            return Frame
        end

        function Elements:Input(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 55)})
            Register(Cfg.Name, Frame); AttachTooltip(Frame, Cfg.Description)
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = Theme("Text"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local InputContainer = Create("Frame", {Parent = Frame, BackgroundColor3 = Theme("ValueBox"), Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30)}); Create("UICorner", {Parent = InputContainer, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = InputContainer, Color = Theme("Stroke"), Thickness = 1})
            local Box = Create("TextBox", {Parent = InputContainer, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), Font = Keyser.Font, Text = "", PlaceholderText = Cfg.Placeholder or "Search...", TextColor3 = Theme("Text"), PlaceholderColor3 = Theme("TextDark"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            Box:GetPropertyChangedSignal("Text"):Connect(function() if Cfg.Callback then pcall(Cfg.Callback, Box.Text) end end)
            return Frame
        end

        function Elements:List(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Cfg.Height or 150)})
            Register(Cfg.Name or "List", Frame); AttachTooltip(Frame, Cfg.Description)
            local Scroll = Create("ScrollingFrame", {Parent = Frame, BackgroundColor3 = Theme("ValueBox"), Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme("Stroke"), CanvasSize = UDim2.new(0,0,0,0)}); Create("UICorner", {Parent = Scroll, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = Scroll, Color = Theme("Stroke"), Thickness = 1})
            local ListLayout = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder}); Create("UIPadding", {Parent = Scroll, PaddingLeft = UDim.new(0, 5)})
            local Items = {}; ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y) end)
            for _, v in pairs(Cfg.Items) do
                local Btn = Create("TextButton", {Parent = Scroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Font = Keyser.Font, Text = "  "..v, TextColor3 = Theme("TextDark"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                Btn.MouseButton1Click:Connect(function() for _, b in pairs(Items) do b.Obj.TextColor3 = Theme("TextDark") end; Btn.TextColor3 = Theme("Text"); if Cfg.Callback then pcall(Cfg.Callback, v) end end)
                table.insert(Items, {Obj = Btn, Val = v})
            end
            local ListObj = {}; function ListObj:Filter(txt) for _, item in pairs(Items) do item.Obj.Visible = string.find(string.lower(item.Val), string.lower(txt or "")) ~= nil end end
            return ListObj
        end

        function Elements:Button(Cfg)
            local Btn = Create("TextButton", {Parent = TargetParent, BackgroundColor3 = Theme("Element"), Size = UDim2.new(1, 0, 0, 32), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Theme("TextDark"), TextSize = 12, AutoButtonColor = false}); Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = Btn, Color = Theme("Stroke"), Thickness = 1})
            Register(Cfg.Name, Btn); AttachTooltip(Btn, Cfg.Description)
            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Theme("Hover"), TextColor3 = Theme("Text")}) end); Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme("Element"), TextColor3 = Theme("TextDark")}) end)
            Btn.MouseButton1Click:Connect(function() if Cfg.Callback then pcall(Cfg.Callback) end end)
        end

        function Elements:Paragraph(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1})
            Register(Cfg.Title or "Paragraph", Frame); AttachTooltip(Frame, Cfg.Description)
            Create("UIListLayout", {Parent = Frame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,16), Font = Keyser.FontBold, Text = Cfg.Title, TextColor3 = Theme("Text"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Keyser.Font, Text = Cfg.Content, TextColor3 = Theme("TextDark"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
            return Frame
        end

        function Elements:PlayerList(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, Size = UDim2.new(1,0,0,200), BackgroundTransparency = 1})
            Register(Cfg.Name or "Player List", Frame); AttachTooltip(Frame, Cfg.Description)
            Create("TextLabel", {Parent = Frame, Size = UDim2.new(1,0,0,20), Font = Keyser.FontBold, Text = Cfg.Name or "Players", TextColor3 = Theme("Text"), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1})
            local SearchP = Create("TextBox", {Parent = Frame, BackgroundColor3 = Theme("ValueBox"), Position = UDim2.new(0,0,0,25), Size = UDim2.new(1,0,0,30), Font = Keyser.Font, PlaceholderText = "Search Player...", TextColor3 = Theme("Text"), TextSize = 12})
            Create("UICorner", {Parent = SearchP, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = SearchP, Color = Theme("Stroke"), Thickness = 1})
            local Scroll = Create("ScrollingFrame", {Parent = Frame, BackgroundColor3 = Theme("SectionBg"), Position = UDim2.new(0,0,0,60), Size = UDim2.new(1,0,1,-60), ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0)})
            Create("UICorner", {Parent = Scroll, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = Scroll, Color = Theme("Stroke"), Thickness = 1})
            local List = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            Create("UIPadding", {Parent = Scroll, PaddingTop = UDim.new(0,5), PaddingBottom = UDim.new(0,5), PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})
            
            local pItems = {}
            local function Refresh()
                for _, b in ipairs(pItems) do b.Frame:Destroy() end; pItems = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    local pFrame = Create("TextButton", {Parent = Scroll, BackgroundColor3 = Theme("Element"), Size = UDim2.new(1, 0, 0, 36), Text = "", AutoButtonColor = false}); Create("UICorner", {Parent = pFrame, CornerRadius = UDim.new(0,4)})
                    local pIcon = Create("ImageLabel", {Parent = pFrame, BackgroundColor3 = Theme("ValueBox"), Position = UDim2.new(0,4,0,4), Size = UDim2.new(0,28,0,28), Image = "rbxthumb://type=AvatarHeadShot&id="..p.UserId.."&w=48&h=48"}); Create("UICorner", {Parent = pIcon, CornerRadius = UDim.new(1,0)})
                    Create("TextLabel", {Parent = pFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1,-40,1,0), Font = Keyser.Font, Text = p.Name, TextColor3 = Theme("TextDark"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                    pFrame.MouseEnter:Connect(function() Tween(pFrame, {BackgroundColor3 = Theme("Hover")}) end); pFrame.MouseLeave:Connect(function() Tween(pFrame, {BackgroundColor3 = Theme("Element")}) end)
                    pFrame.MouseButton1Click:Connect(function() if Cfg.Callback then pcall(Cfg.Callback, p.Name) end end)
                    table.insert(pItems, {Frame = pFrame, Name = p.Name})
                end
                Scroll.CanvasSize = UDim2.new(0,0,0, List.AbsoluteContentSize.Y + 10)
            end
            Players.PlayerAdded:Connect(Refresh); Players.PlayerRemoving:Connect(Refresh); Refresh()
            SearchP:GetPropertyChangedSignal("Text"):Connect(function() local t = SearchP.Text:lower(); for _, data in ipairs(pItems) do data.Frame.Visible = string.find(data.Name:lower(), t) ~= nil end; Scroll.CanvasSize = UDim2.new(0,0,0, List.AbsoluteContentSize.Y + 10) end)
            return Frame
        end

        function Elements:Graph(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, Size = UDim2.new(1, 0, 0, 100), BackgroundTransparency = 1})
            Register(Cfg.Name or "Graph", Frame); AttachTooltip(Frame, Cfg.Description)
            Create("TextLabel", {Parent = Frame, Size = UDim2.new(1,0,0,20), Font = Keyser.FontBold, Text = Cfg.Name or Cfg.Type, TextColor3 = Theme("Text"), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1})
            local Canvas = Create("Frame", {Parent = Frame, BackgroundColor3 = Theme("ValueBox"), Position = UDim2.new(0,0,0,25), Size = UDim2.new(1,0,1,-25)}); Create("UICorner", {Parent = Canvas, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = Canvas, Color = Theme("Stroke"), Thickness = 1})
            
            local maxPoints, history, lines = 50, {}, {}
            for i=1, maxPoints do history[i] = 0 end
            for i=1, maxPoints-1 do lines[i] = Create("Frame", {Parent = Canvas, BackgroundColor3 = Theme("Accent"), AnchorPoint = Vector2.new(0.5,0.5), BorderSizePixel = 0}) end
            
            local lastTick, frames = tick(), 0
            RunService.RenderStepped:Connect(function()
                local val = 0
                if Cfg.Type == "FPS" then
                    frames = frames + 1
                    if tick() - lastTick >= 0.1 then val = math.floor(frames / (tick() - lastTick)); frames = 0; lastTick = tick() else return end
                elseif Cfg.Type == "Ping" then
                    val = tonumber(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+")) or 0
                end
                
                table.remove(history, 1); table.insert(history, val)
                local maxVal = 1; for _, v in ipairs(history) do if v > maxVal then maxVal = v end end
                maxVal = maxVal * 1.2
                
                local w, h, step = Canvas.AbsoluteSize.X, Canvas.AbsoluteSize.Y, Canvas.AbsoluteSize.X / (maxPoints - 1)
                for i=1, maxPoints-1 do
                    local p1, p2 = Vector2.new((i-1)*step, h - (history[i]/maxVal)*h), Vector2.new(i*step, h - (history[i+1]/maxVal)*h)
                    lines[i].Size = UDim2.new(0, (p2 - p1).Magnitude, 0, 2)
                    lines[i].Position = UDim2.new(0, (p1.X+p2.X)/2, 0, (p1.Y+p2.Y)/2)
                    lines[i].Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
                end
            end)
            return Frame
        end

        return Elements
    end

    --[ 1. TAB (SIDEBAR BUTTON) ]
    function WinData:Tab(Config)
        local TabObj = {TopTabs = {}, ActiveTop = nil}
        local TopButtonsFrame = Create("Frame", {Parent = NavContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
        Create("UIListLayout", {Parent = TopButtonsFrame, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 15)})

        local SideBtn = Create("TextButton", {Parent = SideContainer, BackgroundColor3 = Theme("Element"), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Text = "", AutoButtonColor = false}); Create("UICorner", {Parent = SideBtn, CornerRadius = UDim.new(0, 4)})
        local Icon = Create("ImageLabel", {Parent = SideBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), Image = Config.Icon or "", ImageColor3 = Theme("TextDark")})
        local Label = Create("TextLabel", {Parent = SideBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -40, 1, 0), Font = Keyser.FontBold, Text = Config.Name, TextColor3 = Theme("TextDark"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        
        WinData.SearchRegistry.Tabs[TabObj] = {Btn = SideBtn}

        local function ActivateSidebar()
            if WinData.ActiveSidebar == TabObj then return end
            if WinData.ActiveSidebar then
                Tween(WinData.ActiveSidebar.Btn, {BackgroundTransparency = 1}); Tween(WinData.ActiveSidebar.Label, {TextColor3 = Theme("TextDark")}); Tween(WinData.ActiveSidebar.Icon, {ImageColor3 = Theme("TextDark")})
                WinData.ActiveSidebar.TopButtonsFrame.Visible = false
                if WinData.ActiveSidebar.ActiveTop then WinData.ActiveSidebar.ActiveTop.Page.Visible = false end
            end
            WinData.ActiveSidebar = TabObj
            Tween(SideBtn, {BackgroundTransparency = 0}); Tween(Label, {TextColor3 = Theme("Text")}); Tween(Icon, {ImageColor3 = Theme("Text")}); TopButtonsFrame.Visible = true
            if TabObj.ActiveTop then TabObj.ActiveTop:Activate() elseif #TabObj.TopTabs > 0 then TabObj.TopTabs[1]:Activate() end
        end

        SideBtn.MouseButton1Click:Connect(ActivateSidebar)
        TabObj.Activate = ActivateSidebar; TabObj.Btn = SideBtn; TabObj.Label = Label; TabObj.Icon = Icon; TabObj.TopButtonsFrame = TopButtonsFrame

        --[ 2. PAGE (TOPBAR BUTTON) ]
        function TabObj:Page(Name)
            local PageObj = {}
            local TopBtn = Create("TextButton", {Parent = TopButtonsFrame, BackgroundColor3 = Theme("Element"), BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, -20), Font = Keyser.FontBold, Text = Name, TextColor3 = Theme("TextDark"), TextSize = 13, AutomaticSize = Enum.AutomaticSize.X})
            Create("UICorner", {Parent = TopBtn, CornerRadius = UDim.new(0, 4)}); Create("UIPadding", {Parent = TopBtn, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)})

            local PageFrame = Create("Frame", {Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
            Create("UIPadding", {Parent = PageFrame, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})

            local LeftCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.485, 0, 1, 0)})
            local RightCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.485, 0, 1, 0), Position = UDim2.new(0.515, 0, 0, 0)})
            Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)}); Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})

            WinData.SearchRegistry.Pages[PageObj] = {Btn = TopBtn}

            function PageObj:Activate()
                if TabObj.ActiveTop and TabObj.ActiveTop ~= PageObj then Tween(TabObj.ActiveTop.Btn, {BackgroundTransparency = 1, TextColor3 = Theme("TextDark")}); TabObj.ActiveTop.Page.Visible = false end
                TabObj.ActiveTop = PageObj; Tween(TopBtn, {BackgroundTransparency = 0, TextColor3 = Theme("Text")}); PageFrame.Visible = true
            end

            TopBtn.MouseButton1Click:Connect(function() PageObj:Activate() end)
            PageObj.Btn = TopBtn; PageObj.Page = PageFrame
            table.insert(TabObj.TopTabs, PageObj)

            --[ 3. SECTION (GROUPBOX) ]
            local SectionLib = {}
            function SectionLib:Section(SecConfig)
                local Col = (SecConfig.Side == "Right" and RightCol) or LeftCol
                local Groupbox = Create("Frame", {Parent = Col, BackgroundColor3 = Theme("SectionBg"), Size = UDim2.new(1, 0, 0, SecConfig.Height or 0), AutomaticSize = SecConfig.Height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y})
                Create("UICorner", {Parent = Groupbox, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Groupbox, Color = Theme("Stroke"), Thickness = 1})

                local HeaderFrame = Create("Frame", {Parent = Groupbox, BackgroundColor3 = Theme("SectionHeader"), Size = UDim2.new(1, 0, 0, 38), BorderSizePixel = 0})
                Create("UICorner", {Parent = HeaderFrame, CornerRadius = UDim.new(0, 6)}); Create("Frame", {Parent = HeaderFrame, BackgroundColor3 = Theme("SectionHeader"), Position = UDim2.new(0,0,1,-6), Size = UDim2.new(1,0,0,6), BorderSizePixel = 0}) 
                Create("TextLabel", {Parent = HeaderFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -15, 1, 0), Font = Keyser.FontBold, Text = SecConfig.Name, TextColor3 = Theme("Text"), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                
                local ContentFrame = SecConfig.Height and Create("ScrollingFrame", {Parent = Groupbox, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 1, -38), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme("Stroke"), CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel = 0}) or Create("Frame", {Parent = Groupbox, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
                local CList = Create("UIListLayout", {Parent = ContentFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
                Create("UIPadding", {Parent = ContentFrame, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10)})
                
                if SecConfig.Height then CList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() ContentFrame.CanvasSize = UDim2.new(0, 0, 0, CList.AbsoluteContentSize.Y + 20) end) end
                
                WinData.SearchRegistry.Sections[Groupbox] = {Name = SecConfig.Name, Page = PageObj, Tab = TabObj}
                return BuildElements(ContentFrame, {Tab = TabObj, Page = PageObj, Section = Groupbox})
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
