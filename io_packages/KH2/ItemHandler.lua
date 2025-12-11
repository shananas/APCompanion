local ItemHandler = {}

local SoraBack = 0x25D8
local SoraFront = 0x2546
local SoraCurrentAbilitySlot = 0x25D8
local SoraBufferSlots = { [0x2546] = true, [0x2548] = true, [0x254A] = true, [0x254C] = true }
local SoraWeaponIDs = { [42] = true, [43] = true, [480] = true, [481] = true, [484] = true, [485] = true, [486] = true, [487] = true, [488] = true, [489] = true, [490] = true, [491] = true,
    [492] = true, [493] = true, [494] = true, [495] = true, [496] = true, [543] = true, [497] = true, [498] = true, [499] = true, [500] = true, [544] = true, [71] = true }

local HighJumpSlot = 0x25DA
local QuickRunSlot = 0x25DC
local DodgeRollSlot = 0x25DE
local AerialDodgeSlot = 0x25E0
local GlideSlot = 0x25E2

local DonaldBack = 0x26F4
local DonaldFront = 0x2658
local DonaldCurrentAbilitySlot = 0x26F4
local DonaldBufferSlots = { [0x2658] = true, [0x265A] = true, [0x265C] = true, [0x265E] = true }
local DonaldWeaponIDs = { [546] = true, [150] = true, [155] = true, [549] = true, [550] = true, [551] = true, [154] = true, [503] = true, [156] = true }

local GoofyBack = 0x2808
local GoofyFront = 0x276C
local GoofyCurrentAbilitySlot = 0x2808
local GoofyBufferSlots = { [0x276C] = true, [0x276E] = true,  [0x2770] = true, [0x2772] = true }
local GoofyWeaponIDs = { [146] = true, [553] = true, [145] = true, [556] = true, [557] = true, [147] = true, [141] = true, [504] = true, [558] = true }

function ItemHandler:Reset()
  ConsolePrint("Item Handler Reset")
end

function ItemHandler:Receive(item)
    ConsolePrint("Received " .. item.Name)
    if item.Ability == "false" then
        self:GiveItem(item)
    else
        self:GiveAbility(item)
    end

end

function ItemHandler:GiveItem(value)
    if value.Bitmask ~= null then
        WriteByte(Save + value.Address, ItemsReceived[value.Name]| 0x01 <<value.Bitmask)
    else
        if SoraWeaponIDs[value.ID] then
            WriteByte(Save + value.Address, ItemsReceived[value.Name])
        elseif DonaldWeaponIDs[value.ID] then
            WriteByte(Save + value.Address, ItemsReceived[value.Name])
        elseif GoofyWeaponIDs[value.ID] then
            WriteByte(Save + value.Address, ItemsReceived[value.Name])
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
            local slot = SoraBack -(#SoraAbilitiesReceived - 1) * 2
            if not SoraBufferSlots[slot] then
                WriteShort(Save + slot, value.Address)
            else
                ConsolePrint("Error too many abilities cannot receive anymore. Ability skipped "  .. value.Name)
            end
        end
    elseif value.Ability == "Donald" then
        local slot = DonaldBack -(#DonaldAbilitiesReceived - 1) * 2
        if not DonaldBufferSlots[slot] then
            WriteShort(Save + slot, value.Address)
        else
            ConsolePrint("Error too many abilities cannot receive anymore. Ability skipped "  .. value.Name)
        end
    elseif value.Ability == "Goofy" then
        local slot = GoofyBack -(#GoofyAbilitiesReceived - 1) * 2
        if not GoofyBufferSlots[slot] then
            WriteShort(Save + slot, value.Address)
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
