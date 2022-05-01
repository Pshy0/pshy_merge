# Make custom bonuses maps

This module contains additional custom bonuses.

This document explain how to use them to make maps.



# Edit a map

I recommend using [miceditor](https://entibo.github.io/miceditor/) to create custom bonus maps.

To insert a custom bonus, add a new circle ground (13), with the folowing properties:
- Foreground: ☐ false
- Invisible: ☑ true
- Collision with mice: ☐ false
- Collision with grounds: ☐ false
- Color: __use a color from the type table__

The bonus type will depend on the bonus color.



# Test a map with the script

To run the script in your tribehouse:
- Go to your tribehouse.
- Ensure you have, or request the permission from your tribe leaders, to run scripts in your tribehouse.
- Type `/lua` in the chat to open a text area to paste scripts in.
- Copy [this script](https://github.com/Pshy0/pshy_merge/releases/download/v0.7.8/pshy_essentials_plus.tfm.lua.txt) to the test area, then click `confirm`

Then you have two ways to run the map:
- Run a map you exported:
  - Use the `!skip @mapcode` command.
- To run a map from miceditor:
  - In [miceditor](https://entibo.github.io/miceditor/), click on the robot icon on the right of the xml text box.
  - Click the tribehouse tab, click on `Start session`, enter your name, and use the provided command to invite the bot in your tribehouse (do not load the script provided on miceditor).
  - Finaly click `Check` to run the map in your tribehouse.

You may have to use `!shaman <on/off> [player_name]` to test your maps.



# Bonus Type table

**from `pshy_bonuses_basic.lua`:**
| Color | Name | Behavior Type | Effect |
| ----- | ---- | ------------- | ------ |
| F00000 | BonusShrink | `standard` | Makes the player smaller. |
| 0000F0 | BonusGrow | `standard` | Makes the player bigger. |
| 008080 | BonusAttachBalloon | `standard` | Attach a balloon to the player. |
| F080F0 | BonusShaman | `shared` | Turns the first player to grab into a shaman. |
| 804020 | BonusTransformations | `standard` | Gives transformation powers. |
| 8080F0 | BonusFreeze | `standard` | Freeze the mice. |
| 4040F0 | BonusIce | `standard` | Turns the mice into an ice block. |
| 101010 | BonusStrange | `standard` | Turns the mice into strange bonuses (rare bonus, use only if you have a good idea). |
| F0F000 | BonusCheese | `standard` | Turns players into a cheese. |
| 00F000 | BonusTeleporter | `standard` | Teleport players randomly. |
| 00F001 | Teleporter | `remain` | Teleport players randomly. Can be reused. |
| F05040 | BonusCircle | `standard` | Catch the mice inside itself (rare bonus, use only if you have a good idea). |
| F08080 | BonusMarry | `standard` | Creates pairs of soulmates. |
| F08081 | BonusDivorce | `standard` | Release soulmates. |
| 202020 | BonusCannonball | `shared` | Shoots a cannonball when the first player takes it. |
| F06000 | BonusFish | `standard` | Summons loads of fishes when the first player takes it. |
| E04040 | BonusDeath | `remain` | Kills players. |

**from `pshy_bonuses_checkpoints.lua`:**
| Color | Name | Behavior Type | Effect |
| ----- | ---- | ------------- | ------ |
| E0E0E0 | BonusCheckpoint | `standard` | Save the current player location and cheese state. |
| E0E0E1 | BonusSpawnpoint | `standard` | Save the current player location as his spawn. |

**from `pshy_bonuses_speedfly.lua`:**
| Color | Name | Behavior Type | Effect |
| ----- | ---- | ------------- | ------ |
| F0F0F0 | BonusFly | `standard` | Allow the player to fly. |
| F04040 | BonusHighSpeed | `standard` | Gives the player a massive acceleration boost. |

**from `pshy_bonuses_misc.lua`:**
| Color | Name | Behavior Type | Effect |
| ----- | ---- | ------------- | ------ |
| 805040 | MouseTrap | `shared` | Mouse trap that kills the first player to go on it and summon a used trap as a little plank. |
| E00000 | GoreDeath | `remain` | Invisible bonus that kills players and display red particles. |
| D0D000 | PickableCheese | `shared` | Pickable cheese, can be taken by only one player. |
| D0F000 | CorrectCheese | `standard` | Cheese that kills the player and display a red cross when taken. |
| F0D000 | WrongCheese | `standard` | Cheese that displays a green check when the player takes it. |
| ? | Hole | `remain` | Behave like a hole. |
| ? | Cheese | `remain` | Behave like a cheese. |

**from `pshy_bonuses_mario.lua`:**
| Color | Name | Behavior Type | Effect |
| ----- | ---- | ------------- | ------ |
| 4D6101 | MarioCoin | `standard` | Change the player name's color when they grabbed enough coins. |
| 4D6102 | MarioMushroom | `respawn` | Makes the player bigger and gives him 1 health point. |
| 4D6103 | MarioFlower | `standard` | Allows the player to shoot fireballs. |
| 4D6104 | MarioCheckpoint | - | (undetermined) |



# Bonus Behavior Types

Bonuses have 4 different behavior types:
| Behavior Type | Effect |
| ------------- | ------ |
| `standard` | Can be taken once per player. |
| `shared` | Can only be taken once and disapear from other players. |
| `remain` | Never disapear but does its effect on players passing on it. |
| `respawn` | Same as standard but respawns when the player respawn. |



# Optimal placement

Maps objects are ordered acording to their `Z` property.
To improve the script performances, you should order the bonuses in a specific way:
- Group `standard` and `shared` bonuses first, the more numerous group first (lowest `Z`).
- Order the bonuses in those groups depending on the order in wich they are likely to be taken.
- Put `respawn` (respawning) and `remain` bonuses at the end (highest `Z`).



# Submit your maps

Before submitting the maps you want to be added to the script, please ensure the folowing:
- Your map follows game rules applicable to maps.
- Your map does not rely on bugs or undefined/unspecified behaviors.
- Your map have at least 1 spawn, and it does not overlap with the hole (do not rely on the game using the hole as a spawn when you do not put one).
- Your map have a shaman spawn if and only if it is supposed to be a shaman map.
- Your map is interresting, it have original gameplay or something, it is not just a random map with random bonuses added on it.
- Your map looks good and have decorations if appropriate.
- The bonuses are ordered as specified in the "Optimal placement" section.
- You have tested your map with the script and it works as expected.
- Your map does not cause warning or error messages in `#lua`.
