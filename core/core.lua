Saturn = {}

Saturn.MOD = {}
Saturn.MOD.PATH = lovely.mod_dir .. "/QualityOfBalatro/"
Saturn.MOD.VERSION = "1.0.0"

function Saturn.initSaturn()
    local lovely = require("lovely")
    local nativefs = require("modules.nativefs")
    --- Load Saturn Components
    assert(load(nativefs.read(Saturn.MOD.PATH .. "core/stattrack.lua")))
end