Saturn = {}
Saturn.MOD = {}
Saturn.MOD.VERSION = "1.0.0"
Saturn.MOD.RELEASE = false

function Saturn.initSaturn()
  local lovely = require("lovely")
  local nativefs = require("nativefs")
  Saturn.MOD.PATH = lovely.mod_dir .. "/Saturn/"
  --- Load Saturn Components
  assert(load(nativefs.read(Saturn.MOD.PATH .. "core/stattrack.lua")))()
end

