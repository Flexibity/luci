--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2010-2011 Jo-Philipp Wich <xm@subsignal.org>
Copyright 2010 Manuel Munz <freifunk at somakoma dot de>
Copyright 2011 Maxim Osipov <maxim.osipov@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require "luci.fs"
require "luci.sys"
require "luci.util"

f = SimpleForm("Health", "Processing Code",
	translate("Put your Processing code for safety sensors here, check Prosessing.js for more information (http://processingjs.org/)."))

t = f:field(TextValue, "health")
t.rmempty = true
t.rows = 20

function t.cfgvalue()
	return luci.fs.readfile("/www/luci-static/resources/health.pde") or ""
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.health then
			luci.fs.writefile("/www/luci-static/resources/health.pde", data.health:gsub("\r\n", "\n"))
		end
	end
	return true
end

return Template("flexibity/health"), f

