--[[
    Kaelith Internal UI Library (Remastered)
    Style: Skeet/Neverlose/Fatality (Dark & Red Accents)
    Features: Watermark, Keybinds, Options, ColorPicker, Multi-Dropdown
]]

local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Kaelith = {
    Open = true,
    Theme = {
        Accent = Color3.fromRGB(215, 35, 35), -- Vermelho Skech
        Background = Color3.fromRGB(18, 18, 18),
        Section = Color3.fromRGB(24, 24, 24),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(140, 140, 140),
        Outline = Color3.fromRGB(45, 45, 45),
        OutlineAccent = Color3.fromRGB(215, 35, 35)
    },
    Keybind = Enum.KeyCode.RightShift, -- Tecla padrão para minimizar
    Toggled = true
}

-- // Utility Functions // --
local function Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
    end)
    InputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            object.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

-- // Watermark Function // --
function Kaelith:Watermark(Config)
    local WatermarkGui = Create("ScreenGui", {Name = "KaelithWatermark", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    
    local Main = Create("Frame", {
        Name = "Main", Parent = WatermarkGui, BackgroundColor3 = Kaelith.Theme.Background,
        BorderSizePixel = 0, Position = UDim2.new(0.02, 0, 0.02, 0), Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X
    })
    
    -- Estilo Skeet (Barra colorida em cima)
    Create("Frame", {Parent = Main, BackgroundColor3 = Kaelith.Theme.Accent, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0,0,0,0), BorderSizePixel = 0})
    Create("UIStroke", {Parent = Main, Color = Color3.fromRGB(0,0,0), Thickness = 2}) -- Borda preta grossa externa
    Create("UIPadding", {Parent = Main, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0,4)})
    
    local Label = Create("TextLabel", {
        Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Code, Text = "", TextColor3 = Kaelith.Theme.Text, TextSize = 13
    })

    -- Atualizador de Status (FPS, Ping, Time)
    RunService.RenderStepped:Connect(function()
        local FPS = math.floor(1 / RunService.RenderStepped:Wait())
        local Ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        local Date = os.date("%H:%M:%S")
        
        Label.Text = string.format("%s | %s | FPS: %d | Ping: %dms | %s", 
            Config.Name or "Cheat", 
            LocalPlayer.Name, 
            FPS, 
            Ping, 
            Date
        )
    end)
end

-- // Window Initialization // --
function Kaelith:Init(Config)
    Kaelith.Keybind = Config.Keybind or Enum.KeyCode.RightShift
    
    -- Destruir UI antiga
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "KaelithUI" or v.Name == "KaelithWatermark" then v:Destroy() end
    end

    local ScreenGui = Create("ScreenGui", {Name = "KaelithUI", Parent = CoreGui, IgnoreGuiInset = true})
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Kaelith.Theme.Background,
        Position = UDim2.new(0.5, -275, 0.5, -175), Size = UDim2.new(0, 550, 0, 400), BorderSizePixel = 0
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = MainFrame, Color = Kaelith.Theme.OutlineAccent, Thickness = 1}) -- Borda Accent

    -- Topbar
    local Topbar = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
    MakeDraggable(Topbar, MainFrame)
    
    Create("TextLabel", {
        Parent = Topbar, Text = Config.Name or "Kaelith", TextColor3 = Kaelith.Theme.Accent,
        Font = Enum.Font.GothamBold, TextSize = 16, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Containers
    local Sidebar = Create("ScrollingFrame", {
        Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 130, 1, -40),
        Position = UDim2.new(0, 10, 0, 35), ScrollBarThickness = 0
    })
    local SidebarLayout = Create("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 5)})

    local PageContainer = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -160, 1, -40),
        Position = UDim2.new(0, 150, 0, 35)
    })

    -- Toggle UI Logic
    InputService.InputBegan:Connect(function(input)
        if input.KeyCode == Kaelith.Keybind then
            Kaelith.Toggled = not Kaelith.Toggled
            ScreenGui.Enabled = Kaelith.Toggled
        end
    end)

    local LibraryFunctions = {}
    local FirstTab = true

    function LibraryFunctions:Tab(Name, Icon)
        local TabButton = Create("TextButton", {
            Parent = Sidebar, BackgroundColor3 = Kaelith.Theme.Section, Size = UDim2.new(1, 0, 0, 32),
            Text = Name, TextColor3 = Kaelith.Theme.TextDim, Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 4)})
        
        local Page = Create("ScrollingFrame", {
            Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Kaelith.Theme.Accent
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
        Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 6)})

        if FirstTab then
            FirstTab = false
            Page.Visible = true
            TabButton.TextColor3 = Kaelith.Theme.Text
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do 
                if v:IsA("TextButton") then 
                    TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Kaelith.Theme.TextDim, BackgroundColor3 = Kaelith.Theme.Section}):Play()
                end 
            end
            
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Kaelith.Theme.Text, BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        end)

        local ElementFunctions = {}

        function ElementFunctions:Section(Text)
            local SecFrame = Create("Frame", {Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25)})
            Create("TextLabel", {
                Parent = SecFrame, Text = Text, TextColor3 = Kaelith.Theme.Accent, Font = Enum.Font.GothamBold,
                TextSize = 12, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function ElementFunctions:Toggle(Text, Default, Callback)
            local Actions = {}
            local Enabled = Default or false
            local OptionsFrame -- Forward declaration

            local ToggleFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Kaelith.Theme.Section, Size = UDim2.new(1, 0, 0, 30)
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = ToggleFrame, Color = Kaelith.Theme.Outline, Thickness = 1})

            local ToggleBtn = Create("TextButton", {
                Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                Text = "", ZIndex = 2
            })

            local Title = Create("TextLabel", {
                Parent = ToggleFrame, Text = Text, TextColor3 = Kaelith.Theme.Text, Font = Enum.Font.Gotham,
                TextSize = 13, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Checkbox = Create("Frame", {
                Parent = ToggleFrame, BackgroundColor3 = Color3.fromRGB(15, 15, 15), Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(1, -25, 0.5, -9)
            })
            Create("UICorner", {Parent = Checkbox, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = Checkbox, Color = Kaelith.Theme.Outline, Thickness = 1})
            
            local CheckIndicator = Create("Frame", {
                Parent = Checkbox, BackgroundColor3 = Kaelith.Theme.Accent, Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0, 2, 0, 2), BackgroundTransparency = Enabled and 0 or 1
            })
            Create("UICorner", {Parent = CheckIndicator, CornerRadius = UDim.new(0, 2)})

            local function SetState(val)
                Enabled = val
                TweenService:Create(CheckIndicator, TweenInfo.new(0.2), {BackgroundTransparency = Enabled and 0 or 1}):Play()
                pcall(Callback, Enabled)
            end

            ToggleBtn.MouseButton1Click:Connect(function() SetState(not Enabled) end)
            if Default then SetState(true) end

            -- Options Container (Lado direito do toggle)
            local OptionsContainer = Create("Frame", {
                Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(1, -35, 0, 0), AutomaticSize = Enum.AutomaticSize.X
            })
            local OptLayout = Create("UIListLayout", {
                Parent = OptionsContainer, FillDirection = Enum.FillDirection.Horizontal, 
                HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)
            })

            -- :: Adicionar Keybind :: --
            function Actions:AddKeybind(DefaultKey)
                local Key = DefaultKey or Enum.KeyCode.None
                local Waiting = false
                
                local KeyBtn = Create("TextButton", {
                    Parent = OptionsContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0),
                    Text = Key.Name:sub(1,3), TextColor3 = Kaelith.Theme.TextDim, Font = Enum.Font.Code, TextSize = 11,
                    LayoutOrder = 2
                })

                KeyBtn.MouseButton1Click:Connect(function()
                    Waiting = true
                    KeyBtn.Text = "..."
                    local conn
                    conn = InputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            Key = input.KeyCode
                            if Key == Enum.KeyCode.Unknown then Key = Enum.UserInputType.MouseButton3 end -- Exemplo
                            
                            -- Tratamento de nomes
                            local Name = Key.Name
                            if Name == "Unknown" then Name = "MB3" end
                            
                            KeyBtn.Text = Name:sub(1,3)
                            Waiting = false
                            conn:Disconnect()
                        end
                    end)
                end)

                -- Listener global para ativar o toggle
                InputService.InputBegan:Connect(function(input, gpe)
                    if not gpe and input.KeyCode == Key and not Waiting then
                        SetState(not Enabled)
                    end
                end)
            end

            -- :: Adicionar ColorPicker :: --
            function Actions:AddColorPicker(DefaultColor, ColorCallback)
                local CurrentColor = DefaultColor or Color3.fromRGB(255, 255, 255)
                local PickerOpen = false
                
                local ColorBtn = Create("TextButton", {
                    Parent = OptionsContainer, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0,0,0.5,-7),
                    BackgroundColor3 = CurrentColor, Text = "", LayoutOrder = 1
                })
                Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(0, 3)})
                
                local PickerFrame = Create("Frame", {
                    Parent = ScreenGui, Size = UDim2.new(0, 150, 0, 150), BackgroundColor3 = Kaelith.Theme.Background,
                    Visible = false, ZIndex = 10, BorderSizePixel = 0
                })
                Create("UIStroke", {Parent = PickerFrame, Color = Kaelith.Theme.Outline, Thickness = 1})
                
                -- Lógica simples de ColorPicker (HSV) seria implementada aqui
                -- Para brevidade, vamos fazer apenas um botão visual que abre/fecha
                -- Em uma UI completa, você precisaria de imagens de espectro de cor.
                
                ColorBtn.MouseButton1Click:Connect(function()
                    PickerOpen = not PickerOpen
                    PickerFrame.Visible = PickerOpen
                    PickerFrame.Position = UDim2.new(0, Mouse.X + 10, 0, Mouse.Y + 10)
                end)
                
                -- (Simplificado: Aqui você adicionaria a lógica RGB completa)
            end

            return Actions
        end

        function ElementFunctions:Dropdown(Text, Options, Multi, Callback)
            local Dropped = false
            local Selected = Multi and {} or Options[1]
            
            local DropFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Kaelith.Theme.Section, Size = UDim2.new(1, 0, 0, 30),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = DropFrame, Color = Kaelith.Theme.Outline, Thickness = 1})
            
            local Title = Create("TextLabel", {
                Parent = DropFrame, Text = Text, TextColor3 = Kaelith.Theme.Text, Font = Enum.Font.Gotham,
                TextSize = 13, Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 10, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local StateTxt = Create("TextLabel", {
                Parent = DropFrame, Text = Multi and "..." or Selected, TextColor3 = Kaelith.Theme.Accent, Font = Enum.Font.Gotham,
                TextSize = 12, Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(1, -110, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Right
            })
            Create("TextButton", {Parent = DropFrame, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}).MouseButton1Click:Connect(function()
                Dropped = not Dropped
                local Height = Dropped and (30 + (#Options * 25) + 5) or 30
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, Height)}):Play()
            end)

            local ListFrame = Create("Frame", {
                Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -30),
                Position = UDim2.new(0, 0, 0, 30)
            })
            local ListLayout = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})

            for _, opt in pairs(Options) do
                local OptBtn = Create("TextButton", {
                    Parent = ListFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25),
                    Text = "  " .. opt, TextColor3 = Kaelith.Theme.TextDim, Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12
                })
                
                OptBtn.MouseButton1Click:Connect(function()
                    if Multi then
                        if table.find(Selected, opt) then
                            table.remove(Selected, table.find(Selected, opt))
                            OptBtn.TextColor3 = Kaelith.Theme.TextDim
                        else
                            table.insert(Selected, opt)
                            OptBtn.TextColor3 = Kaelith.Theme.Accent
                        end
                        StateTxt.Text = #Selected .. " Selected"
                        Callback(Selected)
                    else
                        Selected = opt
                        StateTxt.Text = Selected
                        Dropped = false
                        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                        Callback(Selected)
                        -- Reset colors
                        for _, v in pairs(ListFrame:GetChildren()) do
                            if v:IsA("TextButton") then v.TextColor3 = Kaelith.Theme.TextDim end
                        end
                        OptBtn.TextColor3 = Kaelith.Theme.Accent
                    end
                end)
            end
        end

        function ElementFunctions:Slider(Text, Min, Max, Default, Callback)
            local Value = Default
            local Dragging = false

            local SliderFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Kaelith.Theme.Section, Size = UDim2.new(1, 0, 0, 45)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = SliderFrame, Color = Kaelith.Theme.Outline, Thickness = 1})

            local Title = Create("TextLabel", {
                Parent = SliderFrame, Text = Text, TextColor3 = Kaelith.Theme.Text, Font = Enum.Font.Gotham,
                TextSize = 13, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 15), TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValText = Create("TextLabel", {
                Parent = SliderFrame, Text = tostring(Value), TextColor3 = Kaelith.Theme.TextDim, Font = Enum.Font.Gotham,
                TextSize = 12, Position = UDim2.new(1, -40, 0, 5), Size = UDim2.new(0, 30, 0, 15), TextXAlignment = Enum.TextXAlignment.Right
            })

            local BarBG = Create("Frame", {
                Parent = SliderFrame, BackgroundColor3 = Color3.fromRGB(10, 10, 10), Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 0, 30)
            })
            Create("UICorner", {Parent = BarBG, CornerRadius = UDim.new(0, 3)})

            local BarFill = Create("Frame", {
                Parent = BarBG, BackgroundColor3 = Kaelith.Theme.Accent, Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                BorderSizePixel = 0
            })
            Create("UICorner", {Parent = BarFill, CornerRadius = UDim.new(0, 3)})

            local function Update(input)
                local SizeX = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                local NewVal = math.floor(Min + ((Max - Min) * SizeX))
                BarFill.Size = UDim2.new(SizeX, 0, 1, 0)
                ValText.Text = tostring(NewVal)
                Callback(NewVal)
            end

            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    Update(input)
                end
            end)
            
            InputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
            end)
            
            InputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input)
                end
            end)
        end

        function ElementFunctions:Button(Text, Callback)
            local Btn = Create("TextButton", {
                Parent = Page, BackgroundColor3 = Kaelith.Theme.Section, Size = UDim2.new(1, 0, 0, 30),
                Text = Text, TextColor3 = Kaelith.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13
            })
            Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = Btn, Color = Kaelith.Theme.Outline, Thickness = 1})
            
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Kaelith.Theme.Accent}):Play()
                wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Kaelith.Theme.Section}):Play()
                pcall(Callback)
            end)
        end

        return ElementFunctions
    end

    return LibraryFunctions
end

return Kaelith
