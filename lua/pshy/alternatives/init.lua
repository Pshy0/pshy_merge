--- pshy.alternatives
--
-- Allow some scripts using restricted lua features to still work when those are not available.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Namespace:
local alternatives = {}
alternatives.chat = pshy.require("pshy.alternatives.chat")
alternatives.getplayersync = pshy.require("pshy.alternatives.getplayersync")
alternatives.timers = pshy.require("pshy.alternatives.timers")



return alternatives
