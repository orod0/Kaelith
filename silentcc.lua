--[[
    Skech/RedFlow Interface Remake (Purple/Silent Edit)
    Refactored for "Silent Aim" Aesthetic
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
        Main = Color3.fromRGB(14, 14, 14),       -- Fundo Principal (Quase preto)
        Sidebar = Color3.fromRGB(10, 10, 10),    -- Sidebar mais escura
        Section = Color3.fromRGB(18, 18, 18),    -- Fundo das Seções
        Stroke = Color3.fromRGB(30, 30, 30),     -- Bordas sutis
        Text = Color3.fromRGB(230, 230, 230),    -- Texto Claro
        TextDark = Color3.fromRGB(100, 100, 100),-- Texto Desativado
        Accent = Color3.fromRGB(170, 80, 255),   -- O ROXO/VIOLETA da imagem
        ToggleBg = Color3.fromRGB(25, 25, 25),   -- Fundo de inputs
    },
    Icons = {
        -- Ícones genéricos atualizados para o estilo
        Sword = "rbxassetid://10723405486",
        Eye = "rbxassetid://10723346959",
        User = "rbxassetid://10747373176",
        Car = "rbxassetid://10709789810",
        Settings = "rbxassetid://10734950309",
        Info = "rbxassetid://10723415903"
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

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
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
        Name = "SilentUI_" .. math.random(1,9999),
        Parent = get_hui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    protect_gui(UI)

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = UI,
        BackgroundColor3 = Library.Colors.Main,
        Position = UDim2.new(0.5, -350, 0.5, -250), -- Um pouco maior para caber o layout
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MainFrame})
    -- Borda roxa sutil
    Create("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Parent = MainFrame}) 

    MakeDraggable(MainFrame, MainFrame)

    -- Sidebar (Esquerda)
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Colors.Sidebar,
        Size = UDim2.new(0, 70, 1, 0), -- Sidebar fina estilo ícones
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Sidebar})
    
    -- Linha divisória da sidebar
    local SidebarLine = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Library.Colors.Stroke,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        ZIndex = 3
    })

    -- Logo Area (O peixe ASCII)
    local LogoFrame = Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        ZIndex = 4
    })
    
    -- O Logo ASCII complexo
    local LogoText = Create("TextLabel", {
        Parent = LogoFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 15),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.Code, -- Fonte Code para ASCII ficar alinhado
        Text = "}<((((*>",
        TextColor3 = Library.Colors.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    -- Efeito de brilho no logo
    local LogoGlow = Create("TextLabel", {
        Parent = LogoText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Code,
        Text = "}<((((*>",
        TextColor3 = Library.Colors.Accent,
        TextTransparency = 0.6,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 0
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -80),
        ScrollBarThickness = 0,
        ZIndex = 4
    })
    local TabLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 15),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    -- Título da página atual (MAIN > AIMBOT)
    local Breadcrumb = Create("TextLabel", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 90, 0, 20),
        Size = UDim2.new(1, -100, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "MAIN > SELECTION",
        TextColor3 = Library.Colors.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Content Area
    local Pages = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 90, 0, 50),
        Size = UDim2.new(1, -110, 1, -60)
    })

    local TabHandler = {}
    local FirstTab = true

    function TabHandler:Tab(Config)
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 40, 0, 40),
            Text = "",
            AutoButtonColor = false
        })

        -- Indicador Lateral (Roxo)
        local TabIndicator = Create("Frame", {
            Parent = TabButton,
            BackgroundColor3 = Library.Colors.Accent,
            Position = UDim2.new(0, -10, 0.15, 0),
            Size = UDim2.new(0, 2, 0.7, 0),
            Visible = false
        })
        -- Efeito de brilho no indicador
        Create("UICorner", {CornerRadius = UDim.new(0,2), Parent=TabIndicator})

        local TabIcon = Create("ImageLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -10, 0.5, -10),
            Size = UDim2.new(0, 20, 0, 20),
            Image = Config.Icon or Library.Icons.Sword,
            ImageColor3 = Library.Colors.TextDark
        })

        -- Page Construction
        local PageFrame = Create("ScrollingFrame", {
            Name = Config.Name,
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Colors.Accent,
            Visible = false
        })

        -- Layout for Two Columns
        local LeftColumn = Create("Frame", {
            Parent = PageFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.49, 0, 1, 0)
        })
        local LeftList = Create("UIListLayout", {
            Parent = LeftColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })

        local RightColumn = Create("Frame", {
            Parent = PageFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.51, 0, 0, 0),
            Size = UDim2.new(0.49, 0, 1, 0)
        })
        local RightList = Create("UIListLayout", {
            Parent = RightColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })

        -- Tab Logic
        local function UpdateTab()
            -- Reset all
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.TextDark}):Play()
                    v.Frame.Visible = false
                end
            end
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end

            -- Activate
            PageFrame.Visible = true
            TabIndicator.Visible = true
            Breadcrumb.Text = "MAIN > " .. string.upper(Config.Name)
            
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.Accent}):Play()
        end

        TabButton.MouseButton1Click:Connect(UpdateTab)

        if FirstTab then
            FirstTab = false
            UpdateTab()
        end

        local SectionHandler = {}

        function SectionHandler:Section(SecConfig)
            local ParentCol = (SecConfig.Side == "Right" and RightColumn) or LeftColumn
            
            local SectionFrame = Create("Frame", {
                Parent = ParentCol,
                BackgroundColor3 = Library.Colors.Section,
                Size = UDim2.new(1, 0, 0, 30),
                ClipsDescendants = true
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SectionFrame})
            Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = SectionFrame})

            -- Header
            local Header = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30)
            })
            
            local HeaderLabel = Create("TextLabel", {
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = string.upper(SecConfig.Name),
                TextColor3 = Library.Colors.TextDark,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Content Container
            local Content = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0)
            })
            local ContentList = Create("UIListLayout", {
                Parent = Content,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
            Create("UIPadding", {Parent = Content, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})

            ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ContentList.AbsoluteContentSize.Y + 42)
                Content.Size = UDim2.new(1, 0, 0, ContentList.AbsoluteContentSize.Y)
            end)

            local Elements = {}

            function Elements:Toggle(TogConfig)
                local ToggleFrame = Create("Frame", {
                    Parent = Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24)
                })

                local Label = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.GothamSemibold,
                    Text = TogConfig.Name,
                    TextColor3 = Library.Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local SwitchBg = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Library.Colors.ToggleBg,
                    Position = UDim2.new(1, -34, 0.5, -8),
                    Size = UDim2.new(0, 34, 0, 16),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchBg})
                Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = SwitchBg})

                local SwitchCircle = Create("Frame", {
                    Parent = SwitchBg,
                    BackgroundColor3 = Library.Colors.TextDark,
                    Position = UDim2.new(0, 2, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchCircle})

                local Toggled = TogConfig.Default or false

                local function Update()
                    if Toggled then
                        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.Accent}):Play()
                        TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
                    else
                        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Library.Colors.ToggleBg}):Play()
                        TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Library.Colors.TextDark}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Library.Colors.Text}):Play()
                    end
                    if TogConfig.Callback then TogConfig.Callback(Toggled) end
                end

                SwitchBg.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                end)

                if Toggled then Update() end
            end

            function Elements:Slider(SlidConfig)
                local SliderContainer = Create("Frame", {
                    Parent = Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34)
                })

                local Label = Create("TextLabel", {
                    Parent = SliderContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.GothamSemibold,
                    Text = SlidConfig.Name,
                    TextColor3 = Library.Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Create("TextLabel", {
                    Parent = SliderContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = tostring(SlidConfig.Default or SlidConfig.Min),
                    TextColor3 = Library.Colors.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SlideBg = Create("TextButton", {
                    Parent = SliderContainer,
                    BackgroundColor3 = Library.Colors.ToggleBg,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 4),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideBg})

                local SlideFill = Create("Frame", {
                    Parent = SlideBg,
                    BackgroundColor3 = Library.Colors.Accent,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideFill})
                
                -- Círculo no final do slider (Estilo da imagem)
                local SlideKnob = Create("Frame", {
                    Parent = SlideFill,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Position = UDim2.new(1, -4, 0.5, -4),
                    Size = UDim2.new(0, 8, 0, 8),
                    ZIndex = 2
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideKnob})

                local Min, Max = SlidConfig.Min, SlidConfig.Max
                local Default = SlidConfig.Default or Min
                local dragging = false

                local function Set(value)
                    value = math.clamp(value, Min, Max)
                    local percent = (value - Min) / (Max - Min)
                    SlideFill.Size = UDim2.new(percent, 0, 1, 0)
                    ValueLabel.Text = tostring(math.floor(value * 10)/10) -- 1 casa decimal opcional
                    if SlidConfig.Callback then SlidConfig.Callback(value) end
                end

                SlideBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local sizeX = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * sizeX))
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local sizeX = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * sizeX))
                    end
                end)

                Set(Default)
            end

            function Elements:Dropdown(DropConfig)
                local IsOpen = false
                local DropFrame = Create("Frame", {
                    Parent = Content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45),
                    ClipsDescendants = true
                })

                local Label = Create("TextLabel", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.GothamSemibold,
                    Text = DropConfig.Name,
                    TextColor3 = Library.Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local MainBtn = Create("TextButton", {
                    Parent = DropFrame,
                    BackgroundColor3 = Library.Colors.ToggleBg,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 22),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. (DropConfig.Default or "Select..."),
                    TextColor3 = Library.Colors.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = MainBtn})
                Create("UIStroke", {Color = Library.Colors.Stroke, Thickness = 1, Parent = MainBtn})

                local Arrow = Create("ImageLabel", {
                    Parent = MainBtn,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -18, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Image = "rbxassetid://10709790948",
                    ImageColor3 = Library.Colors.TextDark
                })

                local ListContainer = Create("Frame", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 45),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true
                })
                local ListLayout = Create("UIListLayout", {Parent = ListContainer, SortOrder = Enum.SortOrder.LayoutOrder})

                local function Toggle()
                    IsOpen = not IsOpen
                    local count = #DropConfig.Options
                    local height = count * 22
                    
                    if IsOpen then
                        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45 + height)}):Play()
                        TweenService:Create(ListContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, height)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
                    else
                        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                        TweenService:Create(ListContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    end
                end

                MainBtn.MouseButton1Click:Connect(Toggle)

                for _, Option in pairs(DropConfig.Options) do
                    local OptBtn = Create("TextButton", {
                        Parent = ListContainer,
                        BackgroundColor3 = Library.Colors.Section,
                        Size = UDim2.new(1, 0, 0, 22),
                        Font = Enum.Font.Gotham,
                        Text = "  " .. Option,
                        TextColor3 = Library.Colors.Text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false
                    })

                    OptBtn.MouseButton1Click:Connect(function()
                        MainBtn.Text = "  " .. Option
                        MainBtn.TextColor3 = Color3.new(1,1,1)
                        Toggle()
                        if DropConfig.Callback then DropConfig.Callback(Option) end
                    end)
                end
            end

            return Elements
        end

        return SectionHandler
    end

    return TabHandler
end

return Library
