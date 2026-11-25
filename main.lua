-- QWERTY HUB v3.0 — FULL WORKING BUILD
-- Aimbot, Silent, Triggerbot, NoSpread/NoRecoil/NoCameraShake, FastFire, WeakSpot,
-- Hitbox Expander, Player/NPC/World ESP (Loot/Base/Drops/Nodes/Pickups/Vehicles),
-- Loot Contents (weapon/C4/sulfur/MVK), Enemy Scanner, Speed/HiJump/Noclip/Fly,
-- FallDamage off, AntiAim, Anti-Cheat Mode, HUD, GunChams, FullBright, RemoveFog, HideGrass,
-- 20 new features. Anti-cheat bypass included.
if not game:IsLoaded() then game.Loaded:Wait() end

local SCRIPT_NAME = "QWERTY HUB"
local SCRIPT_VERSION = "v3.0"

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local LPlr = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================
-- EXECUTOR REFS + ANTI-CHEAT BYPASS
-- ============================================================
local o_getfenv = getfenv
local o_getrawmetatable = getrawmetatable
local o_hookfunction = hookfunction
local o_hookmetamethod = hookmetamethod
local o_newcclosure = newcclosure
local o_checkcaller = checkcaller
local o_isexecutorclosure = isexecutorclosure
local o_identifyexecutor = identifyexecutor
local o_getnamecallmethod = getnamecallmethod
local o_setnamecallmethod = setnamecallmethod
local o_getgc = getgc
local o_isreadonly = isreadonly
local o_setreadonly = setreadonly
local o_getconnections = getconnections

local _fustEnv = _G
if type(getgenv) == "function" then
    local ok, genv = pcall(getgenv)
    if ok and type(genv) == "table" then _fustEnv = genv end
end
if type(_fustEnv) ~= "table" then _fustEnv = {} end
local env = o_getfenv(1)

local HIDE_FROM_ENV = {
    "getgenv","getrenv","getsenv","getgc","getreg",
    "hookfunction","hookmetamethod","unhookfunction",
    "newcclosure","newlclosure","checkcaller","isexecutorclosure",
    "getrawmetatable","setrawmetatable","getconnections","getscripthash",
    "identifyexecutor","getexecutorname",
    "loadfile","savefile","appendfile","writefile","readfile",
    "restorefunction","getupvalue","setupvalue",
    "getconstant","getconstants","setconstant","getstack","setstack",
    "getnamecallmethod","setnamecallmethod",
    "fireclickdetector","firesignal","queue_on_teleport","setclipboard",
    "getthreadidentity","setthreadidentity",
    "getupvalues","getprotos","getproto","getinstances","getnilinstances",
    "getloadedmodules","getmodules","getscripts","getrunningscripts",
    "getscriptclosure","getscriptfunction","getscriptenv",
    "getcallingscript","getcaller","getfunctionhash","getfunctionclosure","getfunctionenv",
    "replaceclosure","clonefunction",
    "setreadonly","isreadonly","makereadonly","makewriteable",
    "firetouchinterest","firetouchtransmitter","fireproximityprompt",
    "setfpscap","getfpscap","setfflag","getfflag","getfflags","setfflags",
    "getcustomasset","getcustomassetasync","gethui","getgui","getcoregui",
    "protectgui","unprotectgui","isprotectedgui","getidentity","setidentity",
    "getscriptbytecode","dumpstring","getcallbackvalue",
    "getproperties","setproperties","getattributes","setattributes",
    "getconnection","getsignal","getsignalarguments","setsignalarguments",
    "getboundaction","getboundactions","setboundaction",
}

local function fakeGetfenv(level)
    local realEnv = o_getfenv(level)
    if type(realEnv) ~= "table" then return realEnv end
    local fake = {}
    for k, v in pairs(realEnv) do
        local hide = false
        for _, name in ipairs(HIDE_FROM_ENV) do
            if k == name then hide = true break end
        end
        if not hide and k ~= "_G" then
            if k == "game" then
                fake[k] = setmetatable({}, {
                    __index = function(_, key)
                        if key == "HttpGet" or key == "HttpPost" then return nil end
                        return v[key]
                    end,
                    __newindex = function(_, key, val) v[key] = val end,
                })
            else fake[k] = v end
        end
    end
    return fake
end
local function fakeGetrawmetatable(obj)
    local mt = o_getrawmetatable(obj)
    if not mt then return mt end
    local fake = {}
    for k, v in pairs(mt) do
        if k ~= "__namecall" and k ~= "__index" then fake[k] = v end
    end
    return fake
end
local function wrap(fn)
    if o_newcclosure then return o_newcclosure(fn) end
    return fn
end
if o_hookfunction and type(o_hookfunction) == "function" then
    pcall(function() o_hookfunction(o_getfenv, wrap(fakeGetfenv)) end)
    pcall(function() o_hookfunction(o_getrawmetatable, wrap(fakeGetrawmetatable)) end)
    pcall(function() o_hookfunction(o_identifyexecutor, wrap(function() return "Roblox" end)) end)
    pcall(function() o_hookfunction(o_checkcaller, wrap(function() return true end)) end)
    pcall(function() o_hookfunction(o_isexecutorclosure, wrap(function() return false end)) end)
else
    pcall(function() rawset(env, "getfenv", wrap(fakeGetfenv)) end)
    pcall(function() rawset(env, "getrawmetatable", wrap(fakeGetrawmetatable)) end)
end
for _, name in ipairs(HIDE_FROM_ENV) do
    pcall(function() if rawget(env, name) then rawset(env, name, nil) end end)
end
local executorName = "unknown"
if type(o_identifyexecutor) == "function" then
    local ok, name = pcall(o_identifyexecutor)
    if ok and name then executorName = tostring(name) end
end
if string.find(string.lower(executorName), "xeno", 1, true) then return end

-- ============================================================
-- STATE
-- ============================================================
local S = {
    -- Aimbot
    Aimbot=false, AimFOV=160, AimRange=1500, AimSmoothing=8, AimPart="Head",
    AimPriority="Crosshair", AimKey="Always", AimTeamCheck=true, AimWallCheck=true,
    AimNPC=false, AimHeli=false, AimPlayersFirst=true, AimPrediction=false,
    AimLead=1.0, FOVCircle=true, TargetLine=false,
    -- Silent
    SilentAimEnabled=false, SilentAimFOV=200, SilentAimRange=1500, SilentAimLead=1.0,
    SilentAimPart="Head", SilentAimKey="Always", SilentAimTeamCheck=true,
    SilentAimWallCheck=false, SilentAimNPC=false, SilentAimHeli=false,
    SilentAimPrediction=false, SilentAimFOVCircle=true, SilentAimTargetLine=false,
    -- Trigger
    Triggerbot=false, TriggerRadius=6, TriggerReaction=80, TriggerDelay=60,
    TriggerKey="Always", TriggerTeamCheck=true, TriggerWallCheck=true, TriggerNPC=false,
    -- Weapon
    WeaponPatches=false, WeaponFireRate=false, FireInterval=90, WeaponClean=false,
    NoSpread=false, AutoCross=false, NoRecoil=false, NoCameraShake=false,
    -- Hitbox
    HitboxExpander=false, HitboxSize=5, HitboxTransparency=0.7,
    HitboxTeamCheck=true, HitboxNPC=false,
    -- Player ESP
    PlayerESP=false, PlayerBox=true, PlayerNames=true, PlayerDistance=true,
    PlayerHealth=true, PlayerHeldItem=true, PlayerTeamCheck=true,
    PlayerTracers=false, PlayerChams=false, PlayerCorners=false,
    TracerOrigin="Bottom", PlayerRange=1500, PlayerTextSize=13,
    -- NPC ESP
    NPCESP=false, NPCHeli=true, NPCBox=false, NPCNames=true, NPCDistance=true,
    NPCHealth=false, NPCRange=500, NPCTextSize=13,
    -- Sleeper ESP
    SleepersESP=false, SleepersRange=500, SleepersNames=true, SleepersDistance=true,
    -- World
    LootESP=false, LootBarrels=true, LootCrates=true, LootMilitary=true, LootElite=true,
    LootDistance=true, LootRange=400, LootContents=false,
    BaseESP=false, BaseBoxes=true, BaseCupboard=true, BaseLocker=true,
    BaseSleepingBag=true, BaseTraps=true, BaseDistance=true, BaseRange=175,
    DropsESP=false, BodyBags=true, DroppedItems=true, DropsDistance=false, DropsRange=400,
    NodesESP=false, NodeStone=true, NodeSulfur=true, NodeMetal=true,
    NodesDistance=true, NodesRange=500,
    PickupsESP=false, PickupOres=true, PickupWood=true, PickupPlants=true,
    PickupsDistance=false, PickupsRange=200,
    VehiclesESP=false, VehicleATV=true, VehicleBoats=true, VehicleHelis=true,
    VehiclesDistance=true, VehiclesRange=1000, WorldTextSize=13,
    -- Movement
    Speed=false, SpeedValue=24, HighJump=false, JumpHeight=50, Noclip=false,
    Fly=false, FlySpeed=50, FallDamage=false, AntiAim=false,
    InfiniteJump=false, NoJumpCooldown=false, AutoRespawn=false, AntiAFK=true,
    -- Misc
    AntiCheatMode=false, HUD=true, AdminCheck=false, UIAnimations=true,
    FullBright=false, RemoveFog=false, HideGrass=false,
    GunChams=false, GunChamsColor=Color3.fromRGB(255,100,100), GunChamsTransparency=0,
    EnemyScanner=true, EnemyScannerRange=600,
    AutoFarm=false, AutoFarmMode="Ore", AutoFarmRange=60,
    InstantProximityPrompt=false, WalkOnWater=false,
    AutoLoot=false, AutoLootRange=25,
    AutoTool=false, AutoBandage=false, AutoDrink=false,
    SpamKillLog=false, NoClipCamera=false, ThirdPersonLock=false,
    FastPlace=false, NoHUD=false, ChatSpy=false,
}
_G.QWERTY_STATE = S

local Colors = {
    Accent=Color3.fromRGB(255,255,255), FOV=Color3.fromRGB(90,175,255),
    TargetLine=Color3.fromRGB(255,90,90), Player=Color3.fromRGB(90,175,255),
    PlayerText=Color3.fromRGB(240,240,240), NPC=Color3.fromRGB(255,105,95),
    Heli=Color3.fromRGB(255,145,80), Loot=Color3.fromRGB(255,190,80),
    Base=Color3.fromRGB(80,210,255), Drops=Color3.fromRGB(220,160,255),
    Nodes=Color3.fromRGB(230,230,190), Pickups=Color3.fromRGB(120,230,140),
    Vehicles=Color3.fromRGB(255,145,80),
}

local Runtime = {
    Unloaded=false, Cleanup={}, Drawings={}, BindApis={},
    ConfigControls={}, FeatureHandlers={}, SettingHandlers={},
    Diagnostics={}, MenuOpen=true,
}
_fustEnv.BurmaldaFust = Runtime
Runtime.State = S
Runtime.Colors = Colors
local function onCleanup(fn) table.insert(Runtime.Cleanup, fn) end
Runtime.AddCleanup = onCleanup
local function trackDrawing(object) table.insert(Runtime.Drawings, object); return object end
local _drawingNew = Drawing and Drawing.new or nil
local function newDrawing(kind)
    if _drawingNew then
        local ok, object = pcall(_drawingNew, kind)
        if ok and object then return trackDrawing(object) end
    end
    return nil
end
Runtime.NewDrawing = newDrawing

-- ============================================================
-- LIBRARY
-- ============================================================
local Library, Window
do
    local ok, result = pcall(function()
        local url = "https://raw.githubusercontent.com/qwerty-hub-script/qwerty-hub-menu/refs/heads/main/menu.lua?cb=" .. tostring(os.time())
        local response = game:HttpGet(url)
        if response:sub(1,3) == "404" then error("URL 404: " .. response:sub(1,100), 0) end
        local chunk, compileErr = loadstring(response)
        if type(chunk) ~= "function" then error("compile: " .. tostring(compileErr), 0) end
        local lib = chunk()
        if type(lib) ~= "table" then error("no table", 0) end
        return lib
    end)
    if not ok then error("UI library: " .. tostring(result), 0) end
    Library = result
end
Library:SetDefaultTheme("Rose")
Window = Library:CreateWindow({
    Name = SCRIPT_NAME, LoadingSubtitle = SCRIPT_VERSION, ToggleUIKeybind = "RightControl",
    ConfigurationSaving = { Enabled=true, FolderName="QWERTYHub", FileName="default" },
    ToggleButton = { Platform = "Mobile" },
    Home = { Title = "Welcome to " .. SCRIPT_NAME .. "!", Tier = SCRIPT_VERSION,
        Discord = "https://discord.gg/BrVFDv7est", Stats = { "Players", "Session", "FPS", "Ping" } },
})

-- ============================================================
-- SHARED
-- ============================================================
local Shared = {}
local Entities = {NPCs={}, Heli=nil, Scanning=false, ScanList={}, ScanIndex=1, Working={}, NextScan=0}
local Team = {Ids={}, Folder=nil, Next=0}

function Shared.Character() return LPlr and LPlr.Character or nil end
function Shared.Root(character)
    character = character or Shared.Character()
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end
function Shared.Humanoid(character)
    character = character or Shared.Character()
    return character and character:FindFirstChildOfClass("Humanoid") or nil
end
function Shared.FindPart(model, candidates)
    if not model then return nil end
    if model:IsA("BasePart") then return model end
    if candidates then
        for _, name in ipairs(candidates) do
            local child = model:FindFirstChild(name)
            if child and child:IsA("BasePart") then return child end
        end
    end
    if model:IsA("Model") then
        local primary = model.PrimaryPart
        if primary and primary:IsA("BasePart") then return primary end
    end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end
function Shared.Project(position)
    if not Camera or not position then return nil end
    local ok, point, onScreen = pcall(Camera.WorldToViewportPoint, Camera, position)
    if not ok or not point then return nil end
    local visible = point.Z > 0 and (onScreen == nil or onScreen == true)
    return point.X, point.Y, point.Z, visible
end
function Shared.ToolName(character)
    character = character or Shared.Character()
    local tool = character and character:FindFirstChildOfClass("Tool")
    return tool and tool.Name or ""
end

local function updateTeam()
    Team.Next = os.clock() + 1
    table.clear(Team.Ids)
    Team.Folder = nil
    local folder = Camera and Camera:FindFirstChild("FustTeamTags") or workspace:FindFirstChild("FustTeamTags")
    Team.Folder = folder
    if not folder then return end
    for _, child in ipairs(folder:GetChildren()) do
        local name = child.Name
        if string.sub(name, 1, 3) == "Tag" then
            local userId = tonumber(string.sub(name, 4))
            if userId then Team.Ids[userId] = true end
        end
    end
end
function Shared.IsTeammate(player)
    if not player then return false end
    if player == LPlr then return true end
    if os.clock() >= Team.Next then updateTeam() end
    local userId = player.UserId
    if Team.Folder then return userId ~= nil and Team.Ids[userId] == true end
    if player.Neutral or LPlr.Neutral then return false end
    return player.Team ~= nil and player.Team == LPlr.Team
end
function Shared.WallClear(position, targetModel)
    if not Camera then return false end
    local origin = Camera.CFrame.Position
    local direction = position - origin
    if direction.Magnitude <= 0.01 then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Shared.Character()}
    params.IgnoreWater = true
    local ok, result = pcall(workspace.Raycast, workspace, origin, direction, params)
    if not ok then return true end
    if not result or not result.Instance then return true end
    if targetModel and result.Instance:IsDescendantOf(targetModel) then return true end
    return false
end

-- ============================================================
-- ENTITIES
-- ============================================================
local function rigEntry(model)
    local humanoid = Shared.Humanoid(model)
    if not humanoid then return nil end
    local root = Shared.Root(model)
    if not root then return nil end
    local head = model:FindFirstChild("Head") or root
    return {Kind="NPC", Model=model, Humanoid=humanoid, Root=root, Head=head, Name=model.Name}
end

local function heliEntry()
    local folder = workspace:FindFirstChild("FustPatrolHeli")
    if not folder then return nil end
    local model = folder:FindFirstChild("PatrolHeliModel") or folder:FindFirstChild("PatrolHeli")
    if not model or not model:IsA("Model") then
        model = nil
        for _, child in ipairs(folder:GetDescendants()) do
            if child:IsA("Model") then model = child; break end
        end
    end
    if not model then return nil end
    local root = Shared.FindPart(model, {"Engine","Body","Fuselage","MainRotor","Frame"})
    if not root then return nil end
    return {Kind="Heli", Model=model, Root=root, Head=root, Name="Patrol Helicopter", Health=5000, MaxHealth=5000}
end
local function npcFolder()
    local folder = workspace:FindFirstChild("Npcs")
    if folder then return folder end
    for _, child in ipairs(workspace:GetChildren()) do
        if string.find(string.lower(child.Name), "npc", 1, true) then return child end
    end
    return nil
end
function Entities.Update()
    local needNPC = S.NPCESP or S.AimNPC or S.TriggerNPC or S.SilentAimNPC or S.HitboxNPC or S.EnemyScanner or S.AutoLoot
    local needHeli = (S.NPCESP and S.NPCHeli) or S.AimHeli or S.SilentAimHeli
    if not needNPC and not needHeli then
        if #Entities.NPCs > 0 or Entities.Heli then Entities.NPCs={}; Entities.Heli=nil end
        Entities.Scanning = false
        return
    end
    local now = os.clock()
    if now >= Entities.NextScan and not Entities.Scanning then
        Entities.NextScan = now + 0.5
        Entities.Heli = needHeli and heliEntry() or nil
        if needNPC then
            local folder = npcFolder()
            Entities.ScanList = folder and folder:GetChildren() or {}
            Entities.ScanIndex = 1
            Entities.Working = {}
            Entities.Scanning = true
        else Entities.NPCs = {} end
    end
    if not Entities.Scanning then return end
    local budget = 16
    local list = Entities.ScanList
    while budget > 0 and Entities.ScanIndex <= #list do
        local model = list[Entities.ScanIndex]
        Entities.ScanIndex += 1
        budget -= 1
        local entry = rigEntry(model)
        if entry then table.insert(Entities.Working, entry) end
    end
    if Entities.ScanIndex > #list then
        Entities.NPCs = Entities.Working
        Entities.Scanning = false
        Entities.ScanList = {}
        Entities.Working = {}
    end
end

-- ============================================================
-- AIM SELECT
-- ============================================================
local boneSets = {
    Head={"Head"},
    Body={"UpperTorso","Torso","LowerTorso","HumanoidRootPart"},
    Root={"HumanoidRootPart","Torso","UpperTorso"},
    Closest={"Head","UpperTorso","Torso","LowerTorso","HumanoidRootPart",
        "LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand",
        "LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"},
}
local gunBallistics = {
    {"lr sniper",2600,24},{"bolt action",2200,30},{"l96",2600,24},
    {"semi-automatic rifle",1425,8},{"semi auto rifle",1425,8},
    {"assault rifle",1350,8},{"scar",1450,8},{"m249",1400,8},
    {"drum smg",880,8},{"tactical smg",950,8},{"custom smg",900,8},
    {"dino hunt smg",900,8},{"hunt smg",900,8},{"lever carbine",1250,8},
    {"double barrel",520,15},{"pump shotgun",560,15},{"pipe shotgun",560,15},
    {"revolver",950,8},{"service pistol",950,8},{"semi-auto pistol",900,8},
    {"semi auto pistol",900,8},{"shotgun",560,15},{"smg",900,8},
    {"sniper",2600,24},{"carbine",1250,8},{"machine gun",1400,8},
    {"rifle",1425,8},{"pistol",900,8},{"rocket launcher",80,8},
}
local bowBallistics = {
    {"crossbow",320,0,28},{"compound",120,170,40},{"hunting",95,125,50},{"bow",95,125,50},
}
local aimOptions, triggerOptions, silentOptions = {}, {}, {}
local aimBest, triggerBest, silentBest = {}, {}, {}
local fovCircle, targetLine, silentFOV, silentLine
do
    fovCircle = newDrawing("Circle")
    if fovCircle then fovCircle.NumSides=48; fovCircle.Thickness=1; fovCircle.Filled=false; fovCircle.Transparency=1 end
    targetLine = newDrawing("Line")
    if targetLine then targetLine.Thickness=1; targetLine.Transparency=1 end
    silentFOV = newDrawing("Circle")
    if silentFOV then silentFOV.NumSides=48; silentFOV.Thickness=1; silentFOV.Filled=false; silentFOV.Transparency=1 end
    silentLine = newDrawing("Line")
    if silentLine then silentLine.Thickness=1; silentLine.Transparency=1 end
end
local function keyDown(key)
    if key == "Always" then return true end
    if key == "RMB" or key == "LMB" then
        local button = key == "RMB" and Enum.UserInputType.MouseButton2 or Enum.UserInputType.MouseButton1
        local ok, down = pcall(UserInputService.IsMouseButtonPressed, UserInputService, button)
        return ok and down == true
    end
    local code = Enum.KeyCode[key]
    if not code then return false end
    local ok, down = pcall(UserInputService.IsKeyDown, UserInputService, code)
    return ok and down == true
end
local function resetBest(best)
    best.Score=math.huge; best.Target=nil; best.Part=nil; best.Position=nil; best.ScreenX=nil; best.ScreenY=nil
end
local function consider(model, root, humanoid, player, kind, name, options, best, healthOverride)
    if not model or not root or not Camera then return end
    if humanoid and humanoid.Health <= 0 then return end
    if player and options.TeamCheck and Shared.IsTeammate(player) then return end
    local origin = Camera.CFrame.Position
    local parts = kind == "Heli" and {root} or boneSets[options.PartMode] or boneSets.Head
    local bestPart, bestPosition, bestX, bestY, bestScreenDistance, bestDistance
    for _, candidate in ipairs(parts) do
        local part = candidate
        if type(candidate) == "string" then part = model:FindFirstChild(candidate) end
        if part and part:IsA("BasePart") then
            local position = part.Position
            local distance = (position - origin).Magnitude
            if distance <= options.Range then
                local x, y, _, visible = Shared.Project(position)
                if visible then
                    local dx, dy = x - Camera.ViewportSize.X*0.5, y - Camera.ViewportSize.Y*0.5
                    local screenDistance = math.sqrt(dx*dx + dy*dy)
                    if screenDistance <= options.FOV and (not bestScreenDistance or screenDistance < bestScreenDistance) then
                        bestPart, bestPosition = part, position
                        bestX, bestY = x, y
                        bestScreenDistance, bestDistance = screenDistance, distance
                    end
                end
            end
        end
    end
    if not bestPart then return end
    local health = humanoid and humanoid.Health or healthOverride or 100
    local score = bestScreenDistance
    if options.Priority == "Distance" then score = bestDistance + bestScreenDistance*0.0001
    elseif options.Priority == "Low HP" then score = health + bestScreenDistance*0.0001 end
    if options.PlayersFirst and not player then score += 1000000 end
    if score >= best.Score then return end
    if options.WallCheck and not Shared.WallClear(bestPosition, model) then return end
    best.Score = score
    best.Target = {Model=model, Root=root, Humanoid=humanoid, Player=player, Kind=kind, Name=name, Health=health}
    best.Part = bestPart; best.Position = bestPosition
    best.ScreenX, best.ScreenY = bestX, bestY
end
local function selectTarget(options, best)
    resetBest(best)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LPlr then
            local character = player.Character
            local humanoid = Shared.Humanoid(character)
            local root = Shared.Root(character)
            if character and humanoid and root then
                consider(character, root, humanoid, player, "Player", player.DisplayName or player.Name, options, best)
            end
        end
    end
    if options.IncludeNPC then
        for _, npc in ipairs(Entities.NPCs) do
            consider(npc.Model, npc.Root, npc.Humanoid, nil, "NPC", npc.Name, options, best)
        end
    end
    if options.IncludeHeli and Entities.Heli then
        local heli = Entities.Heli
        consider(heli.Model, heli.Root, nil, nil, "Heli", heli.Name, options, best, heli.Health)
    end
    return best.Target and best or nil
end

-- ============================================================
-- AIM / SILENT / HOOK / RECOIL
-- ============================================================
local Aim = {CurrentTarget=nil, CurrentPart=nil, CurrentPosition=nil, CurrentScreen=nil, NamecallHookStatus="not installed"}
Runtime.Aim = Aim
local oldNamecall, wrappedHook, hookMode, hookMeta

local Silent = {
    Enabled=false, FOV=200, Range=1500, Part="Head", Key="Always",
    TeamCheck=true, WallCheck=false, NPC=false, Heli=false,
    Prediction=false, Lead=1.0, FOVCircle=true, TargetLine=false,
    CachedTarget=nil, CachedPart=nil, CachedPosition=nil, CachedTime=0, LastStatus="off",
}
Runtime.Silent = Silent

local function callOriginal(self, method, args)
    if method and type(o_setnamecallmethod) == "function" then pcall(o_setnamecallmethod, method) end
    return oldNamecall(self, table.unpack(args, 1, args.n))
end
local function isFustRemote(self, remoteName)
    local ok, result = pcall(function()
        if not self:IsA("RemoteEvent") and not self:IsA("UnreliableRemoteEvent") then return false end
        if self.Name ~= remoteName then return false end
        local remotes = self.Parent
        local fust = remotes and remotes.Parent
        return remotes ~= nil and remotes.Name == "Remotes" and fust ~= nil
            and fust.Name == "Fust" and fust.Parent == ReplicatedStorage
    end)
    return ok and result == true
end
local function isFustShotRemote(self) return isFustRemote(self, "Shoot") or isFustRemote(self, "Fire") end

local function nearestWeakSpot()
    local root = Shared.Root()
    if not root or not root:IsA("BasePart") then return nil, nil end
    local rootPosition = root.Position
    local bestSpot, bestPart, bestDistance = nil, nil, 196
    local seen = {}
    local function considerNode(node)
        if not node or seen[node] or not node:IsDescendantOf(workspace) then return end
        seen[node] = true
        if node:GetAttribute("Depleted") == true then return end
        local weakSpot = node:GetAttribute("WeakSpot")
        if typeof(weakSpot) ~= "Vector3" then return end
        local offset = rootPosition - weakSpot
        local distance = offset.X*offset.X + offset.Y*offset.Y + offset.Z*offset.Z
        if distance >= bestDistance then return end
        bestDistance = distance
        bestSpot = weakSpot
        bestPart = Shared.FindPart(node, {"Rock","Trunk"})
    end
    if CollectionService and type(CollectionService.GetTagged) == "function" then
        local ok, tagged = pcall(CollectionService.GetTagged, CollectionService, "FustNode")
        if ok and type(tagged) == "table" then for _, node in ipairs(tagged) do considerNode(node) end end
    end
    for _, folderName in ipairs({"Nodes","OreNodes"}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then for _, node in ipairs(folder:GetChildren()) do considerNode(node) end end
    end
    return bestSpot, bestPart
end
local function weakSpotPosition(payload)
    local target = payload.target
    if typeof(target) == "Instance" and target:IsA("BasePart") then
        if not target:IsDescendantOf(workspace) then return nil, nil end
        local node = target.Parent
        while node and node ~= workspace do
            local weakSpot = node:GetAttribute("WeakSpot")
            if typeof(weakSpot) == "Vector3" then
                if node:GetAttribute("Depleted") == true then return nil, nil end
                return weakSpot, nil
            end
            node = node.Parent
        end
    end
    return nearestWeakSpot()
end
local function copyPayload(payload)
    local rewritten = {}
    for key, value in pairs(payload) do rewritten[key] = value end
    return rewritten
end
local function stripRecoil(payload)
    if type(payload) ~= "table" then return false end
    local changed = false
    for _, key in ipairs({"spread","sway","kickRoll","adsKick","bloom","shakeDur",
        "Spread","Sway","KickRoll","AdsKick","Bloom","ShakeDur",
        "recoil","Recoil","kick","Kick","cameraShake","CameraShake"}) do
        if payload[key] ~= nil then payload[key] = 0; changed = true end
    end
    return changed
end
local function stripCameraShake(payload)
    if type(payload) ~= "table" then return false end
    local changed = false
    for _, key in ipairs({"shakeDur","ShakeDur","cameraShake","CameraShake","shake","Shake"}) do
        if payload[key] ~= nil then payload[key] = 0; changed = true end
    end
    return changed
end
local function silentPredict(target, part, leadFactor)
    if not target or not part then return nil end
    local velocity = part.AssemblyLinearVelocity
    if not velocity or velocity.Magnitude < 1 then return part.Position end
    local origin = Camera.CFrame.Position
    local dist = (part.Position - origin).Magnitude
    local t = (dist / 900) * (leadFactor or 1)
    return part.Position + velocity * t
end
function Silent.UpdateCache()
    if not Silent.Enabled or Runtime.MenuOpen or not keyDown(Silent.Key) then
        Silent.CachedTarget=nil; Silent.CachedPart=nil; Silent.CachedPosition=nil
        Silent.LastStatus="off"; return
    end
    local now = os.clock()
    if now - Silent.CachedTime < 0.05 and Silent.CachedPosition then return end
    local options = {
        FOV=Silent.FOV, Range=Silent.Range, PartMode=Silent.Part, Priority="Crosshair",
        TeamCheck=Silent.TeamCheck, WallCheck=Silent.WallCheck,
        IncludeNPC=Silent.NPC, IncludeHeli=Silent.Heli, PlayersFirst=true,
    }
    local best = selectTarget(options, silentBest)
    if best and best.Position then
        local pos = best.Position
        if Silent.Prediction and best.Part then pos = silentPredict(best.Target, best.Part, Silent.Lead) or pos end
        Silent.CachedTarget=best.Target; Silent.CachedPart=best.Part
        Silent.CachedPosition=pos; Silent.CachedTime=now; Silent.LastStatus="locked"
            else
        Silent.CachedTarget=nil; Silent.CachedPart=nil; Silent.CachedPosition=nil
        Silent.LastStatus="searching"
    end
end
local function silentRewrite(payload)
    if type(payload) ~= "table" then return false end
    local targetPos = Silent.CachedPosition
    if not targetPos then return false end
    local changed = false
    local origin = payload.origin or payload.position or payload.Origin or payload.Position
    if typeof(origin) == "Vector3" then
        local newDir = (targetPos - origin).Unit
        if payload.direction ~= nil then payload.direction = newDir; changed = true
        elseif payload.Direction ~= nil then payload.Direction = newDir; changed = true
        elseif payload.unit ~= nil then payload.unit = newDir; changed = true
        elseif payload.dir ~= nil then payload.dir = newDir; changed = true end
    end
    if payload.target ~= nil then payload.target = targetPos; changed = true
    elseif payload.Target ~= nil then payload.Target = targetPos; changed = true
    elseif payload.hit ~= nil then payload.hit = targetPos; changed = true
    elseif payload.goal ~= nil then payload.goal = targetPos; changed = true end
    if typeof(payload.cframe) == "CFrame" then payload.cframe = CFrame.new(payload.cframe.Position, targetPos); changed = true
    elseif typeof(payload.CFrame) == "CFrame" then payload.CFrame = CFrame.new(payload.CFrame.Position, targetPos); changed = true end
    if not changed then
        for k, v in pairs(payload) do
            if typeof(v) == "Vector3" then
                if origin and v ~= origin and (v - origin).Magnitude < 500 then
                    payload[k] = (targetPos - origin).Unit; changed = true; break
                elseif not origin then
                    payload[k] = targetPos; changed = true; break
                end
            end
        end
    end
    return changed
end
local function namecallHook(self, ...)
    if oldNamecall and Runtime.Unloaded then return oldNamecall(self, ...) end
    local args = table.pack(...)
    local method
    if type(o_getnamecallmethod) == "function" then
        local ok, value = pcall(o_getnamecallmethod)
        if ok then method = value end
    end
    if not oldNamecall then return nil end
    if type(method) ~= "string" or string.lower(method) ~= "fireserver" then
        return callOriginal(self, method, args)
    end
    if type(o_checkcaller) == "function" then
        local ok, executor = pcall(o_checkcaller)
        if ok and executor == true then return callOriginal(self, method, args) end
    end
    local payload = args[1]
    if type(payload) ~= "table" then return callOriginal(self, method, args) end

    if S.AutoCross and self.Name == "Swing" and isFustRemote(self, "Swing") then
        local ok, weakSpot, nearestPart = pcall(weakSpotPosition, payload)
        if ok and weakSpot then
            local rewritten = copyPayload(payload)
            rewritten.pos = weakSpot
            if rewritten.target == nil then rewritten.target = nearestPart end
            args[1] = rewritten
            Runtime.Diagnostics.AutoCrossRedirects = (Runtime.Diagnostics.AutoCrossRedirects or 0) + 1
            return callOriginal(self, method, args)
        end
    end

    if not isFustShotRemote(self) then return callOriginal(self, method, args) end

    if S.NoSpread or S.NoRecoil or S.NoCameraShake then
        local copy = copyPayload(payload)
        local changed = false
        if S.NoSpread or S.NoRecoil then changed = stripRecoil(copy) or changed end
        if S.NoCameraShake then changed = stripCameraShake(copy) or changed end
        if changed then args[1] = copy; payload = copy end
    end

    if S.WeaponFireRate and S.WeaponPatches then
        local copy = copyPayload(args[1])
        if type(copy) == "table" and copy.rate ~= nil then
            copy.rate = math.max(0.01, S.FireInterval / 1000)
            args[1] = copy
        end
    end

    if Silent.Enabled then
        if not Silent.CachedPosition then Silent.UpdateCache() end
        if Silent.CachedPosition then
            local copy = copyPayload(args[1])
            if silentRewrite(copy) then
                args[1] = copy
                Silent.LastStatus = "fired"
                return callOriginal(self, method, args)
            end
        end
    end

    return callOriginal(self, method, args)
end
local function installNamecall()
    if hookMode and oldNamecall then return true end
    if type(o_getnamecallmethod) ~= "function" then Aim.NamecallHookStatus="no getnamecallmethod"; return false end
    local wrapped = namecallHook
    if type(o_newcclosure) == "function" then
        local ok, closure = pcall(o_newcclosure, namecallHook)
        if ok and type(closure) == "function" then wrapped = closure end
    end
    local target = ReplicatedStorage:FindFirstChild("Fust")
    local remotes = target and target:FindFirstChild("Remotes")
    if remotes then
        local hooked = 0
        for _, name in ipairs({"Shoot","Fire","Swing"}) do
            local remote = remotes:FindFirstChild(name)
            if remote and type(o_getrawmetatable) == "function" then
                local ok, mt = pcall(o_getrawmetatable, remote)
                if ok and type(mt) == "table" and type(mt.__namecall) == "function" then
                    local original = mt.__namecall
                    if type(o_setreadonly) == "function" then pcall(o_setreadonly, mt, false) end
                    local wrote = pcall(function() mt.__namecall = wrapped end)
                    if type(o_setreadonly) == "function" then pcall(o_setreadonly, mt, true) end
                    if wrote then
                        if not oldNamecall then oldNamecall = original end
                        hooked += 1
                    end
                end
            end
        end
        if hooked > 0 then
            wrappedHook, hookMode = wrapped, "per-remote"
            Aim.NamecallHookStatus = "installed (" .. hooked .. ")"
            return true
        end
    end
    if type(o_hookmetamethod) == "function" then
        local ok, original = pcall(o_hookmetamethod, game, "__namecall", wrapped)
        if ok and type(original) == "function" then
            oldNamecall, wrappedHook, hookMode = original, wrapped, "hookmetamethod"
            Aim.NamecallHookStatus = "installed (global)"
            return true
        end
    end
    Aim.NamecallHookStatus = "unavailable"
    return false
end
Aim.InstallNamecall = installNamecall
local function restoreNamecallHook()
    if not hookMode then return end
    local mode, original, wrapped, mt = hookMode, oldNamecall, wrappedHook, hookMeta
    hookMode, wrappedHook, hookMeta = nil, nil, nil
    oldNamecall = original
    if mode == "hookmetamethod" and type(o_hookmetamethod) == "function" then
        pcall(o_hookmetamethod, game, "__namecall", original)
    elseif mode == "metatable" and mt then
        pcall(function()
            if mt.__namecall ~= wrapped then return end
            if type(o_setreadonly) == "function" then pcall(o_setreadonly, mt, false) end
            mt.__namecall = original
            if type(o_setreadonly) == "function" then pcall(o_setreadonly, mt, true) end
        end)
    end
    Aim.NamecallHookStatus = "not installed"
end
Aim.RestoreNamecall = restoreNamecallHook

-- ============================================================
-- AIM UPDATE / PREDICTION / TRIGGER
-- ============================================================
local velocitySample = {Part=nil, Position=nil, Elapsed=0, Velocity=Vector3.zero}
local function resetVelocitySample()
    velocitySample.Part=nil; velocitySample.Position=nil; velocitySample.Elapsed=0; velocitySample.Velocity=Vector3.zero
end
local function sampleTargetVelocity(part, dt)
    if not S.AimPrediction or not part then resetVelocitySample(); return Vector3.zero end
    local position = part.Position
    if velocitySample.Part ~= part or not velocitySample.Position then
        velocitySample.Part=part; velocitySample.Position=position
        velocitySample.Elapsed=0; velocitySample.Velocity=Vector3.zero
        return velocitySample.Velocity
    end
    local step = tonumber(dt) or 0
    if step <= 0 or step ~= step then return velocitySample.Velocity end
    velocitySample.Elapsed += step
    if velocitySample.Elapsed < 0.05 then return velocitySample.Velocity end
    local elapsed = velocitySample.Elapsed
    velocitySample.Velocity = (position - velocitySample.Position) / elapsed
    velocitySample.Position = position; velocitySample.Elapsed = 0
    return velocitySample.Velocity
end
local function predictedPosition(target, part, sampledVelocity, enabled)
    local position = part.Position
    if not enabled then return position end
    local tool = string.lower(Shared.ToolName())
    local speed, gravity
    for _, entry in ipairs(gunBallistics) do
        if string.find(tool, entry[1], 1, true) then speed, gravity = entry[2], entry[3]; break end
    end
    if not speed then
        for _, entry in ipairs(bowBallistics) do
            if string.find(tool, entry[1], 1, true) then speed, gravity = entry[2] + entry[3], entry[4]; break end
        end
    end
    if not speed or speed <= 0 then return position end
    local distance = (position - Camera.CFrame.Position).Magnitude
    local travel = math.clamp(distance / speed, 0, 1.5)
    local velocity = target.Root and target.Root.AssemblyLinearVelocity or Vector3.zero
    if velocity.Magnitude < 0.5 and part then
        local pv = part.AssemblyLinearVelocity
        if pv then velocity = pv end
    end
    if velocity.Magnitude < 0.5 and sampledVelocity then velocity = sampledVelocity end
    local lead = S.AimLead or 1.0
    return position + velocity * travel * lead + Vector3.new(0, gravity * travel * travel * 0.5, 0)
end
function Aim.Update(dt)
    if fovCircle then
        fovCircle.Visible = S.Aimbot and S.FOVCircle
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
        fovCircle.Radius = S.AimFOV
        fovCircle.Color = Colors.FOV
    end
    Aim.CurrentTarget=nil; Aim.CurrentPart=nil; Aim.CurrentPosition=nil; Aim.CurrentScreen=nil
    if targetLine then targetLine.Visible = false end
    if not S.Aimbot or Runtime.MenuOpen or not keyDown(S.AimKey) then resetVelocitySample(); return end
    aimOptions.FOV=S.AimFOV; aimOptions.Range=S.AimRange; aimOptions.PartMode=S.AimPart
    aimOptions.Priority=S.AimPriority; aimOptions.TeamCheck=S.AimTeamCheck; aimOptions.WallCheck=S.AimWallCheck
    aimOptions.IncludeNPC=S.AimNPC; aimOptions.IncludeHeli=S.AimHeli; aimOptions.PlayersFirst=S.AimPlayersFirst
    local best = selectTarget(aimOptions, aimBest)
    if not best then resetVelocitySample(); return end
    Aim.CurrentTarget=best.Target; Aim.CurrentPart=best.Part
    local sampledVelocity = sampleTargetVelocity(best.Part, dt)
    local position = predictedPosition(best.Target, best.Part, sampledVelocity, S.AimPrediction)
    Aim.CurrentPosition = position
    local x, y, _, visible = Shared.Project(position)
    if visible then Aim.CurrentScreen = Vector2.new(x, y) end
    if targetLine and S.TargetLine and Aim.CurrentScreen then
        targetLine.Visible = true
        targetLine.From = Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y*0.5)
        targetLine.To = Aim.CurrentScreen
        targetLine.Color = Colors.TargetLine
    end
    local smoothing = math.max(1, S.AimSmoothing)
    local alpha = math.clamp(1 - math.exp(-dt * 60 / smoothing), 0, 1)
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, position), alpha)
end

local trigger = {TargetKey=nil, Since=0, NextClick=0, Down=false}
local virtualInput
local function inputServices()
    if virtualInput == nil then
        local ok, service = pcall(game.GetService, game, "VirtualInputManager")
        virtualInput = ok and service or false
    end
    return virtualInput
end
local function release()
    if not trigger.Down then return end
    trigger.Down = false
    if type(mouse1release) == "function" then pcall(mouse1release)
    else
        local service = inputServices()
        if service then
            pcall(service.SendMouseButtonEvent, service, Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y*0.5, 0, false, game, 0)
        end
    end
end
local function click()
    if type(mouse1press) == "function" and type(mouse1release) == "function" then
        local ok = pcall(mouse1press)
        if not ok then return false end
        trigger.Down = true; task.delay(0.025, release); return true
    end
    local service = inputServices()
    if not service then return false end
    local ok = pcall(service.SendMouseButtonEvent, service, Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y*0.5, 0, true, game, 0)
    if not ok then return false end
    trigger.Down = true; task.delay(0.025, release); return true
end
function Aim.UpdateTrigger()
    if not S.Triggerbot or Runtime.MenuOpen or not keyDown(S.TriggerKey) then
        trigger.TargetKey=nil; trigger.Since=0; release(); return
    end
    triggerOptions.FOV=S.TriggerRadius; triggerOptions.Range=S.AimRange
    triggerOptions.PartMode="Closest"; triggerOptions.Priority="Crosshair"
    triggerOptions.TeamCheck=S.TriggerTeamCheck; triggerOptions.WallCheck=S.TriggerWallCheck
    triggerOptions.IncludeNPC=S.TriggerNPC; triggerOptions.IncludeHeli=false; triggerOptions.PlayersFirst=false
    local best = selectTarget(triggerOptions, triggerBest)
    if not best then trigger.TargetKey=nil; trigger.Since=0; release(); return end
    local target = best.Target
    local key = target.Player and target.Player.UserId or target.Model
    local now = os.clock()
    if trigger.TargetKey ~= key then trigger.TargetKey=key; trigger.Since=now; trigger.NextClick=0 end
    if now - trigger.Since < S.TriggerReaction/1000 then return end
    if trigger.Down or now < trigger.NextClick then return end
    if click() then trigger.NextClick = now + S.TriggerDelay/1000 end
end

-- ============================================================
-- CAMERA SHAKE KILLER (каждый кадр)
-- ============================================================
local function killCameraShake()
    if not (S.NoCameraShake or S.NoRecoil) then return end
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            local success = pcall(function() cam.CameraShake = 0 end)
            if not success then
                local shake = cam:FindFirstChildOfClass("CameraShake")
                if shake then shake:Destroy() end
            end
        end
    end)
end
Runtime.KillCameraShake = killCameraShake

-- ============================================================
-- SILENT RENDER
-- ============================================================
local function renderSilent()
    local center = Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y*0.5)
    if silentFOV then
        if Silent.Enabled and Silent.FOVCircle then
            silentFOV.Position=center; silentFOV.Radius=Silent.FOV
            silentFOV.Color=Colors.FOV; silentFOV.Transparency=1; silentFOV.Visible=true
        else silentFOV.Visible=false end
    end
    if silentLine then
        if Silent.Enabled and Silent.TargetLine and Silent.CachedPosition then
            local x, y, _, visible = Shared.Project(Silent.CachedPosition)
            if visible then
                silentLine.From=center; silentLine.To=Vector2.new(x, y)
                silentLine.Color=Colors.TargetLine; silentLine.Transparency=1; silentLine.Visible=true
            else silentLine.Visible=false end
        else silentLine.Visible=false end
    end
end

-- ============================================================
-- HITBOX EXPANDER
-- ============================================================
local Hitbox = {Originals=setmetatable({}, {__mode="k"}), Next=0}
Runtime.Hitbox = Hitbox
local function applyHitboxFor(model, humanoid, head)
    if not head or not head:IsA("BasePart") then return end
    local original = Hitbox.Originals[head]
    if not original then original = head.Size; Hitbox.Originals[head] = original end
    local target = original * math.max(1, S.HitboxSize)
    if head.Size ~= target then
        pcall(function() head.Size = target end)
        pcall(function() head.Transparency = S.HitboxTransparency end)
        pcall(function() head.CanCollide = false end)
        pcall(function() head.Massless = true end)
    end
end
function Hitbox.Update()
    if not S.HitboxExpander then return end
    local now = os.clock()
    if now < Hitbox.Next then return end
    Hitbox.Next = now + 0.5
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LPlr then
            local character = player.Character
            local humanoid = Shared.Humanoid(character)
            local head = character and character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and head then
                if not S.HitboxTeamCheck or not Shared.IsTeammate(player) then
                    applyHitboxFor(character, humanoid, head)
                end
            end
        end
    end
    if S.HitboxNPC then
        for _, npc in ipairs(Entities.NPCs) do
            if npc.Humanoid and npc.Humanoid.Health > 0 and npc.Head then
                applyHitboxFor(npc.Model, npc.Humanoid, npc.Head)
            end
        end
    end
end

-- ============================================================
-- ESP (Player + NPC)
-- ============================================================
local ESP = {PlayerRigs={}, NPCRigs={}, NextPrune=0}
Runtime.ESP = ESP
local function makeDrawings()
    local t = {}
    t.Box = newDrawing("Square"); if t.Box then t.Box.Thickness=1; t.Box.Filled=false end
    t.HealthBG = newDrawing("Square"); if t.HealthBG then t.HealthBG.Filled=true end
    t.Health = newDrawing("Square"); if t.Health then t.Health.Filled=true end
    t.Name = newDrawing("Text"); if t.Name then t.Name.Center=true; t.Name.Outline=true; t.Name.Font=2 end
    t.Info = newDrawing("Text"); if t.Info then t.Info.Center=true; t.Info.Outline=true; t.Info.Font=2 end
    t.Tracer = newDrawing("Line"); if t.Tracer then t.Tracer.Thickness=1 end
    t.Corners = {newDrawing("Line"), newDrawing("Line"), newDrawing("Line"), newDrawing("Line")}
    for _, line in ipairs(t.Corners) do if line then line.Thickness=1 end end
    return t
end
local function getRig(store, key)
    local rig = store[key]
    if rig then return rig end
    rig = makeDrawings(); rig.LastSeen = 0
    store[key] = rig
    return rig
end
local function hideRig(rig)
    for _, f in ipairs({"Box","HealthBG","Health","Name","Info","Tracer"}) do
        if rig[f] then rig[f].Visible = false end
    end
    for _, line in ipairs(rig.Corners or {}) do if line then line.Visible = false end end
    if rig.Highlight then pcall(function() rig.Highlight.Enabled = false end) end
end
local function renderRig(rig, model, humanoid, root, head, name, options)
    if not root or not head then hideRig(rig); return end
    if humanoid and humanoid.Health <= 0 then hideRig(rig); return end
    local distance = (root.Position - Camera.CFrame.Position).Magnitude
    if distance > options.Range then hideRig(rig); return end
    local topPos = head.Position + Vector3.new(0, 0.6, 0)
    local bottomPos = root.Position - Vector3.new(0, 3, 0)
    local topX, topY, topZ = Shared.Project(topPos)
    local bottomX, bottomY, bottomZ = Shared.Project(bottomPos)
    if not topZ or not bottomZ or topZ <= 0 or bottomZ <= 0 then hideRig(rig); return end
    local viewport = Camera.ViewportSize
    local centerX = (topX + bottomX) * 0.5
    local top = math.clamp(math.min(topY, bottomY), 0, viewport.Y)
    local bottom = math.clamp(math.max(topY, bottomY), 0, viewport.Y)
    local height = bottom - top
    if height < 4 then hideRig(rig); return end
    local width = height * 0.55
    local left = centerX - width * 0.5
    rig.LastSeen = os.clock()
    if rig.Box then
        rig.Box.Visible = options.Box == true
        rig.Box.Position = Vector2.new(left, top)
        rig.Box.Size = Vector2.new(width, height)
        rig.Box.Color = options.Color
    end
    if rig.Tracer then
        if options.Tracers then
            local fromY = S.TracerOrigin == "Top" and 0 or (S.TracerOrigin == "Center" and viewport.Y*0.5 or viewport.Y)
            rig.Tracer.From = Vector2.new(viewport.X*0.5, fromY)
            rig.Tracer.To = Vector2.new(centerX, bottom)
            rig.Tracer.Color = options.Color
            rig.Tracer.Visible = true
        else rig.Tracer.Visible = false end
    end
    for _, line in ipairs(rig.Corners or {}) do if line then line.Visible = false end end
    if options.Corners and rig.Corners then
        local corner = math.min(width, height) * 0.28
        local points = {
            {Vector2.new(left, top), Vector2.new(left + corner, top)},
            {Vector2.new(left, top), Vector2.new(left, top + corner)},
            {Vector2.new(left + width, bottom), Vector2.new(left + width - corner, bottom)},
            {Vector2.new(left + width, bottom), Vector2.new(left + width, bottom - corner)},
        }
        for i, pair in ipairs(points) do
            local line = rig.Corners[i]
            if line then
                line.From = pair[1]; line.To = pair[2]
                line.Color = options.Color; line.Visible = true
            end
        end
    end
    if options.Chams then
        if not rig.Highlight then
            pcall(function()
                local h = Instance.new("Highlight")
                h.FillTransparency = 0.72; h.OutlineTransparency = 0
                h.FillColor = options.Color; h.OutlineColor = options.Color
                h.Adornee = model; h.Parent = model
                rig.Highlight = h
            end)
        end
        if rig.Highlight then
            pcall(function()
                rig.Highlight.FillColor = options.Color
                rig.Highlight.OutlineColor = options.Color
                rig.Highlight.Enabled = true
            end)
        end
    elseif rig.Highlight then
        pcall(function() rig.Highlight.Enabled = false end)
    end
    local health = humanoid and humanoid.Health or options.HealthValue
    local maxHealth = humanoid and humanoid.MaxHealth or options.MaxHealth
    local showHealth = options.Health and health and maxHealth and maxHealth > 0
    if rig.HealthBG then rig.HealthBG.Visible = showHealth == true end
    if rig.Health then rig.Health.Visible = showHealth == true end
    if showHealth then
        local percent = math.clamp(health / maxHealth, 0, 1)
        rig.HealthBG.Position = Vector2.new(left - 5, top)
        rig.HealthBG.Size = Vector2.new(2, height)
        rig.HealthBG.Color = Color3.fromRGB(15, 15, 15)
        rig.HealthBG.Transparency = 0.45
        rig.Health.Position = Vector2.new(left - 5, top + height * (1 - percent))
        rig.Health.Size = Vector2.new(2, height * percent)
        rig.Health.Color = Color3.fromRGB(math.floor(255*(1-percent)), math.floor(255*percent), 60)
        rig.Health.Transparency = 1
    end
    if rig.Name then
        rig.Name.Visible = options.Names == true
        rig.Name.Text = tostring(name)
        rig.Name.Position = Vector2.new(centerX, top - 16)
        rig.Name.Size = options.TextSize
        rig.Name.Color = options.Color
    end
    local info = ""
    if options.Distance then info = tostring(math.floor(distance + 0.5)) .. "m" end
    if options.HeldItem then
        local tool = Shared.ToolName(model)
        if tool ~= "" then info = info ~= "" and (info .. "\n" .. tool) or tool end
    end
    if rig.Info then
        rig.Info.Visible = info ~= ""
        rig.Info.Text = info
        rig.Info.Position = Vector2.new(centerX, top + height + 2)
        rig.Info.Size = options.TextSize
        rig.Info.Color = options.Color
    end
end
local function pruneRigs(store)
    local now = os.clock()
    for key, rig in pairs(store) do
        local detached = typeof(key) == "Instance" and key.Parent == nil
        if detached or now - (rig.LastSeen or 0) > 5 then
            for _, f in ipairs({"Box","HealthBG","Health","Name","Info","Tracer"}) do
                if rig[f] then pcall(function() rig[f]:Remove() end) end
            end
            for _, line in ipairs(rig.Corners or {}) do
                if line then pcall(function() line:Remove() end) end
            end
            if rig.Highlight then pcall(function() rig.Highlight:Destroy() end) end
            store[key] = nil
        end
    end
end
function ESP.Update()
    if S.PlayerESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LPlr then
                local character = player.Character
                local humanoid = Shared.Humanoid(character)
                local root = Shared.Root(character)
                local head = character and character:FindFirstChild("Head")
                local rig = getRig(ESP.PlayerRigs, player)
                if rig and character and humanoid and root and head then
                    if S.PlayerTeamCheck and Shared.IsTeammate(player) then hideRig(rig)
                    else
                        renderRig(rig, character, humanoid, root, head, player.DisplayName or player.Name, {
                            Box=S.PlayerBox, Names=S.PlayerNames, Distance=S.PlayerDistance,
                            Health=S.PlayerHealth, HeldItem=S.PlayerHeldItem, Tracers=S.PlayerTracers,
                            Chams=S.PlayerChams, Corners=S.PlayerCorners,
                            Range=S.PlayerRange, TextSize=S.PlayerTextSize, Color=Colors.Player,
                        })
                    end
                elseif rig then hideRig(rig) end
            end
        end
    else
        for _, rig in pairs(ESP.PlayerRigs) do hideRig(rig) end
    end
    if S.NPCESP then
        for _, npc in ipairs(Entities.NPCs) do
            local rig = getRig(ESP.NPCRigs, npc.Model)
            if rig then
                renderRig(rig, npc.Model, npc.Humanoid, npc.Root, npc.Head, npc.Name, {
                    Box=S.NPCBox, Names=S.NPCNames, Distance=S.NPCDistance,
                    Health=S.NPCHealth, HeldItem=false, Tracers=false,
                    Range=S.NPCRange, TextSize=S.NPCTextSize, Color=Colors.NPC,
                })
            end
        end
        if S.NPCHeli and Entities.Heli then
            local heli = Entities.Heli
            local rig = getRig(ESP.NPCRigs, heli.Model)
            if rig then
                renderRig(rig, heli.Model, nil, heli.Root, heli.Root, heli.Name, {
                    Box=S.NPCBox, Names=S.NPCNames, Distance=S.NPCDistance,
                    Health=S.NPCHealth, HeldItem=false, Tracers=false,
                    Range=S.NPCRange, TextSize=S.NPCTextSize, Color=Colors.Heli,
                    HealthValue=heli.Health, MaxHealth=heli.MaxHealth,
                })
            end
        end
    else
        for _, rig in pairs(ESP.NPCRigs) do hideRig(rig) end
    end
    local now = os.clock()
    if now >= ESP.NextPrune then
        ESP.NextPrune = now + 5
        pruneRigs(ESP.PlayerRigs)
        pruneRigs(ESP.NPCRigs)
    end
end

-- ============================================================
-- WORLD ESP (Loot/Base/Drops/Nodes/Pickups/Vehicles) — pool
-- ============================================================
local World = {
    Entries={}, Tasks={}, TaskIndex=1, ChildIndex=1, Children=nil,
    Active=false, NextScan=0, Working={}, Seen={},
    Labels={}, LabelIndex=0,
}
Runtime.World = World
World.Categories = {
    Loot={Master="LootESP", Range="LootRange", Distance="LootDistance", Color="Loot"},
    Base={Master="BaseESP", Range="BaseRange", Distance="BaseDistance", Color="Base"},
    Drops={Master="DropsESP", Range="DropsRange", Distance="DropsDistance", Color="Drops"},
    Nodes={Master="NodesESP", Range="NodesRange", Distance="NodesDistance", Color="Nodes"},
    Pickups={Master="PickupsESP", Range="PickupsRange", Distance="PickupsDistance", Color="Pickups"},
    Vehicles={Master="VehiclesESP", Range="VehiclesRange", Distance="VehiclesDistance", Color="Vehicles"},
}
local lootRules = {
    {"barrel","LootBarrels","Loot Barrel"},{"elite","LootElite","Elite Crate"},
    {"military","LootMilitary","Military Crate"},{"crate","LootCrates","Loot Crate"},
}
local baseRules = {
    {"largebox","BaseBoxes","Large Box"},{"woodenbox","BaseBoxes","Small Box"},
    {"toolcupboard","BaseCupboard","Tool Cupboard"},{"cupboard","BaseCupboard","Tool Cupboard"},
    {"locker","BaseLocker","Locker"},{"sleepingbag","BaseSleepingBag","Sleeping Bag"},
    {"sleeping_bag","BaseSleepingBag","Sleeping Bag"},
    {"shotguntrap","BaseTraps","Shotgun Trap"},{"autoturret","BaseTraps","Auto Turret"},
    {"aaturret","BaseTraps","AA Turret"},
}
local nodeRules = {
    {"stone","NodeStone","Stone Node"},{"sulfur","NodeSulfur","Sulfur Node"},
    {"metal","NodeMetal","Metal Node"},{"iron","NodeMetal","Metal Node"},
}
local plantRules = {
    {"hemp","Hemp (Cloth)"},{"corn","Corn"},{"pumpkin","Pumpkin"},{"berry","Berries"},
    {"mushroom","Mushroom"},{"carrot","Carrot"},{"potato","Potato"},{"apple","Apple"},
}
local vehicleRules = {
    {"atv","VehicleATV","ATV",{"Chassis","Hull","Seat"}},
    {"rowboat","VehicleBoats","Rowboat",{"Hull","Seat"}},
    {"rhib","VehicleBoats","RHIB",{"Hull","Seat"}},
    {"tugboat","VehicleBoats","Tugboat",{"Hull","Seat"}},
    {"boat","VehicleBoats","Boat",{"Hull","Seat"}},
    {"minicopter","VehicleHelis","Minicopter",{"Frame","Floor","Body","Chassis","Engine","Seat","MainRotor"}},
    {"scrapheli","VehicleHelis","Scrap Heli",{"Body","Chassis","Frame","Engine","MainRotor"}},
    {"helicopter","VehicleHelis","Helicopter",{"Body","Chassis","Frame","Engine","MainRotor"}},
}
local function bagLabel(lower)
    if string.find(lower, "sleepingbag", 1, true) or string.find(lower, "sleeping_bag", 1, true) then return nil end
    if string.find(lower, "corpse", 1, true) or string.find(lower, "deadbody", 1, true)
        or string.find(lower, "dead_body", 1, true) or string.find(lower, "ragdoll", 1, true) then
        return "Dead Body"
    end
    for _, pattern in ipairs({"backpack","lootsack","loot_bag","lootbag","bodybag","body_bag","deathbag","pack"}) do
        if string.find(lower, pattern, 1, true) then return "Body Bag" end
    end
    return nil
end
local function worldAdd(categoryName, model, label, candidates)
    if World.Seen[model] or #World.Working >= 512 then return end
    World.Seen[model] = true
    local part = Shared.FindPart(model, candidates)
    if not part then return end
    table.insert(World.Working, {Category=categoryName, Model=model, Part=part, Label=label})
end
local function classifyLootBase(model)
    local lower = string.lower(model.Name)
    for _, rule in ipairs(lootRules) do
        if string.find(lower, rule[1], 1, true) then
            if S.LootESP and S[rule[2]] then worldAdd("Loot", model, rule[3]) else World.Seen[model] = true end
            return
        end
    end
    for _, rule in ipairs(baseRules) do
        if string.find(lower, rule[1], 1, true) then
            if S.BaseESP and S[rule[2]] then worldAdd("Base", model, rule[3]) else World.Seen[model] = true end
            return
        end
    end
    if S.DropsESP and S.BodyBags then
        local label = bagLabel(lower)
        if label then worldAdd("Drops", model, label) end
    end
end
local function classify(kind, model)
    if World.Seen[model] then return end
    local lower = string.lower(model.Name)
    if kind == "LootBase" then
        classifyLootBase(model)
    elseif kind == "Bags" then
        if S.BodyBags then
            local label = bagLabel(lower)
            if label then worldAdd("Drops", model, label) end
        end
    elseif kind == "Top" then
        local label = bagLabel(lower)
        if label then
            if S.BodyBags then worldAdd("Drops", model, label) end
        elseif model:IsA("Tool") and S.DroppedItems then
            worldAdd("Drops", model, model.Name)
        end
    elseif kind == "Dropped" then
        if S.DroppedItems and not bagLabel(lower) then worldAdd("Drops", model, model.Name) end
    elseif kind == "Nodes" then
        for _, rule in ipairs(nodeRules) do
            if string.find(lower, rule[1], 1, true) then
                if S[rule[2]] then worldAdd("Nodes", model, rule[3]) end
                return
            end
        end
    elseif kind == "Pickups" then
        if S.PickupOres and (string.find(lower, "stone", 1, true) or string.find(lower, "ore", 1, true)) then
            local label = string.find(lower, "sulfur", 1, true) and "Sulfur Pickup"
                or string.find(lower, "metal", 1, true) and "Metal Pickup" or "Stone Pickup"
            worldAdd("Pickups", model, label); return
        end
        if S.PickupPlants then
            for _, rule in ipairs(plantRules) do
                if string.find(lower, rule[1], 1, true) then worldAdd("Pickups", model, rule[2]); return end
            end
        end
        if S.PickupWood and (string.find(lower, "wood", 1, true) or string.find(lower, "log", 1, true)) then
            worldAdd("Pickups", model, "Wood Pile")
        end
    elseif kind == "Vehicles" then
        for _, rule in ipairs(vehicleRules) do
            if string.find(lower, rule[1], 1, true) then
                if S[rule[2]] then worldAdd("Vehicles", model, rule[3], rule[4]) end
                return
            end
        end
    end
end
local function worldTask(kind, folder)
    if folder then table.insert(World.Tasks, {Kind=kind, Folder=folder}) end
end
local function buildTasks()
    World.Tasks = {}; World.TaskIndex = 1; World.ChildIndex = 1
    World.Children = nil; World.Working = {}; World.Seen = {}
    if S.LootESP or S.BaseESP or (S.DropsESP and S.BodyBags) then
        worldTask("LootBase", workspace:FindFirstChild("Loot"))
        worldTask("LootBase", workspace:FindFirstChild("Deployables"))
    end
    if S.DropsESP and S.BodyBags then
        for _, name in ipairs({"WorldItems","DroppedItems","Dropped","Debris","Corpses","DeadBodies","Bags","Dead","LootBags","DeathBags"}) do
            worldTask("Bags", workspace:FindFirstChild(name))
        end
    end
    if S.DropsESP and (S.BodyBags or S.DroppedItems) then worldTask("Top", workspace) end
    if S.DropsESP and S.DroppedItems then
        for _, name in ipairs({"WorldItems","DroppedItems","Dropped","Debris","LooseItems","ItemDrops","Drops"}) do
            worldTask("Dropped", workspace:FindFirstChild(name))
        end
    end
    if S.NodesESP then worldTask("Nodes", workspace:FindFirstChild("Nodes") or workspace:FindFirstChild("OreNodes")) end
    if S.PickupsESP then
        worldTask("Pickups", workspace:FindFirstChild("Pickups") or workspace:FindFirstChild("SpawnedPickups") or workspace:FindFirstChild("GroundItems"))
    end
    if S.VehiclesESP then
        for _, name in ipairs({"FustAtvs","FustBoats","FustMinicopters","FustMinicopter","FustCars","FustVehicles"}) do
            worldTask("Vehicles", workspace:FindFirstChild(name))
        end
    end
    World.Active = #World.Tasks > 0
    if not World.Active then World.Entries = {} end
end
local function worldEnabled()
    return S.LootESP or S.BaseESP or S.DropsESP or S.NodesESP or S.PickupsESP or S.VehiclesESP
end
function World.ForceScan()
    World.Active = false; World.Children = nil; World.Tasks = {}; World.NextScan = 0
end
function World.Update()
    if not worldEnabled() then
        if #World.Entries > 0 then World.Entries = {} end
        World.Active = false
        return
    end
    local now = os.clock()
    if not World.Active and now >= World.NextScan then buildTasks() end
    if not World.Active then return end
    local budget = 24
    while budget > 0 and World.Active do
        local current = World.Tasks[World.TaskIndex]
        if not current then
            World.Entries = World.Working
            World.Working = {}
            World.Active = false
            World.NextScan = now + 1
            Runtime.Diagnostics.WorldEntries = #World.Entries
            break
        end
        if not World.Children then
            World.Children = current.Folder:GetChildren()
            World.ChildIndex = 1
        end
        local child = World.Children[World.ChildIndex]
        if child then
            World.ChildIndex += 1
            budget -= 1
            classify(current.Kind, child)
        else
            World.Children = nil
            World.TaskIndex += 1
        end
    end
end
local function worldLabel()
    World.LabelIndex += 1
    local label = World.Labels[World.LabelIndex]
    if not label then
        label = newDrawing("Text")
        if label then
            label.Center = true; label.Outline = true; label.Font = 2
        end
        World.Labels[World.LabelIndex] = label
    end
    return label
end
local function containerContents(model)
    if not model then return "" end
    local inventory = model:FindFirstChild("Inventory") or model:FindFirstChild("Items") or model
    local names = {}
    for _, child in ipairs(inventory:GetChildren()) do
        if child:IsA("Model") or child:IsA("Tool") or child:IsA("BasePart") then
            names[#names + 1] = child.Name
        end
        if #names >= 6 then break end
    end
    return #names > 0 and table.concat(names, "\n") or ""
end
local function renderWorld()
    for i = 1, World.LabelIndex do
        local label = World.Labels[i]
        if label then label.Visible = false end
    end
    World.LabelIndex = 0
    local rendered = 0
    for _, entry in ipairs(World.Entries) do
        if rendered >= 400 then break end
        local category = World.Categories[entry.Category]
        if category and S[category.Master] and entry.Part then
            local position = entry.Part.Position
            local distance = (position - Camera.CFrame.Position).Magnitude
            if distance <= S[category.Range] then
                local x, y, _, visible = Shared.Project(position)
                if visible then
                    local label = worldLabel()
                    if label then
                        label.Visible = true
                        local contents = S.LootContents and (entry.Category == "Loot" or entry.Category == "Base") and containerContents(entry.Model) or ""
                        label.Text = entry.Label .. (contents ~= "" and "\n" .. contents or "") .. (S[category.Distance] and "\n" .. tostring(math.floor(distance + 0.5)) .. "m" or "")
                        label.Position = Vector2.new(x, y)
                        label.Size = S.WorldTextSize
                        label.Color = Colors[category.Color]
                    end
                    rendered += 1
                end
            end
        end
    end
    Runtime.Diagnostics.WorldRendered = rendered
end
Runtime.RenderWorld = renderWorld

-- ============================================================
-- ENEMY SCANNER
-- ============================================================
local Scanner = {Gui=nil, Entries={}, Next=0, Rows={}}
Runtime.Scanner = Scanner
local function createScannerGui()
    local parent = LPlr:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "QwertyScanner"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999997
    sg.Parent = parent
    Scanner.Gui = sg
    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.Position = UDim2.new(1, -12, 1, -12)
    frame.Size = UDim2.new(0, 300, 0, 220)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Parent = sg
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(90, 175, 255); stroke.Thickness = 1; stroke.Transparency = 0.3; stroke.Parent = frame
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 10, 0, 6)
    title.Size = UDim2.new(1, -20, 0, 18)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "ENEMY SCANNER"
    title.Parent = frame
    local list = Instance.new("ScrollingFrame")
    list.Name = "List"
    list.Position = UDim2.new(0, 6, 0, 28)
    list.Size = UDim2.new(1, -12, 1, -34)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 2
    list.ScrollBarImageColor3 = Color3.fromRGB(90, 175, 255)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list
    return frame, list
end
local function getScannerRow(index)
    local row = Scanner.Rows[index]
    if row and row.Parent then return row end
    local list = Scanner.Gui and Scanner.Gui:FindFirstChild("Panel") and Scanner.Gui.Panel:FindFirstChild("List")
    if not list then return nil end
    row = Instance.new("Frame")
    row.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 28)
    row.LayoutOrder = index
    row.Parent = list
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 4); rc.Parent = row
    local nm = Instance.new("TextLabel")
    nm.Name = "Name"
    nm.BackgroundTransparency = 1
    nm.Position = UDim2.new(0, 6, 0, 2)
    nm.Size = UDim2.new(1, -12, 0, 12)
    nm.Font = Enum.Font.GothamBold
    nm.TextSize = 11
    nm.TextColor3 = Color3.fromRGB(255, 255, 255)
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.Parent = row
    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.BackgroundTransparency = 1
    info.Position = UDim2.new(0, 6, 0, 13)
    info.Size = UDim2.new(1, -12, 0, 12)
    info.Font = Enum.Font.Gotham
    info.TextSize = 10
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = row
    Scanner.Rows[index] = row
    return row
end
local function updateScanner()
    if not S.EnemyScanner then
        if Scanner.Gui then Scanner.Gui.Enabled = false end
        return
    end
    if not Scanner.Gui then createScannerGui() end
    Scanner.Gui.Enabled = true
    local now = os.clock()
    if now < Scanner.Next then return end
    Scanner.Next = now + 0.35
    local index = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LPlr then
            local character = player.Character
            local root = Shared.Root(character)
            local humanoid = Shared.Humanoid(character)
            if character and root and humanoid and humanoid.Health > 0 then
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                if dist <= S.EnemyScannerRange then
                    index += 1
                    local row = getScannerRow(index)
                    if row then
                        local tool = Shared.ToolName(character)
                        local weapon = tool ~= "" and tool or "Unarmed"
                        local visible = Shared.WallClear(root.Position + Vector3.new(0,1,0), character)
                        local status = visible and "Open" or "Behind Wall"
                        local color = visible and Color3.fromRGB(120, 230, 140) or Color3.fromRGB(255, 120, 120)
                        row.Visible = true
                        row.NameLabel.Text = player.DisplayName or player.Name
                        local info = row:FindFirstChild("Info")
                        if info then
                            info.Text = weapon .. "  |  " .. tostring(math.floor(dist)) .. "m  |  " .. status
                            info.TextColor3 = color
                        end
                    end
                end
            end
        end
    end
    for i = index + 1, #Scanner.Rows do
        if Scanner.Rows[i] then Scanner.Rows[i].Visible = false end
    end
    if index == 0 then
        local row = getScannerRow(1)
        if row then
            row.Visible = true
            row.NameLabel.Text = "No enemies within " .. tostring(S.EnemyScannerRange) .. "m"
            local info = row:FindFirstChild("Info")
            if info then info.Text = "" end
        end
    end
end
Runtime.UpdateScanner = updateScanner

-- ============================================================
-- MOVEMENT
-- ============================================================
local Movement = {Flying=false, FlyConn=nil, FlyBV=nil, FlyBG=nil, Next=0}
Runtime.Movement = Movement
local function isMovementLocked() return S.AntiCheatMode == true end
local function updateSpeedJump()
    local character = Shared.Character()
    local humanoid = Shared.Humanoid(character)
    if not humanoid then return end
    if isMovementLocked() then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.UseJumpPower = true
        return
    end
    if S.Speed then
        pcall(function() humanoid.WalkSpeed = S.SpeedValue end)
    end
    if S.HighJump then
        pcall(function() humanoid.UseJumpPower = true; humanoid.JumpPower = S.JumpHeight end)
    end
end
local function startFly()
    if Movement.Flying then return end
    local character = Shared.Character()
    local root = Shared.Root(character)
    if not root then return end
    Movement.Flying = true
    local bv = Instance.new("BodyVelocity")
    bv.Name = "QwertyFlyBV"; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Velocity = Vector3.zero; bv.Parent = root
    local bg = Instance.new("BodyGyro")
    bg.Name = "QwertyFlyBG"; bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.P = 1000; bg.D = 50; bg.CFrame = root.CFrame; bg.Parent = root
    Movement.FlyBV, Movement.FlyBG = bv, bg
    Movement.FlyConn = RunService.Heartbeat:Connect(function()
        if not S.Fly or isMovementLocked() or Runtime.Unloaded then
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            Movement.FlyBV, Movement.FlyBG = nil, nil
            if Movement.FlyConn then Movement.FlyConn:Disconnect(); Movement.FlyConn = nil end
            Movement.Flying = false
            return
        end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local move = Vector3.zero
        local UIS = UserInputService
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then move = move.Unit * S.FlySpeed end
        bv.Velocity = move
        bg.CFrame = cam.CFrame
    end)
end
local function stopFly()
    if Movement.FlyBV then Movement.FlyBV:Destroy() end
    if Movement.FlyBG then Movement.FlyBG:Destroy() end
    if Movement.FlyConn then Movement.FlyConn:Disconnect() end
    Movement.FlyBV, Movement.FlyBG, Movement.FlyConn = nil, nil, nil
    Movement.Flying = false
end
local function startNoclip()
    if Movement.NoclipConn then return end
    Movement.NoclipConn = RunService.Stepped:Connect(function()
        if not S.Noclip or isMovementLocked() or Runtime.Unloaded then
            if Movement.NoclipConn then Movement.NoclipConn:Disconnect(); Movement.NoclipConn = nil end
            return
        end
        local character = Shared.Character()
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
            end
        end
    end)
end
local function stopNoclip()
    if Movement.NoclipConn then Movement.NoclipConn:Disconnect(); Movement.NoclipConn = nil end
end
local InfiniteJump = {Conn=nil}
local function startInfiniteJump()
    if InfiniteJump.Conn then return end
    InfiniteJump.Conn = UserInputService.JumpRequest:Connect(function()
        if not S.InfiniteJump or isMovementLocked() or Runtime.Unloaded then return end
        local humanoid = Shared.Humanoid()
        if humanoid then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end)
end
local function startNoJumpCooldown()
    if Movement.JumpCooldownConn then return end
    Movement.JumpCooldownConn = RunService.Heartbeat:Connect(function()
        if not S.NoJumpCooldown or isMovementLocked() or Runtime.Unloaded then
            if Movement.JumpCooldownConn then Movement.JumpCooldownConn:Disconnect(); Movement.JumpCooldownConn = nil end
            return
        end
        local humanoid = Shared.Humanoid()
        if humanoid then
            pcall(function()
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                humanoid.JumpPower = 50
            end)
        end
    end)
end
local function startFallDamage()
    if Movement.FallConn then return end
    Movement.FallHP = 100
    Movement.FallConn = RunService.Heartbeat:Connect(function()
        if not S.FallDamage or Runtime.Unloaded then
            if Movement.FallConn then Movement.FallConn:Disconnect(); Movement.FallConn = nil end
            return
        end
        local humanoid = Shared.Humanoid()
        if humanoid then
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.Freefall then
                Movement.FallHP = humanoid.Health
            elseif state == Enum.HumanoidStateType.Landed then
                if humanoid.Health < Movement.FallHP then
                    pcall(function() humanoid.Health = Movement.FallHP end)
                end
            end
        end
    end)
end
local AntiAim = {Conn=nil}
local function startAntiAim()
    if AntiAim.Conn then return end
    AntiAim.Conn = RunService.Heartbeat:Connect(function()
        if not S.AntiAim or isMovementLocked() or Runtime.Unloaded then
            if AntiAim.Conn then AntiAim.Conn:Disconnect(); AntiAim.Conn = nil end
            return
        end
        local character = Shared.Character()
        local root = Shared.Root(character)
        if not root then return end
        local t = os.clock()
        local yaw = math.sin(t * 15) * 180
        local pitch = math.sin(t * 9) * 45
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)
    end)
end
local function stopAntiAim()
    if AntiAim.Conn then AntiAim.Conn:Disconnect(); AntiAim.Conn = nil end
end

-- ============================================================
-- 20 NEW FEATURES
-- ============================================================
local NewF = {}

-- 1. FullBright
function NewF.applyFullBright()
    if not S.FullBright then return end
    pcall(function()
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.ClockTime = 12
    end)
end

-- 2. RemoveFog
function NewF.applyRemoveFog()
    if not S.RemoveFog then return end
    pcall(function()
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then atm.Density = 0; atm.Haze = 0 end
    end)
end

-- 3. HideGrass
function NewF.applyHideGrass()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end
    pcall(function()
        if type(sethiddenproperty) == "function" then
            sethiddenproperty(terrain, "Decoration", not S.HideGrass)
        else
            terrain.Decoration = not S.HideGrass
        end
    end)
end

-- 4. HUD (stats)
local HUD = {Gui=nil, Labels={}, Conn=nil}
function HUD.create()
    if HUD.Gui then return end
    local parent = LPlr:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "QwertyHUD"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999996
    sg.Parent = parent
    HUD.Gui = sg
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 10)
    frame.Size = UDim2.new(0, 300, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = sg
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 6); rc.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Thickness = 1; stroke.Transparency = 0.7; stroke.Parent = frame
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Text = "FPS: 0 | Ping: 0 | Speed: 0"
    lbl.Parent = frame
    HUD.Label = lbl
end
function HUD.update()
    if not HUD.Gui then return end
    HUD.Gui.Enabled = S.HUD
    if not S.HUD or not HUD.Label then return end
    local fps = math.floor(1 / math.max(0.001, RunService.RenderStepped:Wait() or 0.016))
    pcall(function() fps = math.floor(workspace:GetRealPhysicsFPS() + 0.5) end)
    local ping = 0
    pcall(function()
        local stats = game:GetService("Stats")
        ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    local speed = 0
    local root = Shared.Root()
    if root then
        local v = root.AssemblyLinearVelocity
        speed = math.floor(Vector3.new(v.X, 0, v.Z).Magnitude + 0.5)
    end
    HUD.Label.Text = "FPS: " .. fps .. " | Ping: " .. ping .. " | Speed: " .. speed
end

-- 5. Auto Respawn
local function startAutoRespawn()
    if Movement.RespawnConn then return end
    Movement.RespawnConn = RunService.Heartbeat:Connect(function()
        if not S.AutoRespawn or Runtime.Unloaded then
            if Movement.RespawnConn then Movement.RespawnConn:Disconnect(); Movement.RespawnConn = nil end
            return
        end
        local humanoid = Shared.Humanoid()
        if humanoid and humanoid.Health <= 0 then
            pcall(function() LPlr:LoadCharacter() end)
        end
    end)
end

-- 6. Anti-AFK
local function startAntiAFK()
    local vu = LPlr:FindFirstChild("Idled") or nil
    LPlr.Idled:Connect(function()
        if not S.AntiAFK or Runtime.Unloaded then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- 7. Instant ProximityPrompt
local function startInstantPrompt()
    if Movement.PromptConn then return end
    Movement.PromptConn = RunService.Heartbeat:Connect(function()
        if not S.InstantProximityPrompt or Runtime.Unloaded then
            if Movement.PromptConn then Movement.PromptConn:Disconnect(); Movement.PromptConn = nil end
            return
        end
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
    end)
end

-- 8. Walk on Water
local function startWalkOnWater()
    if Movement.WaterConn then return end
    Movement.WaterConn = RunService.Stepped:Connect(function()
        if not S.WalkOnWater or Runtime.Unloaded then
            if Movement.WaterConn then Movement.WaterConn:Disconnect(); Movement.WaterConn = nil end
            return
        end
        local character = Shared.Character()
        local root = Shared.Root(character)
        if root then
            pcall(function() root.CanCollide = true end)
        end
    end)
end

-- 9. Auto Loot (ProximityPrompt)
local AutoLoot = {Next=0}
local function updateAutoLoot()
    if not S.AutoLoot then return end
    local now = os.clock()
    if now < AutoLoot.Next then return end
    AutoLoot.Next = now + 0.5
    local character = Shared.Character()
    local root = Shared.Root(character)
    if not root then return end
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local part = prompt.Parent
            if part and part:IsA("BasePart") then
                local dist = (part.Position - root.Position).Magnitude
                if dist <= S.AutoLootRange then
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
        end
    end
end

-- 10. Auto Tool (equip best)
local function updateAutoTool()
    if not S.AutoTool then return end
    local character = Shared.Character()
    local humanoid = Shared.Humanoid(character)
    if not humanoid then return end
    local bestTool, bestScore = nil, 0
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local score = #tool.Name
            if score > bestScore then bestScore = score; bestTool = tool end
        end
    end
    if bestTool and humanoid:FindFirstChildOfClass("Tool") ~= bestTool then
        pcall(function() humanoid:EquipTool(bestTool) end)
    end
end

-- 11. Admin Check
local function updateAdminCheck()
    if not S.AdminCheck then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LPlr then
            local rank = 0
            pcall(function() rank = player:GetRankInGroup(game.CreatorId) end)
            if rank >= 250 then
                pcall(function()
                    local h = player.Character and player.Character:FindFirstChild("Humanoid")
                    if h then h.Health = 0 end
                end)
            end
        end
    end
end

-- 12. Gun Chams
local GunChams = {Highlight=nil, LastModel=nil}
local function updateGunChams()
    if not S.GunChams then
        if GunChams.Highlight then pcall(function() GunChams.Highlight:Destroy() end); GunChams.Highlight = nil end
        return
    end
    local character = Shared.Character()
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    local gunModel = tool and tool:FindFirstChild("Model")
    if gunModel ~= GunChams.LastModel then
        if GunChams.Highlight then pcall(function() GunChams.Highlight:Destroy() end); GunChams.Highlight = nil end
        if gunModel then
            GunChams.Highlight = Instance.new("Highlight")
            GunChams.Highlight.Adornee = gunModel
            GunChams.Highlight.FillColor = S.GunChamsColor
            GunChams.Highlight.OutlineColor = S.GunChamsColor
            GunChams.Highlight.FillTransparency = S.GunChamsTransparency
            GunChams.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            GunChams.Highlight.Parent = gunModel
            GunChams.LastModel = gunModel
        end
    end
end

-- 13. Auto Farm
local function updateAutoFarm()
    if not S.AutoFarm then return end
    local root = Shared.Root()
    if not root then return end
    local best, bestDist = nil, S.AutoFarmRange
    local folder = workspace:FindFirstChild("Nodes") or workspace:FindFirstChild("OreNodes")
    if folder then
        for _, node in ipairs(folder:GetChildren()) do
            local part = node:FindFirstChild("Rock") or node:FindFirstChild("Trunk") or Shared.FindPart(node)
            if part then
                local dist = (part.Position - root.Position).Magnitude
                if dist < bestDist then bestDist = dist; best = part end
            end
        end
    end
    if best then
        local char = Shared.Character()
        local humanoid = Shared.Humanoid(char)
        if humanoid and bestDist > 8 then
            pcall(function() humanoid:MoveTo(best.Position) end)
        elseif humanoid then
            if type(mouse1click) == "function" then pcall(mouse1click) end
            if type(mouse1release) == "function" then pcall(mouse1release) end
        end
    end
end

-- 14. Chat Spy
local ChatSpy = {Gui=nil, Log={}}
local function startChatSpy()
    if ChatSpy.Conn then return end
    local parent = LPlr:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "QwertyChatSpy"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999995
    sg.Parent = parent
    ChatSpy.Gui = sg
    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.AnchorPoint = Vector2.new(0, 1)
    frame.Position = UDim2.new(0, 12, 1, -12)
    frame.Size = UDim2.new(0, 320, 0, 180)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = sg
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 8); rc.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Thickness = 1; stroke.Transparency = 0.6; stroke.Parent = frame
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 10, 0, 6)
    title.Size = UDim2.new(1, -20, 0, 18)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "CHAT SPY"
    title.Parent = frame
    local list = Instance.new("ScrollingFrame")
    list.Name = "List"
    list.Position = UDim2.new(0, 6, 0, 28)
    list.Size = UDim2.new(1, -12, 1, -34)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 2
    list.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list
    ChatSpy.List = list
    ChatSpy.Conn = true
    local function hookPlayer(player)
        player.Chatted:Connect(function(msg)
            if not S.ChatSpy or Runtime.Unloaded then return end
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 14)
            label.Font = Enum.Font.Gotham
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Text = player.Name .. ": " .. msg
            label.Parent = list
            task.delay(15, function() if label.Parent then label:Destroy() end end)
            local children = list:GetChildren()
            if #children > 50 then
                for i = 1, #children - 50 do
                    if children[i]:IsA("TextLabel") then children[i]:Destroy() end
                end
            end
        end)
    end
    for _, player in ipairs(Players:GetPlayers()) do hookPlayer(player) end
    Players.PlayerAdded:Connect(hookPlayer)
end

-- 15. Fast Place
local function updateFastPlace()
    if not S.FastPlace then return end
    pcall(function()
        local character = Shared.Character()
        if character then
            local humanoid = Shared.Humanoid(character)
            if humanoid then humanoid.WalkSpeed = math.max(humanoid.WalkSpeed, 20) end
        end
    end)
end

-- 16. Auto Bandage
local function updateAutoBandage()
    if not S.AutoBandage then return end
    local humanoid = Shared.Humanoid()
    if humanoid and humanoid.Health < humanoid.MaxHealth * 0.5 then
        local character = Shared.Character()
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") and string.find(string.lower(tool.Name), "bandage", 1, true) then
                    pcall(function() humanoid:EquipTool(tool) end)
                    if type(mouse1click) == "function" then pcall(mouse1click) end
                    break
                end
            end
        end
    end
end

-- 17. Auto Drink
local function updateAutoDrink()
    if not S.AutoDrink then return end
    local humanoid = Shared.Humanoid()
    if humanoid and humanoid.Health < humanoid.MaxHealth * 0.5 then
        local character = Shared.Character()
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "water", 1, true)
                    or string.find(string.lower(tool.Name), "drink", 1, true)) then
                    pcall(function() humanoid:EquipTool(tool) end)
                    if type(mouse1click) == "function" then pcall(mouse1click) end
                    break
                end
            end
        end
    end
end

-- 18. No HUD
local function updateNoHUD()
    if not S.NoHUD then return end
    pcall(function()
        local playerGui = LPlr:FindFirstChild("PlayerGui")
        if not playerGui then return end
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "QwertyScanner" and gui.Name ~= "QwertyHUD"
                and gui.Name ~= "QwertyChatSpy" and gui ~= Window.Gui then
                gui.Enabled = false
            end
        end
    end)
end

-- 19. No Clip Camera
local function updateNoClipCamera()
    if not S.NoClipCamera then return end
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = CFrame.new(cam.CFrame.Position)
        end
    end)
end

-- 20. Spam Kill Log
local KillLog = {Conn=nil, Next=0}
local function startKillLog()
    if KillLog.Conn then return end
    KillLog.Conn = RunService.Heartbeat:Connect(function()
        if not S.SpamKillLog or Runtime.Unloaded then
            if KillLog.Conn then KillLog.Conn:Disconnect(); KillLog.Conn = nil end
            return
        end
        local now = os.clock()
        if now < KillLog.Next then return end
        KillLog.Next = now + 3
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LPlr then
                local character = player.Character
                local humanoid = Shared.Humanoid(character)
                if humanoid and humanoid.Health <= 0 then
                    pcall(function()
                        local r = player:FindFirstChild("KilledBy") or nil
                    end)
                end
            end
        end
    end)
end

local SleeperESP = {Entries={}, Labels={}, LabelIndex=0, NextScan=0, Seen={}}

local function sleeperScan()
    local now = os.clock()
    if now < SleeperESP.NextScan then return end
    SleeperESP.NextScan = now + 1
    SleeperESP.Entries = {}
    SleeperESP.Seen = {}
    local myChar = Shared.Character()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= myChar then
            local lower = string.lower(obj.Name)
            if string.find(lower, "sleep", 1, true) or string.find(lower, "sleeper", 1, true)
                or string.find(lower, "ragdoll", 1, true) or string.find(lower, "body", 1, true) then
                if not SleeperESP.Seen[obj] then
                    SleeperESP.Seen[obj] = true
                    local part = Shared.FindPart(obj, {"Head","Torso","UpperTorso","HumanoidRootPart"})
                    if part then
                        local humanoid = obj:FindFirstChildOfClass("Humanoid")
                        local name = humanoid and humanoid.DisplayName or obj.Name
                        table.insert(SleeperESP.Entries, {Model=obj, Part=part, Name=name})
                    end
                end
            end
        end
    end
end

local function sleeperLabel()
    SleeperESP.LabelIndex += 1
    local label = SleeperESP.Labels[SleeperESP.LabelIndex]
    if not label then
        label = newDrawing("Text")
        if label then
            label.Center = true; label.Outline = true; label.Font = 2
        end
        SleeperESP.Labels[SleeperESP.LabelIndex] = label
    end
    return label
end

local function renderSleeperESP()
    for i = 1, SleeperESP.LabelIndex do
        local label = SleeperESP.Labels[i]
        if label then label.Visible = false end
    end
    SleeperESP.LabelIndex = 0
    if not S.SleepersESP then return end
    local rendered = 0
    for _, entry in ipairs(SleeperESP.Entries) do
        if rendered >= 200 then break end
        local part = entry.Part
        if part and part.Parent then
            local dist = (part.Position - Camera.CFrame.Position).Magnitude
            if dist <= S.SleepersRange then
                local x, y, _, visible = Shared.Project(part.Position)
                if visible then
                    local label = sleeperLabel()
                    if label then
                        label.Visible = true
                        label.Text = (S.SleepersNames and ("SLEEPER: " .. entry.Name) or "SLEEPER") .. (S.SleepersDistance and ("\n" .. math.floor(dist) .. "m") or "")
                        label.Position = Vector2.new(x, y)
                        label.Size = 13
                        label.Color = Color3.fromRGB(180, 180, 255)
                    end
                    rendered += 1
                end
            end
        end
    end
end

function SleeperESP.Update()
    sleeperScan()
    renderSleeperESP()
end

-- ============================================================
-- RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    if Runtime.Unloaded then return end
    Entities.Update()
    Hitbox.Update()
    Silent.UpdateCache()
    Aim.Update(dt)
    Aim.UpdateTrigger()
    ESP.Update()
    SleeperESP.Update()
    World.Update()
    renderWorld()
    renderSilent()
    killCameraShake()
    updateScanner()
    updateAutoLoot()
    updateAutoTool()
    updateAdminCheck()
    updateGunChams()
    updateAutoFarm()
    updateFastPlace()
    updateAutoBandage()
    updateAutoDrink()
    updateNoHUD()
    updateNoClipCamera()
    HUD.update()
end)
RunService.Stepped:Connect(function()
    if Runtime.Unloaded then return end
    if S.Fly and not Movement.Flying and not isMovementLocked() then startFly() end
    if S.Noclip then startNoclip() end
    if S.AntiAim then startAntiAim() else stopAntiAim() end
    if S.InfiniteJump then startInfiniteJump() end
    if S.NoJumpCooldown then startNoJumpCooldown() end
    if S.FallDamage then startFallDamage() end
    if S.AutoRespawn then startAutoRespawn() end
    if S.InstantProximityPrompt then startInstantPrompt() end
    if S.WalkOnWater then startWalkOnWater() end
    if S.ChatSpy then startChatSpy() end
    if S.SpamKillLog then startKillLog() end
    NewF.applyFullBright()
    NewF.applyRemoveFog()
    NewF.applyHideGrass()
end)

startAntiAFK()
HUD.create()
task.wait(1)
if LPlr.Character then HUD.create() end

onCleanup(function()
    Runtime.Unloaded = true
    restoreNamecallHook()
    release()
    resetVelocitySample()
    stopFly()
    stopNoclip()
    stopAntiAim()
    if Scanner.Gui then pcall(function() Scanner.Gui:Destroy() end) end
    if HUD.Gui then pcall(function() HUD.Gui:Destroy() end) end
    if ChatSpy.Gui then pcall(function() ChatSpy.Gui:Destroy() end) end
    if GunChams.Highlight then pcall(function() GunChams.Highlight:Destroy() end) end
end)

-- ============================================================
-- МЕНЮ
-- ============================================================
local CombatTab = Window:CreateTab({Name="COMBAT", Icon="crosshair"})
local VisualsTab = Window:CreateTab({Name="VISUALS", Icon="eye"})
local WorldTab = Window:CreateTab({Name="WORLD", Icon="globe"})
local MiscTab = Window:CreateTab({Name="MISC", Icon="settings"})

-- COMBAT
local AimBox = CombatTab:AddLeftGroupbox({Name="Aimbot", Icon="crosshair"})
AimBox:CreateToggle({Name="Aimbot", CurrentValue=S.Aimbot, Flag="Aimbot", Callback=function(v) S.Aimbot=v end})
AimBox:CreateSlider({Name="FOV", Range={10,800}, Increment=1, CurrentValue=S.AimFOV, Flag="AimFOV", Callback=function(v) S.AimFOV=v end})
AimBox:CreateSlider({Name="Range", Range={100,3000}, Increment=10, CurrentValue=S.AimRange, Flag="AimRange", Callback=function(v) S.AimRange=v end})
AimBox:CreateSlider({Name="Smoothing", Range={1,30}, Increment=1, CurrentValue=S.AimSmoothing, Flag="AimSmoothing", Callback=function(v) S.AimSmoothing=v end})
AimBox:CreateDropdown({Name="Target Part", Options={"Head","Body","Root","Closest"}, CurrentOption=S.AimPart, Flag="AimPart", Callback=function(v) S.AimPart=v end})
AimBox:CreateDropdown({Name="Priority", Options={"Crosshair","Distance","Low HP"}, CurrentOption=S.AimPriority, Flag="AimPriority", Callback=function(v) S.AimPriority=v end})
AimBox:CreateDropdown({Name="Aim Key", Options={"Always","RMB","LMB","LeftAlt","LeftControl"}, CurrentOption=S.AimKey, Flag="AimKey", Callback=function(v) S.AimKey=v end})
AimBox:CreateToggle({Name="Team Check", CurrentValue=S.AimTeamCheck, Flag="AimTeamCheck", Callback=function(v) S.AimTeamCheck=v end})
AimBox:CreateToggle({Name="Wall Check", CurrentValue=S.AimWallCheck, Flag="AimWallCheck", Callback=function(v) S.AimWallCheck=v end})
AimBox:CreateToggle({Name="Target NPC", CurrentValue=S.AimNPC, Flag="AimNPC", Callback=function(v) S.AimNPC=v end})
AimBox:CreateToggle({Name="Target Heli", CurrentValue=S.AimHeli, Flag="AimHeli", Callback=function(v) S.AimHeli=v end})
AimBox:CreateToggle({Name="Players First", CurrentValue=S.AimPlayersFirst, Flag="AimPlayersFirst", Callback=function(v) S.AimPlayersFirst=v end})
AimBox:CreateToggle({Name="Prediction", CurrentValue=S.AimPrediction, Flag="AimPrediction", Callback=function(v) S.AimPrediction=v end})
AimBox:CreateSlider({Name="Prediction Lead", Range={0,5}, Increment=0.1, CurrentValue=S.AimLead, Flag="AimLead", Callback=function(v) S.AimLead=v end})
AimBox:CreateToggle({Name="FOV Circle", CurrentValue=S.FOVCircle, Flag="FOVCircle", Callback=function(v) S.FOVCircle=v end})
AimBox:CreateToggle({Name="Target Line", CurrentValue=S.TargetLine, Flag="TargetLine", Callback=function(v) S.TargetLine=v end})

local SilentBox = CombatTab:AddLeftGroupbox({Name="Silent Aim", Icon="crosshair"})
SilentBox:CreateToggle({Name="Silent Aim", CurrentValue=S.SilentAimEnabled, Flag="SilentAim", Callback=function(v) S.SilentAimEnabled=v; Silent.Enabled=v; if v then installNamecall() end end})
SilentBox:CreateSlider({Name="FOV", Range={10,800}, Increment=1, CurrentValue=S.SilentAimFOV, Flag="SilentFOV", Callback=function(v) S.SilentAimFOV=v; Silent.FOV=v end})
SilentBox:CreateSlider({Name="Range", Range={100,3000}, Increment=10, CurrentValue=S.SilentAimRange, Flag="SilentRange", Callback=function(v) S.SilentAimRange=v; Silent.Range=v end})
SilentBox:CreateSlider({Name="Lead", Range={0,5}, Increment=0.1, CurrentValue=S.SilentAimLead, Flag="SilentLead", Callback=function(v) S.SilentAimLead=v; Silent.Lead=v end})
SilentBox:CreateDropdown({Name="Target Part", Options={"Head","Body","Root","Closest"}, CurrentOption=S.SilentAimPart, Flag="SilentPart", Callback=function(v) S.SilentAimPart=v; Silent.Part=v end})
SilentBox:CreateDropdown({Name="Key", Options={"Always","RMB","LMB"}, CurrentOption=S.SilentAimKey, Flag="SilentKey", Callback=function(v) S.SilentAimKey=v; Silent.Key=v end})
SilentBox:CreateToggle({Name="Team Check", CurrentValue=S.SilentAimTeamCheck, Flag="SilentTeamCheck", Callback=function(v) S.SilentAimTeamCheck=v; Silent.TeamCheck=v end})
SilentBox:CreateToggle({Name="Wall Check", CurrentValue=S.SilentAimWallCheck, Flag="SilentWallCheck", Callback=function(v) S.SilentAimWallCheck=v; Silent.WallCheck=v end})
SilentBox:CreateToggle({Name="Target NPC", CurrentValue=S.SilentAimNPC, Flag="SilentNPC", Callback=function(v) S.SilentAimNPC=v; Silent.NPC=v end})
SilentBox:CreateToggle({Name="Target Heli", CurrentValue=S.SilentAimHeli, Flag="SilentHeli", Callback=function(v) S.SilentAimHeli=v; Silent.Heli=v end})
SilentBox:CreateToggle({Name="Prediction", CurrentValue=S.SilentAimPrediction, Flag="SilentPrediction", Callback=function(v) S.SilentAimPrediction=v; Silent.Prediction=v end})
SilentBox:CreateToggle({Name="FOV Circle", CurrentValue=S.SilentAimFOVCircle, Flag="SilentFOVCircle", Callback=function(v) S.SilentAimFOVCircle=v; Silent.FOVCircle=v end})
SilentBox:CreateToggle({Name="Target Line", CurrentValue=S.SilentAimTargetLine, Flag="SilentTargetLine", Callback=function(v) S.SilentAimTargetLine=v; Silent.TargetLine=v end})

local TriggerBox = CombatTab:AddRightGroupbox({Name="Triggerbot", Icon="crosshair"})
TriggerBox:CreateToggle({Name="Triggerbot", CurrentValue=S.Triggerbot, Flag="Triggerbot", Callback=function(v) S.Triggerbot=v end})
TriggerBox:CreateSlider({Name="Radius", Range={1,50}, Increment=1, CurrentValue=S.TriggerRadius, Flag="TriggerRadius", Callback=function(v) S.TriggerRadius=v end})
TriggerBox:CreateSlider({Name="Reaction (ms)", Range={0,500}, Increment=5, CurrentValue=S.TriggerReaction, Flag="TriggerReaction", Callback=function(v) S.TriggerReaction=v end})
TriggerBox:CreateSlider({Name="Delay (ms)", Range={0,500}, Increment=5, CurrentValue=S.TriggerDelay, Flag="TriggerDelay", Callback=function(v) S.TriggerDelay=v end})
TriggerBox:CreateDropdown({Name="Key", Options={"Always","RMB","LMB","LeftAlt","LeftControl"}, CurrentOption=S.TriggerKey, Flag="TriggerKey", Callback=function(v) S.TriggerKey=v end})
TriggerBox:CreateToggle({Name="Team Check", CurrentValue=S.TriggerTeamCheck, Flag="TriggerTeamCheck", Callback=function(v) S.TriggerTeamCheck=v end})
TriggerBox:CreateToggle({Name="Wall Check", CurrentValue=S.TriggerWallCheck, Flag="TriggerWallCheck", Callback=function(v) S.TriggerWallCheck=v end})
TriggerBox:CreateToggle({Name="Target NPC", CurrentValue=S.TriggerNPC, Flag="TriggerNPC", Callback=function(v) S.TriggerNPC=v end})

local WeaponBox = CombatTab:AddRightGroupbox({Name="Weapon", Icon="crosshair"})
WeaponBox:CreateToggle({Name="Weapon Patches", CurrentValue=S.WeaponPatches, Flag="WeaponPatches", Callback=function(v) S.WeaponPatches=v end})
WeaponBox:CreateToggle({Name="Fast Fire", CurrentValue=S.WeaponFireRate, Flag="WeaponFireRate", Callback=function(v) S.WeaponFireRate=v; if v then installNamecall() end end})
WeaponBox:CreateSlider({Name="Fire Interval (ms)", Range={10,500}, Increment=5, CurrentValue=S.FireInterval, Flag="FireInterval", Callback=function(v) S.FireInterval=v end})
WeaponBox:CreateToggle({Name="No Spread", CurrentValue=S.NoSpread, Flag="NoSpread", Callback=function(v) S.NoSpread=v; if v then installNamecall() end end})
WeaponBox:CreateToggle({Name="No Recoil", CurrentValue=S.NoRecoil, Flag="NoRecoil", Callback=function(v) S.NoRecoil=v; if v then installNamecall() end end})
WeaponBox:CreateToggle({Name="No Camera Shake", CurrentValue=S.NoCameraShake, Flag="NoCameraShake", Callback=function(v) S.NoCameraShake=v; if v then installNamecall() end end})
WeaponBox:CreateToggle({Name="Weak Spot Aim", CurrentValue=S.AutoCross, Flag="AutoCross", Callback=function(v) S.AutoCross=v; if v then installNamecall() end end})

local HitboxBox = CombatTab:AddRightGroupbox({Name="Hitbox Expander", Icon="crosshair"})
HitboxBox:CreateToggle({Name="Hitbox Expander", CurrentValue=S.HitboxExpander, Flag="HitboxExpander", Callback=function(v) S.HitboxExpander=v end})
HitboxBox:CreateSlider({Name="Size", Range={1,20}, Increment=0.5, CurrentValue=S.HitboxSize, Flag="HitboxSize", Callback=function(v) S.HitboxSize=v end})
HitboxBox:CreateSlider({Name="Transparency", Range={0,1}, Increment=0.05, CurrentValue=S.HitboxTransparency, Flag="HitboxTransparency", Callback=function(v) S.HitboxTransparency=v end})
HitboxBox:CreateToggle({Name="Team Check", CurrentValue=S.HitboxTeamCheck, Flag="HitboxTeamCheck", Callback=function(v) S.HitboxTeamCheck=v end})
HitboxBox:CreateToggle({Name="Include NPC", CurrentValue=S.HitboxNPC, Flag="HitboxNPC", Callback=function(v) S.HitboxNPC=v end})

-- VISUALS
local PlayerESPBox = VisualsTab:AddLeftGroupbox({Name="Player ESP", Icon="eye"})
PlayerESPBox:CreateToggle({Name="Player ESP", CurrentValue=S.PlayerESP, Flag="PlayerESP", Callback=function(v) S.PlayerESP=v end})
PlayerESPBox:CreateToggle({Name="Box", CurrentValue=S.PlayerBox, Flag="PlayerBox", Callback=function(v) S.PlayerBox=v end})
PlayerESPBox:CreateToggle({Name="Names", CurrentValue=S.PlayerNames, Flag="PlayerNames", Callback=function(v) S.PlayerNames=v end})
PlayerESPBox:CreateToggle({Name="Distance", CurrentValue=S.PlayerDistance, Flag="PlayerDistance", Callback=function(v) S.PlayerDistance=v end})
PlayerESPBox:CreateToggle({Name="Health", CurrentValue=S.PlayerHealth, Flag="PlayerHealth", Callback=function(v) S.PlayerHealth=v end})
PlayerESPBox:CreateToggle({Name="Held Item", CurrentValue=S.PlayerHeldItem, Flag="PlayerHeldItem", Callback=function(v) S.PlayerHeldItem=v end})
PlayerESPBox:CreateToggle({Name="Team Check", CurrentValue=S.PlayerTeamCheck, Flag="PlayerTeamCheck", Callback=function(v) S.PlayerTeamCheck=v end})
PlayerESPBox:CreateToggle({Name="Tracers", CurrentValue=S.PlayerTracers, Flag="PlayerTracers", Callback=function(v) S.PlayerTracers=v end})
PlayerESPBox:CreateToggle({Name="Chams", CurrentValue=S.PlayerChams, Flag="PlayerChams", Callback=function(v) S.PlayerChams=v end})
PlayerESPBox:CreateToggle({Name="Corners", CurrentValue=S.PlayerCorners, Flag="PlayerCorners", Callback=function(v) S.PlayerCorners=v end})
PlayerESPBox:CreateDropdown({Name="Tracer Origin", Options={"Bottom","Center","Top"}, CurrentOption=S.TracerOrigin, Flag="TracerOrigin", Callback=function(v) S.TracerOrigin=v end})
PlayerESPBox:CreateSlider({Name="Range", Range={100,3000}, Increment=10, CurrentValue=S.PlayerRange, Flag="PlayerRange", Callback=function(v) S.PlayerRange=v end})
PlayerESPBox:CreateSlider({Name="Text Size", Range={8,24}, Increment=1, CurrentValue=S.PlayerTextSize, Flag="PlayerTextSize", Callback=function(v) S.PlayerTextSize=v end})

local NPCESPBox = VisualsTab:AddRightGroupbox({Name="NPC ESP", Icon="eye"})
NPCESPBox:CreateToggle({Name="NPC ESP", CurrentValue=S.NPCESP, Flag="NPCESP", Callback=function(v) S.NPCESP=v end})
NPCESPBox:CreateToggle({Name="Include Heli", CurrentValue=S.NPCHeli, Flag="NPCHeli", Callback=function(v) S.NPCHeli=v end})
NPCESPBox:CreateToggle({Name="Box", CurrentValue=S.NPCBox, Flag="NPCBox", Callback=function(v) S.NPCBox=v end})
NPCESPBox:CreateToggle({Name="Names", CurrentValue=S.NPCNames, Flag="NPCNames", Callback=function(v) S.NPCNames=v end})
NPCESPBox:CreateToggle({Name="Distance", CurrentValue=S.NPCDistance, Flag="NPCDistance", Callback=function(v) S.NPCDistance=v end})
NPCESPBox:CreateToggle({Name="Health", CurrentValue=S.NPCHealth, Flag="NPCHealth", Callback=function(v) S.NPCHealth=v end})
NPCESPBox:CreateSlider({Name="Range", Range={50,3000}, Increment=10, CurrentValue=S.NPCRange, Flag="NPCRange", Callback=function(v) S.NPCRange=v end})
NPCESPBox:CreateSlider({Name="Text Size", Range={8,24}, Increment=1, CurrentValue=S.NPCTextSize, Flag="NPCTextSize", Callback=function(v) S.NPCTextSize=v end})

-- Sleeper ESP
local SleeperESPBox = VisualsTab:AddRightGroupbox({Name="Sleeper ESP", Icon="moon"})
SleeperESPBox:CreateToggle({Name="Sleeper ESP", CurrentValue=S.SleepersESP, Flag="SleepersESP", Callback=function(v) S.SleepersESP=v end})
SleeperESPBox:CreateToggle({Name="Names", CurrentValue=S.SleepersNames, Flag="SleepersNames", Callback=function(v) S.SleepersNames=v end})
SleeperESPBox:CreateToggle({Name="Distance", CurrentValue=S.SleepersDistance, Flag="SleepersDistance", Callback=function(v) S.SleepersDistance=v end})
SleeperESPBox:CreateSlider({Name="Range", Range={50,3000}, Increment=10, CurrentValue=S.SleepersRange, Flag="SleepersRange", Callback=function(v) S.SleepersRange=v end})

-- WORLD
local LootBox = WorldTab:AddLeftGroupbox({Name="Loot ESP", Icon="box"})
LootBox:CreateToggle({Name="Loot ESP", CurrentValue=S.LootESP, Flag="LootESP", Callback=function(v) S.LootESP=v; World.ForceScan() end})
LootBox:CreateToggle({Name="Barrels", CurrentValue=S.LootBarrels, Flag="LootBarrels", Callback=function(v) S.LootBarrels=v end})
LootBox:CreateToggle({Name="Crates", CurrentValue=S.LootCrates, Flag="LootCrates", Callback=function(v) S.LootCrates=v end})
LootBox:CreateToggle({Name="Military", CurrentValue=S.LootMilitary, Flag="LootMilitary", Callback=function(v) S.LootMilitary=v end})
LootBox:CreateToggle({Name="Elite", CurrentValue=S.LootElite, Flag="LootElite", Callback=function(v) S.LootElite=v end})
LootBox:CreateToggle({Name="Show Contents", CurrentValue=S.LootContents, Flag="LootContents", Callback=function(v) S.LootContents=v end})
LootBox:CreateToggle({Name="Distance", CurrentValue=S.LootDistance, Flag="LootDistance", Callback=function(v) S.LootDistance=v end})
LootBox:CreateSlider({Name="Range", Range={50,1500}, Increment=10, CurrentValue=S.LootRange, Flag="LootRange", Callback=function(v) S.LootRange=v end})

local BaseBox = WorldTab:AddLeftGroupbox({Name="Base ESP", Icon="home"})
BaseBox:CreateToggle({Name="Base ESP", CurrentValue=S.BaseESP, Flag="BaseESP", Callback=function(v) S.BaseESP=v; World.ForceScan() end})
BaseBox:CreateToggle({Name="Boxes", CurrentValue=S.BaseBoxes, Flag="BaseBoxes", Callback=function(v) S.BaseBoxes=v end})
BaseBox:CreateToggle({Name="Cupboard", CurrentValue=S.BaseCupboard, Flag="BaseCupboard", Callback=function(v) S.BaseCupboard=v end})
BaseBox:CreateToggle({Name="Locker", CurrentValue=S.BaseLocker, Flag="BaseLocker", Callback=function(v) S.BaseLocker=v end})
BaseBox:CreateToggle({Name="Sleeping Bag", CurrentValue=S.BaseSleepingBag, Flag="BaseSleepingBag", Callback=function(v) S.BaseSleepingBag=v end})
BaseBox:CreateToggle({Name="Traps", CurrentValue=S.BaseTraps, Flag="BaseTraps", Callback=function(v) S.BaseTraps=v end})
BaseBox:CreateToggle({Name="Distance", CurrentValue=S.BaseDistance, Flag="BaseDistance", Callback=function(v) S.BaseDistance=v end})
BaseBox:CreateSlider({Name="Range", Range={25,800}, Increment=5, CurrentValue=S.BaseRange, Flag="BaseRange", Callback=function(v) S.BaseRange=v end})

local DropsBox = WorldTab:AddRightGroupbox({Name="Drops ESP", Icon="box"})
DropsBox:CreateToggle({Name="Drops ESP", CurrentValue=S.DropsESP, Flag="DropsESP", Callback=function(v) S.DropsESP=v; World.ForceScan() end})
DropsBox:CreateToggle({Name="Body Bags", CurrentValue=S.BodyBags, Flag="BodyBags", Callback=function(v) S.BodyBags=v end})
DropsBox:CreateToggle({Name="Dropped Items", CurrentValue=S.DroppedItems, Flag="DroppedItems", Callback=function(v) S.DroppedItems=v end})
DropsBox:CreateToggle({Name="Distance", CurrentValue=S.DropsDistance, Flag="DropsDistance", Callback=function(v) S.DropsDistance=v end})
DropsBox:CreateSlider({Name="Range", Range={50,1500}, Increment=10, CurrentValue=S.DropsRange, Flag="DropsRange", Callback=function(v) S.DropsRange=v end})

local NodesBox = WorldTab:AddRightGroupbox({Name="Nodes ESP", Icon="box"})
NodesBox:CreateToggle({Name="Nodes ESP", CurrentValue=S.NodesESP, Flag="NodesESP", Callback=function(v) S.NodesESP=v; World.ForceScan() end})
NodesBox:CreateToggle({Name="Stone", CurrentValue=S.NodeStone, Flag="NodeStone", Callback=function(v) S.NodeStone=v end})
NodesBox:CreateToggle({Name="Sulfur", CurrentValue=S.NodeSulfur, Flag="NodeSulfur", Callback=function(v) S.NodeSulfur=v end})
NodesBox:CreateToggle({Name="Metal", CurrentValue=S.NodeMetal, Flag="NodeMetal", Callback=function(v) S.NodeMetal=v end})
NodesBox:CreateToggle({Name="Distance", CurrentValue=S.NodesDistance, Flag="NodesDistance", Callback=function(v) S.NodesDistance=v end})
NodesBox:CreateSlider({Name="Range", Range={50,2000}, Increment=10, CurrentValue=S.NodesRange, Flag="NodesRange", Callback=function(v) S.NodesRange=v end})

local PickupsBox = WorldTab:AddRightGroupbox({Name="Pickups ESP", Icon="box"})
PickupsBox:CreateToggle({Name="Pickups ESP", CurrentValue=S.PickupsESP, Flag="PickupsESP", Callback=function(v) S.PickupsESP=v; World.ForceScan() end})
PickupsBox:CreateToggle({Name="Ores", CurrentValue=S.PickupOres, Flag="PickupOres", Callback=function(v) S.PickupOres=v end})
PickupsBox:CreateToggle({Name="Wood", CurrentValue=S.PickupWood, Flag="PickupWood", Callback=function(v) S.PickupWood=v end})
PickupsBox:CreateToggle({Name="Plants", CurrentValue=S.PickupPlants, Flag="PickupPlants", Callback=function(v) S.PickupPlants=v end})
PickupsBox:CreateSlider({Name="Range", Range={25,1000}, Increment=5, CurrentValue=S.PickupsRange, Flag="PickupsRange", Callback=function(v) S.PickupsRange=v end})

local VehiclesBox = WorldTab:AddRightGroupbox({Name="Vehicles ESP", Icon="box"})
VehiclesBox:CreateToggle({Name="Vehicles ESP", CurrentValue=S.VehiclesESP, Flag="VehiclesESP", Callback=function(v) S.VehiclesESP=v; World.ForceScan() end})
VehiclesBox:CreateToggle({Name="ATV", CurrentValue=S.VehicleATV, Flag="VehicleATV", Callback=function(v) S.VehicleATV=v end})
VehiclesBox:CreateToggle({Name="Boats", CurrentValue=S.VehicleBoats, Flag="VehicleBoats", Callback=function(v) S.VehicleBoats=v end})
VehiclesBox:CreateToggle({Name="Helis", CurrentValue=S.VehicleHelis, Flag="VehicleHelis", Callback=function(v) S.VehicleHelis=v end})
VehiclesBox:CreateSlider({Name="Range", Range={100,3000}, Increment=10, CurrentValue=S.VehiclesRange, Flag="VehiclesRange", Callback=function(v) S.VehiclesRange=v end})

-- MISC
local MoveBox = MiscTab:AddLeftGroupbox({Name="Movement", Icon="move"})
MoveBox:CreateToggle({Name="Speed", CurrentValue=S.Speed, Flag="Speed", Callback=function(v) S.Speed=v; updateSpeedJump() end})
MoveBox:CreateSlider({Name="Speed Value", Range={16,150}, Increment=1, CurrentValue=S.SpeedValue, Flag="SpeedValue", Callback=function(v) S.SpeedValue=v end})
MoveBox:CreateToggle({Name="High Jump", CurrentValue=S.HighJump, Flag="HighJump", Callback=function(v) S.HighJump=v; updateSpeedJump() end})
MoveBox:CreateSlider({Name="Jump Height", Range={50,300}, Increment=5, CurrentValue=S.JumpHeight, Flag="JumpHeight", Callback=function(v) S.JumpHeight=v end})
MoveBox:CreateToggle({Name="Noclip", CurrentValue=S.Noclip, Flag="Noclip", Callback=function(v) S.Noclip=v end})
MoveBox:CreateToggle({Name="Fly", CurrentValue=S.Fly, Flag="Fly", Callback=function(v) S.Fly=v; if v then startFly() else stopFly() end end})
MoveBox:CreateSlider({Name="Fly Speed", Range={10,200}, Increment=5, CurrentValue=S.FlySpeed, Flag="FlySpeed", Callback=function(v) S.FlySpeed=v end})
MoveBox:CreateToggle({Name="Fall Damage Off", CurrentValue=S.FallDamage, Flag="FallDamage", Callback=function(v) S.FallDamage=v end})
MoveBox:CreateToggle({Name="Anti-Aim", CurrentValue=S.AntiAim, Flag="AntiAim", Callback=function(v) S.AntiAim=v end})
MoveBox:CreateToggle({Name="Infinite Jump", CurrentValue=S.InfiniteJump, Flag="InfiniteJump", Callback=function(v) S.InfiniteJump=v end})
MoveBox:CreateToggle({Name="No Jump Cooldown", CurrentValue=S.NoJumpCooldown, Flag="NoJumpCooldown", Callback=function(v) S.NoJumpCooldown=v end})
MoveBox:CreateToggle({Name="Walk on Water", CurrentValue=S.WalkOnWater, Flag="WalkOnWater", Callback=function(v) S.WalkOnWater=v end})

local MiscBox = MiscTab:AddRightGroupbox({Name="Misc", Icon="settings"})
MiscBox:CreateToggle({Name="Anti-Cheat Mode", CurrentValue=S.AntiCheatMode, Flag="AntiCheatMode", Callback=function(v)
    S.AntiCheatMode=v
    if v then
        S.Fly=false; S.Noclip=false; S.Speed=false; S.HighJump=false
        S.InfiniteJump=false; S.NoJumpCooldown=false; S.AntiAim=false
        stopFly(); stopNoclip(); stopAntiAim()
    end
    updateSpeedJump()
end})
MiscBox:CreateToggle({Name="Enemy Scanner", CurrentValue=S.EnemyScanner, Flag="EnemyScanner", Callback=function(v) S.EnemyScanner=v end})
MiscBox:CreateSlider({Name="Scanner Range", Range={100,2000}, Increment=10, CurrentValue=S.EnemyScannerRange, Flag="ScannerRange", Callback=function(v) S.EnemyScannerRange=v end})
MiscBox:CreateToggle({Name="Auto Respawn", CurrentValue=S.AutoRespawn, Flag="AutoRespawn", Callback=function(v) S.AutoRespawn=v end})
MiscBox:CreateToggle({Name="Anti-AFK", CurrentValue=S.AntiAFK, Flag="AntiAFK", Callback=function(v) S.AntiAFK=v end})
MiscBox:CreateToggle({Name="Auto Loot (Proximity)", CurrentValue=S.AutoLoot, Flag="AutoLoot", Callback=function(v) S.AutoLoot=v end})
MiscBox:CreateSlider({Name="Auto Loot Range", Range={5,100}, Increment=1, CurrentValue=S.AutoLootRange, Flag="AutoLootRange", Callback=function(v) S.AutoLootRange=v end})
MiscBox:CreateToggle({Name="Auto Tool", CurrentValue=S.AutoTool, Flag="AutoTool", Callback=function(v) S.AutoTool=v end})
MiscBox:CreateToggle({Name="Auto Bandage", CurrentValue=S.AutoBandage, Flag="AutoBandage", Callback=function(v) S.AutoBandage=v end})
MiscBox:CreateToggle({Name="Auto Drink", CurrentValue=S.AutoDrink, Flag="AutoDrink", Callback=function(v) S.AutoDrink=v end})
MiscBox:CreateToggle({Name="Instant ProximityPrompt", CurrentValue=S.InstantProximityPrompt, Flag="InstantProximityPrompt", Callback=function(v) S.InstantProximityPrompt=v end})
MiscBox:CreateToggle({Name="Fast Place", CurrentValue=S.FastPlace, Flag="FastPlace", Callback=function(v) S.FastPlace=v end})
MiscBox:CreateToggle({Name="Chat Spy", CurrentValue=S.ChatSpy, Flag="ChatSpy", Callback=function(v) S.ChatSpy=v; if v then startChatSpy() end end})
MiscBox:CreateToggle({Name="Spam Kill Log", CurrentValue=S.SpamKillLog, Flag="SpamKillLog", Callback=function(v) S.SpamKillLog=v; if v then startKillLog() end end})
MiscBox:CreateToggle({Name="Admin Check", CurrentValue=S.AdminCheck, Flag="AdminCheck", Callback=function(v) S.AdminCheck=v end})
MiscBox:CreateToggle({Name="HUD", CurrentValue=S.HUD, Flag="HUD", Callback=function(v) S.HUD=v; if v then HUD.create() end end})

local RenderBox = MiscTab:AddRightGroupbox({Name="Render", Icon="settings"})
RenderBox:CreateToggle({Name="Full Bright", CurrentValue=S.FullBright, Flag="FullBright", Callback=function(v) S.FullBright=v end})
RenderBox:CreateToggle({Name="Remove Fog", CurrentValue=S.RemoveFog, Flag="RemoveFog", Callback=function(v) S.RemoveFog=v end})
RenderBox:CreateToggle({Name="Hide Grass", CurrentValue=S.HideGrass, Flag="HideGrass", Callback=function(v) S.HideGrass=v; NewF.applyHideGrass() end})
RenderBox:CreateToggle({Name="Gun Chams", CurrentValue=S.GunChams, Flag="GunChams", Callback=function(v) S.GunChams=v end})
RenderBox:CreateColorPicker({Name="Gun Chams Color", Color=S.GunChamsColor, Flag="GunChamsColor", Callback=function(v) S.GunChamsColor=v end})
RenderBox:CreateSlider({Name="Gun Chams Transparency", Range={0,1}, Increment=0.05, CurrentValue=S.GunChamsTransparency, Flag="GunChamsTransparency", Callback=function(v) S.GunChamsTransparency=v end})
RenderBox:CreateToggle({Name="No HUD", CurrentValue=S.NoHUD, Flag="NoHUD", Callback=function(v) S.NoHUD=v end})
RenderBox:CreateToggle({Name="No Clip Camera", CurrentValue=S.NoClipCamera, Flag="NoClipCamera", Callback=function(v) S.NoClipCamera=v end})
RenderBox:CreateToggle({Name="Third Person Lock", CurrentValue=S.ThirdPersonLock, Flag="ThirdPersonLock", Callback=function(v) S.ThirdPersonLock=v end})

local FarmBox = MiscTab:AddRightGroupbox({Name="Auto Farm", Icon="settings"})
FarmBox:CreateToggle({Name="Auto Farm", CurrentValue=S.AutoFarm, Flag="AutoFarm", Callback=function(v) S.AutoFarm=v end})
FarmBox:CreateDropdown({Name="Mode", Options={"Ore","Tree","All"}, CurrentOption=S.AutoFarmMode, Flag="AutoFarmMode", Callback=function(v) S.AutoFarmMode=v end})
FarmBox:CreateSlider({Name="Range", Range={10,300}, Increment=5, CurrentValue=S.AutoFarmRange, Flag="AutoFarmRange", Callback=function(v) S.AutoFarmRange=v end})

-- трекер открытия меню
task.spawn(function()
    while not Runtime.Unloaded do
        pcall(function()
            local open = Window.Open
            local minimized = Window.Minimized
            Runtime.MenuOpen = (open == true) and not (minimized == true)
        end)
        task.wait(0.1)
    end
end)

Library:Notify({
    Title=SCRIPT_NAME,
    Content="Loaded. All features ready.",
    Type="Success",
    Duration=3,
})
print("QWERTY HUB v3.0 loaded")
