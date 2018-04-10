--
-- User: yongerq.qiu
-- Company: shandiangou
-- Date: 7/22/16
-- Time: 16:22
--
local signatureConfig = require "signatureConfig";
local app = require "app";

local _M = {};

_M.filter=function(rules, returnJson)
    local headerSignatureAllConf = signatureConfig.headerSignatureAllConf or {};
    local headerSignatureKey = headerSignatureAllConf.key or 'ApiSDKVersion';
    local headerSignatureVal = headerSignatureAllConf.val or '1.0';

    local headerSignatureSign = ngx.req.get_headers()[headerSignatureKey] or nil;

    local ngxTime = ngx.time();
    local headerTime = ngx.req.get_headers()['webtimestamp'] or ngx.req.get_uri_args()['webtimestamp'] or 0;

    local compareVer = app.compareVersion(headerSignatureSign, headerSignatureVal);

    -- 请求时间限制
    if (nil ~= headerSignatureSign and compareVer >= 0 and (ngxTime - headerTime > 30)) then
        ngx.header.content_type = 'application/json;charset=utf-8';
        ngx.status = returnJson.status;

        ngx.header['reply'] = 'nginx';
        ngx.say('{"code":' .. returnJson.code .. ', "responseCode":' .. returnJson.code .. ','
            .. '"status": false, "message":"' .. returnJson.message .. '", '
            .. '"msg":"' .. returnJson.message .. '",'
            .. '"entry":null, '
            .. '"time":'.. ngxTime ..'}');

        ngx.log(ngx.INFO, 'Client request timeout. ngxTime:' .. tostring(ngxTime) .. ' webtimestamp:' .. tostring(headerTime));

        ngx.exit(returnJson.status);
    end

    ngx.log(ngx.INFO, 'Client Request Not Timeout OR Does Not Check Request Time.');
end

return _M;