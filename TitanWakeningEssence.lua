local ADDON_NAME, L = ...;

local I18N = LibStub("AceLocale-3.0"):GetLocale("TitanWakeningEssence")
local TITAN_I18N = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local CURRENCY_ID = 1533
local PLUGIN_NAME = "TITAN_WAKENING_ESSENCE"
local currencyCount = 0.0
local startcurrency

local function defaultIfEmpty(v,d)
	if not v then
		return d
	end
	return v
end

function CurrencyDisplayCallback()
	local _, amount, _, _, _, _, _ = GetCurrencyInfo(CURRENCY_ID)

	currencyCount = amount or 0
	if not startcurrency then startcurrency = currencyCount end
	TitanPanelButton_UpdateButton(PLUGIN_NAME)

end


local function GetBalanceColor(firstValue, secondValue)
	if (firstValue > secondValue) then
		return GREEN_FONT_COLOR
	elseif (firstValue > secondValue) then
		return RED_FONT_COLOR
	else
		return HIGHLIGHT_FONT_COLOR
	end
end

local function GetBalanceText(currentAmount, startcurrency)
	local balanceFontColor = GetBalanceColor(currentAmount, startcurrency)
	return TitanUtils_GetColoredText( " ["..(currentAmount - startcurrency).."]", balanceFontColor)
end

local function GetButtonText()
	local currencyName, currentAmount, _, _, _, _, _ = GetCurrencyInfo(CURRENCY_ID)

	local currencyCountText
	if not currencyCount then
		currencyCountText = TitanUtils_GetHighlightText("0")
	else
		currencyCountText = TitanUtils_GetHighlightText(currencyCount)
	end

	local shouldDisplayLabelText = TitanGetVar(PLUGIN_NAME, "ShowLabelText")
	local shouldDisplayBalance = TitanGetVar(PLUGIN_NAME, "ShowBarBalance")

	local balanceText = ""
	if shouldDisplayBalance then
		balanceText = GetBalanceText(currentAmount, startcurrency)
	end

	if shouldDisplayLabelText then
		return TitanUtils_GetColoredText( currencyName ..":", NORMAL_FONT_COLOR)  ..
				currencyCountText  ..
				balanceText
	else
		return currencyCountText ..
				balanceText
	end
end

local function TooltipTextCallback()
	if currencyCount and startcurrency then
		local balanceFontColor = GetBalanceColor(currencyCount,startcurrency)
		return I18N["Used to create or upgrade Legion Legendary items."].."\r\r"..
			TitanUtils_GetHighlightText("[Information]") .. "\r"
			.. I18N["Total acquired: "] .. TitanUtils_GetColoredText(defaultIfEmpty(currencyCount, "0"), HIGHLIGHT_FONT_COLOR)  .. "\r"
			.. I18N["Session balance: "] .. TitanUtils_GetColoredText(defaultIfEmpty(currencyCount - startcurrency, "0"), balanceFontColor)
	else
		return I18N["Used to create or upgrade Legion Legendary items."]..
			"\r\r" ..
			TitanUtils_GetHighlightText("["..I18N["Information"].."]") .. "\r"
			.. I18N["Total acquired: "] .. TitanUtils_GetColoredText(defaultIfEmpty(currencyCount, "0"), HIGHLIGHT_FONT_COLOR)  .. "\r"
	end

end

function PrepareMenuCallback()
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[PLUGIN_NAME].menuText)
	TitanPanelRightClickMenu_AddToggleIcon(PLUGIN_NAME)
	TitanPanelRightClickMenu_AddToggleLabelText(PLUGIN_NAME)

	L_UIDropDownMenu_AddButton({
		checked = TitanGetVar(PLUGIN_NAME, "ShowBarBalance"),
		text 	= I18N["Display Session Balance in Bar"],
		func = function (self)
			TitanToggleVar(PLUGIN_NAME, "ShowBarBalance");
			TitanPanelButton_UpdateButton(PLUGIN_NAME)
		end
	});

	L_UIDropDownMenu_AddButton({
		checked = TitanGetVar(PLUGIN_NAME, "DisplayOnRightSide"),
		text = TITAN_I18N["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"],
		func = function (self)
				TitanToggleVar(PLUGIN_NAME, "DisplayOnRightSide");
				TitanPanel_InitPanelButtons();
		end
	});
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(TITAN_I18N["TITAN_PANEL_MENU_HIDE"], PLUGIN_NAME, TITAN_PANEL_MENU_FUNC_HIDE);
end

function RegisterPlugin()

	local currencyName, _,  texturePath, _, _, _, _ = GetCurrencyInfo(CURRENCY_ID)

	local frame = CreateFrame("Button", "TitanPanel" .. PLUGIN_NAME .."Button", CreateFrame("Frame", nil, UIParent), "TitanPanelComboTemplate")
	frame:SetFrameStrata("FULLSCREEN")
	frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnClick", function(self, button, ...)
		TitanPanelButton_OnClick(self, button)
	end)

	frame["CURRENCY_DISPLAY_UPDATE"] = function (self) CurrencyDisplayCallback() end
	frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

	function frame:ADDON_LOADED(a1)
		if a1 ~= ADDON_NAME then
			return
		end

		self:UnregisterEvent("ADDON_LOADED")
		self.ADDON_LOADED = nil
		self.registry = {
			id = PLUGIN_NAME,
			menuText = currencyName .. "|r",
			buttonTextFunction = "TitanPanelButton_WakeningEssenceButtonText",
			tooltipTitle = currencyName,
			tooltipTextFunction = "TitanPanelButton_WakeningEssenceTooltipText",
			frequency = 1,
			icon = texturePath,
			iconWidth = 16,
			category = "Information",
			version = GetAddOnMetadata(ADDON_NAME, "Version"),
			savedVariables = {
				ShowIcon = 1,
				DisplayOnRightSide = false,
				ShowBarBalance = false,
				ShowLabelText = false,
			}

		}

	end

	_G["TitanPanelRightClickMenu_Prepare" .. PLUGIN_NAME .. "Menu"] = PrepareMenuCallback
	_G["TitanPanelButton_WakeningEssenceButtonText"] = GetButtonText
	_G["TitanPanelButton_WakeningEssenceTooltipText"] = TooltipTextCallback

	return frame
end

RegisterPlugin()
