
local ADDON, Addon = ...;

local ItemSlot = { };
ItemSlot.__index = ItemSlot

Addon.ItemSlot = ItemSlot

local RIGHT_BUTTON_UP = "RightButtonUp"
local LEFT_BUTTON_UP = "LeftButtonUp"

-- https://github.com/GoldpawsStuff/Bagnon_BoE/blob/master/Bagnon_BoE/main.lua 
-- local colors = {
-- 	[0] = { 157/255, 157/255, 157/255 }, -- Poor
-- 	[1] = { 240/255, 240/255, 240/255 }, -- Common
-- 	[2] = { 30/255, 178/255, 0/255 }, -- Uncommon
-- 	[3] = { 0/255, 112/255, 221/255 }, -- Rare
-- 	[4] = { 163/255, 53/255, 238/255 }, -- Epic
-- 	[5] = { 225/255, 96/255, 0/255 }, -- Legendary
-- 	[6] = { 229/255, 204/255, 127/255 }, -- Artifact
-- 	[7] = { 79/255, 196/255, 225/255 }, -- Heirloom
-- 	[8] = { 79/255, 196/255, 225/255 } -- Blizzard
-- }

function ItemSlot:New(item, part)
	self = setmetatable({}, ItemSlot)
	
	self.Frame = CreateFrame("Frame", part.Frame:GetName() .. 'Slot' .. item.id, part.Frame)
	self.Button = self:CreateButton(item, self.Frame)
	
	self.part = part;
	
	self:Set(item);

	self:CreateBoE()
	self:CreateItemLevel()
	
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

function ItemSlot:CreateBoE()
	local isBound = self._internalItem.isBound

	if (isBound) then
		return
	end

	local quality = self._internalItem.quality
	local mult = (quality ~= 3 and quality ~= 4) and .7
	local bind = self._internalItem.bindType == LE_ITEM_BIND_ON_EQUIP or self._internalItem.bindType == LE_ITEM_BIND_ON_USE
	local message = bind == LE_ITEM_BIND_ON_USE and "BoU" or "BoE"
	local r, g, b = GetItemQualityColor(quality)
	local color = { r, g, b }
	
	if (not bind) then
		return
	end

	self.BoeFont = self.Button:CreateFontString()
	self.BoeFont:SetDrawLayer("OVERLAY", 2)
	self.BoeFont:SetPoint("BOTTOMLEFT", 2, 2)
	self.BoeFont:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
	self.BoeFont:SetFont(self.BoeFont:GetFont(), 12, "OUTLINE")
	self.BoeFont:SetShadowOffset(1, -1)
	self.BoeFont:SetShadowColor(0, 0, 0, .5)
	self.BoeFont:SetText(message)

	if (color) then
		if (mult) then
			self.BoeFont:SetTextColor(color[1] * mult, color[2] * mult, color[3] * mult)
		else
			self.BoeFont:SetTextColor(color[1], color[2], color[3])
		end
	else
		self.BoeFont:SetTextColor(.94, .94, .94)
	end	
end

function ItemSlot:CreateItemLevel()
	local equipLoc = self._internalItem.equipLoc
	local quality = self._internalItem.quality
	print(equipLoc)

	local noequip = not equipLoc
		or not _G[equipLoc]
		or equipLoc == "INVTYPE_NON_EQUIP"
		or equipLoc == "INVTYPE_TABARD"
		or equipLoc == "INVTYPE_AMMO"
		or equipLoc == "INVTYPE_QUIVER"
		or equipLoc == "INVTYPE_BODY"

	local show = quality and quality > 0 and not noequip
	
	if (not show) then
		return
	end

	-- local itemLevel = C_Item.GetCurrentItemLevel(self._internalItem.location)
	itemLevel = C_Item.GetCurrentItemLevel(self._internalItem.location)
	local mult = (quality ~= 3 and quality ~= 4) and .7
	local message = tostring(itemLevel)
	local r, g, b = GetItemQualityColor(quality)
	local color = { r, g, b }
	

	self.ItemLevelFont = self.Button:CreateFontString()
	self.ItemLevelFont:SetDrawLayer("OVERLAY", 2)
	self.ItemLevelFont:SetPoint("TOPRIGHT", -2, -3)
	self.ItemLevelFont:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
	self.ItemLevelFont:SetFont(self.ItemLevelFont:GetFont(), 12, "OUTLINE")
	self.ItemLevelFont:SetShadowOffset(1, -1)
	self.ItemLevelFont:SetShadowColor(0, 0, 0, .5)
	self.ItemLevelFont:SetText(message)

	if (color) then
		if (mult) then
			self.ItemLevelFont:SetTextColor(color[1] * mult, color[2] * mult, color[3] * mult)
		else
			self.ItemLevelFont:SetTextColor(color[1], color[2], color[3])
		end
	else
		self.ItemLevelFont:SetTextColor(.94, .94, .94)
	end	
end

function ItemSlot:UseConfig()
	local size = VendorixConfig.general.buttonSize
	
	self.Button:SetSize(size, size)
	self.Button.IconBorder:SetSize(size, size)
	self.Frame:SetSize(size, size)
	Addon:StyleButton(self.Button, nil, size)

	if (self.BoeFont ~= nil) then
		if (VendorixConfig.general.showBoE) then
			self.BoeFont:Show()
		else
			self.BoeFont:Hide()
		end
	end

	if (self.ItemLevelFont ~= nil) then
		if (VendorixConfig.general.showItemLevel) then
			self.ItemLevelFont:Show()
		else
			self.ItemLevelFont:Hide()
		end
	end
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
	if item.bag and item.slot then 
		GameTooltip:SetBagItem(item.bag, item.slot)
	else
		GameTooltip:SetHyperlink(item.link)
	end
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