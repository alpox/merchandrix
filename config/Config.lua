local ADDON, Addon = ...;

local defaultConfig = {
	general = {
		numColumns = 10,
		buttonSize = 36
	}
}

MerchandrixConfig = MerchandrixConfig or defaultConfig

local ConfigFrame = CreateFrame("Frame", ADDON .. "ConfigFrame", InterfaceOptionsFramePanelContainer)
ConfigFrame:Hide()
ConfigFrame.name = ADDON

local function UseConfig()
	Addon.ItemFrame:UseConfig()
end

local function UseDefaults()
	MerchandrixConfig = defaultConfig
	UseConfig()
end

ConfigFrame:SetScript("OnShow", function(self)
	local title = self:CreateTitle()
	local columnSlider = self:CreateColumnSlider(title)
	local itemSlider = self:CreateButtonWidthSlider(columnSlider)
	
	local Refresh;
    function Refresh()
        if not self:IsVisible() then return end
        columnSlider:SetSavedValue(MerchandrixConfig.general.numColumns)
		itemSlider:SetSavedValue(MerchandrixConfig.general.buttonSize)
    end

    self:SetScript("OnShow", Refresh) 
    Refresh()
end)

function ConfigFrame:CreateTitle()
	local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(ADDON .. " " .. Addon.L["Konfiguration"])
	return title
end

function ConfigFrame:CreateColumnSlider(anchor)
	local slider = Addon.OptionsSlider:New(Addon.L["Spalten"], self, 5, 20, 1)
	
	slider.SetSavedValue = function(self, value)
		MerchandrixConfig.general.numColumns = value
		self:UpdateValue()
		UseConfig()
	end

	slider.GetSavedValue = function(self)
		return MerchandrixConfig.general.numColumns
	end

	slider.GetFormattedText = function(self, value)
		return value .. ''
	end
	
	slider.tooltipText = Addon.L["Konfiguriere_Spalten"];
	slider:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -15)
	
	return slider
end

function ConfigFrame:CreateButtonWidthSlider(anchor)
	local slider = Addon.OptionsSlider:New(Addon.L["Itemgrösse"], self, 25, 50, 1)

	slider.SetSavedValue = function(self, value)
		MerchandrixConfig.general.buttonSize = value
		self:UpdateValue()
		UseConfig()
	end

	slider.GetSavedValue = function(self)
		return MerchandrixConfig.general.buttonSize
	end

	slider.GetFormattedText = function(self, value)
		return value .. ''
	end
	
	slider.tooltipText = Addon.L["Konfiguriere_Grössen"]
	slider:SetPoint("LEFT", anchor, "RIGHT", 30, 0)
	
	return slider
end

InterfaceOptions_AddCategory(ConfigFrame)