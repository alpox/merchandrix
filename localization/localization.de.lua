local ADDON, Addon = ...
Addon.L = Addon.L or {};
if GetLocale() == "deDE" then
	Addon.L["Aktivieren"] = "Aktivieren";
	Addon.L["Aktiviert_Verkauf"] = "Aktiviert oder deaktiviert den Verkauf für diese Spalte.";
	Addon.L["Waffen"] = "Waffen";
	Addon.L["Rüstung"] = "Rüstung";
	Addon.L["Verbrauchbar"] = "Verbrauchbar";
	Addon.L["Handwerkswaren"] = "Handwerkswaren";
	Addon.L["Verschiedenes"] = "Verschiedenes";
	Addon.L["Grau"] = "Grau";
	Addon.L["Verkauft_Grau"] = "Verkauft alle grauen Items.";
	Addon.L["Verkauft_Freigegeben"] = "Verkauft alle zum Verkauf freigegebenen Items.";
	Addon.L["Ertrag"] = "Ertrag";
	
	-- Config
	Addon.L["Konfiguration"] = "Konfiguration";
	Addon.L["Spalten"] = "Spalten";
	Addon.L["Itemgrösse"] = "Itemgrösse";
	Addon.L["Konfiguriere_Spalten"] = "Konfiguriere hier die Anzahl Spalten der Item Kategorien.";
	Addon.L["Konfiguriere_Grössen"] = "Konfiguriere hier die Grösse der Items.";
end