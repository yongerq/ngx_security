local headerConfig = require "headerFilterConfig";
local array = require "array";

local allowDomains = headerConfig["allow"] or {};
local origin = ngx.req.get_headers()["origin"] or '';
local domain = '';

ngx.log(ngx.DEBUG, "origin:" .. origin);

-- 是否为 http:// 和 https:// 开头的请求协议
if nil ~= origin and string.len(origin) >= 1 then
    local schema = string.find(origin, '^(http://)') or string.find(origin, '^(https://)');

    ngx.log(ngx.DEBUG, "schema:" .. tostring(schema));

    if nil ~= schema then
        local originReverse = string.reverse(origin) or '';
        local originLen = string.len(origin) or 0;

        ngx.log(ngx.DEBUG, "originReverse:" .. originReverse);
        ngx.log(ngx.DEBUG, "originLen:" .. originLen);

        local firstPos = string.find(originReverse, '%.');
        if nil ~= firstPos then
            local originPos = string.find(originReverse, '%.', firstPos+1);
            ngx.log(ngx.DEBUG, "originPos:" .. tostring(originPos));

            if nil ~= originPos then
                domain = string.sub(origin, originLen - originPos + 2) or '';

                -- 去除端口
                local portPos = string.find(domain, ":%d*$");
                if nil ~= portPos then
                    domain = string.sub(domain, 0, portPos-1);
                end
            end
        end
    end
end

ngx.log(ngx.DEBUG, "domain:" .. domain);

if array.in_array(allowDomains, domain) then
    ngx.header['Access-Control-Allow-Origin'] = ngx.req.get_headers()["origin"] or '';
else
    ngx.header['Access-Control-Allow-Origin'] = 'not found';
end

ngx.header['Access-Control-Allow-Credentials'] = 'true';

--[[
-- 跨域头设置:

-- 响应头为: Access-Control-Allow-Methods
-- 请求头为: Access-Control-Allow-Method
--]]
ngx.header['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
ngx.header['Access-Control-Max-Age'] = '3600';

-- 跨域请求 header 配置
ngx.header['Access-Control-Allow-Headers'] = 'content-type, lat, lng, udid, ak, sn, version, X-Requested-With';