local proxy = require("gray")
local upstream = proxy.getUpstreamByUriAndCount()
ngx.var.backend = upstream