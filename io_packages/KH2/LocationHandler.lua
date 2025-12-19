local LocationHandler = {}

local talked = false

function LocationHandler:CheckWorldLocations()
    local CurrentWorld = ReadByte(Now)
    local checks = worldTables[CurrentWorld]
    if checks then
        for i = 1, #checks do
            local contained = false
            for j = 1, #LocationsChecked do
                if checks[i].Name == LocationsChecked[j] or ChestsOpenedList[checks[i].Name] then
                    contained = true
                    break
                end
            end
            if not contained and (ReadByte(Save + checks[i].Address) & (0x1 << checks[i].BitIndex)) > 0 then
                table.insert(LocationsChecked, checks[i].Name)
                if checks[i].Chest then
                    StoreChest(checks[i])
                end
                SendToApClient(MessageTypes.WorldLocationChecked, {checks[i].Name})
            end
        end
    end
    if not talked then
        ConsolePrint("Hello")
        talked = true
    end
end


function LocationHandler:CheckLevelLocations()
    CurrentLevel = ReadByte(Save + 0x24FF)
    if CurrentLevel > MaxSoraLevel.value then
        MaxSoraLevel.value = CurrentLevel
        SendToApClient(MessageTypes.LevelChecked, {CurrentLevel, "Sora"})
    elseif MaxSoraLevel.value > CurrentLevel then
        WriteByte(Save + 0x24FF, MaxSoraLevel.value)
    end
    FormsLists = {ValorForm , WisdomForm, LimitForm, MasterForm, FinalForm, SummonLevels}
    FormLevels = {MaxValorLevel, MaxWisdomLevel, MaxLimitLevel, MaxMasterLevel, MaxFinalLevel, MaxSummonLevel}
    for i = 1, 6 do
        CurrentFormLevel = ReadByte(Save + FormsLists[i][i].Address)
        if CurrentFormLevel > FormLevels[i].value then
            FormLevels[i].value = CurrentFormLevel
            SendToApClient(MessageTypes.LevelChecked, {FormLevels[i].value, FormsLists[i][1].Name:match("^[^ ]+").."Level"})
        elseif FormLevels[i].value > CurrentFormLevel then
            WriteByte(Save + FormsLists[i][i].Address, FormLevels[i].value)
        end
    end
end

function LocationHandler:CheckWeaponAbilities()
    local contained = false
    for i = 1, #WeaponAbilities do
        for j = 1, #LocationsChecked do
            if WeaponAbilities[i].Name == LocationsChecked[j] then
                contained = true
                break
            end
        end
        if not contained then
            if ReadByte(Save + WeaponAbilities[i].Address) > 0 then
                table.insert(LocationsChecked, WeaponAbilities[i].Name)
                SendToApClient(MessageTypes.KeybladeChecked, {WeaponAbilities[i].Name})
            end
        end
        contained = false
	end

    for i = 1, #FormWeaponAbilities do
        for j = 1, #LocationsChecked do
            if FormWeaponAbilities[i].Name == LocationsChecked[j] then
                contained = true
                break
            end
        end
        if not contained and ReadByte(Save + 0x06B2) == 0 then
            if (ReadByte(Save + FormWeaponAbilities[i].Address) & (0x1 << FormWeaponAbilities[i].BitIndex)) > 0 then
                table.insert(LocationsChecked, FormWeaponAbilities[i].Name)
                SendToApClient(MessageTypes.KeybladeChecked, {FormWeaponAbilities[i].Name})
            end
        end
        contained = false
    end
end

function LocationHandler:CheckChests()
    local CurrentWorld = ReadByte(Now)
    local checks = worldTables[CurrentWorld]
    if checks then
        for i = 1, #checks do
            if ChestsOpenedList[checks[i].Name] then
                local Opened = ReadByte(Save + checks[i].Address)
                if (Opened & (1 << checks[i].BitIndex)) == 0 then
                    WriteByte(Save + checks[i].Address, Opened | (1 << checks[i].BitIndex))
                end
            end
        end
    end
end

return LocationHandler