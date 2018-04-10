--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 12/9/15
-- Time: 21:38
-- To change this template use File | Settings | File Templates.

-- 主动请求 rule 全量配置

--[[

请求地址: http://{domain}/noFilter/getAll
请求类型: get
返回结果:
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

--]]

local dkjson = require "dkjson";
local configConvert = require "configConvert";

local ngx = ngx;
local config = ngx.shared.config;

local res = ngx.location.capture("/noFilter/getAll")

if res then
    ngx.say("status: ", res.status)

    local status = res.status;

    if status ~= 200 then
        ngx.log(ngx.ERR, "/noFilter/getAll request error, status:" .. status);
    else
        local body = res.body;
        local reqConfig = dkjson.decode(body);

        if not reqConfig or next(reqConfig) == nil then
            ngx.log(ngx.ERR, "/noFilter/getAll request body empty.");
        else
            local entry = reqConfig.entry or {};
            local configs = configConvert.toConfig(entry);

            config:set("config", configs);
        end
    end
end

