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

m = Map("motion", translate("Webcam"), translate("Here you can configure behavior of Motion webcam service."))

s = m:section(TypedSection, "motion", "")
s.anonymous = true
s.addremove = false
s:tab("device",  translate("Device"))
s:tab("detection", translate("Detection"))
s:tab("output", translate("Output"))
s:tab("snapshot", translate("Snapshot"))
s:tab("stream", translate("Stream"))
s:tab("control", translate("Control"))
s:tab("commands", translate("Commands"))
s:tab("database", translate("Database"))
s:tab("advanced", translate("Advanced"))

--[[ Device Settings ]]--

o = s:taboption("device", Flag, "_init", translate("Start Motion webcam service"))
o.rmempty = false
function o.cfgvalue(self, section)
        return luci.sys.init.enabled("motion") and self.enabled or self.disabled
end
function o.write(self, section, value)
        if value == "1" then
                luci.sys.call("/etc/init.d/motion enable >/dev/null")
                luci.sys.call("/etc/init.d/motion start >/dev/null")
        else
                luci.sys.call("/etc/init.d/motion stop >/dev/null")
                luci.sys.call("/etc/init.d/motion disable >/dev/null")
        end
end

o = s:taboption("device", Flag, "enabled", translate("Enabled"))
o.rmempty = false
o.default = "1"
o.disabled = "0"
o.enabled = "1"

o = s:taboption("device", Value, "videodevice", translate("Videodevice to be used for capturing"))
o.default = "/dev/video0"

o = s:taboption("device", ListValue, "v4l2_palette", translate("Preferable palette to be use by motion"))
o.default = "8"
o:value("0", "S910")
o:value("1", "BA81")
o:value("2", "MJPEG")
o:value("3", "JPEG")
o:value("4", "RGB3")
o:value("5", "UYVY")
o:value("6", "YUYV")
o:value("7", "422P")
o:value("8", "YU12")

o = s:taboption("device", Value, "input", translate("The video input to be used"), translate("Should normally be set to 0 or 1 for video/TV cards, and 8 for USB cameras"))
o.default = "8"

o = s:taboption("device", ListValue, "norm", translate("The video norm to use"))
o.default = "0"
o:value("0", "PAL")
o:value("1", "NTSC")
o:value("2", "SECAM")
o:value("3", "PAL NC no colour")

o = s:taboption("device", Value, "frequency", translate("The frequency to set the tuner to (kHz) (TV tuner only)"))
o.default = "0"

o = s:taboption("device", ListValue, "rotate", translate("Rotate image this number of degrees"))
o.default = "0"
o:value("0", "No rotation")
o:value("90", "90")
o:value("180", "180")
o:value("270", "270")

o = s:taboption("device", Value, "width", translate("Image width (pixels)"))
o.default = "352"

o = s:taboption("device", Value, "height", translate("Image height (pixels)"))
o.default = "288"

o = s:taboption("device", Value, "framerate", translate("Maximum number of frames to be captured per second (2-100)"))
o.default = "2"

o = s:taboption("device", Value, "minimum_frame_time", translate("Minimum time in seconds between capturing picture frames from the camera"), translate("This option is used when you want to capture images at a rate lower than 2 per second"))
o.default = "0"

o = s:taboption("device", Value, "netcam_url", translate("URL to use if you are using a network camera"), translate("Must be a URL that returns single jpeg pictures or a raw mjpeg stream"))

o = s:taboption("device", Value, "netcam_userpass", translate("Username and password for network camera (user:password)"))

o = s:taboption("device", ListValue, "netcam_http", translate("The setting for keep-alive of network socket"))
o.default = "1.0"
o:value("1.0", "HTTP/1.0, closing the socket after each http request")
o:value("keep_alive", "HTTP/1.0 requests with keep alive header");
o:value("1.1", "Use HTTP/1.1 requests that support keep alive");

o = s:taboption("device", Value, "netcam_proxy", translate("URL to use for a netcam proxy server"))

o = s:taboption("device", Flag, "netcam_tolerant_check", translate("Less strict jpeg checks for network cameras"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("device", Flag, "auto_brightness", translate("Let motion regulate the brightness of a video device"), translate("Only recommended for cameras without auto brightness"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("device", Value, "brightness", translate("Set the initial brightness of a video device (0-255)"))
o.default = "0"

o = s:taboption("device", Value, "contrast", translate("Set the contrast of a video device (0-255)"))
o.default = "0"

o = s:taboption("device", Value, "saturation", translate("Set the saturation of a video device (0-255)"))
o.default = "0"

o = s:taboption("device", Value, "hue", translate("Set the hue of a video device (NTSC feature) (0-255)"))
o.default = "0"

o = s:taboption("device", Value, "roundrobin_frames", translate("Number of frames to capture in each roundrobin step"))
o.default = "1"

o = s:taboption("device", Value, "roundrobin_skip", translate("Number of frames to skip before each roundrobin step"))
o.default = "1"

o = s:taboption("device", Flag, "switchfilter", translate("Try to filter out noise generated by roundrobin"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

--[[ Detection Settings ]]--

o = s:taboption("detection", Value, "threshold", translate("Threshold for number of changed pixels in an image that triggers motion detection"))
o.default = "1500"

o = s:taboption("detection", Flag, "threshold_tune", translate("Automatically tune the threshold down if possible"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("detection", Value, "noise_level", translate("Noise threshold for the motion detection"))
o.default = "32"

o = s:taboption("detection", Flag, "noise_tune", translate("Automatically tune the noise threshold"))
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("detection", Value, "despeckle", translate("Despeckle motion image using (e)rode or (d)ilate or (l)abel"), translate("Recommended value is EedDl. Any combination (and number of) of E, e, d, and D is valid. (l)abeling must only be used once and the 'l' must be the last letter."))

o = s:taboption("detection", Value, "area_detect", translate("Detect motion in predefined areas (1-9)"), translate("One or more areas can be specified with this option"))

o = s:taboption("detection", Value, "mask_file", translate("PGM file to use as a sensitivity mask"))

o = s:taboption("detection", Value, "smart_mask_speed", translate("Dynamically create a mask file during operation)"), translate("Adjust speed of mask changes from 0 (off) to 10 (fast)"))
o.default = "0"

o = s:taboption("detection", Value, "lightswitch", translate("Ignore sudden massive light intensity changes (0-100% of picture)"))
o.default = "0"

o = s:taboption("detection", Value, "minimum_motion_frames", translate("Minimum motion frames"), translate("Picture frames must contain motion at least the specified number of frames in a row before they are detected as true motion"))
o.default = "1"

o = s:taboption("detection", Value, "pre_capture", translate("Number of pre-captured pictures in output (0-5)"))
o.default = "0"

o = s:taboption("detection", Value, "post_capture", translate("Number of post-captured pictures in output"))
o.default = "0"

o = s:taboption("detection", Value, "gap", translate("Gap is the seconds of no motion detection"))
o.default = "60"

o = s:taboption("detection", Value, "max_mpeg_time", translate("Maximum length in seconds of an mpeg movie"), translate("When value is exceeded a new mpeg file is created"))
o.default = "0"

o = s:taboption("detection", Flag, "output_all", translate("Always save images even if there was no motion"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

--[[ Output Settings ]]--

o = s:taboption("output", ListValue, "output_normal", translate("Output 'normal' pictures when motion is detected"))
o.default = "on"
o:value("on", "On")
o:value("off", "Off")
o:value("first", "First")
o:value("best", "Best")
o:value("center", "Center")

o = s:taboption("output", Flag, "output_motion", translate("Output pictures with only the pixels moving object"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("output", Value, "quality", translate("The quality (in percent) to be used by the jpeg compression"))
o.default = "75"

o = s:taboption("output", Flag, "ppm", translate("Output ppm images instead of jpeg"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("output", Flag, "ffmpeg_cap_new", translate("Use ffmpeg to encode mpeg movies in realtime"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("output", Flag, "ffmpeg_cap_motion", translate("Use ffmpeg to make movies with only the pixels moving"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("output", Value, "ffmpeg_timelapse", translate("Use ffmpeg to encode a timelapse movie"), translate("0 = off - else save frame every Nth second"))
o.default = "0"

o = s:taboption("output", ListValue, "ffmpeg_timelapse_mode", translate("The file rollover mode of the timelapse video"))
o.default = "daily"
o:value("hourly", "Hourly")
o:value("daily", "Daily")
o:value("weekly-sunday", "Weekly on Sundays")
o:value("weekly-monday", "Weekly on Mondays")
o:value("monthly", "Monthly")
o:value("manual", "Manual")

o = s:taboption("output", Value, "ffmpeg_bps", translate("Bitrate to be used by the ffmpeg encoder"), translate("This option is ignored if ffmpeg_variable_bitrate is not 0"))
o.default = "500000"

o = s:taboption("output", Value, "ffmpeg_variable_bitrate", translate("Enables and defines variable bitrate for the ffmpeg encoder"), translate("0 = fixed bitrate defined by ffmpeg_bps, or the range 2 - 31 where 2 means best quality and 31 is worst"))
o.default = "0"

o = s:taboption("output", ListValue, "ffmpeg_video_codec", translate("Codec to used by ffmpeg for the video compression"))
o.default = "mpeg4"
o:value("mpeg1", "MPEG1")
o:value("mpeg4", "MPEG4")
o:value("msmpeg4", "Microsoft MPEG4")
o:value("swf", "SWF");
o:value("flv", "FLV")
o:value("ffv1", "FF video codec 1")
o:value("mov", "QuickTime")

o = s:taboption("output", Flag, "ffmpeg_deinterlace", translate("Use ffmpeg to deinterlace video"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

--[[ Snapshot Settings ]]--

o = s:taboption("snapshot", Value, "snapshot_interval", translate("Make automated snapshot every N seconds"))
o.default = "0"

o = s:taboption("snapshot", ListValue, "locate", translate("Locate and draw a box around the moving object"))
o.default = "off"
o:value("off", "Off")
o:value("on", "On")
o:value("preview", "Preview")

o = s:taboption("snapshot", Value, "text_right", translate("Draw the timestamp"), translate("Text is placed in lower right corner"))
o.default = "%Y-%m-%d\n%T-%q"

o = s:taboption("snapshot", Value, "text_left", translate("Draw a user defined text on the images"), translate("Text is placed in lower left corner"))

o = s:taboption("snapshot", Flag, "text_changes", translate("Draw the number of changed pixed on the images"), translate("Text is placed in upper right corner"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("snapshot", Value, "text_event", translate("Value of the special event conversion specifier %C"))
o.default = "%Y%m%d%H%M%S"

o = s:taboption("snapshot", Flag, "text_double", translate("Draw characters at twice normal size on images"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("snapshot", Value, "target_dir", translate("Target base directory for pictures and films"))
o.default = "/usr/local/apache2/htdocs/cam1"

o = s:taboption("snapshot", Value, "snapshot_filename", translate("File path for snapshots (jpeg or ppm) (relative)"))
o.default = "%v-%Y%m%d%H%M%S-snapshot"

o = s:taboption("snapshot", Value, "jpeg_filename", translate("File path for motion triggered images (relative)"))
o.default = "%v-%Y%m%d%H%M%S-%q"

o = s:taboption("snapshot", Value, "movie_filename", translate("File path for motion triggered ffmpeg films (relative)"))
o.default = "%v-%Y%m%d%H%M%S"

o = s:taboption("snapshot", Value, "timelapse_filename", translate("File path for timelapse mpegs (relative)"))
o.default = "%Y%m%d-timelapse"

--[[ Stream Settings ]]--

o = s:taboption("stream", Value, "webcam_port", translate("The mini-http server listens to this port for requests"))
o.default = "8080"

o = s:taboption("stream", Value, "webcam_quality", translate("Quality of the jpeg (in percent) images produced"))
o.default = "50"

o = s:taboption("stream", Flag, "webcam_motion", translate("Output frames at 1 fps when no motion is detected and increase when detected"))
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("stream", Value, "webcam_maxrate", translate("Maximum framerate for webcam streams"))
o.default = "1"

o = s:taboption("stream", Flag, "webcam_localhost", translate("Restrict webcam connections to localhost only"))
o.rmempty = false
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("stream", Value, "webcam_limit", translate("Limits the number of images per connection"))
o.default = "0"

--[[ Control Settings ]]--

o = s:taboption("control", Value, "control_port", translate("TCP/IP port for the http server to listen on"))
o.default = "8081"

o = s:taboption("control", Flag, "control_localhost", translate("Restrict control connections to localhost only"))
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("control", Flag, "control_html_output", translate("Output for http server, select off to choose raw text plain"))
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("control", Value, "control_authentication", translate("Authentication for the http based control (username:password)"))

o = s:taboption("control", ListValue, "track_type", translate("Type of tracker"))
o.default = "0"
o:value("0", "None")
o:value("1", "Stepper")
o:value("2", "Iomojo")
o:value("3", "PWC")
o:value("4", "Generic")
o:value("5", "UVCvideo")

o = s:taboption("control", Flag, "track_auto", translate("Enable auto tracking"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("control", Value, "track_port", translate("Serial port of motor"))

o = s:taboption("control", Value, "track_motorx", translate("Motor number for x-axis"))
o.default = "0"

o = s:taboption("control", Value, "track_motory", translate("Motor number for y-axis"))
o.default = "0"

o = s:taboption("control", Value, "track_maxx", translate("Maximum value on x-axis"))
o.default = "0"

o = s:taboption("control", Value, "track_maxy", translate("Maximum value on y-axis"))
o.default = "0"

o = s:taboption("control", Value, "track_iomojo_id", translate("ID of an iomojo camera if used"))
o.default = "0"

o = s:taboption("control", Value, "track_step_angle_x", translate("Angle in degrees the camera moves per step on the X-axis"), translate("Currently only used with pwc type cameras"))
o.default = "10"

o = s:taboption("control", Value, "track_step_angle_y", translate("Angle in degrees the camera moves per step on the Y-axis"), translate("Currently only used with pwc type cameras"))
o.default = "10"

o = s:taboption("control", Value, "track_move_wait", translate("Delay to wait for after tracking movement as number of picture frames"))
o.default = "10"

o = s:taboption("control", Value, "track_speed", translate("Speed to set the motor to (stepper motor option)"))
o.default = "255"

o = s:taboption("control", Value, "track_stepsize", translate("Number of steps to make (stepper motor option)"))
o.default = "40"

--[[ Commands Settings ]]--

o = s:taboption("commands", Flag, "quiet", translate("Do not sound beeps when detecting motion"))
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("commands", Value, "on_event_start", translate("Command to be executed when an event starts"))

o = s:taboption("commands", Value, "on_event_end", translate("Command to be executed when an event ends after a period of no motion"))

o = s:taboption("commands", Value, "on_picture_save", translate("Command to be executed when a picture (.ppm|.jpg) is saved"))

o = s:taboption("commands", Value, "on_motion_detected", translate("Command to be executed when a motion frame is detected"))

o = s:taboption("commands", Value, "on_area_detected", translate("Command to be executed when motion in a predefined area is detected"))

o = s:taboption("commands", Value, "on_movie_start", translate("Command to be executed when a movie file (.mpg|.avi) is created"))

o = s:taboption("commands", Value, "on_movie_end", translate("Command to be executed when a movie file (.mpg|.avi) is closed"))

o = s:taboption("commands", Value, "on_camera_lost", translate("Command to be executed when a camera cant be opened or if it is lost"), "There is situations when motion doesnt detect a lost camera and this can lock the device!")


--[[ Database Settings ]]--

o = s:taboption("database", Flag, "sql_log_image", translate("Log to the database when creating motion triggered image file"))
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("database", Flag, "sql_log_snapshot", translate("Log to the database when creating a snapshot image file"))
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("database", Flag, "sql_log_mpeg", translate("Log to the database when creating motion triggered mpeg file"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("database", Flag, "sql_log_timelapse", translate("Log to the database when creating timelapse mpeg file"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("database", Value, "sql_query", translate("SQL query string that is sent to the database"))
o.default = "insert into security(camera, filename, frame, file_type, time_stamp, event_time_stamp) values('%t', '%f', '%q', '%n', '%Y-%m-%d %T', '%C')"

o = s:taboption("database", Value, "mysql_db", translate("Mysql database to log to"))

o = s:taboption("database", Value, "mysql_host", translate("The host on which the database is located"))

o = s:taboption("database", Value, "mysql_user", translate("User account name for MySQL database"))

o = s:taboption("database", Value, "mysql_password", translate("User password for MySQL database"))

o = s:taboption("database", Value, "pgsql_db", translate("PostgreSQL database to log to"))

o = s:taboption("database", Value, "pgsql_host", translate("The host on which the database is located"))

o = s:taboption("database", Value, "pgsql_user", translate("User account name for PostgreSQL database"))

o = s:taboption("database", Value, "pgsql_password", translate("User password for PostgreSQL database"))

o = s:taboption("database", Value, "pgsql_port", translate("Port on which the PostgreSQL database is located"))
o.default = "5432"

--[[ Advanced Settings ]]--

o = s:taboption("advanced", Flag, "daemon", translate("Start in daemon (background) mode and release terminal"))
o.default = "on"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("advanced", Value, "process_id_file", translate("File to store the process ID"))
o.default = "/var/run/motion.pid"

o = s:taboption("advanced", Flag, "setup_mode", translate("Start in Setup-Mode, daemon disabled"))
o.default = "off"
o.disabled = "off"
o.enabled = "on"

o = s:taboption("advanced", Value, "video_pipe", translate("Output images to a video4linux loopback device"))

o = s:taboption("advanced", Value, "motion_video_pipe", translate("Output motion images to a video4linux loopback device"))

return m

