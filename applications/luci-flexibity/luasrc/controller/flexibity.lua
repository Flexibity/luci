--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: ddns.lua 7362 2011-08-12 13:16:27Z jow $
]]--

module("luci.controller.flexibity", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/sensors") then
		return
	end

	local page = entry({"admin", "services", "sensors"}, arcombine(template("flexibity/summary"), template("flexibity/sensor")), _("Sensors"), 90)
	page.leaf = true
	page.subindex = true
        entry({"admin", "services", "sensors_poll"}, call("action_poll"), nil).leaf = true

	local uci = require "luci.model.uci".cursor_state()
	local router = uci:get(unpack({"sensors", "router", "ip6addr"}))
	if not router then
		return
	end
        local response = require "luci.sys".httpget('http://'..router..'/index.html')
        if not response then
                return
        end
        local data = require "luci.json".decode(response)
        if data then
                for i,v in ipairs(data.routes) do
			local addr = v.addr:gsub("/.*", "")
			entry({"admin", "services", "sensors", addr}, alias("admin", "services", "sensors"), addr).leaf = true
                end
        end
end

function action_poll()
	local sys = require "luci.sys"
	local path = luci.dispatcher.context.requestpath
	local addr = path[#path-1]:gsub("z", ":")
	local dir = path[#path]
	local response = sys.httpget('http://'..addr..'/'..dir)

	if response then
		luci.http.prepare_content("application/json")
		luci.http.write(response)
		return
	end

	luci.http.status(404, "No such sensor")
end

