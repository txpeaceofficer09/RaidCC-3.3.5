local f = CreateFrame("Frame", "RaidCCFrame", UIParent)

local cc = {}
local targets = {}

local numBars = 0
local barSize = 16
local barWidth = 200

local spells = {}

-- Mage
spells[12826] = 50 -- Polymorph

-- Warlock
spells[6215] = 20 -- Fear
spells[17928] = 8 -- Howl of Terror
spells[17926] = 3 -- Death Coil

-- Druid
spells[33786] = 6 -- Cyclone
spells[26995] = 15 -- Soothe Animal
spells[18658] = 40 -- Hibernate

-- Priest
spells[8122] = 8 -- Psychic Scream
spells[9484] = 50 -- Shackle Undead

-- Warrior

-- Rogue

-- Shaman

-- Hunter

RaidCC_Config = {
	["p"] = "RIGHT",
	["x"] = 0,
	["y"] = 0,
	["lock"] = false,
}

f:SetWidth(barWidth)
f:SetHeight(barSize)

f:SetPoint(RaidCC_Config.p, UIParent, RaidCC_Config.p, RaidCC_Config.x, RaidCC_Config.y)

f:SetBackdrop( { bgFile = "Interface\\BUTTONS\\GRADBLUE", edgeFile = nil, tile = false, tileSize = f:GetWidth(), edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } } )
f:SetBackdropColor(1, 0.5, 0.5, 1)

local t = f:CreateFontString(f:GetName().."Title", "OVERLAY", "NumberFont_Outline_Med")
t:SetJustifyH("LEFT")
t:SetPoint("LEFT", f, "LEFT", 2, 0)
t:SetText("RaidCC")

f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetMovable(true)

f:SetScript("OnDragStart", function()
	f:StartMoving()
end)

f:SetScript("OnDragStop", function()
	f:StopMovingOrSizing();

	local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
	RaidCC_Config.p = point;
	RaidCC_Config.x = xOfs;
	RaidCC_Config.y = yOfs;
end)

local function UpdateTargets()
	if UnitExists("target") and GetRaidTargetIndex("target") ~= nil then
		targets[UnitGUID("target")] = GetRaidTargetIndex("target")
	elseif UnitExists("focus") and GetRaidTargetIndex("focus") ~= nil then
		targets[UnitGUID("focus")] = GetRaidTargetIndex("focus")
	elseif GetNumRaidMembers() > 0 then
		for i=1,GetNumRaidMembers(),1 do
			if UnitExists("raid"..i.."target") and GetRaidTargetIndex("raid"..i.."target") ~= nil then
				targets[UnitGUID("raid"..i.."target")] = GetRaidTargetIndex("raid"..i.."target")
			end

			if UnitExists("raid"..i.."focus") and GetRaidTargetIndex("raid"..i.."focus") ~= nil then
				targets[UnitGUID("raid"..i.."focus")] = GetRaidTargetIndex("raid"..i.."focus")
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i=1,GetNumPartyMembers(),1 do
			if UnitExists("party"..i.."target") and GetRaidTargetIndex("party"..i.."target") ~= nil then
				targets[UnitGUID("party"..i.."target")] = GetRaidTargetIndex("party"..i.."target")
			end

			if UnitExists("party"..i.."focus") and GetRaidTargetIndex("party"..i.."focus") ~= nil then
				targets[UnitGUID("party"..i.."focus")] = GetRaidTargetIndex("party"..i.."focus")
			end
		end
	end
end

local function CreateBar(i)
	local bar = _G["RaidCCBar"..i] or CreateFrame("Frame", "RaidCCBar"..i, UIParent)

	bar:SetWidth(barWidth)
	bar:SetHeight(barSize)

	if i == 1 then
		bar:SetPoint("TOP", f, "BOTTOM", 0, -2)
	else
		bar:SetPoint("TOP", _G["RaidCCBar"..(i-1)], "BOTTOM", 0, -2)
	end

	local txt = bar:CreateTexture(bar:GetName().."RaidIcon")
	txt:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
	txt:SetHeight(barSize)
	txt:SetWidth(barSize)

	local sb = CreateFrame("StatusBar", bar:GetName().."Status", bar)
        sb:SetMinMaxValues(0, 100)
        sb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        sb:GetStatusBarTexture():SetHorizTile(false)
        sb:SetStatusBarColor(0, 1, 0)
        sb:SetValue(0)
        sb:SetHeight(barSize)

        sb:SetPoint("TOPLEFT", bar, "TOPLEFT", barSize, 0)
        sb:SetPoint("BOtTOMRIGHT", bar, "BOTTOMRIGHt", 0, 0)

        local t = sb:CreateFontString(bar:GetName().."Name", "OVERLAY", "NumberFont_Outline_Med")
        t:SetJustifyH("LEFT")
        t:SetPoint("LEFT", sb, "LEFT", 2, 0)

        local t = sb:CreateFontString(bar:GetName().."TimeLeft", "OVERLAY", "NumberFont_Outline_Med")
        t:SetJustifyH("RIGHT")
        t:SetPoint("RIGHT", sb, "RIGHT", -2, 0)


	numBars = numBars + 1

	return bar
end

--[[
local warningFrame = CreateFrame("Frame", "RaidCCWarn", UIParent)
warningFrame:SetWidth(200)
warningFrame:SetHeight(50)
warningFrame:SetPoint("CENTER")
warningFrame:SetFrameStrata("FULLSCREEN") -- Ensure it's always on top

-- Create a text element
local warningText = warningFrame:CreateFontString(nil, "OVERLAY")
warningText:SetFontObject("GameFontNormal")
warningText:SetJustifyH("CENTER")
warningText:SetPoint("CENTER")
]]

local function OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then
		self:SetPoint(RaidCC_Config.p, UIParent, RaidCC_Config.p, RaidCC_Config.x, RaidCC_Config.y)

		if RaidCC_Config.lock == true then
			self:EnableMouse(false)
			self:SetMovable(false)
		else
			self:EnableMouse(true)
			self:SetMovable(true)
		end
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		UpdateTargets()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, subevent, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName = ...

		if subevent == "UNIT_DIED" then
			cc[dstGUID] = nil
			targets[dstGUID] = nil
		elseif subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
			if ( bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 or bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 or bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_RAID) > 0 ) then
				if spells[spellID] ~= nil then
					cc[dstGUID] = cc[dstGUID] or {}
					cc[dstGUID][spellID] = cc[dstGUID][spellID] or {}
					cc[dstGUID][spellID].casterName = srcName
					cc[dstGUID][spellID].spellName = spellName
					cc[dstGUID][spellID].startTime = GetTime()
					cc[dstGUID][spellID].endTime = GetTime() + spells[spellID]
				end
			end
		elseif subevent == "SPELL_AURA_REMOVED" or subevent == "SPELL_AURA_BROKEN" or subevent == "SPELL_AURA_BROKEN_SPELL" then
			if ( bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 or bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 or bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_RAID) > 0 ) then
				if spells[spellID] ~= nil then
					if cc[dstGUID] ~= nil and cc[dstGUID][spellID] ~= nil then
						local rti = ""
						if targets[dstGUID] ~= nil then
							rti = ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:16:16|t"):format(targets[dstGUID])
						end
						DEFAULT_CHAT_FRAME:AddMessage(("%s %s's %s is up %s"):format(rti, cc[dstGUID][spellID].casterName, cc[dstGUID][spellID].spellName, rti), 1, 0.5, 0, 1)
						cc[dstGUID][spellID] = nil
					end
				end
			end
		end
	end
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed

	if self.timer >= 0.1 then
		local i = 1

		for k,v in pairs(cc) do
			for a,b in pairs(v) do
				local duration = spells[a]
				local remain = b.endTime - GetTime()

				local bar = CreateBar(i)
				_G[bar:GetName().."Name"]:SetText(b.casterName)
				_G[bar:GetName().."TimeLeft"]:SetText(("%.1fs"):format(remain))
				_G[bar:GetName().."Status"]:SetMinMaxValues(0, duration)
				_G[bar:GetName().."Status"]:SetValue(b.endTime - GetTime())
				_G[bar:GetName().."RaidIcon"]:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..(targets[k] or 0))

				if remain / duration > 0.7 then
				        _G[bar:GetName().."Status"]:SetStatusBarColor(0, 1, 0)
				elseif remain / duration > 0.4 then
				        _G[bar:GetName().."Status"]:SetStatusBarColor(1, 1, 0)
				elseif remain / duration > 0.2 then
				        _G[bar:GetName().."Status"]:SetStatusBarColor(1, 0.5, 0)
				else
				        _G[bar:GetName().."Status"]:SetStatusBarColor(1, 0, 0)
				end
				bar:Show()
				i = i + 1
			end
		end

		if i < numBars then
			for z=i,numBars,1 do
				local bar = _G["RaidCCBar"..z] or nil
				if bar then
					bar:Hide()
				end
			end
		end
		self.timer = 0
	end
end

local function RaidCC_Toggle()
	if RaidCC_Config.lock == true then
		RaidCC_Config.lock = false
		--f:Show()
		f:EnableMouse(true)
		f:SetMovable(true)
	else
		RaidCC_Config.lock = true
		--f:Hide()
		f:EnableMouse(false)
		f:SetMovable(false)
	end
end

local function SlashCmd(...)
	--local cmd, params = string.split(" ", string.lower(...), 2)
	RaidCC_Toggle()
end

SLASH_RAIDCC1 = "/rcc"
SLASH_RAIDCC2 = "/raidcc"
SlashCmdList["RAIDCC"] = SlashCmd

f:RegisterEvent("RAID_TARGET_UPDATE")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("VARIABLES_LOADED")

f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", OnUpdate)
