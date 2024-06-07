local wezterm = require("wezterm")
local keymaps = require("keymaps")
local util = require("util")
require("session")

wezterm.on("update-right-status", function(window, pane)
	local name = window:active_key_table()
	if name then
		name = window:active_workspace() .. ":" .. name
	end
	window:set_right_status(name or "")
end)

local launch_menu = {}

if util.isWindows() then
	table.insert(launch_menu, {
		label = "cmd",
		args = { "cmd.exe" },
	})
else
	print("is unix")
end

local ssh_domains = {}

for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
	table.insert(ssh_domains, {
		name = host,
		remote_address = host,
		assume_shell = "Posix",
	})
	table.insert(launch_menu, {
		label = "SSH " .. host,
		args = { "ssh", host },
	})
end

return {
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	automatically_reload_config = false,
	ssh_domains = ssh_domains,
	-- disable_default_mouse_bindings = true,
	disable_default_key_bindings = true,
	check_for_updates = false,
	enable_scroll_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	show_tab_index_in_tab_bar = true,
	skip_close_confirmation_for_processes_named = {
		"bash",
		"btm",
		"btm.exe",
		"lf.exe",
		"lf",
		"sh",
		"zsh",
		"fish",
		"tmux",
		"cmd.exe",
		"wsl",
	},
	adjust_window_size_when_changing_font_size = false,
	-- font = wezterm.font("Inconsolata Nerd Font Mono", { weight = "Bold", stretch = "Expanded" }),
	font_size = 14,
	unzoom_on_switch_pane = false,
	launch_menu = launch_menu,
	default_prog = { "cmd.exe", "/s", "/k", "clink", "inject", "-q" },

	keys = keymaps.keys,
	key_tables = keymaps.key_tables,
	mouse_bindings = {
		{
			event = { Up = { streak = 1, button = "Right" } },
			mods = "NONE",
			action = wezterm.action.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
		},
	},
}
