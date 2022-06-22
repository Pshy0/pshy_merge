--- pshy.utils.tfm_enum_fix
--
-- Adds missing values to `tfm.enum.shamanObject`.
-- Also fix some errors.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
--
-- @preload



tfm.enum.shamanObject.spirit = 24			-- missing
tfm.enum.shamanObject.bluePortal = 26		-- correct
tfm.enum.shamanObject.orangePortal = 27		-- currently 26 in the API
tfm.enum.shamanObject.fish = 63				-- missing
tfm.enum.shamanObject.oldBox = 96			-- missing but supposed to be removed
tfm.enum.shamanObject.powerOrb = 97			-- missing
