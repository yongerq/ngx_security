local securityConfig = require("securityConfig");
local redis=require("redis");
local redisConfig=require("redisConfig");
local json = require("dkjson");

local config = ngx.shared.config;
local ruleConfig = ngx.shared.ruleConfig;

-- 规则分别获取
local rateRule = ruleConfig.rate or "{}";
local blackRule = ruleConfig.black or "{}";

-- json to table
local rateRules = json.decode(rateRule);
local blackRules = json.decode(blackRule);
local rules = {
    rate=rateRules,
    black=blackRules,
};

-- redis 配置获取
local redisConfigIp = redisConfig.ip or "10.17.1.61";
local redisConfigPort = redisConfig.port or "6379";
local redisConfigPool = redisConfig.pool or "redis_security";
local redisConfigDB = redisConfig.db or 6;

local types = securityConfig.types;

local initSign = config:get("initSign") or 0;
local handler;

-- 后台拉取数据方法
function handler(premature)
    local redisHandle = redis:new();

    redisHandle:connect(redisConfigIp, redisConfigPort, {pool = redisConfigPool});
    redisHandle:select(redisConfigDB);

    ruleConfig.rate = json.encode(redisHandle:get("rate"));
    ruleConfig.black = json.encode(redisHandle:get("black"));

    -- 递归
    local ok, err = ngx.timer.at(5, handler)
    if not ok then
        ngx.log(ngx.ERR, "Failed to create the timer: ", err);
        return;
    end
end

if 0 == initSign then
    local ok, err = ngx.timer.at(5, handler);
    if not ok then
        ngx.log(ngx.ERR, "Failed to create the timer: ", err);
        return;
    end

    config:set("initSign", 1);
end

for _, value in pairs(types) do
    local filterName = value .. "Filter";
    local handle = require(filterName);

    local filterConfigName = value .. "Config";
    local filterConfig = require(filterConfigName);

    handle.filter(rules, filterConfig);
end