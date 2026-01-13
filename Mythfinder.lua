
Mythfinder_SelectedSpec = "None" 


-----------------------------------------------------------------------------------------
-------------------------ОСНОВНОЕ ОКНО АДДОНА--------------------------------------------
-----------------------------------------------------------------------------------------
local Mythfinder = CreateFrame("Frame", "MythfinderFrame", UIParent)
Mythfinder:SetSize(450, 280)
Mythfinder:SetPoint("CENTER")
Mythfinder:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
Mythfinder:SetBackdropColor(0, 0, 0, 0.9)
Mythfinder:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
Mythfinder:SetMovable(true)
Mythfinder:EnableMouse(true)
Mythfinder:RegisterForDrag("LeftButton")
Mythfinder:SetScript("OnDragStart", Mythfinder.StartMoving)
Mythfinder:SetScript("OnDragStop", Mythfinder.StopMovingOrSizing)


local function GetMyItemLevel()
    local totalILvl = 0
    local itemCount = 0
    
    for i = 1, 18 do
        if i ~= 4 then 
            local itemLink = GetInventoryItemLink("player", i)
            if itemLink then
                local _, _, _, iLevel = GetItemInfo(itemLink)
                if iLevel then
                    totalILvl = totalILvl + iLevel
                    itemCount = itemCount + 1
                end
            end
        end
    end


    if itemCount == 0 then return 0 end
    return math.floor(totalILvl / itemCount)
end



tinsert(UISpecialFrames, "MythfinderFrame")

-----------------------------------------------------------------------------------------
-------------------------КНОПКА ЗАКРЫТЬ--------------------------------------------------
-----------------------------------------------------------------------------------------
local closeBtn = CreateFrame("Button", nil, Mythfinder)
closeBtn:SetSize(20, 18)
closeBtn:SetPoint("TOPRIGHT", Mythfinder, "TOPRIGHT", -2, -2)
closeBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
closeBtn:SetBackdropColor(0.2, 0.2, 0.2, 1)
closeBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
closeText:SetPoint("CENTER", 0, 0)
closeText:SetText("X")
closeText:SetTextColor(1.0, 1.0, 1.0)
closeBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.5, 0.2, 0.2, 1) end)
closeBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.2, 0.2, 0.2, 1) end)
closeBtn:SetScript("OnClick", function() Mythfinder:Hide() end)

-----------------------------------------------------------------------------------------
-------------------------КНОПКА РЕЗЕТ----------------------------------------------------
-----------------------------------------------------------------------------------------
local resetBtn = CreateFrame("Button", nil, Mythfinder)
resetBtn:SetSize(50, 18)
resetBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
resetBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
resetBtn:SetBackdropColor(0.2, 0.2, 0.2, 1)
resetBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

local resetText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
resetText:SetPoint("CENTER", 0, 0)
resetText:SetText("Reset")
resetText:SetTextColor(0.8, 0.8, 0.8)

resetBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.3, 0.3, 0.3, 1) end)
resetBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.2, 0.2, 0.2, 1) end)

local title = Mythfinder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("Mythfinder by |cfff48cbaPinkpower|r ver.1.1")

-----------------------------------------------------------------------------------------
-------------------------СПИСОК ИНСТОВ---------------------------------------------------
-----------------------------------------------------------------------------------------
local Dungeons = {
    "Ragefire Chasm", "Wailing Caverns", "Shadowfang Keep", "Blackfathom Deeps",
    "Stockade", "Gnomeregan", "Scarlet Monastery", "Razorfen Kraul",
    "Maraudon", "Uldaman", "Scholomance", "Stratholme", "Blackrock Caverns", "Blackrock Spire", "Dire Maul", "Deadmines", "Zul'Farrak", "Blackrock Depths"
}
table.sort(Dungeons)
table.insert(Dungeons, 1, "All Dungeons")

local Config = { role = "NONE", dungeon = "NONE", levelMin = 0, levelMax = 0, linkAchievement = false }


-- Чекбокс для включения/выключения линка ачивки
local cbAchiev = CreateFrame("CheckButton", "MythfinderCB_Achiev", Mythfinder, "OptionsCheckButtonTemplate")
cbAchiev:SetPoint("TOPLEFT", 20, -40 - (3*25))
cbAchiev:SetSize(22, 22)
_G[cbAchiev:GetName().."Text"]:SetText("Link Achiev")
cbAchiev:SetHitRectInsets(0, -100, 0, 0)
cbAchiev:SetScript("OnClick", function(self)
    Config.linkAchievement = self:GetChecked()
end)

-----------------------------------------------------------------------------------------
-------------------------ОКОШКИ С РОЛЯМИ-------------------------------------------------
-----------------------------------------------------------------------------------------
local function CreateRoleCheckbox(roleName, label, xOffset)
    local cb = CreateFrame("CheckButton", "MythfinderCB_"..roleName, Mythfinder, "OptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20, -40 - (xOffset*25))
    cb:SetSize(22, 22)
    _G[cb:GetName().."Text"]:SetText(label)
    cb:SetHitRectInsets(0, -40, 0, 0)
    cb:SetScript("OnClick", function(self)
        if self:GetChecked() then
            Config.role = roleName
            if roleName ~= "TANK" then MythfinderCB_TANK:SetChecked(false) end
            if roleName ~= "DPS" then MythfinderCB_DPS:SetChecked(false) end
            if roleName ~= "HEAL" then MythfinderCB_HEAL:SetChecked(false) end
        else Config.role = "NONE" end
    end)
    return cb
end

local cbTank = CreateRoleCheckbox("TANK", "TANK", 0)
local cbDps  = CreateRoleCheckbox("DPS", "DPS", 1)
local cbHeal = CreateRoleCheckbox("HEAL", "HEAL", 2)

-----------------------------------------------------------------------------------------
-------------------------ДРОП МЕНЮ ИНСТОВ------------------------------------------------
-----------------------------------------------------------------------------------------
local dropdown = CreateFrame("Frame", "MythfinderDropdown", Mythfinder, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOPLEFT", 110, -50)

_G[dropdown:GetName().."Left"]:Hide()
_G[dropdown:GetName().."Middle"]:Hide()
_G[dropdown:GetName().."Right"]:Hide()

local ddBg = CreateFrame("Frame", nil, dropdown)
ddBg:SetPoint("LEFT", dropdown, "LEFT", 15, 3)
ddBg:SetSize(160, 22)
ddBg:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
ddBg:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
ddBg:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
ddBg:SetFrameLevel(dropdown:GetFrameLevel() - 1)

local ddBtn = _G[dropdown:GetName().."Button"]
ddBtn:ClearAllPoints()
ddBtn:SetPoint("RIGHT", ddBg, "RIGHT", 0, 0)

UIDropDownMenu_SetWidth(dropdown, 140)
UIDropDownMenu_SetText(dropdown, "Select Dungeon")
UIDropDownMenu_Initialize(dropdown, function(self)
    for _, name in ipairs(Dungeons) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = name
        info.func = function()
            Config.dungeon = name
            UIDropDownMenu_SetText(dropdown, name)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-----------------------------------------------------------------------------------------
-------------------------ПОЛЯ УРОВНЕЙ----------------------------------------------------
-----------------------------------------------------------------------------------------
local function CreateNumericBox(name, xOff, labelText)
    local f = CreateFrame("EditBox", name, Mythfinder, "InputBoxTemplate")
    f:SetSize(35, 20)
    f:SetPoint("LEFT", ddBg, "RIGHT", xOff, 0)
    f:SetAutoFocus(false)
    f:SetNumeric(true)
    f:SetMaxLetters(3)
    f:SetText("0")
    local lbl = Mythfinder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 2)
    lbl:SetText(labelText)
    f:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    
    local up = CreateFrame("Button", nil, f)
    up:SetSize(16, 16); up:SetPoint("LEFT", f, "RIGHT", 2, 6)
    up:SetNormalTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Up")
    up:SetScript("OnClick", function() f:SetText((tonumber(f:GetText()) or 0) + 1); f:GetScript("OnTextChanged")(f) end)

    local down = CreateFrame("Button", nil, f)
    down:SetSize(16, 16); down:SetPoint("LEFT", f, "RIGHT", 2, -6)
    down:SetNormalTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Up")
    down:SetScript("OnClick", function() local v = tonumber(f:GetText()) or 0; if v > 0 then f:SetText(v - 1) end; f:GetScript("OnTextChanged")(f) end)
    return f
end

local boxMin = CreateNumericBox("MythBoxMin", 35, "From:")
local boxMax = CreateNumericBox("MythBoxMax", 95, "To (opt):")

boxMin:SetText("1")
boxMax:SetText("0")

boxMin:SetScript("OnTextChanged", function(self) Config.levelMin = tonumber(self:GetText()) or 1 end)
boxMax:SetScript("OnTextChanged", function(self) Config.levelMax = tonumber(self:GetText()) or 0 end)

resetBtn:SetScript("OnClick", function()
    Config.dungeon = "NONE"; 
   -- Config.levelMin = 1;
   -- Config.levelMax = 0;
    
    UIDropDownMenu_SetText(dropdown, "Select Dungeon")
 --   boxMin:SetText("1") 
 --   boxMax:SetText("0")
    print("|cff888888Mythfinder: Настройки сброшены|r")
end)

-----------------------------------------------------------------------------------------
-------------------------ОКНО ЧАТИКА-----------------------------------------------------
-----------------------------------------------------------------------------------------
local msgBg = CreateFrame("Frame", nil, Mythfinder)
msgBg:SetPoint("BOTTOM", Mythfinder, "BOTTOM", 0, 15)
msgBg:SetSize(410, 115)
msgBg:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
msgBg:SetBackdropColor(0, 0, 0, 0.5)
msgBg:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

local msgFrame = CreateFrame("ScrollingMessageFrame", nil, msgBg)
msgFrame:SetSize(380, 105)
msgFrame:SetPoint("LEFT", msgBg, "LEFT", 10, 0)
msgFrame:SetFontObject(GameFontHighlightSmall)
msgFrame:SetMaxLines(50)
msgFrame:SetHyperlinksEnabled(true)
msgFrame:SetFading(false)
msgFrame:SetSpacing(4) 

msgFrame:EnableMouseWheel(true)
msgFrame:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then self:ScrollUp() else self:ScrollDown() end
end)

local btnUp = CreateFrame("Button", nil, msgBg, "UIPanelScrollUpButtonTemplate")
btnUp:SetPoint("TOPRIGHT", msgBg, "TOPRIGHT", -4, -4)
btnUp:SetSize(16, 16)
btnUp:SetScript("OnClick", function() msgFrame:ScrollUp() end)

local btnDown = CreateFrame("Button", nil, msgBg, "UIPanelScrollDownButtonTemplate")
btnDown:SetPoint("BOTTOMRIGHT", msgBg, "BOTTOMRIGHT", -4, 4)
btnDown:SetSize(16, 16)
btnDown:SetScript("OnClick", function() msgFrame:ScrollDown() end)

local btnDN = CreateFrame("Button", nil, msgBg)
btnDN:SetSize(22, 16)
btnDN:SetPoint("RIGHT", msgBg, "RIGHT", -2, 0)
btnDN:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
btnDN:SetBackdropColor(0.15, 0.15, 0.15, 1)
btnDN:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
local dnText = btnDN:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
dnText:SetPoint("CENTER")
dnText:SetText("DN")
dnText:SetTextColor(0.7, 0.7, 0.7)
btnDN:SetScript("OnClick", function() msgFrame:ScrollToBottom() end)

local originalAddMessage = msgFrame.AddMessage
msgFrame.AddMessage = function(self, text, r, g, b, id)
    if text then
        text = text:gsub("(%[%d+:?%d*:?%d*%])", "|cff00ff00%1|r")

        local separator = "|cff444444" .. ("-"):rep(92) .. "|r"

        originalAddMessage(self, separator, 0.5, 0.5, 0.5)
        originalAddMessage(self, text, r, g, b, id)
    else
        originalAddMessage(self, text, r, g, b, id)
    end
end


-----------------------------------------------------------------------------------------
-----------------------------АЧИВЫ-------------------------------------------------------
-----------------------------------------------------------------------------------------
local AchievementPriority = {
    20506, -- Completed Mythic: 1
    20507, -- Completed Mythic: 2
    20508, -- Completed Mythic: 3
    20509, -- Completed Mythic: 4
    20510, -- Completed Mythic: 5
    20511, -- Completed Mythic: 6
    20512, -- Completed Mythic: 7
    20513, -- Completed Mythic: 8
    20514, -- Completed Mythic: 9
    20515, -- Completed Mythic: 10
    20516, -- Completed Mythic: 11
    20517, -- Completed Mythic: 12
    20518, -- Completed Mythic: 13
    20519, -- Completed Mythic: 14
    20520, -- Completed Mythic: 15
    20521, -- Completed Mythic: 16
    20522, -- Completed Mythic: 17
    20523, -- Completed Mythic: 18
    20524, -- Completed Mythic: 19
    20525, -- Completed Mythic: 20
    20526, -- Completed Mythic: 21
    20527, -- Completed Mythic: 22
    20528, -- Completed Mythic: 23
    20529, -- Completed Mythic: 24
    20530, -- Completed Mythic: 25
    20531, -- Completed Mythic: 26
    20532, -- Completed Mythic: 27
    20533, -- Completed Mythic: 28
    20534, -- Completed Mythic: 29
    20535, -- Completed Mythic: 30
    20536, -- Completed Mythic: 31
    20537, -- Completed Mythic: 32
    20538, -- Completed Mythic: 33
    20539, -- Completed Mythic: 34
    20540, -- Completed Mythic: 35
    20541, -- Completed Mythic: 36
    20542, -- Completed Mythic: 37
    20543, -- Completed Mythic: 38
    20544, -- Completed Mythic: 39
    20545, -- Completed Mythic: 40 
}

msgFrame:SetScript("OnHyperlinkClick", function(self, linkData)
    local _, player = strsplit(":", linkData)
    if player then
        local myILvl = GetMyItemLevel()
        local myRole = (Config.role ~= "NONE") and Config.role or "Player"
        
        local bestAchievement = ""
        if Config.linkAchievement then
            for i = #AchievementPriority, 1, -1 do
                local id = AchievementPriority[i]
                local _, _, _, completed = GetAchievementInfo(id)
                if completed then
                    bestAchievement = " " .. GetAchievementLink(id)
                    break
                end
            end
        end


        local specDisplay = ""
            if Mythfinder_SelectedSpec and Mythfinder_SelectedSpec ~= "None" and Mythfinder_SelectedSpec ~= "Spec Tag" then
                specDisplay = " " .. Mythfinder_SelectedSpec
            end
        local whisperMsg = string.format("[Mythfinder] %s%s (%d ilvl)%s",  
            tostring(myRole), 
            specDisplay, 
            tonumber(myILvl) or 0, 
            tostring(bestAchievement)
        )
  
        
        SendChatMessage(whisperMsg, "WHISPER", nil, player)
        DEFAULT_CHAT_FRAME:AddMessage("|cff00fbff[Mythfinder]|r Sent to " .. player .. ": " .. whisperMsg)
    end
end)


-----------------------------------------------------------------------------------------
-------------------------КНОПКА КЛИР-----------------------------------------------------
-----------------------------------------------------------------------------------------
local clearBtn = CreateFrame("Button", nil, msgBg)
clearBtn:SetSize(45, 16)
clearBtn:SetPoint("BOTTOMRIGHT", msgBg, "TOPRIGHT", 0, 2)
clearBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
clearBtn:SetBackdropColor(0.2, 0.2, 0.2, 1)
clearBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

local clearText = clearBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
clearText:SetPoint("CENTER", 0, 0)
clearText:SetText("Clear")
clearText:SetTextColor(0.8, 0.8, 0.8)

clearBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.3, 0.3, 0.3, 1) end)
clearBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.2, 0.2, 0.2, 1) end)

clearBtn:SetScript("OnClick", function()
    msgFrame:Clear()
    print("|cff888888Mythfinder: Окно сообщений очищено|r")
end)        

-----------------------------------------------------------------------------------------
-------------------------ЧАТ И МИНИКАРТА-------------------------------------------------
-----------------------------------------------------------------------------------------
Mythfinder:RegisterEvent("CHAT_MSG_CHANNEL")
Mythfinder:RegisterEvent("CHAT_MSG_LFG")

Mythfinder:SetScript("OnEvent", function(self, event, msg, author)
    if Config.role == "NONE" or Config.dungeon == "NONE" then return end
    local message = msg:upper()
    local dungeonMatch = false
    if Config.dungeon == "All Dungeons" then
        for i = 2, #Dungeons do if message:find(Dungeons[i]:upper()) then dungeonMatch = true break end end
    elseif message:find(Config.dungeon:upper()) then dungeonMatch = true end

    if not dungeonMatch or not message:find(Config.role) then return end
    local foundLevel = message:match("%((%d+)%)")
    if foundLevel then
        local lvl = tonumber(foundLevel)
        local matchLvl = (Config.levelMax > 0) and (lvl >= Config.levelMin and lvl <= Config.levelMax) or (lvl == Config.levelMin)
        if matchLvl then
            local time = date("%H:%M:%S")
            msgFrame:AddMessage("|cff00ff00["..time.."]|r |Hplayer:"..author.."|h["..author.."]|h: " .. msg)
            if not Mythfinder:IsShown() then Mythfinder:Show() end
            PlaySound("RaidWarning", "master")
        end
    end
end)

-----------------------------------------------------------------------------------------
-------------------------АДДОН КОММАНДА И ИКОНКА МИНИМАП---------------------------------
-----------------------------------------------------------------------------------------
SLASH_Mythfinder1 = "/mf"
SlashCmdList["Mythfinder"] = function()
    if Mythfinder:IsShown() then Mythfinder:Hide() else Mythfinder:Show() end
end

local LFG_IconPos = 45 
local minimapBtn = CreateFrame("Button", "MythfinderMinimapBtn", Minimap)
minimapBtn:SetSize(31, 31)
minimapBtn:SetNormalTexture("Interface\\Icons\\LevelUpIcon-LFD") 
minimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local function UpdateMinimapPos(angle)
    minimapBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * math.cos(math.rad(angle))), (80 * math.sin(math.rad(angle))) - 52)
end

minimapBtn:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        if Mythfinder:IsShown() then Mythfinder:Hide() else Mythfinder:Show() end
    end
end)

minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local x, y = GetCursorPosition()
        local xscale = Minimap:GetEffectiveScale()
        local mx, my = Minimap:GetCenter()
        local angle = math.atan2((y/xscale) - my, (x/xscale) - mx)
        LFG_IconPos = math.deg(angle)
        UpdateMinimapPos(LFG_IconPos)
    end)
end)
minimapBtn:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

UpdateMinimapPos(LFG_IconPos)
Mythfinder:Hide()

-----------------------------------------------------------------------------------------
-------------------------ОБ АДДОНЕ-------------------------------------------------------
-----------------------------------------------------------------------------------------
local AboutFrame = CreateFrame("Frame", "MythfinderAboutFrame", Mythfinder)
AboutFrame:SetAllPoints(Mythfinder)
AboutFrame:SetFrameLevel(Mythfinder:GetFrameLevel() + 10)
AboutFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
AboutFrame:SetBackdropColor(0, 0, 0, 1)
AboutFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
AboutFrame:Hide()

local aboutTitle = AboutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
aboutTitle:SetPoint("TOP", 0, -20)
aboutTitle:SetText("|cfff48cbaMythfinder|r")

local aboutText = AboutFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
aboutText:SetPoint("TOPLEFT", 20, -60)
aboutText:SetWidth(410)
aboutText:SetJustifyH("LEFT")
aboutText:SetTextColor(0.7, 0.7, 0.7)
aboutText:SetText(
    "Этот аддон предназначен для удобного поиска групп в подземелья.\n\n" ..
    "Автор: |cfff48cbaPinkpower|r\n" ..
    "Версия: 1.05\n\n" ..
    "Особенности:\n" ..
    "- Автоматический расчет Item Level.\n" ..
    "- Быстрый отклик на объявления в чате.\n" ..
    "- Гибкая фильтрация по ролям и уровням.\n\n" ..
    "|cff888888Нажмите в любое место или ESC, чтобы закрыть это окно.|r"
)

AboutFrame:EnableMouse(true)
AboutFrame:SetScript("OnMouseDown", function(self) self:Hide() end)

AboutFrame:SetScript("OnShow", function(self)
    tinsert(UISpecialFrames, "MythfinderAboutFrame")
end)

-----------------------------------------------------------------------------------------
-------------------------КНОПКА ОБ АДДОНЕ------------------------------------------------
-----------------------------------------------------------------------------------------
local aboutBtn = CreateFrame("Button", nil, Mythfinder)
aboutBtn:SetSize(80, 18)
aboutBtn:SetPoint("TOPLEFT", Mythfinder, "TOPLEFT", 2, -2) 
aboutBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
aboutBtn:SetBackdropColor(0.2, 0.2, 0.2, 1)
aboutBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

local aboutBtnText = aboutBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
aboutBtnText:SetPoint("CENTER", 0, 0)
aboutBtnText:SetText("Об аддоне")
aboutBtnText:SetTextColor(0.8, 0.8, 0.8)

aboutBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.3, 0.3, 0.3, 1) end)
aboutBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.2, 0.2, 0.2, 1) end)
aboutBtn:SetScript("OnClick", function() AboutFrame:Show() end)

-----------------------------------------------------------------------------------------
-------------------------АНОНСЫ СТАРТА И КОНЦА БОЯ---------------------------------------
-----------------------------------------------------------------------------------------
local bossName = nil
local startTime = 0
local isFighting = false

local frame = CreateFrame("Frame")
frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED") 

frame:SetScript("OnEvent", function(self, event)
    if not Config.bossAnnounce then return end
    
    local _, instanceType = GetInstanceInfo()
    if instanceType ~= "party" and instanceType ~= "raid" then return end

    local currentBoss = nil
    for i = 1, 5 do
        if UnitExists("boss"..i) then
            currentBoss = UnitName("boss"..i)
            break
        end
    end

    if currentBoss and not isFighting then
        bossName = currentBoss
        startTime = GetTime()
        isFighting = true
        SendChatMessage("Начало боя с: " .. bossName, "PARTY")
    
    elseif not currentBoss and isFighting then
        local duration = GetTime() - startTime
        local timeStr = string.format("%02d:%02d", math.floor(duration / 60), math.floor(duration % 60))
        
        SendChatMessage("Бой закончен: " .. bossName .. " (" .. timeStr .. ")", "PARTY")
        
        bossName = nil
        isFighting = false
        startTime = 0
    end
    
    if event == "PLAYER_REGEN_ENABLED" and not currentBoss then
        isFighting = false
        bossName = nil
    end
end)
local cbAnnounce = CreateFrame("CheckButton", "MythfinderCB_Announce", Mythfinder, "OptionsCheckButtonTemplate")

cbAnnounce:SetPoint("TOPLEFT", 125, -115) 
cbAnnounce:SetSize(22, 22)


local cbText = _G[cbAnnounce:GetName().."Text"]
cbText:SetText("Announce Bosses")
cbText:SetTextColor(1, 0.82, 0)

cbAnnounce:SetHitRectInsets(0, -120, 0, 0)


cbAnnounce:SetScript("OnClick", function(self)
    Config.bossAnnounce = self:GetChecked()
end)

if Config.bossAnnounce == nil then Config.bossAnnounce = true end
cbAnnounce:SetChecked(Config.bossAnnounce)

--------------------------------------------------------------------------

local subSpecs = {"Elem", "Enh", "EnhTank", "RSham", "Boomy", "Feral", "Bear", "Rdru", "HuntMm", "HuntBm", "HuntSurv", "MageArcan", "MageFire", "MageFrost", "LockDemon", "LockAfli", "LockDestr", "Spriest", "Disc", "HolyPriest", "Ppal", "RetPal", "HollyPal", "ArmsWarr", "FuryWarr", "ProtWarr", "RogueAssa", "RogueSub", "RogueCombat"}
local selectedSubSpec = ""

local SubSpecMenu = CreateFrame("Frame", "MythfinderSubSpecMenu", Mythfinder, "UIDropDownMenuTemplate")

SubSpecMenu:SetPoint("TOPLEFT", 110, -85) 


_G[SubSpecMenu:GetName().."Left"]:Hide()
_G[SubSpecMenu:GetName().."Middle"]:Hide()
_G[SubSpecMenu:GetName().."Right"]:Hide()


local subBg = CreateFrame("Frame", nil, SubSpecMenu)
subBg:SetPoint("LEFT", SubSpecMenu, "LEFT", 15, 3)
subBg:SetSize(160, 22)
subBg:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
subBg:SetBackdropColor(0, 0, 0, 1)
subBg:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
subBg:SetFrameLevel(SubSpecMenu:GetFrameLevel() - 1)


local subBtn = _G[SubSpecMenu:GetName().."Button"]
subBtn:ClearAllPoints()
subBtn:SetPoint("RIGHT", subBg, "RIGHT", 0, 0)

UIDropDownMenu_SetWidth(SubSpecMenu, 140)
UIDropDownMenu_SetText(SubSpecMenu, "Spec Tag")

UIDropDownMenu_Initialize(SubSpecMenu, function(self)
    for _, name in ipairs(subSpecs) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = name
        info.func = function()
            Mythfinder_SelectedSpec = name
            UIDropDownMenu_SetText(SubSpecMenu, name)
        end
        UIDropDownMenu_AddButton(info)
    end
end)





------------------- проверка версиии аддона на гитхабе -----------------------------------

local CURRENT_VERSION = "1.1" 
local GITHUB_URL = "https://github.com/PinkpowerWOW/Mythfinder"

local function PrintUpdateNotice(remoteVersion)
    local link = "|Hurl:"..GITHUB_URL.."|h|cff00ffff[GitHub: Mythfinder]|r|h"
    
    print("|cffffff00[Mythfinder]|r Доступна новая версия: |cff00ff00" .. remoteVersion .. "|r")
    print("Скачать обновление здесь: " .. link)
end

local originalOnHyperlinkClick = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(chatFrame, link, text, button)
    if link:find("^url:") then
        local url = link:sub(5)
        local editBox = ChatEdit_ChooseBoxForSend()
        ChatEdit_ActivateChat(editBox)
        editBox:SetText(url)
        editBox:HighlightText()
        print("|cff00fbff[Mythfinder]|r Ссылка вставлена в чат. Нажмите |cff00ff00Ctrl+C|r, чтобы скопировать.")
    else
        
        if originalOnHyperlinkClick then
            originalOnHyperlinkClick(chatFrame, link, text, button)
        end
    end
end


local UpdateFrame = CreateFrame("Frame")
UpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
UpdateFrame:RegisterEvent("CHAT_MSG_ADDON")
UpdateFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

UpdateFrame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if event == "PLAYER_ENTERING_WORLD" then
        print("|cff00ff00[Mythfinder]|r Загружен. Версия: " .. CURRENT_VERSION)
        C_Timer.After(5, function()
            local targetChannel = IsInRaid() and "RAID" or IsInGroup() and "PARTY" or IsInGuild() and "GUILD"
            if targetChannel then
                SendAddonMessage("MythfinderUpdate", "VERSION_CHECK", targetChannel)
            end
        end)
    elseif event == "CHAT_MSG_ADDON" and prefix == "MythfinderUpdate" then
        if sender == UnitName("player") then return end 

        if message == "VERSION_CHECK" then
            SendAddonMessage("MythfinderUpdate", "VERSION_INFO:" .. CURRENT_VERSION, channel)
            
        elseif message:find("VERSION_INFO:") then
            local remoteVersion = message:match("VERSION_INFO:(.+)")
            
            if remoteVersion > CURRENT_VERSION and not self.announced then
                PrintUpdateNotice(remoteVersion)
                self.announced = true
            end
        end
    end
end)
