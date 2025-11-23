--[[ 
    SILENT LIBRARY REMAKE - "PURPLE AESTHETIC"
    Features: Options, ColorPicker, Keybind, Multi-Dropdown, Professional Watermark
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Library = {
    Open = true,
    ToggleKey = Enum.KeyCode.RightShift,
    Accent = Color3.fromRGB(170, 80, 255), -- Roxo Silent
    Flags = {},
    Theme = {
        Main = Color3.fromRGB(14, 14, 14),
        Secondary = Color3.fromRGB(18, 18, 18),
        Stroke = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(220, 220, 220),
        TextDark = Color3.fromRGB(120, 120, 120),
        Hover = Color3.fromRGB(25, 25, 25)
    }
}

-- Utility
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = object.Position
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Watermark
function Library:Watermark(config)
    local watermark = CoreGui:FindFirstChild("SilentWatermark") or Create("ScreenGui", {Name = "SilentWatermark", Parent = CoreGui})
    local frame = watermark:FindFirstChild("Main") or Create("Frame", {
        Name = "Main", Parent = watermark, BackgroundColor3 = Library.Theme.Main,
        BorderSizePixel = 0, Position = UDim2.new(0.01, 0, 0.01, 0), Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X
    })
    
    if not frame:FindFirstChild("Stroke") then
        Create("UIStroke", {Parent = frame, Color = Library.Theme.Stroke, Thickness = 1, Name = "Stroke"})
        Create("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 4)})
        
        -- Top Line Gradient
        local line = Create("Frame", {Parent = frame, Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.new(1,1,1), Name = "Line"})
        Create("UIGradient", {Parent = line, Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library.Accent), 
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 180))
        }})
        
        local label = Create("TextLabel", {
            Name = "Text", Parent = frame, BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    local label = frame.Text
    task.spawn(function()
        while frame.Parent do
            local fps = math.floor(workspace:GetRealPhysicsFPS())
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1])
            local time = os.date("%X")
            label.Text = string.format("%s | %s | fps: %d | ping: %dms | %s", config.Name or "CHEAT", Players.LocalPlayer.Name, fps, ping, time)
            task.wait(1)
        end
    end)
end

function Library:Window(Config)
    local UI = Create("ScreenGui", {Name = "SilentUI", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    
    -- Toggle Logic
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            UI.Enabled = Library.Open
        end
    end)

    local Main = Create("Frame", {
        Name = "Main", Parent = UI, BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(0.5, -325, 0.5, -225), Size = UDim2.new(0, 650, 0, 450)
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Main})
    Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = Main})
    MakeDraggable(Main, Main)

    -- Sidebar
    local Sidebar = Create("Frame", {Parent = Main, BackgroundColor3 = Library.Theme.Secondary, Size = UDim2.new(0, 60, 1, 0)})
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Theme.Secondary, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0})
    
    -- Logo
    local Logo = Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50),
        Text = "}<((((*>", Font = Enum.Font.Code, TextColor3 = Library.Accent, TextSize = 12
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 60), Size = UDim2.new(1, 0, 1, -70),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    local TabLayout = Create("UIListLayout", {Parent = TabContainer, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 15)})

    -- Content
    local Content = Create("Frame", {Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 75, 0, 40), Size = UDim2.new(1, -90, 1, -55)})
    
    -- Breadcrumbs
    local Breadcrumb = Create("TextLabel", {
        Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 75, 0, 15), Size = UDim2.new(0, 200, 0, 20),
        Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Text = "MAIN > SELECTION"
    })

    local Tabs = {}
    local First = true

    function Tabs:Tab(TabConfig)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 0, 40), Text = ""
        })
        
        local Icon = Create("ImageLabel", {
            Parent = TabBtn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0.5, -10, 0.5, -10),
            Image = TabConfig.Icon or "", ImageColor3 = Library.Theme.TextDark
        })
        
        local Indicator = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Library.Accent, Size = UDim2.new(0, 2, 0, 20), Position = UDim2.new(0, 0, 0.5, -10), Visible = false
        })

        local Page = Create("ScrollingFrame", {
            Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Stroke, CanvasSize = UDim2.new(0,0,0,0)
        })
        
        -- Columns
        local LeftCol = Create("Frame", {Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(0.48, 0, 1, 0)})
        local LeftList = Create("UIListLayout", {Parent = LeftCol, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
        
        local RightCol = Create("Frame", {Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(0.48, 0, 1, 0), Position = UDim2.new(0.52, 0, 0, 0)})
        local RightList = Create("UIListLayout", {Parent = RightCol, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v.ImageLabel, TweenInfo.new(0.3), {ImageColor3 = Library.Theme.TextDark}):Play()
                    v.Frame.Visible = false
                end
            end
            for _, v in pairs(Content:GetChildren()) do v.Visible = false end
            
            Page.Visible = true
            Indicator.Visible = true
            TweenService:Create(Icon, TweenInfo.new(0.3), {ImageColor3 = Library.Accent}):Play()
            Breadcrumb.Text = "MAIN > " .. string.upper(TabConfig.Name)
        end)

        if First then
            First = false
            TabBtn.MouseButton1Click:Fire()
        end

        -- Section Handling
        local Sections = {}
        function Sections:Section(SecConfig)
            local Parent = SecConfig.Side == "Right" and RightCol or LeftCol
            
            local SectionFrame = Create("Frame", {
                Parent = Parent, BackgroundColor3 = Library.Theme.Secondary, Size = UDim2.new(1, 0, 0, 0) -- Auto resize
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SectionFrame})
            Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = SectionFrame})
            
            Create("TextLabel", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 8), Size = UDim2.new(1, -20, 0, 15),
                Font = Enum.Font.GothamBold, Text = string.upper(SecConfig.Name), TextColor3 = Library.Theme.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Container = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 0)
            })
            local ContainerList = Create("UIListLayout", {Parent = Container, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
            Create("UIPadding", {Parent = Container, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})

            ContainerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, 0, 0, ContainerList.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, 0, 0, ContainerList.AbsoluteContentSize.Y + 38)
                -- Update Page Canvas
                local maxH = math.max(LeftList.AbsoluteContentSize.Y, RightList.AbsoluteContentSize.Y)
                Page.CanvasSize = UDim2.new(0, 0, 0, maxH + 20)
            end)

            -- ELEMENTS
            local Elements = {}

            -- Helper: Option/Gear Menu
            local function CreateOptionMenu(ParentFrame, OptConfig)
                if not OptConfig or not OptConfig.Options then return end
                
                local OptionBtn = Create("ImageButton", {
                    Parent = ParentFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -15, 0.5, -7), Image = "rbxassetid://10734950309", ImageColor3 = Library.Theme.TextDark
                })
                
                local OptionFrame = Create("Frame", {
                    Parent = UI, BackgroundColor3 = Library.Theme.Secondary, Size = UDim2.new(0, 150, 0, 0), Visible = false, ZIndex = 10
                })
                Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = OptionFrame})
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptionFrame})
                local OptList = Create("UIListLayout", {Parent = OptionFrame, Padding = UDim.new(0, 5)})
                Create("UIPadding", {Parent = OptionFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5)})

                OptionBtn.MouseButton1Click:Connect(function()
                    OptionFrame.Visible = not OptionFrame.Visible
                    OptionFrame.Position = UDim2.new(0, OptionBtn.AbsolutePosition.X + 20, 0, OptionBtn.AbsolutePosition.Y)
                end)

                -- Close when clicking away logic would go here (simplified for brevity)

                -- Logic for ColorPicker inside Options
                if OptConfig.ColorPicker then
                    local CPConfig = OptConfig.ColorPicker
                    local ColorFrame = Create("Frame", {Parent = OptionFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25)})
                    Create("TextLabel", {Parent = ColorFrame, Text = "Color", Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 12, Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1})
                    local ColorInd = Create("TextButton", {Parent = ColorFrame, Size = UDim2.new(0, 40, 0, 16), Position = UDim2.new(1, -40, 0.5, -8), BackgroundColor3 = CPConfig.Default or Color3.new(1,1,1), Text = ""})
                    Create("UICorner", {Parent = ColorInd, CornerRadius = UDim.new(0, 4)})
                    
                    -- Simple HSV Logic would spawn another frame here. Keeping it simple:
                    ColorInd.MouseButton1Click:Connect(function()
                        -- Trigger callback simulation
                        if CPConfig.Callback then CPConfig.Callback(ColorInd.BackgroundColor3) end
                    end)
                end
                
                -- Extra Toggles/Options could be added here
                OptList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    OptionFrame.Size = UDim2.new(0, 150, 0, OptList.AbsoluteContentSize.Y + 10)
                end)
            end

            function Elements:Toggle(TogConfig)
                local ToggleFrame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25)})
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.GothamMedium, Text = TogConfig.Name, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Switch = Create("TextButton", {
                    Parent = ToggleFrame, BackgroundColor3 = Library.Theme.Hover, Size = UDim2.new(0, 34, 0, 16), Position = UDim2.new(1, -34 - (TogConfig.Options and 20 or 0), 0.5, -8), Text = ""
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
                local Dot = Create("Frame", {
                    Parent = Switch, BackgroundColor3 = Library.Theme.TextDark, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})

                local Toggled = TogConfig.Default or false
                
                local function Update()
                    if Toggled then
                        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Library.Accent}):Play()
                        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
                    else
                        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover}):Play()
                        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Library.Theme.TextDark}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text}):Play()
                    end
                    if TogConfig.Callback then TogConfig.Callback(Toggled) end
                end

                Switch.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)
                if Toggled then Update() end

                if TogConfig.Options then CreateOptionMenu(ToggleFrame, TogConfig.Options) end
            end

            function Elements:Slider(SlidConfig)
                local Frame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
                Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), Font = Enum.Font.GothamMedium,
                    Text = SlidConfig.Name, TextColor3 = Library.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                local ValueLabel = Create("TextLabel", {
                    Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), Font = Enum.Font.Gotham,
                    Text = tostring(SlidConfig.Default or SlidConfig.Min), TextColor3 = Library.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
                })
                local Bar = Create("TextButton", {
                    Parent = Frame, BackgroundColor3 = Library.Theme.Hover, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 22), Text = "", AutoButtonColor = false
                })
                Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
                local Fill = Create("Frame", {
                    Parent = Bar, BackgroundColor3 = Library.Accent, Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                local Knob = Create("Frame", {
                    Parent = Fill, BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(1, -5, 0.5, -5), ZIndex = 2
                })
                Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                local Min, Max = SlidConfig.Min, SlidConfig.Max
                local function Set(val)
                    val = math.clamp(val, Min, Max)
                    local pct = (val - Min) / (Max - Min)
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    ValueLabel.Text = tostring(math.floor(val * 10)/10)
                    if SlidConfig.Callback then SlidConfig.Callback(val) end
                end
                
                local Dragging = false
                Bar.InputBegan:Connect(function(input) 
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        Dragging = true; 
                        local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                        Set(Min + (Max - Min) * p)
                    end 
                end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                        Set(Min + (Max - Min) * p)
                    end
                end)
                Set(SlidConfig.Default or Min)
            end

            function Elements:Dropdown(DropConfig)
                local DropFrame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45), ClipsDescendants = true, ZIndex = 2})
                Create("TextLabel", {
                    Parent = DropFrame, Text = DropConfig.Name, Font = Enum.Font.GothamMedium, TextColor3 = Library.Theme.Text, TextSize = 12,
                    Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Btn = Create("TextButton", {
                    Parent = DropFrame, BackgroundColor3 = Library.Theme.Hover, Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, 18),
                    Text = DropConfig.Default or "Select...", Font = Enum.Font.Gotham, TextColor3 = Library.Theme.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
                })
                Create("UIPadding", {Parent = Btn, PaddingLeft = UDim.new(0, 8)})
                Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Btn, Color = Library.Theme.Stroke, Thickness = 1})
                Create("ImageLabel", {Parent = Btn, Image = "rbxassetid://10709790948", BackgroundTransparency = 1, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -20, 0.5, -6), ImageColor3 = Library.Theme.TextDark})

                local List = Create("Frame", {
                    Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 0, 0)
                })
                local ListLayout = Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})
                
                local Opened = false
                local Selected = {} 

                local function RefreshText()
                    if DropConfig.Multi then
                        local txt = {}
                        for k, v in pairs(Selected) do if v then table.insert(txt, k) end end
                        Btn.Text = #txt > 0 and table.concat(txt, ", ") or "Select..."
                    end
                end

                Btn.MouseButton1Click:Connect(function()
                    Opened = not Opened
                    local h = #DropConfig.Options * 22
                    TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, Opened and (45 + h) or 45)}):Play()
                    TweenService:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, Opened and h or 0)}):Play()
                end)

                for _, Opt in pairs(DropConfig.Options) do
                    local Item = Create("TextButton", {
                        Parent = List, BackgroundColor3 = Library.Theme.Secondary, Size = UDim2.new(1, 0, 0, 22), Text = Opt,
                        Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text, TextSize = 11, ZIndex = 3
                    })
                    
                    Item.MouseButton1Click:Connect(function()
                        if DropConfig.Multi then
                            Selected[Opt] = not Selected[Opt]
                            Item.TextColor3 = Selected[Opt] and Library.Accent or Library.Theme.Text
                            RefreshText()
                            if DropConfig.Callback then DropConfig.Callback(Selected) end
                        else
                            Btn.Text = Opt
                            Btn.TextColor3 = Color3.new(1,1,1)
                            Opened = false
                            TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                            if DropConfig.Callback then DropConfig.Callback(Opt) end
                        end
                    end)
                end
            end

            function Elements:Keybind(BindConfig)
                local Frame = Create("Frame", {Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25)})
                Create("TextLabel", {
                    Parent = Frame, Text = BindConfig.Name, Font = Enum.Font.GothamMedium, TextColor3 = Library.Theme.Text, TextSize = 12,
                    Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left
                })
                local BindBtn = Create("TextButton", {
                    Parent = Frame, BackgroundColor3 = Library.Theme.Hover, Size = UDim2.new(0, 60, 0, 18), Position = UDim2.new(1, -60, 0.5, -9),
                    Text = (BindConfig.Default and BindConfig.Default.Name) or "None", Font = Enum.Font.Gotham, TextColor3 = Library.Theme.TextDark, TextSize = 11
                })
                Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = BindBtn, Color = Library.Theme.Stroke, Thickness = 1})

                BindBtn.MouseButton1Click:Connect(function()
                    BindBtn.Text = "..."
                    local Input = UserInputService.InputBegan:Wait()
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        BindBtn.Text = Input.KeyCode.Name
                        if BindConfig.Callback then BindConfig.Callback(Input.KeyCode) end
                    else
                        BindBtn.Text = "None"
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
