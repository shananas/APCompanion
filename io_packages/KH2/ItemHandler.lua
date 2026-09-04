local ItemHandler = {}

local VerifyIndex = 14 --Skip ansem reports since they currently dont do anything
local InventoryStart = 0x3594
local InventoryEnd = 0x36CA
local KnownTornPageFlag = 0

local AbilityData = {

    Sora = {
        FrontSlot = 0x2546,
        BackSlot = 0x25D8,
        CurrentSlot = 0x25D8,
        BufferSlots = {
            0x2546,
            0x2548,
            0x254A,
            0x254C,
        },
        AbilitiesReceived = SoraAbilitiesReceived,
    },

    Donald = {
        FrontSlot = 0x2658,
        BackSlot = 0x26F4,
        CurrentSlot = 0x26F4,
        BufferSlots = {
            0x2658,
            0x265A,
            0x265C,
            0x265E,
        },
        AbilitiesReceived = DonaldAbilitiesReceived,
    },

    Goofy = {
        FrontSlot = 0x276C,
        BackSlot = 0x2808,
        CurrentSlot = 0x2808,
        BufferSlots = {
            0x276C,
            0x276E,
            0x2770,
            0x2772,
        },
        AbilitiesReceived = GoofyAbilitiesReceived,
    },
}

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

function ItemHandler:Receive(item)
    ConsolePrint("Received " .. item.Name)
    if item.Type ~= "Ability" then
        self:GiveItem(item)
    else
        self:GiveAbility(item)
    end

end

function ItemHandler:GiveItem(value)
    if value.Bitmask ~= nil then
        if value.Type == "Form" then
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
        elseif value.Type == "Accessories" or value.Type == "Armor" then
            local amount = ItemsReceived[value.Name]
            for Character = 1, #CharacterAnchors do
                local Base = Save + CharacterAnchors[Character]
                for Slot = 1, #EquipmentAnchor[value.Type] do
                    if ReadShort(Base + EquipmentAnchor[value.Type][Slot]) == value.ID then
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
    if GrowthSlots[value.Name] then
        local equipped = ReadShort(Save + GrowthSlots[value.Name]) & 0x8000
        WriteShort(Save + GrowthSlots[value.Name], SoraGrowthReceived[value.Name].Current | equipped)
    else
        local characterIndex = AbilityData[value.Ability]
        local slot
        for i = #characterIndex.AbilitiesReceived, 1, -1 do
            if characterIndex.AbilitiesReceived[i] == value then
                slot = characterIndex.BackSlot - (i - 1) * 2
                characterIndex.CurrentSlot = slot
                break
            end
        end
        if slot and slot > characterIndex.FrontSlot then
            local equipped = ReadShort(Save + slot) & 0x8000
            WriteShort(Save + slot, value.Address | equipped)
        else
            ConsolePrint("Error too many abilities cannot receive anymore. Ability skipped "  .. value.Name)
        end
    end
    ItemHandler:RemoveAbilities()
end

function ItemHandler:Request()
  SendToApClient(MessageTypes.RequestAllItems,{})
end

function ItemHandler:RemoveAbilities()
    for _, characterIndex in pairs(AbilityData) do
        for i = 1, #characterIndex.BufferSlots do
            local slot = characterIndex.BufferSlots[i]
            if characterIndex.CurrentSlot > slot then
                if ReadShort(Save + slot) ~= 0 then
                    WriteShort(Save + slot, 0)
                end
            else
                break
            end
        end
    end
end

function VerifyAbilityCharacter(characterIndex)
    local buffer = ReadArray(Save + characterIndex.FrontSlot, (characterIndex.BackSlot - characterIndex.FrontSlot + 2))
    for i, ability in ipairs(characterIndex.AbilitiesReceived) do
        local slot = characterIndex.BackSlot - (i - 1) * 2
        if slot <= characterIndex.FrontSlot then
            break
        end
        local offset = slot - characterIndex.FrontSlot
        --First Byte is always ability ID, Lower half of second byte is also sometimes ability ID otherwise 0, and upper half of second byte is equipped status.
        buffer[offset + 1] = ability.Address & 0xFF
        buffer[offset + 2] = (buffer[offset + 2] & 0x80) | ((ability.Address >> 8) & 0x7F)
    end
    WriteArray(Save + characterIndex.FrontSlot, buffer)
end

function VerifyGrowth()
    local buffer = ReadArray(Save + 0x25DA, 10)
    for i, growth in ipairs(GrowthOrder) do
        local received = SoraGrowthReceived[growth]
        if received.Max - received.Current < 4 then
            local offset = (i - 1) * 2
            --Explanation Above
            buffer[offset + 1] = received.Current & 0xFF
            buffer[offset + 2] = (buffer[offset + 2] & 0x80) | ((received.Current >> 8) & 0x7F)
        end
    end
    WriteArray(Save + 0x25DA, buffer)
end

function ItemHandler:VerifyInventory()
    local ItemsPerFrame = 2
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
     VerifyGrowth()
     for _, characterIndex in pairs(AbilityData) do
        if #characterIndex.AbilitiesReceived > 0 then
            VerifyAbilityCharacter(characterIndex)
        end
     end
end

return ItemHandler
