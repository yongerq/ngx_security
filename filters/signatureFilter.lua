--
-- User: yongerq.qiu
-- Company: shandiangou
-- Date: 7/7/16
-- Time: 14:41
--

local _M = {};
local lib = require "signature";
local array = require "array";
local signatureConfig = require "signatureConfig";
local url = require "url";
local app = require "app";

_M.filter = function (rules, returnJson)
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

    local args = ngx.req.get_uri_args() or {};

    local sk = '';
    local uri = ngx.var.uri;

    local userAgent = ngx.req.get_headers()['user-agent'] or '';

    local appType = app.getAppType(userAgent) or '';
    local appVersion = app.getAppVersion(userAgent) or '';
    local needSignParams = args;

    ngx.log(ngx.DEBUG, uri .. ' ua:' .. userAgent);
    ngx.log(ngx.DEBUG, uri .. ' appType:' .. appType);
    ngx.log(ngx.DEBUG, uri .. ' appVersion:' .. appVersion);

    -- 版本验证开关获取
    local appVersionRuleSwitch = signatureConfig.versionRuleSwitch or false;
    local appVersionRule = versionRule[appType] or {};
    local baseVersion = appVersionRule['version'] or '';

    -- continue 功能变相实现
    while true do
        -- 签名验证功能开关 - 关闭 不做签名验证
        if (false == signatureSwitch) then
            ngx.log(ngx.INFO, "signatureSwitch is false, not check sign.");

            break;
        end

        -- app 版本开关 - 开启 且 客户端版本小于配置版本 不做签名验证
        local compareVer = app.compareVersion(appVersion, baseVersion);
        if (true == appVersionRuleSwitch and compareVer < 0) then
            ngx.log(ngx.INFO, "appVersionRuleSwitch is true but compareVer lt 0, not check sign.");

            break;
        end

        -- 全部签名 header 配置信息获取
        local headerSignatureAllConf = signatureConfig.headerSignatureAllConf or {};
        local headerSignatureKey = headerSignatureAllConf.key or 'ApiSDKVersion';
        local headerSignatureVal = headerSignatureAllConf.val or 1.0;

        local headerSignatureSign = ngx.req.get_headers()[headerSignatureKey] or nil;

        -- ApiSDKVersion 版本验证
        local compareVer = app.compareVersion(headerSignatureSign, headerSignatureVal);

        ngx.log(ngx.INFO, 'headerSignatureSign:' .. tostring(headerSignatureSign) .. " compareVer:" .. tostring(compareVer));

        -- 不符合 ApiSDKVersion header 版本要求的 不做签名验证
        if(not headerSignatureSign or (nil ~= headerSignatureSign and compareVer < 0)) then
            ngx.log(ngx.INFO, "headerSignatureVal lt base.");

            -- 不在签名列表里的 uri 版本要求的 不做签名验证
            if (not array.array_search(signatureList, uri)) then
                ngx.log(ngx.INFO, "Not in signatureList, not check sign.");

                break;
            end
        end

        local headerTime = ngx.req.get_headers()['webtimestamp'] or args['webtimestamp']  or 0;

        -- 白名单列表里的 手机号 不做签名认证
        -- 登陆号码在免签名白名单里 不做签名认证
        local mobile = args.mobile or ngx.var.cookie_redcat_user_mobile or nil;
        if (true == mobileWhiteSwitch and mobile and array.array_search(mobileWhiteList, mobile)) then
            ngx.log(ngx.INFO, 'mobile:' .. mobile .. ' in mobile whilte list, do not check signature.');

            break;
        end
        mobile = mobile or '';

        local ak = '';
        local sn = '';
        -- 加到签名参数数组里去
        if (nil ~= headerSignatureSign and 0 ~= headerTime) then
            needSignParams['webtimestamp'] = headerTime;

            -- 新的签名方式 ak 和 sn 从 head 中获取
            ak = ngx.req.get_headers()['ak'] or '';
            sn = ngx.req.get_headers()['sn'] or '';

            ngx.log(ngx.DEBUG, uri .. ' In new sign, header sn or ak, sn:"' .. sn .. '" ak:"' .. ak .. '"');
        else
            ak = args['ak'] or '';
            sn = args['sn'] or '';

            if ('' == sn or '' == ak) then
                ngx.log(ngx.DEBUG, uri .. ' url sn or ak empty, sn:"' .. sn .. '" ak:"' .. ak .. '"');

                ak = ngx.req.get_headers()['ak'] or '';
                sn = ngx.req.get_headers()['sn'] or '';

                ngx.log(ngx.DEBUG, uri .. 'In old sign, header sn or ak, sn:"' .. sn .. '" ak:"' .. ak .. '"');
            else
                ngx.log(ngx.DEBUG, uri .. 'In old sign, sn and ak in url, sn="' .. sn .. '" ak="' .. ak .. '"');
            end
        end

        local akConfig = url.urlDecode(ak);

        sk = array.array_get(keys, akConfig, defaultSk);

        -- ak 值设置
        if not ak or '' == ak then
            needSignParams['ak'] = 'aMdi6T4a2kA=';
        else
            needSignParams['ak'] = ak;
        end

        local lrsWhiteReqKeys = {};
        if (array.in_array(lrsWhiteKeys, uri)) then
            lrsWhiteReqKeys = lrsWhiteList[uri] or {};
        end

        local signature = '';
        local signature2 = '';
        if (nil ~= headerSignatureSign and 0 ~= headerTime) then
            signature, signature2 = lib.doSignNew(needSignParams, sk);
        else
            signature, signature2 = lib.doSign(needSignParams, sk, lrsWhiteReqKeys, filterKeys);
        end

        ngx.log(ngx.INFO, 'req sn:' .. sn);
        ngx.log(ngx.INFO, 'lua sn:' .. signature);
        ngx.log(ngx.INFO, 'lua sn2:' .. tostring(signature2));

        if ('' == sn or (sn ~= signature and sn ~= signature2)) then
            ngx.header.content_type = 'application/json;charset=utf-8';
            -- ngx.status = 506;
            ngx.status = returnJson.status;

            -- 获取当前时间戳
            local time = ngx.time();

            ngx.header['reply'] = 'nginx';
            -- ngx.say('{"code":304000001, "responseCode":304000001, "status": false, "message":"认证失败", "msg":"认证失败", "entry":null, "time":'.. time ..'}');
            ngx.say('{"code":' .. returnJson.code .. ', "responseCode":' .. returnJson.code .. ','
                    .. '"status": false, "message":"' .. returnJson.message .. '", '
                    .. '"msg":"' .. returnJson.message .. '",'
                    .. '"entry":null,'
                    .. '"time":'.. time ..'}');

            ngx.log(ngx.INFO, 'signature check error');

            ngx.exit(returnJson.status);
        end

        ngx.log(ngx.INFO, 'signature check success');
        break;
    end
end

return _M;