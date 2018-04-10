--[[

--- 安全配置类型:
- rate  - 请求频率
- black - 黑名单

--]]
local securityConfig = {
    -- types={"timeBond", "signature", "rate", "black"},
    types={"timeBond", "signature", "black"},
    --[[
    -- env:
    -- - daily,
    -- - gray,
    -- - production
    --]]
    env="production",
    ret={
        rate={status=403, code=-1, message='请求被过滤'},
        black={status=403, code=-1, message='请求被过滤'},
        signature={status=306, code=304000001, message='认证失败'},
        timeBond={status=306, code=304000002, message='请求无效'},
    }
};

return securityConfig;