--[[
    KEYSER UI V9.0 - FIVEM & IMGUI EDITION (PRO EVOLUTION)
    Structure: Intro -> Sidebar/Topbar/Search -> Content Canvas -> Section Cards
    
    New Features (V9.0):
    - Dynamic Theme Manager ($ColorKey string injection).
    - Global Toast Notification System.
    - Global Search Bar (Filters UI dynamically).
    - Dynamic Tooltips on hover (Pass 'Description' in Cfg).
    - Modern Dropdown & PlayerList (with Avatars).
    - Line Plots / Performance Graphs (FPS & Ping).
    - Complex Keybinds (Ctrl/Shift/Alt + Key).
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = { ThemeObjects = {} }

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

--[ THEME MANAGER & UTILS ]
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if type(v) == "string" and v:sub(1,1) == "$" then
            local colorKey = v:sub(2)
            if Keyser.Colors[colorKey] then
                table.insert(Library.ThemeObjects, {Obj = obj, Prop = k, Color = colorKey})
                obj[k] = Keyser.Colors[colorKey]
            else
                obj[k] = v
            end
        else
            obj[k] = v
        end
    end
    return obj
end

function Library:UpdateTheme(NewColors)
    for k, v in pairs(NewColors) do
        if Keyser.Colors[k] then Keyser.Colors[k] = v end
    end
    for _, entry in ipairs(Library.ThemeObjects) do
        if entry.Obj and entry.Obj.Parent then
            pcall(function() entry.Obj[entry.Prop] = Keyser.Colors[entry.Color] end)
        end
    end
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
            inputChanged = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local delta = inp.Position - dragStart
                    moveObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            inputEnded = UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false; inputChanged:Disconnect(); inputEnded:Disconnect()
                end
            end)
        end
    end)
end

--[ NOTIFICATION SYSTEM (TOASTS) ]
local ToastScreen = Create("ScreenGui", {Name = "KeyserToasts", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
local ToastContainer = Create("Frame", {Parent = ToastScreen, BackgroundTransparency = 1, Size = UDim2.new(0, 250, 1, -20), Position = UDim2.new(1, -270, 0, 10)})
Create("UIListLayout", {Parent = ToastContainer, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 10)})

function Library:Notify(Cfg)
    local duration = Cfg.Duration or 3
    local Toast = Create("Frame", {Parent = ToastContainer, BackgroundColor3 = "$SectionBg", Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(1, 300, 0, 0), ClipsDescendants = true})
    Create("UICorner", {Parent = Toast, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Toast, Color = "$Stroke", Thickness = 1})
    
    Create("TextLabel", {Parent = Toast, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 5), Size = UDim2.new(1, -24, 0, 20), Font = Keyser.FontBold, Text = Cfg.Title or "Notification", TextColor3 = "$Text", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Toast, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 25), Size = UDim2.new(1, -24, 0, 30), Font = Keyser.Font, Text = Cfg.Content or "", TextColor3 = "$TextDark", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})

    local ProgBg = Create("Frame", {Parent = Toast, BackgroundColor3 = "$Element", Position = UDim2.new(0, 0, 1, -3), Size = UDim2.new(1, 0, 0, 3), BorderSizePixel = 0})
    local ProgBar = Create("Frame", {Parent = ProgBg, BackgroundColor3 = "$Accent", Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0})

    TweenService:Create(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    local pTween = TweenService:Create(ProgBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}); pTween:Play()

    task.delay(duration, function()
        local out = TweenService:Create(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 300, 0, 0)})
        out:Play(); out.Completed:Connect(function() Toast:Destroy() end)
    end)
end

function Library:Window(Config)
    local WindowName = Config.Name or "Keyser"
    local WindowScale = Config.Scale or UDim2.new(0, 800, 0, 550)
    local ToggleKey = Config.Keybind or Enum.KeyCode.RightControl

    local Screen = Create("ScreenGui", {Name = "Keyser", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true})
    
    -- [ TOOLTIP SYSTEM ]
    local TooltipUI = Create("Frame", {Parent = Screen, BackgroundColor3 = "$SectionBg", Size = UDim2.new(0,0,0,0), AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 1000, Visible = false})
    Create("UICorner", {Parent = TooltipUI, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = TooltipUI, Color = "$Stroke", Thickness = 1})
    local TooltipText = Create("TextLabel", {Parent = TooltipUI, BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0), AutomaticSize = Enum.AutomaticSize.XY, Font = Keyser.Font, Text = "", TextColor3 = "$Text", TextSize = 11})
    Create("UIPadding", {Parent = TooltipUI, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
    
    local TooltipHovered = false
    local function AttachTooltip(obj, text)
        if not text then return end
        obj.MouseEnter:Connect(function()
            TooltipHovered = true
            task.delay(0.5, function()
                if TooltipHovered then
                    TooltipText.Text = text; TooltipUI.Visible = true
                    local rsConn; rsConn = RunService.RenderStepped:Connect(function()
                        if not TooltipHovered then rsConn:Disconnect() return end
                        local mPos = UserInputService:GetMouseLocation()
                        TooltipUI.Position = UDim2.new(0, mPos.X + 15, 0, mPos.Y - 15)
                    end)
                end
            end)
        end)
        obj.MouseLeave:Connect(function() TooltipHovered = false; TooltipUI.Visible = false end)
    end

    -- [ MAIN WINDOW ]
    local MainFrame = Create("Frame", {Parent = Screen, BackgroundColor3 = "$Main", Position = UDim2.new(0.5, -WindowScale.X.Offset/2, 0.5, -WindowScale.Y.Offset/2), Size = WindowScale, ClipsDescendants = true})
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = MainFrame, Color = "$Stroke", Thickness = 1})
    MakeDraggable(MainFrame, MainFrame)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ToggleKey then Screen.Enabled = not Screen.Enabled end
    end)

    local Header = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 65), ZIndex = 2})
    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 65), Size = UDim2.new(0, 200, 1, -65)})
    
    local LogoArea = Create("Frame", {Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0)})
    Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 14), Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBlack, Text = WindowName, TextColor3 = Color3.fromRGB(150, 150, 160), TextSize = 22})
    Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 14), Font = Keyser.Font, Text = "V9.0 PRO", TextColor3 = "$TextDark", TextSize = 11})

    local NavContainer = Create("Frame", {Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 200, 0, 0), Size = UDim2.new(1, -200, 1, 0)})
    
    -- Global Search Container
    local SearchContainer = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
    local SearchBox = Create("TextBox", {Parent = SearchContainer, BackgroundColor3 = "$Element", Position = UDim2.new(0, 15, 0, 5), Size = UDim2.new(1, -30, 0, 30), Font = Keyser.Font, PlaceholderText = "Search Elements...", Text = "", TextColor3 = "$Text", PlaceholderColor3 = "$TextDark", TextSize = 11})
    Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = SearchBox, Color = "$Stroke", Thickness = 1})

    local SideContainer = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,45), Size = UDim2.new(1, 0, 1, -45), ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)})
    Create("UIListLayout", {Parent = SideContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
    Create("UIPadding", {Parent = SideContainer, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})

    local PageContainer = Create("Frame", {Parent = MainFrame, BackgroundColor3 = "$Canvas", Position = UDim2.new(0, 200, 0, 65), Size = UDim2.new(1, -200, 1, -65), ClipsDescendants = true})
    Create("Frame", {Parent = PageContainer, BackgroundColor3 = "$Stroke", Size = UDim2.new(1,0,0,1), BorderSizePixel = 0}) 
    Create("Frame", {Parent = PageContainer, BackgroundColor3 = "$Stroke", Size = UDim2.new(0,1,1,0), BorderSizePixel = 0})

    local SearchableElements = {}
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local term = string.lower(SearchBox.Text)
        for _, item in ipairs(SearchableElements) do
            if term == "" then item.Obj.Visible = true
            else item.Obj.Visible = (item.Name and string.find(string.lower(item.Name), term) ~= nil) end
        end
    end)

    local WinData = {ActiveSidebar = nil}; local AllSidebarTabs = {}

    local function CreateOptionFlyout(AnchorButton)
        local Flyout = Create("Frame", {Parent = Screen, BackgroundColor3 = "$SectionBg", Size = UDim2.new(0, 180, 0, 0), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 100, Visible = false})
        Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = "$Stroke", Thickness = 1})
        local Scroll = Create("ScrollingFrame", {Parent = Flyout, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0,0,0,5), ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)})
        local List = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        Create("UIPadding", {Parent = Scroll, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 5)})
        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10) end)
        
        local updater; local isOpen = false
        local function ToggleFlyout(state)
            isOpen = state
            if isOpen then
                Flyout.Visible = true; Tween(Flyout, {Size = UDim2.new(0, 180, 0, math.clamp(List.AbsoluteContentSize.Y + 20, 0, 250))})
                updater = RunService.RenderStepped:Connect(function() Flyout.Position = UDim2.new(0, AnchorButton.AbsolutePosition.X + AnchorButton.AbsoluteSize.X + 10, 0, AnchorButton.AbsolutePosition.Y - (Flyout.AbsoluteSize.Y/2) + 10) end)
            else Tween(Flyout, {Size = UDim2.new(0, 180, 0, 0)}); task.delay(0.25, function() if not isOpen then Flyout.Visible = false end end); if updater then updater:Disconnect(); updater = nil end end
        end
        AnchorButton.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)
        return Scroll
    end

    -- Element Builder Factory
    local function BuildElements(TargetParent)
        local Elements = {}
        
        -- [ NOVO: PARAGRAPH ]
        function Elements:Paragraph(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
            Create("UIPadding", {Parent = Frame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})
            local Title = Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Title or "Paragraph", TextColor3 = "$Text", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local Content = Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Keyser.Font, Text = Cfg.Content or "", TextColor3 = "$TextDark", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Title})
        end

        function Elements:Keybind(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = "$TextDark", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local BindBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = "$Element", Position = UDim2.new(1, -70, 0.5, -11), Size = UDim2.new(0, 70, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = BindBtn, Color = "$Stroke", Thickness = 1})
            local BindText = Create("TextLabel", {Parent = BindBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = Cfg.Default and Cfg.Default.Name or "None", TextColor3 = "$Text", TextSize = 11})
            
            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})
            local currentKey = Cfg.Default; local binding = false
            BindBtn.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true; BindText.Text = "..."
                local connection; connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then currentKey = nil; BindText.Text = "None"
                        else currentKey = input.KeyCode; BindText.Text = input.KeyCode.Name end
                        binding = false; if Cfg.Callback then pcall(Cfg.Callback, currentKey) end; connection:Disconnect()
                    end
                end)
            end)
        end

        --[ NOVO: BIND PRO (Ctrl/Shift/Alt Support) ]
        function Elements:Bind(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = "$TextDark", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local BindBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = "$Element", Position = UDim2.new(1, -100, 0.5, -11), Size = UDim2.new(0, 100, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = BindBtn, Color = "$Stroke", Thickness = 1})
            local BindText = Create("TextLabel", {Parent = BindBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = Cfg.Default or "None", TextColor3 = "$Text", TextSize = 11})

            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})
            local currentBind = Cfg.Default; local binding = false
            BindBtn.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true; BindText.Text = "..."
                local connection; connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode.Name
                        if key == "Escape" then currentBind = nil; BindText.Text = "None"
                        elseif key:match("Shift") or key:match("Control") or key:match("Alt") then return 
                        else
                            local mods = ""
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then mods = mods .. "Ctrl+" end
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then mods = mods .. "Shift+" end
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) then mods = mods .. "Alt+" end
                            currentBind = mods .. key; BindText.Text = currentBind
                        end
                        binding = false; if Cfg.Callback then pcall(Cfg.Callback, currentBind) end; connection:Disconnect()
                    end
                end)
            end)
        end
        
        function Elements:Toggle(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = "$TextDark", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local CheckBg = Create("TextButton", {Parent = Frame, BackgroundColor3 = "$Element", Position = UDim2.new(1, -22, 0.5, -11), Size = UDim2.new(0, 22, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = CheckBg, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = CheckBg, Color = "$Stroke", Thickness = 1})
            local CheckIcon = Create("ImageLabel", {Parent = CheckBg, BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 4), Size = UDim2.new(1, -8, 1, -8), Image = "rbxassetid://10709790644", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 1})
            
            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})

            local rightOffset = 30; local OptionBtn
            if Cfg.Option then
                OptionBtn = Create("ImageButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -(rightOffset + 16), 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://10734950309", ImageColor3 = "$TextDark", ImageTransparency = 0.5})
                OptionBtn.MouseEnter:Connect(function() Tween(OptionBtn, {ImageTransparency = 0}) end)
                OptionBtn.MouseLeave:Connect(function() Tween(OptionBtn, {ImageTransparency = 0.5}) end)
            end

            local Toggled = Cfg.Default or false
            local function Update()
                if Toggled then Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Accent}); Tween(CheckIcon, {ImageTransparency = 0}) 
                else Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Element}); Tween(CheckIcon, {ImageTransparency = 1}) end
                if Cfg.Callback then pcall(Cfg.Callback, Toggled) end 
            end
            
            CheckBg.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end); Update()
            local ReturnAPI = {}; if Cfg.Option then ReturnAPI.Option = BuildElements(CreateOptionFlyout(OptionBtn)) end
            return ReturnAPI
        end

        function Elements:Slider(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = "$TextDark", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local ValBox = Create("Frame", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -40, 0, 0), Size = UDim2.new(0, 40, 0, 20)})
            local ValLabel = Create("TextLabel", {Parent = ValBox, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = "0.00", TextColor3 = "$TextDark", TextSize = 11})
            
            local Rail = Create("Frame", {Parent = Frame, BackgroundColor3 = "$Element", Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 4)}); Create("UICorner", {Parent = Rail, CornerRadius = UDim.new(1, 0)})
            local Fill = Create("Frame", {Parent = Rail, BackgroundColor3 = "$TextDark", Size = UDim2.new(0, 0, 1, 0)}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            local Trigger = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,20), Size = UDim2.new(1,0,0,25), Text = ""})
            
            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})

            local OptionBtn
            if Cfg.Option then OptionBtn = Create("ImageButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -65, 0, 2), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://10734950309", ImageColor3 = "$TextDark", ImageTransparency = 0.5}) end

            local Min, Max, Val = Cfg.Min or 0, Cfg.Max or 100, Cfg.Default or Min
            local function Set(v) 
                Val = math.clamp(v, Min, Max); local P = (Val - Min) / (Max - Min); 
                Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}); ValLabel.Text = string.format("%."..(Cfg.Decimals or 0).."f", Val); 
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

            local ReturnAPI = {}; if Cfg.Option then ReturnAPI.Option = BuildElements(CreateOptionFlyout(OptionBtn)) end
            return ReturnAPI
        end

        -- [ NOVO: DROPDOWN MENU COM BUSCA ]
        function Elements:Dropdown(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 55)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = "$Text", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local DropBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = "$Element", Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = DropBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = DropBtn, Color = "$Stroke", Thickness = 1})
            local DropText = Create("TextLabel", {Parent = DropBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0), Font = Keyser.Font, Text = "Select...", TextColor3 = "$TextDark", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            local Icon = Create("ImageLabel", {Parent = DropBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 0.5, -6), Size = UDim2.new(0, 12, 0, 12), Image = "rbxassetid://6031091004", ImageColor3 = "$TextDark"})

            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})

            local Flyout = Create("Frame", {Parent = Screen, BackgroundColor3 = "$SectionBg", Size = UDim2.new(0, 200, 0, 0), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 120, Visible = false})
            Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = "$Stroke", Thickness = 1})
            local SearchBox = Create("TextBox", {Parent = Flyout, BackgroundColor3 = "$Element", Position = UDim2.new(0, 5, 0, 5), Size = UDim2.new(1, -10, 0, 25), Font = Keyser.Font, PlaceholderText = "Search...", Text = "", TextColor3 = "$Text", TextSize = 11})
            Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})
            
            local Scroll = Create("ScrollingFrame", {Parent = Flyout, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 1, -35), ScrollBarThickness = 2, ScrollBarImageColor3 = "$Stroke", CanvasSize = UDim2.new(0,0,0,0)})
            local ListLayout = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}); Create("UIPadding", {Parent = Scroll, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10) end)

            local isOpen = false; local updater; local selected = Cfg.MultiSelect and {} or nil; local itemBtns = {}

            local function ToggleFlyout(state)
                isOpen = state; Flyout.Visible = state
                if state then
                    Tween(Icon, {Rotation = 180}); Flyout.Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, math.clamp(ListLayout.AbsoluteContentSize.Y + 45, 0, 200))
                    updater = RunService.RenderStepped:Connect(function() Flyout.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 5) end)
                else Tween(Icon, {Rotation = 0}); if updater then updater:Disconnect(); updater = nil end end
            end
            DropBtn.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)

            for _, item in ipairs(Cfg.Items or {}) do
                local btn = Create("TextButton", {Parent = Scroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Font = Keyser.Font, Text = "  "..item, TextColor3 = "$TextDark", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                btn.MouseButton1Click:Connect(function()
                    if Cfg.MultiSelect then
                        selected[item] = not selected[item]; btn.TextColor3 = selected[item] and Keyser.Colors.Text or Keyser.Colors.TextDark
                        local t = {}; for k, v in pairs(selected) do if v then table.insert(t, k) end end
                        DropText.Text = #t > 0 and table.concat(t, ", ") or "Select..."
                    else
                        selected = item; for _, b in ipairs(itemBtns) do b.Btn.TextColor3 = Keyser.Colors.TextDark end
                        btn.TextColor3 = Keyser.Colors.Text; DropText.Text = item; ToggleFlyout(false)
                    end
                    if Cfg.Callback then pcall(Cfg.Callback, selected) end
                end)
                table.insert(itemBtns, {Btn = btn, Val = item})
            end

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local term = string.lower(SearchBox.Text); for _, b in ipairs(itemBtns) do b.Btn.Visible = string.find(string.lower(b.Val), term) ~= nil end
            end)
        end

        --[ NOVO: PLAYER LIST (Busca Integrada de Jogadores com Avatares) ]
        function Elements:PlayerList(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 55)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name or "Select Player", TextColor3 = "$Text", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local DropBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = "$Element", Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = DropBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = DropBtn, Color = "$Stroke", Thickness = 1})
            
            local SelectedAvatar = Create("ImageLabel", {Parent = DropBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 5, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), Visible = false}); Create("UICorner", {Parent = SelectedAvatar, CornerRadius = UDim.new(1, 0)})
            local DropText = Create("TextLabel", {Parent = DropBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -50, 1, 0), Font = Keyser.Font, Text = "Select Player...", TextColor3 = "$TextDark", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            local Icon = Create("ImageLabel", {Parent = DropBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 0.5, -6), Size = UDim2.new(0, 12, 0, 12), Image = "rbxassetid://6031091004", ImageColor3 = "$TextDark"})

            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})

            local Flyout = Create("Frame", {Parent = Screen, BackgroundColor3 = "$SectionBg", Size = UDim2.new(0, 200, 0, 0), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 120, Visible = false})
            Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = "$Stroke", Thickness = 1})
            local SearchBox = Create("TextBox", {Parent = Flyout, BackgroundColor3 = "$Element", Position = UDim2.new(0, 5, 0, 5), Size = UDim2.new(1, -10, 0, 25), Font = Keyser.Font, PlaceholderText = "Search Player...", Text = "", TextColor3 = "$Text", TextSize = 11})
            Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})
            
            local Scroll = Create("ScrollingFrame", {Parent = Flyout, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 1, -35), ScrollBarThickness = 2, ScrollBarImageColor3 = "$Stroke", CanvasSize = UDim2.new(0,0,0,0)})
            local ListLayout = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}); Create("UIPadding", {Parent = Scroll, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10) end)

            local isOpen = false; local updater; local itemBtns = {}

            local function ToggleFlyout(state)
                isOpen = state; Flyout.Visible = state
                if state then
                    Tween(Icon, {Rotation = 180}); Flyout.Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, math.clamp(ListLayout.AbsoluteContentSize.Y + 45, 0, 200))
                    updater = RunService.RenderStepped:Connect(function() Flyout.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 5) end)
                else Tween(Icon, {Rotation = 0}); if updater then updater:Disconnect(); updater = nil end end
            end
            DropBtn.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)

            local function Refresh()
                for _, b in ipairs(itemBtns) do b.Btn:Destroy() end; itemBtns = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p == Players.LocalPlayer then continue end
                    local btn = Create("TextButton", {Parent = Scroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Text = ""})
                    local av = Create("ImageLabel", {Parent = btn, BackgroundTransparency = 1, Position = UDim2.new(0, 5, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), Image = "rbxthumb://type=AvatarHeadShot&id="..p.UserId.."&w=48&h=48"}); Create("UICorner", {Parent = av, CornerRadius = UDim.new(1, 0)})
                    Create("TextLabel", {Parent = btn, BackgroundTransparency = 1, Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -30, 1, 0), Font = Keyser.Font, Text = p.Name, TextColor3 = "$TextDark", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                    
                    btn.MouseButton1Click:Connect(function()
                        DropText.Text = p.Name; SelectedAvatar.Image = av.Image; SelectedAvatar.Visible = true; DropText.Position = UDim2.new(0, 30, 0, 0); ToggleFlyout(false)
                        if Cfg.Callback then pcall(Cfg.Callback, p.Name) end
                    end)
                    table.insert(itemBtns, {Btn = btn, Val = p.Name})
                end
            end
            Refresh(); Players.PlayerAdded:Connect(Refresh); Players.PlayerRemoving:Connect(Refresh)

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local term = string.lower(SearchBox.Text); for _, b in ipairs(itemBtns) do b.Btn.Visible = string.find(string.lower(b.Val), term) ~= nil end
            end)
        end

        -- [ NOVO: GRAPH (FPS / Ping) ]
        function Elements:Graph(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 100)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name or "Performance", TextColor3 = "$Text", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local GraphBg = Create("Frame", {Parent = Frame, BackgroundColor3 = "$ValueBox", Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 75), ClipsDescendants = true})
            Create("UICorner", {Parent = GraphBg, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = GraphBg, Color = "$Stroke", Thickness = 1})
            local ValueLabel = Create("TextLabel", {Parent = GraphBg, BackgroundTransparency = 1, Position = UDim2.new(1, -55, 0, 5), Size = UDim2.new(0, 50, 0, 15), Font = Keyser.FontBold, Text = "0", TextColor3 = "$Text", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right})

            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})

            local lines = {}; local history = {}; local maxPoints = 40
            local function UpdateGraph()
                local minVal, maxVal = math.huge, -math.huge
                for _, v in ipairs(history) do if v < minVal then minVal = v end if v > maxVal then maxVal = v end end
                if maxVal - minVal < 10 then maxVal = minVal + 10 end
                local range = maxVal - minVal; for _, line in ipairs(lines) do line:Destroy() end; lines = {}

                local step = GraphBg.AbsoluteSize.X / (maxPoints - 1); local h = GraphBg.AbsoluteSize.Y
                for i = 1, #history - 1 do
                    local p1 = Vector2.new((i - 1) * step, h - ((history[i] - minVal) / range) * h)
                    local p2 = Vector2.new(i * step, h - ((history[i + 1] - minVal) / range) * h)
                    local dist = (p2 - p1).Magnitude; local center = (p1 + p2) / 2; local angle = math.atan2(p2.Y - p1.Y, p2.X - p1.X)

                    local line = Create("Frame", {Parent = GraphBg, BackgroundColor3 = "$Accent", Size = UDim2.new(0, dist, 0, 2), Position = UDim2.new(0, center.X, 0, center.Y), AnchorPoint = Vector2.new(0.5, 0.5), Rotation = math.deg(angle), BorderSizePixel = 0})
                    table.insert(lines, line)
                end
            end

            local lastUpdate = 0
            RunService.RenderStepped:Connect(function(dt)
                if os.clock() - lastUpdate > 0.1 then
                    lastUpdate = os.clock(); local val = 0
                    if Cfg.Type == "FPS" then val = math.floor(1 / dt) elseif Cfg.Type == "Ping" then pcall(function() val = math.floor(game:GetService("Stats").Network.ServerStatsItem("Data Ping"):GetValue()) end) end
                    table.insert(history, val); if #history > maxPoints then table.remove(history, 1) end
                    ValueLabel.Text = tostring(val) .. (Cfg.Type == "FPS" and " FPS" or " ms"); if GraphBg.AbsoluteSize.X > 0 then UpdateGraph() end
                end
            end)
        end
        
        --[ ELEMENTOS CLÁSSICOS (ATUALIZADOS) ]
        function Elements:ColorPicker(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = "$TextDark", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local ColorBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Cfg.Default or Color3.new(1,1,1), Position = UDim2.new(1, -30, 0.5, -10), Size = UDim2.new(0, 30, 0, 20), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = ColorBtn, Color = "$Stroke"})
            
            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})

            local Flyout = Create("Frame", {Parent = Screen, BackgroundColor3 = "$SectionBg", Size = UDim2.new(0, 180, 0, 160), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, ZIndex = 110, Visible = false})
            Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = "$Stroke", Thickness = 1})

            local SatValMap = Create("ImageButton", {Parent = Flyout, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 140, 0, 110), BackgroundColor3 = ColorBtn.BackgroundColor3, AutoButtonColor = false}); Create("UICorner", {Parent = SatValMap, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = SatValMap, Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})})
            local VMap = Create("Frame", {Parent = SatValMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0)}); Create("UICorner", {Parent = VMap, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = VMap, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})})
            local CursorSV = Create("Frame", {Parent = SatValMap, Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(1, -2, 0, -2), BackgroundColor3 = Color3.new(1,1,1)}); Create("UICorner", {Parent = CursorSV, CornerRadius = UDim.new(1,0)})

            local HueRail = Create("ImageButton", {Parent = Flyout, Position = UDim2.new(0, 155, 0, 10), Size = UDim2.new(0, 15, 0, 110), BackgroundColor3 = Color3.new(1,1,1), AutoButtonColor = false}); Create("UICorner", {Parent = HueRail, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = HueRail, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
            local CursorH = Create("Frame", {Parent = HueRail, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.new(0,0,0)})
            
            local HexBox = Create("TextBox", {Parent = Flyout, Position = UDim2.new(0, 10, 0, 130), Size = UDim2.new(0, 160, 0, 20), BackgroundColor3 = "$ValueBox", Font = Keyser.Font, Text = "#FFFFFF", TextColor3 = "$Text", TextSize = 12})
            Create("UICorner", {Parent = HexBox, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = HexBox, Color = "$Stroke"})

            local Hue, Sat, Val = ColorBtn.BackgroundColor3:ToHSV(); local updater, isOpen = nil, false
            local function UpdateColor()
                local newColor = Color3.fromHSV(Hue, Sat, Val); ColorBtn.BackgroundColor3 = newColor; SatValMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1); HexBox.Text = "#" .. newColor:ToHex():upper()
                if Cfg.Callback then pcall(Cfg.Callback, newColor) end
            end

            ColorBtn.MouseButton1Click:Connect(function() 
                isOpen = not isOpen; Flyout.Visible = isOpen
                if isOpen then updater = RunService.RenderStepped:Connect(function() Flyout.Position = UDim2.new(0, ColorBtn.AbsolutePosition.X - 150, 0, ColorBtn.AbsolutePosition.Y + 25) end) else if updater then updater:Disconnect(); updater = nil end end
            end)

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

        function Elements:Input(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 55)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = "$Text", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local InputContainer = Create("Frame", {Parent = Frame, BackgroundColor3 = "$ValueBox", Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30)}); Create("UICorner", {Parent = InputContainer, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = InputContainer, Color = "$Stroke", Thickness = 1})
            local Box = Create("TextBox", {Parent = InputContainer, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), Font = Keyser.Font, Text = "", PlaceholderText = Cfg.Placeholder or "Search...", TextColor3 = "$Text", PlaceholderColor3 = "$TextDark", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            AttachTooltip(Frame, Cfg.Description); table.insert(SearchableElements, {Obj = Frame, Name = Cfg.Name})
            Box:GetPropertyChangedSignal("Text"):Connect(function() if Cfg.Callback then pcall(Cfg.Callback, Box.Text) end end)
        end

        function Elements:List(Cfg)
            local ListObj = {}
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Cfg.Height or 150)})
            local Scroll = Create("ScrollingFrame", {Parent = Frame, BackgroundColor3 = "$ValueBox", Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = "$Stroke", CanvasSize = UDim2.new(0,0,0,0)}); Create("UICorner", {Parent = Scroll, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = Scroll, Color = "$Stroke", Thickness = 1})
            local ListLayout = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder}); Create("UIPadding", {Parent = Scroll, PaddingLeft = UDim.new(0, 5)})
            AttachTooltip(Frame, Cfg.Description)
            
            local Items = {}; ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y) end)
            for _, v in pairs(Cfg.Items) do
                local Btn = Create("TextButton", {Parent = Scroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Font = Keyser.Font, Text = "  "..v, TextColor3 = "$TextDark", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                Btn.MouseButton1Click:Connect(function() for _, b in pairs(Items) do b.Obj.TextColor3 = Keyser.Colors.TextDark end; Btn.TextColor3 = Keyser.Colors.Text; if Cfg.Callback then pcall(Cfg.Callback, v) end end)
                table.insert(Items, {Obj = Btn, Val = v})
            end
            function ListObj:Filter(txt) for _, item in pairs(Items) do item.Obj.Visible = string.find(string.lower(item.Val), string.lower(txt or "")) ~= nil end end
            return ListObj
        end

        function Elements:Button(Cfg)
            local Btn = Create("TextButton", {Parent = TargetParent, BackgroundColor3 = "$Element", Size = UDim2.new(1, 0, 0, 32), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = "$TextDark", TextSize = 12, AutoButtonColor = false}); Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = Btn, Color = "$Stroke", Thickness = 1})
            AttachTooltip(Btn, Cfg.Description); table.insert(SearchableElements, {Obj = Btn, Name = Cfg.Name})
            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Keyser.Colors.Hover, TextColor3 = Keyser.Colors.Text}) end); Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Keyser.Colors.Element, TextColor3 = Keyser.Colors.TextDark}) end)
            Btn.MouseButton1Click:Connect(function() if Cfg.Callback then pcall(Cfg.Callback) end end)
        end
        
        return Elements
    end

    function WinData:Tab(Config)
        local TabObj = {}
        local TopButtonsFrame = Create("Frame", {Parent = NavContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
        Create("UIListLayout", {Parent = TopButtonsFrame, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 15)})

        local SideBtn = Create("TextButton", {Parent = SideContainer, BackgroundColor3 = "$Element", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Text = "", AutoButtonColor = false})
        Create("UICorner", {Parent = SideBtn, CornerRadius = UDim.new(0, 4)})

        local Icon = Create("ImageLabel", {Parent = SideBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), Image = Config.Icon or "", ImageColor3 = "$TextDark"})
        local Label = Create("TextLabel", {Parent = SideBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -40, 1, 0), Font = Keyser.FontBold, Text = Config.Name, TextColor3 = "$TextDark", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        
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
            Tween(SideBtn, {BackgroundTransparency = 0}); Tween(Label, {TextColor3 = Keyser.Colors.Text}); Tween(Icon, {ImageColor3 = Keyser.Colors.Text})
            TopButtonsFrame.Visible = true; if TabObj.ActiveTop then TabObj.ActiveTop:Activate() elseif #TabObj.TopTabs > 0 then TabObj.TopTabs[1]:Activate() end
        end

        SideBtn.MouseButton1Click:Connect(ActivateSidebar)
        TabObj.Activate = ActivateSidebar; TabObj.Btn = SideBtn; TabObj.Label = Label; TabObj.Icon = Icon; TabObj.TopButtonsFrame = TopButtonsFrame

        function TabObj:Page(Name)
            local PageObj = {}
            local TopBtn = Create("TextButton", {Parent = TopButtonsFrame, BackgroundColor3 = "$Element", BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, -20), Font = Keyser.FontBold, Text = Name, TextColor3 = "$TextDark", TextSize = 13, AutomaticSize = Enum.AutomaticSize.X})
            Create("UICorner", {Parent = TopBtn, CornerRadius = UDim.new(0, 4)}); Create("UIPadding", {Parent = TopBtn, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)})

            local PageFrame = Create("Frame", {Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
            Create("UIPadding", {Parent = PageFrame, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})

            local LeftCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.485, 0, 1, 0)})
            local RightCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.485, 0, 1, 0), Position = UDim2.new(0.515, 0, 0, 0)})
            Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})
            Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})

            function PageObj:Activate()
                if TabObj.ActiveTop and TabObj.ActiveTop ~= PageObj then Tween(TabObj.ActiveTop.Btn, {BackgroundTransparency = 1, TextColor3 = Keyser.Colors.TextDark}); TabObj.ActiveTop.Page.Visible = false end
                TabObj.ActiveTop = PageObj; Tween(TopBtn, {BackgroundTransparency = 0, TextColor3 = Keyser.Colors.Text}); PageFrame.Visible = true
            end

            TopBtn.MouseButton1Click:Connect(function() PageObj:Activate() end)
            PageObj.Btn = TopBtn; PageObj.Page = PageFrame
            table.insert(TabObj.TopTabs, PageObj)

            local SectionLib = {}
            function SectionLib:Section(SecConfig)
                local Col = (SecConfig.Side == "Right" and RightCol) or LeftCol
                local Groupbox = Create("Frame", {Parent = Col, BackgroundColor3 = "$SectionBg", Size = UDim2.new(1, 0, 0, SecConfig.Height or 0), AutomaticSize = SecConfig.Height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y})
                Create("UICorner", {Parent = Groupbox, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Groupbox, Color = "$Stroke", Thickness = 1})

                local HeaderFrame = Create("Frame", {Parent = Groupbox, BackgroundColor3 = "$SectionHeader", Size = UDim2.new(1, 0, 0, 38), BorderSizePixel = 0})
                Create("UICorner", {Parent = HeaderFrame, CornerRadius = UDim.new(0, 6)})
                Create("Frame", {Parent = HeaderFrame, BackgroundColor3 = "$SectionHeader", Position = UDim2.new(0,0,1,-6), Size = UDim2.new(1,0,0,6), BorderSizePixel = 0}) 
                Create("TextLabel", {Parent = HeaderFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -15, 1, 0), Font = Keyser.FontBold, Text = SecConfig.Name, TextColor3 = "$Text", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                
                table.insert(SearchableElements, {Obj = Groupbox, Name = SecConfig.Name})

                local ContentFrame
                if SecConfig.Height then ContentFrame = Create("ScrollingFrame", {Parent = Groupbox, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 1, -38), ScrollBarThickness = 2, ScrollBarImageColor3 = "$Stroke", CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel = 0})
                else ContentFrame = Create("Frame", {Parent = Groupbox, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}) end
                
                local CList = Create("UIListLayout", {Parent = ContentFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
                Create("UIPadding", {Parent = ContentFrame, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10)})
                if SecConfig.Height then CList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() ContentFrame.CanvasSize = UDim2.new(0, 0, 0, CList.AbsoluteContentSize.Y + 20) end) end
                
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
