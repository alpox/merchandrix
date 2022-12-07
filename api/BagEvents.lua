
local ADDON, Addon = ...;

local f = CreateFrame("Frame");

ItemParts = {}

local EventHandler = { }
EventHandler.registered = { }

Addon.EventHandler = EventHandler

function EventHandler:RegisterEvent(class, event)
	if not class then return end
	if not self.registered[event] then self.registered[event] = {} end
	table.insert(self.registered[event], class);
end

function EventHandler:FireEvent(event, slot)
	if not self.registered[event] then return end
	for _, class in ipairs(self.registered[event]) do
		class[event](class, slot);
	end
end

function f:Load()
	self.firstVisit = true
	self:RegisterEvent("MERCHANT_SHOW");
	self:RegisterEvent("BAG_UPDATE_DELAYED");
	self:RegisterEvent("EQUIPMENT_SETS_CHANGED");
	
	self.RegisterEvent = function(self, event)
		self:RegisterEvent(event)
	end
	
	self.OnEvent = function(f, event, ...)
		if self[event] then
			self[event](self, event, ...)
		end		
	end

	self:SetScript('OnEvent', self.OnEvent)
end

function f:MERCHANT_SHOW(event, ...)
	DetectItems()
end

function f:BAG_UPDATE_DELAYED(event, ...)
	DetectItems()
end

function f:EQUIPMENT_SETS_CHANGED()
	DetectItems()
end

function Addon:TooltipInformationAvailable(bag, slot, ...)
   local hasMap = {};
   
   C_TooltipInfo.GameTooltip:ClearLines();
   C_TooltipInfo.GameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
   C_TooltipInfo.GameTooltip:SetBagItem(bag, slot);
   
   for p, tag in ipairs({...}) do
		hasMap[p] = false
   end
   
   for _, region in ipairs({C_TooltipInfo.GameTooltip:GetRegions()}) do
      if region and region:GetObjectType() == "FontString" then
         local text = region:GetText()
		 
		 for p, tag in ipairs({...}) do
			 if text and strfind(text, tag) then
				table.insert(hasMap, p, true);
			 end
		 end
      end
   end
   
   C_TooltipInfo.GameTooltip:Hide();
   return unpack(hasMap);
end

function IndexOf(t, v)
	for i, s in ipairs(t) do
		if s == v then
			return i;
		end
	end
	return nil;
end

f:Load();

function GetItemObject(itemId, bag, slot, containerInfo)
	local itemLink, quality, level, _, itemType, _, stackCount, equipLoc, _, price, classId, subClassId, bindType = select(2, GetItemInfo(itemId))
	local id = C_Item.GetItemGUID(ItemLocation:CreateFromBagAndSlot(bag, slot))
	
	return {
		id = id,
		itemId = itemId,
		classId = classId,
		subClassId = subClassId,
		itemType = itemType,
		price = price,
		link = itemLink,
		count = containerInfo.stackCount,
		stackCount = stackCount,
		bag = bag,
		slot = slot,
		quality = quality,
		level = level,
		equipLoc = equipLoc,
		bindType = bindType,
		isBound = containerInfo.isBound,
		location = ItemLocation:CreateFromBagAndSlot(bag, slot),
	}
end

function DetectItems()
	ItemParts = {}

  for bag = 0, 4 do
		
		
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      local itemId = C_Container.GetContainerItemID(bag, slot)
			if itemId ~= nil then
				local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
				local itemObject = GetItemObject(itemId, bag, slot, containerInfo)
				
				local price = itemObject.price
				local itemType = itemObject.itemType
				local classId = itemObject.classId
				
				if price and price > 0 then
					local id = C_Item.GetItemGUID(ItemLocation:CreateFromBagAndSlot(bag, slot))

					local itemPart = {
						typeName = itemType,
						items = {}
					}
					if ItemParts[classId] ~= nil then
						itemPart = ItemParts[classId]
					end
				
					itemPart.items[id] = itemObject

					if classId ~= nil then
						ItemParts[classId] = itemPart
					end
				end
			end
    end
  end

	EventHandler:FireEvent("ITEMS_CHANGE");
  
  return ItemParts
end

