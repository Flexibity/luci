--[[
LuCI - Lua Configuration Interface

Copyright 2011 Maxim Osipov <maxim.osipov@gmail.com>
Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: network.lua 6440 2010-11-15 23:00:53Z jow $
]]--

local fs = require "nixio.fs"

m = Map("sensors", translate("Sensors"), translate("Here you can configure the Flexibity sensors network and upload data servers."))

m:section(SimpleSection).template = "flexibity/summary"

s = m:section(TypedSection, "router", translate("Router"))
s.anonymous = true
s.addremove = false

o = s:option(Value, "ip6addr", translate("IPv6 address"))
o.rmempty = false
o.default = "aaaa::0250:c2a8:c157:4beb"


s = m:section(TypedSection, "server", translate("Servers"))
s.anonymous = true
s.addremove = true

o = s:option(Value, "name", translate("Name"))
o.rmempty = false
o.default = "cosm"

o = s:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false
o.default = "1"
o.disabled = "0"
o.enabled = "1"

o = s:option(Value, "host", translate("Host"))
o.rmempty = false
o.default = "api.cosm.com"

o = s:option(Value, "port", translate("Port"))
o.rmempty = false
o.default = "80"

o = s:option(Value, "interval", translate("Interval (seconds)"))
o.rmempty = false
o.default = "30"

o = s:option(ListValue, "proto", translate("Protocol"))
o.rmempty = false
o.default = "cosm"
o:value("cosm", "Cosm V2")

o = s:option(Value, "id", translate("Protocol-specific ID"))
o.rmempty = false
o.default = ""


s = m:section(TypedSection, "sensor", translate("Sensors"))
s.anonymous = true
s.addremove = true

o = s:option(Value, "name", translate("Name"))
o.rmempty = false
o.default = "default"

o = s:option(Value, "ip6addr", translate("IPv6 address"))
o.rmempty = false
o.default = "aaaa::250:c2a8:c228:5b6a"

o = s:option(Value, "server", translate("Data upload server"))
o.rmempty = false
o.default = "cosm"

o = s:option(Value, "id", translate("Server-specific ID"))
o.rmempty = false
o.default = ""

return m
