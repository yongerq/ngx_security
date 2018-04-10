local redisConfig=require "redisConfig";
local json=require "dkjson";
local config=ngx.shared.config;
--local ruleConfig=ngx.shared.ruleConfig;

local redisConfigString=json.encode(redisConfig);

-- set redis conf
config:set("redisConfig", redisConfigString);
config:set("initSign", 0);

-- for test
config:set("init", 0);