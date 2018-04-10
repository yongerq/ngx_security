### 打包命令

tar -zcf ngx-security.tgz --exclude=ngx-security/.git* --exclude=ngx-security/.DS_Store --exclude=ngx-security/.idea ./ngx-security

- 移除隐藏文件目录

### 功能列表

1. headerFilter.lua
    - 接口跨域设置
1. setTraceId.lua
    - 设置每个请求的 traceid 值, 用于请求链路日志标识
1. mget.lua
    - 合并请求功能
    - 请求 url 为: http://{domain}/merge/mget
1. access/access.lua
    - access_by_lua_file 配置
    - 用于请求权限控制
    - 功能有:
        - 签名功能验证
        - 请求时间限制
        - 请求黑名单功能
        - 请求频率限制