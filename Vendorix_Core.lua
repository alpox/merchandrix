local ADDON, Addon = ...;

EnabledItems = EnabledItems or {}
EnabledParts = EnabledParts or {}
-- Locked = Locked or {}

--[[ core functions ]]--

Addon.CanSellItem = function(item)
	local partEnabled = EnabledParts[item.classId] == nil or EnabledParts[item.classId]
	local itemEnabled = EnabledItems[item.id] == nil or EnabledItems[item.id]
	return partEnabled and itemEnabled
end

Addon.SellItem = function(item)
	if Addon.CanSellItem(item) then
		UseContainerItem(item.bag, item.slot);
	end
end

Addon.SellItems = function(items)
	local itemsPerChunk = 5

	local numItemsToSell = min(#items, itemsPerChunk)

	local nextItems = {}

	for i, item in ipairs(items) do
		if i <= numItemsToSell then
			Addon.SellItem(item)
		else
			table.insert(nextItems, item)
		end
	end

	if #nextItems > 0 then
		Vendorix_wait(0.5, function(itms)
			Addon.SellItems(itms)
		end, nextItems)
	end
end

function Addon:EvaluateEquip(item)
	if not Addon:IsArmor(item) and not Addon:IsWeapon(item) then return true end
	return true
end

function Addon:StyleButton(btn, ico, size)
	if size == nil then size = 36 end
	
	local multiplicator = 64 / 39
	local shown = btn:IsShown()

	local nt = btn:CreateTexture()
	nt:SetTexture([[Interface\Buttons\UI-Quickslot2]])
	nt:SetSize(size * multiplicator, size * multiplicator)
	nt:SetPoint('CENTER', 0, 0)
	btn:SetNormalTexture(nt)

	local pt = btn:CreateTexture()
	pt:SetTexture([[Interface\Buttons\UI-Quickslot-Depress]])
	pt:SetSize(size, size)
	pt:SetAllPoints(btn)
	btn:SetPushedTexture(pt)

	local ht = btn:CreateTexture()
	ht:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
	ht:SetSize(size, size)
	ht:SetAllPoints(btn)
	btn:SetHighlightTexture(ht)
	
	if ico == nil then return end
	
	local icon = btn:CreateTexture()
	icon:SetTexture(ico or [[Interface\PaperDoll\UI-Backpack-EmptySlot]])
	icon:SetSize(size, size)
	icon:SetAllPoints(btn)
	
	if shown then
		btn:Show()
	else
		btn:Hide()
	end
end