--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 12/11/15
-- Time: 17:24
-- To change this template use File | Settings | File Templates.
--

local _M = {};

_M.uuid = function ()
    -- local template ="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    local template ="xxxxxxxxxxxxxxxxxx";
    local len = 19;

    local d = io.open("/dev/urandom", "r"):read(4);

    math.randomseed(os.time() + d:byte(1) + (d:byte(2) * 256) + (d:byte(3) * 65536) + (d:byte(4) * 4294967296));

    local returnStr = string.gsub(template, "x", function (c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb);
        -- return string.format("%x", v);
        return v;
    end);
    returnStr = "3" .. returnStr;

    return string.sub(returnStr, 0, len);
end

return _M;