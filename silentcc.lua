--[[
    SKECH / PURPLE HAZE UI 
    Professional Cheat Interface
    Based on Airflow/Fatality Logic
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local Library = {
    Flags = {},
    Theme = {
        Main = Color3.fromRGB(18, 18, 22), -- Fundo bem escuro
        Sidebar = Color3.fromRGB(22, 22, 26),
        Section = Color3.fromRGB(26, 26, 32),
        Stroke = Color3.fromRGB(45, 45, 50),
        Text = Color3.fromRGB(220, 220, 220),
        TextDark = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(170, 110, 255), -- O Roxo da imagem
        Accent2 = Color3.fromRGB(130, 60, 220), -- Gradiente mais escuro
        Risky = Color3.fromRGB(255, 50, 50)
    },
    Open = true,
    Keybind = Enum.KeyCode.RightShift
}

-- Funções Utilitárias
local function Create(class, props)
    local instance = Instance.new(class)
    for k, v in pairs(props) do instance[k] = v end
    return instance
end

local function ApplyGradient(obj)
    local g = Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, Library.Theme.Accent2)
        },
        Rotation = 45,
        Parent = obj
    })
    return g
end

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true; DragStart = input.Position; StartPosition = object.Position
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            TweenService:Create(object, TweenInfo.new(0.1), {Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)}):Play()
        end
    end)
    topbarobject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)
end

-- Sistema de Watermark
function Library:Watermark(text)
    local Screen = Create("ScreenGui", {Parent = CoreGui, Name = "SkechWatermark", ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    local Main = Create("Frame", {
        Parent = Screen, BackgroundColor3 = Library.Theme.Main,
        BorderSizePixel = 0, Position = UDim2.new(0.01, 0, 0.01, 0), Size = UDim2.new(0, 0, 0, 26),
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Main})
    Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = Main})
    
    -- Top Line Gradient
    local Line = Create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundColor3 = Library.Theme.Accent})
    ApplyGradient(Line)
    
    local Label = Create("TextLabel", {
        Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 0, 1, 0),
        Font = Enum.Font.GothamBold, Text = text, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local size = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.GothamBold, Vector2.new(1000, 1000))
    Main.Size = UDim2.new(0, size.X + 20, 0, 26)
    MakeDraggable(Main, Main)
end

-- Janela Principal
function Library:Window(Config)
    Library.Keybind = Config.Keybind or Enum.KeyCode.RightShift
    
    local Screen = Create("ScreenGui", {Parent = CoreGui, Name = "SkechUI", ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true})
    
    local Main = Create("Frame", {
        Parent = Screen, BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(0.5, -350, 0.5, -250), Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Main})
    Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = Main})
    
    MakeDraggable(Main, Main)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = Main, BackgroundColor3 = Library.Theme.Sidebar,
        Size = UDim2.new(0, 60, 1, 0), BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})
    
    local Logo = Create("ImageLabel", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 15),
        Size = UDim2.new(0, 40, 0, 40), Image = "rbxassetid://14623785968" -- Ícone estilo cheat
    })
    ApplyGradient(Logo)

    local TabContainer = Create("Frame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 80), Size = UDim2.new(1, 0, 1, -80)
    })
    local TabList = Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center})

    -- Content
    local Pages = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 70, 0, 10), Size = UDim2.new(1, -80, 1, -20)
    })
    
    -- Breadcrumb (Ex: MAIN > AIMBOT)
    local Breadcrumb = Create("TextLabel", {
        Parent = Pages, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold, Text = "", TextColor3 = Library.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Toggle Key Handler
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Library.Keybind then
            Library.Open = not Library.Open
            Screen.Enabled = Library.Open
        end
    end)

    local Tabs = {}
    local First = true

    function Tabs:Tab(Config)
        local TabBtn = Create("ImageButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24),
            Image = Config.Icon, ImageColor3 = Library.Theme.TextDark
        })

        local SelectedBar = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Library.Theme.Accent,
            Position = UDim2.new(0, -18, 0, 0), Size = UDim2.new(0, 3, 1, 0), Visible = false
        })
        ApplyGradient(SelectedBar)

        local Page = Create("ScrollingFrame", {
            Parent = Pages, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 1, -30),
            ScrollBarThickness = 0, Visible = false
        })
        
        local LeftCol = Create("Frame", {Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(0.49, 0, 1, 0)})
        Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        
        local RightCol = Create("Frame", {Parent = Page, BackgroundTransparency = 1, Position = UDim2.new(0.51, 0, 0, 0), Size = UDim2.new(0.49, 0, 1, 0)})
        Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

        local function Activate()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("ImageButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.TextDark}):Play()
                    v.Frame.Visible = false
                end
            end
            for _, v in pairs(Pages:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            
            Page.Visible = true
            SelectedBar.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.Accent}):Play()
            Breadcrumb.Text = "MAIN > " .. string.upper(Config.Name)
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        if First then First = false; Activate() end

        local Sections = {}
        
        function Sections:Section(SecConfig)
            local Parent = (SecConfig.Side == "Right" and RightCol) or LeftCol
            local Section = Create("Frame", {
                Parent = Parent, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 100) -- Auto resize
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Section})
            Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = Section})
            
            local Header = Create("TextLabel", {
                Parent = Section, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -10, 0, 30),
                Font = Enum.Font.GothamBold, Text = SecConfig.Name, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Container = Create("Frame", {
                Parent = Section, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 0)
            })
            local List = Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
            Create("UIPadding", {Parent = Container, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
            
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 10)
                Section.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 40)
            end)

            local Elements = {}

            -- OPTION SYSTEM (The Gear Icon logic)
            local function CreateOptionMenu(parentFrame, options)
                local Gear = Create("ImageButton", {
                    Parent = parentFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -15, 0, 0), Size = UDim2.new(0, 12, 0, 12),
                    Image = "rbxassetid://10734950309", ImageColor3 = Library.Theme.TextDark, AnchorPoint = Vector2.new(0, 0.5)
                })
                Gear.Position = UDim2.new(1, -15, 0.5, 0)

                local Menu = Create("Frame", {
                    Parent = Screen, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(0, 120, 0, 0),
                    Visible = false, ZIndex = 10
                })
                Create("UIStroke", {Color = Library.Theme.Stroke, Parent = Menu})
                Create("UIListLayout", {Parent = Menu, SortOrder = Enum.SortOrder.LayoutOrder})
                
                Gear.MouseButton1Click:Connect(function()
                    Menu.Visible = not Menu.Visible
                    Menu.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
                end)

                -- Generic Option adder
                local Opts = {}
                function Opts:AddColorPicker(name, default, callback)
                    local Btn = Create("TextButton", {
                        Parent = Menu, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25),
                        Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham
                    })
                    -- Simple color implementation placeholder
                    Btn.MouseButton1Click:Connect(function() callback(Color3.new(1,0,0)) end) 
                    Menu.Size = UDim2.new(0, 120, 0, Menu.UIListLayout.AbsoluteContentSize.Y)
                end
                
                function Opts:AddKeybind(name, default, callback)
                    local Btn = Create("TextButton", {
                        Parent = Menu, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25),
                        Text = name .. ": " .. (default.Name or "None"), TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham
                    })
                    local binding = false
                    Btn.MouseButton1Click:Connect(function()
                        binding = true
                        Btn.Text = "..."
                        local input = UserInputService.InputBegan:Wait()
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            binding = false
                            Btn.Text = name .. ": " .. input.KeyCode.Name
                            callback(input.KeyCode)
                        end
                    end)
                    Menu.Size = UDim2.new(0, 120, 0, Menu.UIListLayout.AbsoluteContentSize.Y)
                end
                return Opts
            end

            function Elements:Toggle(Config)
                local Frame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)})
                local Label = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0),
                    Text = Config.Name, Font = Enum.Font.GothamMedium, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                local Switch = Create("Frame", {
                    Parent = Frame, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Position = UDim2.new(1, -50, 0.5, -8), Size = UDim2.new(0, 30, 0, 16)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
                
                local Dot = Create("Frame", {
                    Parent = Switch, BackgroundColor3 = Color3.fromRGB(150, 150, 150), Position = UDim2.new(0, 2, 0.5, -6), Size = UDim2.new(0, 12, 0, 12)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})
                
                local Button = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
                
                local state = Config.Default or false
                local function Update()
                    if state then
                        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Accent}):Play()
                        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)}):Play()
                    else
                        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    end
                    if Config.Callback then Config.Callback(state) end
                end
                
                Button.MouseButton1Click:Connect(function() state = not state; Update() end)
                if state then Update() end

                -- Attach Option Menu
                local Options = CreateOptionMenu(Frame)
                return Options -- Returns options so you can :AddKeybind etc
            end

            function Elements:Slider(Config)
                local Frame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
                local Label = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                    Text = Config.Name, Font = Enum.Font.GothamMedium, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                local Value = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 0, 20),
                    Text = tostring(Config.Default), Font = Enum.Font.Gotham, TextColor3 = Library.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
                })
                local Bar = Create("Frame", {
                    Parent = Frame, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, -20, 0, 4)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Bar})
                
                local Fill = Create("Frame", {
                    Parent = Bar, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new(0, 0, 1, 0)
                })
                local Gradient = ApplyGradient(Fill)
                
                local Knob = Create("Frame", {
                    Parent = Fill, BackgroundColor3 = Color3.new(1,1,1), Position = UDim2.new(1, -4, 0.5, -4), Size = UDim2.new(0, 8, 0, 8)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})

                local dragging = false
                local function Update(input)
                    local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local val = Config.Min + (Config.Max - Config.Min) * p
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    Value.Text = string.format("%.1f", val)
                    if Config.Callback then Config.Callback(val) end
                end

                local Btn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,20), Size = UDim2.new(1, -20, 0, 15), Text = ""})
                Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
            end

            function Elements:Dropdown(Config)
                local Frame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45), ZIndex = 2})
                local Label = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Text = Config.Name, Font = Enum.Font.GothamMedium, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                local Main = Create("TextButton", {
                    Parent = Frame, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Position = UDim2.new(0, 0, 0, 18), Size = UDim2.new(1, -20, 0, 22),
                    Text = "  " .. (Config.Multi and "Select..." or Config.Default), TextColor3 = Library.Theme.TextDark, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
                })
                Create("UIStroke", {Color = Library.Theme.Stroke, Parent = Main})
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Main})

                local List = Create("Frame", {
                    Parent = Main, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Position = UDim2.new(0, 0, 1, 2), Size = UDim2.new(1, 0, 0, 0),
                    Visible = false, ZIndex = 5, ClipsDescendants = true
                })
                Create("UIStroke", {Color = Library.Theme.Stroke, Parent = List})
                local Layout = Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})

                local opened = false
                Main.MouseButton1Click:Connect(function()
                    opened = not opened
                    List.Visible = opened
                    local height = #Config.Options * 22
                    TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, opened and height or 0)}):Play()
                    Frame.Size = UDim2.new(1, 0, 0, opened and 45 + height or 45)
                end)

                local selected = {}
                
                for _, opt in pairs(Config.Options) do
                    local Btn = Create("TextButton", {
                        Parent = List, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
                        Text = "  " .. opt, TextColor3 = Library.Theme.TextDark, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    Btn.MouseButton1Click:Connect(function()
                        if Config.Multi then
                            if table.find(selected, opt) then
                                table.remove(selected, table.find(selected, opt))
                                Btn.TextColor3 = Library.Theme.TextDark
                            else
                                table.insert(selected, opt)
                                Btn.TextColor3 = Library.Theme.Accent
                            end
                            Main.Text = "  " .. table.concat(selected, ", ")
                            Config.Callback(selected)
                        else
                            Main.Text = "  " .. opt
                            Config.Callback(opt)
                            opened = false
                            List.Visible = false
                            Frame.Size = UDim2.new(1, 0, 0, 45)
                        end
                    end)
                end
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Library
