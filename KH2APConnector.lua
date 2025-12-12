---------------------------------------------------
------ Kingdom Hearts Dream Drop Distance AP ------
------                by Lux                 ------
---------------------------------------------------
------ Special Thanks to Sonicshadowsilver2, Meebo, & Krujo
---------------------------------------------------

local socket = require("socket")
ItemHandler = require("KH2.ItemHandler")
local ItemDefs = require("KH2.ItemDefs")
local LocationDefs = require("KH2.LocationDefs")
local LocationHandler = require("KH2.LocationHandler")
local RoomSaveTask = require("KH2.RoomSaveTask")

LUAGUI_NAME = "KH2 AP Connector [Socket]"
LUAGUI_AUTH = "Shananas"
LUAGUI_DESC = "Kingdom Hearts 2 AP Integration using Lua Socket"

local canExecute = false
local gameStarted = false
local connectionInitialized = false

frameCount = 0
NotificationFrameCount = 0
VictoryWaitTime = 0
ChestFrameCount = 0
connected = false
ChestWait = false

local client

kh2scii_dict = {
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
	 ['.'] = 0x4F, [',']  = 0x50, [';'] = 0x51, [' ='] = 0x52, ['\''] = 0x57, ['('] = 0x5A, [')'] = 0x5B,
	 ['['] = 0x62, [']']  = 0x63, ['à'] = 0xB7, ['á']  = 0xB8, ['â']  = 0xB9, ['ä'] = 0xBA, ['è'] = 0xBB,
	 ['é'] = 0xBC, ['ê']  = 0xBD, ['ë'] = 0xBE, ['ì']  = 0xBF, ['í']  = 0xC0, ['î'] = 0xC1, ['ï'] = 0xC2,
	 ['ñ'] = 0xC3, ['ò']  = 0xC4, ['ó'] = 0xC5, ['ô']  = 0xC6, ['ö']  = 0xC7, ['ù'] = 0xC8, ['ú'] = 0xC9,
	 ['û'] = 0xCA, ['ü']  = 0xCB, ['ç'] = 0xE8, ['À']  = 0xD0, ['Á']  = 0xD1, ['Â'] = 0xD2, ['Ä'] = 0xD3,
	 ['È'] = 0xD4, ['É']  = 0xD5, ['Ê'] = 0xD6, ['Ë']  = 0xD7, ['Ì']  = 0xD8, ['Í'] = 0xD9, ['Î'] = 0xDA,
	 ['Ï'] = 0xDB, ['Ñ']  = 0xDC, ['Ò'] = 0xDD, ['Ó']  = 0xDE, ['Ô']  = 0xDF, ['Ö'] = 0xE0, ['Ù'] = 0xE1,
	 ['Ú'] = 0xE2, ['Û']  = 0xE3, ['Ü'] = 0xE4, ['¡']  = 0xE5, ['¿']  = 0xE6, ['Ç'] = 0xE7,
}

MessageTypes = {
	Invalid = -1,
	Test = 0,
	WorldLocationChecked = 1,
	LevelChecked = 2,
	KeybladeChecked = 3,
	SlotData = 4,
	BountyList = 5,
	Deathlink = 6,
	NotificationType = 7,
	NotificationSendMessage = 8,
	NotificationReceiveMessage = 9,
	ReceiveItem = 10,
	RequestAllItems = 11,
	Handshake  = 12,
	Victory = 19,
	Closed = 20
}
HandshakeSent = false
HandshakeReceived = false

--Items
items = {}
abilities = {}
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
	["High Jump"] = {current = 0x05D, max = 0x061},
	["Quick Run"] = {current = 0x061, max = 0x065},
	["Dodge Roll"] = {current = 0x233, max = 0x237},
	["Aerial Dodge"] = {current = 0x065, max = 0x069},
	["Glide"] = {current = 0x069, max = 0x06D},
}
DonaldAbilitiesReceived = {}
GoofyAbilitiesReceived = {}
WeaponAbilities = {}
FormWeaponAbilities = {}

LocationsChecked = {}

MaxSoraLevel = { value = 1 }
MaxValorLevel = { value = 1 }
MaxWisdomLevel = { value = 1 }
MaxLimitLevel = { value = 1 }
MaxMasterLevel = { value = 1 }
MaxFinalLevel = { value = 1 }
MaxSummonLevel = { value = 1 }

FinalXemnasRequired = true
FinalXemnasBeaten = false
Goal = -1
LuckyEmblemsRequired = 100
BountyRequired = 100
BountiesFinished = 0
BountyBosses = {}
FormSummonLevels = {
	0x32F6,
	0x332E,
	0x3366,
	0x339E,
	0x33D6,
	0x3526,
}
DeathlinkEnabled = false
RecievedDeath = false
VictorySent = false
VictoryReceived = false
LastReceivedIndex = -1
LastWorld = -1
CurrentWorld = -1
SendNotificationType = "none"
ReceiveNotificationType = "none"
NotificationSendMessage = {}
NotificationReceiveMessage = {}


-- ############################################################
-- ######################  Socket  ############################
-- #############  Special Thanks to Krujo  ####################
-- ############################################################

function ConnectToApClient()
    local ok, err = client:connect("127.0.0.1", 13713)

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

function SocketHasMessages()
	if client then
		local ready = socket.select({client}, nil, 0)
		if #ready > 0 then
			return true
		end
	end
	return false
end

function HandleMessage(msg)
	if msg.type == nil then
		ConsolePrint("No message type defined; cannot handle")
		return
	end

	if msg.type == MessageTypes.Test then
		ConsolePrint("test recieved")
		local _item
		ConsolePrint(tostring(msg.values[2]))
		if msg.values[2] ~= nil then
			_item = getAbilityById(tonumber(msg.values[1]), msg.values[2])
		else
			_item = getItemById(tonumber(msg.values[1]))
		end
		if _item ~= nil then
			ItemHandler:Receive(_item)
		end
	end

	if msg.type == MessageTypes.ReceiveItem then
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
			RecievedDeath = true
		end

	elseif msg.type == MessageTypes.SlotData then
		if tostring(msg.values[1]) == "Final Xemnas" then
			FinalXemnasRequired = (tonumber(msg.values[2]) == 1)
		elseif tostring(msg.values[1]) == "Goal" then
			Goal = tonumber(msg.values[2])
		elseif tostring(msg.values[1]) == "LuckyEmblemsRequired" then
			LuckyEmblemsRequired = tonumber(msg.values[2])
		elseif tostring(msg.values[1]) == "BountyRequired" then
			BountyRequired = tonumber(msg.values[2])
		end

	elseif msg.type == MessageTypes.BountyList then
		local finalmsg = msg.values[1]:sub(2,-2)
		local parsed = {}
		for num in finalmsg:gmatch("%d+") do
			table.insert(parsed, tonumber(num))
		end
		table.insert(BountyBosses, parsed)

	elseif msg.type == MessageTypes.Handshake then
		HandshakeReceived = true
		SendToApClient(MessageTypes.SlotData, {World})
		if msg.values[1] == "True" then
			ConsolePrint("Received handshake; Requesting items")
			SendToApClient(MessageTypes.RequestAllItems, {"Requesting Items"})
		end

	elseif msg.type == MessageTypes.NotificationType then
		if msg.values[1] == "receive" then
			ReceiveNotificationType = msg.values[2]
			ConsolePrint(ReceiveNotificationType)
		elseif msg.values[1] == "send" then
			SendNotificationType = msg.values[2]
			ConsolePrint(SendNotificationType)
		else
			ConsolePrint(msg[1].values)
		end

	elseif msg.type == MessageTypes.NotificationSendMessage then
		table.insert(NotificationSendMessage, msg.values[1])

	elseif msg.type == MessageTypes.NotificationReceiveMessage then
		table.insert(NotificationReceiveMessage, msg.values[1])

	elseif msg.type == MessageTypes.Victory then
		VictoryReceived = true

	end
end

local receiveBuffer = ""

function ReceiveFromApClient()
	if SocketHasMessages() then
		local message, err, partial = client:receive('*l')
		if message then
			if receiveBuffer ~= "" then
				message = receiveBuffer .. message
				receiveBuffer = ""
			end
			ConsolePrint("Full message received: "..message)
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
				return
			end
			return newMessage
		elseif partial and #partial > 0 then
			receiveBuffer = receiveBuffer .. partial
			ConsolePrint("Partial message received")
		elseif err and err ~= "timeout" then
			ConsolePrint("Error receiving message: " .. err)
			if err == "timeout" then
				ConsolPrint("Lost connection to client please relaunch KH2Client")
				CloseConnection()
			end
		end
	else
		return nil
	end
end

function CloseConnection()
	connectionInitialized = false
	gameStarted = false
	HandshakeSent = false
	HandshakeReceived = false
	client:close()
	client = socket.tcp()
	client:settimeout(0)
end

function ProcessItemQueue()
	local Sent = 0
	while Sent < 100 and #ItemQueue > 0 do
		local item = ItemQueue[1]
		if ReadByte(Pause) == 0  and ReadByte(FadeStatus) == 0 and
		ReadLong(PlayerGaugePointer) ~= 0 and ReadLong(ReadLong(PlayerGaugePointer)+0x88, true) ~= 0 then
			if item.Type ~= "Ability" then
				ConsolePrint(tostring(item.Name))
				if item.Name ~= "Torn Page" then
					if ItemsReceived[item.Name] then
						if ItemsReceived[item.Name] < 255 then
							ItemsReceived[item.Name] = ItemsReceived[item.Name] + 1
						end
					else
						ItemsReceived[item.Name] = 1
					end
				else
					TornPagesReceived = TornPagesReceived + 1
					local TornPagesRedeemed = 0
					for i = 1, #PoohProgress do
						if ReadByte(Save + PoohProgress[i].Address) & 0x1 << PoohProgress[i].BitIndex > 0 then
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
	for i = 1, #items do
		if items[i].ID == item_id then
			return items[i]
		end
	end
end

function getAbilityById(ab_id, member)
	for i = 1, #abilities do
		if abilities[i].ID == ab_id  and abilities[i].Ability == member then
			return abilities[i]
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
		local charCode = nil
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
			if kh2scii_dict[c] then
				charCode = kh2scii_dict[c]
			else
				charCode = 0x01
			end
			i = i + 1
		end
		if charCode ~= nil then
			table.insert(returnArr, charCode)
		else
			i = i + 1
		end
	end
	table.insert(returnArr, 0x00)

	return returnArr
end

function GoalGame()
    if FinalXemnasRequired then
        if not FinalXemnasBeaten and ReadByte(Save + Worlds.TWTNW_Checks[37].Address) & 0x1 << Worlds.TWTNW_Checks[37].BitIndex > 0 then
            FinalXemnasBeaten = true
		end
	end
    -- three proofs
    if Goal == 0 then
        if ReadByte(Save + 0x36B2) > 0 and ReadByte(Save + 0x36B3) > 0 and ReadByte(Save + 0x36B4) > 0 then
            if FinalXemnasRequired then
                if FinalXemnasBeaten then
					SendToApClient(MessageTypes.Victory, {"Victory"})
					VictorySent = true
				end
			else
				SendToApClient(MessageTypes.Victory, {"Victory"})
				VictorySent = true
			end
		end
    elseif Goal == 1 then
        if ReadByte(Save + 0x3641) >= LuckyEmblemsRequired then
            if ReadByte(Save + 0x36B3) < 1 then
                WriteByte(Save + 0x36B2, 1)
                WriteByte(Save + 0x36B3, 1)
                WriteByte(Save + 0x36B4, 1)
			end
            if FinalXemnasRequired then
                if FinalXemnasBeaten then
					SendToApClient(MessageTypes.Victory, {"Victory"})
					VictorySent = true
				end
			else
				SendToApClient(MessageTypes.Victory, {"Victory"})
				VictorySent = true
			end
		end
    elseif Goal == 2 then
		CheckBountiesObtained()
        if BountiesFinished >= BountyRequired then
            if ReadByte(Save + 0x36B3) < 1 then
                WriteByte(Save + 0x36B2, 1)
                WriteByte(Save + 0x36B3, 1)
                WriteByte(Save + 0x36B4, 1)
			end
            if FinalXemnasRequired then
                if FinalXemnasBeaten then
					SendToApClient(MessageTypes.Victory, {"Victory"})
					VictorySent = true
                end
			else
				SendToApClient(MessageTypes.Victory, {"Victory"})
				VictorySent = true
			end
		end
    elseif Goal == 3 then
		CheckBountiesObtained()
        if BountiesFinished >= BountyRequired and ReadByte(Save + 0x3641) >= LuckyEmblemsRequired then
            if ReadByte(Save + 0x36B3) < 1 then
                WriteByte(Save + 0x36B2, 1)
                WriteByte(Save + 0x36B3, 1)
                WriteByte(Save + 0x36B4, 1)
			end
            if FinalXemnasRequired then
                if FinalXemnasBeaten then
					SendToApClient(MessageTypes.Victory, {"Victory"})
					VictorySent = true
                end
			else
				SendToApClient(MessageTypes.Victory, {"Victory"})
				VictorySent = true
			end
        end
	end
end

function CheckBountiesObtained()
	BountiesFinished = 0
	for i = 1, #BountyBosses do
		for j = 1, #FormSummonLevels do
			if BountyBosses[i][1] == FormSummonLevels[j] then
				if ReadByte(Save + BountyBosses[i][1]) >= 7 then
					BountiesFinished = BountiesFinished + 1
					break
				end
			end
		end
		if ReadByte(Save + BountyBosses[i][1]) & 0x1 << BountyBosses[i][2] > 0 then
			BountiesFinished = BountiesFinished + 1
		end
	end
end

function CurrentWorldLocation()
    CurrentWorld = World
	if LastWorld ~= CurrentWorld then
		LastWorld = CurrentWorld
		SendToApClient(MessageTypes.SlotData, {CurrentWorld})
	end
end

function Deathlink()
	local KillSora = false
	local IsDead = ReadLong(IsDeadAddress)
	--if deathlink from another player
	if RecievedDeath then
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
		if(not RecievedDeath) then
			SendToApClient(MessageTypes.Deathlink,{Room, Evt, World})
		end
		RecievedDeath = false
	end
end

----This function is needed for room save to work
function sendToInv(item)
    ItemHandler:Receive(item)
end

function ProcessAbility(item)
	if SoraGrowthReceived[item.Name] then
		if SoraGrowthReceived[item.Name].current < SoraGrowthReceived[item.Name].max then
			SoraGrowthReceived[item.Name].current = SoraGrowthReceived[item.Name].current + 1
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
	if NotificationFrameCount == 0 then
		if #NotificationSendMessage > 0 then
			if SendNotificationType == "puzzle" then
				if ReadByte(0x800000) == 0 then
					msg = textToKHSCII(NotificationSendMessage[1])
					WriteArray(0x800104, msg)
					ConsolePrint(tostring(NotificationSendMessage[1]))
					WriteByte(0x800000, 2)
					table.remove(NotificationSendMessage,1)
				end
			elseif SendNotificationType == "info" then
				InfoBarPointerRef = ReadLong(InfoBarPointer)
				if ReadByte(0x800000) == 0 and InfoBarPointerRef ~= 0 and ReadInt(InfoBarPointerRef + 0x48) == 0 then
					WriteByte(0x800000, 1)
					msg = textToKHSCII(NotificationSendMessage[1])
					WriteArray(0x800004, msg)
					table.remove(NotificationSendMessage,1)
				end
			elseif SendNotificationType == "chest" then
				if not ChestWait then
					if ReadByte(0x800000) == 0 then
						msg = textToKHSCII(NotificationSendMessage[1])
						WriteByte(0x800150, 0)
						WriteArray(0x800154, msg)
						ChestWait = true
					end
				elseif ChestFrameCount == 0 then
					WriteByte(0x800000, 3)
					table.remove(NotificationSendMessage,1)
					ChestWait = false
				end
			end
		elseif #NotificationReceiveMessage > 0 then
			if ReceiveNotificationType == "puzzle" then
				if ReadByte(0x800000) == 0 then
					msg = textToKHSCII(NotificationReceiveMessage[1])
					WriteArray(0x800104, msg)
					ConsolePrint(tostring(NotificationReceiveMessage[1]))
					WriteByte(0x800000, 2)
					table.remove(NotificationReceiveMessage,1)
				end
			elseif ReceiveNotificationType == "info" then
				InfoBarPointerRef = ReadLong(InfoBarPointer)
				if ReadByte(0x800000) == 0 and InfoBarPointerRef ~= 0 and ReadInt(InfoBarPointerRef + 0x48) == 0 then
					WriteByte(0x800000, 1)
					msg = textToKHSCII(NotificationReceiveMessage[1])
					WriteArray(0x800004, msg)
					table.remove(NotificationReceiveMessage,1)
				end
			elseif ReceiveNotificationType == "chest" then
				if not ChestWait then
					if ReadByte(0x800000) == 0 then
						msg = textToKHSCII(NotificationReceiveMessage[1])
						WriteByte(0x800150, 0)
						WriteArray(0x800154, msg)
						ChestWait = true
					end
				elseif ChestFrameCount == 0 then
					WriteByte(0x800000, 3)
					table.remove(NotificationReceiveMessage,1)
					ChestWait = false
				end
			end

		end
	end
end

-- ############################################################
-- ######################  Game Setup  ########################
-- ############################################################

function APCommunication()
	CurrentWorldLocation()
	LocationHandler:CheckLevelLocations()
	LocationHandler:CheckWeaponAbilities()
	LocationHandler:CheckWorldLocations()
	if not VictorySent then
		GoalGame()
	elseif not VictoryReceived and VictoryWaitTime == 0 then
		SendToApClient(MessageTypes.Victory, {"Victory"})
	end

	while true do
        local msg = ReceiveFromApClient()
        if not msg then break end
        HandleMessage(msg)
    end
end

function _OnInit()
	--Initialize items and locations
	LocationDefs:DefineWorldEvents()
	LocationDefs:FormLevels()
	LocationDefs:WeaponSlots()
	LocationDefs:TornPageLocks()
	ItemDefs:DefineItems()
	ItemDefs:DefineAbilities()
	GameVersion = 0
	print('Lua Socket test')
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
	frameCount = (frameCount + 1) % 15
	NotificationFrameCount = (NotificationFrameCount + 1) % 30 --IF I CHANGE THIS CHECK CHEST NOTIFICATION WAIT TIME CASUE IT'LL NEED TO BE UPDATED
	if VictorySent then
		VictoryWaitTime = (VictoryWaitTime + 1) % 300
	end
	if ChestWait then
		ChestFrameCount = (ChestFrameCount + 1) % 30
	end
	if not gameStarted and frameCount == 0 then
		local connected =  ConnectToApClient()

		if connected then
			connectionInitialized = true
			gameStarted = true
		end
		return
	end
	PCInteracted = ReadByte(Save + 0x1D27) & 0x1 << 3 > 0
	if gameStarted and PCInteracted then
		if not HandshakeSent then
			SendToApClient(MessageTypes.Handshake, {"Requesting Handshake"})
			HandshakeSent = true
			return
		end
		if not HandshakeReceived then
			APCommunication()
		else
			ProcessNotification()
			RoomSaveTask:GetRoomChange()
			ItemHandler:RemoveAbilities()
			if DeathlinkEnabled then
				Deathlink()
			end
			if frameCount == 0 then --Dont run main logic every frame
				APCommunication()
				ProcessItemQueue()
			end
		end
	end
end

function GetVersion() --Define anchor addresses
if GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
	if ReadString(0x9A9330,4) == 'KH2J' then --EGS
		GameVersion = 2
		print('GoA Epic Version')
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
		HasDied = false
	elseif ReadString(0x9A98B0,4) == 'KH2J' then --Steam Global
		GameVersion = 3
		print('GoA Steam Global Version')
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
		HasDied = false
	elseif ReadString(0x9A98B0,4) == 'KH2J' then --Steam JP (same as Global for now)
		GameVersion = 4
		print('GoA Steam JP Version')
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
		Songs = 0x0B65D74
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
		HasDied = false
	elseif ReadString(0x9A7070,4) == "KH2J" or ReadString(0x9A70B0,4) == "KH2J" or ReadString(0x9A92F0,4) == "KH2J" then
		GameVersion = -1
		print("Epic Version is outdated. Please update the game.")
	elseif ReadString(0x9A9830,4) == "KH2J" then
		GameVersion = -1
		print("Steam Global Version is outdated. Please update the game.")
	elseif ReadString(0x9A8830,4) == "KH2J" then
		GameVersion = -1
		print("Steam JP Version is outdated. Please update the game.")
	end
end
if GameVersion ~= 0 then
	--[[Slot2  = Slot1 - NextSlot
	Slot3  = Slot2 - NextSlot
	Slot4  = Slot3 - NextSlot
	Slot5  = Slot4 - NextSlot
	Slot6  = Slot5 - NextSlot
	Slot7  = Slot6 - NextSlot
	Slot8  = Slot7 - NextSlot
	Slot9  = Slot8 - NextSlot
	Slot10 = Slot9 - NextSlot
	Slot11 = Slot10 - NextSlot
	Slot12 = Slot11 - NextSlot
	Point2 = Point1 + NxtPoint
	Point3 = Point2 + NxtPoint
	Gauge2 = Gauge1 + NxtGauge
	Gauge3 = Gauge2 + NxtGauge--]]
	Menu2  = Menu1 + NextMenu
	--Menu3  = Menu2 + NextMenu
	RoomSaveTask:Init() --Initialize room saves
end
end