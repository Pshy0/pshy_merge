Modules Help (basic infos and commands)
===

This page list features made available by different modules,
that may or may not be included in the runnable scripts found in the `tfm_lua/` folder (scripts ending in `.tfm.lua.txt`).



## pshy.commands

This module handles commands.

You can run a command by starting it with "`!`". 
If you included scripts that are not made by me, and if both my script and the other use the same command name:
- Prefix your commands as `!pshy.<command>` to run a command from a pshy module.
- Prefix your commands as `!other.<command>` to run a command from another module.

In this guide, commands will be presented this way:

| Command | Description |
| ------- | ----------- |
| `!command(aliases) <required_argument> [optional_argument:default_value]` | here is what the command do |

This means you can run this command those ways:
- `!command required_argument_value`
- `!alias required_argument_value`
- `!alias required_argument_value optional_argument_value`

If you type a command wrong, then the command usage will be displayed.

If a command's argument is "`<player>`" or "`[target_player]`" then you only need to write the beginning of the player's name, as long as it is unique in the room. 
You can also use "`*`" to run the command on every single player. This works with ALL the commands.
You can also use hexadecimal codes or words for colors (for instance "#ff0000" and "red" are both valid for red). 

Failing to provide a required argument will result in the module displaying dialogs for you to input these.

You can get a list of commands with:
| `!commands(cmds) [page_index]` | List all the module's commands. |



## pshy.help

This module handles help pages.

| Command | Description |
| ------- | ----------- |
| `!help [page_name\|module_name\|!command]` | Show the general help or a given help page. |

The commands's color match their default permissions:
- 🟢 green: Everyone can use the command.
- 🟡 Yellow: Cheat command that can only be used by room admins, or by everyone if cheat commands are enabled in the room.
- 🔴 red: Only room admins can use the command.
- 🟣 purple: Only the script loader, and room admins who also are FunCorp, can use the command.



## pshy.perms

Handle permissions.

| Command | Description |
| ------- | ----------- |
| `!admin [FullPlayerName#0000]` | Set a player as room admin. |
| `!unadmin [FullPlayerName#0000]` | Remove a player from room admins. |
| `!admins` | List room admins. |
| `!enablecheats [yes\|no]` | Enable or disable cheat commands. In some modules, this is enabled by default. |
| `!setperm <Player#0000\|admins\|cheats\|everyone> <!command> <yes\|no>` | Set permissions for a command. |
| `!trust [FullPlayerName#0000]` | Allow some content from this player to play in the room (custom map features). |
| `!adminmotd [instruction]` | Display a message to all future new room admins. |

Examples:
- `!setperm Abc#1234 !fly true`: Allow Abc#1234 to fly.
- `!setperm everyone !setcheckpoint true`: Allow everyone to set their spawnpoint.



## pshy.commands.list.modules

This module handle the other ones, calling their events if they are enabled. 
Modules with events are enabled by default, except if they are made for a specific map (in this case they will only be enabled on that map).

| Command | Description |
| ------- | ----------- |
| `!modules <event_name>` | List modules. Disabled modules events are not called. |
| `!disablemodule` | Disable a module that was manually enabled. |
| `!enablemodule` | Enable a module. Only useful if a script is built with optional modules. |
| `!pshyversion` | Get the version of the pshy repository this script was built from. |
| `!modulestop` | Stop the script. |
| `!modulereload` | Reload a module. Almost sure to break something but useful when dealing with thirdparty scripts. |



## pshy.anticheats

There is several anticheat features included in this script, but they are only available to FunCorps. 
Use `!help pshy_anticheats` in-game, or check the [forum page for this module][#].

**⚠ If you do run this module with the anticheats enabled, then you should read it's help carefully.**

Only the safe non-sensitive commands will be displayed here:

| Command | Description |
| ------- | ----------- |
| `!antiguestdays(antiguest) <days>` | How many days an account should have to be able to play in this script. Use `-1` to disable, and `0` to only disallow guests and accounts created after the script started. The default value is currently `0` |
| `!antilagautokill <on/off>` | Enable or disable automatic killing of lagging players (xbug). Disabled by default. |
| `!loadersync <on/off> [PlayerSync#0000]` | Toggle the enforcing of the sync player or choose a player to be the enforced sync. Enforcing the sync prevents some exploits. By default the sync is enforced to be the script loader. |
| `!antieasytitle <on/off>` | Prevent players from joining if they are using a easy-to-obtain title. |



## pshy.rotations.newgame

This module replaces the rotation features from TFM.

| Command | Description |
| ------- | ----------- |
| `!next <@mapcode> [force]` | Set the next map to be played. If `force` is `true`, then it will run this map even if another module try to load a different one. |
| `!skip(map) [@mapcode]` | Immediately play the next map. If `@mapcode` is specified, then this map will be played. |
| `!rots` | See the available rotations. The number correspond to how often this rotation will be used. |
| `!rotc [rotation_name]` | Clear the used rotations and set the one to use instead. |
| `!rotw <rotation_name> [weight:1]` | Set how often a rotation should be played. |
| `!repeat(r,replay)` | Replay the current map. |
| `!autorespawn` | Enable or disable automatic respawn (for modules that dont implement it already). |
| `!previous` | Get the name of the previous map. |
| `!back` | Play the previous map. |
| `!nextrepeat(nrt)` | Cause the current map to replay when a new map would have been played. |



## pshy.bases.speedfly

More cheat commands.

| Command | Description |
| ------- | ----------- |
| `!speed [amount:0/50] [target_player]` | Give a speed boost. |
| `!fly [enabled] [target_player]` | Allow to fly. |
| `!tpp [destination] [target_player]` | Teleport to a player. |
| `!tpl <x> <y> [target_player]` | Teleport to coordinates. |
| `!coords` | See your current coordinates. |



## pshy.bases.checkpoints

| Command | Description |
| ------- | ----------- |
| `!setcheckpoint` | Set your checkpoint (spawn point). |
| `!gotocheckpoint` | Teleport to your checkpoint. |
| `!unsetcheckpoint` | Delete your checkpoint. |



## pshy.bases.emoticons

Adds emoticons. 
You can use them using the default numbers or the numpad numbers, combined with CTRL and/or ALT.

| Command | Description |
| ------- | ----------- |
| `!emoticon(em) <emote_name> [target_player]` | Play an emoticon. |

Some emoticons are only available with this command:
- `cheese_left`
- `cheese_right`
- `mario_left`
- `mario_right`
- `noob`
- `noob2`
- `pro`
- `pro2`
- `cute`
- `cute2`
- `cutest`



## pshy.images.changeimage

This module allow changing a mouse's image.

| Command | Description |
| ------- | ----------- |
| `!searchimage <search words>` | Search for an image. |
| `!changeimage <off\|imagecode.png> <target_player>` | Change your image (only works if the image is approved in the script). |
| `!randomchangeimage <search words>` | Change your image to something random but matching some search words. |
| `!randomchangeimages <search words>` | Change everyone's image to something random but matching some search words. |

Examples:
- `!randomchangeimages rats`: Turn everyone to a random rat image.
- `!randomchangeimages food`: Turn everyone to a random food image.



## pshy.tools.fcplatform

Spawn a magic platform that can teleport with players on it.

| Command | Description |
| ------- | ----------- |
| `!fcplatform(fcp) [x] [y]` | Spawn the platform once (at given or last coordinates). |
| `!fcplatformautospawn(fcpautospawn) <enabled>` | Enable or disable the platform's automatic spawning. (TODO) |
| `!set pshy.fcplatform_autospawn true` | Make the platform spawn automatically every game. |
| `!fcplatformpilot(fcpp) [target_player]` | Make yourself or another player control the platform by clicking. |
| `!fcplatformjoin(fcpj,spectate) [yes\|no] [target_player]` | Teleport you to the platform, but you will not be able to leave it. |



## pshy.bases.rain

Rain random objects.

| Command | Description |
| ------- | ----------- |
| `!rain [optional_objects_to_rain]` | Cause a rain of random or given objects. Use empty to stop. |



## pshy.tools.motd

Allow to make different kind of announcements.
This supports html, so be careful closing your markups or escaping them.

| Command | Description |
| ------- | ----------- |
| `!setmotd <message>` | Set a message displayed to players when they join the room. |
| `!motd` | See the current motd. |
| `!announce` | Send a message as "\[FunCorp\]". |

Examples:
- `!setmotd <rose>Squeakkk!!!</rose>`: Set the motd written in pink.
- `!announce jump -&gt; death`: Display "\[FunCorp\] jump -> death".



## pshy.tools.requests (for players)

Those commands will send a message to room admins so that they can enter the corresponding FunCorp commands.

| Command | Description |
| ------- | ----------- |
| `!changenick <nickanme>` | Change your nickname. |
| `!colormouse <color>` | Change your mouse color. |
| `!colornick <color>` | Change your nickname color. |



## pshy.anticheats.adminchat

Add a chat shared with room admins and module messages.

| Command | Description |
| ------- | ----------- |
| `!adminchat(ac) <message>` | Send a message in the room admin chat. |



## pshy.anticheats.ban

provides ways to prevent a player from interfering with the room.

| Command | Description |
| ------- | ----------- |
| `!kick <player> [reason]` | The given player can no longer play until they rejoin. |
| `!ban <player> [reason]` | The given player can no longer play until the script is restarted. |
| `!shadowban <player> [reason]` | The given player can still play, but most of their actions, such as winning, will be ignored by the other modules. |
| `!unban <player>` | Allow a player to play in the room. |



## pshy.commands.list.mice

| Command | Description |
| ------- | ----------- |
| `!shaman [enabled] [target_player]` | Switch between shaman/not shaman. |
| `!shamanmode [mode] [target_player]` | Change your shaman mode. |
| `!vampire [enabled] [target_player]` | Switch between vampire/not vampire. |
| `!cheese [has] [target_player]` | Switch between having the cheese/not having it. |
| `!win [target_player]` | Win the game. |
| `!kill [target_player]` | Die. |
| `!respawn [target_player]` | Resurect. |
| `!freeze <enabled> [target_player]` | Freeze or unfreeze a player. |
| `!size <value> [target_player]` | Change your size. |
| `!namecolor <#RRGGBB> [target_player]` | Change your name's color. |
| `!balloon [target_player]` | Attach or detach a player to/from a balloon. |
| `!link [wished_player] [target_player]` | Link yourself to a player if they use the command as well. |



## pshy.tools.bindkey / pshy.tools.bindmouse

Allow to bind a command to a key / the mouse. 
This is only available to room admins. 

| Command | Description |
| ------- | ----------- |
| `!bindkey <KEYNAME> [command]` | Remove a bind from a key or set a new one. Use %d / %d for coordinates. |
| `!bindmouse [command]` | Remove a bind from the mouse or set a new one. Use %d / %d for coordinates. |

Examples:
- `!bindmouse tpl %d %d`: Allow you to teleport with the mouse.
- `!bindmouse fcp %d %d`: Allow you to teleport the fcplatform with the mouse.



## pshy.commands.list.tfm

Run some TFM functions.
Some of those features are overriden and handled by other pshy modules if present (so the behavior may differ).

| Command | Description |
| ------- | ----------- |
| `!apiversion` | Get the version of the api. |
| `!clear` | Empty the chat by writting new lines. |
| `!colorpicker [target_player]` | Show a colorpicker to someone. |
| `!playerid` | Get your TFM player id. |
| `!playerlook` | Get your TFM's look. |
| `!playsound <sound_name>` | Play a sound ([Sound list here](http://audio.atelier801.com/sounds.html)). |
| `!tfmversion` | Get the version of the game. |
| `!ping` | Get the average latency of a player. |



## pshy.commands.list.rp

| Command | Description |
| ------- | ----------- |
| `!action <message>` | Send a message like if you were roleplaying. |
| `!say <message>` | Send a standard message with no interactible name. |



## pshy.commands.list.room

| Command | Description |
| ------- | ----------- |
| `!afkdeath [enabled]` | Enable (or disable) the afk being killed. |
| `!allowdebug [enabled]` | Allow (or disallow) /debug. |
| `!allowmort [enabled]` | Allow (or disallow) /mort. |
| `!allowwatch [enabled]` | Allow (or disallow) /watch. |
| `!autonewgame [enabled]` | Enable (or disable) auto map changes. |
| `!autoscore [enabled]` | Enable (or disable) TFM from handling the scores. |
| `!autoshaman [enabled]` | Enable (or disable) the shaman. |
| `!autoskills [enabled]` | Enable (or disable) shaman skills. |
| `!autotimeleft [enabled]` | Enable (or disable) the time lowering when few players are alive. |
| `!chatcommandsdisplay [enabled]` | Enable (or disable) the display of chat commands when they are used. |
| `!consumables [enabled]` | Allow (or disallow) the use of physical consumables. |
| `!mapflipmode [enabled]` | **Currently not recommended, will break `pshy_newgame`.** |
| `!minimalist [enabled]` | Allow (or disallow) the minimalist mode. |
| `!password [room_password]` | Set the room's password. |
| `!playerscore <score> [target_player]` | Set a player's score. |
| `!prespawnpreview [enabled]` | Enable (or disable) what the shaman is spawning from being displayed before it have been spawned. |



## pshy.commands.list.game

| Command | Description |
| ------- | ----------- |
| `!aiemode(aie) [on/off] [sensibility] [target_player]` | Enable or disable night mode (for all players by default). |
| `!backgroundcolor <color>` | Change the background color. |
| `!gravity [gravity] [wind]` | Reset or change the gravity/wind |
| `!gravityscale <scale> [target_player]` | Set how much a player is affected by gravity. |
| `!nightmode [on/off] [target_player]` | Enable or disable the night mode. |
| `!time <score> [target_player]` | Set a player's score. |



## pshy.commands.list.lua

Mainly debug commands.
**Those features may only work for the loader, and may not run in some rooms (to respect some rules).**

| Command | Description |
| ------- | ----------- |
| `!luaget(get) <global_variable_name>` | Display the value of a global variable. |
| `!luaset(set) <global_variable_name> <value>` | Parse and set the value of a global variable. |
| `!luals(ls,tree) <table_name>` | List entries in a table. |
| `!luasetstr(setstr) <global_variable_name> <value>` | Set a text as the value of a global variable. |
| `!luacall(call) <function_name> [arguments]` | Call a function. |
| `!luabindbunc(bindbunc) <name> <function> [args...]` | Create a function that calls another with specific arguments. |

You can specify the type of an untyped argument by prefixing it with `<type>:`.



## pshy.debug.glocals

Causes modules locals to be accessible via `_G["~"]`:
 - List a module's locals with `!ls ~/module.name/~`
 - Access a module's local like `!set ~/module.name/local_name new_value`



## pshy.tools.getxml

| Command | Description |
| ------- | ----------- |
| `!getxml [part]` | Print the map xml, or a part of the last map the command was run on. |



## pshy.teams & pshy.teams.racingvs

Adds team features.

| Command | Description |
| ------- | ----------- |
| `!teamadd <team_name> <color>` | Add a team with the given name and the given color. |
| `!teamremove(teamrm) <team_index>` | Remove a team. |
| `!teamname <team_index> <new_name>` | Set a team's name. |
| `!teamcolor <team_index> <color>` | Set a team's color. |
| `!teamleader <team_index> <player>` | Set a team's leader (can change the team name and color). (TODO) |
| `!teamjoin <team_index> [target_player]` | Join a team (only works if the team is loosing or if cheats are enabled). |
| `!teamscore <team_index> <score>` | Set a team's score. |
| `!teamsshuffle [everyone:true]` | Place players in random teams. Also reset the team's scores. |
| `!teamsreset` | Reset team's scores (does not change player's team). |
| `!d` | Set the target team score. |
| `!teamsautojoin(teamsaj,aj) <enabled>` | Enable or disable autojoin. |



## pshy.bases.lobby

| Command | Description |
| ------- | ----------- |
| `!lobby [title]` | Open a lobby with a given title displayed on screen or updates it. The map wont auto-change and you will need to use `!skip`. |



## pshy.alternatives

Replaces functions that would otherwise be available only to lua team members.

| Command | Description |
| ------- | ----------- |
| `!chat` | Toggle the alternative chat (used by `tfm.exec.chatMessage`). |
| `!getplayerdata` | Get the last data loaded by `system.loadPlayerData` or saved to by `system.savePlayerData`. |
| `!setplayerdata` | Set the next data that will be loaded by `system.loadPlayerData`. |
| `!getfiledata <file_id>` | Get the last data loaded by `system.loadFile` or saved to by `system.saveFile`. |
| `!setfiledata <file_id>` | Set the next data that will be loaded by `system.loadFile`. |



## pshy.bonuses

| Command | Description |
| ------- | ----------- |
| `!bonuseffect <bonus_type> [target_player]` | Run a bonus effect. |



## pshy.tools.afks

Finds afk players.

| Command | Description |
| ------- | ----------- |
| `!afks` | List the longest afk players. |



## pshy.tools.entibot

Use entibo's script to load maps directly from [miceditor](https://entibo.github.io/miceditor/).



## pshy.commands.list.unused

| Command | Description |
| ------- | ----------- |
| `!rejoin [player]` | Simulate a rejoin. Will probably not work for every module. |
| `!runas <player> <command>` | Run a command as someone else. |
