--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 4/18/16
-- Time: 15:22
-- To change this template use File | Settings | File Templates.
--

--[[
本地 config 储存格式：

默认为： and 操作，验证方式为 把多个 key 值组合在一起，再做比对

- match - 匹配方式
    - full - 全匹配
    - pattern - 正则

local configs = {
    {
        http_remote_addr={pattern="^/member/", type="header", mode="full"};
        http_user_agent={pattern="/aaa/", type="var", mode="pattern"};
        mobile={pattern="13212349870,13478906754", type="header", mode="in"};
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

local blackConfig = {
    {
        uri={type="var", mode="full", pattern="/aaa/test"}
    },
    --[[
    {
        uri={type="var", mode="pattern", pattern="^/merge/"}
    }
    --]]
};

return blackConfig;