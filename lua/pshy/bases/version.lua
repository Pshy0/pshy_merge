--- pshy.bases.version
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Namespace.
local version = {}



--- Module Settings:
pshy.TFM_VERSION = "8.46"							-- The last tfm version this script was made for.
pshy.TFM_API_VERSION = "0.28"						-- The last tfm api version this script was made for.
version.days_before_update_suggested = 30			-- How old the script should be before suggesting an update (`nil` to disable).
version.days_before_update_advised = 50				-- How old the script should be before requesting an update (`nil` to disable).
version.days_before_update_required = nil			-- How old the script should be before refusing to start (`nil` to disable).



--- Get a table of version numbers from a string representing that version.
-- @param str_v String representing a version such as "8.1".
local function StringToVersion(str_v)
	local version_numbers = {}
	for number_str in string.gmatch(str_v, "([^%.]+)") do
		table.insert(version_numbers, tonumber(number_str))
	end
	return version_numbers
end



--- Get a table of version numbers from a number representing that version.
-- @param str_v String representing a version such as `8.1`.
local function NumberToVersion(num_v)
	local num_1 = math.floor(num_v)
	local num_2 = math.floor((num_v - num_1 + 0.001) * 100)
	return {num_1, num_2}
end



--- Convert either a number or a string to a version table.
-- See StringToVersion() and NumberToVersion().
local function ToVersion(string_or_number)
	if type(string_or_number) == "string" then
		return StringToVersion(string_or_number)
	else
		return NumberToVersion(string_or_number)
	end
end



--- Compare 2 version numbers, and return the order of the change (0 == no update, 1 == major, 2 == minor, -1 == behind)
-- @param current The current version, as a list of the numbers in the version.
-- @param current The expected version, as a list of the numbers in the version.
-- @return 0 if the versions are the same, or the index of the number changed. A negative number if the current version is behind the expected one.
local function CompareVersions(expected, current)
	local order = 1
	while current[order] or expected[order] do
		if (current[order] or 0) < (expected[order] or 0) then
			return -order
		elseif (current[order] or 0) > (expected[order] or 0) then
			return order
		else
			order = order + 1
		end
	end
	return 0
end



--- Compare 2 version numbers represented either by strings or numbers.
-- @return (cf CompareVersions).
local function CompareVersionStrings(expected, current)
	return CompareVersions(ToVersion(expected), ToVersion(current))
end



--- Logs informations about the current version.
-- Warn if a version is old or if Transformice or the Lua api were updated.
function version.Check()
	if pshy.MAIN_VERSION then
		print("<v>Script version <ch>" .. tostring(pshy.MAIN_VERSION) .. "</ch></v>")
	end
	print("<v>Pshy version <ch>" .. tostring(pshy.PSHY_VERSION) .. "</ch></v>")
	-- check release age
	local release_days = pshy.BUILD_TIME / 60 / 60 / 24
	local current_days = os.time() / 1000 / 60 / 60 / 24
	local days_old = current_days - release_days
	if version.days_before_update_required and days_old > version.days_before_update_required then
		print(string.format("<r>This build is <vi>%d days</vi> old. Please consider obtaining a newer version.</r>", days_old))
		error(string.format("<r>This build is <vi>%d days</vi> old. Please consider obtaining a newer version.</r>", days_old))
	elseif version.days_before_update_advised and days_old > version.days_before_update_advised then
		print(string.format("<o>This build is <r>%d days</r> old. Please obtain a newer version as soon as possible.</o>", days_old))
	elseif version.days_before_update_suggested and days_old > version.days_before_update_suggested then
		print(string.format("<j>This build is <o>%d days</o> old. An update may be available.</j>", days_old))
	else
		print(string.format("<v>This build is <ch>%d days</ch> old.</v>", days_old))
	end
	if version.days_before_update_required and days_old > version.days_before_update_required / 2 then
		print(string.format("<r>⚠ This script will not start after being %d days old.</r>", version.days_before_update_required))
	end
	-- check tfm api version
	local tfm_api_version_diff = CompareVersionStrings(pshy.TFM_API_VERSION, tfm.get.misc.apiVersion)
	if tfm_api_version_diff == 1 then
		print("<o>⚠ The TFM LUA API had a major update, an update of pshy's script may be available for this new version.</o>")
	elseif tfm_api_version_diff == 2 then
		print("<j>⚠ The TFM LUA API had a minor update, an update of pshy's script may be available for this new version.</j>")
	elseif tfm_api_version_diff < 0 then
		print("<vi>⚠ The TFM LUA API version is behind what it is supposed to be</vi>")
	end
	-- check tfm version
	if not pshy.MAIN_VERSION then
		local rounded_tfm_version = math.floor(tfm.get.misc.transformiceVersion * 100 + 0.1) / 100
		local tfm_version_diff = CompareVersionStrings(pshy.TFM_VERSION, rounded_tfm_version)
		if tfm_version_diff == 1 then
			print("<o>⚠ Transformice had a major update, an update of pshy's script may be available for this new version.</o>")
		elseif tfm_version_diff == 2 then
			print("<j>⚠ Transformice had a minor update, an update of pshy's script may be available for this new version.</j>")
		elseif tfm_version_diff < 0 then
			print("<vi>⚠ Transformice's version is behind what it is supposed to be!</vi>")
		end
	end
end



--- Init
version.Check()



if os.date("%m-%d") == "09-20" then
	print("<o>squeak :c</o>")
end



return version
