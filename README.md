# gray灰度方案
1. nginx+lua 开发的灰度方案、轻量级
2. 按流量灰度、支持多个级别 比如:0.01% -> 1% -> 20% -> 50% -> 100% 流量依次递增
3. 默认路由到老系统、支持配置100%流量路由到新系统

本项目已在我们生产环境中使用

##### nginx.conf 配置文件
```sh
	//nginx.conf 文件中 加入lua包路径
	//说明:1、 $PREFIX 为openresty安装路径
	lua_package_path "$PREFIX/nginx/lua;$PREFIX/lualib/?.lua;;";
```
比方: 我的openresty安装目录是 /usr/local/openresty
只需在nginx.conf文件中 http域加入如下代码
```sh
   lua_package_path "/usr/local/openresty/nginx/lua/?.lua;/usr/local/openresty/lualib/?.lua;./?.lua;;";
   include servers/*.conf;
```
安装
```
sudo ./make.sh

```

## 配置文件 config.lua
```
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
```
## 设置接口灰度级别 (记录在redis中、可以动态的更改、其中PROXY: 为config.lua中 redis_prefix /abc为请求接口的uri 级别3 (10%几率路由到新系统))
```
127.0.0.1:6379> set PROXY:/abc 3
OK
```
