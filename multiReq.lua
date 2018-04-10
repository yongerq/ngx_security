--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 17/8/21
-- Time: 17:47
-- To change this template use File | Settings | File Templates.
--
--[[
         location ~ ^/outway/mtuan/suguo/ {
              access_by_lua_file "/data/lua/ngx-security/multiReq.lua";

              proxy_pass http://upstream.gray.tradeoutway.java;
              include /usr/local/nginx/conf/vhost/proxy_default.conf;
        }

        location = /suguo/meituan/notify {
              proxy_pass http://58.217.158.16:8080/interfaceweb/meituan/notify;
              include /usr/local/nginx/conf/vhost/proxy_default.conf;
        }
--]]

local method = ngx.req.get_method();

local data = {};

if 'POST' == method then
    ngx.req.read_body();

    data = ngx.req.get_post_args();
else
    data = ngx.req.get_uri_args();
end

local reqUrl = '/suguo/meituan/notify';
local reqData = {args = data, method = ngx.HTTP_POST};

local res1 = ngx.location.capture_multi({
    {reqUrl, reqData}
});

ngx.log(ngx.ERR, 'here. body:' .. tostring(res1.body));