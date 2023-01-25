--- pshy.alternatives.mt
--
-- Allow some scripts using restricted lua features to still work when those are not available.
--
-- This scripts requires everything needed to run a module-team-only script.
-- Scripts may still purposefully refuse to run.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.alternatives.data")
pshy.require("pshy.alternatives.getplayersync")
pshy.require("pshy.alternatives.luaevent")
pshy.require("pshy.alternatives.timers")
pshy.require("pshy.alternatives.uniqueplayers")
