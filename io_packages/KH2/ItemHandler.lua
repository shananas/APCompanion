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
    --ConsolePrint(string.format("%X", value.Address))
    --ConsolePrint(value.Bitmask)
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
            current = ReadShort(Save + HighJumpSlot) | 0x8000
            if current == 0x8000 then
                WriteShort(Save + HighJumpSlot, 0x05E)
            elseif current < 0x8061 then
                WriteShort(Save + HighJumpSlot, ReadShort(Save + HighJumpSlot)+1)
            end
        elseif value.Name == "Quick Run" then
            current = ReadShort(Save + QuickRunSlot) | 0x8000
            if current == 0x8000 then
                WriteShort(Save + QuickRunSlot, 0x062)
            elseif current < 0x8065 then
                WriteShort(Save + QuickRunSlot, ReadShort(Save + QuickRunSlot)+1)
            end
        elseif value.Name == "Dodge Roll" then
            current = ReadShort(Save + DodgeRollSlot) | 0x8000
            if current == 0x8000 then
                WriteShort(Save + DodgeRollSlot, 0x234)
            elseif current < 0x8237 then
                WriteShort(Save + DodgeRollSlot, ReadShort(Save + DodgeRollSlot)+1)
            end
        elseif value.Name == "Aerial Dodge" then
            current = ReadShort(Save + AerialDodgeSlot) | 0x8000
            if current == 0x8000 then
                WriteShort(Save + AerialDodgeSlot, 0x066)
            elseif current < 0x8069 then
                WriteShort(Save + AerialDodgeSlot, ReadShort(Save + AerialDodgeSlot)+1)
            end
        elseif value.Name == "Glide" then
            current = ReadShort(Save + GlideSlot) | 0x8000
            if current == 0x8000 then
                WriteShort(Save + GlideSlot, 0x06A)
            elseif current < 0x806D then
                WriteShort(Save + GlideSlot, ReadShort(Save + GlideSlot)+1)
            end
        else
            if SoraCurrentAbilitySlot <= SoraFront then
                ConsolePrint("Max ability limit reached cannot receive any more abilities.")
            else
                if ReadShort(Save + SoraCurrentAbilitySlot) ~= 0 then
                    SoraCurrentAbilitySlot = FindEmptyAbilitySlot(SoraCurrentAbilitySlot, SoraFront)
                end
                if SoraCurrentAbilitySlot > SoraFront then
                    WriteShort(Save + SoraCurrentAbilitySlot, value.Address)
                    SoraCurrentAbilitySlot = SoraCurrentAbilitySlot - 2
                else
                    ConsolePrint("Max ability limit reached cannot receive any more abilities.")
                end
            end
        end
    elseif value.Ability == "Donald" then
        if  DonaldCurrentAbilitySlot <= DonaldFront then
            ConsolePrint("Max ability limit reached cannot receive any more abilities.")
        else
            if ReadShort(Save + DonaldCurrentAbilitySlot) ~= 0 then
                DonaldCurrentAbilitySlot = FindEmptyAbilitySlot(DonaldCurrentAbilitySlot, DonaldFront)
            end
            if DonaldCurrentAbilitySlot > DonaldFront then
                WriteShort(Save + DonaldCurrentAbilitySlot, value.Address)
                DonaldCurrentAbilitySlot = DonaldCurrentAbilitySlot - 2
            else
                ConsolePrint("Max ability limit reached cannot receive any more abilities.")
            end
        end
    elseif value.Ability == "Goofy" then
        if  GoofyCurrentAbilitySlot <= GoofyFront then
            ConsolePrint("Max ability limit reached cannot receive any more abilities.")
        else
            if ReadShort(Save + GoofyCurrentAbilitySlot) ~= 0 then
                GoofyCurrentAbilitySlot = FindEmptyAbilitySlot(GoofyCurrentAbilitySlot, GoofyFront)
            end
            if GoofyCurrentAbilitySlot > GoofyFront then
                WriteShort(Save + GoofyCurrentAbilitySlot, value.Address)
                GoofyCurrentAbilitySlot = GoofyCurrentAbilitySlot - 2
            else
                ConsolePrint("Max ability limit reached cannot receive any more abilities.")
            end
        end
    end
end

function FindEmptyAbilitySlot (value, front)
	while ReadShort(Save + value) ~= 0 do
        value = value -2
        if value <= front then
            return value
        end
    end
    return value
end

function ItemHandler:Request()
  SendToApClient(MessageTypes.RequestAllItems,{})
end

function ItemHandler:RemoveAbilities()
   for slot, _ in pairs(SoraBufferSlots) do
       if ReadShort(Save + slot) ~= 0 and not SoraBufferSlots[SoraCurrentAbilitySlot] and SoraCurrentAbilitySlot > SoraFront then
           WriteShort(Save + SoraCurrentAbilitySlot, ReadShort(Save + slot))
           WriteShort(Save + slot, 0)
           SoraCurrentAbilitySlot = SoraCurrentAbilitySlot - 2
       end
   end
   for slot, _ in pairs(DonaldBufferSlots) do
       if ReadShort(Save + slot) ~= 0 and not DonaldBufferSlots[DonaldCurrentAbilitySlot] and DonaldCurrentAbilitySlot > DonaldFront then
           WriteShort(Save + DonaldCurrentAbilitySlot, ReadShort(Save + slot))
           WriteShort(Save + slot, 0)
           DonaldCurrentAbilitySlot = DonaldCurrentAbilitySlot - 2
       end
   end
   for slot, _ in pairs(GoofyBufferSlots) do
       if ReadShort(Save + slot) ~= 0 and not GoofyBufferSlots[GoofyCurrentAbilitySlot] and GoofyCurrentAbilitySlot > GoofyFront then
           WriteShort(Save + GoofyCurrentAbilitySlot, ReadShort(Save + slot))
           WriteShort(Save + slot, 0)
           GoofyCurrentAbilitySlot = GoofyCurrentAbilitySlot - 2
       end
   end
end

return ItemHandler
