--[[
    SKECH UI Library (Remake)
    Theme: Internal Red/Dark
    Features: Keybinds, ColorPickers, Multi-Dropdowns, Options Menu
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Mouse = Players.LocalPlayer:GetMouse()

-- Proteção
local protect_gui = protectgui or (syn and syn.protect_gui) or function() end
local get_hui = (gethui and gethui()) or CoreGui

local Library = {
    Flags = {},
    Theme = {
        Main = Color3.fromRGB(18, 18, 18),
        Sidebar = Color3.fromRGB(23, 23, 23),
        Section = Color3.fromRGB(28, 28, 28),
        Stroke = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(225, 225, 225),
        TextDim = Color3.fromRGB(130, 130, 130),
        Accent = Color3.fromRGB(255, 40, 40), -- Vermelho SKECH
        ToggleBg = Color3.fromRGB(40, 40, 40),
        Glow = Color3.fromRGB(255, 0, 0)
    },
    Open = true,
    ToggleKey = Enum.KeyCode.RightShift
}

-- Utility
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function MakeDraggable(top, main)
    local dragging, dragInput, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(main, TweenInfo.new(0.05), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end

-- Color Picker Logic
local function CreateColorPicker(parentFrame, defaultColor, callback)
    local PickerFrame = Create("Frame", {
        Parent = parentFrame, BackgroundColor3 = Library.Theme.Main,
        BorderColor3 = Library.Theme.Stroke, Position = UDim2.new(1, 5, 0, 0),
        Size = UDim2.new(0, 180, 0, 170), Visible = false, ZIndex = 10
    })
    
    local HSVMap = Create("ImageButton", {
        Parent = PickerFrame, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 140, 0, 140),
        Image = "rbxassetid://4155801252", AutoButtonColor = false, ZIndex = 11
    })
    local Cursor = Create("Frame", {
        Parent = HSVMap, Size = UDim2.new(0, 6, 0, 6), BackgroundColor3 = Color3.new(1,1,1),
        BorderColor3 = Color3.new(0,0,0), Rotation = 45, ZIndex = 12
    })
    
    local HueBar = Create("ImageButton", {
        Parent = PickerFrame, Position = UDim2.new(0, 160, 0, 10), Size = UDim2.new(0, 10, 0, 140),
        Image = "rbxassetid://3641079629", AutoButtonColor = false, ZIndex = 11
    })
    local HueCursor = Create("Frame", {
        Parent = HueBar, Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Color3.new(1,1,1),
        BorderColor3 = Color3.new(0,0,0), ZIndex = 12
    })

    local Color = defaultColor or Color3.new(1,1,1)
    local H, S, V = Color:ToHSV()

    local function Update()
        Color = Color3.fromHSV(H, S, V)
        HSVMap.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
        callback(Color)
    end

    local draggingHue, draggingHSV = false, false

    HueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true end
    end)
    
    HSVMap.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHSV = true end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue, draggingHSV = false, false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingHue then
                local y = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                HueCursor.Position = UDim2.new(0, 0, y, 0)
                H = 1 - y
                Update()
            elseif draggingHSV then
                local x = math.clamp((input.Position.X - HSVMap.AbsolutePosition.X) / HSVMap.AbsoluteSize.X, 0, 1)
                local y = math.clamp((input.Position.Y - HSVMap.AbsolutePosition.Y) / HSVMap.AbsoluteSize.Y, 0, 1)
                Cursor.Position = UDim2.new(x, -3, y, -3)
                S = x
                V = 1 - y
                Update()
            end
        end
    end)
    
    return PickerFrame
end

-- Window Function
function Library:Window(Config)
    local Screen = Create("ScreenGui", {Name = "SkechUI", Parent = get_hui, IgnoreGuiInset = true})
    
    -- Watermark
    local Watermark = Create("Frame", {
        Parent = Screen, BackgroundColor3 = Library.Theme.Section,
        BorderSizePixel = 0, Position = UDim2.new(0.01, 0, 0.01, 0), Size = UDim2.new(0, 0, 0, 26),
        AutomaticSize = Enum.AutomaticSize.X
    })
    Create("UICorner", {Parent = Watermark, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = Watermark, Color = Library.Theme.Stroke, Thickness = 1})
    
    -- Accent Line on Watermark
    local WMBar = Create("Frame", {
        Parent = Watermark, BackgroundColor3 = Library.Theme.Accent,
        BorderSizePixel = 0, Size = UDim2.new(0, 2, 1, 0)
    })
    Create("UICorner", {Parent = WMBar, CornerRadius = UDim.new(0, 4)})
    
    local WMLabel = Create("TextLabel", {
        Parent = Watermark, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold, Text = "SKECH", TextSize = 12, TextColor3 = Library.Theme.Text
    })
    Create("UIPadding", {Parent = Watermark, PaddingRight = UDim.new(0, 10)})

    Library.SetWatermark = function(self, text)
        WMLabel.Text = text
    end

    -- Main Frame
    local Main = Create("Frame", {
        Parent = Screen, BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(0.5, -300, 0.5, -200), Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = false
    })
    Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = Main, Color = Library.Theme.Stroke, Thickness = 1})
    MakeDraggable(Main, Main)

    -- Toggle Logic
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            Main.Visible = Library.Open
        end
    end)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = Main, BackgroundColor3 = Library.Theme.Sidebar,
        Size = UDim2.new(0, 150, 1, 0)
    })
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 6)})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(0, 5, 1, 0), Position = UDim2.new(1, -5, 0, 0), BorderSizePixel = 0}) -- Fix corner

    -- Logo
    local Logo = Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 15),
        Size = UDim2.new(1, 0, 0, 30), Font = Enum.Font.GothamBlack, Text = "SKECH",
        TextColor3 = Library.Theme.Accent, TextSize = 26
    })
    -- Shadow for Logo
    Create("TextLabel", {
        Parent = Logo, BackgroundTransparency = 1, Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBlack, Text = "SKECH",
        TextColor3 = Color3.new(0,0,0), TextSize = 26, ZIndex = 0
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60), ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})

    local Pages = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 160, 0, 10),
        Size = UDim2.new(1, -170, 1, -20)
    })

    local Tabs = {}
    
    function Tabs:Tab(Config)
        local TabFrame = Create("ScrollingFrame", {
            Parent = Pages, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 0, Visible = false, Name = Config.Name
        })
        
        local LeftCol = Create("Frame", {Parent = TabFrame, BackgroundTransparency = 1, Size = UDim2.new(0.48, 0, 1, 0)})
        Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        
        local RightCol = Create("Frame", {Parent = TabFrame, BackgroundTransparency = 1, Size = UDim2.new(0.48, 0, 1, 0), Position = UDim2.new(0.52, 0, 0, 0)})
        Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

        local TabBtn = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35),
            Text = "", AutoButtonColor = false
        })
        
        local TabIcon = Create("ImageLabel", {
            Parent = TabBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18), Image = Config.Icon or "", ImageColor3 = Library.Theme.TextDim
        })
        
        local TabTitle = Create("TextLabel", {
            Parent = TabBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 0),
            Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.GothamBold, Text = Config.Name,
            TextColor3 = Library.Theme.TextDim, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local ActiveBar = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new(0, 2, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0), Visible = false
        })

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then
                    TweenService:Create(v.TextLabel, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextDim}):Play()
                    TweenService:Create(v.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.TextDim}):Play()
                    v.Frame.Visible = false
                end 
            end
            
            TabFrame.Visible = true
            ActiveBar.Visible = true
            TweenService:Create(TabTitle, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.Accent}):Play()
        end)

        -- Activate first tab
        if #Pages:GetChildren() == 1 then 
            TabFrame.Visible = true; ActiveBar.Visible = true; 
            TabTitle.TextColor3 = Color3.new(1,1,1); TabIcon.ImageColor3 = Library.Theme.Accent 
        end

        local Sections = {}
        
        function Sections:Section(Config)
            local Parent = (Config.Side == "Right" and RightCol) or LeftCol
            local Section = Create("Frame", {
                Parent = Parent, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 30),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = Section, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = Section, Color = Library.Theme.Stroke, Thickness = 1})
            
            Create("TextLabel", {
                Parent = Section, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 0, 30), Font = Enum.Font.GothamBold, Text = Config.Name,
                TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Content = Create("Frame", {
                Parent = Section, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0)
            })
            local Layout = Create("UIListLayout", {
                Parent = Content, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)
            })
            Create("UIPadding", {Parent = Content, PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
            
            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 40)
                Content.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
            end)

            local Items = {}

            function Items:Toggle(Config)
                local Toggled = Config.Default or false
                local Keybind = nil
                
                local ToggleFrame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)
                })
                
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Enum.Font.GothamMedium, Text = Config.Name, TextColor3 = Library.Theme.TextDim,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Button = Create("TextButton", {
                    Parent = ToggleFrame, BackgroundColor3 = Library.Theme.ToggleBg, Position = UDim2.new(1, -34, 0.5, -8),
                    Size = UDim2.new(0, 34, 0, 16), Text = "", AutoButtonColor = false
                })
                Create("UICorner", {Parent = Button, CornerRadius = UDim.new(1, 0)})
                
                local Circle = Create("Frame", {
                    Parent = Button, BackgroundColor3 = Color3.fromRGB(150, 150, 150), Position = UDim2.new(0, 2, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})

                -- OPTIONS BUTTON (Gear Icon)
                local OptionsBtn = Create("ImageButton", {
                    Parent = ToggleFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -55, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14), Image = Library.Icons.Settings, ImageColor3 = Library.Theme.TextDim
                })

                local OptionsFrame = Create("Frame", {
                    Parent = Main, BackgroundColor3 = Library.Theme.Main, BorderColor3 = Library.Theme.Stroke,
                    Size = UDim2.new(0, 150, 0, 0), Visible = false, ZIndex = 100, ClipsDescendants = true
                })
                Create("UIListLayout", {Parent = OptionsFrame, SortOrder = Enum.SortOrder.LayoutOrder})
                Create("UIPadding", {Parent = OptionsFrame, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5)})

                -- Options: Keybind
                local KeybindBtn = Create("TextButton", {
                    Parent = OptionsFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25),
                    Text = "Keybind: None", TextColor3 = Library.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 12
                })

                -- Options: ColorPicker
                local ColorBtn = Create("TextButton", {
                    Parent = OptionsFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25),
                    Text = "Color", TextColor3 = Library.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 12
                })
                local ColorPreview = Create("Frame", {
                    Parent = ColorBtn, Position = UDim2.new(1, -25, 0.5, -5), Size = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = Color3.new(1,1,1)
                })

                local Picker = CreateColorPicker(OptionsFrame, Color3.new(1,1,1), function(color)
                    ColorPreview.BackgroundColor3 = color
                    if Config.ColorCallback then Config.ColorCallback(color) end
                end)

                ColorBtn.MouseButton1Click:Connect(function()
                    Picker.Visible = not Picker.Visible
                end)

                local Binding = false
                KeybindBtn.MouseButton1Click:Connect(function()
                    Binding = true
                    KeybindBtn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if Binding then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            Keybind = input.KeyCode
                            KeybindBtn.Text = "Keybind: " .. input.KeyCode.Name
                            Binding = false
                        end
                    elseif input.KeyCode == Keybind and not UserInputService:GetFocusedTextBox() then
                        Toggled = not Toggled
                        if Toggled then
                            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Accent}):Play()
                            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)}):Play()
                            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
                        else
                            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ToggleBg}):Play()
                            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(150,150,150)}):Play()
                            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextDim}):Play()
                        end
                        if Config.Callback then Config.Callback(Toggled) end
                    end
                end)

                local function ToggleOptions()
                    OptionsFrame.Visible = not OptionsFrame.Visible
                    if OptionsFrame.Visible then
                        OptionsFrame.Position = UDim2.new(0, UserInputService:GetMouseLocation().X, 0, UserInputService:GetMouseLocation().Y - 30)
                        OptionsFrame:TweenSize(UDim2.new(0, 150, 0, 200), "Out", "Quart", 0.2)
                    end
                end
                OptionsBtn.MouseButton1Click:Connect(ToggleOptions)

                -- Main Toggle Logic
                local function Update()
                    if Toggled then
                        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Accent}):Play()
                        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
                    else
                        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ToggleBg}):Play()
                        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(150,150,150)}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextDim}):Play()
                    end
                    if Config.Callback then Config.Callback(Toggled) end
                end

                Button.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                end)

                if Toggled then Update() end
            end

            function Items:Slider(Config)
                local SliderFrame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)
                })
                
                local Label = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.GothamMedium, Text = Config.Name, TextColor3 = Library.Theme.TextDim,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.GothamMedium, Text = tostring(Config.Default), TextColor3 = Library.Theme.Text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SlideBg = Create("TextButton", {
                    Parent = SliderFrame, BackgroundColor3 = Library.Theme.ToggleBg, Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 6), Text = "", AutoButtonColor = false
                })
                Create("UICorner", {Parent = SlideBg, CornerRadius = UDim.new(1, 0)})
                
                local SlideFill = Create("Frame", {
                    Parent = SlideBg, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {Parent = SlideFill, CornerRadius = UDim.new(1, 0)})

                local Min, Max, Def = Config.Min, Config.Max, Config.Default or Config.Min
                
                local function Set(val)
                    val = math.clamp(val, Min, Max)
                    SlideFill.Size = UDim2.new((val - Min) / (Max - Min), 0, 1, 0)
                    ValueLabel.Text = tostring(math.floor(val))
                    if Config.Callback then Config.Callback(val) end
                end
                
                local Dragging = false
                SlideBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        local size = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * size))
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local size = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * size))
                    end
                end)
                
                Set(Def)
            end

            function Items:Dropdown(Config)
                local DropFrame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45), ClipsDescendants = true
                })
                
                local Label = Create("TextLabel", {
                    Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.GothamMedium, Text = Config.Name, TextColor3 = Library.Theme.TextDim,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Button = Create("TextButton", {
                    Parent = DropFrame, BackgroundColor3 = Library.Theme.ToggleBg, Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.Gotham, Text = "  Select...",
                    TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Button, Color = Library.Theme.Stroke, Thickness = 1})
                
                local List = Create("ScrollingFrame", {
                    Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45),
                    Size = UDim2.new(1, 0, 0, 0), ScrollBarThickness = 2
                })
                local ListLayout = Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})
                
                local Open = false
                local Selected = {} -- For Multi
                
                Button.MouseButton1Click:Connect(function()
                    Open = not Open
                    if Open then
                        local count = #Config.Options
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 45 + (math.min(count, 5) * 22))}):Play()
                        TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, math.min(count, 5) * 22)}):Play()
                        List.CanvasSize = UDim2.new(0,0,0, count * 22)
                    else
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                        TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    end
                end)
                
                for _, Option in pairs(Config.Options) do
                    local OptBtn = Create("TextButton", {
                        Parent = List, BackgroundColor3 = Library.Theme.Section, Size = UDim2.new(1, 0, 0, 22),
                        Font = Enum.Font.Gotham, Text = "  " .. Option, TextColor3 = Library.Theme.TextDim,
                        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
                    })
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        if Config.Multi then
                            if table.find(Selected, Option) then
                                table.remove(Selected, table.find(Selected, Option))
                                OptBtn.TextColor3 = Library.Theme.TextDim
                            else
                                table.insert(Selected, Option)
                                OptBtn.TextColor3 = Library.Theme.Accent
                            end
                            Button.Text = "  " .. table.concat(Selected, ", ")
                            if Config.Callback then Config.Callback(Selected) end
                        else
                            Button.Text = "  " .. Option
                            Open = false
                            TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                            TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                            if Config.Callback then Config.Callback(Option) end
                        end
                    end)
                end
            end

            return Items
        end
        
        return Sections
    end
    return Tabs
end

return Library
