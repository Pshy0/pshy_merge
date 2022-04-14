--- pshy_version.py
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @hardmerge
pshy = pshy or {}



--- Defined by `combine.py`:
-- `__PSHY_VERSION__`			-- Last repository tag.
-- `__PSHY_TIME__`				-- When was the script built.



--- Module Settings:
__PSHY_TFM_VERSION__ = "7.96"						-- The last tfm version this script was made for.
__PSHY_TFM_API_VERSION__ = "0.28"					-- The last tfm api version this script was made for.
pshy.version_days_before_update_suggested = 14		-- How old the script should be before suggesting an update (`nil` to disable).
pshy.version_days_before_update_advised = 30		-- How old the script should be before requesting an update (`nil` to disable).
pshy.version_days_before_update_required = nil		-- How old the script should be before refusing to start (`nil` to disable).



--- Logs informations about the current version.
-- Warn if a version is old or if Transformice or the Lua api were updated.
function pshy.version_Check()
	print("<v>Pshy version <ch>" .. tostring(__PSHY_VERSION__) .. "</ch></v>")
	-- check release age
	local release_days = __PSHY_TIME__ / 60 / 60 / 24
	local current_days = os.time() / 1000 / 60 / 60 / 24
	local days_old = current_days - release_days
	if pshy.version_days_before_update_required and days_old > pshy.version_days_before_update_required then
		print(string.format("<r>This build is <vi>%d days</vi> old. Please consider obtaining a newer version.</r>", days_old))
		error(string.format("<r>This build is <vi>%d days</vi> old. Please consider obtaining a newer version.</r>", days_old))
	elseif pshy.version_days_before_update_advised and days_old > pshy.version_days_before_update_advised then
		print(string.format("<o>This build is <r>%d days</r> old. Please obtain a newer version as soon as possible.</o>", days_old))
	elseif pshy.version_days_before_update_suggested and days_old > pshy.version_days_before_update_suggested then
		print(string.format("<j>This build is <o>%d days</o> old. An update may be available.</j>", days_old))
	else
		print(string.format("<v>This build is <ch>%d days</ch> old.</v>", days_old))
	end
	if pshy.version_days_before_update_required and days_old > pshy.version_days_before_update_required / 2 then
		print(string.format("<r>⚠ This script will not start after being %d days old.</r>", pshy.version_days_before_update_required))
	end
	-- check tfm api version
	local expected_tfm_api_version_numbers = {}
	for number_str in string.gmatch(__PSHY_TFM_API_VERSION__, "([^\.]+)") do
		table.insert(expected_tfm_api_version_numbers, tonumber(number_str))
	end
	local current_tfm_api_version_numbers = {}
	for number_str in string.gmatch(tfm.get.misc.apiVersion, "([^\.]+)") do
		table.insert(current_tfm_api_version_numbers, tonumber(number_str))
	end
	if current_tfm_api_version_numbers[1] and expected_tfm_api_version_numbers[1] ~= current_tfm_api_version_numbers[1] then
		print("<o>⚠ The TFM LUA API had a major update, an update of pshy's script may be available for this new version.</o>")
	elseif current_tfm_api_version_numbers[2] and expected_tfm_api_version_numbers[2] ~= current_tfm_api_version_numbers[2] then
		print("<j>⚠ The TFM LUA API had a minor update, an update of pshy's script may be available for this new version.</j>")
	end
	-- check tfm version
	local expected_tfm_version_numbers = {}
	for number_str in string.gmatch(__PSHY_TFM_VERSION__, "([^\.]+)") do
		table.insert(expected_tfm_version_numbers, tonumber(number_str))
	end
	local current_tfm_version_numbers = {}
	for number_str in string.gmatch(tfm.get.misc.transformiceVersion, "([^\.]+)") do
		table.insert(current_tfm_version_numbers, tonumber(number_str))
	end
	if current_tfm_version_numbers[1] and expected_tfm_version_numbers[1] ~= current_tfm_version_numbers[1] then
		print("<o>⚠ Transformice had a major update, an update of pshy's script may be available for this new version.</o>")
	elseif current_tfm_version_numbers[2] and expected_tfm_version_numbers[2] ~= current_tfm_version_numbers[2] then
		print("<j>⚠ Transformice had a minor update, an update of pshy's script may be available for this new version.</j>")
	end
end



--- Init
pshy.version_Check()
