local ADDON, Addon = ...;

local BUTTON_SIZE = 36;

local vendor = CreateFrame("Frame", ADDON .. "VendorFrame", MerchantFrame, BackdropTemplateMixin and "BackdropTemplate");
Addon.Vendor = vendor;

function vendor:Initialize()
	vendor:SetBackdrop({bgFile = "Interface/FrameGeneral/UI-Background-Rock", 
						edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
						tile = false, tileSize = 16, edgeSize = 16, 
						insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	vendor:ClearAllPoints();
	vendor:SetPoint("TOPLEFT", MerchantFrame, "TOPRIGHT", 15, 0);
	vendor:SetSize(MerchantFrame:GetSize());
	vendor:Show();
	
	vendor:PlaceSellGreyButton();
	vendor:PlaceSellAllButton();
end

function vendor:UpdateSize()
	local width, height = Addon.ItemFrame:GetSize();
	if width < 100 then
		width = 100
	end
	height = height + 60;
	vendor:SetSize(width, height);
end

--[[ sell grey button ]]--

local function SellGreyButtonClick()
	local itemsToSell = {}

	for _, part in pairs(ItemParts) do
		for _, item in pairs(part.items) do
			if item.quality == 0 and Addon.CanSellItem(item) then
				table.insert(itemsToSell, item)
			end
		end
	end

	Addon.SellItems(itemsToSell)
end

function vendor:CreateSellGreyButton()
	local b = CreateFrame('Button', self:GetName() .. 'GreyButton', self);
	local s = self;
	b:SetScript('OnClick', SellGreyButtonClick);
	b:SetScript('OnEnter', function()
		GameTooltip:SetOwner(b, "ANCHOR_RIGHT");
		GameTooltip:SetText(s:GetGreyButtonTooltipText());
	end);
	b:SetScript('OnLeave', function()
		GameTooltip:Hide();
	end);
	self.SellGreyButton = b;
	return b;
end

function vendor:GetSellGreyButton()
	return self.SellGreyButton;
end

function vendor:PlaceSellGreyButton()
	local btn = self:GetSellGreyButton() or self:CreateSellGreyButton();

	btn:ClearAllPoints();
	btn:SetPoint("BOTTOMLEFT", 10, 10);
	btn:SetSize(BUTTON_SIZE, BUTTON_SIZE);
	
	Addon:StyleButton(btn, [[Interface\Icons\INV_Misc_Coin_04]], 36);

	btn:Show();
end

function vendor:GetGreyButtonTooltipText()
	local amount = 0;
	for _, part in pairs(ItemParts) do
		for _, item in pairs(part.items) do
			if item.quality == 0 and Addon.CanSellItem(item) then
				local sellPrice = select(11, GetItemInfo(item.itemId))
				amount = amount + sellPrice * item.count
			end
		end
	end
	
	return Addon.L["Verkauft_Grau"] .. "\n" .. Addon.L["Ertrag"] .. ": " .. GetCoinTextureString(amount);
end

local function SellAllButtonClick()
	local itemsToSell = {}

	for _, part in pairs(ItemParts) do
		for _, item in pairs(part.items) do
			if Addon.CanSellItem(item) then
				table.insert(itemsToSell, item)
			end
		end
	end

	Addon.SellItems(itemsToSell)
end

function vendor:CreateSellAllButton()
	local b = CreateFrame('Button', self:GetName() .. 'AllButton', self);
	local s = self;
	b:SetScript('OnClick', SellAllButtonClick);
	b:SetScript('OnEnter', function()
		GameTooltip:SetOwner(b, "ANCHOR_RIGHT");
		GameTooltip:SetText(s:GetSellAllButtonTooltipText());
	end);
	b:SetScript('OnLeave', function()
		GameTooltip:Hide();
	end);
	self.SellAllButton = b;
	return b;
end

function vendor:GetSellAllButton()
	return self.SellAllButton;
end

function vendor:PlaceSellAllButton()
	local btn = self:GetSellAllButton() or self:CreateSellAllButton();

	btn:ClearAllPoints();
	btn:SetPoint("LEFT", self:GetSellGreyButton(), "RIGHT", 5, 0);
	btn:SetSize(BUTTON_SIZE, BUTTON_SIZE);
	
	Addon:StyleButton(btn, [[Interface\Icons\INV_Misc_Coin_02]]);

	btn:Show();
end

function vendor:GetSellAllButtonTooltipText()
	local amount = 0;
	for _, part in pairs(ItemParts) do
		for _, item in pairs(part.items) do
			if Addon.CanSellItem(item) then
				local sellPrice = select(11, GetItemInfo(item.itemId))
				amount = amount + sellPrice * item.count
			end
		end
	end
	
	return Addon.L["Verkauft_Freigegeben"] .. "\n" .. Addon.L["Ertrag"] .. ": " .. GetCoinTextureString(amount);
end

vendor:Initialize();