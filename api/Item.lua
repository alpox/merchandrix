
local ADDON, Addon = ...;

local ItemSlot = { };
ItemSlot.__index = ItemSlot

Addon.ItemSlot = ItemSlot

local RIGHT_BUTTON_UP = "RightButtonUp"
local LEFT_BUTTON_UP = "LeftButtonUp"

function ItemSlot:New(item, part)
	self = setmetatable({}, ItemSlot)
	
	self.Frame = CreateFrame("Frame", part.Frame:GetName() .. 'Slot' .. item.id, part.Frame)
	self.Button = self:CreateButton(item, self.Frame)
	
	self.part = part;
	
	self:Set(item);
	
	self:UseConfig();
	
	self:UpdateState();
	
	self.Frame:RegisterEvent("MODIFIER_STATE_CHANGED")
	
	self.Frame:SetScript('OnEvent', function(f, event, ...)
		if self[event] then
			self[event](self, event, ...);
		end
	end);
	
	return self;
end

function ItemSlot:UseConfig()
	local size = MerchandrixConfig.general.buttonSize
	
	self.Button:SetSize(size, size)
	self.Button.IconBorder:SetSize(size, size)
	self.Frame:SetSize(size, size)
	Addon:StyleButton(self.Button, nil, size)
end

function ItemSlot:MODIFIER_STATE_CHANGED(event, button, state)
	if button ~= "LSHIFT" and button ~= "RSHIFT" then return end
	
	if state == 1 then
		GameTooltip_ShowCompareItem()
	else
		if ShoppingTooltip1 then
			ShoppingTooltip1:Hide()
		end
		if ShoppingTooltip2 then
			ShoppingTooltip2:Hide()
		end
		if ShoppingTooltip3 then
			ShoppingTooltip3:Hide()
		end
	end
end

function ItemSlot:Remove()
	if not self.Frame:IsShown() then return end
	self.part:RemoveItemBetween(self.id);
end

function ItemSlot:CreateButton(item, parentFrame)
	local button = CreateFrame('ItemButton', parentFrame:GetName() .. 'Button' .. 'Item' .. item.id, parentFrame);
	
	button:RegisterForClicks(LEFT_BUTTON_UP, RIGHT_BUTTON_UP);
	
	button:HookScript('OnClick', function(_, btn) self:SellButtonClick(btn) end);
	button:HookScript('OnEnter', function(...) self:SellButtonEnter() end);
	button:HookScript('OnLeave', function(...) self:SellButtonLeave() end);

	button:SetPoint("TOPLEFT", parentFrame,  0, 0);
	
	button:SetScript('OnEvent', function(f, event, ...)
		if self[event] then
			self[event](self, event, ...);
		end
	end);

	return button
end

function ItemSlot:Set(item)
	self.id = item.id;
	self._internalItem = item

	self.Button:SetItem(self._internalItem.itemId);
	self:SetCount(item);
	self:UpdateState();
end

function ItemSlot:SetCount(item)
	self.Button:SetItemButtonCount(item.count)
end

function ItemSlot:SellButtonClick(button)
	if not self.part:GetEnabled() then return end
	if button == "RightButton" and self:GetEnabled() then
		Addon.SellItem(self._internalItem);
	elseif button == "LeftButton" then
		self:SetEnabled(not self:GetEnabled());
		self:SellButtonEnter();
	end
end

function ItemSlot:AnchorTooltip()
	if self.Button:GetRight() >= (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self.Button, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self.Button, 'ANCHOR_RIGHT')
	end
end
	
function ItemSlot:SellButtonEnter()
	ResetCursor();
	if self:GetEnabled() then
		SetCursor("BUY_CURSOR");
	end
	self:AnchorTooltip();
	GameTooltip:ClearLines();
	local item = self._internalItem
	GameTooltip:SetHyperlink(item.link)
	GameTooltip:Show();
end
	
function ItemSlot:SellButtonLeave()
	GameTooltip:Hide();
	ResetCursor();
end
	
function ItemSlot:UpdateState()
	self:SetEnabled(self:GetEnabled());
end

function ItemSlot:SetEnabled(enabled)
	if enabled ~= nil then
		if self.part:GetEnabled() then
			EnabledItems[self.id] = enabled;
		end
		
		if enabled then
			self.Button:SetAlpha(1);
		else
			self.Button:SetAlpha(0.3);
		end
	end
end

function ItemSlot:GetEnabled()
	if EnabledItems[self.id] == nil then
		return self.part:GetEnabled()
	end

	return EnabledItems[self.id] and self.part:GetEnabled();
end