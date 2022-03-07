# TODO

This is my personal TODO list.
Feel free to create issues on github if something is not in the list.

For v0.6:
	**/!\ It looks like that since 0.6, many things that are not mentioned here are being added or improved.**
	Due to many changes that were not in the todo, it is possible that the next versions will be delayed to the next one.

For v0.7:
- Fixes:
  - [x] Move some of the heavy (in code size) features to optional scripts.
  - [-] ~~Players cant respawn after being banned by antiguest, even if unbanned.~~ (caused by a thirdparty script)
  - [-] Antimacro can be highly improved.
  - [-] Make keystats report weird things (cf win without keys).
  - [x] `pshy_newgame` gets stuck if a map it tries to load does not exist.
  - [ ] Sometime the xml from the previous map does not get cleared on the next one.
  - [ ] Rate limits to `pshy_emoticons`.
- Performances:
  - [x] `pshy_merge.lua`: Minimize the generated `eventKeyboard` function.
- Interface:
  - [x] `pshy_newgame.lua`: Implement `title` and `author`.
- Features:
  - [x] Command `!luals`.
  - [x] Finish overriding `tfm.exec.newGame`.
  - [x] Handle custom map features.
  - [x] Create and fill a vanilla_vs rotation.
  - [-] Enable custom maps features in most scripts.
  - [x] `!backgroundcolor <color>` command.
  - [ ] Add an inventory system.
  - [ ] Add a default "request" inventory.
- Anticheat:
  - [x] Move antiguest to tools. (Is it realy useful to be public?)
  - [-] Add anticheat maps and rotations.
  - [ ] Add An `!anti` command to play anticheat maps.
  - [-] Filterkey detection.
- Other:
  - [ ] Test with cute mice!

For v0.8:
- Fixes:
  - [-] Clean combine.py, make clearer error messages.
  - [ ] Redo `pshy_bonuses`.
- Performances:
  - [-] Optimize merged events (dont always check for updates of the function).
  - [ ] Gather keyboard features in other kind of events? (`eventDirectionChanged`? `eventControl`(bound differently)?)
  - [ ] Making `pshy` and `pshy.players` locals may help some script's performances.
  - [ ] Make `pshy_splashscreen.lua` use a timer instead of eventLoop.
- Features:
  - [-] `pshy_autoid.lua`: Create functions that returns an allocated id.
- Interface:
  - [ ] Requests should not display until a room admin wants to pop some of them.
- Optional
  - [ ] "-- @mapmodule" to disable a module by default (so it's enabled only on games needing it). (or "-- @default_disabled", for modules requiring others?)
  - [ ] Make `!disablemodule` safe.

For 1.0:
- [ ] Test compatibility with scripts from other authors.
- [ ] Create separate `master`, `prerelease` and `dev` public branches. `master` will only contain stable and tested scripts.
- [x] Replace `chat_commands` by `commands` in all scripts.
- [ ] Implement `pshy_alloc`. (what happen to grounds on eventNewGame?)
- [ ] Test all the current scripts and fix as many bugs as possible.

Ideas/Maybe/Canceled (Not foing unless needed and asked for):
- Features:
  - [x] Make an extention for pshy_merge debug features, instead of ugly conditions.
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
  - [ ] Some bot detection using special maps and bonuses?.
  - [ ] Command to cause automatic image changes between rounds (`!autochangeimages`).
  - [ ] Add a way to bind the mouse when a key is pressed (command executer on combo). (Low priority, because keyboard features are already causing too many issues)
  - [ ] `pshy_keyboard` ? to bind keys to functions instead of having an event ?
  - [ ] Add commands to give/remove permissions. (not that useful)
  - [ ] ~~Troll luamap: teleporting/talking cheese.~~ (the api can now simulate a physical cheese)
  - [ ] ~~Move examples to their own repositories.~~ (there is examples of this already and it will be slower to maintain)
  - [ ] ~~Make `!keystats` (no args) gives global stats.~~ (not that useful)
  - [ ] ~~Use FNN for emote keys~~ (players may try things such as `ALT + F4`).
  - [ ] ~~Use a default set of help pages.~~ (there must be a better idea)
- Fixes:
  - [ ] Remove some dependencies, so the generated script is less heavy.
  - [ ] ~~Make `!rejoin` better simulate a rejoin.~~ (not that useful)
  - [ ] Pshy version not displayed from a submodule.
