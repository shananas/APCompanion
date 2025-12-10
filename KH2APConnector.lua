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
--[[local PromptTask = require("KHDDD.Tasks.PromptTask")
local CheatTask = require("KHDDD.Tasks.CheatTask")
local ConfigTask = require("KHDDD.Tasks.ConfigTask")
local SoftlockTask = require("KHDDD.Tasks.SoftlockTask")--]]

LUAGUI_NAME = "KH2 AP Connector [Socket]"
LUAGUI_AUTH = "Shananas"
LUAGUI_DESC = "Kingdom Hearts 2 AP Integration using Lua Socket"


--Define Globals
local gameID = GAME_ID
local engineType = ENGINE_TYPE

local canExecute = false
local gameStarted = false
local connectionInitialized = false

frameCount = 0
connected = false

local client

KHSCII = {
  A = 0x41,B = 0x42,C = 0x43,D = 0x44,E = 0x45,F = 0x46,
  G = 0x47,H = 0x48,I = 0x49,J = 0x4A,K = 0x4B,
  L = 0x4C,M = 0x4D,N = 0x4E,O = 0x4F,P = 0x50,
  Q = 0x51,R = 0x52,S = 0x53,T = 0x54,U = 0x55,
  V = 0x56,W = 0x57,X = 0x58,Y = 0x59,Z = 0x5A,
  a = 0x61,b = 0x62,c = 0x63,d = 0x64,e = 0x65,f = 0x66,
  g = 0x67,h = 0x68,i = 0x69,j = 0x6A,k = 0x6B,
  l = 0x6C,m = 0x6D,n = 0x6E,o = 0x6F,p = 0x70,
  q = 0x71,r = 0x72,s = 0x73,t = 0x74,u = 0x75,
  v = 0x76,w = 0x77,x = 0x78,y = 0x79,z = 0x7A,
  Period = 0x2E,Space = 0x20,Exclamation = 0x21, And = 0x26
}

item_usefulness = {
	trap = 0,
	useless = 1,
	normal = 2,
	progression = 3,
	special = 4
}

MessageTypes = {
	Invalid = -1,
	Test = 0,
	WorldLocationChecked = 1,
	LevelChecked = 2,
	KeybladeChecked = 3,
	ClientCommand = 4,
	Deathlink = 5,
    SlotData = 6,
    BountyList = 7,
    ReceiveAllItems = 8,
    RequestAllItems = 9,
    ReceiveSingleItem = 10,
    Victory = 11,
	Handshake  = 12,
	Closed = 20
}

--Items
items = {}
abilities = {}

--Locations
Worlds = {}
ValorForm = {}
WisdomForm = {}
LimitForm = {}
MasterForm = {}
FinalForm = {}
SummonLevels = {}
WeaponAbilities = {}
FormWeaponAbilities = {}
--worldTables = {
--   [2]  = Worlds.TT_Checks,
--   [4]  = Worlds.HB_Checks,
--   [5]  = Worlds.BC_Checks,
--   [6]  = Worlds.OC_Checks,
--   [7]  = Worlds.AG_Checks,
--   [8]  = Worlds.LoD_Checks,
--   [9]  = Worlds.Pooh_Checks,
--   [10] = Worlds.PL_Checks,
--   [11] = Worlds.AT_Checks,
--   [12] = Worlds.DC_Checks,
--   [13] = Worlds.TR_Checks,
--   [14] = Worlds.HT_Checks,
--   [16] = Worlds.PR_Checks,
--   [17] = Worlds.SP_Checks,
--   [18] = Worlds.TWTNW_Checks
--}
LastWorld = -1
CurrentWorld = -1

LocationsChecked = {}

MaxSoraLevel = { value = 1}
MaxValorLevel = { value = 1}
MaxWisdomLevel = { value = 1}
MaxLimitLevel = { value = 1}
MaxMasterLevel = { value = 1}
MaxFinalLevel = { value = 1}
MaxSummonLevel = { value = 1}
FinalXemnasRequired = true
FinalXemnasBeaten = false
Goal = -1
LuckyEmblemsRequired = 100
BountyRequired = 100
BountiesFinished = 0
finished = false
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
		local _item = getItemById(tonumber(msg.values[1]))
		--ConsolePrint(_item.ID)
		--ConsolePrint(_item.Name)
		--ConsolePrint(_item.Address)
		ItemHandler:Receive(_item)
	end

	if msg.type == MessageTypes.ReceiveAllItems then
		ConsolePrint("Receiving all items")
		ItemHandler:Reset()
		for i = 1, #msg.values do
			local _msg = msg.values[i]
			ConsolePrint("Msg Value: ".._msg)
			local _item = getItemById(tonumber(_msg))
			if _item == nil then
				ConsolePrint("Invalid item received. Val: ".._msg)
				return
			end
		ItemHandler:Receive(_item)
		RoomSaveTask:StoreItem(_item)
		end
	elseif msg.type == MessageTypes.ReceiveSingleItem then
		ConsolePrint("Receiving single item")
		local _item = getItemById(tonumber(msg.values[1]))
		ItemHandler:Receive(_item)
		RoomSaveTask:StoreItem(_item)

	elseif msg.type == MessageTypes.ClientCommand then
		local _cmdId = tonumber(msg.values[1])

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
		if msg.values[1] == "True" then
			ConsolePrint("Received handshake; Requesting items")
			SendToApClient(MessageTypes.RequestAllItems, {"Requesting Items"})
		end
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
				connectionInitialized = false
				gameStarted = false
				client:close()
				client = socket.tcp()
				client:settimeout(0)
				return
			end
			return newMessage
		elseif partial and #partial > 0 then
			receiveBuffer = receiveBuffer .. partial
			ConsolePrint("partial")
		elseif err  and err ~= "timeout" then
			ConsolePrint("Error receiving message: " .. err)
			if err == "closed" then
				connectionInitialized = false
				gameStarted = false
			end
		end
	else
		return nil
	end
end

-- ############################################################
-- ######################  Helpers  ###########################
-- ############################################################

function toHex(str)
	return string.format("%X", str)
end

function toBits(num)
	-- returns a table of bits, least significant first.
	local t={} -- will contain the bits
	while num>0 do
		rest=math.fmod(num,2)
		t[#t+1]=rest
		num=(num-rest)/2
	end
	return t
end

function hasValue(arr, val)
	for index, value in ipairs(arr) do
		if value == val then
			return true
		end
	end
	return false
end

function countValues(arr, val)
	local _cnt = 0
	for index, value in ipairs(arr) do
		if value == val then
			_cnt = _cnt + 1
		end
	end
	return _cnt
end

function removeDuplicates(arr)
	local _uniqueArr = {}
	local _seen = {}

	for _, value in ipairs(arr) do
		if not _seen[value] then
			table.insert(_uniqueArr, value)
			_seen[value] = true
		end
	end

	return _uniqueArr
end

function getItemById(item_id)
	for i = 1, #items do
		if items[i].ID == item_id then
			return items[i]
		end
	end
	for i = 1, #abilities do
		if abilities[i].ID == item_id then
			return abilities[i]
		end
	end
end
function getAbilityById(ab_id)
	for i = 1, #abilities do
		if abilities[i].ID == ab_id then
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

function GetArraySum(arr)
	local _arrSum = 0
	for i=1, #arr do
		_arrSum = _arrSum + arr[i]
	end
	return _arrSum
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
	returnArr = {}
	for i=1, #value do
		local c = value:sub(i, i)
		local charCode = charToKHSCII(c)
		table.insert(returnArr, charCode)
		table.insert(returnArr, 0x00)
	end
	return returnArr
end

function charToKHSCII(char)
	local returnChars = {
		["A"] = KHSCII.A,["B"] = KHSCII.B,["C"] = KHSCII.C,["D"] = KHSCII.D,
		["E"] = KHSCII.E,["F"] = KHSCII.F,["G"] = KHSCII.G,["H"] = KHSCII.H,
		["I"] = KHSCII.I,["J"] = KHSCII.J,["K"] = KHSCII.K,["L"] = KHSCII.L,
		["M"] = KHSCII.M,["N"] = KHSCII.N,["O"] = KHSCII.O,["P"] = KHSCII.P,
		["Q"] = KHSCII.Q,["R"] = KHSCII.R,["S"] = KHSCII.S,["T"] = KHSCII.T,
		["U"] = KHSCII.U,["V"] = KHSCII.V,["W"] = KHSCII.W,["X"] = KHSCII.X,
		["Y"] = KHSCII.Y,["Z"] = KHSCII.Z,
		["a"] = KHSCII.a,["b"] = KHSCII.b,["c"] = KHSCII.c,["d"] = KHSCII.d,
		["e"] = KHSCII.e,["f"] = KHSCII.f,["g"] = KHSCII.g,["h"] = KHSCII.h,
		["i"] = KHSCII.i,["j"] = KHSCII.j,["k"] = KHSCII.k,["l"] = KHSCII.l,
		["m"] = KHSCII.m,["n"] = KHSCII.n,["o"] = KHSCII.o,["p"] = KHSCII.p,
		["q"] = KHSCII.q,["r"] = KHSCII.r,["s"] = KHSCII.s,["t"] = KHSCII.t,
		["u"] = KHSCII.u,["v"] = KHSCII.v,["w"] = KHSCII.w,["x"] = KHSCII.x,
		["y"] = KHSCII.y,["z"] = KHSCII.z,
		["."] = KHSCII.Period,[" "] = KHSCII.Space,["!"] = KHSCII.Exclamation,["&"] = KHSCII.And
	}
	return returnChars[char]
end

function writeTxtToGame(startAddr, txt, fillerCnt)
	txtBytes = textToKHSCII(txt)
	for i=1, fillerCnt do
		table.insert(txtBytes, 0x00)
		table.insert(txtBytes, 0x00)
	end
	WriteArray(startAddr, txtBytes)
end

function updateReceived(itemCnt)
	if currentReceivedIndex < lastReceivedIndex then --Increment current received until we reach our last received
		currentReceivedIndex = currentReceivedIndex+1
	else --Fill with item index of latest received
		currentReceivedIndex = itemCnt
	end
	WriteInt(MemoryAddresses.medals, currentReceivedIndex)
	ConsolePrint("Current Received Index: "..tostring(currentReceivedIndex))
	ConsolePrint("Last Received Index: "..tostring(lastReceivedIndex))
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
					SendToApClient(MessageTypes.Victory, {"Game Completed"})
					finished = true
				end
			else
				SendToApClient(MessageTypes.Victory, {"Game Completed"})
				finished = true
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
					SendToApClient(MessageTypes.Victory, {"Game Completed"})
					finished = true
				end
			else
				SendToApClient(MessageTypes.Victory, {"Game Completed"})
				finished = true
			end
		end
    elseif Goal == 2 then
		CheckBountiesObtained()
        if BountiesFinished > BountyRequired then
            if ReadByte(Save + 0x36B3) < 1 then
                WriteByte(Save + 0x36B2, 1)
                WriteByte(Save + 0x36B3, 1)
                WriteByte(Save + 0x36B4, 1)
			end
            if FinalXemnasRequired then
                if FinalXemnasBeaten then
					SendToApClient(MessageTypes.Victory, {"Game Completed"})
					finished = true
                end
			else
				SendToApClient(MessageTypes.Victory, {"Game Completed"})
				finished = true
			end
		end
    elseif Goal == 3 then
		CheckBountiesObtained()
        if BountiesFinished > BountyRequired and ReadByte(Save + 0x3641) >= LuckyEmblemsRequired then
            if ReadByte(Save + 0x36B3) < 1 then
                WriteByte(Save + 0x36B2, 1)
                WriteByte(Save + 0x36B3, 1)
                WriteByte(Save + 0x36B4, 1)
			end
            if FinalXemnasRequired then
                if FinalXemnasBeaten then
					SendToApClient(MessageTypes.Victory, {"Game Completed"})
					finished = true
                end
			else
				SendToApClient(MessageTypes.Victory, {"Game Completed"})
				finished = true
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
    CurrentWorld = ReadByte(Now)
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

-- ############################################################
-- ######################  Game Setup  ########################
-- ############################################################

function APCommunication()
	CurrentWorldLocation()
	LocationHandler:CheckLevelLocations()
	LocationHandler:CheckWeaponAbilities()
	LocationHandler:CheckWorldLocations()
	if not finished then
		GoalGame()
	end

	while true do
        local msg = ReceiveFromApClient()
        if not msg then break end
        HandleMessage(msg)
    end
end

function _OnInit()
	ConsolePrint("Game ID: ".. tostring(gameID))
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
	frameCount = (frameCount + 1) % 30
	if not gameStarted and frameCount == 0 then
		local connected =  ConnectToApClient()

		if connected then
			connectionInitialized = true
			gameStarted = true
			SendToApClient(MessageTypes.Handshake, {"Requesting Handshake"})
		end
		return
	end
	RoomSaveTask:GetRoomChange()
	if DeathlinkEnabled then
		Deathlink()
	end
	ItemHandler:RemoveAbilities()
	if frameCount == 0 and ReadByte(Save + 0x1D27) & 0x1 << 3 > 0 then --Dont run main logic every frame
		APCommunication()
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