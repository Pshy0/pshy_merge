# Introduction

This project contains a Python script to merge TFM lua scripts/modules,  
and some TFM modules I made as well.
**TAKE CAUTION USING THOSE SCRIPTS, THEY MAY BE VERY UNSTABLE BEFORE 1.0**



# TODO
For v0.3:
- [x] Move features from `pshy_mapdb` to `pshy_newgame`.
- [x] Make bonuses ext load from pshy_mapinfo instead of xml.
- [x] Anticheat improvements (still a long way to go).
- [x] Anticheat should ignore and warn on `pshy.perms_cheats_enabled == true`.
- [x] Anticheat: ignore clicks within the timer, and record into stats.
- [x] Print "command executed" when a command doesnt return anything.
- [x] Huge anticheat improvements for anti-bots, leve revelation, and state-forcing revelations.

For v0.4:
- [x] Create an user guide (outside of the !help command) for the basic modules.
- [x] Create an user guide for the anticheat.
- [x] Add a variant for !antiaccell.
- [x] Better directory structure.
- [x] Add color as a valid command parameter.
- [x] Add commands to fcplatform.
- [x] Split features related to teams from win conditions.
- [x] Finish adding team commands.
- [x] Add \_\_PSHY\_VERSION\_\_ variable.
- [x] Add a `!version` command.
- [x] Implement the color parameter where it can be useful.

For v0.5:
- Fixes:
  - [x] Fixed `!antiaccel` false positives.
  - [x] Improve merging order.
  - [x] Merge some of the anticheats.
  - [x] Code time measurements?
  - [-] Investigate on keyboard crash???
  - [x] Fix wrong bonuses sometime being added to maps (when calling next map too fast).
  - [ ] pshy_bonuses.lua: eventPlayerBonusGrabbed: attempt to index nil (on sync issues / lags?)
  - [ ] Bonuses not spawning when a player join.
- Performances:
  - [x] Optimize keyboard all events (? -> 0.0565 -> 0.0552).
    - [x] [...]
    - [x] Optimize `pshy_players` (eventKeyboard 0.0140).
      - [-] It is unbelievable that such a small feature uses so much time. Investigate. 
  - [x] Do not recreate event functions (has no effect due to the implementation).
  - [ ] Stop always requiring the entire `pshy_essentials.lua`?
- Features:
  - [x] Debug features for measuring code performance: `!eventstiming` and `!eventtiming [event_name]`.
  - [x] Add maps and rotations (proceed pending maps).
  - [x] Display available rotations in alphabetic order.
  - [x] Replace pshy_requests content to add `!changenick`, `!colornick` and `!colormouse`.
  - [x] Commands `!pshyversion`, `!luaversion`, `!jitversion`, `!apiversion` and `!tfmversion` to get a version number.
  - [x] Command `!playerid` to see your TFM player id.
  - [x] Warn if the last version of the api that was developed on is behind the current one.
  - [x] Warn if the script is older than some time.
  - [x] Improve command result messages (make specific answers and eliminate "command executed" when not needed).
  - [x] Teleporters can now use several random destinations.
  - [x] New `BonusRemoveGround` bonus.
  - [x] Many new images for image modules.
  - [x] Custom maps can now have a `background_color` attribute.
  - [ ] Command `!enablecheats` to enable or disable cheat commands for everyone.
  - [-] Filterkey detection.
- other:
  - [x] `pshy_players`: remove `.is_facing_right` and replace with a separate module.
  - [-] TFM's LUA performance test. Results will be released in a specific file.
  - [ ] Test with cute mice!

For v0.6:
- Fixes:
  - [ ] Players cant respawn after being banned by antiguest, even if unbanned.
  - [ ] Rotation help.
  - [ ] Pshy version not displayed when submodule.
  - [ ] Antimacro can be highly improved.
  - [ ] Make `!rejoin` better simulate a rejoin.
  - [ ] Make keystats report weird things (cf win without keys).
  - [ ] Optimize merged events (dont always check for updates of the function).
  - [ ] Make an emoji rate limit (to prevent abuses).
  - [ ] Redo `pshy_bonuses`.
- Performances:
  - [ ] Gather keyboard features in other kind of events? (`eventDirectionChanged`? `eventControl`(bound differently)?)
  - [ ] Making `pshy` and `pshy.players` locals may help some script's performances.
- Interface:
  - [-] `pshy_autoid.lua`: Create functions that returns an allocated id.
  - [ ] `pshy_newgame.lua`: Implement `title` and `author`.
- Features:
  - [-] Command `!luals`.
  - [ ] Use FNN for emote keys.
  - [ ] Use a default set of help pages.
  - [-] Finish overriding `tfm.exec.newGame`.
  - [-] Handle custom map features.
  - [ ] Create and fill a vanilla_vs rotation.
  - [ ] Create anticheat maps played and appropriate rotations.
  - [ ] An `!anti` command to play anticheat maps.
  - [ ] Enable custom maps features in most scripts.
  - [ ] Add commands to give/remove permissions.
  - [ ] Make `!keystats` (no args) gives global stats.
  - [ ] Requests should not display until a room admin wants to pop some of them.
- Lower priority/optional (may be delayed):
  - [ ] Rate limits to `pshy_emoticons`.
  - [ ] Make `!disablemodule` safe.
  - [ ] `pshy_keyboard` ? to bind keys to functions instead of having an event ?
  - [ ] Add a way to bind the mouse when a key is pressed (command executer on combo). (Low priority, because keyboard features are already causing too many issues)
  - [ ] Move antiguest to tools. (Is it realy useful to be public?)

For v0.7:
- [-] Clean combine.py, make clearer error messages.
- [ ] "-- @mapmodule" to disable a module by default (so it's enabled only on games needing it). (or "-- @default_disabled", for modules requiring others?)

For 1.0:
- [ ] Test compatibility with scripts from other authors.
- [ ] Create separate `master`, `prerelease` and `dev` public branches. `master` will only contain stable and tested scripts.
- [ ] Replace `chat_commands` by `commands` in all scripts.
- [ ] Implement `pshy_alloc`. (what happen to grounds on eventNewGame?)
- [ ] Test all the current scripts and fix as many bugs as possible.

For later (I will not be doing those unless you tell me you need):
- [ ] Anti-xbug
- [x] Make an extention for pshy_merge debug features, instead of ugly conditions.
- [ ] Remove some dependencies, so you can add pshy features to your scripts without adding too many things.
- [ ] Add an user interface to ease the use of the scripts for commandophobics.
- [ ] A settings script with a command to change the different script's available settings (so you wont need to go in the source anymore).
- [ ] Generate rotations from desired map features (for instance `!rotc {racing, lava}`)
- [ ] Dual shaman may not be working due to features being unavailable from lua, but can be replaced.
- [ ] Make specific funtions to create commands (instead of adding to a list).
- [ ] Make specific funtions to create help pages (instead of adding to a list).
- [ ] Change the conditions required by pshy_merge to enable/disable a module (internally know dependencies?)
- [ ] Add translation features (per-player translations).
- [ ] Translations.
- [ ] Add alias for commands with arguments.
- [ ] Command to list allowed commands (other than the help).
- [ ] `!autochangeimages`.
- [ ] Troll luamap: teleporting/talking cheese.
- [ ] Some bot detection using special maps and bonuses?.
- [ ] Command to cause automatic image changes between rounds.



# Combined TFM Lua Scripts

Projects using pshy_merge:
- [Nnaaaz's death maze](https://github.com/nnaaaz/DeathMaze)

You can find ready-to-run-in-game combined scripts in `examples/`.

- `pshyvs.tfm.lua`: My main TFM vs script.
- `pshyfun.tfm.lua`: My main chill script, used for funcorp villages.
- `mario.tfm.lua`: Module to run Nnaaaz#0000's Mario map.
- `pacmice.tfm.lua`: A pacman module, but with mice.

The folowing scripts require you to download third-party scripts separately,  
place those in `lua/other/`,  
then run `make examples/SCRIPT_NAME.lua`.

- `vsteamsantimacro.tfm.lua`: Mattseba#0000's V/S Teams script with additions (see `!pshy.help vs`).
- `vsteams.tfm.lua`: Mattseba#0000's V/S Teams script with additions (see `!pshy.help vs`), and an alternative antimacro.

[Mattseba's scripts (FunCorp only)](https://atelier801.com/topic?f=6&t=894050&p=1#m13) - Name the files `vs_teams_with_antimacro.lua` and `vs_teams_without_antimacro.lua` respectively.
Note that the latest versions should accept the `!vs.` command prefix.

Run `make combined/MODULE_NAME.combined.lua` to compile a single script.

Run `make allall` to compile every modulepack possible, but this require you to download every single third-party script.

Help about ingame commands is available [here](./TODO.md)



# Merge modules

You can merge modules using `./combine.py pshy_merge.lua [additional_module_names_to_merge_in_that_order] <main_module>` script.

Your modules must be located in a folder within `lua/`
The folder `lua/pshy/` is reserved for Pshy's scripts.
The folder `lua/pshy_private/` is reserved for Pshy's private scripts.
The folder `lua/test/` is reserved for test scripts.
Use the `lua/other/` folder by default, or create one for you.

Within your source files, you can use the following documentation tags:
- `-- @require otherscript.lua`: Specify that your script require another one.
- `-- @optional_require otherscript.lua`: Specify that your script require another one, but only if it's specified when compiling.
- `-- @require_priority CATEGORY`: Secondary setting to help choosing the order for script that dont depends on each other (0 = highest, 10 = lowest, default = 5).
Those settings helps choosing the order in which the different scripts will be merged.
This also define the order in which the events will be called.

When including `pshy_merge.lua`, either on the command line or with `-- @require pshy_merge.lua`,  
you can merge modules even if they would otherwise be conflicting because they use the same events.

Example to merge the modules listed in modulepack_pshyfun.lua and  
put the result in the clipboard with `xclip`:
```bash
./combine.py modulepack_pshyfun.lua | xclip -selection clipboard
```



# Minigames (NOT SUPPORTED YET, BUT SOON)

If you make a minigame script that is supposed to only run when your map is enabled, 
add `-- @mapmodule` somewhere in your script, so that it wont be enabled by default.
You also need to add en entry in `pshy.mapdb_maps` so that your script get loaded when this map is run.
Your other module's events wont be called while the module is disabled (callbacks will still be called).
You can add this at the end of your script to simulate it being ran as a minigame:
```lua
if not pshy then
	if eventInit then
		eventInit()
	end
	if eventEnableModule then
		eventEnableModule()
	end
end
```



# Fixing conflicts / issues

Pshy's commands may be called using the `!pshy ` prefix. You can also enforce this (if another module use the same command name):
lua:
```lua
pshy.commands_require_prefix = true
```
ingame:
```
!pshy set pshy.commands_require_prefix true
```

Avoid calling an event yourself, unless your REALY want all modules to receive the event.
For instance, if you call `eventNewPlayer()` yourself, then all modules will receive this call.
This is probably not what you want.
You should instead call a function (for instance `local function TouchPlayer(player_name)`) from `eventNewGame`, and for each player, from `eventInit`.
The same goes for all events.

I may add the ability to use a prefix for any module in the future.

If several modules use a graphic interfaces or ingame objects,  
they may conflict because of the use of identical ids.
This cannot be fixed yet by `pshy_merge`.
I recommend using arbitrary random ids to dodge the issue (but I will add a function for that in the future).

If several modules use the keyboard and mouse, they may obviously conflict.
This cannot be fixed yet (but I may create a keyboard remapping script to fix this).

The merging scripts abort an event if you return either True or False from it.
In this case, later modules will not receive the event.



# Use Pshy modules as dependancies

You can, but be aware that the current version may see substantial changes.



# License

This is a TODO.
But you will be able to reuse the scripts as long as I am mentioned as the original author.
Some scripts may also be from other people (They should be credited in the source files after a `-- @author`).
