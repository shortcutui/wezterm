local wezterm = require("wezterm")
local util = require("util")
local act = wezterm.action
local mux = wezterm.mux

local M = {}

local closeOtherPane = function(confirm)
	return function(window, pane)
		local tab = pane:tab()
		local panes = tab:panes()
		local pid = pane:pane_id()
		for _, p in ipairs(panes) do
			if p:pane_id() ~= pid then
				p:activate()
				window:perform_action(act.CloseCurrentPane({ confirm = confirm }), p)
			end
		end
	end
end

local notImplemented = wezterm.action_callback(function()
	util.notify("not implemented")
end)

function startsWithIgnoreCase(str, start)
	return string.lower(string.sub(str, 1, string.len(start))) == string.lower(start)
end

local findTab = function(prefix)
	return function(window, pane)
		local tab = pane:tab()
		local w = tab:window()
		local tabs = w:tabs()
		for _, t in ipairs(tabs) do
			if startsWithIgnoreCase(t:get_title(), prefix) then
				t:activate()
			end
		end
	end
end

local paneMoveTo = function(prefix, focus)
	return function(window, pane)
		util.notify("not implemented")
		-- local tab = pane:tab()
		-- local w = tab:window()
		-- local tabs = w:tabs()
		-- for _, t in ipairs(tabs) do
		-- 	if startsWithIgnoreCase(t:get_title(), prefix) then
		-- 		t:activate()
		-- 	end
		-- end
	end
end

local keys = {
	--  {
	--     key = 'y',
	--     mods = 'SUPER',
	--     -- 这个是输入emoji等特殊字符的
	--     action = wezterm.action.CharSelect {
	--       copy_on_select = true,
	--       copy_to = 'ClipboardAndPrimarySelection',
	--     },
	--   },
	{
		key = "v",
		mods = "CTRL",
		action = act.PasteFrom("Clipboard"),
	},
	{
		key = "c",
		mods = "CTRL|ALT",
		action = act.QuickSelect,
	},
	{
		key = "q",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "quit",
			timeout_milliseconds = 1000,
		}),
	},
	{
		key = "y",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "cuscopy",
			one_shot = true,
			timeout_milliseconds = 2000,
		}),
	},
	{
		key = "l",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "launch",
			timeout_milliseconds = 1000,
		}),
	},
	{ key = "n", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "o", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "i", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "r", mods = "CTRL|ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "LeftArrow", mods = "CTRL|ALT", action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "CTRL|ALT", action = act.ActivateTabRelative(1) },
	-- { key = "UpArrow", mods = "SUPER", action = notImplemented },
	-- { key = "DownArrow", mods = "SUPER", action = notImplemented },
	{
		key = "g",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "goquick",
			timeout_milliseconds = 1000,
		}),
	},
	{
		key = "s",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "resize",
			one_shot = false,
		}),
	},
	{
		key = "w",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "window",
		}),
	},
	{
		key = "t",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "tab",
		}),
	},
	{
		key = "m",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "move",
		}),
	},
	{
		key = "d",
		mods = "CTRL|ALT",
		action = act.ActivateKeyTable({
			name = "deliver",
		}),
	},
	-- { key = "RightArrow", mods = "SHIFT", action = act.CopyMode("MoveRight") },
	-- { key = "LeftArrow", mods = "SHIFT", action = act.CopyMode("MoveLeft") },
	-- { mods = "CTRL|SHIFT", key = "LeftArrow", action = act.SendString "\x1bf" }
}

local key_tables = {
	search_mode = {
		{
			key = "Enter",
			mods = "",
			action = act.Multiple({ { CopyMode = "AcceptPattern" } }),
		},
		{ key = "Tab", mods = "", action = act.CopyMode("NextMatch") },
		{ key = "Tab", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
	},
	copy_mode = {
		{ key = "Tab", mods = "", action = act.CopyMode("NextMatch") },
		{ key = "Tab", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
		{ key = "s", mods = "", action = act.CopyMode("EditPattern") },
		{
			key = "Enter",
			mods = "",
			action = act.Multiple({ { CopyMode = "AcceptPattern" } }),
		},
		{
			key = "l",
			mods = "",
			action = act.Multiple({
				act.CopyMode("Close"),
				wezterm.action_callback(function(window, pane)
					wezterm.time.call_after(0.1, function()
						window:perform_action(act.QuickSelect, pane)
					end)
				end),
			}),
		},
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "End", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "Home", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
		},
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "LeftArrow", mods = "SUPER", action = act.CopyMode("MoveBackwardWord") },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "RightArrow", mods = "SUPER", action = act.CopyMode("MoveForwardWord") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
	},
	cuscopy = {
		{
			key = "p", -- copy file path
			action = act.QuickSelectArgs({
				patterns = {
					"/\\S*",
					"[a-zA-Z]:\\\\\\S*",
					"[a-zA-Z]:/\\S*",
					'".+"',
					"'.+'",
				},
			}),
		},
		{
			key = "w", -- copy word
			action = act.QuickSelectArgs({
				patterns = {
					"\\w+",
				},
			}),
		},
		{
			key = "c", -- copy command line
			action = act.QuickSelectArgs({
				patterns = {
					"[❯$] s*(.+)",
				},
			}),
		},
		{
			key = "l", -- copy link
			action = act.QuickSelectArgs({
				patterns = {
					"https?://\\S+",
				},
			}),
		},
		{
			key = "y",
			action = act.ActivateCopyMode,
		},
	},
	launch = {
		{ key = "Escape", action = act.PopKeyTable },
		{
			key = "w",
			action = act.PromptInputLine({
				description = "(launch program)Enter yout program name",
				action = wezterm.action_callback(function(window, pane, line)
					window:perform_action(act.SplitVertical({ args = { line } }), pane)
				end),
			}),
		},
		{ key = "W", action = act.ShowLauncher },
		{ key = "v", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "h", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "f", action = notImplemented }, -- no floating window
		{
			key = "t",
			action = act.PromptInputLine({
				description = "(launch in new tab)Enter yout program name",
				action = wezterm.action_callback(function(window, pane, line)
					window:perform_action(act.SpawnCommandInNewTab({ args = { line } }), pane)
				end),
			}),
		},
		{ key = "l", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = ".", action = act.ActivateCommandPalette },
		{ key = "c", action = act.ReloadConfiguration },
		{ key = "S", action = notImplemented },
		{ key = "s", action = notImplemented },
		{ key = "R", action = notImplemented },
		{ key = "r", action = notImplemented },
	},
	quit = {
		{ key = "Escape", action = act.PopKeyTable },
		{ key = "a", action = notImplemented }, -- close all tab
		{ key = "q", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "w", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "t", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "o", action = wezterm.action_callback(closeOtherPane(true)) },
		{ key = "l", action = notImplemented }, -- close other tab
		{ key = "A", action = notImplemented }, -- close all tab
		{ key = "Q", action = act.CloseCurrentPane({ confirm = false }) },
		{ key = "W", action = act.CloseCurrentPane({ confirm = false }) },
		{ key = "T", action = act.CloseCurrentTab({ confirm = false }) },
		{ key = "O", action = wezterm.action_callback(closeOtherPane(false)) },
		{ key = "L", action = notImplemented }, -- close ohter tab
	},
	goquick = {
		{ key = "Escape", action = act.PopKeyTable },
		{
			key = "n",
			action = act.Multiple({
				act.ActivateLastTab,
				act.PopKeyTable,
			}),
		},
		{
			key = "o",
			action = act.Multiple({
				act.ActivateLastTab,
				act.PopKeyTable,
			}),
		},
		{ key = ".", action = notImplemented },
		{ key = "t", action = notImplemented },
	},
	resize = { -- resize && rename
		{ key = "Escape", action = act.PopKeyTable },
		{
			key = ".", -- switch workspace, session
			action = act.Multiple({
				act.PopKeyTable,
				wezterm.action_callback(function(window, pane)
					local choices = {}
					for _, value in ipairs(mux.get_workspace_names()) do
						table.insert(choices, { label = value })
					end
					window:perform_action(
						act.InputSelector({
							action = wezterm.action_callback(function(w, p, id, label)
								mux.set_active_workspace(label)
							end),
							title = "Choose a workspace",
							choices = choices,
						}),
						pane
					)
				end),
			}),
		},
		{
			key = "t", -- rename tab
			action = act.Multiple({
				act.PopKeyTable,
				act.PromptInputLine({
					description = "Enter new name for current tab",
					action = wezterm.action_callback(function(window, pane, line)
						if line then
							window:active_tab():set_title(line)
						end
					end),
				}),
			}),
		},
		{ key = "w", action = notImplemented }, -- rename window
		{ key = "f", action = notImplemented }, -- move window floating
		{ key = "n", action = act.AdjustPaneSize({ "Left", 10 }) },
		{ key = "o", action = act.AdjustPaneSize({ "Right", 10 }) },
		{ key = "r", action = act.AdjustPaneSize({ "Up", 10 }) },
		{ key = "i", action = act.AdjustPaneSize({ "Down", 10 }) },
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "m", action = act.Multiple({ act.TogglePaneZoomState, act.PopKeyTable }) },
		{ key = "z", action = act.Multiple({ act.ToggleFullScreen, act.PopKeyTable }) },
		{ key = "h", action = notImplemented },
		{ key = "u", action = act.IncreaseFontSize },
		{ key = "d", action = act.DecreaseFontSize },
		{ key = "s", action = act.ResetFontAndWindowSize },
	},
	window = {
		{ key = "Escape", action = act.PopKeyTable },
		{
			key = ".",
			action = act.Multiple({
				act.PaneSelect,
				act.PopKeyTable,
			}),
		},
	},
	tab = {
		{ key = "Escape", action = act.PopKeyTable },
		{ key = ".", action = act.ShowTabNavigator },
		{ key = "a", action = wezterm.action_callback(findTab("a")) },
		{ key = "b", action = wezterm.action_callback(findTab("b")) },
		{ key = "c", action = wezterm.action_callback(findTab("c")) },
		{ key = "d", action = wezterm.action_callback(findTab("d")) },
		{ key = "e", action = wezterm.action_callback(findTab("e")) },
		{ key = "f", action = wezterm.action_callback(findTab("f")) },
		{ key = "g", action = wezterm.action_callback(findTab("g")) },
		{ key = "h", action = wezterm.action_callback(findTab("h")) },
		{ key = "i", action = wezterm.action_callback(findTab("i")) },
		{ key = "j", action = wezterm.action_callback(findTab("j")) },
		{ key = "k", action = wezterm.action_callback(findTab("k")) },
		{ key = "l", action = wezterm.action_callback(findTab("l")) },
		{ key = "m", action = wezterm.action_callback(findTab("m")) },
		{ key = "n", action = wezterm.action_callback(findTab("n")) },
		{ key = "o", action = wezterm.action_callback(findTab("o")) },
		{ key = "p", action = wezterm.action_callback(findTab("p")) },
		{ key = "q", action = wezterm.action_callback(findTab("q")) },
		{ key = "r", action = wezterm.action_callback(findTab("r")) },
		{ key = "s", action = wezterm.action_callback(findTab("s")) },
		{ key = "t", action = wezterm.action_callback(findTab("t")) },
		{ key = "u", action = wezterm.action_callback(findTab("u")) },
		{ key = "v", action = wezterm.action_callback(findTab("v")) },
		{ key = "w", action = wezterm.action_callback(findTab("w")) },
		{ key = "x", action = wezterm.action_callback(findTab("x")) },
		{ key = "y", action = wezterm.action_callback(findTab("y")) },
		{ key = "z", action = wezterm.action_callback(findTab("z")) },
		{ key = "a", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("a")) },
		{ key = "b", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("b")) },
		{ key = "c", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("c")) },
		{ key = "d", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("d")) },
		{ key = "e", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("e")) },
		{ key = "f", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("f")) },
		{ key = "g", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("g")) },
		{ key = "h", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("h")) },
		{ key = "i", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("i")) },
		{ key = "j", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("j")) },
		{ key = "k", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("k")) },
		{ key = "l", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("l")) },
		{ key = "m", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("m")) },
		{ key = "n", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("n")) },
		{ key = "o", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("o")) },
		{ key = "p", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("p")) },
		{ key = "q", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("q")) },
		{ key = "r", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("r")) },
		{ key = "s", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("s")) },
		{ key = "t", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("t")) },
		{ key = "u", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("u")) },
		{ key = "v", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("v")) },
		{ key = "w", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("w")) },
		{ key = "x", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("x")) },
		{ key = "y", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("y")) },
		{ key = "z", mods = "CTRL|ALT", action = wezterm.action_callback(findTab("z")) },
	},
	move = {
		{ key = "Escape", action = act.PopKeyTable },
		{
			key = "s",
			action = act.Multiple({
				act.MoveTabRelative(-1),
				act.PopKeyTable,
			}),
		},
		{
			key = "t",
			action = act.Multiple({
				act.MoveTabRelative(1),
				act.PopKeyTable,
			}),
		},
		{
			key = "LeftArrow",
			action = act.Multiple({
				act.MoveTabRelative(-1),
				act.PopKeyTable,
			}),
		},
		{
			key = "RightArrow",
			action = act.Multiple({
				act.MoveTabRelative(1),
				act.PopKeyTable,
			}),
		},
		{ key = "n", action = act.RotatePanes("Clockwise") },
		{ key = "o", action = act.RotatePanes("CounterClockwise") },
		{ key = "r", action = act.RotatePanes("Clockwise") },
		{ key = "i", action = act.RotatePanes("CounterClockwise") },
		{ key = "f", action = notImplemented },
	},
	deliver = {
		{ key = "Escape", action = act.PopKeyTable },
		{
			key = ".",
			action = act.Multiple({
				act.PopKeyTable,
				act.PromptInputLine({
					description = "move pane to new tab, enter tab name",
					action = wezterm.action_callback(function(window, pane, line)
						if line then
							local tab, window = pane:move_to_new_tab()
							tab:set_title(line)
						end
					end),
				}),
			}),
		},
		{ key = "a", action = wezterm.action_callback(paneMoveTo("a", false)) },
		{ key = "b", action = wezterm.action_callback(paneMoveTo("b", false)) },
		{ key = "c", action = wezterm.action_callback(paneMoveTo("c", false)) },
		{ key = "d", action = wezterm.action_callback(paneMoveTo("d", false)) },
		{ key = "e", action = wezterm.action_callback(paneMoveTo("e", false)) },
		{ key = "f", action = wezterm.action_callback(paneMoveTo("f", false)) },
		{ key = "g", action = wezterm.action_callback(paneMoveTo("g", false)) },
		{ key = "h", action = wezterm.action_callback(paneMoveTo("h", false)) },
		{ key = "i", action = wezterm.action_callback(paneMoveTo("i", false)) },
		{ key = "j", action = wezterm.action_callback(paneMoveTo("j", false)) },
		{ key = "k", action = wezterm.action_callback(paneMoveTo("k", false)) },
		{ key = "l", action = wezterm.action_callback(paneMoveTo("l", false)) },
		{ key = "m", action = wezterm.action_callback(paneMoveTo("m", false)) },
		{ key = "n", action = wezterm.action_callback(paneMoveTo("n", false)) },
		{ key = "o", action = wezterm.action_callback(paneMoveTo("o", false)) },
		{ key = "p", action = wezterm.action_callback(paneMoveTo("p", false)) },
		{ key = "q", action = wezterm.action_callback(paneMoveTo("q", false)) },
		{ key = "r", action = wezterm.action_callback(paneMoveTo("r", false)) },
		{ key = "s", action = wezterm.action_callback(paneMoveTo("s", false)) },
		{ key = "t", action = wezterm.action_callback(paneMoveTo("t", false)) },
		{ key = "u", action = wezterm.action_callback(paneMoveTo("u", false)) },
		{ key = "v", action = wezterm.action_callback(paneMoveTo("v", false)) },
		{ key = "w", action = wezterm.action_callback(paneMoveTo("w", false)) },
		{ key = "x", action = wezterm.action_callback(paneMoveTo("x", false)) },
		{ key = "y", action = wezterm.action_callback(paneMoveTo("y", false)) },
		{ key = "z", action = wezterm.action_callback(paneMoveTo("z", false)) },
		{ key = "A", action = wezterm.action_callback(paneMoveTo("a", true)) },
		{ key = "B", action = wezterm.action_callback(paneMoveTo("b", true)) },
		{ key = "C", action = wezterm.action_callback(paneMoveTo("c", true)) },
		{ key = "D", action = wezterm.action_callback(paneMoveTo("d", true)) },
		{ key = "E", action = wezterm.action_callback(paneMoveTo("e", true)) },
		{ key = "F", action = wezterm.action_callback(paneMoveTo("f", true)) },
		{ key = "G", action = wezterm.action_callback(paneMoveTo("g", true)) },
		{ key = "H", action = wezterm.action_callback(paneMoveTo("h", true)) },
		{ key = "I", action = wezterm.action_callback(paneMoveTo("i", true)) },
		{ key = "J", action = wezterm.action_callback(paneMoveTo("j", true)) },
		{ key = "K", action = wezterm.action_callback(paneMoveTo("k", true)) },
		{ key = "L", action = wezterm.action_callback(paneMoveTo("l", true)) },
		{ key = "M", action = wezterm.action_callback(paneMoveTo("m", true)) },
		{ key = "N", action = wezterm.action_callback(paneMoveTo("n", true)) },
		{ key = "O", action = wezterm.action_callback(paneMoveTo("o", true)) },
		{ key = "P", action = wezterm.action_callback(paneMoveTo("p", true)) },
		{ key = "Q", action = wezterm.action_callback(paneMoveTo("q", true)) },
		{ key = "R", action = wezterm.action_callback(paneMoveTo("r", true)) },
		{ key = "S", action = wezterm.action_callback(paneMoveTo("s", true)) },
		{ key = "T", action = wezterm.action_callback(paneMoveTo("t", true)) },
		{ key = "U", action = wezterm.action_callback(paneMoveTo("u", true)) },
		{ key = "V", action = wezterm.action_callback(paneMoveTo("v", true)) },
		{ key = "W", action = wezterm.action_callback(paneMoveTo("w", true)) },
		{ key = "X", action = wezterm.action_callback(paneMoveTo("x", true)) },
		{ key = "Y", action = wezterm.action_callback(paneMoveTo("y", true)) },
		{ key = "Z", action = wezterm.action_callback(paneMoveTo("z", true)) },
	},
}

M.keys = keys
M.key_tables = key_tables

return M
