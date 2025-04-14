local function load()
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/Ui-Lib/Gui.lua"))()

    local UI = library:CreateWindow({ text = "The Red Lake Script" })

    UI:AddButton("Public Server Version", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/scripts/scptrl/public.lua"))()
        wait(1)
        library:DestroyUI()
    end)

    UI:AddButton("Private Server Version", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/scripts/scptrl/ps.lua"))()
        wait(1)
        library:DestroyUI()
    end)
end

local HttpService = game:GetService("HttpService")

local function copyToClipboard(text)
    setclipboard(text)
end

local Notify = loadstring(game:HttpGet("https://raw.githubusercontent.com/None7464/testss/main/Ui-Lib/Notification.lua"))()

local function checkExecutor()
	local issues = {}

	local Functions = {
		["getrawmetatable"] = getrawmetatable or get_raw_metatable,
		["setrawmetatable"] = setrawmetatable or set_raw_metatable,
		["setreadonly"] = setreadonly or make_readonly or makereadonly,
		["iswriteable"] = iswriteable or writeable or is_writeable,

		-- // IO Functions \--
		["isfolder"] = isfolder or syn_isfolder or is_folder,
		["isfile"] = isfile or syn_isfile or is_file,
		["delfolder"] = delfolder or syn_delfolder or del_folder,
		["delfile"] = delfile or syn_delfile or del_file,
		["appendfile"] = appendfile or syn_io_append or append_file,
		["makefolder"] = makefolder or make_folder or createfolder or create_folder,

		-- // Environment Manipulation \--
		["hookfunction"] = hookfunction or hookfunc or detour_function,
		["hookmetamethod"] = hookmetamethod or hook_meta_method,
		["islclosure"] = islclosure or is_lclosure or isluaclosure,
		["iscclosure"] = iscclosure or is_cclosure,
		["newcclosure"] = newcclosure or new_cclosure,
		["cloneref"] = cloneref or clonereference,
		["getconnections"] = getconnections or get_connections or get_signal_cons,
		["getnamecallmethod"] = getnamecallmethod or get_namecall_method,
		["setnamecallmethod"] = setnamecallmethod or set_namecall_method,

		-- // Instance Functions \--
		["getnilinstances"] = getnilinstances or get_nil_instances,
		["getproperties"] = getproperties or get_properties,
		["fireclickdetector"] = fireclickdetector or fire_click_detector,
		["gethiddenproperties"] = gethiddenproperties or get_hidden_properties or gethiddenprop or get_hidden_prop,
		["sethiddenproperties"] = sethiddenproperties or set_hidden_properties or sethiddenprop or set_hidden_prop,
		["getscripts"] = getrunningscripts or getscripts or get_running_scripts or get_scripts,

		-- // Script Methods \--
		["getthreadcontext"] = getthreadcontext or get_thread_context or getthreadidentity or get_thread_identity,
		["setthreadcontext"] = setthreadcontext or set_thread_context or setthreadidentity or set_thread_identity,
		["getcallingscript"] = getcallingscript or get_calling_script,
		["getscriptclosure"] = getscriptclosure,

		-- // Misc Functions \--
		["http_request"] = http_request or request or httprequest,
		["writeclipboard"] = write_clipboard or writeclipboard or setclipboard or set_clipboard,
		["queue_on_teleport"] = queue_on_teleport or queueonteleport,
		["firesignal"] = fire_signal or firesignal,
	}

	for name, func in pairs(Functions) do
		if typeof(func) ~= "function" then
			table.insert(issues, name .. " is missing or not a function.")
		end
	end

	if #issues == 1 then
		local message = "[The Red Lake] Environment error detected:\n" .. issues[1] .. "\nPlease contact the developer and paste the copied info."
		if setclipboard then setclipboard(message) end

		Notify:Create({
			Type = "Error",
			Message = "Executor issue! Info copied for developer.",
			Duration = 5
		})
	elseif #issues == 0 then
		load()
		getgenv().__LOADER_USED = true
	end
end

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

checkExecutor()
