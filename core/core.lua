local nativefs = require("nativefs")
local lovely = require("lovely")

assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/core/" .. "saturn.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/core/" .. "globals.lua")))()

assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/features/" .. "challenger_plus.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/features/" .. "consumeable_plus.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/features/" .. "stat_tracker.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/features/" .. "remove_animations.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/features/" .. "show_stickers.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/features/" .. "console.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/features/" .. "reroll.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/features/" .. "run_timer.lua")))()

assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/tools/" .. "functions.lua")))()

assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/UI/" .. "ui_definitions.lua")))()
assert(load(nativefs.read(lovely.mod_dir .. "/Saturn/UI/" .. "ui_functions.lua")))()


