local Img_rankBg = self:GetChildByName('Img_rankBg')
local Txt_bestTime = self:GetChildByName('Txt_bestTime')
local Btn_close = self:GetChildByName('Btn_close')
local Txt_time = self:GetChildByName('Txt_time')
local Txt_name = self:GetChildByName('Txt_name')
local Btn_rank = self:GetChildByName('Btn_rank')
local Txt_countdown = self:GetChildByName('Txt_countdown')
local Img_countdownBg = self:GetChildByName('Img_countdownBg')
local VL_rank = self:GetChildByName('VL_rank')
local Txt_rank = self:GetChildByName('Txt_rank')
local Img_logo = self:GetChildByName('Img_logo')
local DW_rankLine = Img_rankBg:GetChildByName('DW_rankLine'):Clone()

--zero-fill the single-digit time unit
local function ZeroFill(timeInfo)
  for index, v in pairs(timeInfo) do
    timeInfo[index] = v > 9 and v or ("0" .. v)
  end
end

--Remove illegal characters from names
local function CullIllegalChar(name)
  local tempName = ''
  local array = Lib.splitString(name, "#")
  for _, line in pairs(array) do
    local arr = Lib.splitString(line, ":")
    for _, word in pairs(arr) do
      tempName = tempName .. word
    end
  end
  return tempName
end

--convert time to characters
local function ConversionTime(time)
  if not time or tonumber(time) == -1 then
    return
  end
  local timeInfo = {}
  timeInfo.Minute = math.floor(time / 1200)
  timeInfo.Second = math.floor(time / 20) % 60
  timeInfo.Millisecond = (time % 20) * 5
  ZeroFill(timeInfo)
  return timeInfo.Minute .. ":" .. timeInfo.Second .. ":" .. timeInfo.Millisecond
end

local function InitText()
  Txt_time.Text = Lang:toText('LangKey_time')
  Txt_name.Text = Lang:toText('LangKey_name')
  Txt_rank.Text = Lang:toText('LangKey_ranking')
  Img_logo.Txt_info.Text = Lang:toText('LangKey_rankTitle')
  Btn_close.Txt_info.Text = Lang:toText('LangKey_close')
  Btn_rank.Txt_info.Text = Lang:toText('LangKey_rankTitle')
end

--Refresh leaderboard display
function self:RefreshRankInfo(data)
  Img_rankBg.Visible = true
  VL_rank:DestroyAllChildren()

  for i = 1, 10 do
    local rankData = data[i] or {}
    local newRank = DW_rankLine:Clone()
    newRank.Txt_rankLineIndex.Text = i
    newRank.Txt_rankLineName.Text = rankData.Name or '---'
    newRank.Txt_rankLineTime.Text = ConversionTime(rankData.Time) or '---'

    --Current player information highlighted
    if rankData.Name == CullIllegalChar(Me.name) then
      newRank.Img_rankLineBg.Visible = true
      newRank.Txt_rankLineName.TextColor = Color3.new(0, 1, 1)
      newRank.Txt_rankLineTime.TextColor = Color3.new(0, 1, 1)
    end

    if i <= 3 then
      newRank.Img_rankLineLogo.Visible = true
      newRank.Img_rankLineLogo.Image = string.format("gameres|asset/file/ui/%s.png",i)
      newRank.Txt_rankLineIndex.Text = ''
    end
    VL_rank:AddChild(newRank)
  end
  local myBestTime = ConversionTime(Me:getValue('time'))
  Txt_bestTime.Text = Lang:toText('LangKey_bestTime') .. ' : ' .. (myBestTime or '')
end

local event = Btn_rank:GetEvent("OnClick")
event:Bind(function()
  Btn_rank.Visible = false
  PackageHandlers:SendToServer("RequireRankData")
end)

local event = Btn_close:GetEvent("OnClick")
event:Bind(function()
  Btn_rank.Visible = true
  Img_rankBg.Visible = false
end)

function self:RefreshTimer(timeInfo)
  Img_countdownBg.Visible = true
  ZeroFill(timeInfo)
  Txt_countdown.Text = timeInfo.Minute .. ":" .. timeInfo.Second .. ":" .. timeInfo.Millisecond
end

PackageHandlers:Receive("CountdownHandler", function(player, timeInfo)
  self:RefreshTimer(timeInfo)
end)

PackageHandlers:Receive("ShowRankUI", function(player, packet)
  self:RefreshRankInfo(packet)
end)

InitText()