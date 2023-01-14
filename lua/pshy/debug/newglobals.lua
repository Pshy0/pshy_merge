--- pshy.debug.newglobals
--
-- Log new variables in global.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
pshy.require("pshy.utils.print")



local existing_globals = {}



function eventInit()
	for n in pairs(_G) do
		existing_globals[n] = true
	end
end



function eventLoop()
	for n, v in pairs(_G) do
		if not existing_globals[n] then
			print_warn("New global `%s` of type `%s`.", n, type(v))
			existing_globals[n] = true
		end
	end
end
