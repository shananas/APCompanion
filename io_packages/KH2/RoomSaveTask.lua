--Refunds certain items if the player dies while in a room

local RoomSaveTask = {}
local HasDied = false
local ItemsRestored = false
local LocationsRestored = false
RoomSaveTask.State = {
	SveRoom = 0x00,
	CurrentRoom = 0x00,
	ItemIds = {},
	LocationIds = {},
}

function RoomSaveTask:Init()
	self.State.SveRoom = ReadByte(Sve + 0x01)
	self.State.CurrentRoom = Room
end

function RoomSaveTask:GetRoomChange() --Determine if the room has changed
	local currRoom = Room
	local currSve = ReadByte(Sve + 0x01)
	if ReadLong(IsDeadAddress) ~= 0 then
		HasDied = true
	end

	if self.State.SveRoom ~= currSve then
		if #self.State.ItemIds > 0 then
			ConsolePrint("Room changed items have been saved!?!")
			self.State.CurrentRoom = currRoom
			self.State.SveRoom = currSve
			self:OnRoomChange()
		else
			self.State.SveRoom = currSve
		end
	elseif HasDied and ReadByte(Pause) == 0 then
		if #self.State.LocationIds > 0 and not LocationsRestored then
			ConsolePrint("Opening chests closed on death...")
			self:RestoreLocations()
			LocationsRestored = true
		end
		if #self.State.ItemIds > 0 and not ItemsRestored and ReadLong(ReadLong(PlayerGaugePointer)+0x88, true) ~= 0 then
			ConsolePrint("Restoring items lost on death...")
			self:RestoreItems()
			ItemsRestored = true
		end
		if (#self.State.ItemIds == 0 or ItemsRestored) and (#self.State.LocationIds == 0 or LocationsRestored) then
				self.State.CurrentRoom = currRoom
				HasDied = false
				ItemsRestored = false
				LocationsRestored = false
		end
	elseif self.State.CurrentRoom ~= currRoom and ReadLong(ReadLong(PlayerGaugePointer)+0x88, true) ~= 0 then
		self.State.CurrentRoom = currRoom
		HasDied = false
	end
end

function RoomSaveTask:OnRoomChange()
	self.State.ItemIds = {} --Vanilla room save occurred; clear list
	self.State.LocationIds = {}
end

function RoomSaveTask:StoreItem(id) --Store items to prepare for potential room save
	table.insert(self.State.ItemIds, id)
end

function RoomSaveTask:StoreLocation(id) --Store open chests to reopen for potential room save
	table.insert(self.State.LocationIds, id)
	ConsolePrint("Saving chest: " .. id.Name)
end

function RoomSaveTask:RestoreItems() --Put items likely lost to death back into inventory
	for i = 1, #self.State.ItemIds do
		SendToInv(self.State.ItemIds[i])
	end
end

function RoomSaveTask:RestoreLocations()
	for i = 1, #self.State.LocationIds do
		WriteByte(Save + self.State.LocationIds[i].Address, ReadByte(Save + self.State.LocationIds[i].Address) | 0x01 << self.State.LocationIds[i].BitIndex)
	end
end


return RoomSaveTask