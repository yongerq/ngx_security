local securityConfig = require("securityConfig");
local types = securityConfig.types;
local rets = securityConfig.ret;

for _, value in pairs(types) do
    local filterName = value .. "Filter";
    ngx.log(ngx.DEBUG, "filterName:" .. tostring(filterName));

    local handle = require(filterName);
    ngx.log(ngx.DEBUG, "type(handle):" .. type(handle));

    local filterConfigName = value .. "Config";
    ngx.log(ngx.DEBUG, "filterConfigName:" .. tostring(filterConfigName));

    local filterConfig = require(filterConfigName) or {};
    local returnJson = rets[value] or {status=403, code=-1, responseCode=-1, message='', status=false, entry='null'};

    -- ngx.log(ngx.INFO, "Request is not filter, type:" .. value);
    handle.filter(filterConfig, returnJson);
    --[[
    local filter, retJson = handle.filter(filterConfig);
    local ret = rets[value] or {status=403, code=-1, message='', status=false, entry='null'};

    -- 过滤不通过,返回错误
    if not filter then
        ngx.log(ngx.INFO, "Request is filter, forbidden, type:" .. value);

        ngx.status = ret.status;
        ngx.header['reply'] = 'nginx';

        ngx.header.content_type = 'application/json;charset=utf-8';

        ngx.say('{"code":' .. ret.code .. ', "responseCode":' .. ret.code ..
                ', "status": ' .. ret.status .. ', "message":' .. ret.message ..
                ', "entry":null}');
        ngx.exit(ngx.HTTP_FORBIDDEN);
    else
        ngx.log(ngx.INFO, "Request is not filter, type:" .. value);
    end
    --]]
end