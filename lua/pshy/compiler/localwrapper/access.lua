--- pshy.compiler.localwrapper.access
--
-- Definition of an element of `pshy.locals[module_name]`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
	LOCAL_NAME = {
		Get = function() return LOCAL_NAME end;
		Set = function(v) LOCAL_NAME = v end;
	};
