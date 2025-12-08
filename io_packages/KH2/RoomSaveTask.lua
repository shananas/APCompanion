--Refunds certain items if the player dies while in a room

local RoomSaveTask = {}

RoomSaveTask.State = {
	Room = 0x00,
	Evt = 0x00,
	ItemIds = {}
}

RoomSaveTask.ValidTypes = {"Command", "Recipe", "Consumable", "Support", "Spirit", "World"}
RoomSaveTask.PrepareLoad = false

function RoomSaveTask:Init()
	self.State.Room = ReadByte(Room)
	self.State.Evt = ReadByte(Evt)
end

function RoomSaveTask:GetRoomChange() --Determine if the room has changed
	local _currRoom = ReadByte(Room)
	local _currEvt = ReadByte(Evt)
	if self.State.Room ~= _currRoom or self.State.Evt ~= _currEvt then
		ConsolePrint("Room changed")
		self:OnRoomChange()
		self.State.Room = _currRoom
		self.State.Evt = _currEvt
	end
end

function RoomSaveTask:OnRoomChange()
	if self.PrepareLoad then --Redeem items before clearing the list to be safe
		self:RestoreItems()
		self.PrepareLoad = false
	end
	self.State.ItemIds = {} --Vanilla room save occurred; clear list
end

function RoomSaveTask:StoreItem(id) --Store items to prepare for potential room save
		table.insert(self.State.ItemIds, id)
end

function RoomSaveTask:CheckPlayerState() --See if player has died
	local _ptr = GetPointer(MemoryAddresses.deathPtr, MemoryAddresses.deathOffset)
	if not self.PrepareLoad then
		if ReadByte(_ptr, true) == 3 then --Player died
			ConsolePrint("Player died; preparing load from room save")
			self.PrepareLoad = true
		end
	else
		if ReadByte(_ptr, true) == 0x01 or ReadByte(_ptr, true) == 0x02 then --Player respawned
			self:RestoreItems()
			self.PrepareLoad = false
		end
	end
end

function RoomSaveTask:RestoreItems() --Put items likely lost to death back into inventory
	for i=1, #self.State.ItemIds do
		sendToInv(self.State.ItemIds[i])
	end
end

return RoomSaveTask