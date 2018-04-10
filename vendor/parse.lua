local _M = {};
local array = require("array");

function _M.getData(key, type)
    local action = {
        ["header"] = function(x) return ngx.req.get_headers()[x] or ''; end,
        ["var"] = function(x) return ngx.var[x] or ''; end,
        ["req"] = function(x) return ngx.req[x] or ''; end,
    };

    return action[type](key);
end

function _M.match(data, pattern, mode)
    local action = {
        ["pattern"] = function(data, pattern) return nil ~= string.find(data, pattern); end,
        ["full"] = function(data, pattern) return data == pattern; end,
        ["in"] = function(data, pattern) local items=array.split(pattern, ","); return in_array(items, data); end,
    };

    return action[mode](data, pattern);
end

--[[
-- 黑名单策略数据

    - type - 值来源
        - header - head
        - var - 入参
        - req - 请求参数
    - mode - 匹配规则
        - full - 全量匹配 - 默认
        - pattern - 正则匹配
        - in - 范围匹配
    - pattern - 匹配规则, 为空时不做匹配验证

-- return
    - true - 规则匹配
    - false - 规则不匹配
--]]
function _M.check(rule)
    if not rule or nil == rule then
        return false;
    end

    for key, value in pairs(rule) do
        repeat
            -- local key = value['key'] or '';
            local type = value['type'] or "header";
            local mode = value['mode'] or "full";
            local pattern = value['pattern'] or "";

            if not pattern or '' == pattern or nil == pattern then
                break;
            end

            ngx.log(ngx.DEBUG, 'In check func, pattern:' .. tostring(pattern) .. ' mode:' .. tostring(mode) .. ' type:' .. type .. ' key:' .. key);

            local data = _M.getData(key, type);

            ngx.log(ngx.DEBUG, 'In check func, data:' .. tostring(data) .. ' pattern:' .. tostring(pattern) .. ' mode:' .. tostring(mode));

            local check = _M.match(data, pattern, mode);

            -- 没有匹配规则, 直接返回 - false
            if not check then
                return false;
            end
            break;
        until true;
    end

    return true;
end

return _M;