--[[
    KEYSER UI V8.5 - FIVEM & IMGUI EDITION (OPTIMIZED by AI)
    Structure: Intro -> Sidebar/Topbar -> Content Canvas -> Section Cards
    
    Features:
    - FiveM Style Layout (Floating sections over dark canvas).
    - Smooth CanvasGroups for Window & Flyout fading (No lag).
    - Responsive Lerp Tracking for Flyout Menus.
    - Two-tone Section Cards (Header differs from body).
    - Independent Section Scrolling (Pass Height in Section Config).
    - Keybind System (Standalone & Embedded in Toggles).
    - Nested Options (Gear Icon / Flyout Menus) with smooth expanding.
    - Massive Lucide Icon Library (Integrated from Fatality).
    - Premium Animations (Quint Easing & Responsive Color Tweens).
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}

--[ THEME & ICONS - FIVEM / IMGUI STYLE ]
local Keyser = {
    Colors = {
        Main          = Color3.fromRGB(19, 18, 23),     -- #131217 (Fundo da Sidebar e Topbar)
        Canvas        = Color3.fromRGB(14, 13, 18),     -- #0e0d12 (Fundo do Quadro/Canvas)
        SectionHeader = Color3.fromRGB(28, 27, 34),     -- #1c1b22 (Fundo do Título da Seção)
        SectionBg     = Color3.fromRGB(19, 18, 23),     -- #131217 (Fundo dos Cards das Seções)
        Divider       = Color3.fromRGB(35, 34, 40),     -- Linhas sutis
        Element       = Color3.fromRGB(28, 27, 33),     -- Fundo das caixas de input e binds
        Stroke        = Color3.fromRGB(40, 38, 45),     -- Bordas 
        Text          = Color3.fromRGB(240, 240, 245),  -- Texto claro
        TextDark      = Color3.fromRGB(120, 120, 130),  -- Texto apagado (inativo)
        Accent        = Color3.fromRGB(255, 255, 255),  -- Cor principal ativa
        Hover         = Color3.fromRGB(45, 43, 50),     -- Efeito Hover
        ValueBox      = Color3.fromRGB(16, 15, 20)      -- Fundo de valores de slider
    },
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    Icons = {
        ["lucide-accessibility"] = "rbxassetid://10709751939",
        ["lucide-activity"] = "rbxassetid://10709752035",
        ["lucide-air-vent"] = "rbxassetid://10709752131",
        ["lucide-airplay"] = "rbxassetid://10709752254",
        ["lucide-alarm-check"] = "rbxassetid://10709752405",["lucide-alarm-clock"] = "rbxassetid://10709752630",
        ["lucide-alarm-clock-off"] = "rbxassetid://10709752508",
        ["lucide-alarm-minus"] = "rbxassetid://10709752732",
        ["lucide-alarm-plus"] = "rbxassetid://10709752825",
        ["lucide-album"] = "rbxassetid://10709752906",["lucide-alert-circle"] = "rbxassetid://10709752996",
        ["lucide-alert-octagon"] = "rbxassetid://10709753064",
        ["lucide-alert-triangle"] = "rbxassetid://10709753149",
        ["lucide-align-center"] = "rbxassetid://10709753570",["lucide-align-center-horizontal"] = "rbxassetid://10709753272",
        ["lucide-align-center-vertical"] = "rbxassetid://10709753421",
        ["lucide-align-end-horizontal"] = "rbxassetid://10709753692",
        ["lucide-align-end-vertical"] = "rbxassetid://10709753808",["lucide-align-horizontal-distribute-center"] = "rbxassetid://10747779791",
        ["lucide-align-horizontal-distribute-end"] = "rbxassetid://10747784534",["lucide-align-horizontal-distribute-start"] = "rbxassetid://10709754118",
        ["lucide-align-horizontal-justify-center"] = "rbxassetid://10709754204",
        ["lucide-align-horizontal-justify-end"] = "rbxassetid://10709754317",["lucide-align-horizontal-justify-start"] = "rbxassetid://10709754436",
        ["lucide-align-horizontal-space-around"] = "rbxassetid://10709754590",["lucide-align-horizontal-space-between"] = "rbxassetid://10709754749",
        ["lucide-align-justify"] = "rbxassetid://10709759610",
        ["lucide-align-left"] = "rbxassetid://10709759764",
        ["lucide-align-right"] = "rbxassetid://10709759895",["lucide-align-start-horizontal"] = "rbxassetid://10709760051",["lucide-align-start-vertical"] = "rbxassetid://10709760244",
        ["lucide-align-vertical-distribute-center"] = "rbxassetid://10709760351",["lucide-align-vertical-distribute-end"] = "rbxassetid://10709760434",
        ["lucide-align-vertical-distribute-start"] = "rbxassetid://10709760612",
        ["lucide-align-vertical-justify-center"] = "rbxassetid://10709760814",["lucide-align-vertical-justify-end"] = "rbxassetid://10709761003",
        ["lucide-align-vertical-justify-start"] = "rbxassetid://10709761176",["lucide-align-vertical-space-around"] = "rbxassetid://10709761324",["lucide-align-vertical-space-between"] = "rbxassetid://10709761434",
        ["lucide-anchor"] = "rbxassetid://10709761530",
        ["lucide-angry"] = "rbxassetid://10709761629",
        ["lucide-annoyed"] = "rbxassetid://10709761722",["lucide-aperture"] = "rbxassetid://10709761813",["lucide-apple"] = "rbxassetid://10709761889",
        ["lucide-archive"] = "rbxassetid://10709762233",
        ["lucide-archive-restore"] = "rbxassetid://10709762058",
        ["lucide-armchair"] = "rbxassetid://10709762327",
        ["lucide-arrow-big-down"] = "rbxassetid://10747796644",["lucide-arrow-big-left"] = "rbxassetid://10709762574",
        ["lucide-arrow-big-right"] = "rbxassetid://10709762727",
        ["lucide-arrow-big-up"] = "rbxassetid://10709762879",["lucide-arrow-down"] = "rbxassetid://10709767827",["lucide-arrow-down-circle"] = "rbxassetid://10709763034",
        ["lucide-arrow-down-left"] = "rbxassetid://10709767656",
        ["lucide-arrow-down-right"] = "rbxassetid://10709767750",["lucide-arrow-left"] = "rbxassetid://10709768114",
        ["lucide-arrow-left-circle"] = "rbxassetid://10709767936",
        ["lucide-arrow-left-right"] = "rbxassetid://10709768019",
        ["lucide-arrow-right"] = "rbxassetid://10709768347",["lucide-arrow-right-circle"] = "rbxassetid://10709768226",
        ["lucide-arrow-up"] = "rbxassetid://10709768939",
        ["lucide-arrow-up-circle"] = "rbxassetid://10709768432",["lucide-arrow-up-down"] = "rbxassetid://10709768538",["lucide-arrow-up-left"] = "rbxassetid://10709768661",
        ["lucide-arrow-up-right"] = "rbxassetid://10709768787",
        ["lucide-asterisk"] = "rbxassetid://10709769095",
        ["lucide-at-sign"] = "rbxassetid://10709769286",["lucide-award"] = "rbxassetid://10709769406",
        ["lucide-axe"] = "rbxassetid://10709769508",
        ["lucide-axis-3d"] = "rbxassetid://10709769598",
        ["lucide-baby"] = "rbxassetid://10709769732",
        ["lucide-backpack"] = "rbxassetid://10709769841",
        ["lucide-baggage-claim"] = "rbxassetid://10709769935",["lucide-banana"] = "rbxassetid://10709770005",
        ["lucide-banknote"] = "rbxassetid://10709770178",
        ["lucide-bar-chart"] = "rbxassetid://10709773755",
        ["lucide-bar-chart-2"] = "rbxassetid://10709770317",["lucide-bar-chart-3"] = "rbxassetid://10709770431",["lucide-bar-chart-4"] = "rbxassetid://10709770560",
        ["lucide-bar-chart-horizontal"] = "rbxassetid://10709773669",
        ["lucide-barcode"] = "rbxassetid://10747360675",
        ["lucide-baseline"] = "rbxassetid://10709773863",["lucide-bath"] = "rbxassetid://10709773963",["lucide-battery"] = "rbxassetid://10709774640",
        ["lucide-battery-charging"] = "rbxassetid://10709774068",
        ["lucide-battery-full"] = "rbxassetid://10709774206",
        ["lucide-battery-low"] = "rbxassetid://10709774370",
        ["lucide-battery-medium"] = "rbxassetid://10709774513",["lucide-beaker"] = "rbxassetid://10709774756",
        ["lucide-bed"] = "rbxassetid://10709775036",
        ["lucide-bed-double"] = "rbxassetid://10709774864",
        ["lucide-bed-single"] = "rbxassetid://10709774968",
        ["lucide-beer"] = "rbxassetid://10709775167",
        ["lucide-bell"] = "rbxassetid://10709775704",["lucide-bell-minus"] = "rbxassetid://10709775241",
        ["lucide-bell-off"] = "rbxassetid://10709775320",
        ["lucide-bell-plus"] = "rbxassetid://10709775448",
        ["lucide-bell-ring"] = "rbxassetid://10709775560",
        ["lucide-bike"] = "rbxassetid://10709775894",["lucide-binary"] = "rbxassetid://10709776050",["lucide-bitcoin"] = "rbxassetid://10709776126",
        ["lucide-bluetooth"] = "rbxassetid://10709776655",
        ["lucide-bluetooth-connected"] = "rbxassetid://10709776240",
        ["lucide-bluetooth-off"] = "rbxassetid://10709776344",
        ["lucide-bluetooth-searching"] = "rbxassetid://10709776501",["lucide-bold"] = "rbxassetid://10747813908",["lucide-bomb"] = "rbxassetid://10709781460",
        ["lucide-bone"] = "rbxassetid://10709781605",
        ["lucide-book"] = "rbxassetid://10709781824",
        ["lucide-book-open"] = "rbxassetid://10709781717",
        ["lucide-bookmark"] = "rbxassetid://10709782154",
        ["lucide-bookmark-minus"] = "rbxassetid://10709781919",["lucide-bookmark-plus"] = "rbxassetid://10709782044",
        ["lucide-bot"] = "rbxassetid://10709782230",
        ["lucide-box"] = "rbxassetid://10709782497",
        ["lucide-box-select"] = "rbxassetid://10709782342",
        ["lucide-boxes"] = "rbxassetid://10709782582",
        ["lucide-briefcase"] = "rbxassetid://10709782662",["lucide-brush"] = "rbxassetid://10709782758",["lucide-bug"] = "rbxassetid://10709782845",
        ["lucide-building"] = "rbxassetid://10709783051",
        ["lucide-building-2"] = "rbxassetid://10709782939",
        ["lucide-bus"] = "rbxassetid://10709783137",
        ["lucide-cake"] = "rbxassetid://10709783217",
        ["lucide-calculator"] = "rbxassetid://10709783311",
        ["lucide-calendar"] = "rbxassetid://10709789505",["lucide-calendar-check"] = "rbxassetid://10709783474",
        ["lucide-calendar-check-2"] = "rbxassetid://10709783392",
        ["lucide-calendar-clock"] = "rbxassetid://10709783577",
        ["lucide-calendar-days"] = "rbxassetid://10709783673",["lucide-calendar-heart"] = "rbxassetid://10709783835",
        ["lucide-calendar-minus"] = "rbxassetid://10709783959",
        ["lucide-calendar-off"] = "rbxassetid://10709788784",
        ["lucide-calendar-plus"] = "rbxassetid://10709788937",
        ["lucide-calendar-range"] = "rbxassetid://10709789053",["lucide-calendar-search"] = "rbxassetid://10709789200",
        ["lucide-calendar-x"] = "rbxassetid://10709789407",
        ["lucide-calendar-x-2"] = "rbxassetid://10709789329",
        ["lucide-camera"] = "rbxassetid://10709789686",
        ["lucide-camera-off"] = "rbxassetid://10747822677",["lucide-car"] = "rbxassetid://10709789810",
        ["lucide-carrot"] = "rbxassetid://10709789960",
        ["lucide-cast"] = "rbxassetid://10709790097",
        ["lucide-charge"] = "rbxassetid://10709790202",
        ["lucide-check"] = "rbxassetid://10709790644",
        ["lucide-check-circle"] = "rbxassetid://10709790387",["lucide-check-circle-2"] = "rbxassetid://10709790298",
        ["lucide-check-square"] = "rbxassetid://10709790537",
        ["lucide-chef-hat"] = "rbxassetid://10709790757",
        ["lucide-cherry"] = "rbxassetid://10709790875",
        ["lucide-chevron-down"] = "rbxassetid://10709790948",["lucide-chevron-first"] = "rbxassetid://10709791015",["lucide-chevron-last"] = "rbxassetid://10709791130",
        ["lucide-chevron-left"] = "rbxassetid://10709791281",
        ["lucide-chevron-right"] = "rbxassetid://10709791437",
        ["lucide-chevron-up"] = "rbxassetid://10709791523",["lucide-chevrons-down"] = "rbxassetid://10709796864",
        ["lucide-chevrons-down-up"] = "rbxassetid://10709791632",
        ["lucide-chevrons-left"] = "rbxassetid://10709797151",["lucide-chevrons-left-right"] = "rbxassetid://10709797006",
        ["lucide-chevrons-right"] = "rbxassetid://10709797382",
        ["lucide-chevrons-right-left"] = "rbxassetid://10709797274",["lucide-chevrons-up"] = "rbxassetid://10709797622",
        ["lucide-chevrons-up-down"] = "rbxassetid://10709797508",
        ["lucide-chrome"] = "rbxassetid://10709797725",
        ["lucide-circle"] = "rbxassetid://10709798174",["lucide-circle-dot"] = "rbxassetid://10709797837",["lucide-circle-ellipsis"] = "rbxassetid://10709797985",
        ["lucide-circle-slashed"] = "rbxassetid://10709798100",
        ["lucide-citrus"] = "rbxassetid://10709798276",
        ["lucide-clapperboard"] = "rbxassetid://10709798350",
        ["lucide-clipboard"] = "rbxassetid://10709799288",["lucide-clipboard-check"] = "rbxassetid://10709798443",
        ["lucide-clipboard-copy"] = "rbxassetid://10709798574",
        ["lucide-clipboard-edit"] = "rbxassetid://10709798682",
        ["lucide-clipboard-list"] = "rbxassetid://10709798792",["lucide-clipboard-signature"] = "rbxassetid://10709798890",["lucide-clipboard-type"] = "rbxassetid://10709798999",
        ["lucide-clipboard-x"] = "rbxassetid://10709799124",
        ["lucide-clock"] = "rbxassetid://10709805144",
        ["lucide-cloud"] = "rbxassetid://10709806740",
        ["lucide-code"] = "rbxassetid://10709810463",["lucide-code-2"] = "rbxassetid://10709807111",["lucide-coffee"] = "rbxassetid://10709810814",
        ["lucide-cog"] = "rbxassetid://10709810948",
        ["lucide-coins"] = "rbxassetid://10709811110",
        ["lucide-command"] = "rbxassetid://10709811365",
        ["lucide-compass"] = "rbxassetid://10709811445",
        ["lucide-component"] = "rbxassetid://10709811595",
        ["lucide-copy"] = "rbxassetid://10709812159",
        ["lucide-cpu"] = "rbxassetid://10709813383",["lucide-crosshair"] = "rbxassetid://10709818534",
        ["lucide-crown"] = "rbxassetid://10709818626",
        ["lucide-database"] = "rbxassetid://10709818996",
        ["lucide-delete"] = "rbxassetid://10709819059",
        ["lucide-diamond"] = "rbxassetid://10709819149",
        ["lucide-disc"] = "rbxassetid://10723343537",
        ["lucide-download"] = "rbxassetid://10723344270",
        ["lucide-droplet"] = "rbxassetid://10723344432",["lucide-edit"] = "rbxassetid://10734883598",
        ["lucide-eye"] = "rbxassetid://10723346959",
        ["lucide-eye-off"] = "rbxassetid://10723346871",
        ["lucide-file"] = "rbxassetid://10723374641",
        ["lucide-filter"] = "rbxassetid://10723375128",
        ["lucide-flag"] = "rbxassetid://10723375890",
        ["lucide-flame"] = "rbxassetid://10723376114",
        ["lucide-folder"] = "rbxassetid://10723387563",["lucide-gamepad"] = "rbxassetid://10723395457",
        ["lucide-gamepad-2"] = "rbxassetid://10723395215",
        ["lucide-globe"] = "rbxassetid://10723404337",
        ["lucide-hash"] = "rbxassetid://10723405975",
        ["lucide-headphones"] = "rbxassetid://10723406165",
        ["lucide-heart"] = "rbxassetid://10723406885",
        ["lucide-help-circle"] = "rbxassetid://10723406988",["lucide-home"] = "rbxassetid://10723407389",["lucide-image"] = "rbxassetid://10723415040",
        ["lucide-info"] = "rbxassetid://10723415903",
        ["lucide-key"] = "rbxassetid://10723416652",
        ["lucide-keyboard"] = "rbxassetid://10723416765",
        ["lucide-layers"] = "rbxassetid://10723424505",
        ["lucide-layout"] = "rbxassetid://10723425376",
        ["lucide-link"] = "rbxassetid://10723426722",["lucide-list"] = "rbxassetid://10723433811",["lucide-lock"] = "rbxassetid://10723434711",
        ["lucide-log-in"] = "rbxassetid://10723434830",
        ["lucide-log-out"] = "rbxassetid://10723434906",
        ["lucide-mail"] = "rbxassetid://10734885430",
        ["lucide-map"] = "rbxassetid://10734886202",
        ["lucide-maximize"] = "rbxassetid://10734886735",["lucide-menu"] = "rbxassetid://10734887784",
        ["lucide-message-circle"] = "rbxassetid://10734888000",
        ["lucide-message-square"] = "rbxassetid://10734888228",
        ["lucide-mic"] = "rbxassetid://10734888864",
        ["lucide-minimize"] = "rbxassetid://10734895698",
        ["lucide-minus"] = "rbxassetid://10734896206",
        ["lucide-monitor"] = "rbxassetid://10734896881",["lucide-moon"] = "rbxassetid://10734897102",
        ["lucide-more-horizontal"] = "rbxassetid://10734897250",
        ["lucide-more-vertical"] = "rbxassetid://10734897387",
        ["lucide-mouse"] = "rbxassetid://10734898592",
        ["lucide-move"] = "rbxassetid://10734900011",
        ["lucide-music"] = "rbxassetid://10734905958",
        ["lucide-navigation"] = "rbxassetid://10734906744",
        ["lucide-package"] = "rbxassetid://10734909540",["lucide-pause"] = "rbxassetid://10734919336",
        ["lucide-pen-tool"] = "rbxassetid://10734919503",
        ["lucide-pencil"] = "rbxassetid://10734919691",
        ["lucide-percent"] = "rbxassetid://10734919919",
        ["lucide-phone"] = "rbxassetid://10734921524",
        ["lucide-pie-chart"] = "rbxassetid://10734921727",
        ["lucide-pin"] = "rbxassetid://10734922324",["lucide-play"] = "rbxassetid://10734923549",["lucide-plus"] = "rbxassetid://10734924532",
        ["lucide-pointer"] = "rbxassetid://10734929723",
        ["lucide-power"] = "rbxassetid://10734930466",
        ["lucide-printer"] = "rbxassetid://10734930632",
        ["lucide-radio"] = "rbxassetid://10734931596",
        ["lucide-refresh-ccw"] = "rbxassetid://10734933056",
        ["lucide-refresh-cw"] = "rbxassetid://10734933222",["lucide-repeat"] = "rbxassetid://10734933966",
        ["lucide-save"] = "rbxassetid://10734941499",
        ["lucide-scissors"] = "rbxassetid://10734942778",
        ["lucide-search"] = "rbxassetid://10734943674",
        ["lucide-send"] = "rbxassetid://10734943902",
        ["lucide-server"] = "rbxassetid://10734949856",
        ["lucide-settings"] = "rbxassetid://10734950309",
        ["lucide-share"] = "rbxassetid://10734950813",["lucide-shield"] = "rbxassetid://10734951847",
        ["lucide-shopping-cart"] = "rbxassetid://10734952479",
        ["lucide-shuffle"] = "rbxassetid://10734953451",
        ["lucide-sidebar"] = "rbxassetid://10734954301",
        ["lucide-sliders"] = "rbxassetid://10734963400",
        ["lucide-smartphone"] = "rbxassetid://10734963940",
        ["lucide-smile"] = "rbxassetid://10734964441",
        ["lucide-speaker"] = "rbxassetid://10734965419",
        ["lucide-square"] = "rbxassetid://10734965702",["lucide-star"] = "rbxassetid://10734966248",
        ["lucide-sun"] = "rbxassetid://10734974297",
        ["lucide-sword"] = "rbxassetid://10734975486",
        ["lucide-swords"] = "rbxassetid://10734975692",
        ["lucide-table"] = "rbxassetid://10734976230",
        ["lucide-tablet"] = "rbxassetid://10734976394",
        ["lucide-tag"] = "rbxassetid://10734976528",
        ["lucide-tags"] = "rbxassetid://10734976739",["lucide-target"] = "rbxassetid://10734977012",["lucide-terminal"] = "rbxassetid://10734982144",
        ["lucide-thumbs-down"] = "rbxassetid://10734983359",
        ["lucide-thumbs-up"] = "rbxassetid://10734983629",
        ["lucide-toggle-left"] = "rbxassetid://10734984834",
        ["lucide-toggle-right"] = "rbxassetid://10734985040",["lucide-trash"] = "rbxassetid://10747362393",["lucide-trash-2"] = "rbxassetid://10747362241",
        ["lucide-trending-down"] = "rbxassetid://10747363205",
        ["lucide-trending-up"] = "rbxassetid://10747363465",
        ["lucide-triangle"] = "rbxassetid://10747363621",
        ["lucide-trophy"] = "rbxassetid://10747363809",
        ["lucide-truck"] = "rbxassetid://10747364031",
        ["lucide-tv"] = "rbxassetid://10747364593",["lucide-type"] = "rbxassetid://10747364761",["lucide-umbrella"] = "rbxassetid://10747364971",
        ["lucide-underline"] = "rbxassetid://10747365191",
        ["lucide-undo"] = "rbxassetid://10747365484",
        ["lucide-unlock"] = "rbxassetid://10747366027",
        ["lucide-upload"] = "rbxassetid://10747366434",
        ["lucide-user"] = "rbxassetid://10747373176",
        ["lucide-users"] = "rbxassetid://10747373426",["lucide-video"] = "rbxassetid://10747374938",["lucide-volume"] = "rbxassetid://10747376008",
        ["lucide-volume-x"] = "rbxassetid://10747375880",
        ["lucide-wallet"] = "rbxassetid://10747376205",
        ["lucide-wand"] = "rbxassetid://10747376565",
        ["lucide-watch"] = "rbxassetid://10747376722",
        ["lucide-wifi"] = "rbxassetid://10747382504",["lucide-wind"] = "rbxassetid://10747382750",["lucide-wrench"] = "rbxassetid://10747383470",
        ["lucide-x"] = "rbxassetid://10747384394",
        ["lucide-zoom-in"] = "rbxassetid://10747384552",
        ["lucide-zoom-out"] = "rbxassetid://10747384679",
    }
}

--[ UTILS ]
local function GetIcon(name)
    if not name or name == "" then return "" end
    if string.match(name, "^rbxassetid://") then return name end
    if string.match(name, "^http://") then return name end
    local lucideName = "lucide-" .. tostring(name)
    return Keyser.Icons[lucideName] or Keyser.Icons[tostring(name)] or ""
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function MakeDraggable(dragObj, moveObj)
    local dragging = false
    local dragStart, startPos
    local inputChanged, inputEnded

    dragObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = moveObj.Position

            inputChanged = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local delta = input2.Position - dragStart
                    moveObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)

            inputEnded = UserInputService.InputEnded:Connect(function(input3)
                if input3.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    inputChanged:Disconnect()
                    inputEnded:Disconnect()
                end
            end)
        end
    end)
end

function Library:Window(Config)
    local WindowName = Config.Name or "Keyser"
    local WindowScale = Config.Scale or UDim2.new(0, 800, 0, 550)
    local ToggleKey = Config.Keybind or Enum.KeyCode.RightControl

    local Screen = Create("ScreenGui", {Name = "Keyser", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true})
    
    --[ INTRO SEQUENCE (SMOOTH CANVAS GROUP) ]
    local IntroFrame = Create("CanvasGroup", {
        Name = "Intro", Parent = Screen, BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        Position = UDim2.new(0.5, -175, 0.5, -100), Size = UDim2.new(0, 350, 0, 200),
        BorderSizePixel = 0, GroupTransparency = 0
    })
    Create("UICorner", {Parent = IntroFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = IntroFrame, Color = Keyser.Colors.Stroke, Thickness = 1})
    
    local IntroHolder = Create("Frame", {Parent = IntroFrame, BackgroundColor3 = Keyser.Colors.Main, Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true, BorderSizePixel = 0})
    Create("UICorner", {Parent = IntroHolder, CornerRadius = UDim.new(0, 6)})
    Create("UIGradient", {Parent = IntroHolder, Rotation = 30, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.5)})})
    
    local IntroTitle = Create("TextLabel", {Parent = IntroHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 0, 50), Font = Enum.Font.GothamBlack, Text = WindowName, TextColor3 = Color3.new(1,1,1), TextSize = 40, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1})
    local StatusText = Create("TextLabel", {Parent = IntroHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 110), Size = UDim2.new(1, -40, 0, 25), Font = Keyser.Font, Text = "Fetching API...", TextColor3 = Color3.new(1,1,1), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1})
    
    local ProgressBarBg = Create("Frame", {Parent = IntroHolder, BackgroundColor3 = Keyser.Colors.Canvas, Position = UDim2.new(0, 20, 0, 145), Size = UDim2.new(1, -40, 0, 4), BorderSizePixel = 0})
    Create("UICorner", {Parent = ProgressBarBg, CornerRadius = UDim.new(1, 0)})
    local ProgressBar = Create("Frame", {Parent = ProgressBarBg, BackgroundColor3 = Keyser.Colors.Accent, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0})
    Create("UICorner", {Parent = ProgressBar, CornerRadius = UDim.new(1, 0)})

    Tween(IntroTitle, {TextTransparency = 0, Position = UDim2.new(0, 0, 0, 35)}, 0.6)
    Tween(StatusText, {TextTransparency = 0}, 0.6)
    task.wait(0.6)
    
    local loadingSteps = {{0.2, "Bypassing Anticheat..."}, {0.5, "Loading Assets..."}, {0.8, "Building User Interface..."}, {1.0, "Ready!"}}
    for _, step in ipairs(loadingSteps) do
        StatusText.Text = step[2]
        Tween(ProgressBar, {Size = UDim2.new(step[1], 0, 1, 0)}, 0.4)
        task.wait(math.random(4, 8) / 10)
    end
    
    task.wait(0.3)
    Tween(IntroFrame, {GroupTransparency = 1}, 0.5)
    task.wait(0.5)
    IntroFrame:Destroy()

    -- [ MAIN WINDOW ]
    local MainFrame = Create("CanvasGroup", {
        Name = "Main", Parent = Screen, BackgroundColor3 = Keyser.Colors.Main,
        Position = UDim2.new(0.5, -WindowScale.X.Offset/2, 0.5, -WindowScale.Y.Offset/2), 
        Size = WindowScale, GroupTransparency = 1, BorderSizePixel = 0
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = MainFrame, Color = Keyser.Colors.Stroke, Thickness = 1})

    MakeDraggable(MainFrame, MainFrame)
    Tween(MainFrame, {GroupTransparency = 0}, 0.5)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ToggleKey then
            if MainFrame.GroupTransparency == 0 then
                Tween(MainFrame, {GroupTransparency = 1}, 0.3)
                for _, f in pairs(Screen:GetChildren()) do
                    if f.Name == "Flyout" and f.Visible then
                        Tween(f, {GroupTransparency = 1}, 0.3)
                        task.delay(0.3, function() f.Visible = false end)
                    end
                end
                task.delay(0.3, function() MainFrame.Visible = false end)
            else
                MainFrame.Visible = true
                Tween(MainFrame, {GroupTransparency = 0}, 0.3)
            end
        end
    end)

    --[ LAYOUT STRUCTURE - FIVEM STYLE ]
    local Header = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 65), ZIndex = 2})
    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 65), Size = UDim2.new(0, 200, 1, -65), BorderSizePixel = 0})
    
    local LogoArea = Create("Frame", {Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0)})
    Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 14), Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBlack, Text = WindowName, TextColor3 = Color3.fromRGB(150, 150, 160), TextSize = 22})
    Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 14), Font = Keyser.Font, Text = "discord.gg/keyser", TextColor3 = Keyser.Colors.TextDark, TextSize = 11})

    local NavContainer = Create("Frame", {Parent = Header, BackgroundTransparency = 1, Position = UDim2.new(0, 200, 0, 0), Size = UDim2.new(1, -200, 1, 0)})
    
    local SideContainer = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)})
    Create("UIListLayout", {Parent = SideContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
    Create("UIPadding", {Parent = SideContainer, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})

    -- THE CANVAS (Quadro no meio)
    local PageContainer = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Keyser.Colors.Canvas,
        Position = UDim2.new(0, 200, 0, 65), Size = UDim2.new(1, -200, 1, -65), ClipsDescendants = true
    })
    
    Create("Frame", {Parent = PageContainer, BackgroundColor3 = Keyser.Colors.Stroke, Size = UDim2.new(1,0,0,1), BorderSizePixel = 0}) -- Top divider
    Create("Frame", {Parent = PageContainer, BackgroundColor3 = Keyser.Colors.Stroke, Size = UDim2.new(0,1,1,0), BorderSizePixel = 0}) -- Left divider

    local WinData = {ActiveSidebar = nil}
    local AllSidebarTabs = {}
    
    -- Function to Handle Floating "Option" Menus
    local function CreateOptionFlyout(AnchorButton)
        local Flyout = Create("CanvasGroup", {
            Name = "Flyout", Parent = Screen, BackgroundColor3 = Keyser.Colors.SectionBg,
            Size = UDim2.new(0, 180, 0, 0), Position = UDim2.new(0,0,0,0),
            ZIndex = 100, Visible = false, GroupTransparency = 1
        })
        Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = Flyout, Color = Keyser.Colors.Stroke, Thickness = 1})
        
        local Scroll = Create("ScrollingFrame", {
            Parent = Flyout, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0,0,0,5),
            ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
        })
        local List = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
        Create("UIPadding", {Parent = Scroll, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 5)})
        
        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10) end)
        
        local updater; local isOpen = false
        
        local function ToggleFlyout(state)
            isOpen = state
            if isOpen then
                Flyout.Visible = true
                Tween(Flyout, {GroupTransparency = 0}, 0.2)
                local targetHeight = math.clamp(List.AbsoluteContentSize.Y + 20, 0, 250)
                Tween(Flyout, {Size = UDim2.new(0, 180, 0, targetHeight)}, 0.3)
                Tween(AnchorButton, {Rotation = 90, ImageColor3 = Keyser.Colors.Accent}, 0.3)
                
                updater = RunService.RenderStepped:Connect(function(dt)
                    local targetPos = UDim2.new(0, AnchorButton.AbsolutePosition.X + AnchorButton.AbsoluteSize.X + 10, 0, AnchorButton.AbsolutePosition.Y - (Flyout.AbsoluteSize.Y/2) + 10)
                    Flyout.Position = Flyout.Position:Lerp(targetPos, math.clamp(dt * 15, 0, 1))
                end)
            else
                Tween(Flyout, {GroupTransparency = 1}, 0.2)
                Tween(Flyout, {Size = UDim2.new(0, 180, 0, 0)}, 0.3)
                Tween(AnchorButton, {Rotation = 0, ImageColor3 = Keyser.Colors.TextDark}, 0.3)
                task.delay(0.3, function() if not isOpen then Flyout.Visible = false end end)
                if updater then updater:Disconnect(); updater = nil end
            end
        end
        
        AnchorButton.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)
        
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mx, my = input.Position.X, input.Position.Y
                local fx, fy = Flyout.AbsolutePosition.X, Flyout.AbsolutePosition.Y
                local bx, by = AnchorButton.AbsolutePosition.X, AnchorButton.AbsolutePosition.Y
                
                local inFlyout = mx >= fx and mx <= fx + Flyout.AbsoluteSize.X and my >= fy and my <= fy + Flyout.AbsoluteSize.Y
                local inButton = mx >= bx and mx <= bx + AnchorButton.AbsoluteSize.X and my >= by and my <= by + AnchorButton.AbsoluteSize.Y
                
                if isOpen and not inFlyout and not inButton then ToggleFlyout(false) end
            end
        end)
        return Scroll
    end

    -- Element Builder Factory
    local function BuildElements(TargetParent)
        local Elements = {}
        
        function Elements:Keybind(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local BindBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Keyser.Colors.Element, Position = UDim2.new(1, -70, 0.5, -11), Size = UDim2.new(0, 70, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
            local BindStroke = Create("UIStroke", {Parent = BindBtn, Color = Keyser.Colors.Stroke, Thickness = 1})
            local BindText = Create("TextLabel", {Parent = BindBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = Cfg.Default and Cfg.Default.Name or "None", TextColor3 = Keyser.Colors.Text, TextSize = 11})
            
            BindBtn.MouseEnter:Connect(function() Tween(BindStroke, {Color = Keyser.Colors.TextDark}) Tween(BindBtn, {BackgroundColor3 = Keyser.Colors.Hover}) end)
            BindBtn.MouseLeave:Connect(function() Tween(BindStroke, {Color = Keyser.Colors.Stroke}) Tween(BindBtn, {BackgroundColor3 = Keyser.Colors.Element}) end)
            
            local currentKey = Cfg.Default
            local binding = false
            
            BindBtn.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true; BindText.Text = "..."
                Tween(BindBtn, {BackgroundColor3 = Keyser.Colors.Accent})
                Tween(BindText, {TextColor3 = Keyser.Colors.Main})
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            currentKey = nil; BindText.Text = "None"
                        else
                            currentKey = input.KeyCode; BindText.Text = input.KeyCode.Name
                        end
                        binding = false; 
                        Tween(BindBtn, {BackgroundColor3 = Keyser.Colors.Element})
                        Tween(BindText, {TextColor3 = Keyser.Colors.Text})
                        if Cfg.Callback then task.spawn(Cfg.Callback, currentKey) end
                        connection:Disconnect()
                    end
                end)
            end)
        end
        
        function Elements:Toggle(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local CheckBg = Create("TextButton", {Parent = Frame, BackgroundColor3 = Keyser.Colors.Element, Position = UDim2.new(1, -22, 0.5, -11), Size = UDim2.new(0, 22, 0, 22), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = CheckBg, CornerRadius = UDim.new(0, 4)})
            local CheckStroke = Create("UIStroke", {Parent = CheckBg, Color = Keyser.Colors.Stroke, Thickness = 1})
            local CheckIcon = Create("ImageLabel", {Parent = CheckBg, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -12, 1, -12), Image = GetIcon("check"), ImageColor3 = Keyser.Colors.Main, ImageTransparency = 1})
            
            local Toggled = Cfg.Default or false
            
            CheckBg.MouseEnter:Connect(function() Tween(CheckStroke, {Color = Keyser.Colors.TextDark}) end)
            CheckBg.MouseLeave:Connect(function() if not Toggled then Tween(CheckStroke, {Color = Keyser.Colors.Stroke}) else Tween(CheckStroke, {Color = Keyser.Colors.Accent}) end end)

            local rightOffset = 30
            local OptionBtn
            if Cfg.Option then
                OptionBtn = Create("ImageButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -(rightOffset + 16), 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = GetIcon("settings"), ImageColor3 = Keyser.Colors.TextDark, ImageTransparency = 0.5})
                OptionBtn.MouseEnter:Connect(function() Tween(OptionBtn, {ImageTransparency = 0}) end)
                OptionBtn.MouseLeave:Connect(function() Tween(OptionBtn, {ImageTransparency = 0.5}) end)
                rightOffset = rightOffset + 22
            end

            local boundKey = Cfg.Keybind
            if boundKey ~= nil then
                local BindBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Keyser.Colors.Main, Position = UDim2.new(1, -(rightOffset + 40), 0.5, -10), Size = UDim2.new(0, 40, 0, 20), Text = "", AutoButtonColor = false})
                Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
                local BindStroke = Create("UIStroke", {Parent = BindBtn, Color = Keyser.Colors.Stroke, Thickness = 1})
                local BindText = Create("TextLabel", {Parent = BindBtn, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = typeof(boundKey)=="EnumItem" and boundKey.Name or "None", TextColor3 = Keyser.Colors.TextDark, TextSize = 10})
                
                BindBtn.MouseEnter:Connect(function() Tween(BindStroke, {Color = Keyser.Colors.TextDark}) end)
                BindBtn.MouseLeave:Connect(function() Tween(BindStroke, {Color = Keyser.Colors.Stroke}) end)

                local binding = false
                BindBtn.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true; BindText.Text = "..."
                    Tween(BindBtn, {BackgroundColor3 = Keyser.Colors.Accent})
                    Tween(BindText, {TextColor3 = Keyser.Colors.Main})
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then boundKey = nil; BindText.Text = "None"
                            else boundKey = input.KeyCode; BindText.Text = boundKey.Name end
                            binding = false
                            Tween(BindBtn, {BackgroundColor3 = Keyser.Colors.Main})
                            Tween(BindText, {TextColor3 = Keyser.Colors.TextDark})
                            conn:Disconnect()
                        end
                    end)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == boundKey and boundKey ~= nil then
                        CheckBg.BackgroundColor3 = Keyser.Colors.Hover
                        task.delay(0.1, function()
                            Toggled = not Toggled
                            if Toggled then 
                                Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Accent})
                                Tween(CheckStroke, {Color = Keyser.Colors.Accent})
                                Tween(CheckIcon, {ImageTransparency = 0, Size = UDim2.new(1, -6, 1, -6)}) 
                            else 
                                Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Element})
                                Tween(CheckStroke, {Color = Keyser.Colors.Stroke})
                                Tween(CheckIcon, {ImageTransparency = 1, Size = UDim2.new(1, -12, 1, -12)}) 
                            end
                            if Cfg.Callback then task.spawn(Cfg.Callback, Toggled) end 
                        end)
                    end
                end)
            end

            local function Update()
                if Toggled then 
                    Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Accent})
                    Tween(CheckStroke, {Color = Keyser.Colors.Accent})
                    Tween(CheckIcon, {ImageTransparency = 0, Size = UDim2.new(1, -6, 1, -6)}) 
                else 
                    Tween(CheckBg, {BackgroundColor3 = Keyser.Colors.Element})
                    Tween(CheckStroke, {Color = Keyser.Colors.Stroke})
                    Tween(CheckIcon, {ImageTransparency = 1, Size = UDim2.new(1, -12, 1, -12)}) 
                end
                if Cfg.Callback then task.spawn(Cfg.Callback, Toggled) end 
            end
            
            CheckBg.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end); Update()
            
            local ReturnAPI = {}
            if Cfg.Option then ReturnAPI.Option = BuildElements(CreateOptionFlyout(OptionBtn)) end
            return ReturnAPI
        end

        function Elements:Slider(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local ValBox = Create("Frame", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -40, 0, 0), Size = UDim2.new(0, 40, 0, 20)})
            local ValLabel = Create("TextLabel", {Parent = ValBox, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Keyser.FontBold, Text = "0.00", TextColor3 = Keyser.Colors.TextDark, TextSize = 11})
            
            local Rail = Create("Frame", {Parent = Frame, BackgroundColor3 = Keyser.Colors.Element, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 4)}); Create("UICorner", {Parent = Rail, CornerRadius = UDim.new(1, 0)})
            local Fill = Create("Frame", {Parent = Rail, BackgroundColor3 = Keyser.Colors.TextDark, Size = UDim2.new(0, 0, 1, 0)}); Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            local Knob = Create("Frame", {Parent = Fill, BackgroundColor3 = Keyser.Colors.TextDark, Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0)}); Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
            
            local Trigger = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,20), Size = UDim2.new(1,0,0,25), Text = ""})
            
            local OptionBtn
            if Cfg.Option then
                OptionBtn = Create("ImageButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(1, -65, 0, 2), Size = UDim2.new(0, 16, 0, 16), Image = GetIcon("settings"), ImageColor3 = Keyser.Colors.TextDark, ImageTransparency = 0.5})
                OptionBtn.MouseEnter:Connect(function() Tween(OptionBtn, {ImageTransparency = 0}) end)
                OptionBtn.MouseLeave:Connect(function() Tween(OptionBtn, {ImageTransparency = 0.5}) end)
            end

            local Dragging = false
            Trigger.MouseEnter:Connect(function() Tween(Knob, {Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Keyser.Colors.Accent}) Tween(Fill, {BackgroundColor3 = Keyser.Colors.Accent}) end)
            Trigger.MouseLeave:Connect(function() if not Dragging then Tween(Knob, {Size = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Keyser.Colors.TextDark}) Tween(Fill, {BackgroundColor3 = Keyser.Colors.TextDark}) end end)

            local Min, Max, Val = Cfg.Min or 0, Cfg.Max or 100, Cfg.Default or Min
            local function Set(v, fast) 
                Val = math.clamp(v, Min, Max); local P = (Val - Min) / (Max - Min); 
                Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, fast and 0.05 or 0.25); 
                ValLabel.Text = string.format("%."..(Cfg.Decimals or 0).."f", Val); 
                if Cfg.Callback then task.spawn(Cfg.Callback, Val) end 
            end
            
            Trigger.InputBegan:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    Dragging = true; Tween(Knob, {Size = UDim2.new(0, 16, 0, 16)}); local x = math.clamp((i.Position.X - Rail.AbsolutePosition.X)/Rail.AbsoluteSize.X,0,1); Set(Min + (Max-Min)*x, true); 
                    local changed, ended; 
                    changed = UserInputService.InputChanged:Connect(function(i2) 
                        if Dragging and i2.UserInputType == Enum.UserInputType.MouseMovement then Set(Min + (Max-Min)*math.clamp((i2.Position.X - Rail.AbsolutePosition.X)/Rail.AbsoluteSize.X,0,1), true) end 
                    end); 
                    ended = UserInputService.InputEnded:Connect(function(i3) 
                        if i3.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false; Tween(Knob, {Size = UDim2.new(0, 10, 0, 10)}); changed:Disconnect(); ended:Disconnect() end 
                    end) 
                end 
            end); Set(Val, false)

            local ReturnAPI = {}
            if Cfg.Option then ReturnAPI.Option = BuildElements(CreateOptionFlyout(OptionBtn)) end
            return ReturnAPI
        end
        
        function Elements:ColorPicker(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 1, 0), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local ColorBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Cfg.Default or Color3.new(1,1,1), Position = UDim2.new(1, -30, 0.5, -10), Size = UDim2.new(0, 30, 0, 20), Text = "", AutoButtonColor = false})
            Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(0, 4)}); 
            local ColorStroke = Create("UIStroke", {Parent = ColorBtn, Color = Keyser.Colors.Stroke})
            
            ColorBtn.MouseEnter:Connect(function() Tween(ColorStroke, {Color = Keyser.Colors.TextDark}) end)
            ColorBtn.MouseLeave:Connect(function() Tween(ColorStroke, {Color = Keyser.Colors.Stroke}) end)

            local Flyout = Create("CanvasGroup", {Name = "Flyout", Parent = Screen, BackgroundColor3 = Keyser.Colors.SectionBg, Size = UDim2.new(0, 180, 0, 0), Position = UDim2.new(0,0,0,0), ZIndex = 110, Visible = false, GroupTransparency = 1})
            Create("UICorner", {Parent = Flyout, CornerRadius = UDim.new(0, 6)}); Create("UIStroke", {Parent = Flyout, Color = Keyser.Colors.Stroke, Thickness = 1})

            local SatValMap = Create("ImageButton", {Parent = Flyout, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 140, 0, 110), BackgroundColor3 = ColorBtn.BackgroundColor3, AutoButtonColor = false}); Create("UICorner", {Parent = SatValMap, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = SatValMap, Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})})
            local VMap = Create("Frame", {Parent = SatValMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0)}); Create("UICorner", {Parent = VMap, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = VMap, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})})
            local CursorSV = Create("Frame", {Parent = SatValMap, Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(1, -2, 0, -2), BackgroundColor3 = Color3.new(1,1,1)}); Create("UICorner", {Parent = CursorSV, CornerRadius = UDim.new(1,0)})

            local HueRail = Create("ImageButton", {Parent = Flyout, Position = UDim2.new(0, 155, 0, 10), Size = UDim2.new(0, 15, 0, 110), BackgroundColor3 = Color3.new(1,1,1), AutoButtonColor = false}); Create("UICorner", {Parent = HueRail, CornerRadius = UDim.new(0, 4)})
            Create("UIGradient", {Parent = HueRail, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
            local CursorH = Create("Frame", {Parent = HueRail, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.new(0,0,0)})
            
            local HexBox = Create("TextBox", {Parent = Flyout, Position = UDim2.new(0, 10, 0, 130), Size = UDim2.new(0, 160, 0, 20), BackgroundColor3 = Keyser.Colors.ValueBox, Font = Keyser.Font, Text = "#FFFFFF", TextColor3 = Keyser.Colors.Text, TextSize = 12})
            Create("UICorner", {Parent = HexBox, CornerRadius = UDim.new(0, 4)}); Create("UIStroke", {Parent = HexBox, Color = Keyser.Colors.Stroke})

            local Hue, Sat, Val = ColorBtn.BackgroundColor3:ToHSV(); local updater, isOpen = nil, false
            local function UpdateColor()
                local newColor = Color3.fromHSV(Hue, Sat, Val); ColorBtn.BackgroundColor3 = newColor; SatValMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1); HexBox.Text = "#" .. newColor:ToHex():upper()
                if Cfg.Callback then task.spawn(Cfg.Callback, newColor) end
            end

            local function ToggleFlyout(state)
                isOpen = state; 
                if state then 
                    Flyout.Visible = true
                    Tween(Flyout, {GroupTransparency = 0, Size = UDim2.new(0, 180, 0, 160)}, 0.3)
                    updater = RunService.RenderStepped:Connect(function(dt) 
                        local tgt = UDim2.new(0, ColorBtn.AbsolutePosition.X - 150, 0, ColorBtn.AbsolutePosition.Y + 25)
                        Flyout.Position = Flyout.Position:Lerp(tgt, math.clamp(dt * 15, 0, 1)) 
                    end)
                else 
                    Tween(Flyout, {GroupTransparency = 1, Size = UDim2.new(0, 180, 0, 0)}, 0.3)
                    task.delay(0.3, function() if not isOpen then Flyout.Visible = false end end)
                    if updater then updater:Disconnect(); updater = nil end 
                end
            end
            ColorBtn.MouseButton1Click:Connect(function() ToggleFlyout(not isOpen) end)

            local function HandleDrag(btn, type)
                local dragging = false
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true; local changed, ended
                        local function upd(inp)
                            local y = math.clamp((inp.Position.Y - btn.AbsolutePosition.Y)/btn.AbsoluteSize.Y, 0, 1)
                            if type == "Hue" then Hue = 1 - y; CursorH.Position = UDim2.new(0,0,y,0) else local x = math.clamp((inp.Position.X - btn.AbsolutePosition.X)/btn.AbsoluteSize.X, 0, 1); Sat = x; Val = 1 - y; CursorSV.Position = UDim2.new(x, -2, y, -2) end
                            UpdateColor()
                        end; upd(input)
                        changed = UserInputService.InputChanged:Connect(function(inp) if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then upd(inp) end end)
                        ended = UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; changed:Disconnect(); ended:Disconnect() end end)
                    end
                end)
            end
            HandleDrag(HueRail, "Hue"); HandleDrag(SatValMap, "SV")
            
            UserInputService.InputBegan:Connect(function(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mx, my, fx, fy, bx, by = input.Position.X, input.Position.Y, Flyout.AbsolutePosition.X, Flyout.AbsolutePosition.Y, ColorBtn.AbsolutePosition.X, ColorBtn.AbsolutePosition.Y
                    if not (mx >= fx and mx <= fx + Flyout.AbsoluteSize.X and my >= fy and my <= fy + Flyout.AbsoluteSize.Y) and not (mx >= bx and mx <= bx + ColorBtn.AbsoluteSize.X and my >= by and my <= by + ColorBtn.AbsoluteSize.Y) then ToggleFlyout(false) end
                end
            end); UpdateColor()
        end

        function Elements:Input(Cfg)
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 55)})
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Keyser.FontBold, Text = Cfg.Name, TextColor3 = Keyser.Colors.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local InputContainer = Create("Frame", {Parent = Frame, BackgroundColor3 = Keyser.Colors.ValueBox, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30)}); 
            Create("UICorner", {Parent = InputContainer, CornerRadius = UDim.new(0, 4)}); 
            local InputStroke = Create("UIStroke", {Parent = InputContainer, Color = Keyser.Colors.Stroke, Thickness = 1})
            
            local Box = Create("TextBox", {Parent = InputContainer, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), Font = Keyser.Font, Text = "", PlaceholderText = Cfg.Placeholder or "Search...", TextColor3 = Keyser.Colors.Text, PlaceholderColor3 = Keyser.Colors.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            
            Box.Focused:Connect(function() Tween(InputStroke, {Color = Keyser.Colors.Accent}) end)
            Box.FocusLost:Connect(function() Tween(InputStroke, {Color = Keyser.Colors.Stroke}) end)
            InputContainer.MouseEnter:Connect(function() if not Box:IsFocused() then Tween(InputStroke, {Color = Keyser.Colors.TextDark}) end end)
            InputContainer.MouseLeave:Connect(function() if not Box:IsFocused() then Tween(InputStroke, {Color = Keyser.Colors.Stroke}) end end)

            Box:GetPropertyChangedSignal("Text"):Connect(function() if Cfg.Callback then task.spawn(Cfg.Callback, Box.Text) end end)
        end

        function Elements:List(Cfg)
            local ListObj = {}
            local Frame = Create("Frame", {Parent = TargetParent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Cfg.Height or 150)})
            local Scroll = Create("ScrollingFrame", {Parent = Frame, BackgroundColor3 = Keyser.Colors.ValueBox, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = Keyser.Colors.Stroke, CanvasSize = UDim2.new(0,0,0,0)}); 
            Create("UICorner", {Parent = Scroll, CornerRadius = UDim.new(0, 4)}); 
            Create("UIStroke", {Parent = Scroll, Color = Keyser.Colors.Stroke, Thickness = 1})
            local ListLayout = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder}); Create("UIPadding", {Parent = Scroll, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
            
            local Items = {}; 
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y) end)
            
            for _, v in pairs(Cfg.Items) do
                local Btn = Create("TextButton", {Parent = Scroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Font = Keyser.Font, Text = "  "..v, TextColor3 = Keyser.Colors.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                local BtnBg = Create("Frame", {Parent = Btn, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Keyser.Colors.Hover, BackgroundTransparency = 1, ZIndex = Btn.ZIndex - 1})
                Create("UICorner", {Parent = BtnBg, CornerRadius = UDim.new(0, 4)})
                
                Btn.MouseEnter:Connect(function() Tween(BtnBg, {BackgroundTransparency = 0}) end)
                Btn.MouseLeave:Connect(function() Tween(BtnBg, {BackgroundTransparency = 1}) end)

                Btn.MouseButton1Click:Connect(function() 
                    for _, b in pairs(Items) do Tween(b.Obj, {TextColor3 = Keyser.Colors.TextDark}) end
                    Tween(Btn, {TextColor3 = Keyser.Colors.Accent})
                    if Cfg.Callback then task.spawn(Cfg.Callback, v) end 
                end)
                table.insert(Items, {Obj = Btn, Val = v})
            end
            
            function ListObj:Filter(txt) 
                for _, item in pairs(Items) do item.Obj.Visible = string.find(string.lower(item.Val), string.lower(txt or "")) ~= nil end 
            end
            return ListObj
        end

        function Elements:Button(Cfg)
            local Btn = Create("TextButton", {Parent = TargetParent, BackgroundColor3 = Keyser.Colors.Element, Size = UDim2.new(1, 0, 0, 32), Font = Keyser.Font, Text = Cfg.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 12, AutoButtonColor = false}); 
            Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
            local BtnStroke = Create("UIStroke", {Parent = Btn, Color = Keyser.Colors.Stroke, Thickness = 1})
            
            Btn.MouseEnter:Connect(function() 
                Tween(Btn, {BackgroundColor3 = Keyser.Colors.Hover, TextColor3 = Keyser.Colors.Text}) 
                Tween(BtnStroke, {Color = Keyser.Colors.TextDark})
            end)
            Btn.MouseLeave:Connect(function() 
                Tween(Btn, {BackgroundColor3 = Keyser.Colors.Element, TextColor3 = Keyser.Colors.TextDark}) 
                Tween(BtnStroke, {Color = Keyser.Colors.Stroke})
            end)
            Btn.MouseButton1Down:Connect(function() Tween(Btn, {BackgroundColor3 = Keyser.Colors.Accent, TextColor3 = Keyser.Colors.Main}) end)
            Btn.MouseButton1Up:Connect(function() Tween(Btn, {BackgroundColor3 = Keyser.Colors.Hover, TextColor3 = Keyser.Colors.Text}) end)
            Btn.MouseButton1Click:Connect(function() if Cfg.Callback then task.spawn(Cfg.Callback) end end)
        end
        
        return Elements
    end

    --[ 1. TAB (SIDEBAR BUTTON) ]
    function WinData:Tab(Config)
        local TabObj = {}
        local TopButtonsFrame = Create("Frame", {Parent = NavContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
        Create("UIListLayout", {Parent = TopButtonsFrame, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 15)})

        local SideBtn = Create("TextButton", {Parent = SideContainer, BackgroundColor3 = Keyser.Colors.Element, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Text = "", AutoButtonColor = false})
        Create("UICorner", {Parent = SideBtn, CornerRadius = UDim.new(0, 4)})

        local Icon = Create("ImageLabel", {Parent = SideBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), Image = GetIcon(Config.Icon), ImageColor3 = Keyser.Colors.TextDark})
        local Label = Create("TextLabel", {Parent = SideBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -40, 1, 0), Font = Keyser.FontBold, Text = Config.Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        
        TabObj.TopTabs = {}; TabObj.ActiveTop = nil

        local function ActivateSidebar()
            if WinData.ActiveSidebar == TabObj then return end
            if WinData.ActiveSidebar then
                Tween(WinData.ActiveSidebar.Btn, {BackgroundTransparency = 1, BackgroundColor3 = Keyser.Colors.Element})
                Tween(WinData.ActiveSidebar.Label, {TextColor3 = Keyser.Colors.TextDark})
                Tween(WinData.ActiveSidebar.Icon, {ImageColor3 = Keyser.Colors.TextDark})
                WinData.ActiveSidebar.TopButtonsFrame.Visible = false
                if WinData.ActiveSidebar.ActiveTop then WinData.ActiveSidebar.ActiveTop.Page.Visible = false end
            end
            WinData.ActiveSidebar = TabObj
            Tween(SideBtn, {BackgroundTransparency = 0, BackgroundColor3 = Keyser.Colors.Hover}) 
            Tween(Label, {TextColor3 = Keyser.Colors.Text})
            Tween(Icon, {ImageColor3 = Keyser.Colors.Text})
            TopButtonsFrame.Visible = true
            if TabObj.ActiveTop then TabObj.ActiveTop:Activate() elseif #TabObj.TopTabs > 0 then TabObj.TopTabs[1]:Activate() end
        end

        SideBtn.MouseEnter:Connect(function()
            if WinData.ActiveSidebar ~= TabObj then
                Tween(SideBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = Keyser.Colors.Hover})
                Tween(Label, {TextColor3 = Keyser.Colors.Text})
                Tween(Icon, {ImageColor3 = Keyser.Colors.Text})
            end
        end)
        SideBtn.MouseLeave:Connect(function()
            if WinData.ActiveSidebar ~= TabObj then
                Tween(SideBtn, {BackgroundTransparency = 1, BackgroundColor3 = Keyser.Colors.Element})
                Tween(Label, {TextColor3 = Keyser.Colors.TextDark})
                Tween(Icon, {ImageColor3 = Keyser.Colors.TextDark})
            end
        end)

        SideBtn.MouseButton1Click:Connect(ActivateSidebar)
        TabObj.Activate = ActivateSidebar; TabObj.Btn = SideBtn; TabObj.Label = Label; TabObj.Icon = Icon; TabObj.TopButtonsFrame = TopButtonsFrame

        --[ 2. PAGE (TOPBAR BUTTON) ]
        function TabObj:Page(Name)
            local PageObj = {}
            local TopBtn = Create("TextButton", {Parent = TopButtonsFrame, BackgroundColor3 = Keyser.Colors.Element, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, -20), Font = Keyser.FontBold, Text = Name, TextColor3 = Keyser.Colors.TextDark, TextSize = 13, AutomaticSize = Enum.AutomaticSize.X})
            Create("UICorner", {Parent = TopBtn, CornerRadius = UDim.new(0, 4)}); Create("UIPadding", {Parent = TopBtn, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)})

            local PageFrame = Create("Frame", {Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
            Create("UIPadding", {Parent = PageFrame, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})

            local LeftCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.485, 0, 1, 0)})
            local RightCol = Create("Frame", {Parent = PageFrame, BackgroundTransparency = 1, Size = UDim2.new(0.485, 0, 1, 0), Position = UDim2.new(0.515, 0, 0, 0)})
            Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})
            Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})

            TopBtn.MouseEnter:Connect(function() if TabObj.ActiveTop ~= PageObj then Tween(TopBtn, {BackgroundTransparency = 0.5, TextColor3 = Keyser.Colors.Text}) end end)
            TopBtn.MouseLeave:Connect(function() if TabObj.ActiveTop ~= PageObj then Tween(TopBtn, {BackgroundTransparency = 1, TextColor3 = Keyser.Colors.TextDark}) end end)

            function PageObj:Activate()
                if TabObj.ActiveTop and TabObj.ActiveTop ~= PageObj then
                    Tween(TabObj.ActiveTop.Btn, {BackgroundTransparency = 1, TextColor3 = Keyser.Colors.TextDark})
                    TabObj.ActiveTop.Page.Visible = false
                end
                TabObj.ActiveTop = PageObj
                Tween(TopBtn, {BackgroundTransparency = 0, TextColor3 = Keyser.Colors.Text})
                
                PageFrame.Visible = true
                PageFrame.Position = UDim2.new(0, 20, 0, 0)
                Tween(PageFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
            end

            TopBtn.MouseButton1Click:Connect(function() PageObj:Activate() end)
            PageObj.Btn = TopBtn; PageObj.Page = PageFrame
            table.insert(TabObj.TopTabs, PageObj)

            --[ 3. SECTION (GROUPBOX) - FIVEM STYLE ]
            local SectionLib = {}
            function SectionLib:Section(SecConfig)
                local Col = (SecConfig.Side == "Right" and RightCol) or LeftCol
                local fixHeight = SecConfig.Height
                
                local Groupbox = Create("Frame", {Parent = Col, BackgroundColor3 = Keyser.Colors.SectionBg, Size = UDim2.new(1, 0, 0, fixHeight or 0), AutomaticSize = fixHeight and Enum.AutomaticSize.None or Enum.AutomaticSize.Y})
                Create("UICorner", {Parent = Groupbox, CornerRadius = UDim.new(0, 6)})
                Create("UIStroke", {Parent = Groupbox, Color = Keyser.Colors.Stroke, Thickness = 1})

                local HeaderFrame = Create("Frame", {Parent = Groupbox, BackgroundColor3 = Keyser.Colors.SectionHeader, Size = UDim2.new(1, 0, 0, 38), BorderSizePixel = 0})
                Create("UICorner", {Parent = HeaderFrame, CornerRadius = UDim.new(0, 6)})
                Create("Frame", {Parent = HeaderFrame, BackgroundColor3 = Keyser.Colors.SectionHeader, Position = UDim2.new(0,0,1,-6), Size = UDim2.new(1,0,0,6), BorderSizePixel = 0}) 

                Create("TextLabel", {Parent = HeaderFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -15, 1, 0), Font = Keyser.FontBold, Text = SecConfig.Name, TextColor3 = Keyser.Colors.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                
                local ContentFrame
                if fixHeight then
                    ContentFrame = Create("ScrollingFrame", {Parent = Groupbox, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 1, -38), ScrollBarThickness = 2, ScrollBarImageColor3 = Keyser.Colors.Stroke, CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel = 0})
                else
                    ContentFrame = Create("Frame", {Parent = Groupbox, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
                end
                
                local CList = Create("UIListLayout", {Parent = ContentFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
                Create("UIPadding", {Parent = ContentFrame, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10)})
                
                if fixHeight then CList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() ContentFrame.CanvasSize = UDim2.new(0, 0, 0, CList.AbsoluteContentSize.Y + 20) end) end
                
                return BuildElements(ContentFrame)
            end
            return SectionLib
        end
        
        table.insert(AllSidebarTabs, TabObj)
        return TabObj
    end
    
    task.defer(function() if not WinData.ActiveSidebar and #AllSidebarTabs > 0 then AllSidebarTabs[1]:Activate() end end)
    return WinData
end

return Library
