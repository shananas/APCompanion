local LocationHandler = {}

function LocationHandler:CheckWorldLocations()
    local CurrentWorld = ReadByte(Now)
    local checks = WorldTables[CurrentWorld]
    if checks then
        for locationID, check in pairs(checks) do
            if not LocationsChecked[locationID] and not ChestsOpenedList[locationID] then
                if (ReadByte(Save + check.Address) & (0x1 << check.BitIndex)) > 0 then
                    LocationsChecked[locationID] = true
                    if check.Chest then
                        StoreChest(check)
                    end
                    SendToApClient(MessageTypes.WorldLocationChecked, {locationID})
                end
            end
        end
    end
end


function LocationHandler:CheckLevelLocations()
    local CurrentLevel = ReadByte(Save + 0x24FF)
    if CurrentLevel > MaxSoraLevel.Value then
        MaxSoraLevel.Value = CurrentLevel
        SendToApClient(MessageTypes.LevelChecked, {CurrentLevel, "Sora"})
    elseif MaxSoraLevel.Value > CurrentLevel then
        WriteByte(Save + 0x24FF, MaxSoraLevel.Value)
    end
    FormsLists = {ValorForm, WisdomForm, LimitForm, MasterForm, FinalForm, SummonLevels}
    FormLevels = {MaxValorLevel, MaxWisdomLevel, MaxLimitLevel, MaxMasterLevel, MaxFinalLevel, MaxSummonLevel}
    for i = 1, 6 do
        local _, entry = next(FormsLists[i])
        local CurrentFormLevel = ReadByte(Save + entry.Address)
        if CurrentFormLevel > FormLevels[i].Value then
            FormLevels[i].Value = CurrentFormLevel
            SendToApClient(MessageTypes.LevelChecked, {FormLevels[i].Value, entry.Name:match("^[^ ]+").."Level"})
        elseif FormLevels[i].Value > CurrentFormLevel then
            WriteByte(Save + entry.Address, FormLevels[i].Value)
        end
    end
end

function LocationHandler:CheckWeaponAbilities()
    for locationID, ability in pairs(WeaponAbilities) do
        if not LocationsChecked[locationID] then
            if ReadByte(Save + ability.Address) > 0 then
                LocationsChecked[locationID] = true
                SendToApClient(MessageTypes.KeybladeSlotChecked, {locationID})
            end
        end
    end
    for locationID, ability in pairs (FormWeaponAbilities) do
        if not LocationsChecked[locationID] and ReadByte(Save + 0x06B2) == 0 then
            if (ReadByte(Save + ability.Address) & (0x1 << ability.BitIndex)) > 0 then
                LocationsChecked[locationID] = true
                SendToApClient(MessageTypes.KeybladeSlotChecked, {locationID})
            end
        end
    end
end

function LocationHandler:CheckChests()
    local CurrentWorld = ReadByte(Now)
    local checks = WorldTables[CurrentWorld]
    if checks then
        for locationID, check in pairs(checks) do
            if ChestsOpenedList[locationID] then
                local opened = ReadByte(Save + check.Address)
                if (opened & (1 << check.BitIndex)) == 0 then
                    WriteByte(Save + check.Address, opened | (1 << check.BitIndex))
                end
            end
        end
    end
end

return LocationHandler