# TFM Lua performance tests results.



## Pshy performances before opti
keyboard events (? -> 0.0565 -> 0.0552)
`pshy_keystats` (eventKeyboard 0.0154 -> 0.0283)
`pshy_players` (eventKeyboard 0.0140)
`pshy_bindkey` (eventKeyboard 0.0079).
`pshy_emoticons` (eventKeyboard 0.0200ms)
`pshy_changeimage` (eventKeyboard 0.0093ms)
`pshy_antimacro` (eventKeyboard 0.0086 -> 0.0154)



## Test 1 (2021-12-16)

**Values are for 100 operations.** (So if a time is 0.033ms/call, it's 0.00033ms/operation.)
**All tests include "witness".** (It's an empty test to know the cost of measuring)
**Those values are too small to be accurate.**

• # [@Pshy] Times at 1639682116888:
• # [@Pshy] call(): 33ms / 1000calls == 0.033 ms/call
• # [@Pshy] global=int: 25ms / 1000calls == 0.025 ms/call
• # [@Pshy] ipairs_iteration: 28ms / 1000calls == 0.028 ms/call
• # [@Pshy] local=int: 14ms / 1000calls == 0.014 ms/call
• # [@Pshy] local=string: 15ms / 1000calls == 0.015 ms/call
• # [@Pshy] numeric_for_iteration: 16ms / 1000calls == 0.016 ms/call
• # [@Pshy] os.time(): 44ms / 1000calls == 0.044 ms/call
• # [@Pshy] pairs_iteration: 36ms / 1000calls == 0.036 ms/call
• # [@Pshy] pass_arg(ints): 12ms / 1000calls == 0.012 ms/call
• # [@Pshy] pass_arg(strings): 16ms / 1000calls == 0.016 ms/call
• # [@Pshy] string==string: 14ms / 1000calls == 0.014 ms/call
• # [@Pshy] tfm.get.room.playerList[]: 113ms / 1000calls == 0.113 ms/call
• # [@Pshy] witness: 8ms / 1000calls == 0.008 ms/call



## Test 2 (2021-12-16)

**Values are for 100 operations.** (So if a time is 0.033ms/call, it's 0.00033ms/operation.)
**All tests include "witness".** (It's an empty test to know the cost of measuring)
**Those values are too small to be accurate.**

• # [@Pshy] Times at 1639684089998:
• # [@Pshy] call(): 36ms / 1000calls == 0.036 ms/call
• # [@Pshy] global=int: 23ms / 1000calls == 0.023 ms/call
• # [@Pshy] ipairs_iteration: 28ms / 1000calls == 0.028 ms/call
• # [@Pshy] keyboard_event_v0: 66ms / 1000calls == 0.066 ms/call
• # [@Pshy] keyboard_event_v1: 87ms / 1000calls == 0.087 ms/call
• # [@Pshy] keyboard_event_v2: 108ms / 1000calls == 0.108 ms/call
• # [@Pshy] keyboard_event_v3: 91ms / 1000calls == 0.091 ms/call
• # [@Pshy] local=int: 17ms / 1000calls == 0.017 ms/call
• # [@Pshy] local=string: 16ms / 1000calls == 0.016 ms/call
• # [@Pshy] numeric_for_iteration: 12ms / 1000calls == 0.012 ms/call
• # [@Pshy] os.time(): 47ms / 1000calls == 0.047 ms/call
• # [@Pshy] pairs_iteration: 40ms / 1000calls == 0.04 ms/call
• # [@Pshy] pass_arg(ints): 19ms / 1000calls == 0.019 ms/call
• # [@Pshy] pass_arg(strings): 7ms / 1000calls == 0.007 ms/call
• # [@Pshy] string==string: 14ms / 1000calls == 0.014 ms/call
• # [@Pshy] tfm.get.room.playerList[]: 108ms / 1000calls == 0.108 ms/call
• # [@Pshy] witness: 7ms / 1000calls == 0.007 ms/call

