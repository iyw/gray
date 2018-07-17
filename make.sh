#!/bin/bash
PREFIX=/usr/local/openresty
if [ ! -d "${PREFIX}/nginx/lua" ]; then
    mkdir -p ${PREFIX}/nginx/lua
fi
if [ ! -d "${PREFIX}/nginx/servers" ]; then
    mkdir -p ${PREFIX}/nginx/servers
fi
cp  ./conf/proxy.conf ${PREFIX}/nginx/conf/servers/
cp  ./conf/test_new.conf ${PREFIX}/nginx/conf/servers/
cp  ./conf/test_old.conf ${PREFIX}/nginx/conf/servers/

cp ./lua/* ${PREFIX}/nginx/lua/