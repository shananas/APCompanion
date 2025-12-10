local ItemHandler = {}

SoraBack = 0x25D8
SoraFront = 0x2546
SoraCurrentAbilitySlot = 0x25D8
SoraBufferSlots = { 0x2546, 0x2548, 0x254A, 0x254C }

HighJumpSlot = 0x25DA
QuickRunSlot = 0x25DC
DodgeRollSlot = 0x25DE
AerialDodgeSlot = 0x25E0
GlideSlot = 0x25E2

DonaldBack = 0x26F4
DonaldFront = 0x2658
DonaldCurrentAbilitySlot = 0x26F4
DonaldBufferSlots = { 0x2658, 0x265A, 0x265C, 0x265E }

GoofyBack = 0x2808
GoofyFront = 0x276C
GoofyCurrentAbilitySlot = 0x2808
GoofyBufferSlots = { 0x276C, 0x276E,  0x2770, 0x2772 }

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
        WriteByte(Save + value.Address, ReadByte(Save + value.Address)| 0x01 <<value.Bitmask)
    else
        WriteByte(Save + value.Address, ReadByte(Save + value.Address)+1)
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
        elseif SoraCurrentAbilitySlot > SoraFront then
            if ReadShort(Save + SoraCurrentAbilitySlot) == 0 then
                WriteShort(Save + SoraCurrentAbilitySlot, value.Address)
                SoraCurrentAbilitySlot = SoraCurrentAbilitySlot - 2
            else
                SoraCurrentAbilitySlot = SoraFront
                ConsolePrint("Max ability limit reached cannot receive any more abilities.")
            end
        end
    elseif value.Ability == "Donald" and DonaldCurrentAbilitySlot > DonaldFront then
        if ReadShort(Save + DonaldCurrentAbilitySlot) == 0 then
            WriteShort(Save + DonaldCurrentAbilitySlot, value.Address)
            DonaldCurrentAbilitySlot = DonaldCurrentAbilitySlot - 2
        else
            DonaldCurrentAbilitySlot = DonaldFront
            ConsolePrint("Max ability limit reached cannot receive any more abilities.")
        end
    elseif value.Ability == "Goofy" and GoofyCurrentAbilitySlot > GoofyFront then
        if ReadShort(Save + GoofyCurrentAbilitySlot) == 0 then
            WriteShort(Save + GoofyCurrentAbilitySlot, value.Address)
            GoofyCurrentAbilitySlot = GoofyCurrentAbilitySlot - 2
        else
            GoofyCurrentAbilitySlot = GoofyFront
            ConsolePrint("Max ability limit reached cannot receive any more abilities.")
        end
    end
end

function ItemHandler:Request()
  SendToApClient(MessageTypes.RequestAllItems,{})
end

function ItemHandler:RemoveAbilities()
    for i = 1, #SoraBufferSlots do
        if ReadShort(Save + SoraBufferSlots[i] ~= 0) and not SoraBufferSlots[SoraCurrentAbilitySlot] then
            ReadShort(Save + SoraCurrentAbilitySlot, ReadShort(Save + SoraBufferSlots[i]))
            ReadShort(Save + SoraBufferSlots[i], 0)
            SoraCurrentAbilitySlot = SoraCurrentAbilitySlot - 2
        end
    end
    for i = 1, #DonaldBufferSlots do
        if ReadShort(Save + DonaldBufferSlots[i] ~= 0) and not DonaldBufferSlots[DonaldCurrentAbilitySlot] then
            ReadShort(Save + DonaldCurrentAbilitySlot, ReadShort(Save + DonaldBufferSlots[i]))
            ReadShort(Save + DonaldBufferSlots[i], 0)
            DonaldCurrentAbilitySlot = DonaldCurrentAbilitySlot - 2
        end
    end
    for i = 1, #GoofyBufferSlots do
        if ReadShort(Save + GoofyBufferSlots[i] ~= 0) and not GoofyBufferSlots[GoofyCurrentAbilitySlot] then
            ReadShort(Save + GoofyCurrentAbilitySlot, ReadShort(Save + GoofyBufferSlots[i]))
            ReadShort(Save + GoofyBufferSlots[i], 0)
            GoofyCurrentAbilitySlot = GoofyCurrentAbilitySlot - 2
        end
    end
end

return ItemHandler
