# globals vs locals

This test compares globals and locals access times.

Snippet used to measure:
```lua
local start_time = os.time()
Test()
local total_time = os.time() - start_time
print("taken: " .. tostring(total_time) .. "ms")
```
The empty test loop takes 37ms for 400000 access (so you can remove it from all results).



## local read
```
local dst
local v = 5
local function Test()
	for i = 1, 400000 do
		dst = v + v + v + v + v + v + v + v + v + v
	end
end
```
> #  taken: 240ms
> #  taken: 237ms
> #  taken: 237ms



## local write
```
local v
local function Test()
	for i = 1, 400000 do
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
	end
end
```
> #  taken: 214ms
> #  taken: 215ms
> #  taken: 216ms



## global read
```
local dst
v = 5
local function Test()
	for i = 1, 400000 do
		dst = v + v + v + v + v + v + v + v + v + v
	end
end
```
> #  taken: 288ms
> #  taken: 288ms
> #  taken: 288ms



## local write
```
local function Test()
	for i = 1, 400000 do
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
		v = 5
	end
end
```
> #  taken: 277ms
> #  taken: 278ms
> #  taken: 272ms
