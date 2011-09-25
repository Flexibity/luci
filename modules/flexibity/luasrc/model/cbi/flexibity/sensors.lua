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

m = Map("sensors", translate("Senosrs"), translate("Here you can configure Flexibity wireless sensors."))

s = m:section(TypedSection, "health", translate("Health"))
s.anonymous = true
s.addremove = true

o = s:option(ListValue, "type", translate("Sensor type"))
o.rmempty = false
o.default = "activity"
o:value("activity", "Activity")
o:value("pulseox", "PulseOx")
o:value("temperature", "Temperature")

o = s:option(Value, "user", translate("User"))

o = s:option(Value, "address", translate("IP address"))
o.rmempty = false
o.default = "192.168.117.1"

s = m:section(TypedSection, "safety", translate("Safety"))
s.anonymous = true
s.addremove = true

o = s:option(ListValue, "type", translate("Sensor type"))
o.rmempty = false
o.default = "smoke"
o:value("motion", "Motion")
o:value("smoke", "Smoke")
o:value("water", "Water")

o = s:option(Value, "location", translate("User"))

o = s:option(Value, "address", translate("IP address"))
o.rmempty = false
o.default = "192.168.117.1"

s = m:section(TypedSection, "environment", translate("Environment"))
s.anonymous = true
s.addremove = true

o = s:option(ListValue, "type", translate("Sensor type"))
o.rmempty = false
o.default = "temperature"
o:value("temperature", "Temperature")
o:value("humidity", "Humidity")
o:value("co2", "CO2")

o = s:option(Value, "location", translate("User"))

o = s:option(Value, "address", translate("IP address"))
o.rmempty = false
o.default = "192.168.117.1"

return m
