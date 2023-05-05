function createFrame(width, height)
    local frame = CreateFrame("Frame", "frame", UIParent, "SecureHandlerStateTemplate")
    frame:SetSize(width, height)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        --SavePosition()
    end)
    
    -- Set a background texture
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.5)
    
    return frame
end

-- classic era build version: 49229
-- classic era interface version: 11403

function SavePosition(frame)
    local point, _, _, x, y = frame:GetPoint()
    return {point, x, y}
end

defaultFramePoint = {"CENTER", 0, 0}

function InitializePosition(frame, storedDB, defaultPoint)
    local point, x, y
    if storedDB then
        point, x, y = unpack(storedDB)
    else
        point, x, y = unpack(defaultPoint or {"CENTER", 0, 0})
    end
    frame:SetPoint(point, x, y)
end

function ResetInactiveBuffIcon(frameIcon)
    frameIcon:SetAlpha(0.1)
    frameIcon.text:SetText("")
    frameIcon:Hide()
end

function buffDataContainsSpellId(data, spellId)
    for _, data in pairs(data) do
        if data.spellId == spellId then
            return true
        end
    end
    return false
end

function CreateSpellIcon(parent, texture)
    local iconFrame = CreateFrame("Frame", nil, parent)
    iconFrame:SetSize(32, 32)

    local iconTexture = iconFrame:CreateTexture(nil, "ARTWORK")
    iconTexture:SetTexture(texture)
    iconTexture:SetAllPoints(iconFrame)
    iconFrame.texture = iconTexture

    local cooldownText = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cooldownText:SetPoint("BOTTOM", iconFrame, "TOP", 0, -2)
    cooldownText:SetFont(GameFontNormal:GetFont(), 14)
    cooldownText:SetTextColor(1, 1, 1)
    iconFrame.text = cooldownText

    return iconFrame
end

local function findPowerWordShieldBuff()
    local absorbAmount = 0
    local powerWordShieldRanks = {
        [6] = 48,   -- Rank 1
        [12] = 94,  -- Rank 2
        [18] = 166, -- Rank 3
        [24] = 244, -- Rank 4
        [30] = 313, -- Rank 5
        [36] = 394, -- Rank 6
        [42] = 499, -- Rank 7
        [48] = 622, -- Rank 8
        [54] = 783, -- Rank 9
        [60] = 964, -- Rank 10
        [66] = 1144,-- Rank 11
        [70] = 1286,-- Rank 12
        [75] = 1951,-- Rank 13
        [80] = 2230 -- Rank 14
    }

    local playerLevel = UnitLevel("player")

    local index = 1
    while true do
        local buffName, buffRank, buffIcon, count, buffDuration, buffExpirationTime, buffCaster, _, _, buffSpellId, _, _, _, _, buffAmount, _, _, _ = UnitAura("player", index, "HELPFUL|PLAYER")
        if not buffName then
            break
        end

        if buffName == "Power Word: Shield" then
            local maxAvailableRank = 0
            for level, baseAbsorb in pairs(powerWordShieldRanks) do
                if playerLevel >= level and level > maxAvailableRank then
                    maxAvailableRank = level
                    absorbAmount = baseAbsorb
                end
            end
            return absorbAmount
        end

        index = index + 1
    end

    local base = absorbAmount
    local coeff = 0.8068
    local borrowedTime = 0.40
    local twinDisciplines = 0.05
    local focusedPower = 0.04
    local improvedPWShield = 0.15

    local pws = (base + (GetSpellBonusHealing() * (coeff + borrowedTime))) * (1 + twinDisciplines) * (1 + focusedPower) * (1 + improvedPWShield)
    return pws
end

function buffsDebuffs()
    local buffsData, debuffsData = {}, {}
    for i = 1, 40 do -- assuming you want to check all 40 buff/debuff slots
        local debuffName, debuffIcon, debuffCount, _, debuffDuration, debuffExpirationTime, debuffCaster, _, _, debuffSpellId = UnitAura("target", i, "HARMFUL|PLAYER")
        local buffName, buffIcon, count, _, buffDuration, buffExpirationTime, buffCaster, _, _, buffSpellId = UnitAura("player", i, "HELPFUL|PLAYER")
        local petBuffName, _, petBuffIcon, _, petBuffDuration, petBuffExpirationTime, petBuffCaster, _, _, petBuffSpellId, _, _,_,_,_,_, buffAmount  = UnitAura("pet", i, "HELPFUL|PLAYER")
        if debuffName and debuffCaster == "player" then -- if there is a debuff present and it's applied by the player
            local debuff = {
                name = debuffName, 
                icon = debuffIcon,
                count = debuffCount,
                duration = debuffDuration, 
                expirationTime = debuffExpirationTime, 
                texture = GetSpellTexture(debuffSpellId), 
                spellId = debuffSpellId, 
                isDebuff = true,
                modifiesSpellPower = false,
            }
            table.insert(debuffsData, debuff)
        end
        if buffName and buffCaster == "player" then -- if there is a buff present and it's applied by the player
            local buff = {}
            if buffName == "Power Word: Shield" then
                buff = {
                    name = buffName, 
                    icon = buffIcon,
                    count = count,
                    duration = buffDuration, 
                    expirationTime = buffExpirationTime, 
                    texture = GetSpellTexture(buffSpellId), 
                    spellId = buffSpellId, 
                    isDebuff = false,
                    modifiesSpellPower = false,
                    isShield = true,
                    buffAmount = findPowerWordShieldBuff()
                }
            else
                buff = {
                    name = buffName, 
                    icon = buffIcon,
                    count = count,
                    duration = buffDuration, 
                    expirationTime = buffExpirationTime, 
                    texture = GetSpellTexture(buffSpellId), 
                    spellId = buffSpellId, 
                    isDebuff = false,
                    modifiesSpellPower = false,
                    isShield = false
                }
            end
            table.insert(buffsData, buff)
        end
        if petBuffName and petBuffCaster == "pet" and petBuffName == "Demonic Pact" then
            local buff = {
                name = petBuffName,
                icon = petBuffIcon,
                duration = petBuffDuration,
                expirationTime = petBuffExpirationTime,
                texture = GetSpellTexture(petBuffSpellId),
                spellId = petBuffSpellId,
                isDebuff = false,
                modifiesSpellPower = true,
                bonus = bonus,
                buffAmount = buffAmount
            }
            table.insert(buffsData, buff)
        end
    end
    return buffsData, debuffsData
end