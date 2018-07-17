-- 按流量灰度
local _M = {
    _VERSION = "0.0.1"
}
-- proxy level  
-- 0: default transmit requests according to the proxy_percent
-- 1: all request transmit  to the new system
-- 2: all request transmit  to the old system
local proxy_sys_level = 0;

-- proxy percent
local proxy_percent = {
    { new = 1, base = 1000 }, --level 1   0.1%
    { new = 1, base = 100 }, --level 2   1%
    { new = 10, base = 100 }, --level 3   10%
    { new = 50, base = 100 }, --level 4   50%
    { new = 100, base = 100 }, --level 5   100%
}
-- white ip list
local white_ip_list = {
    "192.168.0.1"
}

--
local proxy_new_uri_list = {
    ["/write"] = true,
}
--old
local old_upstream = "proxy_old"

--new
local new_upstream = "proxy_new"

-- redis key prefix
local redis_prefix = "PROXY:"


_M['proxy_sys_level'] = proxy_sys_level
_M['proxy_percent'] = proxy_percent
_M['white_ip_list'] = white_ip_list
_M['proxy_new_uri_list'] = proxy_new_uri_list
_M['old_upstream'] = old_upstream
_M['new_upstream'] = new_upstream
_M['redis_prefix'] = redis_prefix
return _M