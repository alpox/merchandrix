local ADDON, Addon = ...;

local itemFrame = CreateFrame("Frame", ADDON .. "ItemFrame", Addon.Vendor);

Addon.ItemFrame = itemFrame;

function itemFrame:Initialize()
	self.items = DetectItems()
	self.itemParts = {}

	self:ClearAllPoints();
	self:SetPoint("TOPLEFT", 0, 0);
	self:SetSize(Addon.Vendor:GetSize());
	self:UpdateParts();
	
	self:RegisterEvent("ADDON_LOADED");
	Addon.EventHandler:RegisterEvent(self, "ITEMS_CHANGE");
	
	self:SetScript("OnEvent", function(f, event, ...)
		if self[event] then
			self[event](self, event, ...)
		end		
	end);
end

function itemFrame:ADDON_LOADED()
	self:UseConfig()
end

function itemFrame:ITEMS_CHANGE()
	self:UpdateParts()
end

function itemFrame:OrganizeParts()
	local prev = nil
	for _, part in pairs(self.itemParts) do
		part.Frame:ClearAllPoints()
		
		if not prev then
			part.Frame:SetPoint("TOPLEFT", Addon.Vendor, "TOPLEFT", 10, -10)
		else
			part.Frame:SetPoint("TOP", prev.Frame , "BOTTOM", 0, -5)
		end

		if part:NumShownItems() > 0 then
			prev = part
		end
	end
end

function itemFrame:UpdateParts()
	for key, value in orderedPairs(ItemParts) do
		if self.itemParts[key] == nil then
			self.itemParts[key] = Addon.ItemPart:New(key, value.typeName)
		end
	end
	for _, part in pairs(self.itemParts) do
		part:UpdateItems()
	end

	self:UpdateSize();
end

function itemFrame:UseConfig()
	for _, part in pairs(self.itemParts) do
		part:UseConfig()
	end
end

function itemFrame:GetEnabledItems()
	local enabled = {}
	for _, part in pairs(self.itemParts) do
		for p, item in ipairs(part:GetEnabledItems()) do
			table.insert(enabled, item)
		end
	end
	
	return enabled
end

function itemFrame:UpdateSize()
	local height = 0;
	local width = 0;

	self:OrganizeParts();
	
	for _, part in pairs(self.itemParts) do
		local w, h = part.Frame:GetSize();
		
		if w > width then
			width = w;
		end
		
		if part:NumShownItems() > 0 then
			height = height + h + 5;
		end
	end
	width = width + 20;
	
	self:SetSize(width, height);

	Addon.Vendor:UpdateSize();
end

itemFrame:Initialize();