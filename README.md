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
