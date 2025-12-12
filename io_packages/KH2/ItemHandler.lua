local ItemHandler = {}

local SoraBack = 0x25D8
local SoraFront = 0x2546
local SoraCurrentAbilitySlot = 0x25D8
local SoraBufferSlots = { [0x2546] = true, [0x2548] = true, [0x254A] = true, [0x254C] = true }
local SoraEquippedKeyladeSlots = { 0x24F0, 0x32F4, 0x339C, 0x33D4, }

local HighJumpSlot = 0x25DA
local QuickRunSlot = 0x25DC
local DodgeRollSlot = 0x25DE
local AerialDodgeSlot = 0x25E0
local GlideSlot = 0x25E2

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
        self:GiveItem(item)
    else
        self:GiveAbility(item)
    end

end

function ItemHandler:GiveItem(value)
    if value.Bitmask ~= nil then
        WriteByte(Save + value.Address, ReadByte(Save + value.Address) | 0x01 <<value.Bitmask)
    else
        if value.Type == "Keyblade" then
            local amount = ItemsReceived[value.Name]
            for i = 1, #SoraEquippedKeyladeSlots do
                if ReadShort(Save + SoraEquippedKeyladeSlots[i]) == value.ID then
                    amount = amount - 1
                    if amount <= 0 then
                        amount = 0
                        break
                    end
                end
            end
            WriteByte(Save + value.Address, amount)
        elseif value.Type == "Accessories" then
            local amount = ItemsReceived[value.Name]
            for Character = 1, #CharacterAnchors do
                local Base = Save + CharacterAnchors[Character]
                for Slot = 1, #EquipmentAnchor.Accessories do
                    if ReadShort(Base + EquipmentAnchor.Accessories[Slot]) == value.ID then
                        amount = amount - 1
                        if amount <= 0 then
                            amount = 0
                            break
                        end
                    end
                end
                if amount == 0 then
                    break
                end
            end
            WriteByte(Save + value.Address, amount)
        elseif value.Type == "Armor" then
            local amount = ItemsReceived[value.Name]
            for Character = 1, #CharacterAnchors do
                local Base = Save + CharacterAnchors[Character]
                for Slot = 1, #EquipmentAnchor.Armor do
                    if ReadShort(Base + EquipmentAnchor.Armor[Slot]) == value.ID then
                        amount = amount - 1
                        if amount <= 0 then
                            amount = 0
                            break
                        end
                    end
                end
                if amount == 0 then
                    break
                end
            end
            WriteByte(Save + value.Address, amount)
        elseif value.Type == "Staff" then
            local amount = ItemsReceived[value.Name]
            if ReadShort(Save + 0x2604) == value.ID then
                amount = math.max(0, amount - 1)
            end
            WriteByte(Save + value.Address, amount)
        elseif value.Type == "Shield" then
            local amount = ItemsReceived[value.Name]
            if ReadShort(Save + 0x2718) == value.ID then
                amount = math.max(0, amount - 1)
            end
            WriteByte(Save + value.Address, amount)
        else
            WriteByte(Save + value.Address, ItemsReceived[value.Name])
        end
    end
end

function ItemHandler:GiveAbility(value)
    if value.Ability == "Sora" then
        if value.Name == "High Jump" then
            local equipped = ReadShort(Save + HighJumpSlot) & 0x8000
            WriteShort(Save + HighJumpSlot, SoraGrowthReceived[value.Name].current | equipped)
        elseif value.Name == "Quick Run" then
            local equipped = ReadShort(Save + QuickRunSlot) & 0x8000
            WriteShort(Save + QuickRunSlot, SoraGrowthReceived[value.Name].current | equipped)
        elseif value.Name == "Dodge Roll" then
            local equipped = ReadShort(Save + DodgeRollSlot) & 0x8000
            WriteShort(Save + DodgeRollSlot, SoraGrowthReceived[value.Name].current | equipped)
        elseif value.Name == "Aerial Dodge" then
            local equipped = ReadShort(Save + AerialDodgeSlot) & 0x8000
            WriteShort(Save + AerialDodgeSlot, SoraGrowthReceived[value.Name].current | equipped)
        elseif value.Name == "Glide" then
            local equipped = ReadShort(Save + GlideSlot) & 0x8000
            WriteShort(Save + GlideSlot, SoraGrowthReceived[value.Name].current | equipped)
        else
            local slot = SoraBack - (#SoraAbilitiesReceived - 1) * 2
            if not SoraBufferSlots[slot] then
                local equipped = ReadShort(Save + slot) & 0x8000
                WriteShort(Save + slot, value.Address | equipped)
            else
                ConsolePrint("Error too many abilities cannot receive anymore. Ability skipped "  .. value.Name)
            end
        end
    elseif value.Ability == "Donald" then
        local slot = DonaldBack - (#DonaldAbilitiesReceived - 1) * 2
        if not DonaldBufferSlots[slot] then
            local equipped = ReadShort(Save + slot) & 0x8000
            WriteShort(Save + slot, value.Address | equipped)
        else
            ConsolePrint("Error too many abilities cannot receive anymore. Ability skipped "  .. value.Name)
        end
    elseif value.Ability == "Goofy" then
        local slot = GoofyBack - (#GoofyAbilitiesReceived - 1) * 2
        if not GoofyBufferSlots[slot] then
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

return ItemHandler
