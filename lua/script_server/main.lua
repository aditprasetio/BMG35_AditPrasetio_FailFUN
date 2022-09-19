print('script_server:hello world')
require "script_server.calcTime"
local BestTimeRankService = Engine.DataService:GetRankDataStore("BestTime")

local function PartFalsh(part)
    part.IsFlash = true
    local intervalTime = 10
    local interval = 1 / -intervalTime
    local timer
    timer = Timer.new(1, function()
        if part:IsValid() then
            local alpha = part.Transparency
            alpha = alpha + interval
            if alpha >= 1 then
                part.Transparency = 1
                part.CanCollide = true
                part.IsFlash = false
                timer.Loop = false
            elseif alpha <= 0 then
                part.Transparency = 0
                interval = 1 / 30
                part.CanCollide = false
            end

            part.Transparency = alpha
        end
    end)
    timer.Loop = true
    timer:Start()
end

--Remove illegal characters from names
local function CullIllegalChar(name)
    local tempName = ''
    local array = Lib.splitString(name, "#")
    for _, line in pairs(array) do
        local arr = Lib.splitString(line, ":")
        for _, word in pairs(arr) do
            tempName = tempName..word
        end
    end
    return tempName
end

local touchFunc = {}
--Part function that fades after touch
function touchFunc.Flash(part)
    if not part.IsFlash then
        PartFalsh(part)
    end
end

--Touch the start part to trigger the function
function touchFunc.StartTimer(part, player)
    local startTime = player:data('startTime')

    if not (type(startTime) == 'number') then
        player:setData('startTime', World.Now())
    end
end

--Touch the end part to trigger the function
function touchFunc.Destination(part, player)
    local startTime = player:data('startTime')
    if (type(startTime) == 'number') then
        local time = World.Now() - startTime
        local oldTime = player:getValue('time')
        if oldTime == 0 or (oldTime > 0 and time < oldTime) then
            player:setValue('time', time)
            local name = CullIllegalChar(player.name)
            if name == '' then
                player:sendTip(1, "Txt_illegal_name", 120)
            else
                --Use negative numbers to sort in reverse order
                BestTimeRankService:SetData(name, -time)
            end
        end
        player:setData('startTime', nil)
    end
end

local cfg = Entity.GetCfg("myplugin/player1")

--touch event with part
Trigger.addHandler(cfg, "ENTITY_TOUCH_PART_BEGIN", function(context)
    local player = context.obj1
    local part = context.part
    local partName = part.name
    --Trigger different functions based on part name
    if touchFunc[partName] then
        touchFunc[partName](part, player)
    end
end)


PackageHandlers:Receive("RequireRankData", function(player, packet)
    BestTimeRankService:RequestRangeData(1, 10, function(dataList)
        if player and player:isValid() then
            local rankList = {}
            for i, list in ipairs(dataList) do
                table.insert(rankList,{Name = list.key,Time = -list.value})  --convert to positive
            end
            PackageHandlers:SendToClient(player, 'ShowRankUI', rankList)
        end
    end)
end)


