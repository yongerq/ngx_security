
local signatureConfig = {
    -- ak = sk
    key = {
        ['aMdi6T4a2kA='] = 'iS0Dc7zK2/Ef/rxoe480Yg==';
    };
    -- default sk
    sk = "iS0Dc7zK2/Ef/rxoe480Yg==";
    filter = {'sn'},
    -- signature switch; on - true, off - false
    signatureSwitch = true;
    -- 是否所有接口做签名开关; on - true, off - false
    -- 废弃
    signatureAll = false;
    -- header ApiSDK 版本定义
    -- 大于等于该版本 需做全量签名验证
    headerSignatureAllConf = {
        key='ApiSDKVersion',
        val='1.2'
    },

    -- 汪翔三个特殊接口参数列表定义
    lrsWhiteList = {
        ['/api/shop.do'] =  {'lid', 'ak'},
        ['/api/locate.do'] = {'lat', 'lng', 'd', 'ak', 'nlid'},
        --['/api/landmark.do'] = {'lat', 'lng', 'name', 'city', 'd', 'ak', 't', 's', 'l', 'level', 'sid', 'scope'},
        --['/api/landmark.do'] = {'lat', 'lng', 'name', 'address', 'ak', 't'},
        ['/api/landmark.do'] = {"lat", "lng", "name", "city", "d", "ak", "t", "s", "l", "level", "sid", "scope"},
    },
    -- need signature url list
    signatureList = {
        "/api/shop.do",
        "/api/locate.do",
        "/api/landmark.do",
        "/member/sendAuthCodeV1.do",
        "/member/sendWmtAuthCode.do",
        "/member/sendPosAuthCode.do",
        "/member/ka/sendAuthCodeV1.do",
    };
    -- 版本验证开关
    -- -- 客户端 版本 大于等于 配置版本的 需要做签名验证
    -- -- 默认 - false - 不开启, true - 开启
    versionRuleSwitch = false,
    versionRule = {
        buyer = {
            version = '3.0',
        },
    };
    -- mobile white list switch; on - true, off - false
    mobileWhiteSwitch = true;
    -- must string type
    mobileWhiteList = {
        "13918080431",
        "12345679000",
        "13713004273",
        "13732272557",
        "19912341234",
        "19912341235",
        "19812341234",
        "19812341235",
        "19712341234",
        "19712341235",
        "19988888888",
        "19888888888",
        "18513622751",
        "13646834799",
    }
};

return signatureConfig;