--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 2/22/16
-- Time: 11:50
-- To change this template use File | Settings | File Templates.
--

local _M = {};

_M.dayAdd = function (addDays)
    local currentTime = os.time();

    if nil == tonumber(addDays) then
        return os.date("%Y-%m-%d %H:%M:%S", currentTime);
    end

    local addTimes = addDays * 24 * 60 * 60;
    local toTime = currentTime + addTimes;

    return os.date("%Y-%m-%d %H:%M:%S", toTime);
end
