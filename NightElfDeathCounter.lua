local ADDON_NAME = ...
local NEDC = {}
_G.NEDC = NEDC

-- -----------------------------
-- Saved Vars (defaults)
-- -----------------------------
local defaults = {
  count = 0,
  locked = false,
  sound = true,
  scale = 1.0,
  alpha = 1.0,
  cuteMessages = true,
}

-- Utility: table copy
local function tblcopy(src)
  local t = {}
  for k,v in pairs(src) do t[k] = v end
  return t
end

-- -----------------------------
-- Create Frame (UI)
-- -----------------------------
local backdrop = {
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local function createUI()
  local f = CreateFrame("Frame", "NEDC_Frame", UIParent, "BackdropTemplate")
  f:SetSize(140, 54)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
  f:SetBackdrop(backdrop)
  f:SetBackdropColor(0.09, 0.05, 0.18, 0.7) -- deep night-elf purple bg
  f:SetBackdropBorderColor(0.6, 0.5, 1.0, 0.8)

  -- Make it movable
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self)
    if not NEDC_DB.locked then self:StartMoving() end
  end)
  f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

  -- Soft moon glow
  local glow = f:CreateTexture(nil, "BACKGROUND")
  glow:SetTexture("Interface\\Cooldown\\star4")
  glow:SetPoint("CENTER", f, "LEFT", 12, 0)
  glow:SetSize(56, 56)
  glow:SetVertexColor(0.85, 0.85, 1.0, 0.45)

  local glowAG = glow:CreateAnimationGroup()
  local a1 = glowAG:CreateAnimation("Alpha")
  a1:SetFromAlpha(0.2); a1:SetToAlpha(0.6); a1:SetDuration(1.4)
  a1:SetOrder(1)
  local a2 = glowAG:CreateAnimation("Alpha")
  a2:SetFromAlpha(0.6); a2:SetToAlpha(0.2); a2:SetDuration(1.4)
  a2:SetOrder(2)
  glowAG:SetLooping("REPEAT")
  glowAG:Play()

  -- Moon icon (Night Elf-ish)
  local icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetTexture("Interface\\Icons\\inv_misc_moonstone_01")
  icon:SetPoint("LEFT", f, "LEFT", 6, 0)
  icon:SetSize(32, 32)

  -- Title
  local title = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, 6)
  title:SetTextColor(0.85, 0.9, 1.0, 0.95)
  title:SetText("Night Elf Deaths")

  -- Big number
  local num = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
  num:SetPoint("LEFT", icon, "RIGHT", 8, -2)
  num:SetTextColor(0.9, 0.8, 1.0, 1.0)
  num:SetText("0")
  num:SetJustifyH("LEFT")

  -- Subtitle (cute)
  local sub = f:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
  sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
  sub:SetTextColor(0.8, 0.75, 1.0, 0.9)
  sub:SetText("“Fallen, not forgotten.”")

  -- Cute blink when you die
  local pulseAG = f:CreateAnimationGroup()
  local p1 = pulseAG:CreateAnimation("Scale")
  p1:SetFromScale(1,1); p1:SetToScale(1.08,1.08); p1:SetDuration(0.09); p1:SetOrder(1)
  local p2 = pulseAG:CreateAnimation("Scale")
  p2:SetFromScale(1.08,1.08); p2:SetToScale(1,1); p2:SetDuration(0.12); p2:SetOrder(2)

  f._num = num
  f._pulse = pulseAG
  f._title = title
  f._subtitle = sub
  f._icon = icon
  f._glow = glow
  return f
end

-- -----------------------------
-- Core
-- -----------------------------
local frame = createUI()

local function updateNumber()
  frame._num:SetText(NEDC_DB.count or 0)
end

local cuteLines = {
  "Another spirit run? I like a girl who’s persistent. 💜",
  "You fall with such grace. 10/10 swan dive.",
  "Elune forgives. Your repair bill won’t. 😘",
  "Death becomes you… but maybe try less of it?",
  "One step closer to immortality speedrun.",
}

local function saySomethingCute()
  if not NEDC_DB.cuteMessages then return end
  local i = math.random(#cuteLines)
  print("|cffbfaaffNEDC:|r "..cuteLines[i])
end

local function celebrate()
  frame._pulse:Stop()
  frame._pulse:Play()
  if NEDC_DB.sound then
    -- Soft UI sound that won't blow ears off
    if PlaySound then
      PlaySound(SOUNDKIT.UI_LOOT_TOAST_SHOW or 515, "SFX")
    end
  end
end

-- Slash commands
SLASH_NEDC1 = "/nedc"
SlashCmdList["NEDC"] = function(msg)
  msg = string.lower(msg or "")
  if msg == "reset" then
    NEDC_DB.count = 0
    updateNumber()
    print("|cffbfaaffNEDC:|r counter reset. Fresh as moonlight.")
  elseif msg == "lock" then
    NEDC_DB.locked = true
    print("|cffbfaaffNEDC:|r frame locked.")
  elseif msg == "unlock" then
    NEDC_DB.locked = false
    print("|cffbfaaffNEDC:|r frame unlocked. Drag me, darling.")
  elseif msg == "hide" then
    frame:Hide()
    print("|cffbfaaffNEDC:|r hidden. Use |cffffff00/nedc show|r to bring me back.")
  elseif msg == "show" then
    frame:Show()
  elseif msg:match("^scale%s+[%d%.]+$") then
    local s = tonumber(msg:match("scale%s+([%d%.]+)"))
    if s and s >= 0.6 and s <= 2.0 then
      NEDC_DB.scale = s
      frame:SetScale(s)
      print("|cffbfaaffNEDC:|r scale set to "..s)
    else
      print("|cffbfaaffNEDC:|r scale must be between 0.6 and 2.0")
    end
  elseif msg == "sound on" then
    NEDC_DB.sound = true; print("|cffbfaaffNEDC:|r sound enabled.")
  elseif msg == "sound off" then
    NEDC_DB.sound = false; print("|cffbfaaffNEDC:|r sound disabled.")
  elseif msg == "cute on" then
    NEDC_DB.cuteMessages = true; print("|cffbfaaffNEDC:|r cute messages enabled.")
  elseif msg == "cute off" then
    NEDC_DB.cuteMessages = false; print("|cffbfaaffNEDC:|r cute messages disabled.")
  else
    print("|cffbfaaffNEDC usage:|r /nedc reset | lock | unlock | show | hide | sound on/off | cute on/off | scale <0.6-2.0>")
  end
end

-- Events
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_DEAD")

events:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
    if type(NEDC_DB) ~= "table" then
      NEDC_DB = tblcopy(defaults)
    else
      -- ensure defaults exist if new version adds keys
      for k,v in pairs(defaults) do
        if NEDC_DB[k] == nil then NEDC_DB[k] = v end
      end
    end
    frame:SetScale(NEDC_DB.scale or 1.0)
    frame:SetAlpha(NEDC_DB.alpha or 1.0)
    updateNumber()
  elseif event == "PLAYER_DEAD" then
    NEDC_DB.count = (NEDC_DB.count or 0) + 1
    updateNumber()
    celebrate()
    saySomethingCute()
  end
end)
