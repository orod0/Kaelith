--[[ 
    SILENT PROFESSIONAL UI LIBRARY
    Style: FiveM / CS:GO Internal Cheat
    Features: Options System, ColorPicker, Keybinds, Multi-Dropdown, Watermark
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    Open = true,
    ToggleKey = Enum.KeyCode.RightShift,
    Accent = Color3.fromRGB(170, 80, 255), -- Roxo Principal
    Colors = {
        Main = Color3.fromRGB(12, 12, 12),
        Section = Color3.fromRGB(18, 18, 18),
        Stroke = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(230, 230, 230),
        TextDark = Color3.fromRGB(120, 120, 120),
        Outline = Color3.fromRGB(0, 0, 0)
    },
    -- Ícones Lucide/Roblox
    Icons = {
        Gear = "rbxassetid://10734950309",
        Arrow = "rbxassetid://10709790948",
    }
}

local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true; DragStart = input.Position; StartPosition = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            TweenService:Create(object, TweenInfo.new(0.05), {Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)}):Play()
        end
    end)
end

function Library:Window(Config)
    local ScreenGui = Create("ScreenGui", {Name = "SilentUI", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    
    -- Watermark System
    local WatermarkFrame = Create("Frame", {
        Parent = ScreenGui, BackgroundColor3 = Library.Colors.Main,
        BorderSizePixel = 0, Position = UDim2.new(0.88, 0, 0.02, 0), Size = UDim2.new(0, 200, 0, 24),
        Visible = true
    })
    Create("UIStroke", {Parent = WatermarkFrame, Color = Library.Colors.Stroke, Thickness = 1})
    -- Top Line Accent
    Create("Frame", {Parent = WatermarkFrame, BackgroundColor3 = Library.Accent, Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0})
    
    local WatermarkText = Create("TextLabel", {
        Parent = WatermarkFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Code, Text = "uid: 1 | user: admin | fps: 60",
        TextColor3 = Library.Colors.Text, TextSize = 12
    })

    -- Function to update watermark
    function Library:UpdateWatermark(text)
        WatermarkText.Text = text
        local size = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Code, Vector2.new(999, 999))
        WatermarkFrame.Size = UDim2.new(0, size.X + 20, 0, 24)
        WatermarkFrame.Position = UDim2.new(1, -(size.X + 40), 0.02, 0) -- Align right
    end

    -- Main Window
    local MainFrame = Create("Frame", {
        Name = "Main", Parent = ScreenGui, BackgroundColor3 = Library.Colors.Main,
        Position = UDim2.new(0.5, -325, 0.5, -225), Size = UDim2.new(0, 650, 0, 450),
        ClipsDescendants = false
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = MainFrame, Color = Library.Colors.Stroke, Thickness = 1})
    
    -- Accent Line Top
    Create("Frame", {Parent = MainFrame, BackgroundColor3 = Library.Accent, Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, ZIndex = 5})

    MakeDraggable(MainFrame, MainFrame)

    -- Sidebar
    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 60, 1, 0)})
    local SidebarLine = Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Colors.Stroke, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BorderSizePixel = 0})
    
    -- ASCII Logo
    local Logo = Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60),
        Font = Enum.Font.Code, Text = "}<((((*>", TextColor3 = Library.Accent, TextSize = 12
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -70), ScrollBarThickness = 0
    })
    local TabLayout = Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 15)})

    -- Pages Area
    local PageContainer = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 70, 0, 10),
        Size = UDim2.new(1, -80, 1, -20)
    })

    -- Global Keybind Logic
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            MainFrame.Visible = Library.Open
        end
    end)

    local Tabs = {}
    
    function Tabs:Tab(Config)
        local TabButton = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 0, 40),
            Text = "", AutoButtonColor = false
        })
        local TabIcon = Create("ImageLabel", {
            Parent = TabButton, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0.5, -10, 0.5, -10), Image = Config.Icon, ImageColor3 = Library.Colors.TextDark
        })
        
        local Page = Create("ScrollingFrame", {
            Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Colors.Stroke, Visible = false
        })
        
        local LeftCol = Create("Frame", {Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(0.49, 0, 1, 0)})
        local RightCol = Create("Frame", {Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(0.49, 0, 1, 0), Position = UDim2.new(0.51, 0, 0, 0)})
        
        Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(TabContainer:GetChildren()) do if t:IsA("TextButton") then TweenService:Create(t.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.TextDark}):Play() end end
            for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
            
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Accent}):Play()
            Page.Visible = true
        end)

        -- Auto Select first tab
        if #PageContainer:GetChildren() == 1 then
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Accent}):Play()
            Page.Visible = true
        end

        local Sections = {}
        function Sections:Section(SConfig)
            local ParentCol = SConfig.Side == "Right" and RightCol or LeftCol
            local SectionFrame = Create("Frame", {
                Parent = ParentCol, BackgroundColor3 = Library.Colors.Section, Size = UDim2.new(1, 0, 0, 0),
                BorderSizePixel = 0
            })
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = SectionFrame, Color = Library.Colors.Stroke, Thickness = 1})
            
            local Header = Create("TextLabel", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 0, 30), Text = string.upper(SConfig.Name), Font = Enum.Font.GothamBold,
                TextColor3 = Library.Colors.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Container = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0)
            })
            local List = Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
            Create("UIPadding", {Parent = Container, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})

            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 45)
                Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y)
            end)

            local Elements = {}

            -- Helper for Options Menu (The Gear)
            local function AddOptions(ParentItem, Options)
                if not Options then return end
                
                local GearBtn = Create("ImageButton", {
                    Parent = ParentItem, BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -15, 0.5, -7), Image = Library.Icons.Gear,
                    ImageColor3 = Library.Colors.TextDark
                })

                local OptionsFrame = Create("Frame", {
                    Parent = MainFrame, BackgroundColor3 = Library.Colors.Section, Size = UDim2.new(0, 130, 0, 0),
                    Visible = false, ZIndex = 10, BorderSizePixel = 0
                })
                Create("UICorner", {Parent = OptionsFrame, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = OptionsFrame, Color = Library.Colors.Stroke, Thickness = 1})
                local OptList = Create("UIListLayout", {Parent = OptionsFrame, Padding = UDim.new(0, 5)})
                Create("UIPadding", {Parent = OptionsFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})

                GearBtn.MouseButton1Click:Connect(function()
                    OptionsFrame.Visible = not OptionsFrame.Visible
                    OptionsFrame.Position = UDim2.new(0, GearBtn.AbsolutePosition.X + 20, 0, GearBtn.AbsolutePosition.Y)
                end)

                if Options.ColorPicker then
                    local CPLabel = Create("TextLabel", {Parent = OptionsFrame, Text = "Color", TextColor3 = Library.Colors.Text, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,15), Font = Enum.Font.Gotham, TextSize = 11})
                    local CPPreview = Create("TextButton", {Parent = OptionsFrame, Text = "", BackgroundColor3 = Options.DefaultColor or Color3.new(1,1,1), Size = UDim2.new(1,0,0,15)})
                    Create("UICorner", {Parent = CPPreview, CornerRadius = UDim.new(0,3)})
                    
                    -- Simple Color Randomizer for this example (Full picker is huge)
                    CPPreview.MouseButton1Click:Connect(function()
                        -- In a full implementation, this opens a gradient frame.
                        -- For this "Professional Look" example, we simulate setting a color.
                        -- You would insert full HSV logic here if you want 1000 lines of code.
                        local newColor = Color3.fromHSV(math.random(), 1, 1)
                        CPPreview.BackgroundColor3 = newColor
                        if Options.ColorCallback then Options.ColorCallback(newColor) end
                    end)
                    OptionsFrame.Size = UDim2.new(0, 130, 0, OptList.AbsoluteContentSize.Y + 10)
                end

                if Options.Keybind then
                    local KeyLabel = Create("TextLabel", {Parent = OptionsFrame, Text = "Keybind", TextColor3 = Library.Colors.Text, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,15), Font = Enum.Font.Gotham, TextSize = 11})
                    local KeyBtn = Create("TextButton", {
                        Parent = OptionsFrame, Text = "[ NONE ]", BackgroundColor3 = Library.Colors.Main,
                        Size = UDim2.new(1,0,0,15), TextColor3 = Library.Colors.TextDark, Font = Enum.Font.Code, TextSize = 10
                    })
                    Create("UICorner", {Parent = KeyBtn, CornerRadius = UDim.new(0,3)})
                    
                    local binding = false
                    KeyBtn.MouseButton1Click:Connect(function()
                        binding = true
                        KeyBtn.Text = "[ ... ]"
                        local input = UserInputService.InputBegan:Wait()
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            KeyBtn.Text = "[ " .. input.KeyCode.Name .. " ]"
                            if Options.KeybindCallback then Options.KeybindCallback(input.KeyCode) end
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                             KeyBtn.Text = "[ NONE ]"
                        end
                        binding = false
                    end)
                    OptionsFrame.Size = UDim2.new(0, 130, 0, OptList.AbsoluteContentSize.Y + 10)
                end
            end

            function Elements:Toggle(TConfig)
                local ToggleFrame = Create("Frame", {
                    Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)
                })
                
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame, Text = TConfig.Name, Font = Enum.Font.GothamSemibold,
                    TextColor3 = Library.Colors.Text, TextSize = 12, BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left
                })

                local OuterSwitch = Create("TextButton", {
                    Parent = ToggleFrame, BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Size = UDim2.new(0, 34, 0, 16), Position = UDim2.new(1, -40, 0.5, -8),
                    Text = "", AutoButtonColor = false
                })
                Create("UICorner", {Parent = OuterSwitch, CornerRadius = UDim.new(1, 0)})
                
                local Circle = Create("Frame", {
                    Parent = OuterSwitch, BackgroundColor3 = Color3.fromRGB(150, 150, 150),
                    Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)
                })
                Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})

                local active = TConfig.Default or false
                
                local function Update()
                    if active then
                        TweenService:Create(OuterSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Library.Accent}):Play()
                        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)}):Play()
                    else
                        TweenService:Create(OuterSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(150,150,150)}):Play()
                    end
                    if TConfig.Callback then TConfig.Callback(active) end
                end
                
                OuterSwitch.MouseButton1Click:Connect(function()
                    active = not active
                    Update()
                end)
                
                if active then Update() end

                -- Add Options Gear if requested
                if TConfig.ColorPicker or TConfig.Keybind then
                    AddOptions(ToggleFrame, {
                        ColorPicker = TConfig.ColorPicker,
                        DefaultColor = TConfig.DefaultColor,
                        ColorCallback = TConfig.ColorCallback,
                        Keybind = TConfig.Keybind,
                        KeybindCallback = TConfig.KeybindCallback
                    })
                end
            end

            function Elements:Dropdown(DConfig)
                local isMulti = DConfig.Multi or false
                local DropdownFrame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45), ClipsDescendants = true})
                local Label = Create("TextLabel", {Parent = DropdownFrame, Text = DConfig.Name, Font = Enum.Font.GothamSemibold, TextColor3 = Library.Colors.Text, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left})
                
                local Button = Create("TextButton", {
                    Parent = DropdownFrame, BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                    Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, 18),
                    Text = "", AutoButtonColor = false
                })
                Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Button, Color = Library.Colors.Stroke, Thickness = 1})
                
                local SelectedText = Create("TextLabel", {
                    Parent = Button, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 5, 0, 0),
                    Font = Enum.Font.Gotham, Text = isMulti and "None" or (DConfig.Default or "Select..."), TextColor3 = Library.Colors.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Arrow = Create("ImageLabel", {Parent = Button, Image = Library.Icons.Arrow, BackgroundTransparency = 1, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -18, 0.5, -6), ImageColor3 = Library.Colors.TextDark})
                
                local List = Create("Frame", {Parent = DropdownFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true})
                local ListLayout = Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})
                
                local opened = false
                local selected = isMulti and {} or nil

                local function UpdateText()
                    if isMulti then
                        local txt = {}
                        for k, v in pairs(selected) do if v then table.insert(txt, k) end end
                        if #txt == 0 then SelectedText.Text = "None"
                        else SelectedText.Text = table.concat(txt, ", ") end
                        SelectedText.TextColor3 = #txt > 0 and Library.Colors.Text or Library.Colors.TextDark
                    else
                        SelectedText.Text = selected
                        SelectedText.TextColor3 = Library.Colors.Text
                    end
                end

                Button.MouseButton1Click:Connect(function()
                    opened = not opened
                    local count = #DConfig.Options
                    local height = count * 22
                    
                    if opened then
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45 + height)}):Play()
                        TweenService:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, height)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
                    else
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                        TweenService:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    end
                end)

                for _, opt in pairs(DConfig.Options) do
                    local Item = Create("TextButton", {
                        Parent = List, BackgroundColor3 = Library.Colors.Section, Size = UDim2.new(1, 0, 0, 22),
                        Text = "  " .. opt, Font = Enum.Font.Gotham, TextColor3 = Library.Colors.TextDark, TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
                    })
                    
                    Item.MouseButton1Click:Connect(function()
                        if isMulti then
                            if selected[opt] then selected[opt] = nil; Item.TextColor3 = Library.Colors.TextDark
                            else selected[opt] = true; Item.TextColor3 = Library.Accent end
                            UpdateText()
                            if DConfig.Callback then DConfig.Callback(selected) end
                        else
                            selected = opt
                            UpdateText()
                            -- Close dropdown
                            opened = false
                            TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                            TweenService:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                            if DConfig.Callback then DConfig.Callback(opt) end
                        end
                    end)
                end
            end

            function Elements:Slider(SConfig)
                local SliderFrame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
                local Label = Create("TextLabel", {Parent = SliderFrame, Text = SConfig.Name, Font = Enum.Font.GothamSemibold, TextColor3 = Library.Colors.Text, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left})
                local ValueLabel = Create("TextLabel", {Parent = SliderFrame, Text = tostring(SConfig.Default or SConfig.Min), Font = Enum.Font.Code, TextColor3 = Library.Accent, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Right})
                
                local SlideBg = Create("TextButton", {
                    Parent = SliderFrame, BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 22), Text = "", AutoButtonColor = false
                })
                Create("UICorner", {Parent = SlideBg, CornerRadius = UDim.new(1, 0)})
                
                local Fill = Create("Frame", {
                    Parent = SlideBg, BackgroundColor3 = Library.Accent, Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                
                local Min, Max = SConfig.Min, SConfig.Max
                local dragging = false

                local function Set(value)
                    local percent = (value - Min) / (Max - Min)
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    ValueLabel.Text = tostring(math.floor(value))
                    if SConfig.Callback then SConfig.Callback(value) end
                end
                
                Set(SConfig.Default or Min)

                SlideBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = UDim2.new(math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1), 0, 1, 0)
                        local val = math.floor(Min + ((Max - Min) * pos.X.Scale))
                        Set(val)
                    end
                end)
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Library
