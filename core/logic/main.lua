local nfs = require("nativefs")
local lovely = require("lovely")

local is_dev = false

Saturn = {
  -- Consts
  VERSION = "0.2.3b",
  PATH = "",
  DEFAULTS = {},
  -- Vars
  config = {},
  -- // Rem-Animation
  calculating_card = false,
  calculating_joker = false,
  calculating_score = false,
  using_consumeable = false,
  dollars_add_amount = 0,
  dollars_update = false,

  -- UI
  ui = {
    opts = {},
  },
}

local mod_dir = lovely.mod_dir -- Cache the base directory
local found = false
local search_str = "saturn" -- or "saturn-dev" depending on the environment

for _, item in ipairs(nfs.getDirectoryItems(mod_dir)) do
  local itemPath = mod_dir .. "/" .. item
  -- Check if the item is a directory and contains the search string
  if
    nfs.getInfo(itemPath, "directory") and string.lower(item):find(search_str)
  then
    Saturn.PATH = itemPath
    found = true
    break
  end
end

-- Raise an error if the directory wasn't found
if not found then
  error("ERROR: Unable to locate Saturn directory.")
end

function Saturn.getDefaults()
  local defaults_path = Saturn.PATH .. "/core/config/defaults.lua"
  if not nfs.getInfo(defaults_path) then
    error("Unable to fetch default configs.")
  else
    local defaults_loader = loadfile(defaults_path)
    if defaults_loader then
      Saturn.DEFAULTS = defaults_loader() or nil
      if not Saturn.DEFAULTS then
        error("Unable to read default config.")
      end
    end
  end
end

function Saturn.loadConfig()
  local config_path = Saturn.PATH .. "/core/config/settings.lua"
  if not nfs.getInfo(config_path) then
    Saturn.writeConfig()
  else
    local config_loader = loadfile(config_path)
    if config_loader then
      Saturn.config = config_loader() or Saturn.DEFAULTS
    else
      error("Failed to load config file.")
    end
  end
end

function Saturn.writeConfig()
  local config_path = Saturn.PATH .. "/core/config/settings.lua"
  local data = Saturn.config or Saturn.DEFAULTS or {}
  local success, err = nfs.write(config_path, STR_PACK(data))
  if not success then
    error("Failed to write config file: " .. (err or "UNKNOWN ERROR"))
  end
end

function Saturn.loadLogic()
  -- Utils
  assert(load(nfs.read(Saturn.PATH .. "/core/utils/table_utils.lua")))()

  -- Loads other Saturn logic files for feature
  assert(load(nfs.read(Saturn.PATH .. "/core/logic/rem_anim.lua")))()
  -- UI
  assert(load(nfs.read(Saturn.PATH .. "/UI/definitions.lua")))()
  assert(load(nfs.read(Saturn.PATH .. "/UI/functions.lua")))()

  if is_dev == true then
    assert(load(nfs.read(Saturn.PATH .. "/Testing/ui_tests.lua")))()
    assert(load(nfs.read(Saturn.PATH .. "/Testing/stat_tests.lua")))()
  end
end

function Saturn.initialize()
  Saturn.getDefaults()
  Saturn.loadConfig()
  Saturn.loadLogic()
end

local start_up_ref = Game.start_up
function Game:start_up()
  start_up_ref(self)
  Saturn.initialize()
end
