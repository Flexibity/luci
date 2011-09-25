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

m = Map("transmission", translate("Torrents"), translate("Here you can configure behavior of Transmission torrents client."))

s = m:section(TypedSection, "transmission", "")
s.anonymous = true
s.addremove = false
s:tab("general",  translate("General"))
s:tab("network", translate("Network"))
s:tab("speed", translate("Speed"))
s:tab("rpc", translate("RPC"))
s:tab("peer", translate("Peer"))
s:tab("advanced", translate("Advanced"))

--[[ General settings ]]--
o = s:taboption("general", Flag, "_init", translate("Start Transmission torrents service"))
o.rmempty = false
function o.cfgvalue(self, section)
        return luci.sys.init.enabled("transmission") and self.enabled or self.disabled
end
function o.write(self, section, value)
        if value == "1" then
                luci.sys.call("/etc/init.d/transmission enable >/dev/null")
                luci.sys.call("/etc/init.d/transmission start >/dev/null")
        else
                luci.sys.call("/etc/init.d/transmission stop >/dev/null")
                luci.sys.call("/etc/init.d/transmission disable >/dev/null")
        end
end

o = s:taboption("general", Flag, "enabled", translate("Enabled"))
o.rmempty = false
o.default = "1"
o.disabled = "0"
o.enabled = "1"
o = s:taboption("general", Flag, "start_added_torrents", translate("Start added torrents"))
o.rmempty = false
o.default = "true"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("general", Value, "config_dir", translate("Config directory"))
o.rmempty = false
o.default = "/tmp/transmission"
o = s:taboption("general", Value, "download_dir", translate("Download directory"))
o.rmempty = false
o.default = "/tmp/transmission/done"
o = s:taboption("general", Flag, "incomplete_dir_enabled", translate("Enable incomplete directory"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("general", Value, "incomplete_dir", translate("Incomplete directory"))
o.rmempty = true
o.default = "/tmp/transmission/incomplete"
o:depends("incomplete_dir_enabled", "true")
o = s:taboption("general", Flag, "watch_dir_enabled", translate("Enable watch directory"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("general", Value, "watch_dir", translate("Watch directory"))
o.rmempty = true
o.default = ""
o:depends("watch_dir_enabled", "true")
o = s:taboption("general", Flag, "script_torrent_done_enabled", translate("Enable torrent done script"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("general", Value, "script_torrent_done_filename", translate("Torrent done script file"))
o.rmempty = true
o.default = ""
o:depends("script_torrent_done_enabled", "true")

--[[ Network Settings ]]--
o = s:taboption("network", Value, "bind_address_ipv4", translate("IPV4 bind address"))
o.rmempty = false
o.default = "0.0.0.0"
o = s:taboption("network", Value, "bind_address_ipv6", translate("IPV6 bind address"))
o.rmempty = false
o.default = "::"

o = s:taboption("network", Flag, "blocklist_enabled", translate("Blocklist enabled"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("network", Value, "blocklist_url", translate("Blocklist URL"))
o.rmempty = true
o.default = ""
o:depends("blocklist_enabled", "true")

o = s:taboption("network", Flag, "port_forwarding_enabled", translate("Enable port forwarding"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"

--[[ Speed settings ]]--

o = s:taboption("speed", Flag, "ratio_limit_enabled", translate("Enable ratio limit"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("speed", Value, "ratio_limit", translate("Ratio limit"))
o.rmempty = true
o.default = "2.0000"
o:depends("ratio_limit_enabled", "true")

o = s:taboption("speed", Flag, "speed_limit_down_enabled", translate("Enable down speed limit"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("speed", Value, "speed_limit_down", translate("Down speed limit"))
o.rmempty = true
o.default = "100"
o:depends("speed_limit_down_enabled", "true")
o = s:taboption("speed", Flag, "speed_limit_up_enabled", translate("Up speed limit enabled"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("speed", Value, "speed_limit_up", translate("Up speed limit"))
o.rmempty = true
o.default = "20"
o:depends("speed_limit_up_enabled", "true")

o = s:taboption("speed", Flag, "alt_speed_enabled", translate("Enable alternative speed"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("speed", Value, "alt_speed_down", translate("Alternative down speed"))
o.rmempty = true
o.default = "50"
o:depends("alt_speed_enabled", "true")
o = s:taboption("speed", Value, "alt_speed_up", translate("Alternative up speed"))
o.rmempty = true
o.default = "50"
o:depends("alt_speed_enabled", "true")
o = s:taboption("speed", Flag, "alt_speed_time_enabled", translate("Alternative speed time enabled"))
o.rmempty = true
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o:depends("alt_speed_enabled", "true")
o = s:taboption("speed", Value, "alt_speed_time_begin", translate("Alternative speed begin time"))
o.rmempty = true
o.default = "540"
o:depends("alt_speed_time_enabled", "true")
o = s:taboption("speed", Value, "alt_speed_time_day", translate("Alternative speed day"))
o.rmempty = true
o.default = "127"
o:depends("alt_speed_time_enabled", "true")
o = s:taboption("speed", Value, "alt_speed_time_end", translate("Alternative speed time end"))
o.rmempty = true
o.default = "1020"
o:depends("alt_speed_time_enabled", "true")

--[[ RPC settings ]]--

o = s:taboption("rpc", Flag, "rpc_enabled", translate("Enable RPC"), translate("Required for web interface!"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("rpc", Value, "rpc_port", translate("RPC port"), translate("Port 9091 on localhost required for web interface!"))
o.rmempty = true
o.default = "9091"
o:depends("rpc_enabled", "true")
o = s:taboption("rpc", Value, "rpc_url", translate("RPC URL"))
o.rmempty = true
o.default = "/transmission/"
o:depends("rpc_enabled", "true")
o = s:taboption("rpc", Value, "rpc_bind_address", translate("RPC bind address"))
o.rmempty = true
o.default = "0.0.0.0"
o:depends("rpc_enabled", "true")
o = s:taboption("rpc", Flag, "rpc_whitelist_enabled", translate("Enable RPC whitelists"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o:depends("rpc_enabled", "true")
o = s:taboption("rpc", Value, "rpc_whitelist", translate("RPC whitelist"))
o.rmempty = true
o.default = "127.0.0.1,192.168.119.*"
o:depends("rpc_whitelist_enabled", "true")
o = s:taboption("rpc", Flag, "rpc_authentication_required", translate("RPC authentication required"))
o.rmempty = true
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o:depends("rpc_enabled", "true")
o = s:taboption("rpc", Value, "rpc_username", translate("RPC user name"))
o.rmempty = true
o.default = ""
o:depends("rpc_authentication_required", "true")
o = s:taboption("rpc", Value, "rpc_password", translate("RPC password"))
o.rmempty = true
o.default = ""
o:depends("rpc_authentication_required", "true")

--[[ Peer settings ]]--

o = s:taboption("peer", Value, "peer_port", translate("Peer port"))
o.rmempty = false
o.default = "51413"
o = s:taboption("peer", Value, "peer_port_random_high", translate("Peer randop port high"))
o.rmempty = false
o.default = "65535"
o = s:taboption("peer", Value, "peer_port_random_low", translate("Peer random port low"))
o.rmempty = false
o.default = "49152"
o = s:taboption("peer", Flag, "peer_port_random_on_start", translate("Enable random peer port on start"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("peer", Value, "peer_socket_tos", translate("Peer socket ToS"))
o.rmempty = false
o.default = "0"
o = s:taboption("peer", Value, "peer_congestion_algorithm", translate("Peer congestion algorithm"))
o.rmempty = true
o.default = ""
o = s:taboption("peer", Value, "peer_limit_global", translate("Peer global limit"))
o.rmempty = false
o.default = "240"
o = s:taboption("peer", Value, "peer_limit_per_torrent", translate("Peer limit per torrent"))
o.rmempty = false
o.default = "60"

--[[ Advanced settings ]]--

o = s:taboption("advanced", Value, "cache_size_mb", translate("Cache size in MB"))
o.rmempty = false
o.default = "2"
o = s:taboption("advanced", Flag, "dht_enabled", translate("DHT Enabled"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("advanced", Flag, "encryption", translate("Enable encryption"))
o.rmempty = false
o.default = "1"
o.disabled = "0"
o.enabled = "1"

o = s:taboption("advanced", Flag, "idle_seeding_limit_enabled", translate("Enable idle seeding limit"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("advanced", Value, "idle_seeding_limit", translate("Idle seeding limit"))
o.rmempty = true
o.default = "30"
o:depends("idle_seeding_limit_enabled", "true")

o = s:taboption("advanced", Flag, "lazy_bitfield_enabled", translate("Lazy bitfield enabled"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("advanced", Flag, "lpd_enabled", translate("LPD enabled"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("advanced", Value, "message_level", translate("Message level"))
o.rmempty = false
o.default = "1"
o = s:taboption("advanced", Value, "open_file_limit", translate("Open file limit"))
o.rmempty = false
o.default = "32"
o = s:taboption("advanced", Flag, "pex_enabled", translate("Enable PEX"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("advanced", Flag, "preallocation", translate("Preallocation"))
o.rmempty = false
o.default = "1"
o.disabled = "0"
o.enabled = "1"
o = s:taboption("advanced", Flag, "prefetch_enabled", translate("Enable prefetch"))
o.rmempty = false
o.default = "1"
o.disabled = "0"
o.enabled = "1"
o = s:taboption("advanced", Flag, "rename_partial_files", translate("Rename partial files"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("advanced", Flag, "trash_original_torrent_files", translate("Trash original torrent files"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("advanced", Value, "run_daemon_as_user", translate("Transmission user"))
o.rmempty = false
o.default = "root"
o = s:taboption("advanced", Value, "umask", translate("Files umask"))
o.rmempty = false
o.default = "18"
o = s:taboption("advanced", Value, "upload_slots_per_torrent", translate("Upload slots per torrent"))
o.rmempty = false
o.default = "14"
o = s:taboption("advanced", Flag, "utp_enabled", translate("Enable UTP"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"
o = s:taboption("advanced", Flag, "scrape_paused_torrents", translate("Scrape paused torrents"))
o.rmempty = false
o.default = "false"
o.disabled = "false"
o.enabled = "true"

return m
