local vm_path = os.getenv("MY_VM_PATH")

if not vm_path then
	local sysname = os.getenv("OS")
	if sysname and sysname:lower():find("windows") then
		vm_path = string.gsub(os.getenv("USERPROFILE"), [[\]], "/") .. "/vm"
	else
		vm_path = "~/vm"
	end
end

local M = {}

function M.vm_path()
	return vm_path
end

function isWindows()
	return package.config:sub(1, 1) == "\\"
end
M.isWindows = isWindows

function M.notify(str)
	if isWindows() then
		os.execute('nircmd infobox "' .. str .. '" "错误!"')
	end
end

return M
