local config = require("config")
local redisModule = require("MyRedis")
-- 按流量灰度
local _M = {
    _VERSION = "0.0.1"
}
-- request count
local req_count = 0;
local uri_req_count_map = {}

local _getRequestUri = function()
    local uri = ngx.var.uri
    return uri
end

local _getRedisUriKey = function()
    local uri_prefix = config['redis_prefix']
    local uri = ngx.var.uri
    if uri_prefix then
        uri = uri_prefix .. uri
    end
    return uri
end

-- write api transmit to new api
function _M._isProxyNewMust()
    local proxy_new_uri_list = config['proxy_new_uri_list']
    if proxy_new_uri_list[_getRequestUri()] then
        return true
    end
    return false;
end

function _M.checkWhiteReq()
    local headers = ngx.req.get_headers()
    local white_ip_list = config['white_ip_list']
    local ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
    for _, v in ipairs(white_ip_list) do
        if v == ip then
            return true
        end
    end
    return false
end

function _M.getReqCnt()
    req_count = req_count + 1
    return req_count;
end

function _M.getReqCountByKey(key)
    local req_count = uri_req_count_map[key]
    if req_count == nil then
        req_count = 0
    end
    uri_req_count_map[key] = req_count + 1
    return uri_req_count_map[key]
end

function _M.getUpstreamByUriAndCount()
    local proxy_sys_level = config['proxy_sys_level']
    local old_upstream = config['old_upstream']
    local new_upstream = config['new_upstream']
    local proxy_percent = config['proxy_percent']
    -- system level
    if proxy_sys_level == 2 then
        return old_upstream
    elseif proxy_sys_level == 1 then
        return new_upstream
    else 
        if _M.checkWhiteReq() == true then
            return new_upstream
        end
        -- write first
        if _M._isProxyNewMust() == true then
            return new_upstream
        end
        -- get for redis
        -- in uri and count % base < new
        local redis = redisModule:new()
        local redis_uri_key = _getRedisUriKey()
        local level, _ = redis:get(redis_uri_key)
        if level then
            local count = _M.getReqCountByKey(redis_uri_key)
            local index = tonumber(level)
            local proxy = proxy_percent[index]
            if proxy then
                if (count % proxy['base']) < proxy['new'] then
                    return new_upstream
                end
            end
        end
        return old_upstream
    end
end

return _M