--[[
LuCI - Lua Configuration Interface

Copyright 2011 Maxim Osipov <maxim.osipov@gmail.com>
Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: system.lua 6068 2010-04-15 00:15:35Z cshore $
]]--

module("luci.controller.flexibity.sensors", package.seeall)

function index()
	luci.i18n.loadc("base")
	local i18n = luci.i18n.translate

	entry({"flexibity", "sensors"}, alias("flexibity", "sensors", "index"), i18n("Sensors"), 20).index = true
        entry({"flexibity", "sensors", "index"}, cbi("flexibity/sensors_overview"), i18n("Overview"), 1).leaf = true

	entry({"flexibity", "sensors", "health"}, template("flexibity/health"), i18n("Health"), 10).leaf = true

	entry({"flexibity", "sensors", "safety"}, template("flexibity/safety"), i18n("Safety"), 20).leaf = true

        entry({"flexibity", "sensors", "environment"}, template("flexibity/environment"), i18n("Environment"), 30).leaf = true
        entry({"flexibity", "senosrs", "environment_status"}, call("action_environment")).leaf = true
end

function action_environment()
        local fs = require "luci.fs"
        if fs.access("/var/lib/luci-bwc/load") then
                luci.http.prepare_content("application/json")

                local bwc = io.popen("luci-bwc -l 2>/dev/null")
                if bwc then
                        luci.http.write("[")

                        while true do
                                local ln = bwc:read("*l")
                                if not ln then break end
                                luci.http.write(ln)
                        end

                        luci.http.write("]")
                        bwc:close()
                end

                return
        end

        luci.http.status(404, "No data available")
end

