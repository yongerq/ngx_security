--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 12/17/15
-- Time: 20:30
-- To change this template use File | Settings | File Templates.
--

-- 日志链路标志设置
-- traceId 设置

local uu = require "uuid";

local uuid = uu.uuid();

-- ngx.log(ngx.INFO, 'set traceId:' .. uuid);

return uuid;

-- ngx.req.set_header("_traceId", uuid);
