# TFM Lua performance tests results.



## Test 1 (2021-12-16)

**Values are for 100 operations.** (So if a time is 0.033ms/call, it's 0.00033ms/operation.)
**All tests include "witness".** (It's an empty test to know the cost of measuring)
**Those values are too small to be accurate.**

```
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
```



## Test 2 (2021-12-16)

**Values are for 100 operations.** (So if a time is 0.033ms/call, it's 0.00033ms/operation.)
**All tests include "witness".** (It's an empty test to know the cost of measuring)
**Those values are too small to be accurate.**

```
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
```



## Test 3 (2021-12-16)

**Values are for 100 operations.** (So if a time is 0.033ms/call, it's 0.00033ms/operation.)
**All tests include "witness".** (It's an empty test to know the cost of measuring)
**Those values are too small to be accurate.**

```
• # [@Pshy] Times at 1639686145753:
• # [@Pshy] call(): 34ms / 1000calls == 0.034 ms/call
• # [@Pshy] global=int: 16ms / 1000calls == 0.016 ms/call
• # [@Pshy] ipairs_iteration: 28ms / 1000calls == 0.028 ms/call
• # [@Pshy] keyboard_event_v0: 51ms / 1000calls == 0.051 ms/call
• # [@Pshy] keyboard_event_v1: 70ms / 1000calls == 0.07 ms/call
• # [@Pshy] keyboard_event_v2: 96ms / 1000calls == 0.096 ms/call
• # [@Pshy] keyboard_event_v3: 93ms / 1000calls == 0.093 ms/call
• # [@Pshy] keyboard_event_v4: 44ms / 1000calls == 0.044 ms/call
• # [@Pshy] local=int: 17ms / 1000calls == 0.017 ms/call
• # [@Pshy] local=string: 15ms / 1000calls == 0.015 ms/call
• # [@Pshy] numeric_for_iteration: 21ms / 1000calls == 0.021 ms/call
• # [@Pshy] os.time(): 48ms / 1000calls == 0.048 ms/call
• # [@Pshy] pairs_iteration: 45ms / 1000calls == 0.045 ms/call
• # [@Pshy] pass_arg(ints): 19ms / 1000calls == 0.019 ms/call
• # [@Pshy] pass_arg(strings): 11ms / 1000calls == 0.011 ms/call
• # [@Pshy] string==string: 10ms / 1000calls == 0.01 ms/call
• # [@Pshy] tests: 890ms / 61calls == 14.59016 ms/call
• # [@Pshy] tfm.get.room.playerList[]: 103ms / 1000calls == 0.103 ms/call
• # [@Pshy] witness: 4ms / 1000calls == 0.004 ms/call
```



# Test 4 (2022-03-13)

**Values are for 100 operations.** (So if a time is 0.033ms/call, it's 0.00033ms/operation.)
**All tests include "witness".** (It's an empty test to know the cost of measuring)
**Those values are too small to be accurate.**

```
• #  Times at 1647188689951:
• #  call(): 28ms / 1000calls == 0.028 ms/call
• #  call_longfuncname(): 33ms / 1000calls == 0.033 ms/call
• #  global=int: 18ms / 1000calls == 0.018 ms/call
• #  ipairs_iteration: 16ms / 1000calls == 0.016 ms/call
• #  keyboard_event_v0: 60ms / 1000calls == 0.06 ms/call
• #  keyboard_event_v1: 86ms / 1000calls == 0.086 ms/call
• #  keyboard_event_v2: 133ms / 1000calls == 0.133 ms/call
• #  keyboard_event_v3: 90ms / 1000calls == 0.09 ms/call
• #  keyboard_event_v6: 47ms / 1000calls == 0.047 ms/call
• #  local=int: 13ms / 1000calls == 0.013 ms/call
• #  local=string: 10ms / 1000calls == 0.01 ms/call
• #  numeric_for_iteration: 15ms / 1000calls == 0.015 ms/call
• #  os.time(): 59ms / 1000calls == 0.059 ms/call
• #  pairs_iteration: 43ms / 1000calls == 0.043 ms/call
• #  pass_arg(ints): 17ms / 1000calls == 0.017 ms/call
• #  pass_arg(strings): 23ms / 1000calls == 0.023 ms/call
• #  string==string: 20ms / 1000calls == 0.02 ms/call
• #  tests: 976ms / 293calls == 3.331058 ms/call
• #  tfm.get.room.playerList[]: 107ms / 1000calls == 0.107 ms/call
• #  witness: 5ms / 1000calls == 0.005 ms/call
```



# Test 5 (2022-04-10, TFM v7.95, pshy v0.7.5-c14)

**Values are for 100 operations.** (So if a time is 0.033ms/call, it's 0.00033ms/operation.)
**All tests include "witness".** (It's an empty test to know the cost of measuring)
**Those values are too small to be accurate.**
**Tests `string==string` and `tfm.get.room.playerList` were made slightly more complex than in pevious tests!**

## first set (crashed before reaching 1000 calls)
```
• #  Times at 1649545528198:
• #  call(): 35ms / 840calls == 0.041666 ms/call
• #  call(t): 43ms / 840calls == 0.051190 ms/call
• #  call_longfuncname(): 38ms / 840calls == 0.045238 ms/call
• #  global=int: 31ms / 840calls == 0.036904 ms/call
• #  ipairs_iteration: 27ms / 840calls == 0.032142 ms/call
• #  keyboard_event_v0: 54ms / 840calls == 0.064285 ms/call
• #  keyboard_event_v1: 85ms / 840calls == 0.101190 ms/call
• #  keyboard_event_v2: 132ms / 840calls == 0.157142 ms/call
• #  keyboard_event_v3: 95ms / 840calls == 0.113095 ms/call
• #  keyboard_event_v6: 53ms / 840calls == 0.063095 ms/call
• #  local=int: 20ms / 840calls == 0.023809 ms/call
• #  local=string: 28ms / 840calls == 0.033333 ms/call
• #  next_iteration: 35ms / 840calls == 0.041666 ms/call
• #  numeric_for_iteration: 15ms / 840calls == 0.017857 ms/call
• #  os.time(): 56ms / 840calls == 0.066666 ms/call
• #  pairs_iteration: 50ms / 840calls == 0.059523 ms/call
• #  pass_arg(10-strings): 20ms / 840calls == 0.023809 ms/call
• #  pass_arg(ints): 12ms / 840calls == 0.014285 ms/call
• #  string==string: 8ms / 840calls == 0.009523 ms/call
• #  t:call(): 50ms / 840calls == 0.059523 ms/call
• #  tests: 1279ms / 50calls == 25.58 ms/call
• #  tfm.get.room.playerList[]: 149ms / 840calls == 0.177380 ms/call
• #  witness: 5ms / 840calls == 0.005952 ms/call
```

## second set
```
• #  Times at 1649546071975:
• #  call(): 53ms / 1000calls == 0.053 ms/call
• #  call(t): 51ms / 1000calls == 0.051 ms/call
• #  call_longfuncname(): 49ms / 1000calls == 0.049 ms/call
• #  global=int: 38ms / 1000calls == 0.038 ms/call
• #  ipairs_iteration: 57ms / 1000calls == 0.057 ms/call
• #  keyboard_event_v0: 89ms / 1000calls == 0.089 ms/call
• #  keyboard_event_v1: 93ms / 1000calls == 0.093 ms/call
• #  keyboard_event_v2: 142ms / 1000calls == 0.142 ms/call
• #  keyboard_event_v3: 132ms / 1000calls == 0.132 ms/call
• #  keyboard_event_v6: 54ms / 1000calls == 0.054 ms/call
• #  local=int: 21ms / 1000calls == 0.021 ms/call
• #  local=string: 18ms / 1000calls == 0.018 ms/call
• #  next_iteration: 47ms / 1000calls == 0.047 ms/call
• #  numeric_for_iteration: 13ms / 1000calls == 0.013 ms/call
• #  os.time(): 85ms / 1000calls == 0.085 ms/call
• #  pairs_iteration: 61ms / 1000calls == 0.061 ms/call
• #  pass_arg(10-strings): 14ms / 1000calls == 0.014 ms/call
• #  pass_arg(ints): 18ms / 1000calls == 0.018 ms/call
• #  string==string: 12ms / 1000calls == 0.012 ms/call
• #  t:call(): 76ms / 1000calls == 0.076 ms/call
• #  tests: 1613ms / 55calls == 29.32727 ms/call
• #  tfm.get.room.playerList[]: 213ms / 1000calls == 0.213 ms/call
• #  witness: 9ms / 1000calls == 0.009 ms/call
```
