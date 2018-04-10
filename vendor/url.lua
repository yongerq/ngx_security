--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 11/26/15
-- Time: 12:00
-- To change this template use File | Settings | File Templates.
--

local _M = {};

-- url encode
function _M.urlEncode(s)
    s = string.gsub(s, "([^%w%.%-_ ])", function(c) return string.format("%%%02X", string.byte(c)) end);

    return string.gsub(s, " ", "+");
end

-- url decode
function _M.urlDecode(s)
    if ('' == s) then
        return s;
    end

    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end);

    return s;
end

return _M;

