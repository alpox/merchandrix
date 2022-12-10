
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

	self.BoeFont = self:CreateBoE(item)
	self.ItemLevelFont = self:CreateItemLevel(item)
	
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

function ItemSlot:CreateBoE()
	local boeFont = self.Button:CreateFontString()
	boeFont:SetDrawLayer("OVERLAY", 2)
	boeFont:SetPoint("BOTTOMLEFT", 2, 2)
	boeFont:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
	boeFont:SetFont(boeFont:GetFont(), 12, "OUTLINE")
	boeFont:SetShadowOffset(1, -1)
	boeFont:SetShadowColor(0, 0, 0, .5)
	return boeFont
end

function ItemSlot:CreateItemLevel()
	local itemLevelFont = self.Button:CreateFontString()
	itemLevelFont:SetDrawLayer("OVERLAY", 2)
	itemLevelFont:SetPoint("TOPRIGHT", -2, -3)
	itemLevelFont:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
	itemLevelFont:SetFont(itemLevelFont:GetFont(), 12, "OUTLINE")
	itemLevelFont:SetShadowOffset(1, -1)
	itemLevelFont:SetShadowColor(0, 0, 0, .5)
	return itemLevelFont
end

function ItemSlot:UpdateBoe()
	local isBound = self._internalItem.isBound

	if (isBound) then
		self.BoeFont:Hide()
		return
	end

	local quality = self._internalItem.quality
	local mult = (quality ~= 3 and quality ~= 4) and .7
	local bind = self._internalItem.bindType == LE_ITEM_BIND_ON_EQUIP or self._internalItem.bindType == LE_ITEM_BIND_ON_USE
	local message = bind == LE_ITEM_BIND_ON_USE and "BoU" or "BoE"
	local color = self._internalItem.color
	
	if (not bind) then
		self.BoeFont:Hide()
		return
	end

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

function ItemSlot:UpdateItemLevel()
	local equipLoc = self._internalItem.equipLoc
	local quality = self._internalItem.quality

	local noequip = not equipLoc
		or not _G[equipLoc]
		or equipLoc == "INVTYPE_NON_EQUIP"
		or equipLoc == "INVTYPE_TABARD"
		or equipLoc == "INVTYPE_AMMO"
		or equipLoc == "INVTYPE_QUIVER"
		or equipLoc == "INVTYPE_BODY"

	local show = quality and quality > 0 and not noequip
	
	if (not show) then
		self.ItemLevelFont:Hide()
		return
	end

	local itemLevel = self._internalItem.level
	local mult = (quality ~= 3 and quality ~= 4) and .7
	local message = tostring(itemLevel)
	local color = self._internalItem.color

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
	local button = CreateFrame('ItemButton', parentFrame:GetName() .. 'Button' .. 'Item' .. item.id, parentFrame, 'ContainerFrameItemButtonTemplate');
	
	button:RegisterForClicks(LEFT_BUTTON_UP, RIGHT_BUTTON_UP);
	
	-- button:SetScript("PreClick", function(_, btn) self:OnClick(btn) end);
	button:SetScript("OnClick", function(_, btn) self:OnClick(btn) end);
	-- button:HookScript('OnLeave', function(...) self:SellButtonLeave() end);
	button:SetPoint("TOPLEFT", parentFrame,  0, 0);
	
	button:SetScript('OnEvent', function(f, event, ...)
		if self[event] then
			self[event](self, event, ...);
		end
	end);

	return button
end

function ItemSlot:OnClick(button)
	local modifiedClick = IsModifiedClick();

	-- If we can loot the item and autoloot toggle is active, then do a normal click
	if ( button ~= "LeftButton" and modifiedClick and IsModifiedClick("AUTOLOOTTOGGLE") ) then
		local info = C_Container.GetContainerItemInfo(self.Button:GetBagID(), self.Button:GetID());
		local lootable = info and info.hasLoot;
		if ( lootable ) then
			modifiedClick = false;
		end
	end

	if button == "LeftButton" and not modifiedClick then
		self:SetEnabled(not self:GetEnabled());
		return
	else
		if ( modifiedClick ) then
			self.Button:OnModifiedClick(button);
		else
			ContainerFrameItemButton_OnClick(self.Button, button);
		end
	end
end

function ItemSlot:Set(item)
	self.id = item.id;
	self._internalItem = item
	
	self.Button:SetItemLocation(item.location);
	self.Button:SetBagID(item.bag)
	self.Button:SetID(item.slot)
	self.Button:UpdateExtended()
	self.Button:UpdateNewItem(item.quality)
	self:SetCount(item);
	self:UpdateState();
	self:UpdateBoe()
	self:UpdateItemLevel()
	self:UseConfig()
end

function ItemSlot:SetCount(item)
	self.Button:SetItemButtonCount(item.count)
end
-- 
-- function ItemSlot:AnchorTooltip()
-- 	if self.Button:GetRight() >= (GetScreenWidth() / 2) then
-- 		GameTooltip:SetOwner(self.Button, 'ANCHOR_LEFT')
-- 	else
-- 		GameTooltip:SetOwner(self.Button, 'ANCHOR_RIGHT')
-- 	end
-- end
	
-- function ItemSlot:SellButtonEnter()
-- 	ResetCursor();
-- 	if self:GetEnabled() then
-- 		SetCursor("BUY_CURSOR");
-- 	end
-- 	self:AnchorTooltip();
-- 	GameTooltip:ClearLines();
-- 	local item = self._internalItem
-- 	if item.bag and item.slot then 
-- 		GameTooltip:SetBagItem(item.bag, item.slot)
-- 	else
-- 		GameTooltip:SetHyperlink(item.link)
-- 	end
-- 	GameTooltip:Show();
-- end
-- 	
-- function ItemSlot:SellButtonLeave()
-- 	GameTooltip:Hide();
-- 	ResetCursor();
-- end
	
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