---------------------------------------------------
------ Kingdom Hearts Dream Drop Distance AP ------
------                by Lux                 ------
---------------------------------------------------
------ Special Thanks to Sonicshadowsilver2, Meebo, & Krujo
---------------------------------------------------

local socket = require("socket")
local ItemHandler = require("KH2.ItemHandler")
local ItemDefs = require("KH2.ItemDefs")
local LocationDefs = require("KH2.LocationDefs")
local LocationHandler = require("KH2.LocationHandler")
local RoomSaveTask = require("KH2.RoomSaveTask")

LUAGUI_NAME = "KH2 AP Connector [Socket]"
LUAGUI_AUTH = "Shananas"
LUAGUI_DESC = "Kingdom Hearts 2 AP Integration using Lua Socket"

local GameStarted = false
local ConnectionInitialized = false
local FrameCount = 0
local FramerateSelected = -1
local Modulo = 15
local QuarterSecond = 0
local HalfSecond = 0
local OneSecond = 0
local FiveSeconds = 0
ChestWait = false

local client

Kh2sciiDict = {
	 ['a'] = 0x9A, ['b'] = 0x9B, ['c'] = 0x9C, ['d'] = 0x9D, ['e'] = 0x9E, ['f'] = 0x9F, ['g'] = 0xA0, ['h'] = 0xA1,
	 ['i'] = 0xA2, ['j'] = 0xA3, ['k'] = 0xA4, ['l'] = 0xA5, ['m'] = 0xA6, ['n'] = 0xA7, ['o'] = 0xA8, ['p'] = 0xA9,
	 ['q'] = 0xAA, ['r'] = 0xAB, ['s'] = 0xAC, ['t'] = 0xAD, ['u'] = 0xAE, ['v'] = 0xAF, ['w'] = 0xB0, ['x'] = 0xB1,
	 ['y'] = 0xB2, ['z'] = 0xB3,

	 ['A'] = 0x2E, ['B'] = 0x2F, ['C'] = 0x30, ['D'] = 0x31, ['E'] = 0x32, ['F'] = 0x33,
	 ['G'] = 0x34, ['H'] = 0x35, ['I'] = 0x36, ['J'] = 0x37, ['K'] = 0x38, ['L'] = 0x39, ['M'] = 0x3A, ['N'] = 0x3B,
	 ['O'] = 0x3C, ['P'] = 0x3D, ['Q'] = 0x3E, ['R'] = 0x3F, ['S'] = 0x40, ['T'] = 0x41, ['U'] = 0x42, ['V'] = 0x43,
	 ['W'] = 0x44, ['X'] = 0x45, ['Y'] = 0x46, ['Z'] = 0x47,

	 ['1'] = 0x91, ['2'] = 0x92, ['3'] = 0x93, ['4'] = 0x94,
	 ['5'] = 0x95, ['6'] = 0x96, ['7'] = 0x97, ['8'] = 0x98, ['9'] = 0x99,

	 [' '] = 0x01, ['\n'] = 0x02, ['-'] = 0x54, ['!']  = 0x48, ['?']  = 0x49, ['%'] = 0x4A, ['/'] = 0x4B,
	 ['.'] = 0x4F, [',']  = 0x50, [';'] = 0x51, ['='] = 0x52, ['\''] = 0x57, ['('] = 0x5A, [')'] = 0x5B,
	 ['['] = 0x62, [']']  = 0x63, ['à'] = 0xB7, ['á']  = 0xB8, ['â']  = 0xB9, ['ä'] = 0xBA, ['è'] = 0xBB,
	 ['é'] = 0xBC, ['ê']  = 0xBD, ['ë'] = 0xBE, ['ì']  = 0xBF, ['í']  = 0xC0, ['î'] = 0xC1, ['ï'] = 0xC2,
	 ['ñ'] = 0xC3, ['ò']  = 0xC4, ['ó'] = 0xC5, ['ô']  = 0xC6, ['ö']  = 0xC7, ['ù'] = 0xC8, ['ú'] = 0xC9,
	 ['û'] = 0xCA, ['ü']  = 0xCB, ['ç'] = 0xE8, ['À']  = 0xD0, ['Á']  = 0xD1, ['Â'] = 0xD2, ['Ä'] = 0xD3,
	 ['È'] = 0xD4, ['É']  = 0xD5, ['Ê'] = 0xD6, ['Ë']  = 0xD7, ['Ì']  = 0xD8, ['Í'] = 0xD9, ['Î'] = 0xDA,
	 ['Ï'] = 0xDB, ['Ñ']  = 0xDC, ['Ò'] = 0xDD, ['Ó']  = 0xDE, ['Ô']  = 0xDF, ['Ö'] = 0xE0, ['Ù'] = 0xE1,
	 ['Ú'] = 0xE2, ['Û']  = 0xE3, ['Ü'] = 0xE4, ['¡']  = 0xE5, ['¿']  = 0xE6, ['Ç'] = 0xE7,
}

MessageTypes = {
    WorldLocationChecked = 1,
    LevelChecked = 2,
    KeybladeSlotChecked = 3,
    CurrentWorldInt = 4,
    FinalXemnasDefeated = 5,
    SendProofs = 6,
    SoldItems = 7,
    ChestsOpened = 8,
    Deathlink = 9,
    NotificationType = 10,
    NotificationMessage = 11,
    GiveItem = 12,
    RequestAllItems = 13,
    Handshake = 19,
    Closed = 20,
}
HandshakeSent = false
HandshakeReceived = false

--Items
Items = {}
Abilities = {}
ItemsReceived = {
	["Torn Page"] = 0,
}
TornPagesReceived = 0
ItemQueue = {}

--Locations
Worlds = {}
ValorForm = {}
WisdomForm = {}
LimitForm = {}
MasterForm = {}
FinalForm = {}
SummonLevels = {}
SoraAbilitiesReceived = {}
--current is (level 1 growth - 1) since anytime you receive it it increments it by 1 including the first growth
SoraGrowthReceived = {
	["High Jump"] = {Current = 0x05D, Max = 0x061},
	["Quick Run"] = {Current = 0x061, Max = 0x065},
	["Dodge Roll"] = {Current = 0x233, Max = 0x237},
	["Aerial Dodge"] = {Current = 0x065, Max = 0x069},
	["Glide"] = {Current = 0x069, Max = 0x06D},
}
DonaldAbilitiesReceived = {}
GoofyAbilitiesReceived = {}
WeaponAbilities = {}
FormWeaponAbilities = {}

LocationsChecked = {}
ChestsOpenedList = {}

MaxSoraLevel = { Value = 1 }
MaxValorLevel = { Value = 1 }
MaxWisdomLevel = { Value = 1 }
MaxLimitLevel = { Value = 1 }
MaxMasterLevel = { Value = 1 }
MaxFinalLevel = { Value = 1 }
MaxSummonLevel = { Value = 1 }

ProofsGiven = false
FormSummonLevels = {
	0x32F6,
	0x332E,
	0x3366,
	0x339E,
	0x33D6,
	0x3526,
}
DeathlinkEnabled = false
ReceivedDeath = false
VictorySent = false
LastReceivedIndex = -1
LastWorld = -1
CurrentWorld = -1
SendNotificationType = "none"
ReceiveNotificationType = "none"
NotificationMessage = {}
SellableItems = {}
SoldItems = {}
local ShopState = {
	Active = false,
	SellableSnapshot = {},
}
WorldTables = {}

-- ############################################################
-- ######################  Socket  ############################
-- #############  Special Thanks to Krujo  ####################
-- ############################################################

function ConnectToApClient()
    local ok, err = client:connect("127.0.0.1", 13137)

    if ok or err == "already connected" then
        ConsolePrint("Connected to client!")
		return true
    elseif err == "timeout" then
        -- NON-BLOCKING: means connection is still in progress
        return false
    else
        -- Any other error = failed
        --ConsolePrint("Failed to connect: " .. tostring(err))
        return false
    end
end

function SendToApClient(type,messages)
	if client then
		local message = tostring(type)
		for i = 1, #messages do
			message = message .. ";" .. tostring(messages[i])
		end
		message = message .. "\n"

		ConsolePrint("Sending message:" .. message)
		client:send(message)
	end
end

function HandleMessage(msg)
	if msg.type == nil then
		ConsolePrint("No message type defined; cannot handle")
		return
	end

	if msg.type == MessageTypes.GiveItem then
		ConsolePrint("Receiving single item")
		local _item
		if tonumber(msg.values[3]) > LastReceivedIndex then
			LastReceivedIndex = tonumber(msg.values[3])
			if msg.values[2] == "false" then
				_item = getItemById(tonumber(msg.values[1]))
			else
				_item = getAbilityById(tonumber(msg.values[1]), msg.values[2])
			end
			table.insert(ItemQueue, _item)
		else
			ConsolePrint("Already received item: " .. table.concat(msg.values, ","))
		end

	elseif msg.type == MessageTypes.Deathlink then
		if msg.values[1] ~= nil then
			DeathlinkEnabled = ("True" == msg.values[1])
			ConsolePrint(tostring(DeathlinkEnabled))
		else
			ReceivedDeath = true
		end

	elseif msg.type == MessageTypes.SoldItems then
		SoldItems[msg.values[1]] = tonumber(msg.values[2])


	elseif msg.type == MessageTypes.ChestsOpened then
		ChestsOpenedList[tonumber(msg.values[1])] = true

	elseif msg.type == MessageTypes.Handshake then
		HandshakeReceived = true
		SendToApClient(MessageTypes.CurrentWorldInt, {World})
		if msg.values[1] == "True" then
			ConsolePrint("Received handshake; Requesting items")
			SendToApClient(MessageTypes.RequestAllItems, {"Requesting Items"})
		end

	elseif msg.type == MessageTypes.NotificationType then
		if msg.values[1] == "R" then
			ReceiveNotificationType = msg.values[2]
		elseif msg.values[1] == "S" then
			SendNotificationType = msg.values[2]
		end

	elseif msg.type == MessageTypes.NotificationMessage then
		table.insert(NotificationMessage, { msg.values[1], msg.values[2] })

	elseif msg.type == MessageTypes.SendProofs then
		ItemsReceived["Proof of Connection"] = 1
		ItemsReceived["Proof of Nonexistence"] = 1
		ItemsReceived["Proof of Peace"] = 1
		WriteByte(Save + 0x36B2, 1)
		WriteByte(Save + 0x36B3, 1)
		WriteByte(Save + 0x36B4, 1)
		RoomSaveTask:StoreItem({ID = 593, Name = "Proof of Connection", Type = "Progression", Address = 0x36B2})
		RoomSaveTask:StoreItem({ID = 594, Name = "Proof of Nonexistence", Type = "Progression", Address = 0x36B3})
		RoomSaveTask:StoreItem({ID = 595, Name = "Proof of Peace", Type = "Progression", Address = 0x36B4})

	end
end

local BuildingMessage = ""
function ReceiveFromApClient()
    if not client then return {} end

	local messages = {}
	while true do
		local message, err = client:receive("*l")
		if message and message ~= "" then

			if BuildingMessage ~= "" then
				message = BuildingMessage .. message
				BuildingMessage = ""
			end

            local isWait = message:sub(-4) == ";MOR"
            local isFin = message:sub(-4) == ";FIN"
            if isWait then
                BuildingMessage = message:sub(1, -5)
            elseif isFin then
                message = message:sub(1, -5)
            end

			if not isWait then
				ConsolePrint("Full message received: " .. message)
				local parts = SplitString(message, ";")
				local type = tonumber(parts[1])
				local newMessage = {
				    type = GetMessageType(type),
				    values = {}
				}

				for i = 2, #parts do
				    table.insert(newMessage.values, parts[i])
				end

				if newMessage.type == MessageTypes.Closed then
				    ConsolePrint("Server closed resetting client")
				    CloseConnection()
				    return {}
				end

				table.insert(messages, newMessage)
			end
		else
			if err and err ~= "timeout" and err ~= "wantread" then
				ConsolePrint("Error receiving message: " .. err)
				CloseConnection()
			end
			break
		end
	end

    return messages
end

function CloseConnection()
	ConnectionInitialized = false
	GameStarted = false
	HandshakeSent = false
	HandshakeReceived = false
	client:close()
	client = socket.tcp()
	client:settimeout(0)
end

function ProcessItemQueue()
	local Sent = 0
	while Sent < 1000 and #ItemQueue > 0 do
		local item = ItemQueue[1]
		if ReadByte(Pause) == 0  and ReadByte(FadeStatus) == 0 and ReadByte(Cntrl) == 0 and
		ReadLong(PlayerGaugePointer) ~= 0 and ReadLong(ReadLong(PlayerGaugePointer)+0x88, true) ~= 0 then
			if item.Type ~= "Ability" then
				ConsolePrint(tostring(item.Name))
				if item.Name ~= "Torn Page" then
					ItemsReceived[item.Name] = math.min((ItemsReceived[item.Name] or 0) + 1, 255)
				else
					TornPagesReceived = TornPagesReceived + 1
					local TornPagesRedeemed = 0
					for i = 1, #PoohProgress do
						if (ReadByte(Save + PoohProgress[i].Address) & (0x1 << PoohProgress[i].BitIndex)) > 0 then
							TornPagesRedeemed = TornPagesRedeemed + 1
						end
					end
					ItemsReceived[item.Name] = math.max(0, math.min(TornPagesReceived - TornPagesRedeemed, 255))
				end
			else
				ProcessAbility(item)
			end
			ItemHandler:Receive(item)
			RoomSaveTask:StoreItem(item)
			table.remove(ItemQueue,1)
			Sent = Sent + 1
		else
			break
		end
	end
end

-- ############################################################
-- ######################  Helpers  ###########################
-- ############################################################

function getItemById(item_id)
	for i = 1, #Items do
		if Items[i].ID == item_id then
			return Items[i]
		end
	end
end

function getAbilityById(ab_id, member)
	for i = 1, #Abilities do
		if Abilities[i].ID == ab_id  and Abilities[i].Ability == member then
			return Abilities[i]
		end
	end
end

function SplitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function GetMessageType(value)
	for name, number in pairs(MessageTypes) do
		if number == value then
			return MessageTypes[name]
		end
	end
	return nil
end

function textToKHSCII(value)
	--Returns byte array based on string
	local returnArr = {}
	local i = 1
	while i <= #value do
		local c = value:sub(i, i)
		local charCode
		if c == '{' then
			local command = value:sub(i, i + 5)
			if command:match("^%{0x[%da-fA-F][%da-fA-F]%}$") then
			    local hexVal = command:sub(2, 5)
			    charCode = tonumber(hexVal, 16)
			    i = i + 6  -- skip the whole command
			else
			    i = i + 1  -- not a valid command, just move forward
			end
		else
			charCode = Kh2sciiDict[c] or 0x01
			i = i + 1
		end

		if charCode then
			table.insert(returnArr, charCode)
		end
	end
	table.insert(returnArr, 0x00)

	return returnArr
end

function CurrentWorldLocation()
    CurrentWorld = World
	if LastWorld ~= CurrentWorld then
		LastWorld = CurrentWorld
		LocationHandler:CheckChests()
		SendToApClient(MessageTypes.CurrentWorldInt, {CurrentWorld})
	end
end

function Deathlink()
	local KillSora = false
	local IsDead = ReadLong(IsDeadAddress)
	--if deathlink from another player
	if ReceivedDeath then
		-- if drive gauge >= 5 and not in atlantica
		if ReadByte(Slot1+0x1B2)>=5 and World ~= 11 then
			--if safe to kill sora
			if World~=6 or Room~=0 then
				WriteByte(Slot1,0)
			end
		end
	end
	-- if the script says kill sora and we are safe to do so kill him
	if(IsDead~=0) then
		HasDied = true
	end
	if(HasDied and IsDead==0)then
		HasDied = false
		if(not ReceivedDeath) then
			SendToApClient(MessageTypes.Deathlink,{Room, Evt, World})
		end
		ReceivedDeath = false
	end
end

--This function is needed for room save to work
function SendToInv(item)
    ItemHandler:Receive(item)
end

function StoreChest(item)
	RoomSaveTask:StoreLocation(item)
end

function ProcessAbility(item)
	if SoraGrowthReceived[item.Name] then
		if SoraGrowthReceived[item.Name].Current < SoraGrowthReceived[item.Name].Max then
			SoraGrowthReceived[item.Name].Current = SoraGrowthReceived[item.Name].Current + 1
		end
	elseif item.Ability == "Sora" then
		table.insert(SoraAbilitiesReceived, item)
	elseif item.Ability == "Donald" then
		table.insert(DonaldAbilitiesReceived, item)
	elseif item.Ability == "Goofy" then
		table.insert(GoofyAbilitiesReceived, item)
	end
end

function ProcessNotification()
	if #NotificationMessage > 0 then
		if not ChestWait then
			if type(NotificationMessage[1]) ~= "table" or type(NotificationMessage[1][1]) ~= "string" or type(NotificationMessage[1][2]) ~= "string" then
				ConsolePrint("Bad NotificationMessage entry removing")
				table.remove(NotificationMessage, 1)
				return
			end
			if NotificationMessage[1][1] ~= "S" and NotificationMessage[1][1] ~= "R" then
				ConsolePrint("Unknown notification type removing entry")
				table.remove(NotificationMessage, 1)
				return
			end
		end
		local NotifType
		if NotificationMessage[1][1]  == "S" then
			NotifType = SendNotificationType
		elseif NotificationMessage[1][1]  == "R" then
			NotifType = ReceiveNotificationType
		end

		if NotifType == "chest" then
			if not ChestWait then
				if ReadByte(0x800000) == 0 then
					local msg = textToKHSCII(NotificationMessage[1][2])
					WriteByte(0x800150, 0)
					WriteArray(0x800154, msg)
					ChestWait = true
				end
			elseif (FrameCount % OneSecond) == 0 then
				WriteByte(0x800000, 3)
				table.remove(NotificationMessage,1)
				ChestWait = false
			end
		elseif NotifType == "puzzle" then
			if ReadByte(0x800000) == 0 then
				local msg = textToKHSCII(NotificationMessage[1][2])
				WriteArray(0x800104, msg)
				WriteByte(0x800000, 2)
				table.remove(NotificationMessage,1)
			end
		elseif NotifType == "info" then
			if ReadByte(0x0717418) == 1 then
				local InfoBarPointerRef = ReadLong(InfoBarPointer)
				if ReadByte(0x800000) == 0 and InfoBarPointerRef ~= 0 and ReadInt(InfoBarPointerRef + 0x48) == 0 then
					WriteByte(0x800000, 1)
					local msg = textToKHSCII(NotificationMessage[1][2])
					WriteArray(0x800004, msg)
					table.remove(NotificationMessage,1)
				end
			end
		end
	end
end

function IsInShop()
	local JournalValue = ReadShort(Journal)
	local ShopValue = ReadShort(Shop)
	local InShop = (JournalValue ~= -1 and ShopValue == 5) or (JournalValue == -1 and ShopValue == 10)

	if InShop and not ShopState.Active then
		ShopState.Active = true
		ShopState.SellableSnapshot = {}
		for i = 1, #SellableItems do
			local Amount = ReadByte(Save + SellableItems[i].Address)
			ShopState.SellableSnapshot[SellableItems[i].Name] = Amount
		end
	elseif not InShop and ShopState.Active then
		for i = 1, #SellableItems do
			local item = SellableItems[i]
			local BeforeShop = ShopState.SellableSnapshot[item.Name] or 0
			local AfterShop = ReadByte(Save + item.Address)
			SoldItems[item.Name] = (SoldItems[item.Name] or 0) + (BeforeShop - AfterShop)
			if SoldItems[item.Name] > 0 and BeforeShop - AfterShop > 0 then
				SendToApClient(MessageTypes.SoldItems, {item.Name, SoldItems[item.Name]})
			end
		end
		ShopState.Active = false
		ShopState.SellableSnapshot = {}
	end
end

-- ############################################################
-- ######################  Game Setup  ########################
-- ############################################################

local MessageLimit = 1000
function APCommunication()
    local MessagesProcessed = 0
	CurrentWorldLocation()
	LocationHandler:CheckLevelLocations()
	LocationHandler:CheckWeaponAbilities()
	LocationHandler:CheckWorldLocations()

    local messages = ReceiveFromApClient()
    for i = 1, #messages do
        HandleMessage(messages[i])
        MessagesProcessed = MessagesProcessed + 1
		if MessagesProcessed > MessageLimit then
			break
		end
    end
end

function _OnInit()
	--Initialize items and locations
	LocationDefs:DefineWorldEvents()
	LocationDefs:FormLevels()
	LocationDefs:WeaponSlots()
	LocationDefs:TornPageLocks()
	WorldTables = {
		[2]  = Worlds.TT_Checks,
		[4]  = Worlds.HB_Checks,
		[5]  = Worlds.BC_Checks,
		[6]  = Worlds.OC_Checks,
		[7]  = Worlds.AG_Checks,
		[8]  = Worlds.LoD_Checks,
		[9]  = Worlds.Pooh_Checks,
		[10] = Worlds.PL_Checks,
		[11] = Worlds.AT_Checks,
		[12] = Worlds.DC_Checks,
		[13] = Worlds.TR_Checks,
		[14] = Worlds.HT_Checks,
		[16] = Worlds.PR_Checks,
		[17] = Worlds.SP_Checks,
		[18] = Worlds.TWTNW_Checks
	}
	ItemDefs:DefineItems()
	ItemDefs:DefineAbilities()
	ItemDefs:SellableItems()
	GameVersion = 0
	ConsolePrint('KH2APConnector Initializing')
	client = socket.tcp()
	client:settimeout(0)
	WriteByte(0x800000, 0)
end

function _OnFrame()
	if GameVersion == 0 then --Get anchor addresses
		GetVersion()
		return
	end
	if true then
		World  = ReadByte(Now+0x00)
		Room   = ReadByte(Now+0x01)
		Place  = ReadShort(Now+0x00)
		Door   = ReadShort(Now+0x02)
		Map    = ReadShort(Now+0x04)
		Btl    = ReadShort(Now+0x06)
		Evt    = ReadShort(Now+0x08)
		PrevPlace = ReadShort(Now+0x30)
		ARD = ReadLong(ARDPointer)
	end
	if FramerateSelected ~= ReadByte(Framerate) then
		FramerateSelected = ReadByte(Framerate)
		if FramerateSelected == 0 then
			Modulo = 15
			QuarterSecond = Modulo
			HalfSecond = Modulo * 2
			OneSecond = Modulo * 4
			FiveSeconds = Modulo * 20
			ConsolePrint("Switched to 30 FPS")
		elseif FramerateSelected == 1 then
			Modulo = 30
			QuarterSecond = Modulo
			HalfSecond = Modulo * 2
			OneSecond = Modulo * 4
			FiveSeconds = Modulo * 20
			ConsolePrint("Switched to 60 FPS")
		elseif FramerateSelected == 2 or FramerateSelected == 3 then
			Modulo = 60
			QuarterSecond = Modulo
			HalfSecond = Modulo * 2
			OneSecond = Modulo * 4
			FiveSeconds = Modulo * 20
			ConsolePrint("Switched to 120/Unlimited FPS")
		else
			ConsolePrint("Error reading Framerate")
		end
	end
	FrameCount = FrameCount + 1
	if FrameCount >= FiveSeconds then
		FrameCount = 0
	end
	if not GameStarted and (FrameCount % QuarterSecond) == 0 then
		local connected =  ConnectToApClient()

		if connected then
			ConnectionInitialized = true
			GameStarted = true
		end
		return
	end
	IsInShop()
	PCInteracted = ReadByte(Save + 0x1D27) & 0x1 << 3 > 0
	if GameStarted and PCInteracted then
		if not HandshakeSent then
			SendToApClient(MessageTypes.Handshake, {"Requesting Handshake"})
			HandshakeSent = true
			return
		end
		if not HandshakeReceived then
			APCommunication()
		else
			RoomSaveTask:GetRoomChange()
			ItemHandler:RemoveAbilities()
			if not VictorySent and ((ReadByte(Save + 0x1ED9) & (0x1 << 0)) > 0 or (ReadByte(Save + 0x1ED8) & (0x1 << 1)) > 0) then
				SendToApClient(MessageTypes.FinalXemnasDefeated, {"Final Xemnas Defeated"})
				VictorySent = true
			end
			if not ShopState.Active then
				ItemHandler:VerifyInventory()
			end
			if (FrameCount % QuarterSecond) == 0 then
				APCommunication()
				ProcessItemQueue()
			end
			if (FrameCount % HalfSecond) == 0 then
				ProcessNotification()
			end
			if DeathlinkEnabled then
				Deathlink()
			end
		end
	end
end

function GetVersion() --Define anchor addresses
if GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
	if ReadString(0x9A9330,4) == 'KH2J' then --EGS
		GameVersion = 2
		ConsolePrint('KH2APConnector Epic Version')
		Now = 0x0716DF8
		Sve = 0x2A0BFC0
		Save = 0x09A9330
		Obj0Pointer = 0x2A24AB0
		Sys3Pointer = 0x2AE58D0
		Btl0Pointer = 0x2AE58D8
		ARDPointer = 0x2A0F2A8
		Music = 0x0ABA7C4
		Pause = 0x0ABB2F8
		React = 0x2A10BE2
		Cntrl = 0x2A16C68
		Timer = 0x0ABB2D0
		Songs = 0x0B657F4
		GScre = 0x072AEB0
		GMdal = 0x072B044
		GKill = 0x0AF6BC6
		CamTyp = 0x0718A98
		GamSpd = 0x0717214
		CutNow = 0x0B64A18
		CutLen = 0x0B64A34
		CutSkp = 0x0B64A1C
		BtlTyp = 0x2A10E84
		BtlEnd = 0x2A0F760
		TxtBox = 0x074DCB0
		DemCln = 0x2A0F334
		Slot1    = 0x2A23018
		NextSlot = 0x278
		Point1   = 0x2A0F4C8
		NxtPoint = 0x50
		Gauge1   = 0x2A0F5B8
		NxtGauge = 0x48
		Menu1    = 0x2A10B90
		NextMenu = 0x8
		Obj0 = ReadLong(Obj0Pointer)
		Sys3 = ReadLong(Sys3Pointer)
		Btl0 = ReadLong(Btl0Pointer)
		MSN = 0x0BF2C80
		IsDeadAddress = 0x0BEEF28
        Journal = 0x743260
        Shop = 0x743350
        InfoBarPointer = 0xABE2A8
        FadeStatus = 0xABAF38
        PlayerGaugePointer = 0x0ABCCC8
		MenuType = 0x09001C4
		HasDied = false
		PauseFlag = 0x0717208
		Framerate = 0x08CBD0A
	elseif ReadString(0x9A98B0,4) == 'KH2J' then --Steam Global
		GameVersion = 3
		ConsolePrint('KH2APConnector Steam Global Version')
		Now = 0x0717008
		Sve = 0x2A0C540
		Save = 0x09A98B0
		Obj0Pointer = 0x2A25030
		Sys3Pointer = 0x2AE5E50
		Btl0Pointer = 0x2AE5E58
		ARDPointer = 0x2A0F828
		Music = 0x0ABAD44
		Pause = 0x0ABB878
		React = 0x2A11162
		Cntrl = 0x2A171E8
		Timer = 0x0ABB850
		Songs = 0x0B65D44
		GScre = 0x072B130
		GMdal = 0x072B2C4
		GKill = 0x0AF7146
		CamTyp = 0x0718CA8
		GamSpd = 0x0717424
		CutNow = 0x0B64F98
		CutLen = 0x0B64FB4
		CutSkp = 0x0B64F9C
		BtlTyp = 0x2A11404
		BtlEnd = 0x2A0FCE0
		TxtBox = 0x074DF20
		DemCln = 0x2A0F8B4
		Slot1    = 0x2A23598
		NextSlot = 0x278
		Point1   = 0x2A0FA48
		NxtPoint = 0x50
		Gauge1   = 0x2A0FB38
		NxtGauge = 0x48
		Menu1    = 0x2A11110
		NextMenu = 0x8
		Obj0 = ReadLong(Obj0Pointer)
		Sys3 = ReadLong(Sys3Pointer)
		Btl0 = ReadLong(Btl0Pointer)
		MSN = 0x0BF33C0
		IsDeadAddress = 0x0BEF4A8
        Journal = 0x7434E0
        Shop =  0x7435D0
        InfoBarPointer = 0xABE828
        FadeStatus = 0xABB4B8
        PlayerGaugePointer = 0x0ABD248
		MenuType = 0x0900724
		HasDied = false
		PauseFlag = 0x0717418
		Framerate = 0x071536E
	elseif ReadString(0x9A7070,4) == "KH2J" or ReadString(0x9A70B0,4) == "KH2J" or ReadString(0x9A92F0,4) == "KH2J" then
		GameVersion = -1
		ConsolePrint("Epic Version is outdated. Please update the game.")
	elseif ReadString(0x9A9830,4) == "KH2J" then
		GameVersion = -1
		ConsolePrint("Steam Global Version is outdated. Please update the game.")
	elseif ReadString(0x9A8830,4) == "KH2J" then
		GameVersion = -1
		ConsolePrint("Steam JP Version is outdated. Please update the game.")
	end
end
if GameVersion ~= 0 then
	Menu2  = Menu1 + NextMenu
	RoomSaveTask:Init() --Initialize room saves
end
end