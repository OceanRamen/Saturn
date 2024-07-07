local nativefs = require("nativefs")
Saturn = {}
Saturn.MOD = {}
Saturn.MOD.VERSION = "1.0.0"
Saturn.MOD.RELEASE = false

Saturn.USER = {}
Saturn.TOOLS = {}
Saturn.debug_true = true
local function requireWithNFS(modulePath)
  -- Read the file content
  local content, err = nativefs.read(modulePath)
  if not content then
    error("Error reading module file: " .. tostring(err))
  end

  -- Load the content as a chunk
  local chunk, loadErr = load(content, modulePath)
  if not chunk then
    error("Error loading module chunk: " .. tostring(loadErr))
  end

  -- Execute the chunk and return the module
  local result = chunk()
  return result
end

function Saturn.initSaturn()
  local lovely = require("lovely")
  local nativefs = require("nativefs")

  Saturn.MOD.PATH = lovely.mod_dir .. "/Saturn/"
  Saturn.TOOLS.LOGGER = requireWithNFS(Saturn.MOD.PATH .. "tools/logger.lua")
  Saturn.TOOLS.INSPECTOR = requireWithNFS(Saturn.MOD.PATH .. "tools/inspector.lua")
  --- Load User Settings
  if nativefs.getInfo(Saturn.MOD.PATH .. "user/settings.lua") then
    local settings_file = STR_UNPACK(nativefs.read((Saturn.MOD.PATH .. "user/settings.lua") ))
    if settings_file ~= nil then
      Saturn.USER.SETTINGS = settings_file
    end
  else
    Saturn.TOOLS.LOGGER.logError("user-settings file not found")
  end
  Saturn.TOOLS.LOGGER.logInfo(Saturn.TOOLS.INSPECTOR.inspectDepth(Saturn.USER.SETTINGS))
  --- Load Saturn Components
  assert(load(nativefs.read(Saturn.MOD.PATH .. "core/stattrack.lua")))()
  assert(load(nativefs.read(Saturn.MOD.PATH .. "core/usersettings.lua")))()
  assert(load(nativefs.read(Saturn.MOD.PATH .. "core/hide_played.lua")))()

  Saturn.TOOLS.LOGGER.logInfo("initialization succesful")
end


