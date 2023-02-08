--- pshy.enums.html_ansi
--
-- ANSI escape sequences matching TFM html markups.
-- Lua escape sequence start: `\x1B[`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



local html_ansi = {
	-- Misk
	b				= "1m";
	u				= "4m";
	i				= "3m";
	strike			= "9m";
	-- Colors
	bl				= "38;5;62m";
	bv				= "38;5;26m";
	ce				= "38;5;178m";
	cep				= "38;5;180m";
	ch				= "38;5;153m";
	ch2				= "38;5;225m";
	cs				= "38;5;222m";
	d				= "38;5;223m";
	fc				= "38;5;202m";
	g				= "38;5;19m";
	j				= "38;5;226m";
	n				= "38;5;252m";
	n2				= "38;5;247m";
	o				= "38;5;214m";
	ps				= "38;5;225m";
	pt				= "38;5;41m";
	r				= "38;5;124m";
	rose			= "38;5;164m";
	s				= "38;5;183m";
	t				= "38;5;157m";
	v				= "38;5;37m";
	vi				= "38;5;128m";
	vp				= "38;5;40m";
}



return html_ansi
