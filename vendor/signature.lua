--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 11/25/15
-- Time: 20:34
-- To change this template use File | Settings | File Templates.

local array = require "array";
local url = require "url";

local _M = {};

-- 老签名方式
-- 需过滤 reqParam
-- 部分接口只对 指定 key 做签名
function _M.doSign(source, sk, whiteReqKeys, filterKeys)
    local params = "";
    local params2 = '';
    local originParams = "";

    -- 取出所有键
    local keys = array.keys(source);

    ngx.log(ngx.DEBUG, ngx.var.uri .. ' whiteReqKeys:' .. table.concat(whiteReqKeys, ','));
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' filterKeys:' .. table.concat(filterKeys, ','));
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' origin param keys:' .. table.concat(keys, ','));

    -- whiteReqKeys 非空 做交集
    -- whiteReqKeys 为空 做差集
    if (next(whiteReqKeys) ~= nil) then
        keys = array.intersect(keys, whiteReqKeys);
    else
        keys = array.diff(keys, filterKeys);
    end

    ngx.log(ngx.DEBUG, ngx.var.uri .. ' process param keys:' .. table.concat(keys, ','));

    -- 对所有键进行排序
    table.sort(keys);

    for _,key in pairs(keys) do
        originParams = originParams .. tostring(key) .. '=' .. tostring(source[key]) .. '&';

        -- params = params .. tostring(key) .. "=" .. url.urlEncode(url.urlEncode(tostring(source[key]))) .. "&";
        params = params .. tostring(key) .. "=" .. url.urlEncode(tostring(source[key])) .. "&";

        -- double urlencode
        if ('ak' ~= key) then
            params2 = params2 .. tostring(key) .. "=" .. url.urlEncode(url.urlEncode(tostring(source[key]))) .. "&";
        else
            params2 = params2 .. tostring(key) .. "=" .. url.urlEncode(tostring(source[key])) .. "&";
        end
    end

    params = string.sub(params, 1, -2);
    originParams = string.sub(originParams, 1, -2);
    params2 = string.sub(params2, 1, -2);

    params = params .. sk;
    params2 = params2 .. sk;
    originParams = originParams .. sk;

    ngx.log(ngx.DEBUG, ngx.var.uri .. ' originParams:' .. originParams);
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' params:' .. params);
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' params2:' .. tostring(params2));

    local sign = ngx.md5(params);
    local sign2 = ngx.md5(params2);

    ngx.log(ngx.DEBUG, ngx.var.uri .. ' sign:' .. tostring(sign));
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' sign2:' .. tostring(sign2));

    return sign, sign2;
end

-- 新签名方式
-- 不做任何过滤,任何 reqParam 都做签名
function _M.doSignNew(source, sk)
    local params = "";
    local params2 = '';
    local originParams = "";

    -- 取出所有键
    local keys = array.keys(source);

    ngx.log(ngx.DEBUG, ngx.var.uri .. ' In signatureNew func.');
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' param keys:' .. table.concat(keys, ','));

    -- 对所有键进行排序
    table.sort(keys);

    for _,key in pairs(keys) do
        originParams = originParams .. tostring(key) .. '=' .. tostring(source[key]) .. '&';

        params = params .. tostring(key) .. "=" .. url.urlEncode(tostring(source[key])) .. "&";

        -- double urlencode
        if ('ak' ~= key) then
            params2 = params2 .. tostring(key) .. "=" .. url.urlEncode(url.urlEncode(tostring(source[key]))) .. "&";
        else
            params2 = params2 .. tostring(key) .. "=" .. url.urlEncode(tostring(source[key])) .. "&";
        end
    end

    params = string.sub(params, 1, -2);
    originParams = string.sub(originParams, 1, -2);
    params2 = string.sub(params2, 1, -2);

    params = params .. sk;
    params2 = params2 .. sk;
    originParams = originParams .. sk;

    ngx.log(ngx.DEBUG, ngx.var.uri .. ' originParams:' .. originParams);
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' params:' .. params);
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' params2:' .. tostring(params2));

    local sign = ngx.md5(params);
    local sign2 = ngx.md5(params2);

    ngx.log(ngx.DEBUG, ngx.var.uri .. ' sign:' .. tostring(sign));
    ngx.log(ngx.DEBUG, ngx.var.uri .. ' sign2:' .. tostring(sign2));

    return sign, sign2;
end

function _M.getSignArgs()
    local headerSignArgs = {'udid', 'imei', 'imsi', ''};
end

return _M;
