--- pshy.bases.version
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Namespace.
local version = {}



--- Module Settings:
pshy.TFM_VERSION = 8.63								-- The last tfm version this script was made for.
pshy.TFM_API_VERSION = "0.28"						-- The last tfm api version this script was made for.
version.days_before_update_suggested = 30			-- How old the script should be before suggesting an update (`nil` to disable).
version.days_before_update_advised = 50				-- How old the script should be before requesting an update (`nil` to disable).
local VERSION_MARGIN = 0.03							-- Do not warn for every update.



--- Logs informations about the current version.
-- Warn if a version is old or if Transformice or the Lua api were updated.
function version.Check()
	if pshy.MAIN_VERSION then
		print(string.format("<v>Script version <ch>%s</ch></v>", pshy.MAIN_VERSION))
	end
	print(string.format("<v>Pshy version <ch>%s</ch></v>", pshy.PSHY_VERSION))
	-- check release age
	local release_days = pshy.BUILD_TIME / 60 / 60 / 24
	local current_days = os.time() / 1000 / 60 / 60 / 24
	local days_old = current_days - release_days
	if version.days_before_update_advised and days_old > version.days_before_update_advised then
		print(string.format("<o>This build is <r>%d days</r> old. Please obtain a newer version as soon as possible.</o>", days_old))
	elseif version.days_before_update_suggested and days_old > version.days_before_update_suggested then
		print(string.format("<j>This build is <o>%d days</o> old. An update may be available.</j>", days_old))
	else
		print(string.format("<v>This build is <ch>%d days</ch> old.</v>", days_old))
	end
	-- check tfm api version
	if tfm.get.misc.apiVersion ~= pshy.TFM_API_VERSION then
		print("<o>⚠ The TFM LUA API was updated, an update of pshy's script may be available for this new version.</o>")
	end
	-- check tfm version
	local tfm_version = tfm.get.misc.transformiceVersion
	if not pshy.MAIN_VERSION then
		if math.floor(tfm_version) > math.floor(pshy.TFM_VERSION) then
			print("<o>⚠ Transformice had a major update, an update of pshy's script may be available for this new version.</o>")
		elseif tfm_version > pshy.TFM_VERSION + VERSION_MARGIN + 0.0001 then
			print("<j>⚠ Transformice had a minor update, an update of pshy's script may be available for this new version.</j>")
		end
	end
	if tfm_version + 0.0001 < pshy.TFM_VERSION then
		print("<vi>⚠ Transformice's version is behind what it is supposed to be!</vi>")
	end
end



--- Init
version.Check()



local d = os.date("%m-%d")
if d == "09-20" then
	print("<o>squeak :c</o>")
elseif d == "05-02" then
	print("<o>piou piou</o>")
end



return version
