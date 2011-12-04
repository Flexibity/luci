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

module("luci.controller.flexibity.configuration", package.seeall)

function index()
	luci.i18n.loadc("base")
	local i18n = luci.i18n.translate

	entry({"flexibity", "configuration"}, alias("flexibity", "configuration", "index"), i18n("Configuration"), 90).index = true
        entry({"flexibity", "configuration", "index"}, cbi("flexibity/configuration", {autoapply=true}), i18n("General"), 1)

        local has_config = nixio.fs.stat("/etc/config/connect")
        if has_config and has_config.size > 0 then
		entry({"flexibity", "configuration", "connect"}, call("action_empty"), i18n("Connect"), 3)
	else
		entry({"flexibity", "configuration", "connect"}, call("action_empty"), i18n("Connect"), 3)
	end

        local has_config = nixio.fs.stat("/etc/config/sensors")
        if has_config and has_config.size > 0 then
		entry({"flexibity", "configuration", "sensors"}, cbi("flexibity/sensors"), i18n("Sensors"), 4)
	else
		entry({"flexibity", "configuration", "sensors"}, call("action_empty"), i18n("Sensors"), 4)
	end

        local has_config = nixio.fs.stat("/etc/config/motion")
        if has_config and has_config.size > 0 then
		entry({"flexibity", "configuration", "webcam"}, cbi("flexibity/motion"), i18n("Webcam"), 5)
	else
		entry({"flexibity", "configuration", "webcam"}, template("flexibity/webcam_empty"), i18n("Webcam"), 5)
	end

        local has_config = nixio.fs.stat("/etc/config/transmission")
        if has_config and has_config.size > 0 then
		entry({"flexibity", "configuration", "torrents"}, cbi("flexibity/transmission"), i18n("Torrents"), 6)
	else
		entry({"flexibity", "configuration", "torrents"}, template("flexibity/torrent_empty"), i18n("Torrents"), 6)
	end
end

function action_empty()
	luci.template.render("flexibity/empty", {reset_avail = reset_avail})
end

