
--Calculate the time spent by the player
local function CalcSpendTime()
  local now =  World.Now()
  for id, player in pairs(Game.GetAllPlayers()) do
    local startTime = player:data('startTime')
    if type(startTime)=='number' and startTime >=1 then
      local timeInfo = {}
      local totalTime = now - startTime
      timeInfo.Minute = math.floor(totalTime/1200)
      timeInfo.Second = math.floor(totalTime/20) % 60
      timeInfo.Millisecond = (totalTime%20) *5
      PackageHandlers:SendToClient(player, 'CountdownHandler', timeInfo)
    end
  end
end

local timer =  Timer.new(1,function()
    CalcSpendTime()
  end)
timer.Loop = true
timer:Start()