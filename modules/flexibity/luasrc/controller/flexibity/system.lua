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

module("luci.controller.flexibity.system", package.seeall)

function index()
	luci.i18n.loadc("base")
	local i18n = luci.i18n.translate

	entry({"flexibity", "system"}, alias("flexibity", "system", "index"), i18n("System"), 90).index = true
        entry({"flexibity", "system", "index"}, form("flexibity/passwd"), i18n("Password"), 2)
	entry({"flexibity", "system", "upgrade"}, call("action_upgrade"), i18n("Upgrade"), 7)
	entry({"flexibity", "system", "reboot"}, call("action_reboot"), i18n("Reboot"), 100)
end

function action_reboot()
	local reboot = luci.http.formvalue("reboot")
	luci.template.render("flexibity/reboot", {reboot=reboot})
	if reboot then
		luci.sys.reboot()
	end
end

function action_upgrade()
        local sys = require "luci.sys"
        local fs  = require "luci.fs"

	local tmpfile = "/mnt/rootfs.tar.gz"

	-- Install upload handler
	local file
	luci.http.setfilehandler(
		function(meta, chunk, eof)
			if not nixio.fs.access(tmpfile) and not file and chunk and #chunk > 0 then
				file = io.open(tmpfile, "w")
			end
			if file and chunk then
				file:write(chunk)
			end
			if file and eof then
				file:close()
			end
		end
	)

        local is_root_sd = os.execute([[rdev | grep mmcblk >/dev/null 2>&1]]) == 0

	if is_root_sd then
		local upgrade = luci.http.formvalue("upgrade")
		luci.template.render("flexibity/upgrade_sd", {upgrade=upgrade})
		if upgrade then
			luci.sys.exec("mv /uImage /uImage.upgrade")
			luci.sys.reboot()
		end
	else
		-- Determine state
		local step         = tonumber(luci.http.formvalue("step") or 0)
		local has_image    = nixio.fs.access(tmpfile)
		local has_upload   = luci.http.formvalue("image")

		-- This does the actual extraction which is invoked inside an iframe
		if step == 5 then
			if has_image then
				-- Mimetype text/plain
				luci.http.prepare_content("text/plain")

				io.flush()

				-- Now invoke upgrade
				luci.http.write("Performing upgrade... ")
				luci.sys.exec("tar -C /mnt -xzf " .. tmpfile)
				luci.http.write("done.\n")

				luci.http.write("Removing temporary files... ")
				luci.sys.exec("rm " .. tmpfile)
				luci.http.write("done.\n")

				luci.http.write("Performing reboot...\n")
				luci.sys.reboot()
			else
				-- Mimetype text/plain
				luci.http.prepare_content("text/plain")
				luci.http.write("Cannot find firmware image. Please try again the upgrade process.\n")
       		        end

		-- Request upgrade permission
		elseif step == 0 then
			luci.template.render("flexibity/upgrade_df", { step=0 } )

		-- Prepare SD/MMC card, executed in iframe
		elseif step == 1 then
			-- format dataflash
			luci.http.prepare_content("text/plain")
			luci.http.write("Unmounting partition... ")
			luci.sys.exec("umount /mnt")
			luci.http.write("done.\n")

			luci.http.write("Creating partition table... ")
			luci.sys.exec("parted -s /dev/mmcblk0 mklabel msdos")
			luci.http.write("done.\n")

			luci.http.write("Creating partition structure... ")
			luci.sys.exec("parted -s /dev/mmcblk0 mkpart pri 0 100%")
			luci.http.write("done.\n")

			luci.http.write("Formatting partition... ")
			luci.sys.exec("mkfs.ext3 -L flexibity /dev/mmcblk0p1")
			luci.http.write("done.\n")

			luci.http.write("Mounting partition... ")
			luci.sys.exec("mount /dev/mmcblk0p1 /mnt")
			luci.http.write("done.\n")

			luci.http.write("Complete!\n")

		-- Upload firmware
		elseif step == 2 then
			luci.template.render("flexibity/upgrade_df", { step=2 } )

		-- Request upgrade continuation
		elseif step == 3 then
			luci.template.render("flexibity/upgrade_df", { step=3 } )

		-- Load iframe which calls the actual flash procedure
		elseif step == 4 then
			luci.template.render("flexibity/upgrade_df", { step=4 } )
		end
	end
end

