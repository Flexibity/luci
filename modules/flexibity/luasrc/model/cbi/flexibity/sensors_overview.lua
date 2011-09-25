--[[
LuCI - Lua Configuration Interface

Copyright 2011 Maxim Osipov <maxim.osipov@gmail.com>
Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: system.lua 5472 2009-11-01 01:37:03Z jow $
]]--

require("luci.sys")
require("luci.sys.zoneinfo")
require("luci.tools.webadmin")


m = Map("sensors", translate("Sensors"), nil)

--[[ Health related sensors ]]--

s1 = m:section(TypedSection, "health", translate("Health"))
s1.anonymous = true
s1.addremove = false

o = s1:option(ListValue, "type", translate("Sensor type"))
o:value("activity", "Activity")
o:value("pulseox", "PulseOx")
o:value("temperature", "Temperature")
o = s1:option(Value, "user", translate("User"))
o = s1:option(Value, "address", translate("IP address"))
s1:option(DummyValue, "_safety", translate("Status")).value = "OK (100% battery level)"

--[[ Safety related sensors ]]--

s2 = m:section(TypedSection, "safety", translate("Safety"))
s2.anonymous = true
s2.addremove = false

o = s2:option(ListValue, "type", translate("Sensor type"))
o:value("motion", "Motion")
o:value("smoke", "Smoke")
o:value("water", "Water")
o = s2:option(Value, "location", translate("Location"))
o = s2:option(Value, "address", translate("IP address"))
s2:option(DummyValue, "_safety", translate("Measurement")).value = "3% (100% battery level)"

--[[ Environment related sensors ]]--

s3 = m:section(TypedSection, "environment", translate("Environment"))
s3.anonymous = true
s3.addremove = false

o = s3:option(ListValue, "type", translate("Sensor type"))
o:value("temperature", "Temperature")
o:value("humidity", "Humidity")
o:value("co2", "CO2")
o = s3:option(Value, "location", translate("Location"))
o = s3:option(Value, "address", translate("IP address"))
s3:option(DummyValue, "_safety", translate("Measurement")).value = "7% (100% battery level)"

return m

