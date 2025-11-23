--[[
    Skech UI Remastered (Pixel Perfect)
    Refactored for specific "SKECH" Dark/Red Aesthetic
    Target: GTA V Style / Modern Cheat UI
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Proteção básica
local protect_gui = protectgui or (syn and syn.protect_gui) or function() end
local get_hui = (gethui and gethui()) or CoreGui

local Library = {
    Colors = {
        Main = Color3.fromRGB(10, 10, 10),       -- Fundo Principal (Mais escuro)
        Sidebar = Color3.fromRGB(13, 13, 13),    -- Sidebar
        Section = Color3.fromRGB(16, 16, 16),    -- Fundo das Seções
        Stroke = Color3.fromRGB(30, 30, 30),     -- Bordas Sutis
        Text = Color3.fromRGB(240, 240, 240),    -- Texto Principal
        TextDark = Color3.fromRGB(100, 100, 100),-- Texto Desabilitado/Secundário
        Accent = Color3.fromRGB(255, 30, 30),    -- Vermelho Vibrante SKECH
        Hover = Color3.fromRGB(25, 25, 25),
    },
    Fonts = {
        Title = Enum.Font.GothamBold,
        Element = Enum.Font.GothamMedium
    }
}

-- Utility Functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            local TargetPos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
            TweenService:Create(object, TweenInfo.new(0.05), {Position = TargetPos}):Play()
        end
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
        Name = "MainFrame", Parent = UI,
        BackgroundColor3 = Library.Colors.Main,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = false
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = MainFrame})
    Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = MainFrame})

    MakeDraggable(MainFrame, MainFrame)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar", Parent = MainFrame,
        BackgroundColor3 = Library.Colors.Sidebar,
        Size = UDim2.new(0, 180, 1, 0),
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Sidebar})
    -- Fix corner overlap visual
    Create("Frame", {
        Parent = Sidebar, BackgroundColor3 = Library.Colors.Sidebar, BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0, 0), Size = UDim2.new(0, 5, 1, 0), ZIndex = 1
    })

    -- Logo Area
    local LogoFrame = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 70), ZIndex = 2})
    local LogoText = Create("TextLabel", {
        Parent = LogoFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(1, -24, 1, 0), Font = Enum.Font.GothamBlack, Text = "SKECH",
        TextColor3 = Color3.fromRGB(15, 15, 15), TextSize = 32, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })
    -- Gradient/Overlay Effect for Logo
    local LogoOverlay = Create("TextLabel", {
        Parent = LogoText, BackgroundTransparency = 1, Position = UDim2.new(0, -2, 0, -2),
        Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = "SKECH",
        TextColor3 = Library.Colors.Accent, TextSize = 32, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3
    })
    local LogoGrad = Create("UIGradient", {
        Parent = LogoOverlay, Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library.Colors.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 20, 20))
        }, Rotation = 45
    })

    -- Navigation Container
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 1, -80), ScrollBarThickness = 0, ZIndex = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    local TabLayout = Create("UIListLayout", {
        Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)
    })

    -- Content Area
    local Pages = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 190, 0, 20),
        Size = UDim2.new(1, -200, 1, -50), ClipsDescendants = true
    })

    -- Footer
    local Footer = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Library.Colors.Sidebar, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -25), Size = UDim2.new(1, 0, 0, 25), ZIndex = 5
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Footer})
    -- Cover top corners of footer to blend
    Create("Frame", {
        Parent = Footer, BackgroundColor3 = Library.Colors.Sidebar, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 5), ZIndex = 5
    })
    Create("TextLabel", {
        Parent = Footer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold, Text = "SKECH [beta] for Grand Theft Auto V",
        TextColor3 = Library.Colors.TextDark, TextSize = 10, ZIndex = 6
    })

    local TabHandler = {}
    local CurrentTab = nil

    -- Function to Add Categories (The grey text between buttons)
    function TabHandler:Category(Text)
        local CatLabel = Create("TextLabel", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25),
            Font = Library.Fonts.Title, Text = "    " .. Text, TextColor3 = Library.Colors.TextDark,
            TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    function TabHandler:Tab(TabConfig)
        local TabButton = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32),
            Text = "", AutoButtonColor = false
        })

        -- The Red Line Indicator
        local ActiveLine = Create("Frame", {
            Parent = TabButton, BackgroundColor3 = Library.Colors.Accent,
            Position = UDim2.new(0, 0, 0.2, 0), Size = UDim2.new(0, 2, 0.6, 0),
            Visible = false
        })
        -- Glow for the line
        Create("ImageLabel", {
            Parent = ActiveLine, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 10, 1, 0), Image = "rbxassetid://100", -- Placeholder for shadow if needed, or use UIStroke
            Visible = false
        })

        local TabIcon = Create("ImageLabel", {
            Parent = TabButton, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16), Image = TabConfig.Icon or "",
            ImageColor3 = Library.Colors.TextDark
        })

        local TabLabel = Create("TextLabel", {
            Parent = TabButton, BackgroundTransparency = 1, Position = UDim2.new(0, 45, 0, 0),
            Size = UDim2.new(1, -45, 1, 0), Font = Library.Fonts.Element, Text = TabConfig.Name,
            TextColor3 = Library.Colors.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Page
        local PageFrame = Create("ScrollingFrame", {
            Name = TabConfig.Name, Parent = Pages, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 0, Visible = false,
            CanvasSize = UDim2.new(0,0,0,0)
        })

        -- Columns
        local LeftCol = Create("Frame", {
            Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.49, 0, 1, 0),
            Position = UDim2.new(0,0,0,0)
        })
        local LeftList = Create("UIListLayout", {
            Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)
        })

        local RightCol = Create("Frame", {
            Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.49, 0, 1, 0),
            Position = UDim2.new(0.51, 0, 0, 0)
        })
        local RightList = Create("UIListLayout", {
            Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)
        })

        local function UpdateTabState()
            -- Reset others
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v.TextLabel, TweenInfo.new(0.2), {TextColor3 = Library.Colors.TextDark})
                    Tween(v.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.TextDark})
                    v.Frame.Visible = false
                end
            end
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end

            -- Activate current
            PageFrame.Visible = true
            ActiveLine.Visible = true
            Tween(TabLabel, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)})
            Tween(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.Accent})
        end

        TabButton.MouseButton1Click:Connect(UpdateTabState)

        -- Select first tab automatically
        if not CurrentTab then
            CurrentTab = TabConfig.Name
            UpdateTabState()
        end

        local SectionHandler = {}

        function SectionHandler:Section(SecConfig)
            local ParentCol = (SecConfig.Side == "Right" and RightCol) or LeftCol
            
            local SectionContainer = Create("Frame", {
                Parent = ParentCol, BackgroundColor3 = Library.Colors.Section,
                Size = UDim2.new(1, 0, 0, 0), -- Auto Resize
                ClipsDescendants = true
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SectionContainer})
            Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = SectionContainer})

            -- Section Header
            local Header = Create("Frame", {
                Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32)
            })
            
            -- Header Icon
            local HIcon
            if SecConfig.Icon then
                HIcon = Create("ImageLabel", {
                    Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14), Image = SecConfig.Icon,
                    ImageColor3 = Library.Colors.Accent
                })
            end

            -- Header Title
            local TitlePos = (HIcon and 28) or 10
            local Title = Create("TextLabel", {
                Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, TitlePos, 0, 0),
                Size = UDim2.new(1, -50, 1, 0), Font = Library.Fonts.Title, Text = SecConfig.Name,
                TextColor3 = Color3.new(1,1,1), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Master Toggle (Optional in header)
            if SecConfig.MasterToggle then
                local MTog = Create("TextButton", {
                    Parent = Header, BackgroundColor3 = Library.Colors.Accent,
                    Position = UDim2.new(1, -34, 0.5, -7), Size = UDim2.new(0, 26, 0, 14),
                    Text = "", AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = MTog})
                
                local MCircle = Create("Frame", {
                    Parent = MTog, BackgroundColor3 = Color3.new(1,1,1),
                    Position = UDim2.new(1, -12, 0.5, -5), Size = UDim2.new(0, 10, 0, 10)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = MCircle})
                
                local MToggled = true
                MTog.MouseButton1Click:Connect(function()
                    MToggled = not MToggled
                    if MToggled then
                        Tween(MTog, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.Accent})
                        Tween(MCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -12, 0.5, -5)})
                    else
                        Tween(MTog, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,50,50)})
                        Tween(MCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -5)})
                    end
                end)
            end

            -- Elements Container
            local Content = Create("Frame", {
                Parent = SectionContainer, BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 0, 0)
            })
            local ContentList = Create("UIListLayout", {
                Parent = Content, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)
            })
            Create("UIPadding", {
                Parent = Content, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)
            })

            -- Resize Logic
            ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContainer.Size = UDim2.new(1, 0, 0, ContentList.AbsoluteContentSize.Y + 42)
            end)

            local Elements = {}

            -- 1. Checkbox (Square)
            function Elements:Checkbox(Cfg)
                local Frame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20)
                })
                
                local Label = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 1, 0),
                    Font = Library.Fonts.Element, Text = Cfg.Name, TextColor3 = Library.Colors.TextDark,
                    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
                })

                local Box = Create("TextButton", {
                    Parent = Frame, BackgroundColor3 = Color3.fromRGB(20,20,20),
                    Position = UDim2.new(1, -16, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
                    Text = "", AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Box})
                Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = Box})

                local CheckInner = Create("Frame", {
                    Parent = Box, BackgroundColor3 = Library.Colors.Accent,
                    Position = UDim2.new(0.5, -4, 0.5, -4), Size = UDim2.new(0, 8, 0, 8),
                    BackgroundTransparency = 1
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = CheckInner})

                local Active = Cfg.Default or false
                local function Update()
                    if Active then
                        Tween(CheckInner, TweenInfo.new(0.15), {BackgroundTransparency = 0})
                        Tween(Label, TweenInfo.new(0.15), {TextColor3 = Library.Colors.Text})
                    else
                        Tween(CheckInner, TweenInfo.new(0.15), {BackgroundTransparency = 1})
                        Tween(Label, TweenInfo.new(0.15), {TextColor3 = Library.Colors.TextDark})
                    end
                    if Cfg.Callback then Cfg.Callback(Active) end
                end

                Box.MouseButton1Click:Connect(function() Active = not Active; Update() end)
                if Active then Update() end
            end

            -- 2. Slider (Thin Line)
            function Elements:Slider(Cfg)
                local Frame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32)
                })
                
                local Label = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(0.5, 0, 0, 15), Font = Library.Fonts.Element, Text = Cfg.Name,
                    TextColor3 = Library.Colors.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0,0),
                    Size = UDim2.new(0.5, 0, 0, 15), Font = Library.Fonts.Element, 
                    Text = tostring(Cfg.Default or Cfg.Min),
                    TextColor3 = Library.Colors.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBg = Create("TextButton", {
                    Parent = Frame, BackgroundColor3 = Color3.fromRGB(35,35,35),
                    Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 4),
                    Text = "", AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = SliderBg})

                local SliderFill = Create("Frame", {
                    Parent = SliderBg, BackgroundColor3 = Library.Colors.Accent,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = SliderFill})

                local Min, Max = Cfg.Min, Cfg.Max
                local Default = Cfg.Default or Min
                local Dragging = false

                local function Set(val)
                    val = math.clamp(val, Min, Max)
                    local Pct = (val - Min) / (Max - Min)
                    SliderFill.Size = UDim2.new(Pct, 0, 1, 0)
                    ValueLabel.Text = tostring(math.floor(val * 10)/10)
                    if Cfg.Callback then Cfg.Callback(val) end
                end

                SliderBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        local X = math.clamp((inp.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * X))
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
                end)
                
                UserInputService.InputChanged:Connect(function(inp)
                    if Dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local X = math.clamp((inp.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * X))
                    end
                end)

                Set(Default)
            end

            -- 3. Color Picker (Visual)
            function Elements:ColorPicker(Cfg)
                local Frame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20)
                })

                local Label = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 1, 0),
                    Font = Library.Fonts.Element, Text = Cfg.Name, TextColor3 = Library.Colors.TextDark,
                    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
                })

                local PickerBtn = Create("TextButton", {
                    Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12), Text = "", AutoButtonColor = false
                })
                
                -- Circle Visual
                local ColorCircle = Create("Frame", {
                    Parent = PickerBtn, BackgroundColor3 = Cfg.Default or Color3.fromRGB(0, 255, 255),
                    Size = UDim2.new(1, 0, 1, 0)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ColorCircle})
                Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = ColorCircle})

                -- Placeholder Interaction (Would open a palette in a full suite)
                PickerBtn.MouseButton1Click:Connect(function()
                    if Cfg.Callback then Cfg.Callback(ColorCircle.BackgroundColor3) end
                end)
            end

            -- 4. Keybind
            function Elements:Keybind(Cfg)
                 local Frame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20)
                })
                
                Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Library.Fonts.Element, Text = Cfg.Name, TextColor3 = Library.Colors.TextDark,
                    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
                })

                local KeyLabel = Create("TextButton", {
                    Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.6, 0, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0), Font = Library.Fonts.Element,
                    Text = (Cfg.Default and Cfg.Default.Name) or "None",
                    TextColor3 = Library.Colors.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right
                })

                local Binding = false
                KeyLabel.MouseButton1Click:Connect(function()
                    KeyLabel.Text = "..."
                    Binding = true
                    local Input = UserInputService.InputBegan:Wait()
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        KeyLabel.Text = Input.KeyCode.Name
                        if Cfg.Callback then Cfg.Callback(Input.KeyCode) end
                    else
                        KeyLabel.Text = "None"
                    end
                    Binding = false
                end)
            end

            return Elements
        end

        return SectionHandler
    end

    return TabHandler
end

return Library
