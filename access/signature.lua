local lib = require "signature";
local array = require "array";
local signatureConfig = require "signatureConfig";
local url = require "url";
local app = require "app";

local ngx = ngx;

-- 获取签名配置
local defaultSk = signatureConfig.sk;

local keys = signatureConfig.key or {};
local signatureList = signatureConfig.signatureList or {};
local mobileWhiteList = signatureConfig.mobileWhiteList or {};

local signatureSwitch = signatureConfig.signatureSwitch or true;
local mobileWhiteSwitch = signatureConfig.mobileWhiteSwitch or true;
local versionRule = signatureConfig.versionRule or {};
local filterKeys = signatureConfig.filter or {};
-- 汪翔接口白名单列表
local lrsWhiteList = signatureConfig.lrsWhiteList or {};
-- 汪翔接口白名单列表 keys
local lrsWhiteKeys = array.keys(lrsWhiteList);

-- 请求方法、请求参数、请求url
local request_method = ngx.var.request_method;

local args = ngx.req.get_uri_args() or {};

local sk = '';
local uri = ngx.var.uri;

local userAgent = ngx.req.get_headers()['user-agent'] or '';
-- local userAgent = ngx.var.arg_ua;

local appType = app.getAppType(userAgent) or '';
local appVersion = app.getAppVersion(userAgent) or '';

ngx.log(ngx.DEBUG, uri .. ' ua:' .. userAgent);
ngx.log(ngx.DEBUG, uri .. ' appType:' .. appType);
ngx.log(ngx.DEBUG, uri .. ' appVersion:' .. appVersion);

-- 版本验证开关获取
local appVersionRuleSwitch = signatureConfig.versionRuleSwitch or false;
local appVersionRule = versionRule[appType] or {};
local baseVersion = appVersionRule['version'] or '';

local compareVer = app.compareVersion(appVersion, baseVersion);

ngx.log(ngx.DEBUG, uri .. ' ============= compareVer:' .. compareVer
        .. ' appVersion:' .. appVersion .. ' baseVersion:'
        .. baseVersion .. ' ============= ');

-- 大于等于指定版本的需要做签名认证
if (false == appVersionRuleSwitch or (appType and '' ~= appType and compareVer >= 0)) then
    ngx.log(ngx.INFO, 'appVersion:' .. appVersion .. ' ge ruleVersion:' .. baseVersion .. ' need check signature');

    -- 签名功能是否启用开关
    if (true == signatureSwitch) then
        -- 是否全部做签名认证开关
        -- local signatureAll = signatureConfig.signatureAll or false;

        -- 全部签名 header 配置信息获取
        local headerSignatureAllConf = signatureConfig.headerSignatureAllConf or {};
        local headerSignatureKey = headerSignatureAllConf.key or 'ApiSDKVersion';
        local headerSignatureVal = headerSignatureAllConf.val or 1.0;
        headerSignatureVal = tonumber(headerSignatureVal);

        local headerSignatureSign = ngx.req.get_headers()[headerSignatureKey] or nil;
        headerSignatureSign = tonumber(headerSignatureSign);

        local ngxTime = ngx.time();
        local headerTime = ngx.req.get_headers()['webtimestamp'] or args['webtimestamp']  or 0;

        -- 加到签名参数数组里去
        if (nil ~= headerSignatureSign and 0 ~= headerTime) then
            args['webtimestamp'] = headerTime;
        end

        -- 请求时间限制
        if (nil ~= headerSignatureSign and (ngxTime - headerTime > 30)) then
            ngx.header.content_type = 'application/json;charset=utf-8';
            ngx.status = 306;

            -- 获取当前时间戳
            local time = ngx.time();

            ngx.header['reply'] = 'nginx';
            ngx.say('{"code":304000002, "responseCode":304000002, "status": false, "message":"请求无效", "msg":"请求无效", "entry":null, "time":'.. time ..'}');

            ngx.log(ngx.INFO, 'request timeout.');

            ngx.exit(ngx.HTTP_OK);
        end

        -- 在签名列表里的 uri 和 符合 ApiSDKVersion header 信息的请求 需要做签名认证
        if((nil ~= headerSignatureSign and headerSignatureSign >= headerSignatureVal)
                or array.array_search(signatureList, uri)) then
            ngx.log(ngx.INFO, 'uri in signatureList.');

            -- 白名单列表里的 手机号 不做签名认证
            local mobile = args.mobile or ngx.var.cookie_redcat_user_mobile or nil;

            ngx.log(ngx.DEBUG, uri .. 'method:' .. request_method);

            --[[
                if "GET" == request_method then
                args = ngx.req.get_uri_args();
                elseif "POST" == request_method then
                -- args = ngx.req.get_post_args();
                args = ngx.req.get_uri_args();
                else
                ngx.status = ngx.HTTP_NOT_ALLOWED;
                ngx.log(ngx.ERR, "request method is Allowed.");
                ngx.exit(ngx.HTTP_NOT_ALLOWED);
                end
                --]]

            if (true == mobileWhiteSwitch and mobile and array.array_search(mobileWhiteList, mobile)) then
                ngx.log(ngx.INFO, 'mobile:' .. mobile .. ' in mobile whilte list, do not check signature.');
            else
                mobile = mobile or '';
                ngx.log(ngx.INFO, 'mobile:' .. mobile .. ' not in mobile whilte list, do check signature.');

                local ak = args['ak'] or '';
                local sn = args['sn'] or '';

                if ('' == sn or '' == ak) then
                    ngx.log(ngx.DEBUG, uri .. ' url sn or ak empty, sn:"' .. sn .. '" ak:"' .. ak .. '"');

                    ak = ngx.req.get_headers()['ak'] or '';
                    sn = ngx.req.get_headers()['sn'] or '';

                    ngx.log(ngx.DEBUG, uri .. ' header sn or ak, sn:"' .. sn .. '" ak:"' .. ak .. '"');
                else
                    ngx.log(ngx.DEBUG, uri .. ' sn and ak in url, sn="' .. sn .. '" ak="' .. ak .. '"');
                end

                local akConfig = url.urlDecode(ak);

                sk = array.array_get(keys, akConfig, defaultSk);

                -- ak 值设置
                if not ak or '' == ak then
                    args['ak'] = 'aMdi6T4a2kA=';
                else
                    args['ak'] = ak;
                end

                local lrsWhiteReqKeys = {};
                if (array.in_array(lrsWhiteKeys, uri)) then
                    lrsWhiteReqKeys = lrsWhiteList[uri] or {};
                end

                local signature = lib.signature(args, sk, lrsWhiteReqKeys, filterKeys) or '';

                ngx.log(ngx.INFO, 'req sn:' .. sn);
                ngx.log(ngx.INFO, 'lua sn:' .. signature);

                if ('' == sn or sn ~= signature) then
                    ngx.header.content_type = 'application/json;charset=utf-8';
                    -- ngx.status = 506;
                    ngx.status = 306;

                    -- 获取当前时间戳
                    local time = ngx.time();

                    ngx.header['reply'] = 'nginx';
                    -- ngx.say('{"status":false, "responseCode":-1, "message":"签名认证不正确", "entry":null}');
                    ngx.say('{"code":304000001, "responseCode":304000001, "status": false, "message":"认证失败", "msg":"认证失败", "entry":null, "time":'.. time ..'}');

                    ngx.log(ngx.INFO, 'signature check error');

                    ngx.exit(ngx.HTTP_OK);
                else
                    ngx.log(ngx.INFO, 'signature check success');
                end
            end
        else
            ngx.log(ngx.INFO, 'uri:' .. uri .. ' uri not in signatureList, do not check signature');
        end
    else
        ngx.log(ngx.INFO, 'uri:' .. uri .. ' uri not in signatureList, do not check signature');
    end
else
    ngx.log(ngx.INFO, 'appVersion:' .. appVersion .. ' lt ruleVersion:' .. baseVersion .. ' or appType is empty, unwant check signature');
end