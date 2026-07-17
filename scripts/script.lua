--credits(all this name is on discord names)
-- king_free(owner)
-- holo(deloveper
--peetist(designer & deloveper)
--utost(partner)
--dogee_happy(head of promotion)


local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Market = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

repeat task.wait() until LP and LP.Parent

local lastItem = { Id = nil, Type = nil }
local currentBypassToken = 0
local isSequenceActive = false

-- ========== IMAGEN DEL LOGO ==========
local LOGO_ICONO = "82292028547805"

-- ========== MÉTODO UNIFICADO (43 técnicas de bypass) ==========
local function fireAllMethods(id, t)
    task.spawn(function()
        if t == "GamePass" then
            pcall(function() Market:SignalPromptGamePassPurchaseFinished(LP.UserId, id, true) end)
            pcall(function() firesignal(Market.PromptGamePassPurchaseFinished, LP, id, true) end)
        elseif t == "Product" then
            pcall(function() Market:SignalPromptProductPurchaseFinished(LP.UserId, id, true) end)
            pcall(function() firesignal(Market.PromptProductPurchaseFinished, LP.UserId, id, true) end)
        elseif t == "Asset" then
            pcall(function() Market:SignalPromptPurchaseFinished(LP.UserId, id, true) end)
            pcall(function() firesignal(Market.PromptPurchaseFinished, LP, id, true) end)
        elseif t == "Bundle" then
            pcall(function() Market:SignalPromptBundlePurchaseFinished(LP.UserId, id, true) end)
            pcall(function() firesignal(Market.PromptBundlePurchaseFinished, LP.UserId, id, true) end)
        elseif t == "Premium" then
            pcall(function() Market:SignalPromptPremiumPurchaseFinished(true) end)
            pcall(function() firesignal(Market.PromptPremiumPurchaseFinished, true) end)
        end

        if t == "GamePass" then pcall(function() firesignal(Market.PromptGamePassPurchaseFinished, id, true) end)
        elseif t == "Product" then pcall(function() firesignal(Market.PromptProductPurchaseFinished, id, true) end)
        elseif t == "Asset" then pcall(function() firesignal(Market.PromptPurchaseFinished, id, true) end)
        elseif t == "Bundle" then pcall(function() firesignal(Market.PromptBundlePurchaseFinished, id, true) end)
        end

        local ownerId = 0
        pcall(function()
            local info = Market:GetProductInfo(game.PlaceId)
            if info and info.Creator then
                if info.Creator.CreatorType == "User" then ownerId = info.Creator.CreatorTargetId
                elseif info.Creator.CreatorType == "Group" then
                    ownerId = game:GetService("GroupService"):GetGroupInfoAsync(info.Creator.CreatorTargetId).Owner.Id
                end
            end
        end)
        if ownerId > 0 then
            if t == "GamePass" then pcall(function() Market:SignalPromptGamePassPurchaseFinished(ownerId, id, true) end)
            elseif t == "Product" then pcall(function() Market:SignalPromptProductPurchaseFinished(ownerId, id, true) end)
            elseif t == "Asset" then pcall(function() Market:SignalPromptPurchaseFinished(ownerId, id, true) end)
            elseif t == "Bundle" then pcall(function() Market:SignalPromptBundlePurchaseFinished(ownerId, id, true) end)
            end
        end

        pcall(function()
            LP:SetAttribute("Gamepass_"..id, true)
            LP:SetAttribute("Owns"..id, true)
            LP:SetAttribute("HasPass", true)
        end)

        local ac = game:GetService("ServerScriptService"):FindFirstChild("GamepassAntiCheat")
        if ac and ac:IsA("ModuleScript") then
            local env = getsenv(ac)
            if env then
                pcall(function()
                    env.Init = function() end
                    env.VerifyGamepass = function() return true end
                    env.HighValueVerification = function() return true end
                    env.HandleSuspiciousPlayer = function() end
                    env.CheckRateLimit = function() return true end
                    env.ActionCooldown = function() return true end
                    env.SanitizeArgs = function() return true end
                    env.CheckBlacklistedArgs = function() return true end
                    env.CheckDataSize = function() return true end
                    env.VerifyPromptToken = function() return true end
                    env.ValidateReceipt = function() return true end
                    env.HasPurchaseRecord = function() return true end
                    env.IsReceiptProcessed = function() return false end
                    env.DetectUnauthorizedChange = function() return false end
                end)
            end
        end
    end)

    local allDescendants = game:GetDescendants()
    local words = {"buy","purchase","comprar","grant","give","gamepass","product","bundle","vip","item","reward"}
    local actions = {"ActivateBenefit", "RequestToken", "VerifyGamepass", "GiveAccess"}
    local cmds = {"give", "grant", "add", "unlock"}
    local combos = { {id}, {t, id}, {id, t}, {LP, id}, {id, LP}, {LP.UserId, id}, {id, true}, {id, false}, {id, t, LP}, {id, LP, t} }
    local payloads = { {gamepassId = id}, {productId = id}, {id = id, type = t}, {id, t}, {id} }
    local allArgs = {
        {id, t, LP}, {id, LP, t}, {LP, id, t}, {t, id}, {id, true}, {id, "PurchaseGranted"},
        {id, "Owned", true}, {"Grant", id, LP}, {"GivePass", id, LP}, {"AddGamepass", id, LP},
        {"Unlock", id}, {"Buy", id}
    }
    local receipt = { PlayerId = LP.UserId, PurchaseId = id, ProductId = id, CurrencyType = "Robux", Price = 0, PlaceId = game.PlaceId }

    for _, obj in ipairs(allDescendants) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            for _, w in ipairs(words) do
                if nameLower:find(w) then
                    pcall(function() obj:FireServer(id, t) end)
                    pcall(function() obj:FireServer(id, t, LP) end)
                    pcall(function() obj:FireServer(id) end)
                    break
                end
            end
            for _, args in ipairs(combos) do pcall(function() obj:FireServer(unpack(args)) end) end
            if nameLower:find("activate") or nameLower:find("benefit") then
                pcall(function() obj:FireServer("ActivateBenefit", id) end)
            end
            if nameLower:find("gamepass") then
                for i=1,5 do
                    task.spawn(function()
                        local nonce = HttpService:GenerateGUID(false)
                        pcall(function() obj:FireServer("ActivateBenefit", id, nonce) end)
                    end)
                end
            end
            for _, action in ipairs(actions) do pcall(function() obj:FireServer(action, id) end) end
            for _, payload in ipairs(payloads) do pcall(function() obj:FireServer(payload) end) end
            local encoded = HttpService:JSONEncode({id = id, type = t})
            pcall(function() obj:FireServer(encoded) end)
            if nameLower:find("admin") then pcall(function() obj:FireServer("grant", id, "admin") end) end
            if nameLower:find("message") then pcall(function() obj:FireServer("BenefitActivated", id) end) end
            if nameLower:find("process") then pcall(function() obj:FireServer(receipt) end) end
            pcall(function() obj:FireServer(game.CreatorId, id) end)
            for _, cmd in ipairs(cmds) do pcall(function() obj:FireServer(cmd, id) end) end
            for _, args in ipairs(allArgs) do pcall(function() obj:FireServer(unpack(args)) end) end

        elseif obj:IsA("RemoteFunction") then
            local nameLower = obj.Name:lower()
            for _, w in ipairs(words) do
                if nameLower:find(w) then
                    pcall(function() obj:InvokeServer(id, t) end)
                    pcall(function() obj:InvokeServer(id, t, LP) end)
                    pcall(function() obj:InvokeServer(id) end)
                    break
                end
            end
            for _, args in ipairs(combos) do pcall(function() obj:InvokeServer(unpack(args)) end) end
            if nameLower:find("activate") or nameLower:find("benefit") then
                pcall(function() obj:InvokeServer("ActivateBenefit", id) end)
            end
            for _, action in ipairs(actions) do pcall(function() obj:InvokeServer(action, id) end) end
            for _, payload in ipairs(payloads) do pcall(function() obj:InvokeServer(payload) end) end
            local encoded = HttpService:JSONEncode({id = id, type = t})
            pcall(function() obj:InvokeServer(encoded) end)
            if nameLower:find("process") then pcall(function() obj:InvokeServer(receipt) end) end
            for _, cmd in ipairs(cmds) do pcall(function() obj:InvokeServer(cmd, id) end) end
            for _, args in ipairs(allArgs) do pcall(function() obj:InvokeServer(unpack(args)) end) end

        elseif obj:IsA("BindableEvent") then
            pcall(function() obj:Fire(id, t) end)
            pcall(function() obj:Fire(id) end)

        elseif obj:IsA("BindableFunction") then
            pcall(function() obj:Invoke(id, t) end)
            pcall(function() obj:Invoke(id) end)
            pcall(function()
                local old = obj.OnInvoke
                obj.OnInvoke = function(...)
                    local args = {...}
                    if args[1] == "PurchaseVerification" then return true end
                    return old and old(...)
                end
            end)

        elseif obj:IsA("ModuleScript") then
            local env = getsenv(obj)
            if env then
                for fn, f in pairs(env) do
                    if type(f) == "function" and (fn:lower():find("purchase") or fn:lower():find("buy")) then
                        pcall(f, id, t, LP)
                    end
                end
                local ok, mod = pcall(require, obj)
                if ok and type(mod) == "table" then
                    for k, v in pairs(mod) do
                        if type(v) == "function" and (k:lower():find("purchase") or k:lower():find("buy")) then
                            pcall(v, id, t, LP)
                        end
                    end
                end
                local overrideList = {"VerifyGamepass","HighValueVerification","HandleSuspiciousPlayer","CheckRateLimit","ActionCooldown","SanitizeArgs","CheckBlacklistedArgs","CheckDataSize","VerifyPromptToken","ValidateReceipt","HasPurchaseRecord","IsReceiptProcessed","DetectUnauthorizedChange","SignData"}
                for _, funcName in ipairs(overrideList) do
                    if env[funcName] and type(env[funcName]) == "function" then
                        if funcName == "IsReceiptProcessed" or funcName == "DetectUnauthorizedChange" then
                            pcall(function() env[funcName] = function() return false end end)
                        elseif funcName == "HandleSuspiciousPlayer" then
                            pcall(function() env[funcName] = function() end end)
                        elseif funcName == "SignData" then
                            pcall(function() env[funcName] = function(data) return HttpService:HMACSHA256(data, "ClaveSuperSecreta2025") end end)
                        else
                            pcall(function() env[funcName] = function() return true end end)
                        end
                    end
                end
                if env.ownershipCache then
                    pcall(function()
                        if not env.ownershipCache[LP.UserId] then env.ownershipCache[LP.UserId] = {} end
                        env.ownershipCache[LP.UserId][id] = {owns = true, lastCheck = os.time()}
                    end)
                end
            end

        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            local env = getsenv(obj)
            if env then
                for fnName, fn in pairs(env) do
                    if type(fn) == "function" and fnName:lower():find("purchase") then
                        pcall(fn, id, LP, true)
                        pcall(fn, id, true)
                    end
                end
            end
        end
    end

    task.spawn(function()
        local mainRemote = game:GetService("ReplicatedStorage"):FindFirstChild("AntiCheatRemotes") and game:GetService("ReplicatedStorage").AntiCheatRemotes:FindFirstChild("GamepassRequest")
        if mainRemote then
            for _, conn in pairs(getconnections(mainRemote.OnServerEvent)) do
                pcall(function() conn:Disable() end)
            end
        end
    end)
end

-- ========== GUI PRINCIPAL ==========
local gui = Instance.new("ScreenGui")
gui.Name = "KingFreeGUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- Botón flotante "K"
local kBtn = Instance.new("TextButton")
kBtn.Size = UDim2.new(0, 60, 0, 60)
kBtn.Position = UDim2.new(0.1, 0, 0.5, -30)
kBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
kBtn.Text = "K"
kBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
kBtn.Font = Enum.Font.GothamBold
kBtn.TextSize = 30
kBtn.BorderSizePixel = 0
kBtn.Parent = gui

local kCorner = Instance.new("UICorner", kBtn)
kCorner.CornerRadius = UDim.new(1, 0)
local kStroke = Instance.new("UIStroke", kBtn)
kStroke.Color = Color3.fromRGB(255, 215, 0)
kStroke.Thickness = 2

-- Variables de arrastre del botón K
local isDraggingSphere = false
local dragStartSphere = Vector2.new(0,0)
local startPosSphere = UDim2.new(0,0,0,0)
local clickTimer = 0

kBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSphere = true
        dragStartSphere = input.Position
        startPosSphere = kBtn.Position
        clickTimer = tick()
    end
end)

kBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSphere = false
        if (tick() - clickTimer) < 0.25 then
            toggleGUI()
        end
    end
end)

UIS.InputChanged:Connect(function(input)
    if isDraggingSphere and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartSphere
        kBtn.Position = UDim2.new(startPosSphere.X.Scale, startPosSphere.X.Offset + delta.X,
                                  startPosSphere.Y.Scale, startPosSphere.Y.Offset + delta.Y)
    end
end)

-- Frame principal (312x144)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 312, 0, 144)
frame.Position = UDim2.new(0.5, -156, 0.5, -72)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Visible = false
frame.Parent = gui

local strokeFrame = Instance.new("UIStroke", frame)
strokeFrame.Color = Color3.fromRGB(255, 215, 0)
strokeFrame.Thickness = 2
local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 10)

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 10)

local logoIcon = Instance.new("ImageLabel")
logoIcon.Size = UDim2.new(0, 20, 0, 20)
logoIcon.Position = UDim2.new(0, 6, 0.5, -10)
logoIcon.Image = "rbxassetid://" .. LOGO_ICONO
logoIcon.BackgroundTransparency = 1
logoIcon.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 30, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "King Free Bypass"
titleText.TextColor3 = Color3.new(1,1,1)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.Parent = titleBar

-- Arrastre del frame (solo desde la barra de título)
local draggingFrame = false
local dragStartFrame = Vector2.new(0,0)
local startPosFrame = UDim2.new(0,0,0,0)

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = true
        dragStartFrame = input.Position
        startPosFrame = frame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingFrame and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartFrame
        frame.Position = UDim2.new(startPosFrame.X.Scale, startPosFrame.X.Offset + delta.X,
                                   startPosFrame.Y.Scale, startPosFrame.Y.Offset + delta.Y)
    end
end)

-- Etiqueta de información
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 25)
infoLabel.Position = UDim2.new(0, 10, 0, 40)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Gamepass ID: waiting..."
infoLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 13
infoLabel.TextWrapped = true
infoLabel.Parent = frame

-- Botón BYPASS
local grantBtn = Instance.new("TextButton")
grantBtn.Size = UDim2.new(1, -20, 0, 32)
grantBtn.Position = UDim2.new(0, 10, 0, 75)
grantBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
grantBtn.Text = "BYPASS"
grantBtn.TextColor3 = Color3.new(1,1,1)
grantBtn.Font = Enum.Font.GothamBold
grantBtn.TextSize = 14
grantBtn.Parent = frame
local grantCorner = Instance.new("UICorner", grantBtn)
grantCorner.CornerRadius = UDim.new(0, 6)

-- Lógica del botón BYPASS
grantBtn.Activated:Connect(function()
    if isSequenceActive then return end

    local item = lastItem
    if not item.Id and item.Type ~= "Premium" then return end

    isSequenceActive = true
    currentBypassToken = currentBypassToken + 1
    local myToken = currentBypassToken

    infoLabel.Text = "Bypassing..."
    infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)

    local bypassId = item.Id
    local bypassType = item.Type

    task.spawn(function()
        -- Esperar 3 segundos
        task.wait(3)
        if currentBypassToken ~= myToken then
            isSequenceActive = false
            return
        end

        -- Ejecutar los 43 métodos
        fireAllMethods(bypassId, bypassType)

        -- Mostrar Bypassed! en verde
        infoLabel.Text = "Gamepass ID: ".. (bypassId or "Premium") .. " | Bypassed!"
        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 100)

        -- Mantener el mensaje 3 segundos
        task.wait(3)
        if currentBypassToken ~= myToken then
            isSequenceActive = false
            return
        end

        -- Volver a estado de espera
        infoLabel.Text = "Gamepass ID: waiting..."
        infoLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
        isSequenceActive = false
    end)
end)

-- Toggle de visibilidad de la ventana
local guiVisible = false

function toggleGUI()
    guiVisible = not guiVisible
    if guiVisible then
        frame.Visible = true
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 312, 0, 144), Position = UDim2.new(0.5, -156, 0.5, -72)}):Play()
    else
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        task.wait(0.2)
        frame.Visible = false
        frame.Size = UDim2.new(0, 312, 0, 144)
        frame.Position = UDim2.new(0.5, -156, 0.5, -72)
    end
end

-- ========== LISTENERS DE MARKETPLACE ==========
Market.PromptGamePassPurchaseRequested:Connect(function(p, id)
    if p == LP then
        lastItem = {Id = id, Type = "GamePass"}
        currentBypassToken = currentBypassToken + 1
        isSequenceActive = false
        infoLabel.Text = "Gamepass ID: "..id
        infoLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
    end
end)

Market.PromptProductPurchaseRequested:Connect(function(p, id)
    if p == LP then
        lastItem = {Id = id, Type = "Product"}
        currentBypassToken = currentBypassToken + 1
        isSequenceActive = false
        infoLabel.Text = "Gamepass ID: "..id
        infoLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
    end
end)

Market.PromptPurchaseRequested:Connect(function(p, id)
    if p == LP then
        lastItem = {Id = id, Type = "Asset"}
        currentBypassToken = currentBypassToken + 1
        isSequenceActive = false
        infoLabel.Text = "Gamepass ID: "..id
        infoLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
    end
end)

Market.PromptBundlePurchaseRequested:Connect(function(p, id)
    if p == LP then
        lastItem = {Id = id, Type = "Bundle"}
        currentBypassToken = currentBypassToken + 1
        isSequenceActive = false
        infoLabel.Text = "Gamepass ID: "..id
        infoLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
    end
end)

Market.PromptPremiumPurchaseRequested:Connect(function(p)
    if p == LP then
        lastItem = {Id = 0, Type = "Premium"}
        currentBypassToken = currentBypassToken + 1
        isSequenceActive = false
        infoLabel.Text = "Gamepass ID: Premium"
        infoLabel.TextColor3 = Color3.new(0.9,0.9,0.9)
    end
end)
