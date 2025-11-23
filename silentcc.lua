--[[
    SKECH INTERNAL UI [REMAKE v2]
    Author: 4lpaca / Refactored by AI
    Style: Internal / Skeet / Neverlose
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Proteção e Ambiente
local protect_gui = protectgui or (syn and syn.protect_gui) or function() end
local get_hui = (gethui and gethui()) or CoreGui

local Library = {
    Open = true,
    ToggleKey = Enum.KeyCode.RightShift,
    Accent = Color3.fromRGB(255, 35, 35), -- Vermelho Skech
    Dragging = {Gui = nil, Drag = nil, Start = nil},
    Flags = {},
    Theme = {
        Main = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(16, 16, 16),
        Section = Color3.fromRGB(19, 19, 19),
        Stroke = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(230, 230, 230),
        TextDark = Color3.fromRGB(140, 140, 140),
        Glow = "rbxassetid://5028857472"
    }
}

-- Utility Functions
local function Create(instance, props)
    local new = Instance.new(instance)
    for k, v in pairs(props) do
        new[k] = v
    end
    return new
end

local function MakeDraggable(DragPoint, MainFrame)
    DragPoint.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Library.Dragging.Gui = MainFrame
            Library.Dragging.Start = MainFrame.Position
            Library.Dragging.Drag = input.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Library.Dragging.Gui = nil
                end
            end)
        end
    end)

    DragPoint.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if Library.Dragging.Gui == MainFrame then
                local Delta = input.Position - Library.Dragging.Drag
                local Position = UDim2.new(Library.Dragging.Start.X.Scale, Library.Dragging.Start.X.Offset + Delta.X, Library.Dragging.Start.Y.Scale, Library.Dragging.Start.Y.Offset + Delta.Y)
                TweenService:Create(MainFrame, TweenInfo.new(0.05), {Position = Position}):Play()
            end
        end
    end)
end

-- Main Window Function
function Library:Window(Config)
    Config.Name = Config.Name or "SKECH"
    Library.ToggleKey = Config.Keybind or Enum.KeyCode.RightShift

    local ScreenGui = Create("ScreenGui", {
        Name = "SkechInternal",
        Parent = get_hui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        ResetOnSpawn = false
    })
    protect_gui(ScreenGui)

    local MainFrame = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = MainFrame})
    Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = MainFrame})

    -- Topbar Accent
    local TopAccent = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Library.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2)
    })

    MakeDraggable(MainFrame, MainFrame)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Sidebar,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, 60, 1, -2),
        BorderSizePixel = 0
    })
    
    -- Logo Logic
    local Logo = Create("ImageLabel", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 15),
        Size = UDim2.new(0, 40, 0, 40),
        Image = "http://www.roblox.com/asset/?id=120245531583106", -- Logo Genérico, troque se quiser
        ImageColor3 = Library.Accent
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -80),
        ScrollBarThickness = 0
    })
    local TabLayout = Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15), HorizontalAlignment = Enum.HorizontalAlignment.Center})

    -- Pages Area
    local Pages = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 10),
        Size = UDim2.new(1, -80, 1, -20)
    })

    -- Toggle Key Listener
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            MainFrame.Visible = Library.Open
        end
    end)

    local TabHandler = {}
    local SelectedTab = nil

    function TabHandler:Tab(TabConfig)
        local TabButton = Create("ImageButton", {
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 32, 0, 32),
            Image = TabConfig.Icon or "",
            ImageColor3 = Library.Theme.TextDark
        })

        local PageFrame = Create("ScrollingFrame", {
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 0,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0) -- Auto resize handled later
        })

        -- Two columns
        local LeftCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.49, 0, 1, 0)})
        local RightCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Position = UDim2.new(0.51, 0, 0, 0), Size = UDim2.new(0.49, 0, 1, 0)})
        Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

        TabButton.MouseButton1Click:Connect(function()
            if SelectedTab then
                TweenService:Create(SelectedTab.Btn, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.TextDark}):Play()
                SelectedTab.Page.Visible = false
            end
            SelectedTab = {Btn = TabButton, Page = PageFrame}
            TweenService:Create(TabButton, TweenInfo.new(0.2), {ImageColor3 = Library.Accent}):Play()
            PageFrame.Visible = true
        end)

        if not SelectedTab then
            SelectedTab = {Btn = TabButton, Page = PageFrame}
            TabButton.ImageColor3 = Library.Accent
            PageFrame.Visible = true
        end

        local SectionHandler = {}

        function SectionHandler:Section(SecConfig)
            local ParentCol = (SecConfig.Side == "Right" and RightCol) or LeftCol
            
            local SectionContainer = Create("Frame", {
                Parent = ParentCol,
                BackgroundColor3 = Library.Theme.Section,
                Size = UDim2.new(1, 0, 0, 30),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SectionContainer})
            Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = SectionContainer})

            local Header = Create("Frame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            local Title = Create("TextLabel", {
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = SecConfig.Name,
                TextColor3 = Library.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("Frame", { -- Line
                Parent = Header,
                BackgroundColor3 = Library.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundTransparency = 0.5
            })

            local Items = Create("Frame", {
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", {Parent = Items, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
            Create("UIPadding", {Parent = Items, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})

            local Elements = {}

            -- *** TOGGLE FUNCTION WITH RIGHT CLICK CONTEXT ***
            function Elements:Toggle(Config)
                local Toggled = Config.Default or false
                local Color = Config.Color or Library.Accent
                local Keybind = Config.Keybind or nil

                local ToggleFrame = Create("Frame", {
                    Parent = Items,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })

                local Button = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 2
                })

                local Checkbox = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, -8)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Checkbox})
                Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = Checkbox})

                local CheckFill = Create("Frame", {
                    Parent = Checkbox,
                    BackgroundColor3 = Color,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = CheckFill})

                local Label = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 24, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = Config.Name,
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                -- Settings Icon (Context)
                local Gear = Create("ImageLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -16, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Image = "rbxassetid://10734950309", -- Gear Icon
                    ImageColor3 = Library.Theme.TextDark,
                    Visible = false
                })

                local function Update()
                    if Toggled then
                        TweenService:Create(CheckFill, TweenInfo.new(0.15), {BackgroundTransparency = 0, BackgroundColor3 = Color}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Color3.new(1,1,1)}):Play()
                    else
                        TweenService:Create(CheckFill, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Library.Theme.TextDark}):Play()
                    end
                    if Config.Callback then Config.Callback(Toggled) end
                end

                Button.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                end)

                -- ** KEYBIND LOGIC **
                if Keybind then
                    UserInputService.InputBegan:Connect(function(input, gp)
                        if not gp and input.KeyCode == Keybind then
                            Toggled = not Toggled
                            Update()
                        end
                    end)
                end

                -- ** CONTEXT MENU LOGIC (Right Click) **
                Button.MouseButton2Click:Connect(function()
                    Library:ContextMenu({
                        {
                            Type = "Label", Text = "Settings for " .. Config.Name
                        },
                        {
                            Type = "Keybind", Text = "Bind", Current = Keybind, Callback = function(NewKey) 
                                Keybind = NewKey 
                            end
                        },
                        {
                            Type = "ColorPicker", Text = "Accent Color", Default = Color, Callback = function(NewCol)
                                Color = NewCol
                                if Toggled then Update() end
                            end
                        }
                    })
                end)

                if Config.Default then Update() end
            end

            function Elements:Slider(Config)
                local SliderFrame = Create("Frame", {
                    Parent = Items,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35)
                })

                local Label = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.GothamMedium,
                    Text = Config.Name,
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.Gotham,
                    Text = tostring(Config.Default or Config.Min),
                    TextColor3 = Color3.new(1,1,1),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local BG = Create("TextButton", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Library.Theme.Main,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 6),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = BG})

                local Fill = Create("Frame", {
                    Parent = BG,
                    BackgroundColor3 = Library.Accent,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Fill})

                local Min, Max, Round = Config.Min, Config.Max, Config.Default or Config.Min
                
                local function Update(Input)
                    local SizeX = math.clamp((Input.Position.X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
                    local NewValue = math.floor(Min + ((Max - Min) * SizeX))
                    
                    Fill.Size = UDim2.new(SizeX, 0, 1, 0)
                    ValueLabel.Text = tostring(NewValue)
                    if Config.Callback then Config.Callback(NewValue) end
                end

                BG.InputBegan:Connect(function(i) 
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        local Connection; Connection = UserInputService.InputChanged:Connect(function(io)
                            if io.UserInputType == Enum.UserInputType.MouseMovement then
                                Update(io)
                            end
                        end)
                        Update(i)
                        UserInputService.InputEnded:Wait()
                        Connection:Disconnect()
                    end
                end)
                
                -- Init default
                local percent = (Round - Min) / (Max - Min)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
            end

            function Elements:Dropdown(Config)
                local IsMulti = Config.Multi or false
                local Options = Config.Options or {}
                local Selected = Config.Default or (IsMulti and {} or Options[1])
                
                local DropFrame = Create("Frame", {
                    Parent = Items,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    ClipsDescendants = true
                })

                local Label = Create("TextLabel", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.GothamMedium,
                    Text = Config.Name,
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local MainBtn = Create("TextButton", {
                    Parent = DropFrame,
                    BackgroundColor3 = Library.Theme.Main,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 22),
                    AutoButtonColor = false,
                    Font = Enum.Font.Gotham,
                    Text = " ...",
                    TextColor3 = Color3.new(1,1,1),
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = MainBtn})
                Create("UIStroke", {Color = Library.Theme.Stroke, Thickness = 1, Parent = MainBtn})

                -- Function to update text
                local function UpdateText()
                    if IsMulti then
                        local t = {}
                        for k, v in pairs(Selected) do if v then table.insert(t, k) end end
                        MainBtn.Text = " " .. (#t > 0 and table.concat(t, ", ") or "None")
                    else
                        MainBtn.Text = " " .. tostring(Selected)
                    end
                end
                UpdateText()

                -- Dropdown List
                local List = Create("ScrollingFrame", {
                    Parent = DropFrame,
                    BackgroundColor3 = Library.Theme.Main,
                    BorderColor3 = Library.Theme.Stroke,
                    BorderSizePixel = 1,
                    Position = UDim2.new(0, 0, 0, 45),
                    Size = UDim2.new(1, 0, 0, 0), -- Resizes
                    ScrollBarThickness = 2,
                    ZIndex = 5
                })
                Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})

                local Open = false
                MainBtn.MouseButton1Click:Connect(function()
                    Open = not Open
                    local Count = #Options
                    local Height = math.min(Count * 22, 150)
                    
                    if Open then
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 45 + Height)}):Play()
                        TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, Height)}):Play()
                    else
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                        TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    end
                end)

                for _, v in pairs(Options) do
                    local Btn = Create("TextButton", {
                        Parent = List,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 22),
                        Font = Enum.Font.Gotham,
                        Text = v,
                        TextColor3 = Library.Theme.TextDark,
                        TextSize = 12,
                        ZIndex = 6
                    })

                    Btn.MouseButton1Click:Connect(function()
                        if IsMulti then
                            if Selected[v] then Selected[v] = nil else Selected[v] = true end
                        else
                            Selected = v
                            Open = false
                            TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                            TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        end
                        UpdateText()
                        if Config.Callback then Config.Callback(Selected) end
                    end)
                end
            end

            return Elements
        end
        return SectionHandler
    end
    return TabHandler
end

-- Context Menu Function
function Library:ContextMenu(Options)
    -- Remove old context menu
    if get_hui:FindFirstChild("SkechContext") then get_hui.SkechContext:Destroy() end

    local Screen = Create("ScreenGui", {Name = "SkechContext", Parent = get_hui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    local Frame = Create("Frame", {
        Parent = Screen,
        BackgroundColor3 = Library.Theme.Section,
        Position = UDim2.new(0, Mouse.X, 0, Mouse.Y),
        Size = UDim2.new(0, 150, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Frame})
    Create("UIStroke", {Color = Library.Accent, Thickness = 1, Parent = Frame})
    Create("UIListLayout", {Parent = Frame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    Create("UIPadding", {Parent = Frame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})

    -- Close on click out
    local ClickOut = Create("TextButton", {Parent = Screen, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "", ZIndex = -1})
    ClickOut.MouseButton1Click:Connect(function() Screen:Destroy() end)

    for _, opt in pairs(Options) do
        if opt.Type == "Label" then
            Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Text = opt.Text,
                TextColor3 = Library.Theme.TextDark,
                Font = Enum.Font.GothamBold,
                TextSize = 11
            })
        elseif opt.Type == "Keybind" then
            local Btn = Create("TextButton", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Text = "Bind: " .. (opt.Current and opt.Current.Name or "None"),
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12
            })
            Btn.MouseButton1Click:Connect(function()
                Btn.Text = "Press any key..."
                local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then
                    opt.Callback(input.KeyCode)
                    Btn.Text = "Bind: " .. input.KeyCode.Name
                end
            end)
        elseif opt.Type == "ColorPicker" then
            local ColorFrame = Create("Frame", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20)
            })
            Create("TextLabel", {
                Parent = ColorFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(0, 100, 1, 0),
                Text = opt.Text,
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local Preview = Create("TextButton", {
                Parent = ColorFrame,
                BackgroundColor3 = opt.Default or Color3.new(1,1,1),
                Position = UDim2.new(1, -25, 0.5, -6),
                Size = UDim2.new(0, 20, 0, 12),
                Text = ""
            })
            Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 2)})
            
            -- Simple Random Color for demo (Proper picker requires huge code)
            Preview.MouseButton1Click:Connect(function()
                local r = math.random()
                local g = math.random()
                local b = math.random()
                local newCol = Color3.new(r,g,b)
                Preview.BackgroundColor3 = newCol
                opt.Callback(newCol)
            end)
        end
    end
end

-- Watermark System
function Library:SetWatermark(Text)
    local GUI = get_hui:FindFirstChild("SkechWatermark") or Create("ScreenGui", {Name = "SkechWatermark", Parent = get_hui})
    local Frame = GUI:FindFirstChild("Main") or Create("Frame", {
        Name = "Main",
        Parent = GUI,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        Position = UDim2.new(0.85, 0, 0.02, 0),
        Size = UDim2.new(0, 0, 0, 26), -- Auto sized
        AutomaticSize = Enum.AutomaticSize.X
    })
    
    if not Frame:FindFirstChild("UIStroke") then
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Frame})
        Create("UIStroke", {Color = Library.Accent, Thickness = 1, Parent = Frame})
        Create("UIPadding", {Parent = Frame, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
    end

    local Label = Frame:FindFirstChild("Label") or Create("TextLabel", {
        Name = "Label",
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 12,
        Text = Text
    })
    
    Label.Text = Text
    
    -- Accent Line on Top
    if not Frame:FindFirstChild("TopLine") then
        Create("Frame", {
            Name = "TopLine",
            Parent = Frame,
            BackgroundColor3 = Library.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 0)
        })
    end
end

return Library
