local ADDON, Addon = ...
Addon.L = Addon.L or {};
if GetLocale() ~= "deDE" then
	Addon.L["Aktivieren"] = "Activate";
	Addon.L["Aktiviert_Verkauf"] = "Activates or deactivates this category.";
	Addon.L["Waffen"] = "Weapons";
	Addon.L["Rüstung"] = "Armor";
	Addon.L["Verbrauchbar"] = "Usables";
	Addon.L["Handwerkswaren"] = "Workitems";
	Addon.L["Verschiedenes"] = "Miscellaneous";
	Addon.L["Grau"] = "Grey";
	Addon.L["Verkauft_Grau"] = "Sells all grey items.";
	Addon.L["Verkauft_Freigegeben"] = "Sells all activated items.";
	Addon.L["Ertrag"] = "Profit";
	
	-- Config
	Addon.L["Konfiguration"] = "Configuration";
	Addon.L["Spalten"] = "Columns";
	Addon.L["Itemgrösse"] = "Itemsize";
	Addon.L["ShowBoE"] = "Show BoE and BoU";
	Addon.L["ShowItemLevel"] = "Show item level";
	Addon.L["Konfiguriere_Spalten"] = "Configurate here the number of columns of your categories.";
	Addon.L["Konfiguriere_Grössen"] = "Configurate here the size of the item-buttons.";
	Addon.L["Konfiguriere_ShowBoE"] = "Configurate here if you want to see the label 'BoE' for bind on equip or 'BoU' for bind on use.";
	Addon.L["Konfiguriere_ShowItemLevel"] = "Configurate here if you want to see the item levels.";
end