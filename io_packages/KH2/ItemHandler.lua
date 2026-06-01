local ItemHandler = {}

local VerifyIndex = 14 --Skip ansem reports since they currently dont do anything
local VerifyIndexGrowth = 1
local VerifyIndexSora = 1
local VerifyIndexDonald = 1
local VerifyIndexGoofy = 1
local KnownTornPageFlag = 0

local SoraBack = 0x25D8
local SoraFront = 0x2546
local SoraCurrentAbilitySlot = 0x25D8
local SoraBufferSlots = { [0x2546] = true, [0x2548] = true, [0x254A] = true, [0x254C] = true }
local SoraEquippedKeybladeSlots = { 0x24F0, 0x32F4, 0x339C, 0x33D4, }

local GrowthSlots = {
    ["High Jump"] = 0x25DA,
    ["Quick Run"] = 0x25DC,
    ["Dodge Roll"] = 0x25DE,
    ["Aerial Dodge"] = 0x25E0,
    ["Glide"] = 0x25E2,
}

local GrowthOrder = {
    "High Jump",
    "Quick Run",
    "Dodge Roll",
    "Aerial Dodge",
    "Glide",
}

local DonaldBack = 0x26F4
local DonaldFront = 0x2658
local DonaldCurrentAbilitySlot = 0x26F4
local DonaldBufferSlots = { [0x2658] = true, [0x265A] = true, [0x265C] = true, [0x265E] = true }

local GoofyBack = 0x2808
local GoofyFront = 0x276C
local GoofyCurrentAbilitySlot = 0x2808
local GoofyBufferSlots = { [0x276C] = true, [0x276E] = true,  [0x2770] = true, [0x2772] = true }

local CharacterAnchors = {
     0x24F0,    --Sora
     0x2604,    --Donald
     0x2718,    --Goofy
     0x2940,    --Auron
     0x2A54,    --Mulan
     0x2B68,    --Aladdin
     0x2C7C,    --Jack Sparrow
     0x2D90,    --Beast
     0x2EA4,    --Jack Skellington
     0x2FB8,    --Simba
     0x30CC,    --Tron
     0x31E0,    --Riku
}
local EquipmentAnchor = {
    Armor       = { 0x14, 0x16, 0x18, 0x1A, 0x1C, 0x1E, 0x20, 0x22 },
    Accessories = { 0x24, 0x26, 0x28, 0x2A, 0x2C, 0x2E, 0x30, 0x32 },
}

function ItemHandler:Reset()
  ConsolePrint("Item Handler Reset")
end

function ItemHandler:Receive(item)
    ConsolePrint("Received " .. item.Name)
    if item.Type ~= "Ability" then
        self:GiveItem(item, false)
    else
        self:GiveAbility(item)
    end

end

function ItemHandler:GiveItem(value, verify)
    if value.Bitmask ~= nil then
        if value.Type == "Form" and not verify then
            WriteByte(Save + 0x3410, 0)
        end
        WriteByte(Save + value.Address, ReadByte(Save + value.Address) | (0x01 << value.Bitmask))
    else
        if value.Type == "Keyblade" then
            local amount = ItemsReceived[value.Name]
            for i = 1, #SoraEquippedKeybladeSlots do
                if ReadShort(Save + SoraEquippedKeybladeSlots[i]) == value.ID then
                    amount = amount - 1
                    if amount <= 0 then
                        break
                    end
                end
            end
            amount = math.max(0, amount - (SoldItems[value.Name] or 0))
            WriteByte(Save + value.Address, amount)
        elseif value.Type == "Accessories" then
            local amount = ItemsReceived[value.Name]
            for Character = 1, #CharacterAnchors do
                local Base = Save + CharacterAnchors[Character]
                for Slot = 1, #EquipmentAnchor.Accessories do
                    if ReadShort(Base + EquipmentAnchor.Accessories[Slot]) == value.ID then
                        amount = amount - 1
                        if amount <= 0 then
                            break
                        end
                    end
                end
                if amount <= 0 then
                    break
                end
            end
            amount = math.max(0, amount - (SoldItems[value.Name] or 0))
            WriteByte(Save + value.Address, amount)
        elseif value.Type == "Armor" then
            local amount = ItemsReceived[value.Name]
            for Character = 1, #CharacterAnchors do
                local Base = Save + CharacterAnchors[Character]
                for Slot = 1, #EquipmentAnchor.Armor do
                    if ReadShort(Base + EquipmentAnchor.Armor[Slot]) == value.ID then
                        amount = amount - 1
                        if amount <= 0 then
                            break
                        end
                    end
                end
                if amount <= 0 then
                    break
                end
            end
            amount = math.max(0, amount - (SoldItems[value.Name] or 0))
            WriteByte(Save + value.Address, amount)
        elseif value.Type == "Staff" then
            local amount = ItemsReceived[value.Name]
            if ReadShort(Save + 0x2604) == value.ID then
                amount = amount - 1
            end
            amount = math.max(0, amount - (SoldItems[value.Name] or 0))
            WriteByte(Save + value.Address, amount)
        elseif value.Type == "Shield" then
            local amount = ItemsReceived[value.Name]
            if ReadShort(Save + 0x2718) == value.ID then
                amount = amount - 1
            end
            amount = math.max(0, amount - (SoldItems[value.Name] or 0))
            WriteByte(Save + value.Address, amount)
        else
            WriteByte(Save + value.Address, ItemsReceived[value.Name])
        end
    end
end

function ItemHandler:GiveAbility(value)
    if value.Ability == "Sora" then
        if GrowthSlots[value.Name] then
            local equipped = ReadShort(Save + GrowthSlots[value.Name]) & 0x8000
            WriteShort(Save + GrowthSlots[value.Name], SoraGrowthReceived[value.Name].Current | equipped)
        else
            local slot
            for i = #SoraAbilitiesReceived, 1, -1 do
                if SoraAbilitiesReceived[i] == value then
                    slot = SoraBack - (i - 1) * 2
                    break
                end
            end
            if slot and not SoraBufferSlots[slot] then
                local equipped = ReadShort(Save + slot) & 0x8000
                WriteShort(Save + slot, value.Address | equipped)
            else
                ConsolePrint("Error too many abilities cannot receive anymore. Ability skipped "  .. value.Name)
            end
        end
    elseif value.Ability == "Donald" then
        local slot
        for i = #DonaldAbilitiesReceived, 1, -1 do
            if DonaldAbilitiesReceived[i] == value then
                slot = DonaldBack - (i - 1) * 2
                break
            end
        end
        if slot and not DonaldBufferSlots[slot] then
            local equipped = ReadShort(Save + slot) & 0x8000
            WriteShort(Save + slot, value.Address | equipped)
        else
            ConsolePrint("Error too many abilities cannot receive anymore. Ability skipped "  .. value.Name)
        end
    elseif value.Ability == "Goofy" then
        local slot
        for i = #GoofyAbilitiesReceived, 1, -1 do
            if GoofyAbilitiesReceived[i] == value then
                slot = GoofyBack - (i - 1) * 2
                break
            end
        end
        if slot and not GoofyBufferSlots[slot] then
             local equipped = ReadShort(Save + slot) & 0x8000
             WriteShort(Save + slot, value.Address | equipped)
        else
            ConsolePrint("Error too many abilities cannot receive anymore. Ability skipped "  .. value.Name)
        end
    end
end

function ItemHandler:Request()
  SendToApClient(MessageTypes.RequestAllItems,{})
end

function ItemHandler:RemoveAbilities()
   for slot, _ in pairs(SoraBufferSlots) do
       if ReadShort(Save + slot) ~= 0 then
           WriteShort(Save + slot, 0)
       end
   end
   for slot, _ in pairs(DonaldBufferSlots) do
       if ReadShort(Save + slot) ~= 0 then
           WriteShort(Save + slot, 0)
       end
   end
   for slot, _ in pairs(GoofyBufferSlots) do
       if ReadShort(Save + slot) ~= 0 then
           WriteShort(Save + slot, 0)
       end
   end
end

function ItemHandler:VerifyInventory()
    local ItemsPerFrame = 3
    for i = 1, ItemsPerFrame do
        local item = Items[VerifyIndex]
        if not item then
             VerifyIndex = 14 --Skip ansem reports since they currently dont do anything
             break
        end
        local receivedAmount = ItemsReceived[item.Name] or 0
        if item.Name == "Torn Page" then
            local tornPagesRedeemed = KnownTornPageFlag
            if KnownTornPageFlag < 5 then
                for j = KnownTornPageFlag + 1, #PoohProgress do
                	if (ReadByte(Save + PoohProgress[j].Address) & (0x1 << PoohProgress[j].BitIndex)) > 0 then
                		tornPagesRedeemed = tornPagesRedeemed + 1
                    else
                        break
                	end
                end
                KnownTornPageFlag = tornPagesRedeemed
            end
            ItemsReceived[item.Name] = math.max(0, math.min(TornPagesReceived - tornPagesRedeemed, 255))
        end
        if receivedAmount > 0 then
            ItemHandler:GiveItem(item, true)
        else
            if not item.Bitmask then
                WriteByte(Save + item.Address, 0)
            end
        end
        VerifyIndex = VerifyIndex + 1
        if VerifyIndex > #Items then
            VerifyIndex = 14 --Skip ansem reports since they currently dont do anything
        end
    end
    --[[local growth = GrowthOrder[VerifyIndexGrowth]
    if growth then
        local equipped = ReadShort(Save + GrowthSlots[growth]) & 0x8000
        WriteShort(Save + GrowthSlots[growth], SoraGrowthReceived[growth].Current | equipped)
        VerifyIndexGrowth = VerifyIndexGrowth + 1
        if VerifyIndexGrowth > #GrowthOrder then
            VerifyIndexGrowth = 1
        end
    end
    for i = 1, ItemsPerFrame do
        local ability =  SoraAbilitiesReceived[VerifyIndexSora]
        local slot = SoraBack - (VerifyIndexSora - 1) * 2
        if ability and not SoraBufferSlots[slot] then
            local equipped = ReadShort(Save + slot) & 0x8000
            WriteShort(Save + slot, ability.Address | equipped)
        end
        VerifyIndexSora = VerifyIndexSora + 1
        if VerifyIndexSora > #SoraAbilitiesReceived then
            VerifyIndexSora = 1
        end
    end
    for i = 1, ItemsPerFrame do
        local ability =  DonaldAbilitiesReceived[VerifyIndexDonald]
        local slot = DonaldBack - (VerifyIndexDonald - 1) * 2
        if ability and not DonaldBufferSlots[slot] then
            local equipped = ReadShort(Save + slot) & 0x8000
            WriteShort(Save + slot, ability.Address | equipped)
        end
        VerifyIndexDonald = VerifyIndexDonald + 1
        if VerifyIndexDonald > #DonaldAbilitiesReceived then
            VerifyIndexDonald = 1
        end
    end
    for i = 1, ItemsPerFrame do
        local ability =  GoofyAbilitiesReceived[VerifyIndexGoofy]
        local slot = GoofyBack - (VerifyIndexGoofy - 1) * 2
        if ability and not GoofyBufferSlots[slot] then
            local equipped = ReadShort(Save + slot) & 0x8000
            WriteShort(Save + slot, ability.Address | equipped)
        end
        VerifyIndexGoofy = VerifyIndexGoofy + 1
        if VerifyIndexGoofy > #GoofyAbilitiesReceived then
            VerifyIndexGoofy = 1
        end
    end--]]
end

return ItemHandler
