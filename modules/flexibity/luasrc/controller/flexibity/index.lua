--[[
LuCI - Lua Configuration Interface

Copyright 2011 Maxim Osipov <maxim.osipov@gmail.com>
Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: index.lua 5485 2009-11-01 14:24:04Z jow $
]]--

module("luci.controller.flexibity.index", package.seeall)

function index()
	luci.i18n.loadc("base")
	local i18n = luci.i18n.translate
        local uci = require("luci.model.uci").cursor()
        local net = require("luci.model.network").init(uci)

	local root = node()
	if not root.lock then
		root.target = alias("flexibity")
		root.index = true
	end
	
	entry({"about"}, template("about"))
	
	local page   = entry({"flexibity"}, alias("flexibity", "index"), i18n("Flexibity"), 10)
	page.sysauth = "root"
	page.sysauth_authenticator = "htmlauth"
	page.index = true
	
	entry({"flexibity", "index"}, alias("flexibity", "index", "index"), i18n("Connect"), 10).index = true
	entry({"flexibity", "index", "index"}, form("flexibity/index"), i18n("Overview"), 1)

	local has_wifi = nixio.fs.stat("/etc/config/wireless")
	if has_wifi and has_wifi.size > 0 then
		page = entry({"flexibity", "index", "wifi"}, arcombine(template("flexibity/wifi_overview"), cbi("flexibity/wifi")), i18n("Wi-Fi"), 3)
		page.leaf = true
		page = entry({"flexibity", "index", "wireless_status"}, call("wifi_status"), nil, 16)
		page.leaf = true
                local wdev
                for _, wdev in ipairs(net:get_wifidevs()) do
                        local wnet
                        for _, wnet in ipairs(wdev:get_wifinets()) do
                                entry(
                                        {"flexibity", "index", "wifi", wnet:id()},
                                        alias("flexibity", "index", "wifi"),
                                        nil
                                )
                        end
                end
	else
		page = entry({"flexibity", "index", "wifi"}, template("flexibity/wifi_empty"), i18n("Wi-Fi"), 3)
		page.leaf = true
	end

	entry({"flexibity", "index", "modem"}, template("flexibity/modem"), i18n("Modem"), 4)
		
	local has_motion = nixio.fs.stat("/etc/config/motion")
	if has_motion and has_motion.size > 0 then
		entry({"flexibity", "index", "webcam"}, template("flexibity/webcam"), i18n("Webcam"), 5)
		page = entry({"flexibity", "index", "webcam_snapshots"}, template("flexibity/webcam_snapshots"), nil, 17)
		page.leaf = true
		page = entry({"flexibity", "index", "snapshot_update"}, call("snapshot_update"), nil, 18)
		page.leaf = true
	else
		entry({"flexibity", "index", "webcam"}, template("flexibity/webcam_empty"), i18n("Webcam"), 5)
	end

	local has_transmission = nixio.fs.stat("/etc/config/transmission")
	if has_transmission and has_transmission.size > 0 then
	        entry({"flexibity", "index", "torrents"}, template("flexibity/torrent"), i18n("Torrents"), 6)
	else
	        entry({"flexibity", "index", "torrents"}, template("flexibity/torrent_empty"), i18n("Torrents"), 6)
	end

	entry({"flexibity", "index", "logout"}, call("action_logout"), i18n("Logout"), 9)
end

function snapshot_update()
	local fs = require "luci.fs"

	local image_direction = luci.http.formvalue("dir")
        local image_dir = "/www/cam1"
        local image_prefix = "/cam1"
	local image_files = luci.fs.dir(image_dir)
	local image_dates = { }
	local rv = { }
--[[
	luci.http.prepare_content("text/plain")
]]--
	for idx,image_file in ipairs(image_files) do
		image_dates[idx] = luci.fs.mtime(image_dir.."/"..image_file)
--[[
        	luci.http.write("image_file = "..image_file.." image_date = "..image_dates[idx].."\n")
]]--
	end

	local curr_image = luci.http.formvalue("image")
	if curr_image and curr_image ~= "" then
		curr_image = luci.fs.basename(curr_image)
		curr_time = luci.fs.mtime(image_dir.."/"..curr_image)
	else
		curr_image = ""
		curr_time = 0
	end
--[[
        luci.http.write("curr_image = "..curr_image.." curr_time = "..curr_time.."\n")
]]--
	--[[ search for last image ]]--
	local last_image = ""
	local last_time = luci.fs.mtime(image_dir)
	if curr_image == "" then
		last_image = ""
		last_time = 0
		if image_files then
			local image_file
			for idx,image_file in ipairs(image_files) do
				if image_file:match("jpg$") then
					local tmp_time = image_dates[idx]
					if tmp_time > last_time then
						last_time = tmp_time
						last_image = image_file
					end
				end
			end
		end
	--[[ search for next image ]]--
	else
		last_image = ""
		last_time = luci.fs.mtime(image_dir)
		if image_direction == "next" then
			if image_files then
				local image_file
				for idx,image_file in ipairs(image_files) do
					if image_file:match("jpg$") then
						local tmp_time = image_dates[idx]
						if tmp_time > curr_time and tmp_time <= last_time then
							last_time = tmp_time
							last_image = image_file
						end
					end
				end
			end
		end
		if last_image == "" then
			last_image = curr_image
			last_time = curr_time
		end
	end
	if last_image ~= "" then
		rv[#rv+1] = image_prefix.."/"..last_image
	end
--[[
        luci.http.write("last_image = "..last_image.." last_time = "..last_time.."\n")
]]--
	--[[ Find previous image  ]]--
	local prev_image = ""
	local prev_time = 0
	if image_files then
		local image_file
		for idx,image_file in ipairs(image_files) do
			if image_file:match("jpg$") then
				local tmp_time = image_dates[idx]
				if tmp_time < last_time and tmp_time > prev_time then
					prev_time = tmp_time
					prev_image = image_file
				end
			end
		end
	end
	if prev_image == "" then
		prev_image = last_image
		prev_time = last_time
	end
	if prev_image ~= "" then
		rv[#rv+1] = image_prefix.."/"..prev_image
	end
--[[
        luci.http.write("prev_image = "..prev_image.." prev_time = "..prev_time.."\n")
]]--
	if #rv > 0 then
		luci.http.prepare_content("application/json")
		luci.http.write_json(rv)
		return
	end

        luci.http.status(404, "File not found")
end

function wifi_status()
	local path = luci.dispatcher.context.requestpath
	local s    = require "luci.tools.status"
	local rv   = { }

	local dev
	for dev in path[#path]:gmatch("[%w%.%-]+") do
		rv[#rv+1] = s.wifi_network(dev)
	end

	if #rv > 0 then
		luci.http.prepare_content("application/json")
		luci.http.write_json(rv)
		return
	end

        luci.http.status(404, "No such device")
end

function action_logout()
	local dsp = require "luci.dispatcher"
	local sauth = require "luci.sauth"
	if dsp.context.authsession then
		sauth.kill(dsp.context.authsession)
		dsp.context.urltoken.stok = nil
	end

	luci.http.header("Set-Cookie", "sysauth=; path=" .. dsp.build_url())
	luci.http.redirect(luci.dispatcher.build_url())
end

