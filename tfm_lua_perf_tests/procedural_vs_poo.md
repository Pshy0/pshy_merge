# Procedural VS POO

Those tests compare performances of procedural vs POO.

Snipped used to measure:
```lua
local start_time = os.time()
Test()
local total_time = os.time() - start_time
print("taken: " .. tostring(total_time) .. "ms")
```

## Procedural
```lua
local function DrinkMilk(cat)
	cat.fur = cat.fur + 1
end
local cat = {fur = 4}
local function Test()
	for i = 1, 100000 do
		DrinkMilk(cat)
		DrinkMilk(cat)
		DrinkMilk(cat)
		DrinkMilk(cat)
		DrinkMilk(cat)
		DrinkMilk(cat)
		DrinkMilk(cat)
		DrinkMilk(cat)
		DrinkMilk(cat)
		DrinkMilk(cat)
	end
end
```
> #  taken: 298ms
> #  taken: 299ms
> #  taken: 299ms



## Metatable Class
```lua
local Cat = {fur = 4}
function Cat:NewCat()
	local obj = {}
	setmetatable(obj, self)
	self.__index = self
	self.fur = self.fur
	return self
end
function Cat:DrinkMilk()
	self.fur = self.fur + 1
end
local cat = Cat:NewCat({})
local function Test()
	for i = 1, 100000 do
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
	end
end
```
> #  taken: 337ms
> #  taken: 333ms
> #  taken: 338ms



## Function Class
```lua
local function Cat()
	local fur = 4
	local function DrinkMilk()
		fur = fur + 1
	end
	return {DrinkMilk = DrinkMilk}
end
local cat = Cat()
function Test()
	for i = 1, 100000 do
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
	end
end
```
> #  taken: 296ms
> #  taken: 300ms
> #  taken: 299ms



## Hybrid Class
```lua
local function Cat()
	local Cat = {}
	local fur = 4
	function Cat:DrinkMilk()
		fur = fur + 1
	end
	return Cat
end
local cat = Cat()
local function Test()
	for i = 1, 100000 do
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
		cat:DrinkMilk()
	end
end
```
> #  taken: 298ms
> #  taken: 299ms
> #  taken: 299ms
