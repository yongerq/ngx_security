--
-- Created by IntelliJ IDEA.
-- User: bean
-- Date: 17/5/23
-- Time: 14:04
-- To change this template use File | Settings | File Templates.
-- 请求方式： http://{host}/upstream/up?upstream_name=aaa.com&upstream_ip=10.23.1.17

local upstream = require "ngx.upstream"
local args = ngx.req.get_uri_args()

local upstream_name = args["upstream_name"] or nil
local upstream_ip = args["upstream_ip"] or nil

ngx.log(ngx.ERR, "start upstream peer up.")
ngx.log(ngx.ERR, "req upstream_name=" .. tostring(upstream_name) .. " upstream_ip:" .. tostring(upstream_ip))

if nil ~= upstream_name and nil ~= upstream_ip then
    -- upstream_name = string.trim(upstream_name)
    -- upstream_ip = string.trim(upstream_ip)

    local srvs = upstream.get_servers(upstream_name)

    local addr, pureAddr, backup
    local success = false

    for key, srv in ipairs(srvs) do
        addr = srv["addr"] or ""
        backup = srv["backup"] or false

        pureAddr = string.sub(addr, 1, string.find(addr, ":") - 1)

        ngx.log(ngx.ERR, "addr=" .. tostring(addr) .. " key=" .. tostring(key-1)
                .. " find addr=" .. string.find(addr, ":") .. " sub addr=" .. pureAddr)

        if upstream_ip == pureAddr then
            ngx.log(ngx.ERR, "set peer up success.")

            upstream.set_peer_down(upstream_name, backup, key-1, false)
            success = true

            break
        end
    end

    if success then
        ngx.say("ok")
        ngx.exit(ngx.HTTP_OK)
    else
        ngx.say("no server")
        ngx.exit(ngx.HTTP_OK)
    end
else
    ngx.log(ngx.ERR, "upstream_name=" .. tostring(upstream_name) .. " ip:" .. tostring(upstream_ip) .. " not ")

    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("upstream_name or upstream_ip is nil.")
    ngx.exit(400)
end
