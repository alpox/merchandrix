local ADDON, Addon = ...;

local defaultConfig = {
	general = {
		numColumns = 10,
		buttonSize = 36,
		showBoE = false,
		showItemLevel = false,
		safeSell = false,
		showInAuctionHouse = false
	}
}

VendorixConfig = VendorixConfig or defaultConfig

local category = Settings.RegisterVerticalLayoutCategory("Vendorix")

local function UseConfig()
	Addon.ItemFrame:UseConfig()
end

local function UseDefaults()
	VendorixConfig = defaultConfig
	UseConfig()
end

function SetValue(key, setting)
	return function (event)
		VendorixConfig.general[key] = setting:GetValue()
		UseConfig()
	end
end

function Register()
	local variable = "numColumns"
	local name = Addon.L["Spalten"]
	local tooltip = Addon.L["Konfiguriere_Spalten"]
	local defaultValue = VendorixConfig.general[variable] or defaultConfig.general[variable]
	local minValue = 5
	local maxValue = 20
	local step = 1

	local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
	local options = Settings.CreateSliderOptions(minValue, maxValue, step)
	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
	Settings.SetOnValueChangedCallback(variable, SetValue(variable, setting));
	Settings.CreateSlider(category, setting, options, tooltip)

	local variable = "buttonSize"
	local name = Addon.L["Itemgrösse"]
	local tooltip = Addon.L["Konfiguriere_Grössen"]
	local defaultValue = VendorixConfig.general[variable] or defaultConfig.general[variable]
	local minValue = 25
	local maxValue = 50
	local step = 1

	local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
	local options = Settings.CreateSliderOptions(minValue, maxValue, step)
	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
	Settings.SetOnValueChangedCallback(variable, SetValue(variable, setting));
	Settings.CreateSlider(category, setting, options, tooltip)

	local variable = "showBoE"
	local name = Addon.L["ShowBoE"] or "ShowBoE"
	local tooltip = Addon.L["Konfiguriere_ShowBoE"]
	local defaultValue = VendorixConfig.general[variable] or defaultConfig.general[variable]
		
	local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), VendorixConfig.general.showBoE)
	Settings.SetOnValueChangedCallback(variable, SetValue(variable, setting));
	Settings.CreateCheckBox(category, setting, tooltip)

	local variable = "showItemLevel"
	local name = Addon.L["ShowItemLevel"] or "ShowItemLevel"
	local tooltip = Addon.L["Konfiguriere_ShowItemLevel"]
	local defaultValue = VendorixConfig.general[variable] or defaultConfig.general[variable]
		
	local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), VendorixConfig.general.showItemLevel)
	Settings.SetOnValueChangedCallback(variable, SetValue(variable, setting));
	Settings.CreateCheckBox(category, setting, tooltip)

	local variable = "safeSell"
	local name = Addon.L["SafeSell"] or "SafeSell"
	local tooltip = Addon.L["Konfiguriere_SafeSell"]
	local defaultValue = VendorixConfig.general[variable] or defaultConfig.general[variable]
		
	local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), VendorixConfig.general.safeSell)
	Settings.SetOnValueChangedCallback(variable, SetValue(variable, setting));
	Settings.CreateCheckBox(category, setting, tooltip)

	local variable = "showInAuctionHouse"
	local name = Addon.L["ShowInAuctionHouse"] or "ShowInAuctionHouse"
	local tooltip = Addon.L["Konfiguriere_ShowInAuctionHouse"]
	local defaultValue = VendorixConfig.general[variable] or defaultConfig.general[variable]
		
	local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), VendorixConfig.general.showInAuctionHouse)
	Settings.SetOnValueChangedCallback(variable, SetValue(variable, setting));
	Settings.CreateCheckBox(category, setting, tooltip)

	Settings.RegisterAddOnCategory(category)
end

SettingsRegistrar:AddRegistrant(Register);