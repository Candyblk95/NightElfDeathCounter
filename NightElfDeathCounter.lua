local ADDON = ...

-- ============================================================
-- Saved Vars
-- ============================================================
NightElfDeathsDB = NightElfDeathsDB or {}
local function Defaults()
  return {
    count = 0,
    shown = true,
    locked = false,
    label = "Night Elf Deaths",
    quote = "Fallen, not forgotten.",
    point = "CENTER", relPoint = "CENTER", x = 0, y = 0,
    scale = 1.0,

    -- Background (your art)
    width = 512, height = 400,  -- current frame size
    texW  = 512, texH   = 400,  -- native image size (aspect used for width/height commands)

    -- Layout (tuned for your card art)
    titleX = 48,   titleY = -106, -- title aligned with moon
    countX = 28,   countY =   0,  -- big zero centered-ish
    quoteX =  0,   quoteY = 120,  -- quote perfectly centered & tucked up

    -- Fonts
    titleSize = 28,
    countSize = 120,
    quoteSize = 18,
  }
end
local function Merge(db, def) for k,v in pairs(def) do if db[k]==nil then db[k]=v end end end

-- ============================================================
-- Helpers (aspect-safe sizing)
-- ============================================================
local function round(n) return math.floor(n + 0.5) end
local function HeightForWidth(w)
  return round(w * (NightElfDeathsDB.texH / NightElfDeathsDB.texW))
end
local function WidthForHeight(h)
  return round(h * (NightElfDeathsDB.texW / NightElfDeathsDB.texH))
end
local function FitToNative()
  NightElfDeathsDB.width  = NightElfDeathsDB.texW
  NightElfDeathsDB.height = NightElfDeathsDB.texH
end

-- ============================================================
-- Frame (skinned by your TGA)
-- ============================================================
local f = CreateFrame("Frame", "NightElfDeathsFrame", UIParent)
f:SetSize(512, 400)
f:SetPoint("CENTER")
f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", function(self) if not NightElfDeathsDB.locked then self:StartMoving() end end)
f:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local p,_,rp,x,y = self:GetPoint()
  NightElfDeathsDB.point, NightElfDeathsDB.relPoint, NightElfDeathsDB.x, NightElfDeathsDB.y = p, rp, x, y
end)

-- Background texture (Interface/AddOns/<AddonFolder>/NEDC.tga)
local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
local function ApplyTexture()
  bg:SetTexture(("Interface\\AddOns\\%s\\NEDC"):format(ADDON)) -- no .tga in code
  bg:SetTexCoord(0,1,0,1)
end
ApplyTexture()

-- ============================================================
-- Fonts (uses game font; no external files)
-- ============================================================
local base = select(1, GameFontNormal:GetFont())
local TitleFont = CreateFont("NED_TitleFont")
local CountFont = CreateFont("NED_CountFont")
local QuoteFont = CreateFont("NED_QuoteFont")

local function ApplyFonts()
  TitleFont:SetFont(base, NightElfDeathsDB.titleSize or 28, "OUTLINE")
  TitleFont:SetShadowColor(0,0,0,1); TitleFont:SetShadowOffset(1,-1)

  CountFont:SetFont(base, NightElfDeathsDB.countSize or 120, "OUTLINE")
  CountFont:SetShadowColor(0,0,0,1); CountFont:SetShadowOffset(2,-2)

  QuoteFont:SetFont(base, NightElfDeathsDB.quoteSize or 18, "")
  QuoteFont:SetShadowColor(0,0,0,1); QuoteFont:SetShadowOffset(1,-1)
end
ApplyFonts()

-- ============================================================
-- Text
-- ============================================================
local title = f:CreateFontString(nil, "OVERLAY")
title:SetFontObject(TitleFont)
title:SetTextColor(0.96, 0.90, 1.00)

local countText = f:CreateFontString(nil, "OVERLAY")
countText:SetFontObject(CountFont)
countText:SetTextColor(0.97, 0.92, 1.00)

local quote = f:CreateFontString(nil, "OVERLAY")
quote:SetFontObject(QuoteFont)
quote:SetTextColor(0.96, 0.86, 1.00)

local function LayoutText()
  title:ClearAllPoints()
  title:SetPoint("TOP",    NightElfDeathsDB.titleX or 48,   NightElfDeathsDB.titleY or -106)
  countText:ClearAllPoints()
  countText:SetPoint("CENTER", NightElfDeathsDB.countX or 28, NightElfDeathsDB.countY or 0)
  quote:ClearAllPoints()
  quote:SetPoint("BOTTOM", NightElfDeathsDB.quoteX or 0,     NightElfDeathsDB.quoteY or 120) -- centered horizontally
end

-- Tooltip hint
f:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_TOP")
  GameTooltip:AddLine("/ned for options", 1,1,1)
  GameTooltip:Show()
end)
f:SetScript("OnLeave", function() GameTooltip:Hide() end)

local function Refresh()
  title:SetText(NightElfDeathsDB.label)
  countText:SetText(tostring(NightElfDeathsDB.count))
  quote:SetText(("\"%s\""):format(NightElfDeathsDB.quote))

  f:ClearAllPoints()
  f:SetPoint(NightElfDeathsDB.point, UIParent, NightElfDeathsDB.relPoint, NightElfDeathsDB.x, NightElfDeathsDB.y)
  f:SetScale(NightElfDeathsDB.scale or 1)
  f:SetSize(NightElfDeathsDB.width or 512, NightElfDeathsDB.height or 400)

  ApplyFonts()
  LayoutText()
  if NightElfDeathsDB.shown then f:Show() else f:Hide() end
end

-- ============================================================
-- Events
-- ============================================================
local e = CreateFrame("Frame")
e:RegisterEvent("ADDON_LOADED")
e:RegisterEvent("PLAYER_DEAD")
e:SetScript("OnEvent", function(_, ev, arg1)
  if ev == "ADDON_LOADED" and arg1 == ADDON then
    Merge(NightElfDeathsDB, Defaults())
    Refresh()
  elseif ev == "PLAYER_DEAD" then
    local race = select(2, UnitRace("player"))
    if race == "NightElf" then
      NightElfDeathsDB.count = (NightElfDeathsDB.count or 0) + 1
      Refresh()
    end
  end
end)

-- ============================================================
-- Slash Commands
-- ============================================================
SLASH_NIGHTELFDEATHS1 = "/ned"
SlashCmdList["NIGHTELFDEATHS"] = function(msg)
  msg = (msg and msg:lower() or ""):gsub("^%s+","")

  if msg == "show" then NightElfDeathsDB.shown = true; Refresh()
  elseif msg == "hide" then NightElfDeathsDB.shown = false; Refresh()
  elseif msg == "lock" then NightElfDeathsDB.locked = true; print("|cffcba0ffNED|r locked.")
  elseif msg == "unlock" then NightElfDeathsDB.locked = false; print("|cffcba0ffNED|r unlocked (drag to move).")
  elseif msg == "reset" then NightElfDeathsDB.count = 0; Refresh()
  elseif msg:match("^set%s+%d+$") then NightElfDeathsDB.count = tonumber(msg:match("%d+")) or 0; Refresh()

  elseif msg:match("^label%s+.+") then NightElfDeathsDB.label = msg:match("^label%s+(.+)"); Refresh()
  elseif msg:match("^quote%s+.+") then NightElfDeathsDB.quote = msg:match("^quote%s+(.+)"); Refresh()

  elseif msg:match("^scale%s+[%d%.]+$") then
    local s = tonumber(msg:match("([%d%.]+)")) or 1
    NightElfDeathsDB.scale = math.max(0.5, math.min(2.0, s)); Refresh()

  -- Keep aspect automatically:
  elseif msg:match("^width%s+%d+$") then
    local w = tonumber(msg:match("%d+"))
    NightElfDeathsDB.width  = w
    NightElfDeathsDB.height = HeightForWidth(w)
    Refresh()
    print(string.format("|cffcba0ffNED|r size %dx%d (kept aspect).", NightElfDeathsDB.width, NightElfDeathsDB.height))

  elseif msg:match("^height%s+%d+$") then
    local h = tonumber(msg:match("%d+"))
    NightElfDeathsDB.height = h
    NightElfDeathsDB.width  = WidthForHeight(h)
    Refresh()
    print(string.format("|cffcba0ffNED|r size %dx%d (kept aspect).", NightElfDeathsDB.width, NightElfDeathsDB.height))

  elseif msg == "fit" then
    FitToNative(); Refresh()
    print(string.format("|cffcba0ffNED|r fit to native %dx%d.", NightElfDeathsDB.width, NightElfDeathsDB.height))

  elseif msg:match("^ratio%s+%d+:%d+$") then
    local w,h = msg:match("^ratio%s+(%d+):(%d+)$")
    NightElfDeathsDB.texW, NightElfDeathsDB.texH = tonumber(w), tonumber(h)
    print(string.format("|cffcba0ffNED|r native ratio set to %s:%s.", w, h))

  -- Manual size (will stretch if not matching aspect)
  elseif msg:match("^size%s+%d+x%d+$") then
    local w,h = msg:match("^size%s+(%d+)x(%d+)$")
    NightElfDeathsDB.width, NightElfDeathsDB.height = tonumber(w), tonumber(h)
    Refresh()
    print(string.format("|cffcba0ffNED|r size %sx%s (may stretch).", w, h))

  -- Position & font tweaks
  elseif msg:match("^pos%s+(title|count|quote)%s+[-%d]+%s+[-%d]+$") then
    local which, x, y = msg:match("^pos%s+(title|count|quote)%s+([-%d]+)%s+([-%d]+)$")
    x, y = tonumber(x), tonumber(y)
    if which == "title" then NightElfDeathsDB.titleX, NightElfDeathsDB.titleY = x, y
    elseif which == "count" then NightElfDeathsDB.countX, NightElfDeathsDB.countY = x, y
    elseif which == "quote" then NightElfDeathsDB.quoteX, NightElfDeathsDB.quoteY = x, y end
    Refresh()
    print(string.format("|cffcba0ffNED|r %s pos x=%d, y=%d", which, x, y))

  elseif msg:match("^font%s+(title|count|quote)%s+%d+$") then
    local which, sz = msg:match("^font%s+(title|count|quote)%s+(%d+)$")
    sz = tonumber(sz)
    if which == "title" then NightElfDeathsDB.titleSize = sz
    elseif which == "count" then NightElfDeathsDB.countSize = sz
    elseif which == "quote" then NightElfDeathsDB.quoteSize = sz end
    ApplyFonts(); LayoutText()
    print(string.format("|cffcba0ffNED|r %s font %d", which, sz))

  elseif msg == "tex" then
    ApplyTexture(); print("|cffcba0ffNED|r texture reapplied. (New files require one full client restart.)")

  else
    print("|cffcba0ffNight Elf Deaths|r commands:")
    print("  /ned show|hide|lock|unlock|reset|set N")
    print("  /ned label <text>   /ned quote <text>")
    print("  /ned scale <0.5–2.0>")
    print("  /ned width <W>   /ned height <H>   /ned fit   /ned ratio W:H")
    print("  /ned size <W>x<H> (stretches)   /ned tex")
    print("  /ned pos <title|count|quote> <x> <y>   /ned font <title|count|quote> <size>")
  end
end
