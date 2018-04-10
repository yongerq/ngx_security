--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 2/15/16
-- Time: 17:19
-- To change this template use File | Settings | File Templates.
--

-- 接口请求 url: http://{domain}/merge/mget

local mgetConfig = require "mgetConfig";
local array = require "array";
local json = require "dkjson";

local args = ngx.req.get_uri_args();
local keys = mgetConfig.keys;

local argKeys = array.keys(args);

local intersectKeys = array.intersect(keys, argKeys);

-- 没有规定的 key 返回错误信息
if next(intersectKeys) == nil or next(intersectKeys) == nil then
    ngx.header.content_type = 'application/json;charset=utf-8';
    ngx.status = ngx.HTTP_BAD_REQUEST;
    ngx.say('{"status":false, "responseCode":-1, "message":"请求参数错误", "entry":{}}');
    ngx.log(ngx.INFO, 'mget args error');
    ngx.exit(400);
end

local url = "";
local urls = {};
for _, value in pairs(intersectKeys) do
    url = args[value];

    table.insert(urls, {url});
end

local results = {ngx.location.capture_multi(urls)};
local finalResults = {};

ngx.log(ngx.DEBUG, 'results json:' .. json.encode(results));

-- 回写请求参数 key 到返回结果中
local key = '';
for argName, result in pairs(results) do
    key = intersectKeys[argName];

    table.insert(finalResults, {[key]=result.body});
end

-- 组合返回结果
local returns = {status=true, responseCode=0, message='', entry=finalResults};
-- table.insert(returns, {entry=finalResults});

local resultJson = json.encode(returns);
ngx.log(ngx.DEBUG, 'finalResult json:' .. resultJson);

ngx.header.content_type = 'application/json;charset=utf-8';
ngx.say(resultJson);
ngx.log(ngx.DEBUG, 'mget success.');
ngx.exit(ngx.HTTP_OK);
