--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 12/9/15
-- Time: 00:26
-- To change this template use File | Settings | File Templates.
--

local _M = {};
local parse = require("parse");
local json = require("dkjson");

--[[
本地 config 储存格式：

默认为： and 操作，验证方式为 把多个 key 值组合在一起，再做比对

- match - 匹配方式
    - full - 全匹配
    - pattern - 正则

local configs = {
    {
        http_remote_addr = {pattern="^/member/", type="header", mode="full"};
        http_user_agent = {pattern="/aaa/", type="var", mode="pattern"};
        mobile = {pattern="13212349870,13478906754", type="header", mode="in"};
    },
    {}
};

- 黑名单策略数据

    - type - 值来源
        - header - head
        - var - 入参
        - req - 请求参数
    - mode - 匹配规则
        - full - 全量匹配 - 默认
        - pattern - 正则匹配
        - in - 范围匹配
    - pattern - 匹配规则, 为空时不做匹配验证
--]]

_M.filter = function (rules, returnJson)
    ngx.log(ngx.DEBUG, "In blackFilter func.");

    while true do
        if (not rules or nil == next(rules)) then
            ngx.log(ngx.DEBUG, 'rules is empty, not check.');

            break;
        end

        ngx.log(ngx.DEBUG, 'rules:' .. json.encode(rules));

        for _, rule in pairs(rules) do
            ngx.log(ngx.DEBUG, 'rule:' .. json.encode(rule));

            local check = parse.check(rule);

            ngx.log(ngx.DEBUG, 'parse.check:' .. tostring(check));

            -- true - 符合过滤规则 - 返回禁止访问
            -- false - 不符合过滤规则 - 继续运行
            if check then
                ngx.log(ngx.INFO, 'Filter black rule:' .. json.encode(rule));

                ngx.header.content_type = 'application/json;charset=utf-8';
                ngx.status = returnJson.status;

                ngx.header['reply'] = 'nginx';
                ngx.say('{"code":' .. returnJson.code .. ', "responseCode":' .. returnJson.code .. ','
                        .. '"status": false, "message":"' .. returnJson.message .. '", '
                        .. '"msg":"' .. returnJson.message .. '",'
                        .. '"entry":null}');

                ngx.log(ngx.INFO, 'client request timeout.');

                ngx.exit(returnJson.status);
            end
        end

        ngx.log(ngx.INFO, 'Not in black filter.');
        break;
    end
end

return _M;