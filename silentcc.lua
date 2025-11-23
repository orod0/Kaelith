--[[
    Skech UI Remastered
    Inspired by Fatality logic + Skech Aesthetic
    Features: ColorPicker, Keybinds, Smooth Animations, Options
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Proteção e Parent
local protect_gui = protectgui or (syn and syn.protect_gui) or function() end
local get_hui = (gethui and gethui()) or CoreGui

local Library = {
    Opened = true,
    Colors = {
        Main = Color3.fromRGB(15, 15, 15),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Section = Color3.fromRGB(22, 22, 22),
        Stroke = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(220, 220, 220),
        TextDark = Color3.fromRGB(120, 120, 120),
        Accent = Color3.fromRGB(255, 40, 40), -- O Vermelho Skech
        ToggleBg = Color3.fromRGB(40, 40, 40),
        Hover = Color3.fromRGB(45, 45, 45)
    },
    ActiveTweens = {},
    Icons = {
        Arrow = "rbxassetid://10709790948",
        Check = "rbxassetid://10709790644",
        Alpha = "rbxassetid://10709791437" -- Checkerboard pattern or simple icon
    }
}

-- Utility Functions
local function Create(class, props)
    local instance = Instance.new(class)
    for k, v in pairs(props) do
        instance[k] = v
    end
    return instance
end

local function Tween(instance, info, props)
    local tween = TweenService:Create(instance, info, props)
    tween:Play()
    return tween
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        Tween(object, TweenInfo.new(0.1), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        })
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- Notifier System
function Library:Notify(config)
    local title = config.Title or "Skech"
    local content = config.Content or "Notification"
    local duration = config.Duration or 3

    local gui = get_hui:FindFirstChild("SkechNotify")
    if not gui then
        gui = Create("ScreenGui", {Name = "SkechNotify", Parent = get_hui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
        protect_gui(gui)
    end
    
    local container = gui:FindFirstChild("Container")
    if not container then
        container = Create("Frame", {
            Name = "Container", Parent = gui, BackgroundTransparency = 1,
            Position = UDim2.new(1, -220, 1, -20), Size = UDim2.new(0, 200, 1, 0),
            AnchorPoint = Vector2.new(0, 1)
        })
        local list = Create("UIListLayout", {
            Parent = container, SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)
        })
    end
    
    local frame = Create("Frame", {
        Parent = container, BackgroundColor3 = Library.Colors.Section,
        Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = frame})
    Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = frame})
    
    local line = Create("Frame", {
        Parent = frame, BackgroundColor3 = Library.Colors.Accent,
        Size = UDim2.new(0, 2, 1, 0)
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -10, 0, 20), Font = Enum.Font.GothamBold,
        Text = title, TextColor3 = Library.Colors.Accent, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local msgLabel = Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -10, 0, 20), Font = Enum.Font.GothamMedium,
        Text = content, TextColor3 = Library.Colors.Text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Animation In
    Tween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 50)})
    
    task.delay(duration, function()
        Tween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        task.wait(0.3)
        frame:Destroy()
    end)
end

function Library:Window(Config)
    local UI = Create("ScreenGui", {
        Name = "SkechUI_" .. math.random(1,9999),
        Parent = get_hui,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true
    })
    protect_gui(UI)

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = UI,
        BackgroundColor3 = Library.Colors.Main,
        Position = UDim2.new(0.5, -325, 0.5, -225),
        Size = UDim2.new(0, 650, 0, 450),
        ClipsDescendants = false -- Changed for popups
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = MainFrame})
    Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = MainFrame})

    MakeDraggable(MainFrame, MainFrame)

    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == (Config.Keybind or Enum.KeyCode.RightControl) then
            Library.Opened = not Library.Opened
            UI.Enabled = Library.Opened
        end
    end)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar", Parent = MainFrame, BackgroundColor3 = Library.Colors.Sidebar,
        Size = UDim2.new(0, 160, 1, 0), BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})
    Create("Frame", { -- Cover rounded corner
        Parent = Sidebar, BackgroundColor3 = Library.Colors.Sidebar, BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0, 0), Size = UDim2.new(0, 5, 1, 0), ZIndex = 1
    })

    -- Logo
    local LogoFrame = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60), ZIndex = 2})
    local LogoText = Create("TextLabel", {
        Parent = LogoFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -20, 1, 0), Font = Enum.Font.GothamBlack, Text = "SKECH",
        TextColor3 = Library.Colors.Accent, TextSize = 28, TextXAlignment = Enum.TextXAlignment.Left
    })
    -- Shadow/Glow effect on logo
    Create("TextLabel", {
        Parent = LogoText, BackgroundTransparency = 1, Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = "SKECH",
        TextColor3 = Color3.fromRGB(0,0,0), TextSize = 28, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 0.5, ZIndex = 0
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -80), ScrollBarThickness = 0, ZIndex = 2
    })
    local TabLayout = Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})

    local Pages = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 170, 0, 10),
        Size = UDim2.new(1, -180, 1, -20), ClipsDescendants = true
    })

    local TabHandler = {}
    local CurrentPage = nil

    function TabHandler:Tab(TabConfig)
        local TabButton = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40),
            Text = "", AutoButtonColor = false
        })

        local TabIndicator = Create("Frame", {
            Parent = TabButton, BackgroundColor3 = Library.Colors.Accent,
            Position = UDim2.new(0, 0, 0.2, 0), Size = UDim2.new(0, 0, 0.6, 0), Visible = true -- Start size 0 width
        })

        local TabLabel = Create("TextLabel", {
            Parent = TabButton, BackgroundTransparency = 1, Position = UDim2.new(0, 25, 0, 0),
            Size = UDim2.new(1, -25, 1, 0), Font = Enum.Font.GothamBold, Text = TabConfig.Name,
            TextColor3 = Library.Colors.TextDark, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        if TabConfig.Icon then
            local Ico = Create("ImageLabel", {
                Parent = TabButton, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20), Image = TabConfig.Icon, ImageColor3 = Library.Colors.TextDark
            })
            TabLabel.Position = UDim2.new(0, 50, 0, 0)
        end

        local PageFrame = Create("ScrollingFrame", {
            Name = TabConfig.Name, Parent = Pages, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 0, Visible = false
        })
        
        local LeftCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.48, 0, 1, 0)})
        local LeftList = Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        
        local RightCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Position = UDim2.new(0.52, 0, 0, 0), Size = UDim2.new(0.48, 0, 1, 0)})
        local RightList = Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

        local function UpdateTab()
            if CurrentPage == PageFrame then return end
            
            -- Deactivate others
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v.TextLabel, TweenInfo.new(0.3), {TextColor3 = Library.Colors.TextDark})
                    Tween(v.Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0.6, 0)})
                    if v:FindFirstChild("ImageLabel") then Tween(v.ImageLabel, TweenInfo.new(0.3), {ImageColor3 = Library.Colors.TextDark}) end
                end
            end
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end

            -- Activate
            CurrentPage = PageFrame
            PageFrame.Visible = true
            Tween(TabLabel, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1)})
            Tween(TabIndicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 3, 0.6, 0)})
            if TabButton:FindFirstChild("ImageLabel") then Tween(TabButton.ImageLabel, TweenInfo.new(0.3), {ImageColor3 = Library.Colors.Accent}) end
        end

        TabButton.MouseButton1Click:Connect(UpdateTab)
        if CurrentPage == nil then UpdateTab() end -- Select first tab

        local SectionHandler = {}

        function SectionHandler:Section(SecConfig)
            local ParentCol = (SecConfig.Side == "Right" and RightCol) or LeftCol
            
            local SectionFrame = Create("Frame", {
                Parent = ParentCol, BackgroundColor3 = Library.Colors.Section,
                Size = UDim2.new(1, 0, 0, 30), ClipsDescendants = true
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = SectionFrame})
            Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = SectionFrame})

            local Header = Create("Frame", {Parent = SectionFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Create("TextLabel", {
                Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 1, 0), Font = Enum.Font.GothamBold, Text = SecConfig.Name,
                TextColor3 = Library.Colors.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
            })

            local Content = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0)
            })
            local ContentList = Create("UIListLayout", {Parent = Content, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
            Create("UIPadding", {Parent = Content, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})

            ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ContentList.AbsoluteContentSize.Y + 38)
            end)

            local Elements = {}

            -- Helper to create side options/color pickers
            local function CreateOptionContainer(parentFrame)
                local container = Create("Frame", {
                    Parent = parentFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(1, -5, 0.5, 0), Size = UDim2.new(0, 0, 1, 0), -- Grows to left
                    AnchorPoint = Vector2.new(1, 0.5)
                })
                local layout = Create("UIListLayout", {
                    Parent = container, FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)
                })
                
                -- Resize logic
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    container.Size = UDim2.new(0, layout.AbsoluteContentSize.X, 1, 0)
                end)
                return container
            end

            -- // TOGGLE ELEMENT //
            function Elements:Toggle(TogConfig)
                local ToggleFrame = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.GothamMedium, Text = TogConfig.Name, TextColor3 = Library.Colors.TextDark,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })

                local ButtonOuter = Create("TextButton", {
                    Parent = ToggleFrame, BackgroundColor3 = Library.Colors.ToggleBg,
                    Position = UDim2.new(1, -34, 0.5, -9), Size = UDim2.new(0, 34, 0, 18),
                    Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0) -- Adjusted for options
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ButtonOuter})
                local Circle = Create("Frame", {
                    Parent = ButtonOuter, BackgroundColor3 = Library.Colors.TextDark,
                    Position = UDim2.new(0, 2, 0.5, -7), Size = UDim2.new(0, 14, 0, 14)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

                local OptionContainer = CreateOptionContainer(ToggleFrame)
                ButtonOuter.Position = UDim2.new(1, 0, 0.5, -9) -- Reset Pos, Container handles offset
                
                -- Shift button left if options exist
                OptionContainer:GetPropertyChangedSignal("Size"):Connect(function()
                     ButtonOuter.Position = UDim2.new(1, -OptionContainer.Size.X.Offset - 5, 0.5, -9)
                end)

                local Toggled = TogConfig.Default or false

                local function Update()
                    if Toggled then
                        Tween(ButtonOuter, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.Accent})
                        Tween(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)})
                        Tween(Label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)})
                    else
                        Tween(ButtonOuter, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.ToggleBg})
                        Tween(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Library.Colors.TextDark})
                        Tween(Label, TweenInfo.new(0.2), {TextColor3 = Library.Colors.TextDark})
                    end
                    if TogConfig.Callback then TogConfig.Callback(Toggled) end
                end

                ButtonOuter.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                end)

                -- Extra Options Logic
                local Extras = {}
                
                function Extras:ColorPicker(CPConfig)
                    local CPBtn = Create("TextButton", {
                        Parent = OptionContainer, Size = UDim2.new(0, 25, 0, 14),
                        BackgroundColor3 = CPConfig.Default or Color3.new(1,1,1), Text = "",
                        AutoButtonColor = false, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0,0,0.5,0)
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = CPBtn})
                    
                    local Color = CPConfig.Default or Color3.new(1,1,1)
                    
                    -- Popup Logic
                    CPBtn.MouseButton1Click:Connect(function()
                        Library:OpenColorPicker(CPConfig.Title or "Color", Color, function(newColor)
                            Color = newColor
                            CPBtn.BackgroundColor3 = newColor
                            if CPConfig.Callback then CPConfig.Callback(newColor) end
                        end)
                    end)
                end

                if Toggled then Update() end
                return Extras
            end

            -- // SLIDER ELEMENT //
            function Elements:Slider(SlidConfig)
                local SliderFrame = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32)})
                local Label = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.GothamMedium, Text = SlidConfig.Name, TextColor3 = Library.Colors.TextDark,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                local ValueLabel = Create("TextBox", { -- Editable text box
                    Parent = SliderFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 15), Font = Enum.Font.GothamBold, Text = tostring(SlidConfig.Default or SlidConfig.Min),
                    TextColor3 = Color3.new(1,1,1), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
                    ClearTextOnFocus = false
                })

                local SlideBg = Create("TextButton", {
                    Parent = SliderFrame, BackgroundColor3 = Library.Colors.ToggleBg,
                    Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 6),
                    Text = "", AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideBg})

                local SlideFill = Create("Frame", {
                    Parent = SlideBg, BackgroundColor3 = Library.Colors.Accent,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideFill})

                local Circle = Create("Frame", { -- Handle
                    Parent = SlideFill, BackgroundColor3 = Color3.new(1,1,1),
                    Position = UDim2.new(1, -4, 0.5, -4), Size = UDim2.new(0, 8, 0, 8), Visible = false -- Show on hover
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

                local Min, Max = SlidConfig.Min, SlidConfig.Max
                local dragging = false

                local function Set(value)
                    value = math.clamp(value, Min, Max)
                    local percent = (value - Min) / (Max - Min)
                    Tween(SlideFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)})
                    ValueLabel.Text = tostring(math.floor(value * 100)/100) -- Precision
                    if SlidConfig.Callback then SlidConfig.Callback(value) end
                end

                SlideBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Circle.Visible = true
                        local sizeX = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * sizeX))
                    end
                end)
                
                SlideBg.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        dragging = false 
                        Circle.Visible = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local sizeX = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * sizeX))
                    end
                end)

                -- Manual Input
                ValueLabel.FocusLost:Connect(function()
                    local n = tonumber(ValueLabel.Text)
                    if n then Set(n) else ValueLabel.Text = tostring(math.floor((SlideFill.Size.X.Scale * (Max - Min)) + Min)) end
                end)

                Set(SlidConfig.Default or Min)
            end

            -- // DROPDOWN ELEMENT //
            function Elements:Dropdown(DropConfig)
                local IsOpen = false
                local DropFrame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 46), ClipsDescendants = true
                })
                
                Create("TextLabel", {
                    Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.GothamMedium, Text = DropConfig.Name, TextColor3 = Library.Colors.TextDark,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })

                local MainBtn = Create("TextButton", {
                    Parent = DropFrame, BackgroundColor3 = Library.Colors.ToggleBg,
                    Position = UDim2.new(0, 0, 0, 18), Size = UDim2.new(1, 0, 0, 24),
                    Text = "", AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = MainBtn})
                Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = MainBtn})
                
                local SelectedText = Create("TextLabel", {
                    Parent = MainBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -25, 1, 0), Font = Enum.Font.Gotham, Text = DropConfig.Default or "Select...",
                    TextColor3 = Library.Colors.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Arrow = Create("ImageLabel", {
                    Parent = MainBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12), Image = Library.Icons.Arrow, ImageColor3 = Library.Colors.TextDark
                })

                local ListContainer = Create("Frame", {
                    Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 46),
                    Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true
                })
                local ListLayout = Create("UIListLayout", {Parent = ListContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
                Create("UIPadding", {Parent = ListContainer, PaddingTop = UDim.new(0, 2)})

                local function Toggle()
                    IsOpen = not IsOpen
                    local count = #DropConfig.Options
                    local contentHeight = count * 22 + 4
                    
                    if IsOpen then
                        Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 46 + contentHeight)})
                        Tween(ListContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, contentHeight)})
                        Tween(Arrow, TweenInfo.new(0.3), {Rotation = 180})
                        Tween(MainBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.Section})
                    else
                        Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 46)})
                        Tween(ListContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)})
                        Tween(Arrow, TweenInfo.new(0.3), {Rotation = 0})
                        Tween(MainBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.ToggleBg})
                    end
                end

                MainBtn.MouseButton1Click:Connect(Toggle)

                for _, Option in ipairs(DropConfig.Options) do
                    local OptBtn = Create("TextButton", {
                        Parent = ListContainer, BackgroundColor3 = Library.Colors.ToggleBg,
                        Size = UDim2.new(1, 0, 0, 20), Text = " " .. Option, Font = Enum.Font.Gotham,
                        TextColor3 = Library.Colors.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = OptBtn})
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedText.Text = Option
                        SelectedText.TextColor3 = Color3.new(1,1,1)
                        Toggle()
                        if DropConfig.Callback then DropConfig.Callback(Option) end
                    end)
                    
                    -- Hover
                    OptBtn.MouseEnter:Connect(function() Tween(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.Hover, TextColor3 = Color3.new(1,1,1)}) end)
                    OptBtn.MouseLeave:Connect(function() Tween(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.ToggleBg, TextColor3 = Library.Colors.TextDark}) end)
                end
            end

            -- // KEYBIND ELEMENT //
            function Elements:Keybind(KeyConfig)
                local KeyFrame = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                Create("TextLabel", {
                    Parent = KeyFrame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Enum.Font.GothamMedium, Text = KeyConfig.Name, TextColor3 = Library.Colors.TextDark,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local BindBtn = Create("TextButton", {
                    Parent = KeyFrame, BackgroundColor3 = Library.Colors.ToggleBg,
                    Position = UDim2.new(1, -60, 0, 2), Size = UDim2.new(0, 60, 0, 20),
                    Text = KeyConfig.Default and KeyConfig.Default.Name or "None", Font = Enum.Font.GothamBold,
                    TextColor3 = Library.Colors.Text, TextSize = 11, AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = BindBtn})
                
                local Binding = false
                
                BindBtn.MouseButton1Click:Connect(function()
                    Binding = true
                    BindBtn.Text = "..."
                    
                    local inputConn
                    inputConn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Binding = false
                            if input.KeyCode == Enum.KeyCode.Backspace then
                                BindBtn.Text = "None"
                                if KeyConfig.Callback then KeyConfig.Callback(nil) end
                            else
                                BindBtn.Text = input.KeyCode.Name
                                if KeyConfig.Callback then KeyConfig.Callback(input.KeyCode) end
                            end
                            inputConn:Disconnect()
                        end
                    end)
                end)
            end
            
            -- // BUTTON ELEMENT //
            function Elements:Button(BtnConfig)
                 local BtnFrame = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28)})
                 local Btn = Create("TextButton", {
                    Parent = BtnFrame, BackgroundColor3 = Library.Colors.ToggleBg,
                    Size = UDim2.new(1, 0, 1, 0), Text = BtnConfig.Name, Font = Enum.Font.GothamBold,
                    TextColor3 = Library.Colors.Text, TextSize = 12, AutoButtonColor = false
                 })
                 Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Btn})
                 Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = Btn})
                 
                 Btn.MouseButton1Click:Connect(function()
                     if BtnConfig.Callback then BtnConfig.Callback() end
                     -- Click Effect
                     Tween(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Colors.Accent})
                     task.wait(0.1)
                     Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.ToggleBg})
                 end)
                 
                 Btn.MouseEnter:Connect(function() Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.Hover}) end)
                 Btn.MouseLeave:Connect(function() Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.ToggleBg}) end)
            end

            return Elements
        end

        return SectionHandler
    end
    
    -- COLOR PICKER MODAL
    function Library:OpenColorPicker(title, defaultColor, callback)
        local cpUI = Create("ScreenGui", {Parent = get_hui, ZIndexBehavior = Enum.ZIndexBehavior.Global, Name = "ColorPicker"})
        protect_gui(cpUI)
        
        -- Backdrop
        local bg = Create("TextButton", {
            Parent = cpUI, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.6,
            Size = UDim2.new(1,0,1,0), Text = "", AutoButtonColor = false
        })
        
        local frame = Create("Frame", {
            Parent = cpUI, BackgroundColor3 = Library.Colors.Main, Position = UDim2.new(0.5,-100, 0.5, -100),
            Size = UDim2.new(0, 200, 0, 240), ClipsDescendants = true
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = frame})
        Create("UIStroke", {Color = Library.Colors.Accent, Thickness = 1, Parent = frame})
        
        Create("TextLabel", {
            Parent = frame, Text = title, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1,
            TextColor3 = Library.Colors.Text, Font = Enum.Font.GothamBold, TextSize = 14
        })
        
        -- RGB Image
        local pickerImg = Create("ImageButton", {
            Parent = frame, Position = UDim2.new(0, 10, 0, 35), Size = UDim2.new(0, 150, 0, 150),
            Image = "rbxassetid://4155801252", AutoButtonColor = false
        })
        
        -- Hue Slider
        local hueImg = Create("ImageButton", {
            Parent = frame, Position = UDim2.new(0, 170, 0, 35), Size = UDim2.new(0, 20, 0, 150),
            Image = "rbxassetid://4155801252", AutoButtonColor = false
        })
        -- Create gradient for Hue
        local hueGrad = Create("UIGradient", {
            Parent = hueImg, Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
            }
        })
        
        local h, s, v = defaultColor:ToHSV()
        local color = defaultColor
        
        -- Logic helpers
        local function updateColor()
            color = Color3.fromHSV(h, s, v)
            pickerImg.BackgroundColor3 = Color3.fromHSV(h, 1, 1) -- Hue base
            callback(color)
        end
        
        -- Close Logic
        local closeBtn = Create("TextButton", {
            Parent = frame, Position = UDim2.new(0, 10, 1, -35), Size = UDim2.new(1, -20, 0, 25),
            BackgroundColor3 = Library.Colors.Section, Text = "Apply", TextColor3 = Library.Colors.Text,
            Font = Enum.Font.GothamBold, TextSize = 12
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = closeBtn})
        
        closeBtn.MouseButton1Click:Connect(function()
            cpUI:Destroy()
        end)
        bg.MouseButton1Click:Connect(function() cpUI:Destroy() end)
        
        -- Inputs
        local mouse = Players.LocalPlayer:GetMouse()
        local draggingHue, draggingSV = false, false
        
        hueImg.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true end end)
        pickerImg.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end end)
        UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false; draggingSV = false end end)
        
        UserInputService.InputChanged:Connect(function(inp)
            if draggingHue then
                local y = math.clamp(mouse.Y - hueImg.AbsolutePosition.Y, 0, 150)
                h = 1 - (y / 150)
                updateColor()
            elseif draggingSV then
                local x = math.clamp(mouse.X - pickerImg.AbsolutePosition.X, 0, 150)
                local y = math.clamp(mouse.Y - pickerImg.AbsolutePosition.Y, 0, 150)
                s = x / 150
                v = 1 - (y / 150)
                updateColor()
            end
        end)
        updateColor()
    end

    return TabHandler
end

return Library
