local addon = CreateFrame("Button", "ArkInventoryCharacter")
local SLOTIDS, FONTSIZE = {}, 12
local R,G,B = 1,1,1

local cSlotTypes = {
    'Head',
    'Neck',
    'Shoulder',
    'Back',
    'Chest',
    'Shirt',
    'Tabard',
    'Wrist',
    'Hands',
    'Waist',
    'Legs',
    'Feet',
    'Finger0',
    'Finger1',
    'Trinket0',
    'Trinket1',
    'MainHand',
    'SecondaryHand',
    'Ranged',
    'Ammo',
};
for _,slot in pairs(cSlotTypes) do SLOTIDS[slot] = GetInventorySlotInfo(slot .. "Slot") end
local frame = CreateFrame("Frame", "Character", CharacterFrame)

local fontstrings = setmetatable({}, {
    __index = function(t,i)
        local gslot = _G["Character"..i.."Slot"]
        assert(gslot, "Character"..i.."Slot does not exist")

        local fstr = gslot:CreateFontString(nil, "OVERLAY")
        local font, _, flags = NumberFontNormal:GetFont()
        fstr:SetFont(font, FONTSIZE, flags)
        fstr:SetPoint("BOTTOMRIGHT", gslot, "BOTTOMRIGHT", 0, 0)
        t[i] = fstr
        return fstr
    end,
})
function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1:lower() ~= "arkinventorymisc" then
        hooksecurefunc("ToggleCharacter", function() addon:characterFrame_OnToggle()  end)
        for i,fstr in pairs(fontstrings) do
            local font, _, flags = NumberFontNormal:GetFont()
            fstr:SetFont(font, FONTSIZE, flags)
        end
        return
    end

    for slot,id in pairs(SLOTIDS) do
        local link = GetInventoryItemLink("player", id)
        if link then
            local _,_,irarity,ilevel,_,_,_,_,_,_ = GetItemInfo(link)
            if ilevel then
                local str = fontstrings[slot]
                R, G, B = GetItemQualityColor(irarity)
                str:SetTextColor(R,G,B)
                str:SetText(string.format("%s", ilevel))
            end
        else
            local str = rawget(fontstrings, slot)
            if str then str:SetText(nil) end
        end
    end
end

function addon:updateBorder(unit, frameType)
    for _, cSlot in ipairs(cSlotTypes) do
        local id, _ = GetInventorySlotInfo(cSlot.."Slot")
        local quality = GetInventoryItemQuality(unit, id)
        local slotName = frameType..cSlot.."Slot"

        if (_G[slotName]) then
            slotslot = _G[slotName]

            if (not slotslot.gborder) then
                local height = 68
                local width = 68

                if cSlot == "Ammo" then
                    height = 58
                    width = 58
                end

                slotslot.qborder = addon:createBorder(slotName, _G[slotName], width, height)
            end

            if (quality) then
                R, G, B = GetItemQualityColor(quality)
                slotslot.qborder:SetVertexColor(R, G, B)
                slotslot.qborder:SetAlpha(0.5)
                slotslot.qborder:Show()
            else
                slotslot.qborder:Hide()
            end
        end
    end
end

function addon:createBorder(name, parent, width, height, x, y)
    local x = x or 0
    local y = y or 1
    local border = parent:CreateTexture(name .. "Quality", "OVERLAY")

    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    border:SetBlendMode("ADD")
    border:SetAlpha(0.5)
    border:SetHeight(height)
    border:SetWidth(width)
    border:SetPoint("CENTER", parent, "CENTER", x, y)
    border:Hide()

    return border
end

function addon:characterFrame_OnToggle()
    if (CharacterFrame:IsShown()) then
        addon:characterFrame_OnShow()
    else
        addon:characterFrame_OnHide()
    end
end

function addon:characterFrame_OnShow()
    addon:RegisterEvent("UNIT_INVENTORY_CHANGED")
    addon:updateBorder("player", "Character")
end

function addon:characterFrame_OnHide()
    addon:UnregisterEvent("UNIT_INVENTORY_CHANGED")
end

function addon:UNIT_INVENTORY_CHANGED()
    addon:updateBorder("player", "Character")
end

frame:SetScript("OnEvent", frame.OnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")

