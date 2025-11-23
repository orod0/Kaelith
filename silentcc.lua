--[[ 
    SILENT PROFESSIONAL UI LIBRARY [RECODE]
    Style: FiveM Internal / Cheat Style
    Features: Option System (Gear), Keybinds, ColorPicker, Multi-Dropdown, Watermark
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local Library = {
    Open = true,
    ToggleKey = Enum.KeyCode.RightShift,
    Accent = Color3.fromRGB(170, 80, 255), -- Roxo Principal
    Colors = {
        Main = Color3.fromRGB(12, 12, 12),
        Header = Color3.fromRGB(16, 16, 16),
        Section = Color3.fromRGB(18, 18, 18),
        Stroke = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(230, 230, 230),
        TextDark = Color3.fromRGB(120, 120, 120),
        Hover = Color3.fromRGB(25, 25, 25)
    },
    Icons = {
        Gear = "rbxassetid://10734950309",
        Arrow = "rbxassetid://10709790948",
        Check = "rbxassetid://10709790644"
    },
    ActiveOptionsFrame = nil
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

-- Close options when clicking outside
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Library.ActiveOptionsFrame and Library.ActiveOptionsFrame.Visible then
            -- Simple check (can be improved)
            Library.ActiveOptionsFrame.Visible = false
            Library.ActiveOptionsFrame = nil
        end
    end
end)

function Library:Window(Config)
    local ScreenGui = Create("ScreenGui", {Name = "SilentProfessional", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    
    -- Watermark
    local WatermarkFrame = Create("Frame", {
        Parent = ScreenGui, BackgroundColor3 = Library.Colors.Main,
        BorderSizePixel = 0, Position = UDim2.new(0.85, 0, 0.02, 0), Size = UDim2.new(0, 200, 0, 26),
        Visible = true, ZIndex = 100
    })
    Create("UICorner", {Parent = WatermarkFrame, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = WatermarkFrame, Color = Library.Colors.Stroke, Thickness = 1})
    Create("Frame", {Parent = WatermarkFrame, BackgroundColor3 = Library.Accent, Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 101}) -- Top Line
    
    local WatermarkText = Create("TextLabel", {
        Parent = WatermarkFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Code, Text = "", TextColor3 = Library.Colors.Text, TextSize = 12
    })

    function Library:UpdateWatermark(text)
        WatermarkText.Text = text
        local size = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Code, Vector2.new(999, 999))
        WatermarkFrame.Size = UDim2.new(0, size.X + 24, 0, 26)
        WatermarkFrame.Position = UDim2.new(0.98, -(size.X + 30), 0.02, 0)
    end

    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Library.Colors.Main,
        Position = UDim2.new(0.5, -325, 0.5, -225), Size = UDim2.new(0, 650, 0, 450),
        ClipsDescendants = false
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = MainFrame, Color = Library.Colors.Stroke, Thickness = 1})
    
    MakeDraggable(MainFrame, MainFrame)

    -- Sidebar
    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Library.Colors.Header, Size = UDim2.new(0, 60, 1, 0), BorderSizePixel = 0})
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 6)})
    local SidebarCover = Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Colors.Header, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Colors.Stroke, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BorderSizePixel = 0}) -- Line

    -- Logo
    local Logo = Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50),
        Font = Enum.Font.Code, Text = "}<((((*>", TextColor3 = Library.Accent, TextSize = 11
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60), ScrollBarThickness = 0
    })
    local TabLayout = Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 15)})

    -- Content Pages
    local Pages = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 75, 0, 15),
        Size = UDim2.new(1, -90, 1, -30)
    })

    local Breadcrumb = Create("TextLabel", {
        Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 75, 0, 15),
        Size = UDim2.new(1, -90, 0, 20), Font = Enum.Font.GothamBold, Text = "MAIN > SELECTION",
        TextColor3 = Library.Colors.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Keybind Toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            MainFrame.Visible = Library.Open
        end
    end)

    local Tabs = {}

    function Tabs:Tab(TabConfig)
        local TabButton = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 0, 40),
            Text = "", AutoButtonColor = false
        })
        local TabIcon = Create("ImageLabel", {
            Parent = TabButton, BackgroundTransparency = 1, Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0.5, -11, 0.5, -11), Image = TabConfig.Icon, ImageColor3 = Library.Colors.TextDark
        })

        local PageFrame = Create("ScrollingFrame", {
            Parent = Pages, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25),
            Size = UDim2.new(1, 0, 1, -25), ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Accent,
            Visible = false
        })
        
        local LeftCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.48, 0, 1, 0)})
        local RightCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.48, 0, 1, 0), Position = UDim2.new(0.52, 0, 0, 0)})
        
        Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
        Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(TabContainer:GetChildren()) do if t:IsA("TextButton") then TweenService:Create(t.ImageLabel, TweenInfo.new(0.2), {ImageColor3 = Library.Colors.TextDark}):Play() end end
            for _, p in pairs(Pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Accent}):Play()
            PageFrame.Visible = true
            Breadcrumb.Text = "MAIN > " .. string.upper(TabConfig.Name)
        end)

        if #Pages:GetChildren() == 1 then -- First tab auto-select
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Accent}):Play()
            PageFrame.Visible = true
            Breadcrumb.Text = "MAIN > " .. string.upper(TabConfig.Name)
        end

        local Sections = {}

        function Sections:Section(SConfig)
            local ParentCol = SConfig.Side == "Right" and RightCol or LeftCol
            local SectionFrame = Create("Frame", {
                Parent = ParentCol, BackgroundColor3 = Library.Colors.Section,
                Size = UDim2.new(1, 0, 0, 50) -- Auto sizes
            })
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = SectionFrame, Color = Library.Colors.Stroke, Thickness = 1})

            local Header = Create("TextLabel", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -12, 0, 30), Text = string.upper(SConfig.Name), Font = Enum.Font.GothamBold,
                TextColor3 = Library.Colors.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left
            })

            local Container = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0)
            })
            local ContainerLayout = Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
            Create("UIPadding", {Parent = Container, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})

            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 45)
                Container.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
            end)

            -- OPTION SYSTEM (The Gear)
            local function AddOptionMenu(ItemParent, Configs)
                if not (Configs.Keybind or Configs.ColorPicker) then return end

                -- Hover gear button
                local Gear = Create("ImageButton", {
                    Parent = ItemParent, BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -15, 0.5, -7), Image = Library.Icons.Gear,
                    ImageColor3 = Library.Colors.TextDark, Visible = false, ZIndex = 5
                })

                ItemParent.MouseEnter:Connect(function() Gear.Visible = true end)
                ItemParent.MouseLeave:Connect(function() if not Library.ActiveOptionsFrame then Gear.Visible = false end end)

                Gear.MouseButton1Click:Connect(function()
                    -- Close existing
                    if Library.ActiveOptionsFrame then Library.ActiveOptionsFrame:Destroy() Library.ActiveOptionsFrame = nil end

                    -- Create Menu
                    local OptFrame = Create("Frame", {
                        Parent = ScreenGui, BackgroundColor3 = Library.Colors.Header,
                        Size = UDim2.new(0, 140, 0, 0), Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 5),
                        ZIndex = 200
                    })
                    Create("UICorner", {Parent = OptFrame, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = OptFrame, Color = Library.Colors.Stroke, Thickness = 1})
                    local OptList = Create("UIListLayout", {Parent = OptFrame, Padding = UDim.new(0, 5)})
                    Create("UIPadding", {Parent = OptFrame, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

                    Library.ActiveOptionsFrame = OptFrame

                    -- Keybind Element
                    if Configs.Keybind then
                        local KLabel = Create("TextLabel", {
                            Parent = OptFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                            Text = "Keybind", Font = Enum.Font.Gotham, TextColor3 = Library.Colors.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                        })
                        local BindBtn = Create("TextButton", {
                            Parent = OptFrame, BackgroundColor3 = Library.Colors.Section, Size = UDim2.new(1, 0, 0, 20),
                            Text = "[ None ]", Font = Enum.Font.Code, TextColor3 = Library.Colors.TextDark, TextSize = 11
                        })
                        Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
                        
                        local binding = false
                        BindBtn.MouseButton1Click:Connect(function()
                            binding = true
                            BindBtn.Text = "[ ... ]"
                            local input = UserInputService.InputBegan:Wait()
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                BindBtn.Text = "[ " .. input.KeyCode.Name .. " ]"
                                if Configs.KeyCallback then Configs.KeyCallback(input.KeyCode) end
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                BindBtn.Text = "[ None ]"
                            end
                            binding = false
                        end)
                    end

                    -- Color Picker Element
                    if Configs.ColorPicker then
                        local CLabel = Create("TextLabel", {
                            Parent = OptFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                            Text = "Color", Font = Enum.Font.Gotham, TextColor3 = Library.Colors.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                        })
                        local ColorBtn = Create("TextButton", {
                            Parent = OptFrame, BackgroundColor3 = Configs.DefaultColor or Color3.new(1,1,1), Size = UDim2.new(1, 0, 0, 15),
                            Text = ""
                        })
                        Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(0, 2)})
                        
                        -- Simple Randomizer for demo (Full HSV is huge)
                        ColorBtn.MouseButton1Click:Connect(function()
                            local rColor = Color3.fromHSV(math.random(), 0.8, 1)
                            ColorBtn.BackgroundColor3 = rColor
                            if Configs.ColorCallback then Configs.ColorCallback(rColor) end
                        end)
                    end

                    OptFrame.Size = UDim2.new(0, 140, 0, OptList.AbsoluteContentSize.Y + 16)
                end)
            end

            local Elements = {}

            function Elements:Toggle(TConfig)
                local ToggleFrame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0),
                    Text = TConfig.Name, Font = Enum.Font.GothamMedium, TextColor3 = Library.Colors.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Switch = Create("TextButton", {
                    Parent = ToggleFrame, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Size = UDim2.new(0, 34, 0, 16),
                    Position = UDim2.new(1, -40, 0.5, -8), Text = "", AutoButtonColor = false
                })
                Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
                local Circle = Create("Frame", {
                    Parent = Switch, BackgroundColor3 = Library.Colors.TextDark, Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 2, 0.5, -6)
                })
                Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})

                local active = TConfig.Default or false
                local function Update()
                    if active then
                        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Library.Accent}):Play()
                        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)}):Play()
                    else
                        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Library.Colors.TextDark}):Play()
                    end
                    if TConfig.Callback then TConfig.Callback(active) end
                end
                
                Switch.MouseButton1Click:Connect(function() active = not active; Update() end)
                if active then Update() end

                -- Add Options
                AddOptionMenu(ToggleFrame, TConfig)
            end

            function Elements:Dropdown(DConfig)
                local isMulti = DConfig.Multi or false
                local DropdownFrame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45), ClipsDescendants = true})
                local Label = Create("TextLabel", {
                    Parent = DropdownFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Text = DConfig.Name, Font = Enum.Font.GothamMedium, TextColor3 = Library.Colors.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Main = Create("TextButton", {
                    Parent = DropdownFrame, BackgroundColor3 = Library.Colors.Hover, Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 0, 18), Text = "", AutoButtonColor = false
                })
                Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Main, Color = Library.Colors.Stroke, Thickness = 1})
                
                local CurrentText = Create("TextLabel", {
                    Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 5, 0, 0),
                    Text = isMulti and "None" or (DConfig.Default or "Select..."), Font = Enum.Font.Gotham, TextColor3 = Library.Colors.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
                })
                local Arrow = Create("ImageLabel", {
                    Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -18, 0.5, -6), Image = Library.Icons.Arrow, ImageColor3 = Library.Colors.TextDark
                })

                local DropList = Create("Frame", {Parent = DropdownFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 0, 0)})
                local ListLayout = Create("UIListLayout", {Parent = DropList, SortOrder = Enum.SortOrder.LayoutOrder})

                local open = false
                local selection = isMulti and {} or nil

                local function UpdateVal()
                    if isMulti then
                        local txt = {}
                        for k,v in pairs(selection) do if v then table.insert(txt, k) end end
                        if #txt == 0 then CurrentText.Text = "None"; CurrentText.TextColor3 = Library.Colors.TextDark
                        else CurrentText.Text = table.concat(txt, ", "); CurrentText.TextColor3 = Library.Colors.Text end
                    else
                        CurrentText.Text = selection
                        CurrentText.TextColor3 = Library.Colors.Text
                    end
                end

                Main.MouseButton1Click:Connect(function()
                    open = not open
                    local size = #DConfig.Options * 22
                    if open then
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45 + size)}):Play()
                        TweenService:Create(DropList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, size)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
                    else
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                        TweenService:Create(DropList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    end
                end)

                for _, opt in pairs(DConfig.Options) do
                    local Btn = Create("TextButton", {
                        Parent = DropList, BackgroundColor3 = Library.Colors.Section, Size = UDim2.new(1, 0, 0, 22),
                        Text = "  " .. opt, Font = Enum.Font.Gotham, TextColor3 = Library.Colors.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
                    })
                    
                    Btn.MouseButton1Click:Connect(function()
                        if isMulti then
                            if selection[opt] then selection[opt] = nil; Btn.TextColor3 = Library.Colors.TextDark
                            else selection[opt] = true; Btn.TextColor3 = Library.Accent end
                            UpdateVal()
                            if DConfig.Callback then DConfig.Callback(selection) end
                        else
                            selection = opt
                            UpdateVal()
                            -- Close
                            open = false
                            TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                            TweenService:Create(DropList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                            if DConfig.Callback then DConfig.Callback(opt) end
                        end
                    end)
                end
            end

            function Elements:Slider(SConfig)
                local SliderFrame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
                local Label = Create("TextLabel", {Parent = SliderFrame, Text = SConfig.Name, Font = Enum.Font.GothamMedium, TextColor3 = Library.Colors.Text, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left})
                local ValLabel = Create("TextLabel", {Parent = SliderFrame, Text = tostring(SConfig.Default or SConfig.Min), Font = Enum.Font.Code, TextColor3 = Library.Accent, TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Right})
                
                local SlideBg = Create("TextButton", {Parent = SliderFrame, BackgroundColor3 = Color3.fromRGB(40,40,40), Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 22), Text = "", AutoButtonColor = false})
                Create("UICorner", {Parent = SlideBg, CornerRadius = UDim.new(1, 0)})
                local Fill = Create("Frame", {Parent = SlideBg, BackgroundColor3 = Library.Accent, Size = UDim2.new(0, 0, 1, 0)})
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                
                local Min, Max = SConfig.Min, SConfig.Max
                local function Set(val)
                    local p = (val - Min) / (Max - Min)
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    ValLabel.Text = tostring(math.floor(val))
                    if SConfig.Callback then SConfig.Callback(val) end
                end
                
                Set(SConfig.Default or Min)
                local dragging = false
                SlideBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local s = math.clamp((i.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        Set(Min + ((Max - Min) * s))
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
