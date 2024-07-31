--local Module = LibStub("AceAddon-3.0"):NewAddon("ArkInventoryMisc")
--local SynastriaCoreLib = LibStub("SynastriaCoreLib-1.0")
--local debug = false

local SLOTIDS, FONTSIZE = {}, 12
local R,G,B = 1,1,1
for _,slot in pairs({"Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1", "MainHand", "SecondaryHand", "Ranged"}) do SLOTIDS[slot] = GetInventorySlotInfo(slot .. "Slot") end
local frame = CreateFrame("Frame", "characterframe", CharacterFrame)

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
        for _,fstr in pairs(fontstrings) do
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
                local bc = self:GetParent():CreateTexture(nil, "OVERLAY")
                bc:SetTexture"Interface\\Buttons\\UI-ActionButton-Border"
                bc:SetBlendMode"ADD"
                bc:SetAlpha(.8)
                bc:SetWidth(70)
                bc:SetHeight(70)
                bc:SetPoint("CENTER", self)
                bc:SetVertexColor(R,G,B)
                bc:Show()
            end
        else
            local str = rawget(fontstrings, slot)
            if str then str:SetText(nil) end
        end
    end
end

frame:SetScript("OnEvent", frame.OnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
