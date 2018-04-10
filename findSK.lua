--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 1/7/16
-- Time: 18:57
-- To change this template use File | Settings | File Templates.
--

-- require("aeslua")
-- local util = require("aeslua.util");
local signatureConfig = require("signatureConfig");
-- local time = require("time");

local args = ngx.req.get_uri_args();

local pk = args['pk'] or '';
local sign = args['sign'] or 0;

local keys = signatureConfig.key or {};

local sk = keys[pk] or '';
-- local invalidDate = time.dayAdd(7);
local invalidDate = '2017-03-01 00:00:00';
local ngx = ngx;

ngx.log(ngx.DEBUG, 'sign:' .. sign);

local result = '{' ..
                    '"code": 10000,' ..
                    '"data": {'..
                        '"sk": "'.. sk ..'",'..
                        '"invalidDate": "'.. invalidDate ..'",'..
                        '"sign":'.. sign ..
                    '},'..
                    '"extra" : { },'..
                    '"msg"   : "ok",'..
                    '"sum"   : 0'..
                '}';

ngx.header.content_type = 'application/json; charset=utf-8';
ngx.say(result);
ngx.exit(ngx.HTTP_OK);