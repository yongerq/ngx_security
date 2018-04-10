--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 12/9/15
-- Time: 00:25
-- To change this template use File | Settings | File Templates.
--

local _M = {};

--[[

-- ge,gt,le,lt,eq,neq

请求频率限制: {"key": ["remote_addr"], "pattern":{"remote_addr":"^/member/"}, "limit":5, "mode":1, "method":"ge"}

- key - 限制的 header 数据，为数组类型。key的值可配置。如: "key" :["remote_addr", "user_agent"]
- value - 限制阀值。key-value类型。value的值根据key的值一一对应。"value" : {"remote_addr":"5"}
- limit - 限制数量,
- mode - 限制单位 1 - 秒, 2 - 分
- method - 判断方法
    - ge - >=
    - gt - >
    - le - <=
    - lt - <
    - eq - =
    - neq - !=
--]]

_M.filter = function (rules)
    ngx.log(ngx.DEBUG, "In rateFilter func.");

    if (not rules or nil == next(rules)) then
        ngx.log(ngx.DEBUG, 'In if');
    end
end

return _M;