--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 12/9/15
-- Time: 21:47
-- To change this template use File | Settings | File Templates.

-- 被动接收 rule 全量配置

--[[

nginx 暴露的接口

请求地址 http://{domain}/nginx/pushRule
请求类型 json/application post
请求参数 {"rule":value, "action" : "delete"}

value是上面策略的json对象
action: create, update, delete

返回结果: {"status":true, "responseCode":1000, "message":""}
1000:成功

-- ]]
