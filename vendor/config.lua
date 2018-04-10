--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 11/26/15
-- Time: 21:03
-- To change this template use File | Settings | File Templates.
--

local dkjson = require "dkjson";

local _M = {};

function _M.load(file)
    local config = {};

    local file = io.open(file, "r");
    local content = dkjson.decode(file:read("*a"));

    file:close();

    for name, value in pairs(content) do
        config[name] = value;
    end

    return content;
end

return _M;
