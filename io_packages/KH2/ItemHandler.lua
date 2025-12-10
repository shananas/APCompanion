local ItemHandler = {}

SoraBack = 0x25D8
SoraFront = 0x2546
SoraCurrentAbilitySlot = 0x25D8
SoraCurrentAbilityInt = 70

HighJumpSlot = 0x25DA
QuickRunSlot = 0x25DC
DodgeRollSlot = 0x25DE
AerialDodgeSlot = 0x25E0
GlideSlot = 0x25E2

DonaldBack = 0x26F4
DonaldFront = 0x2658
DonaldCurrentAbilitySlot = 0x26F4
DonaldCurrentAbilityInt = 78

GoofyBack = 0x2808
GoofyFront = 0x276C
GoofyCurrentAbilitySlot = 0x2808
GoofyCurrentAbilityInt = 78

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
            WriteShort(Save + SoraCurrentAbilitySlot, value.Address)
            SoraCurrentAbilitySlot = SoraCurrentAbilitySlot - 2
            SoraCurrentAbilityInt = SoraCurrentAbilityInt - 1
        end
    elseif value.Ability == "Donald" and DonaldCurrentAbilitySlot > DonaldFront then
        WriteShort(Save + DonaldCurrentAbilitySlot, value.Address)
        DonaldCurrentAbilitySlot = DonaldCurrentAbilitySlot - 2
        DonaldCurrentAbilityInt = SoraCurrentAbilityInt - 1
    elseif value.Ability == "Goofy" and GoofyCurrentAbilitySlot > GoofyFront then
        WriteShort(Save + GoofyCurrentAbilitySlot, value.Address)
        GoofyCurrentAbilitySlot = GoofyCurrentAbilitySlot - 2
        GoofyCurrentAbilityInt = SoraCurrentAbilityInt - 1
    end
end

function ItemHandler:Request()
  SendToApClient(MessageTypes.RequestAllItems,{})
end

function ItemHandler:RemoveAbilities()
    for i = 0, SoraCurrentAbilityInt do
        WriteShort(SoraFront + (i * 2), 0)
    end
    for i = 0, DonaldCurrentAbilityInt do
        WriteShort(DonaldFront + (i * 2), 0)
    end
    for i = 0, GoofyCurrentAbilityInt do
        WriteShort(GoofyFront + (i * 2), 0)
    end
end
return ItemHandler
