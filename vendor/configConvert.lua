--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 12/9/15
-- Time: 20:52
-- To change this template use File | Settings | File Templates.
--

local array = require "array";

local _M = {};

--[[
 --- 转换前配置
黑名单策略数据

请求 ip 限制:

        json/application
         {
           "status": true,
           "message": "success",
           "responseCode": 1000,
           "entry": [
             {
               "id": 4,
               "type": "21111",
               "key": "sss",
               "value": "sss"
             }
           ]
         }

[
    {"id":1,"type": "black", "key" : ["remote_addr","user_agent"], "value" : {"remote_addr":"192.168.1.100", "user_agent":"Mozila"},
    {},
    {}
]

type - 策略类型
key - 限制的 header 数据,key的值可配置，如: key 值为："key" :["remote_addr", "user_agent"]
value - 黑名单列表，value的值根据key的值一一对应。如："value" : {"remote_addr":"192.168.1.100", "user_agent":"Mozilla"}
id 唯一标识，用于增量更新使用

 --- 转换后配置
local configs = {
    {
        "key" = {
            "http_remote_addr",
            "http_user_agent",
        };
        "value" = {
            "http_remote_addr" = "";
            "http_user_agent" = "";
        };
    },
    {},
    {}
};
--]]

_M.toConfig = function (config, types, ngx)
    if type(config) ~= 'table' then
        ngx.log(ngx.ERR, "config type:" .. type(config) .. " not table.");

        return {};
    end

    if not config or next(config) == nil then
        ngx.log(ngx.ERR, "config is empty.");

        return {};
    end

    local convertConfigs = {};

    for _, value in pairs(config) do
        local type = value.type;

        if array.in_array(types, type) then
            local insertConfig = {};
            local key = type .. "Config";

            insertConfig.key = value.key;
            insertConfig.value = value.value;

            table.insert(convertConfigs[key], insertConfig);
        end
    end

    return convertConfigs;
end

return _M;

