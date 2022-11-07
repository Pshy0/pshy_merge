# TODO

This is my personal TODO list.
Feel free to create issues on github if something is not in the list.

Misc:
 - [ ] Requests should not display until a room admin wants to pop some of them.
 - [ ] Implement `pshy_alloc`. (what happen to grounds on eventNewGame?)
 - [ ] Some features (cf `!getxml`) does not work with /np (but work with `!skip`).
 - [ ] Make `!disablemodule` safe.
 - [ ] "-- @mapmodule" to disable a module by default (so it's enabled only on games needing it). (or "-- @default_disabled", for modules requiring others?)

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
