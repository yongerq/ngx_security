local redis = require "redis";
-- local ngx = ngx;

local config = ngx.shared.config;
local init = config:get("init");

--因为该例子使用递归，所以要提前定义handler变量
local handler;

-- ngx.log(ngx.ERR, "init:" .. init .. ' type(init):' .. type(init));

--第一个参数为premature
function handler(premature, params)
    local red = redis:new();

    red:connect("10.17.1.61", "6379", {pool = "my_redis_pool"});
    red:select(3);
    red:set('aaa', ngx.now());

    ngx.log(ngx.ERR, "ngx.timer.at:", ngx.now());

    --递归
    local ok, err = ngx.timer.at(5, handler, params)
    -- ngx.log(ngx.DEBUG, "ok:", ok, " err:", err)
end

if (0 == init) then
    --每隔5s进行一次处理, 每次请求都是独立的, 请求10次就会调用10次ngx.timer.at函数
    local ok, err = ngx.timer.at(5, handler, "params-data");
    ngx.log(ngx.ERR, "ok:", ok, " err:", err);
    if not ok then
        ngx.log(ngx.ERR, "err:", err);
    else
        ngx.log(ngx.ERR, "in else");

        ngx.log(ngx.ERR, "before set init:" .. config:get("init"));

        local succ, err, forcible = config:set("init", 1);

        ngx.log(ngx.ERR, "config:set result, succ:" .. tostring(succ) .. " err:" .. (err or 'nil') .. " forcible:" .. tostring(forcible));
        ngx.log(ngx.ERR, "after set init:" .. config:get("init"));
    end
end