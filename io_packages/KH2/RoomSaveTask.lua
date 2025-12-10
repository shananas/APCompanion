--Refunds certain items if the player dies while in a room

local RoomSaveTask = {}
local HasDied = false
RoomSaveTask.State = {
	SveRoom = 0x00,
	CurrentRoom = 0x00,
	ItemIds = {}
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
			ConsolePrint("Room changed")
			self.State.CurrentRoom = currRoom
			self.State.SveRoom = currSve
			self:OnRoomChange()
		else
			self.State.SveRoom = currSve
		end
	elseif HasDied and ReadByte(Pause) == 0 and ReadLong(ReadLong(PlayerGaugePointer)+0x88, true) ~= 0 and #self.State.ItemIds > 0 then
		ConsolePrint("Restoring items lost on death...")
		self:RestoreItems()
		self.State.CurrentRoom = currRoom
		HasDied = false
	elseif self.State.CurrentRoom ~= currRoom then
		self.State.CurrentRoom = currRoom
		HasDied = false
	end
end

function RoomSaveTask:OnRoomChange()
	self.State.ItemIds = {} --Vanilla room save occurred; clear list
end

function RoomSaveTask:StoreItem(id) --Store items to prepare for potential room save
		table.insert(self.State.ItemIds, id)
end

function RoomSaveTask:RestoreItems() --Put items likely lost to death back into inventory
	for i=1, #self.State.ItemIds do
		sendToInv(self.State.ItemIds[i])
	end
end

return RoomSaveTask