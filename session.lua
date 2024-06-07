local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local util = require("util")

wezterm.on("gui-startup", function()
	local tab, dockerPane, window = mux.spawn_window({
		cwd = util.vm_path() .. "/app/win10",
	})
	tab:set_title("docker")
	dockerPane:send_text("docker start -i 8d0")
	local vim, vimPane = window:spawn_tab({ cwd = util.vm_path() })
	vim:set_title("vim")
	vimPane:send_text("v\r\n")
	local yazi, yaziPane = window:spawn_tab({ cwd = util.vm_path() })
	yazi:set_title("yazi")
	yaziPane:send_text("ya\r\n")
	local shell = window:spawn_tab({ cwd = util.vm_path() })
	shell:set_title("shell")

	-- -- 4个快捷窗口,app,download,thunder,startup
	-- local tab, app, window = mux.spawn_window({
	--   cwd = util.vm_path() .. "/app/win10",
	-- })
	-- tab:set_title("vim")
	-- app:send_text("v\r\n")
	--
	-- local startup = app:split({
	--   size = 0.5,
	--   cwd = os.getenv("USERPROFILE") .. "/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup",
	-- })
	-- startup:send_text("lf\r\n")
	--
	-- local downloads = app:split({
	--   direction = "Bottom",
	--   size = 0.5,
	--   cwd = os.getenv("USERPROFILE") .. "/Downloads",
	-- })
	-- downloads:send_text("lf\r\n")
	--
	-- local thunder = startup:split({
	--   direction = "Bottom",
	--   size = 0.5,
	--   cwd = "E:\\迅雷下载",
	-- })
	-- thunder:send_text("lf\r\n")
	-- window:spawn_tab({ cwd = util.vm_path() })
	-- -- mux.spawn_window()
	-- -- mux.set_active_workspace("default")
end)
