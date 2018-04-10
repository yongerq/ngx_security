--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 1/12/16
-- Time: 20:06
-- To change this template use File | Settings | File Templates.
--

local array = require "array";

local _M = {};

function _M.getAppType(userAgent)
    if (not userAgent or '' == userAgent) then
        return nil;
    end

    local appType = string.match(userAgent, "appType%((.-)%)");

    return appType;
end

function _M.getAppVersion(userAgent)
    if (not userAgent or '' == userAgent) then
        return nil;
    end

    local appVersion = string.match(userAgent, "appVersion%((.-)%)");

    return appVersion;
end

--[[
-- @return int
--      1  - source 大于 dest
--      0  - source 等于 dest
--      -1 - source 小于 dest
--]]
function _M.compareVersion(sourceVer, destVer)
    if (nil == sourceVer or '' == sourceVer) then
        return -1;
    end

    if (nil == destVer or '' == destVer) then
        return 1;
    end

    if (sourceVer == destVer) then
        return 0;
    end

    local sources = array.split(sourceVer, '%.');
    local dests = array.split(destVer, '%.');

    for key,val1 in pairs(sources) do
        local destData = dests[key] or 0;
        val1 = val1 or 0;

        destData = tonumber(destData) or 0;
        val1 = tonumber(val1) or 0;

        if (val1 > destData) then
            return 1;
        end

        if (val1 < destData) then
            return -1;
        end
    end

    return 0;
end

return _M;

