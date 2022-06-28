--- pshy.enums.html_ansi
--
-- ANSI escape sequences matching TFM html markups.
-- Lua escape sequence start: `\x1B[`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Public Map:
local html_ansi = {}
-- Misk
html_ansi["b"]			= "1m"
html_ansi["u"]			= "4m"
html_ansi["i"]			= "3m"
html_ansi["strike"]		= "9m"
-- Colors
html_ansi["bl"]			= "38;5;24m"
html_ansi["bv"]			= "38;5;26m"
html_ansi["ce"]			= "38;5;178m"
html_ansi["cep"]		= "38;5;180m"
html_ansi["ch"]			= "38;5;153m"
html_ansi["ch2"]		= "38;5;225m"
html_ansi["cs"]			= "38;5;222m"
html_ansi["d"]			= "38;5;223m"
html_ansi["fc"]			= "38;5;202m"
html_ansi["g"]			= "38;5;19m"
html_ansi["j"]			= "38;5;226m"
html_ansi["n"]			= "38;5;252m"
html_ansi["n2"]			= "38;5;247m"
html_ansi["o"]			= "38;5;214m"
html_ansi["ps"]			= "38;5;225m"
html_ansi["pt"]			= "38;5;41m"
html_ansi["r"]			= "38;5;124m"
html_ansi["rose"]		= "38;5;164m"
html_ansi["s"]			= "38;5;183m"
html_ansi["t"]			= "38;5;157m"
html_ansi["v"]			= "38;5;37m"
html_ansi["vi"]			= "38;5;128m"
html_ansi["vp"]			= "38;5;40m"



return html_ansi
