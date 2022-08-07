local ADDON, Addon = ...;

local TITLE_HEIGHT = 10;

local ItemSlot = Addon.ItemSlot;

local ItemPart = { };
ItemPart.__index = ItemPart;

Addon.ItemPart = ItemPart;

function ItemPart:New(classId, title)
	local name = ADDON .. "ItemPart" .. classId

	self = setmetatable({ Items = {} }, ItemPart);
	
	self.id = classId
	self.Frame = CreateFrame("Frame", name, Addon.ItemFrame, BackdropTemplateMixin and "BackdropTemplate");
	
	self.Frame:RegisterEvent("ADDON_LOADED");
	
	self.Frame:SetScript("OnEvent", function(f, event, ...)
		if self[event] then
			self[event](self, event, ...)
		end		
	end);
	
	self:UpdateSize();
	
	self.Frame:SetBackdrop({bgFile = "Interface/FrameGeneral/UI-Background-Marble", 
						edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
						tile = false, tileSize = 16, edgeSize = 16, 
						insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	
	self:CreateTitle(title);
	self:CreateCheckBox();
	
	self:UpdateEnabled();
	
	return self;
end

function ItemPart:ADDON_LOADED(event, ad)
	if ad ~= ADDON then return end
	self.Frame:UnregisterEvent(event);
	self:SetEnabled(EnabledParts[self.id]);
	
	for _, item in ipairs(self.Items) do
		item:UpdateState()
	end
end

function ItemPart:UpdateItems()
	self:Clear();
	local sortFunc = nil;
	
	if self.id == Addon.ARMOR_ID or self.id == Addon.WEAPON_ID then
		sortFunc = sortedArmor;
	else
		sortFunc = sortedOther;
	end

	if ItemParts[self.id] ~= nil then
		for _, item in sortFunc(ItemParts[self.id].items) do
			self:AddItem(item)
		end
	end

	self:UpdateSize();
end

function ItemPart:CreateTitle(title)
	local frame = self.Frame;
	local font = frame:CreateFontString(frame:GetName() .. "Title");
	font:SetPoint("TOPLEFT", 3, -10);
	font:SetFontObject(GameFontNormal);
	font:SetText(title);
	font:SetSize(font:GetStringWidth() + 20, TITLE_HEIGHT);
end

function ItemPart:CheckBoxClick()
	if self:GetChecked() then
		self.part:SetEnabled(true)
	else
		self.part:SetEnabled(false)
	end
end

function ItemPart:CreateCheckBox()
	local frame = self.Frame
	local box = CreateFrame("CheckButton", "$parentCheckBox", frame, "InterfaceOptionsCheckButtonTemplate")
	local func = self.CheckBoxClick;
	
	self.CheckBox = box
	
	box.part = self;
	
	box:SetPoint("TOPRIGHT", -75, -3);
	box.Text:SetText(Addon.L["Aktivieren"]);
	box.tooltipText = Addon.L["Aktiviert_Verkauf"];
	
	box:SetScript("OnClick", func);
	
	return box
end

function ItemPart:UpdateSize()
	local numItems = self:NumShownItems();

	if numItems == 0 then
		self.Frame:SetSize(0, 0);
		self.Frame:Hide();
		return
	end

	local buttonSize = MerchandrixConfig.general.buttonSize;
	local itemSize = self.Items[1].Frame:GetHeight()
	local newHeight = math.ceil(numItems / MerchandrixConfig.general.numColumns) * (itemSize + 5) + TITLE_HEIGHT + 30;
	local width = (buttonSize + 5) * MerchandrixConfig.general.numColumns + 15;
	
	self.Frame:Show();
	
	self.Frame:SetSize(width, newHeight);
end

--[[ ItemButton ]]--

function ItemPart:CreateSellButton(item)
	local b = ItemSlot:New(item, self);
	
	table.insert(self.Items, b);
	
	return b;
end

function ItemPart:PlaceSellButton(btn)
	local itemNum = self:GetItemIndex(btn);
	local item = btn._internalItem;

	btn.Frame:ClearAllPoints();
	
	local function PlaceRight()
		if self:GetLastItem(item) then
			btn.Frame:SetPoint("LEFT", self:GetLastItem(item).Frame, "RIGHT", 5, 0);
		end
	end

	local function PlaceBottom()
		local topItem = self:GetTopItem(item);
		if not topItem then
			btn.Frame:SetPoint("TOPLEFT", self.Frame,  10, -20 - TITLE_HEIGHT);
		else
			btn.Frame:SetPoint("TOP", topItem.Frame, "BOTTOM", 0, -5);
		end
	end
	
	if (itemNum - 1) % MerchandrixConfig.general.numColumns == 0 then
		PlaceBottom()
	else
		PlaceRight()
	end
end

function ItemPart:Clear()
	for _, item in ipairs(self.Items) do
		item.Frame:Hide();
		item.Button:Hide();
	end
end

function ItemPart:AddItem(item)
	local index = self:NumShownItems() + 1
	local itemSlot = self.Items[index]
	
	if itemSlot then
		itemSlot:Set(item)
	else
		itemSlot = self:CreateSellButton(item)
		self:PlaceSellButton(itemSlot);
	end
	
	itemSlot.Frame:Show();
	itemSlot.Button:Show();
	itemSlot:UpdateState();
end

function ItemPart:UseConfig()
	for _, itemSlot in ipairs(self.Items) do
		self:PlaceSellButton(itemSlot);
		itemSlot:UseConfig()
	end
	
	self:UpdateSize()
end

function ItemPart:GetItemIndex(btn)
	for i, slot in ipairs(self.Items) do
		if slot == btn then
			return i;
		end
	end
	return nil;
end

function ItemPart:GetButtonById(id)
	for _, item in ipairs(self.Items) do
		if item.id == id then
			return item
		end
	end
end

function ItemPart:GetItem(item)
	for _, slot in ipairs(self.Items) do
		if slot.id == item.id then
			return slot
		end
	end
	
	return nil
end

function ItemPart:GetTopItem(item)
	local idx = self:GetIndexOfItem(item);
	if not idx then return nil end
	idx = idx - MerchandrixConfig.general.numColumns;
	return self.Items[idx];
end

function ItemPart:GetIndexOfItem(item)
	for i, p in ipairs(self.Items) do
		if p.id == item.id then
			return i;
		end
	end
	return nil;
end

function ItemPart:GetLastItem(item)
	for i, it in ipairs(self.Items) do
		if it.id == item.id then
			return self.Items[i - 1];
		end
	end
end

function ItemPart:GetColumnNums()
	local idx = {};
	for i = 1, MerchandrixConfig.general.numColumns do
		idx[i] = i;
	end
	return unpack(idx);
end

function ItemPart:NumShownItems()
	local counter = 0;
	for _, item in ipairs(self.Items) do
		if item.Frame:IsShown() then
			counter = counter + 1
		end
	end
	return counter;
end

function ItemPart:GetHiddenButton()
	for _, btn in ipairs(self.Items) do
		if not btn.Frame:IsShown() then
			return btn
		end
	end
	return nil
end

function ItemPart:RemoveItemBetween(id)
	local found = false;
	for i, item in ipairs(self.Items) do
		if item.id == id then
			found = true
		end
		
		if found and self.Items[i + 1] then
			item:Set(self.Items[i + 1].slot);
		end
	end
	
	if found then
		local lastNotHidden = self:GetLastNotHiddenItem();
		if lastNotHidden then
			lastNotHidden:Hide();
		end
	end
	
	self:UpdateSize();
end

function ItemPart:GetHiddenItems()
	local hidden = {};
	for _, item in ipairs(self.Items) do
		if not item.Frame:IsShown() then
			table.insert(hidden, item);
		end
	end
	return hidden;
end

function ItemPart:GetLastNotHiddenItem()
	return self.Items[self:NumShownItems()];
end

function ItemPart:GetEnabledItems()
	if not self:GetEnabled() then return {} end
	
	local items = {}
	for _, item in ipairs(self.Items) do
		if item:GetEnabled() and item.Frame:IsShown() then
			table.insert(items, item._internalItem)
		end
	end
	
	return items
end

function ItemPart:SetEnabled(enabled)
	self.CheckBox:SetChecked(enabled)
	EnabledParts[self.id] = enabled;
	
	for _, item in ipairs(self.Items) do
		item:UpdateState();
	end
end

function ItemPart:UpdateEnabled()
	self:SetEnabled(self:GetEnabled());
end

function ItemPart:GetEnabled()
	if EnabledParts[self.id] == nil then
		return true
	end
	return EnabledParts[self.id];
end