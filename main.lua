-- kayeshiHUB v2.1 - Dark Pink Premium Edition
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local DISCORD = "https://discord.gg/tfXf5W6WCw"
local WHATSAPP = "https://whatsapp.com/channel/0029Vb9IS0P5K3zLIVZzsv3W"
local CONFIG_FILE = "kayeshiHUB_config.json"
local FAR = 1e6
local PANEL_W, PANEL_H = 640, 440

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "kayeshiHUB", Text = string.sub(tostring(text), 1, 200), Duration = 4})
    end)
end

notify("kayeshiHUB v2.1 memuat...")

-- ===== THEME DARK PINK =====
local C = {
    Panel = Color3.fromRGB(10, 10, 12),
    Side = Color3.fromRGB(18, 18, 22),
    Card = Color3.fromRGB(28, 28, 34),
    Row = Color3.fromRGB(38, 38, 46),
    Dark = Color3.fromRGB(50, 50, 60),
    Light = Color3.fromRGB(245, 245, 250),
    Accent = Color3.fromRGB(255, 105, 180),
    AccentDark = Color3.fromRGB(200, 80, 140),
    HotPink = Color3.fromRGB(255, 20, 147),
    PinkBorder = Color3.fromRGB(255, 150, 200),
    Text = Color3.fromRGB(255, 255, 255),
    Ink = Color3.fromRGB(20, 20, 25),
    Muted = Color3.fromRGB(150, 150, 160),
    Success = Color3.fromRGB(120, 200, 120),
    Warning = Color3.fromRGB(255, 180, 80),
}

-- ===== DATABASE EGG =====
local EGG_LIST = {
    -- Index 1
    {"Common Egg", "1"},
    {"Coral Egg", "20"},
    {"Reef Egg", "400"},
    {"Tidal Egg", "8K"},
    {"Deep Egg", "160K"},
    {"Abyss Egg", "3M"},
    {"Trench Egg", "60M"},
    {"Sovereign Egg", "1B"},
    {"Celestial Egg", "20B"},
    -- Index 2
    {"Eternal Egg", "70B"},
    {"Coral Reef Egg", "90B"},
    {"Glacial Spiral Egg", "115B"},
    {"Amethyst Spiral Egg", "140B"},
    {"Azure Crown Egg", "170B"},
    {"Solar Orbit Egg", "200B"},
    {"Spikey Egg", "Unknown"},
    {"Mamba Egg", "Unknown"},
    {"Inferno Egg", "Unknown"},
    -- Index 3
    {"Prism Egg", "15T"},
    {"Astral Vortex", "5T"},
    {"Damumu Egg", "3.5T-6T"},
    {"Eclipse Egg", "35T"},
    {"Admin Abuse Seraph Egg", "80B-2T"},
    {"Kraken Glory Egg", "140B-980B"},
    {"KingKalolo Egg", "Unknown"},
    {"Golem Egg", "Unknown"},
}

-- Alias database untuk deteksi yang lebih akurat
local EGG_ALIASES = {
    ["common"] = "common egg",
    ["coral"] = "coral egg",
    ["reef"] = "reef egg",
    ["tidal"] = "tidal egg",
    ["deep"] = "deep egg",
    ["abyss"] = "abyss egg",
    ["trench"] = "trench egg",
    ["sovereign"] = "sovereign egg",
    ["celestial"] = "celestial egg",
    ["eternal"] = "eternal egg",
    ["coral reef"] = "coral reef egg",
    ["glacial spiral"] = "glacial spiral egg",
    ["amethyst spiral"] = "amethyst spiral egg",
    ["azure crown"] = "azure crown egg",
    ["solar orbit"] = "solar orbit egg",
    ["spikey"] = "spikey egg",
    ["mamba"] = "mamba egg",
    ["inferno"] = "inferno egg",
    ["prism"] = "prism egg",
    ["astral vortex"] = "astral vortex",
    ["damumu"] = "damumu egg",
    ["eclipse"] = "eclipse egg",
    ["admin abuse seraph"] = "admin abuse seraph egg",
    ["kraken glory"] = "kraken glory egg",
    ["kingkalolo"] = "kingkalolo egg",
    ["king kolo"] = "kingkalolo egg",
    ["golem"] = "golem egg",
}

local EGG, EGG_KEYS = {}, {}
for i, e in ipairs(EGG_LIST) do
    local key = string.lower(e[1])
    EGG[key] = {name = e[1], luck = e[2], rank = i, key = key}
    table.insert(EGG_KEYS, key)
end

-- Tambahkan alias ke database
for alias, real in pairs(EGG_ALIASES) do
    if not EGG[alias] and EGG[real] then
        EGG[alias] = EGG[real]
        table.insert(EGG_KEYS, alias)
    end
end

table.sort(EGG_KEYS, function(a, b)
    return #a > #b
end)

local MIN_STEPS = {
    {"Semua", 0},
    {"Sovereign+", EGG["sovereign egg"].rank},
    {"Celestial+", EGG["celestial egg"].rank},
    {"Kraken+", EGG["kraken glory egg"].rank},
    {"Golem+", EGG["golem egg"].rank},
}

-- ===== KONSTANTA DETEKSI =====
local BAD_NAME = {"hatch", "place", "plant", "incubat", "inventor", "shop", "machine", "npc", "sell", "buy", "tukar"}
local BAD_ANCESTOR = {"hatch", "place", "plant", "incubat", "machine", "shop", "npc", "display", "showcase", "inventory", "mudagen", "mudargen", "reward"}
local BAD_PROMPT = {"inventory", "place", "plant", "incubat", "hatch", "shop", "buy", "sell", "tukar"}
local BAD_CHAIN = {"generator", "shop", "npc", "citadel", "merchant", "tukar", "swap", "event", "halloween", "pumpkins"}
local MACHINE_WORDS = {"place", "plant", "incubat", "hatch", "inventory"}
local LOW_OFF = {
    ParticleEmitter = true, Trail = true, Beam = true, Smoke = true, Fire = true, Sparkles = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, Clouds = true,
}

-- ===== CONFIG =====
local CFG = {
    AutoSteal = true, RarityFirst = false, MinRank = 0, StealWait = 1.2, IgnoreTime = 6,
    MachineClear = 25, ReturnRadius = 6, SafeTrail = true, SafeSide = 4,
    AutoInv = true, InvCd = 1.5, InvTries = 3,
    AutoPlace = false, PlaceReturn = true, MachineCd = 2,
    AutoHatch = false, HatchCd = 3,
    EggESP = false, XRay = false,
    LowGraphics = false, Walk = false, WalkSpeed = 16, Jump = false, JumpPower = 50,
    AntiAFK = true, AfkIdle = 300, AutoSave = true,
    DetectionRadius = 500, ESPRadius = 500,
}
local DEFAULT = {}
for k, v in pairs(CFG) do
    DEFAULT[k] = v
end

-- ===== STATE =====
local idx = {egg = {}, prompt = {}, trail = {}}
local eggSel, espSel = {}, {}
local visuals, ignored, cooldown, waterCache = {}, {}, {}, {}
local machCache, machAt = {}, 0
local S = {status = "Memuat...", steal = 0, inv = 0, place = 0, hatch = 0, errors = 0, config = "-", held = "-", low = 0, lowErr = 0, detectedEggs = 0}
local zone
local busy = false
local paints, uiRefs = {}, {}
local layout = {main = Vector2.new(0, 0), logo = Vector2.new(0, 0), ready = false}
local orderSeq = 0
local lastActive = os.clock()
local baseWalk, baseJump = 16, 50
local nextInv, nextPlace, nextHatch = 0, 0, 0
local invFails = 0
local lastJson
local minIdx = 1
local eggSearchQuery = ""
local welcomeShown = false

-- ===== UTILITY FUNCTIONS =====
local function refresh()
    for _, f in ipairs(paints) do
        pcall(f)
    end
end

local function nextOrder()
    orderSeq += 1
    return orderSeq
end

local function getRoot()
    local ch = player.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function humanoid()
    local ch = player.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function tpTo(pos)
    local ch = player.Character
    local r = ch and ch:FindFirstChild("HumanoidRootPart")
    if r then
        r.AssemblyLinearVelocity = Vector3.zero
        ch:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
    end
end

local function streamAround(pos)
    if pos then
        pcall(function()
            player:RequestStreamAroundAsync(pos, 1024)
        end)
    end
end

local function hasAny(text, words)
    for _, w in ipairs(words) do
        if string.find(text, w, 1, true) then
            return true
        end
    end
    return false
end

local function chainOf(inst)
    local names, node = {}, inst
    while node and node ~= workspace do
        table.insert(names, string.lower(node.Name))
        node = node.Parent
    end
    return table.concat(names, " / ")
end

-- ===== IMPROVED EGG DETECTION =====
local function eggOf(text)
    if not text then return nil end
    local l = string.lower(text or "")
    
    -- Direct match
    if EGG[l] then
        return EGG[l]
    end
    
    -- Alias match
    if EGG_ALIASES[l] and EGG[EGG_ALIASES[l]] then
        return EGG[EGG_ALIASES[l]]
    end
    
    -- Partial match (more aggressive)
    for _, k in ipairs(EGG_KEYS) do
        if string.find(l, k, 1, true) then
            return EGG[k]
        end
    end
    
    -- Fuzzy match: check if any egg name is contained in the text
    for _, eggData in pairs(EGG) do
        if eggData.name and string.find(l, string.lower(eggData.name), 1, true) then
            return eggData
        end
    end
    
    return nil
end

local function selOn(sel, key)
    return sel[key] ~= false
end

local function partOf(obj)
    if obj:IsA("BasePart") then
        return obj
    end
    return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
end

local function textOf(p)
    return string.lower(p.ActionText .. " " .. p.ObjectText)
end

local function promptPos(p)
    local node = p.Parent
    if node and node:IsA("Attachment") then
        node = node.Parent
    end
    if node and node:IsA("BasePart") then
        return node.Position
    end
    if node and node:IsA("Model") then
        return node:GetPivot().Position
    end
    return nil
end

local function dropVisual(obj)
    local item = visuals[obj]
    if item then
        pcall(function()
            item.hl:Destroy()
            item.bb:Destroy()
        end)
        visuals[obj] = nil
    end
end

local function clearVisuals()
    for obj in pairs(visuals) do
        dropVisual(obj)
    end
end

-- ===== IMPROVED kindOf with better egg detection =====
local function kindOf(obj)
    if obj:IsA("ProximityPrompt") then
        return "prompt"
    end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then
        return nil
    end
    
    local n = string.lower(obj.Name)
    
    -- Trail shop check
    if n == "trail shop" or n == "trailshop" or n == "trail" then
        return "trail"
    end
    
    -- Egg detection - check name first
    local eggInfo = eggOf(obj.Name)
    if eggInfo then
        -- Skip if name contains bad words (machines, etc)
        if hasAny(n, BAD_NAME) then
            -- But check if it's actually an egg model with egg in name
            if string.find(n, "egg", 1, true) and not hasAny(n, {"hatch", "incubat", "inventor"}) then
                return "egg"
            end
            return nil
        end
        
        -- Skip if parent is also an egg (nested)
        if obj:IsA("BasePart") and obj.Parent and eggOf(obj.Parent.Name) then
            return nil
        end
        
        -- Check ancestor chain
        local chain = chainOf(obj)
        if hasAny(chain, BAD_ANCESTOR) then
            -- But allow if it's clearly an egg model
            if obj:IsA("Model") and eggInfo and not hasAny(chain, {"hatch", "incubat", "inventor"}) then
                return "egg"
            end
            return nil
        end
        
        return "egg"
    end
    
    -- Check if object contains egg in name but wasn't matched
    if string.find(n, "egg", 1, true) and not hasAny(n, BAD_NAME) then
        -- Try to find closest match
        for _, eggData in pairs(EGG) do
            if eggData.name and string.find(n, string.lower(eggData.name):gsub(" ", ""), 1, true) then
                return "egg"
            end
        end
    end
    
    -- Check for egg-like attributes (Size, Shape)
    if obj:IsA("BasePart") and obj.Size.Y < 5 and obj.Size.X < 5 and obj.Size.Z < 5 then
        -- Check if it's a small part that could be an egg
        local parent = obj.Parent
        if parent and parent:IsA("Model") then
            local parentName = string.lower(parent.Name)
            if string.find(parentName, "egg", 1, true) then
                return "egg"
            end
        end
    end
    
    return nil
end

local function track(obj)
    local k = kindOf(obj)
    if k then
        idx[k][obj] = true
    end
end

local function untrack(obj)
    for _, set in pairs(idx) do
        set[obj] = nil
    end
    dropVisual(obj)
end

-- Initial scan
for _, d in ipairs(workspace:GetDescendants()) do
    track(d)
end

workspace.DescendantAdded:Connect(track)
workspace.DescendantRemoving:Connect(untrack)

-- ===== PROMPT & MACHINE FUNCTIONS =====
local function nearestPrompt(pos, pred)
    local best, bestD
    for p in pairs(idx.prompt) do
        if p:IsDescendantOf(workspace) and (not pred or pred(p)) then
            local pp = promptPos(p)
            if pp then
                local d = (pp - pos).Magnitude
                if not bestD or d < bestD then
                    best, bestD = p, d
                end
            end
        end
    end
    return best, bestD
end

local function machinePositions()
    if os.clock() - machAt < 1 then
        return machCache
    end
    machAt = os.clock()
    machCache = {}
    for p in pairs(idx.prompt) do
        if p:IsDescendantOf(workspace) and hasAny(textOf(p), MACHINE_WORDS) then
            local pp = promptPos(p)
            if pp then
                table.insert(machCache, pp)
            end
        end
    end
    return machCache
end

local function nearMachine(pos)
    for _, mp in ipairs(machinePositions()) do
        if (mp - pos).Magnitude <= CFG.MachineClear then
            return true
        end
    end
    return false
end

-- ===== IMPROVED eggPromptOf =====
local function eggPromptOf(model)
    -- First check if model has its own prompt
    local own = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if own and not hasAny(textOf(own), BAD_PROMPT) then
        return own
    end
    
    local part = partOf(model)
    if not part then
        return nil
    end
    
    -- Find nearest prompt to the egg
    local best, bestD
    for p in pairs(idx.prompt) do
        if p:IsDescendantOf(workspace) and p.Enabled and not hasAny(textOf(p), BAD_PROMPT) and not hasAny(chainOf(p), BAD_CHAIN) then
            local pp = promptPos(p)
            if pp then
                local d = (pp - part.Position).Magnitude
                if d <= 15 and (not bestD or d < bestD) then
                    best, bestD = p, d
                end
            end
        end
    end
    return best
end

local function firePrompt(p)
    if typeof(fireproximityprompt) == "function" then
        local dist, hold = p.MaxActivationDistance, p.HoldDuration
        pcall(function()
            p.MaxActivationDistance = FAR
            p.HoldDuration = 0
        end)
        pcall(fireproximityprompt, p)
        pcall(function()
            p.MaxActivationDistance = dist
            p.HoldDuration = hold
        end)
        return
    end
    pcall(function()
        p:InputHoldBegin()
        task.wait(p.HoldDuration + 0.05)
        p:InputHoldEnd()
    end)
end

local function touchPart(part)
    local root = getRoot()
    if root and part and typeof(firetouchinterest) == "function" then
        pcall(firetouchinterest, root, part, 0)
        task.wait(0.05)
        pcall(firetouchinterest, root, part, 1)
    end
end

local function waitFor(pred, secs)
    local deadline = os.clock() + secs
    repeat
        if pred() then
            return true
        end
        task.wait(0.05)
    until os.clock() >= deadline
    return pred() and true or false
end

-- ===== INVENTORY FUNCTIONS =====
local function eggsIn(c, out)
    if c then
        for _, x in ipairs(c:GetChildren()) do
            if (x:IsA("Tool") or x:IsA("Model")) and eggOf(x.Name) and not hasAny(string.lower(x.Name), BAD_NAME) then
                table.insert(out, x.Name)
            end
        end
    end
    return out
end

local function handEggs()
    return eggsIn(player.Character, {})
end

local function bagEggs()
    return eggsIn(player:FindFirstChildOfClass("Backpack"), {})
end

local function totalEggs()
    return #handEggs() + #bagEggs()
end

local function safePos()
    if CFG.SafeTrail then
        for t in pairs(idx.trail) do
            if t:IsDescendantOf(workspace) then
                local cf, size
                if t:IsA("Model") then
                    cf, size = t:GetBoundingBox(), t:GetExtentsSize()
                else
                    cf, size = t.CFrame, t.Size
                end
                local side = cf.Position + cf.RightVector * (size.X / 2 + CFG.SafeSide)
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {t}
                local hit = workspace:Raycast(Vector3.new(side.X, side.Y + 40, side.Z), Vector3.new(0, -160, 0), params)
                return hit and hit.Position or side
            end
        end
    end
    return zone
end

local function backToSafe()
    local p = safePos()
    local r = getRoot()
    if p and r and (r.Position - p).Magnitude > CFG.ReturnRadius then
        tpTo(p)
    end
end

-- ===== IMPROVED pickEgg with detection radius =====
local function pickEgg()
    local r = getRoot()
    if not r then
        return nil
    end
    
    local now = os.clock()
    local best
    local eggCount = 0
    local detectionRadius = CFG.DetectionRadius
    
    for obj in pairs(idx.egg) do
        if obj:IsDescendantOf(workspace) and not (player.Character and obj:IsDescendantOf(player.Character)) and (ignored[obj] or 0) < now then
            local info = eggOf(obj.Name)
            local part = partOf(obj)
            
            if info and part then
                local dist = (part.Position - r.Position).Magnitude
                
                -- Check detection radius
                if dist <= detectionRadius then
                    eggCount = eggCount + 1
                    
                    -- Check if egg is selected in filter
                    if selOn(eggSel, info.key) and info.rank >= CFG.MinRank then
                        -- Check ancestor chain
                        local chain = chainOf(obj)
                        if not hasAny(chain, BAD_ANCESTOR) then
                            -- Check machine proximity (but don't skip if it's the only option)
                            local nearMach = nearMachine(part.Position)
                            
                            -- Only skip if near machine AND there are other options
                            if not nearMach or not best then
                                local cand = {model = obj, part = part, info = info, dist = dist}
                                
                                if not best then
                                    best = cand
                                elseif CFG.RarityFirst then
                                    if cand.info.rank > best.info.rank or (cand.info.rank == best.info.rank and cand.dist < best.dist) then
                                        best = cand
                                    end
                                elseif cand.dist < best.dist then
                                    best = cand
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Update detected egg count
    S.detectedEggs = eggCount
    
    -- Update status with detection info
    if eggCount > 0 and not best then
        S.status = string.format("Ditemukan %d egg, tapi tidak ada yang cocok dengan filter", eggCount)
    elseif eggCount == 0 then
        S.status = "Tidak ada egg terdeteksi dalam radius " .. detectionRadius
    end
    
    return best
end

-- ===== STEAL FUNCTION =====
local function steal(e)
    local before = totalEggs()
    for _ = 1, 2 do
        if not CFG.AutoSteal or not e.model:IsDescendantOf(workspace) then
            break
        end
        streamAround(e.part.Position)
        tpTo(e.part.Position)
        task.wait(0.15)
        
        local p
        local t0 = os.clock()
        repeat
            p = eggPromptOf(e.model)
            if p and p.Enabled then
                break
            end
            task.wait(0.1)
        until os.clock() - t0 > 1.5
        
        if p then
            firePrompt(p)
        end
        touchPart(e.part)
        
        if waitFor(function()
            return not e.model:IsDescendantOf(workspace) or totalEggs() > before
        end, CFG.StealWait) then
            backToSafe()
            return true
        end
        task.wait(0.2)
    end
    backToSafe()
    return false
end

-- ===== PROMPT & MACHINE INTERACTIONS =====
local function findPromptNearest(words)
    local r = getRoot()
    if not r then
        return nil
    end
    local now = os.clock()
    return (nearestPrompt(r.Position, function(p)
        return hasAny(textOf(p), words) and (cooldown[p] or 0) < now
    end))
end

local function ensurePrompt(words)
    local p = findPromptNearest(words)
    if not p then
        local r = getRoot()
        streamAround(zone or (r and r.Position))
        waitFor(function()
            p = findPromptNearest(words)
            return p ~= nil
        end, 1.5)
    end
    return p
end

local function useMachine(p)
    local pos = promptPos(p)
    if pos then
        streamAround(pos)
        tpTo(pos)
    end
    task.wait(0.1)
    firePrompt(p)
    task.wait(0.15)
end

local function putInventory()
    local p = ensurePrompt({"put to inventory"})
    if not p then
        S.status = "Prompt Put To Inventory tidak ketemu"
        return false
    end
    local beforeHand, beforeAll = #handEggs(), totalEggs()
    cooldown[p] = os.clock() + CFG.InvCd
    useMachine(p)
    backToSafe()
    if waitFor(function()
        return #handEggs() < beforeHand or totalEggs() < beforeAll
    end, 2) then
        S.inv += 1
        S.status = "Masuk inventory"
        return true
    end
    S.status = "Egg belum masuk inventory, dicoba lagi"
    return false
end

local function placeEgg()
    local p = ensurePrompt({"place", "plant", "incubat"})
    if not p then
        S.status = "Mesin place tidak ketemu"
        return false
    end
    local beforeHand = #handEggs()
    cooldown[p] = os.clock() + CFG.MachineCd
    local pos = promptPos(p)
    if pos then
        streamAround(pos)
        tpTo(pos)
    end
    task.wait(0.1)
    firePrompt(p)
    local ok = waitFor(function()
        return #handEggs() < beforeHand
    end, 1.5)
    local safe = safePos()
    if CFG.PlaceReturn and safe then
        tpTo(safe)
    else
        backToSafe()
    end
    if ok then
        S.place += 1
        S.status = "Egg ditaruh ke mesin"
        return true
    end
    S.status = "Place belum berhasil, dicoba lagi"
    return false
end

local function hatchOnce()
    local p = ensurePrompt({"hatch"})
    if not p then
        return false
    end
    cooldown[p] = os.clock() + CFG.HatchCd
    useMachine(p)
    backToSafe()
    S.hatch += 1
    S.status = "Hatch dijalankan"
    return true
end

local function ensureInventoryStep()
    if os.clock() < nextInv then
        return
    end
    nextInv = os.clock() + CFG.InvCd
    busy = true
    local ok = putInventory()
    busy = false
    if ok then
        invFails = 0
        return
    end
    invFails += 1
    if invFails >= CFG.InvTries then
        invFails = 0
        local hum = humanoid()
        if hum then
            pcall(function()
                hum:UnequipTools()
            end)
        end
        S.status = "Egg dipindah dari tangan, coba inventory lagi"
    end
end

-- ===== MAIN LOOP =====
local function mainTick()
    if not getRoot() then
        S.status = "Menunggu karakter"
        return
    end
    
    local hand = #handEggs()
    S.held = hand .. " di tangan, " .. #bagEggs() .. " di tas"
    
    if hand > 0 then
        if CFG.AutoInv then
            ensureInventoryStep()
            return
        end
        if CFG.AutoPlace and os.clock() >= nextPlace then
            nextPlace = os.clock() + CFG.MachineCd
            busy = true
            placeEgg()
            busy = false
            return
        end
        S.status = CFG.AutoPlace and "Egg di tangan, menunggu Auto Place" or "Egg di tangan. Nyalakan Auto Inventory atau Auto Place"
        return
    end
    
    if CFG.AutoHatch and os.clock() >= nextHatch then
        nextHatch = os.clock() + CFG.HatchCd
        busy = true
        local did = hatchOnce()
        busy = false
        if did then
            return
        end
    end
    
    if not CFG.AutoSteal then
        S.status = "Auto steal mati (tekan F untuk nyala)"
        return
    end
    
    local target = pickEgg()
    if not target then
        return
    end
    
    S.status = "Steal " .. target.info.name .. " (Luck " .. target.info.luck .. ")"
    busy = true
    local ok = steal(target)
    busy = false
    
    if ok then
        S.steal += 1
        S.status = "Dapat " .. target.info.name
    else
        ignored[target.model] = os.clock() + CFG.IgnoreTime
        S.status = "Gagal steal " .. target.info.name
    end
end

-- ===== WATER & VISUAL =====
local function isWater(pos)
    local ok, res = pcall(function()
        local region = Region3.new(pos - Vector3.new(3, 3, 3), pos + Vector3.new(3, 3, 3)):ExpandToGrid(4)
        local mats, occs = workspace.Terrain:ReadVoxels(region, 4)
        for x = 1, #mats do
            for y = 1, #mats[x] do
                for z = 1, #mats[x][y] do
                    if mats[x][y][z] == Enum.Material.Water and occs[x][y][z] > 0.5 then
                        return true
                    end
                end
            end
        end
        return false
    end)
    return ok and res or false
end

local function collectVisuals()
    local want = {}
    local root = getRoot()
    local ch = player.Character
    if not root then
        return want
    end
    
    local rp = root.Position
    local checks = 0
    local now = os.clock()
    local espRadius = CFG.ESPRadius
    
    for obj in pairs(idx.egg) do
        local info = eggOf(obj.Name)
        local part = obj:IsDescendantOf(workspace) and not (ch and obj:IsDescendantOf(ch)) and partOf(obj)
        
        if info and part and selOn(espSel, info.key) and not hasAny(chainOf(obj), BAD_ANCESTOR) then
            local dist = (part.Position - rp).Magnitude
            
            -- Check ESP radius
            if dist <= espRadius then
                local d = math.floor(dist)
                
                if CFG.EggESP then
                    want[obj] = {part = part, text = string.format("%s | %d m", info.name, d), mode = "esp"}
                elseif CFG.XRay then
                    local c = waterCache[obj]
                    local inWater
                    if c and now - c.at < 4 then
                        inWater = c.v
                    elseif checks < 30 then
                        checks += 1
                        inWater = isWater(part.Position)
                        waterCache[obj] = {v = inWater, at = now}
                    end
                    if inWater then
                        want[obj] = {part = part, text = "Luck " .. info.luck, mode = "xray"}
                    end
                end
            end
        end
    end
    
    return want
end

local function makeVisual(obj, w)
    local xray = w.mode == "xray"
    local color = xray and C.Accent or C.Light
    
    local hl = Instance.new("Highlight")
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = color
    hl.FillTransparency = 0.6
    hl.OutlineColor = color
    hl.Parent = obj
    
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(xray and 130 or 210, 20)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = w.part
    bb.Parent = w.part
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.fromScale(1, 1)
    lb.BackgroundColor3 = xray and C.AccentDark or C.Panel
    lb.BackgroundTransparency = 0.15
    lb.TextColor3 = C.Text
    lb.Font = Enum.Font.GothamSemibold
    lb.TextSize = 11
    lb.Parent = bb
    Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 6)
    
    return {hl = hl, bb = bb, lb = lb, mode = w.mode}
end

local function applyVisuals(want)
    for obj, item in pairs(visuals) do
        local w = want[obj]
        if not w or w.mode ~= item.mode or not obj:IsDescendantOf(workspace) then
            dropVisual(obj)
        end
    end
    
    for obj, w in pairs(want) do
        local item = visuals[obj]
        if not item then
            item = makeVisual(obj, w)
            visuals[obj] = item
        end
        item.lb.Text = w.text
    end
end

-- ===== LOW GRAPHICS =====
local low = {on = false, saved = {}, queue = {}, seen = {}, quality = nil}

local function remember(obj, prop)
    local rec = low.saved[obj]
    if not rec then
        rec = {}
        low.saved[obj] = rec
    end
    if rec[prop] == nil then
        local ok, val = pcall(function()
            return obj[prop]
        end)
        if ok and val ~= nil then
            rec[prop] = val
        end
    end
end

local function setLow(obj, prop, value)
    remember(obj, prop)
    pcall(function()
        obj[prop] = value
    end)
end

local function lowApply(d)
    if d:IsA("Terrain") then
        return
    end
    local ok = pcall(function()
        if d:IsA("PostEffect") or LOW_OFF[d.ClassName] then
            setLow(d, "Enabled", false)
        elseif d:IsA("Atmosphere") then
            setLow(d, "Density", 0)
            setLow(d, "Haze", 0)
            setLow(d, "Glare", 0)
        elseif d:IsA("Decal") or d:IsA("Texture") then
            setLow(d, "Transparency", 1)
        elseif d:IsA("BasePart") then
            setLow(d, "CastShadow", false)
            setLow(d, "Material", Enum.Material.SmoothPlastic)
        end
    end)
    if ok then
        S.low += 1
    else
        S.lowErr += 1
    end
end

local function lowSweep()
    for _, d in ipairs(Lighting:GetDescendants()) do
        table.insert(low.queue, d)
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        table.insert(low.queue, d)
    end
end

local function lowPump()
    local n = 0
    while #low.queue > 0 and n < 250 do
        local d = table.remove(low.queue)
        if d and d.Parent and not low.seen[d] then
            low.seen[d] = true
            lowApply(d)
        end
        n += 1
    end
end

local function lowRestore()
    for obj, rec in pairs(low.saved) do
        for prop, val in pairs(rec) do
            pcall(function()
                obj[prop] = val
            end)
        end
    end
    low.saved, low.queue, low.seen = {}, {}, {}
    pcall(function()
        settings().Rendering.QualityLevel = low.quality or Enum.QualityLevel.Automatic
    end)
    low.quality = nil
    S.low, S.lowErr = 0, 0
end

local function lowSet(on)
    low.on = on
    if on then
        if low.quality == nil then
            pcall(function()
                low.quality = settings().Rendering.QualityLevel
            end)
        end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        setLow(Lighting, "GlobalShadows", false)
        setLow(Lighting, "EnvironmentDiffuseScale", 0)
        setLow(Lighting, "EnvironmentSpecularScale", 0)
        setLow(workspace.Terrain, "Decoration", false)
        setLow(workspace.Terrain, "WaterWaveSize", 0)
        setLow(workspace.Terrain, "WaterWaveSpeed", 0)
        setLow(workspace.Terrain, "WaterReflectance", 0)
        lowSweep()
        S.status = "Low Graphics aktif"
    else
        lowRestore()
        S.status = "Low Graphics mati, efek dikembalikan"
    end
end

workspace.DescendantAdded:Connect(function(d)
    if low.on then
        table.insert(low.queue, d)
    end
end)
Lighting.DescendantAdded:Connect(function(d)
    if low.on then
        table.insert(low.queue, d)
    end
end)

-- ===== ANTI AFK & MOVEMENT =====
local function antiAfkClick()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local function antiAfkJump()
    local hum = humanoid()
    if hum and hum.Health > 0 then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function applyMove()
    local hum = humanoid()
    if not hum then
        return
    end
    if CFG.Walk and hum.WalkSpeed ~= CFG.WalkSpeed then
        hum.WalkSpeed = CFG.WalkSpeed
    end
    if CFG.Jump then
        hum.UseJumpPower = true
        if hum.JumpPower ~= CFG.JumpPower then
            hum.JumpPower = CFG.JumpPower
        end
    end
end

local function captureBase(ch)
    local hum = ch:WaitForChild("Humanoid", 10)
    if hum then
        baseWalk = hum.WalkSpeed
        baseJump = hum.JumpPower
    end
end

-- ===== CONFIG SYSTEM =====
local function buildData()
    local data = {cfg = {}, eggs = eggSel, esp = espSel}
    for k, v in pairs(CFG) do
        local t = typeof(v)
        if t == "boolean" or t == "number" or t == "string" then
            data.cfg[k] = v
        end
    end
    return HttpService:JSONEncode(data)
end

local function applySettings(raw)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(data) ~= "table" or type(data.cfg) ~= "table" then
        return false
    end
    for k, v in pairs(data.cfg) do
        if CFG[k] ~= nil and typeof(CFG[k]) == typeof(v) then
            CFG[k] = v
        end
    end
    for k, v in pairs(data.eggs or {}) do
        if EGG[k] and type(v) == "boolean" then
            eggSel[k] = v
        end
    end
    for k, v in pairs(data.esp or {}) do
        if EGG[k] and type(v) == "boolean" then
            espSel[k] = v
        end
    end
    return true
end

local function saveConfig(force)
    if typeof(writefile) ~= "function" then
        S.config = "writefile tidak ada"
        return
    end
    local json = buildData()
    if not force and json == lastJson then
        return
    end
    if pcall(writefile, CONFIG_FILE, json) then
        lastJson = json
        S.config = "tersimpan"
    else
        S.config = "gagal simpan"
    end
end

local function loadConfig()
    if typeof(readfile) ~= "function" then
        S.config = "readfile tidak ada"
        return
    end
    if typeof(isfile) == "function" and not isfile(CONFIG_FILE) then
        S.config = "belum ada config"
        return
    end
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or type(raw) ~= "string" then
        S.config = "gagal baca"
        return
    end
    S.config = applySettings(raw) and "dimuat" or "config rusak"
end

-- ===== UI HELPERS =====
local function make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        o[k] = v
    end
    if parent then
        o.Parent = parent
    end
    return o
end

local function corner(o, r)
    make("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o)
end

local function btn(parent, text, color, h)
    local b = make("TextButton", {
        Size = UDim2.new(1, 0, 0, h or 30), BackgroundColor3 = color, BorderSizePixel = 0, Text = text,
        TextColor3 = C.Text, Font = Enum.Font.GothamSemibold, TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd, AutoButtonColor = false,
    }, parent)
    corner(b, 8)
    return b
end

local function section(page, text)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = string.upper(text),
        TextColor3 = C.Accent, Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),
    }, page)
end

local function note(page, text)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        TextWrapped = true, Text = text, TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = nextOrder(),
    }, page)
end

-- ===== MODERN TOGGLE =====
local function switch(page, label, key, onChange)
    local row = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.Card, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "", LayoutOrder = nextOrder(),
    }, page)
    corner(row, 10)
    
    make("UIStroke", {Color = C.PinkBorder, Transparency = 0.8, Thickness = 1}, row)
    
    make("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, Font = Enum.Font.GothamSemibold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    
    local track = make("Frame", {
        Size = UDim2.fromOffset(44, 22), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        BackgroundColor3 = C.Dark, BorderSizePixel = 0,
    }, row)
    corner(track, 11)
    
    local knob = make("Frame", {
        Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = C.Muted, BorderSizePixel = 0,
    }, track)
    corner(knob, 9)
    
    table.insert(paints, function()
        local on = CFG[key] == true
        track.BackgroundColor3 = on and C.Accent or C.Dark
        knob.Position = on and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2)
        knob.BackgroundColor3 = on and C.Text or C.Muted
    end)
    
    row.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        if onChange then
            onChange(CFG[key])
        end
        refresh()
    end)
end

-- ===== MODERN STEPPER =====
local function stepper(page, label, key, step, lo, hi)
    local r = make("Frame", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.Card, BorderSizePixel = 0, LayoutOrder = nextOrder(),
    }, page)
    corner(r, 10)
    
    make("UIStroke", {Color = C.PinkBorder, Transparency = 0.8, Thickness = 1}, r)
    
    make("TextLabel", {
        Size = UDim2.new(1, -140, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Muted, Font = Enum.Font.GothamSemibold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, r)
    
    local value = make("TextLabel", {
        Size = UDim2.fromOffset(44, 36), Position = UDim2.new(1, -98, 0, 0), BackgroundTransparency = 1,
        TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 13,
    }, r)
    
    local minus = btn(r, "−", C.Row, 26)
    minus.Size = UDim2.fromOffset(28, 26)
    minus.Position = UDim2.new(1, -50, 0.5, -13)
    minus.TextColor3 = C.Accent
    
    local plus = btn(r, "+", C.Row, 26)
    plus.Size = UDim2.fromOffset(28, 26)
    plus.Position = UDim2.new(1, -18, 0.5, -13)
    plus.TextColor3 = C.Accent
    
    minus.MouseButton1Click:Connect(function()
        CFG[key] = math.clamp(math.floor((CFG[key] - step) / step + 0.5) * step, lo, hi)
        refresh()
    end)
    plus.MouseButton1Click:Connect(function()
        CFG[key] = math.clamp(math.floor((CFG[key] + step) / step + 0.5) * step, lo, hi)
        refresh()
    end)
    
    table.insert(paints, function()
        value.Text = string.format("%g", CFG[key])
    end)
end

-- ===== MODERN EGG ROW =====
local function eggRow(page, sel, e)
    local key = string.lower(e[1])
    local b = btn(page, "", C.Row, 30)
    b.LayoutOrder = nextOrder()
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    
    make("UIPadding", {PaddingLeft = UDim.new(0, 12)}, b)
    
    table.insert(paints, function()
        local on = selOn(sel, key)
        b.Text = (on and "●  " or "○  ") .. e[1] .. "   |   Luck " .. e[2]
        b.BackgroundColor3 = on and C.AccentDark or C.Row
        b.TextColor3 = on and C.Text or C.Muted
    end)
    
    b.MouseButton1Click:Connect(function()
        sel[key] = not selOn(sel, key)
        refresh()
    end)
end

-- ===== MODERN EGG LIST =====
local function eggList(page, sel, withMin)
    local r = make("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, page)
    
    local all = btn(r, "Pilih semua", C.AccentDark, 32)
    all.Size = UDim2.new(withMin and 0.34 or 0.5, -4, 1, 0)
    all.TextColor3 = C.Text
    
    local none = btn(r, "Kosongkan", C.Row, 32)
    none.Size = UDim2.new(withMin and 0.33 or 0.5, -4, 1, 0)
    none.Position = UDim2.new(withMin and 0.34 or 0.5, 4, 0, 0)
    none.TextColor3 = C.Muted
    
    all.MouseButton1Click:Connect(function()
        for _, e in ipairs(EGG_LIST) do
            sel[string.lower(e[1])] = true
        end
        refresh()
    end)
    
    none.MouseButton1Click:Connect(function()
        for _, e in ipairs(EGG_LIST) do
            sel[string.lower(e[1])] = false
        end
        refresh()
    end)
    
    if withMin then
        local minB = btn(r, "", C.Row, 32)
        minB.Size = UDim2.new(0.33, -4, 1, 0)
        minB.Position = UDim2.new(0.67, 4, 0, 0)
        minB.TextColor3 = C.Accent
        
        minB.MouseButton1Click:Connect(function()
            minIdx = minIdx % #MIN_STEPS + 1
            CFG.MinRank = MIN_STEPS[minIdx][2]
            refresh()
        end)
        
        table.insert(paints, function()
            minB.Text = "Min: " .. MIN_STEPS[minIdx][1]
        end)
    end
    
    for _, e in ipairs(EGG_LIST) do
        eggRow(page, sel, e)
    end
end

-- ===== VIEWPORT & LAYOUT =====
local function viewportSize()
    local cam = workspace.CurrentCamera
    local v = cam and cam.ViewportSize or Vector2.new(900, 600)
    if v.X < 1 or v.Y < 1 then
        v = Vector2.new(900, 600)
    end
    return v
end

local function applyLayout()
    local main = uiRefs.main
    if not main then
        return
    end
    
    local v = viewportSize()
    local s = math.clamp(math.min((v.X - 20) / PANEL_W, (v.Y - 20) / PANEL_H, 1), 0.45, 1)
    uiRefs.scale.Scale = s
    
    local w, h = PANEL_W * s, PANEL_H * s
    
    if not layout.ready then
        layout.main = Vector2.new(v.X / 2, v.Y / 2)
        layout.logo = Vector2.new(v.X - 36, v.Y / 2)
        layout.ready = true
    end
    
    local mx = math.max(w / 2, math.min(v.X - w / 2, layout.main.X))
    local my = math.max(h / 2, math.min(v.Y - h / 2, layout.main.Y))
    layout.main = Vector2.new(mx, my)
    main.Position = UDim2.fromOffset(mx, my)
    
    if uiRefs.logo then
        local lx = math.max(26, math.min(v.X - 26, layout.logo.X))
        local ly = math.max(26, math.min(v.Y - 26, layout.logo.Y))
        layout.logo = Vector2.new(lx, ly)
        uiRefs.logo.Position = UDim2.fromOffset(lx, ly)
    end
end

local function drag(handle, getPos, setPos, onTap)
    local dragging, moved = false, false
    local start, origin
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            start = input.Position
            origin = getPos()
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved and onTap then
                onTap()
            end
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - start
            if d.Magnitude > 5 then
                moved = true
            end
            if moved then
                setPos(origin.X + d.X, origin.Y + d.Y)
            end
        end
    end)
end

local function copyLink(url)
    return pcall(function()
        assert(type(setclipboard) == "function", "Clipboard tidak didukung")
        setclipboard(url)
    end)
end

-- ===== LOGO KH ANIMATED =====
local function createLogo(parent, size)
    local logoFrame = make("Frame", {
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = C.AccentDark,
        BorderSizePixel = 0,
    }, parent)
    corner(logoFrame, size * 0.3)
    
    -- Gradient effect
    local gradient = make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.HotPink),
            ColorSequenceKeypoint.new(0.5, C.Accent),
            ColorSequenceKeypoint.new(1, C.AccentDark)
        }),
        Rotation = 45,
    }, logoFrame)
    
    -- Glossy effect
    local gloss = make("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
    }, logoFrame)
    corner(gloss, size * 0.3)
    
    -- KH Monogram
    local khText = make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "KH",
        TextColor3 = C.Text,
        Font = Enum.Font.GothamBold,
        TextSize = size * 0.4,
        TextStrokeTransparency = 0,
        TextStrokeColor3 = C.HotPink,
    }, logoFrame)
    
    -- Glow effect
    local glow = make("UIStroke", {
        Color = C.Accent,
        Thickness = 2,
        Transparency = 0.3,
    }, logoFrame)
    
    -- Animation loop
    task.spawn(function()
        local t = 0
        while logoFrame.Parent do
            t += 0.05
            
            -- Pulse effect
            local scale = 1 + math.sin(t * 2) * 0.05
            logoFrame.Size = UDim2.fromOffset(size * scale, size * scale)
            
            -- Glow pulse
            glow.Transparency = 0.3 + math.sin(t * 3) * 0.2
            
            -- Shine effect
            gloss.BackgroundTransparency = 0.7 + math.sin(t * 4) * 0.3
            
            task.wait(0.05)
        end
    end)
    
    return logoFrame
end

-- ===== WELCOME POPUP =====
local function showWelcomePopup()
    if welcomeShown then
        return
    end
    welcomeShown = true
    
    local host = player:WaitForChild("PlayerGui")
    local okH, hui = pcall(gethui)
    if okH and typeof(hui) == "Instance" then
        host = hui
    end
    
    local popupGui = make("ScreenGui", {
        Name = "kayeshiHUB_Welcome",
        ResetOnSpawn = false,
        DisplayOrder = 1000,
        IgnoreGuiInset = true,
    }, host)
    
    local overlay = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
    }, popupGui)
    
    local popup = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(400, 450),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
    }, overlay)
    corner(popup, 16)
    make("UIStroke", {Color = C.PinkBorder, Transparency = 0.5, Thickness = 2}, popup)
    
    -- Close button (X)
    local closeBtn = make("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -35, 0, 10),
        BackgroundColor3 = C.Row,
        Text = "✕",
        TextColor3 = C.Muted,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, popup)
    corner(closeBtn, 15)
    
    closeBtn.MouseButton1Click:Connect(function()
        popupGui:Destroy()
    end)
    
    -- Logo
    local logo = createLogo(popup, 80)
    logo.Position = UDim2.new(0.5, -40, 0, 30)
    
    -- Title
    make("TextLabel", {
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0, 20, 0, 120),
        BackgroundTransparency = 1,
        Text = "Welcome to kayeshiHUB!",
        TextColor3 = C.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextScaled = true,
    }, popup)
    
    -- Description
    make("TextLabel", {
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0, 20, 0, 170),
        BackgroundTransparency = 1,
        Text = "v2.1 Dark Pink Premium Edition\nSistem deteksi Egg yang lebih akurat\nUI premium dengan logo KH eksklusif",
        TextColor3 = C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextWrapped = true,
    }, popup)
    
    -- WhatsApp button
    local waBtn = btn(popup, "Join WhatsApp", C.AccentDark, 40)
    waBtn.Position = UDim2.new(0.5, -170, 0, 280)
    waBtn.Size = UDim2.fromOffset(340, 40)
    waBtn.TextColor3 = C.Text
    
    waBtn.MouseButton1Click:Connect(function()
        copyLink(WHATSAPP)
        notify("Link WhatsApp disalin")
    end)
    
    -- Discord button
    local dcBtn = btn(popup, "Join Discord", C.Row, 40)
    dcBtn.Position = UDim2.new(0.5, -170, 0, 330)
    dcBtn.Size = UDim2.fromOffset(340, 40)
    dcBtn.TextColor3 = C.Accent
    
    dcBtn.MouseButton1Click:Connect(function()
        copyLink(DISCORD)
        notify("Link Discord disalin")
    end)
    
    -- Footer text
    make("TextLabel", {
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0, 390),
        BackgroundTransparency = 1,
        Text = "kayeshiHUB v2.1",
        TextColor3 = C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
    }, popup)
end

-- ===== BUILD UI =====
local function buildUI()
    local host = player:WaitForChild("PlayerGui")
    local okH, hui = pcall(gethui)
    if okH and typeof(hui) == "Instance" then
        host = hui
    end
    
    local old = host:FindFirstChild("kayeshiHUB")
    if old then
        old:Destroy()
    end
    
    local gui = make("ScreenGui", {Name = "kayeshiHUB", ResetOnSpawn = false, DisplayOrder = 999, IgnoreGuiInset = true}, host)
    
    -- Main Panel
    local main = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(PANEL_W, PANEL_H),
        BackgroundColor3 = C.Panel, BorderSizePixel = 0,
    }, gui)
    corner(main, 16)
    make("UIStroke", {Color = C.PinkBorder, Transparency = 0.5, Thickness = 1}, main)
    uiRefs.main = main
    uiRefs.scale = make("UIScale", {Scale = 1}, main)
    
    -- Header
    local header = make("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = C.Side, BorderSizePixel = 0}, main)
    corner(header, 16)
    
    -- Logo in header
    local headerLogo = createLogo(header, 36)
    headerLogo.Position = UDim2.new(0, 12, 0.5, -18)
    
    make("TextLabel", {
        Size = UDim2.new(0, 200, 0, 22), Position = UDim2.fromOffset(56, 6), BackgroundTransparency = 1,
        Text = "kayeshiHUB", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    
    local subtitle = make("TextLabel", {
        Size = UDim2.new(1, -130, 0, 14), Position = UDim2.fromOffset(56, 28), BackgroundTransparency = 1,
        TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, header)
    
    local minBtn = btn(header, "Sembunyi", C.AccentDark, 28)
    minBtn.Size = UDim2.fromOffset(88, 28)
    minBtn.Position = UDim2.new(1, -98, 0, 12)
    minBtn.TextSize = 11
    minBtn.TextColor3 = C.Text
    
    -- Sidebar
    local side = make("Frame", {
        Position = UDim2.fromOffset(10, 60), Size = UDim2.new(0, 140, 1, -126),
        BackgroundColor3 = C.Side, BorderSizePixel = 0,
    }, main)
    corner(side, 12)
    make("UIStroke", {Color = C.PinkBorder, Transparency = 0.7, Thickness = 1}, side)
    make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, side)
    make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, side)
    
    -- Content Area
    local content = make("Frame", {
        Position = UDim2.fromOffset(158, 60), Size = UDim2.new(1, -168, 1, -126),
        BackgroundColor3 = C.Side, BorderSizePixel = 0,
    }, main)
    corner(content, 12)
    
    -- Footer
    local footer = make("Frame", {
        Position = UDim2.new(0, 10, 1, -60), Size = UDim2.new(1, -20, 0, 50),
        BackgroundColor3 = C.Side, BorderSizePixel = 0,
    }, main)
    corner(footer, 12)
    
    local statusLbl = make("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
        TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, footer)
    
    -- Tabs
    local TABS = {
        {"main", "Utama"}, {"egg", "Filter Egg"}, {"auto", "Auto"},
        {"esp", "ESP & X-Ray"}, {"grafik", "Grafik"}, {"discord", "Komunitas"},
    }
    
    local pages, tabs = {}, {}
    for i, t in ipairs(TABS) do
        local page = make("ScrollingFrame", {
            Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.Muted,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
        }, content)
        make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
        make("UIPadding", {PaddingRight = UDim.new(0, 8)}, page)
        pages[t[1]] = page
        
        local b = btn(side, t[2], C.Card, 32)
        b.LayoutOrder = i
        b.TextSize = 11
        b.TextColor3 = C.Muted
        tabs[t[1]] = b
    end
    
    local mp, ep, ap, esp, gp, dp = pages.main, pages.egg, pages.auto, pages.esp, pages.grafik, pages.discord
    
    -- ===== MAIN TAB =====
    section(mp, "Auto Steal")
    note(mp, "Steal egg terpilih di seluruh map. Tekan F untuk nyala/mati.")
    
    switch(mp, "Auto Steal", "AutoSteal")
    switch(mp, "Rarity tertinggi dulu", "RarityFirst")
    stepper(mp, "Tunggu prompt (detik)", "StealWait", 0.1, 0.5, 3)
    stepper(mp, "Jarak aman dari mesin", "MachineClear", 5, 5, 80)
    
    section(mp, "Detection Radius")
    stepper(mp, "Radius deteksi egg", "DetectionRadius", 50, 100, 1000)
    stepper(mp, "Radius tampilan ESP", "ESPRadius", 50, 100, 1000)
    
    local detectedLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        TextColor3 = C.Accent, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),
    }, mp)
    table.insert(paints, function()
        detectedLabel.Text = string.format("Egg terdeteksi: %d", S.detectedEggs)
    end)
    
    section(mp, "Safe Zone")
    local zr = make("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, mp)
    
    local zoneBtn = btn(zr, "Set Safe Zone", C.AccentDark, 34)
    zoneBtn.Size = UDim2.new(0.5, -4, 1, 0)
    zoneBtn.TextColor3 = C.Text
    
    local tpBtn = btn(zr, "Teleport", C.Row, 34)
    tpBtn.Size = UDim2.new(0.5, -4, 1, 0)
    tpBtn.Position = UDim2.new(0.5, 4, 0, 0)
    tpBtn.TextColor3 = C.Accent
    
    zoneBtn.MouseButton1Click:Connect(function()
        local r = getRoot()
        if r then
            zone = r.Position
            S.status = "Safe zone disimpan"
        else
            S.status = "Karakter belum siap"
        end
        refresh()
    end)
    
    tpBtn.MouseButton1Click:Connect(function()
        local p = safePos()
        if p then
            tpTo(p)
            S.status = "Teleport ke safe zone"
        else
            S.status = "Safe zone belum di-set"
        end
        refresh()
    end)
    
    switch(mp, "Safe zone dekat Trail Shop", "SafeTrail")
    
    section(mp, "Anti AFK & Gerak")
    switch(mp, "Anti AFK", "AntiAFK", function()
        lastActive = os.clock()
    end)
    stepper(mp, "Lompat setelah diam (detik)", "AfkIdle", 30, 60, 900)
    switch(mp, "WalkSpeed", "Walk", function(on)
        local hum = humanoid()
        if hum and not on then
            hum.WalkSpeed = baseWalk
        end
    end)
    stepper(mp, "Kecepatan jalan", "WalkSpeed", 5, 16, 250)
    switch(mp, "JumpPower", "Jump", function(on)
        local hum = humanoid()
        if hum and not on then
            hum.JumpPower = baseJump
        end
    end)
    stepper(mp, "Kekuatan lompat", "JumpPower", 10, 50, 300)
    
    section(mp, "Config")
    switch(mp, "Auto Save", "AutoSave")
    
    local cr = make("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, mp)
    local saveBtn = btn(cr, "Simpan", C.AccentDark, 34)
    saveBtn.Size = UDim2.new(0.5, -4, 1, 0)
    saveBtn.TextColor3 = C.Text
    
    local loadBtn = btn(cr, "Muat", C.Row, 34)
    loadBtn.Size = UDim2.new(0.5, -4, 1, 0)
    loadBtn.Position = UDim2.new(0.5, 4, 0, 0)
    loadBtn.TextColor3 = C.Accent
    
    saveBtn.MouseButton1Click:Connect(function()
        saveConfig(true)
        refresh()
    end)
    loadBtn.MouseButton1Click:Connect(function()
        loadConfig()
        refresh()
    end)
    
    local resetBtn = btn(mp, "Reset ke Default", C.Row, 34)
    resetBtn.LayoutOrder = nextOrder()
    resetBtn.TextColor3 = C.Warning
    resetBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(DEFAULT) do
            CFG[k] = v
        end
        for _, e in ipairs(EGG_LIST) do
            local key = string.lower(e[1])
            eggSel[key] = true
            espSel[key] = true
        end
        minIdx = 1
        clearVisuals()
        lowSet(false)
        saveConfig(true)
        S.status = "Settingan dikembalikan ke default"
        refresh()
    end)
    
    -- ===== FILTER EGG TAB =====
    section(ep, "Filter Egg untuk Steal")
    note(ep, "Egg yang tidak dicentang tidak akan di-steal.")
    
    -- Search bar
    local searchFrame = make("Frame", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.Card, BorderSizePixel = 0, LayoutOrder = nextOrder(),
    }, ep)
    corner(searchFrame, 10)
    make("UIStroke", {Color = C.PinkBorder, Transparency = 0.7, Thickness = 1}, searchFrame)
    
    local searchBox = make("TextBox", {
        Size = UDim2.new(1, -20, 0, 28), Position = UDim2.fromOffset(10, 4), BackgroundColor3 = C.Row, BorderSizePixel = 0,
        Text = "", PlaceholderText = "🔍 Cari egg...", PlaceholderColor3 = C.Muted,
        TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, searchFrame)
    corner(searchBox, 8)
    make("UIPadding", {PaddingLeft = UDim.new(0, 10)}, searchBox)
    
    searchBox.FocusLost:Connect(function()
        eggSearchQuery = string.lower(searchBox.Text or "")
        refresh()
    end)
    
    -- Filtered egg list
    local function createFilteredEggList()
        -- Clear existing filtered eggs
        for _, child in ipairs(ep:GetChildren()) do
            if child:GetAttribute("FilteredEgg") then
                child:Destroy()
            end
        end
        
        -- Add filtered eggs
        for _, e in ipairs(EGG_LIST) do
            if eggSearchQuery == "" or string.find(string.lower(e[1]), eggSearchQuery, 1, true) then
                local row = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = C.Card,
                    BorderSizePixel = 0,
                    LayoutOrder = nextOrder(),
                }, ep)
                corner(row, 8)
                row:SetAttribute("FilteredEgg", true)
                
                local b = btn(row, "", C.Row, 28)
                b.Size = UDim2.new(1, -10, 0, 28)
                b.Position = UDim2.fromOffset(5, 1)
                b.Font = Enum.Font.Gotham
                b.TextSize = 11
                b.TextXAlignment = Enum.TextXAlignment.Left
                make("UIPadding", {PaddingLeft = UDim.new(0, 8)}, b)
                
                local key = string.lower(e[1])
                table.insert(paints, function()
                    local on = selOn(eggSel, key)
                    b.Text = (on and "●  " or "○  ") .. e[1] .. "   |   Luck " .. e[2]
                    b.BackgroundColor3 = on and C.AccentDark or C.Row
                    b.TextColor3 = on and C.Text or C.Muted
                end)
                
                b.MouseButton1Click:Connect(function()
                    eggSel[key] = not selOn(eggSel, key)
                    refresh()
                end)
            end
        end
    end
    
    -- Buttons
    local btnFrame = make("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, ep)
    local allBtn = btn(btnFrame, "Pilih Semua", C.AccentDark, 34)
    allBtn.Size = UDim2.new(0.5, -4, 1, 0)
    allBtn.TextColor3 = C.Text
    
    local noneBtn = btn(btnFrame, "Kosongkan", C.Row, 34)
    noneBtn.Size = UDim2.new(0.5, -4, 1, 0)
    noneBtn.Position = UDim2.new(0.5, 4, 0, 0)
    noneBtn.TextColor3 = C.Muted
    
    allBtn.MouseButton1Click:Connect(function()
        for _, e in ipairs(EGG_LIST) do
            eggSel[string.lower(e[1])] = true
        end
        refresh()
    end)
    
    noneBtn.MouseButton1Click:Connect(function()
        for _, e in ipairs(EGG_LIST) do
            eggSel[string.lower(e[1])] = false
        end
        refresh()
    end)
    
    -- Min Rank button
    local minFrame = make("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, ep)
    local minBtn = btn(minFrame, "", C.Row, 34)
    minBtn.Size = UDim2.new(1, 0, 1, 0)
    minBtn.TextColor3 = C.Accent
    
    minBtn.MouseButton1Click:Connect(function()
        minIdx = minIdx % #MIN_STEPS + 1
        CFG.MinRank = MIN_STEPS[minIdx][2]
        refresh()
    end)
    
    table.insert(paints, function()
        minBtn.Text = "Min Rank: " .. MIN_STEPS[minIdx][1]
    end)
    
    -- Initial filtered list
    createFilteredEggList()
    
    -- ===== AUTO TAB =====
    section(ap, "Auto Inventory")
    note(ap, "Saat egg di tangan, script menekan Put To Inventory.")
    switch(ap, "Auto Inventory", "AutoInv")
    stepper(ap, "Cooldown (detik)", "InvCd", 0.5, 0.5, 10)
    stepper(ap, "Gagal sebelum pindah", "InvTries", 1, 1, 10)
    
    section(ap, "Auto Place")
    note(ap, "Dipakai jika Auto Inventory mati.")
    switch(ap, "Auto Place", "AutoPlace")
    switch(ap, "Balik ke safe zone", "PlaceReturn")
    stepper(ap, "Cooldown place (detik)", "MachineCd", 0.5, 0.5, 10)
    
    section(ap, "Auto Hatch")
    note(ap, "Saat tidak memegang egg, teleport ke mesin hatch.")
    switch(ap, "Auto Hatch", "AutoHatch")
    stepper(ap, "Cooldown hatch (detik)", "HatchCd", 0.5, 0.5, 30)
    
    -- ===== ESP TAB =====
    section(esp, "Egg ESP")
    note(esp, "Menandai egg dengan nama dan jarak.")
    switch(esp, "Egg ESP", "EggESP")
    
    section(esp, "X-Ray")
    note(esp, "Menampilkan luck egg di air.")
    switch(esp, "X-Ray Egg", "XRay")
    
    section(esp, "Filter ESP")
    eggList(esp, espSel, false)
    
    -- ===== GRAFIK TAB =====
    section(gp, "Low Graphics")
    note(gp, "Optimasi grafis untuk performa lebih baik.")
    switch(gp, "Low Graphics", "LowGraphics", function(on)
        lowSet(on)
    end)
    
    local reapply = btn(gp, "Terapkan ulang", C.Row, 34)
    reapply.LayoutOrder = nextOrder()
    reapply.TextColor3 = C.Accent
    reapply.MouseButton1Click:Connect(function()
        if low.on then
            low.seen = {}
            lowSweep()
            S.status = "Low Graphics diterapkan ulang"
        end
        refresh()
    end)
    
    local lowInfo = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),
    }, gp)
    table.insert(paints, function()
        lowInfo.Text = string.format("Objek: %d | Error: %d | Antrian: %d", S.low, S.lowErr, #low.queue)
    end)
    
    -- ===== KOMUNITAS TAB =====
    section(dp, "Discord")
    note(dp, "Info, update script, dan saran fitur.")
    
    local discordCopy = btn(dp, "Salin link Discord", C.AccentDark, 36)
    discordCopy.LayoutOrder = nextOrder()
    discordCopy.TextColor3 = C.Text
    discordCopy.MouseButton1Click:Connect(function()
        local ok = copyLink(DISCORD)
        notify(ok and "Link Discord disalin" or DISCORD)
    end)
    note(dp, DISCORD)
    
    section(dp, "WhatsApp")
    note(dp, "Saluran WhatsApp untuk update terbaru.")
    
    local waCopy = btn(dp, "Salin link WhatsApp", C.AccentDark, 36)
    waCopy.LayoutOrder = nextOrder()
    waCopy.TextColor3 = C.Text
    waCopy.MouseButton1Click:Connect(function()
        local ok = copyLink(WHATSAPP)
        notify(ok and "Link WhatsApp disalin" or WHATSAPP)
    end)
    note(dp, WHATSAPP)
    
    -- Status bar updates
    table.insert(paints, function()
        subtitle.Text = string.format("Steal %d | Inv %d | Place %d | Hatch %d", S.steal, S.inv, S.place, S.hatch)
        statusLbl.Text = string.format("%s | Egg: %d | Config: %s", S.status, S.detectedEggs, S.config)
    end)
    
    -- Logo button (minimized)
    local logo = make("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(52, 52),
        BackgroundColor3 = C.Ink, BorderSizePixel = 0, AutoButtonColor = false, Visible = false,
        Text = "", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 22, ZIndex = 5,
    }, gui)
    corner(logo, 26)
    make("UIStroke", {Color = C.Accent, Thickness = 2}, logo)
    
    -- Create logo inside button
    local logoInner = createLogo(logo, 44)
    logoInner.Position = UDim2.new(0.5, -22, 0.5, -22)
    
    uiRefs.logo = logo
    
    local function setMenu(open)
        main.Visible = open
        logo.Visible = not open
        applyLayout()
    end
    uiRefs.setMenu = setMenu
    
    local function setPage(name)
        for key, p in pairs(pages) do
            p.Visible = key == name
        end
        for key, b in pairs(tabs) do
            local active = key == name
            b.BackgroundColor3 = active and C.AccentDark or C.Card
            b.TextColor3 = active and C.Text or C.Muted
        end
    end
    
    for key, b in pairs(tabs) do
        b.MouseButton1Click:Connect(function()
            setPage(key)
        end)
    end
    minBtn.MouseButton1Click:Connect(function()
        setMenu(false)
    end)
    
    drag(logo,
        function() return layout.logo end,
        function(x, y)
            layout.logo = Vector2.new(x, y)
            applyLayout()
        end,
        function() setMenu(true) end)
    
    drag(header,
        function() return layout.main end,
        function(x, y)
            layout.main = Vector2.new(x, y)
            applyLayout()
        end)
    
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(applyLayout)
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout)
    end
    
    setPage("main")
    refresh()
    applyLayout()
end

-- ===== INITIALIZATION =====
for _, e in ipairs(EGG_LIST) do
    local key = string.lower(e[1])
    if eggSel[key] == nil then
        eggSel[key] = true
    end
    if espSel[key] == nil then
        espSel[key] = true
    end
end

loadConfig()
local okUI, errUI = pcall(buildUI)
if not okUI then
    warn("kayeshiHUB menu: " .. tostring(errUI))
    notify("Menu gagal: " .. string.sub(tostring(errUI), 1, 150))
end

-- Show welcome popup
task.wait(1)
showWelcomePopup()

UIS.InputBegan:Connect(function(input, gameProcessed)
    lastActive = os.clock()
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.F then
        CFG.AutoSteal = not CFG.AutoSteal
        S.status = CFG.AutoSteal and "Auto steal nyala" or "Auto steal mati"
        refresh()
    elseif input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightShift then
        if uiRefs.setMenu then
            uiRefs.setMenu(not uiRefs.main.Visible)
        end
    end
end)

if CFG.LowGraphics then
    lowSet(true)
end

if player.Character then
    task.spawn(captureBase, player.Character)
end
player.CharacterAdded:Connect(captureBase)

task.spawn(function()
    local ch = player.Character or player.CharacterAdded:Wait()
    local r = ch:WaitForChild("HumanoidRootPart", 10)
    if r and not zone then
        zone = r.Position
        S.status = "Safe zone otomatis di posisi awal"
    end
end)

player.Idled:Connect(function()
    if CFG.AntiAFK then
        antiAfkClick()
        antiAfkJump()
    end
end)

local function loop(name, interval, fn)
    task.spawn(function()
        while true do
            local ok, err = pcall(fn)
            if not ok then
                S.errors += 1
                S.status = name .. ": " .. string.sub(tostring(err), 1, 60)
                warn("kayeshiHUB " .. name .. ": " .. tostring(err))
                task.wait(0.5)
            end
            task.wait(interval)
        end
    end)
end

loop("utama", 0.12, mainTick)
loop("visual", 0.5, function()
    if CFG.EggESP or CFG.XRay then
        applyVisuals(collectVisuals())
    elseif next(visuals) then
        clearVisuals()
    end
end)
loop("grafik", 0.05, function()
    if low.on then
        lowPump()
    end
end)
loop("stream", 4, function()
    local r = getRoot()
    if r then
        streamAround(r.Position)
    end
end)
loop("gerak", 0.25, applyMove)
loop("afk", 1, function()
    if CFG.AntiAFK and os.clock() - lastActive >= CFG.AfkIdle then
        lastActive = os.clock()
        antiAfkJump()
        S.status = "Anti AFK: lompat setelah diam"
    end
end)
loop("autosave", 3, function()
    if CFG.AutoSave then
        saveConfig(false)
    end
end)
loop("ui", 0.4, refresh)

notify("kayeshiHUB v2.1 aktif. K = menu, F = auto steal.")
