local nfs = require("nativefs")
local lovely = require("lovely")

local is_dev = false

Saturn = {
  -- Consts
  VERSION = "alpha-0.2.0-C",
  PATH = "",
  DEFAULTS = {},
  -- Vars
  config = {},
  -- Rem-Animation
  calculating_card = false,
  calculating_joker = false,
  calculating_score = false,
  using_consumeable = false,
  dollars_add_amount = 0,
  dollars_update = false,
  -- stacking
  is_merging = false,
  is_splitting = false,
  waiting_to_merge = {},
  do_merge = false,

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

-- Function to get default configurations
function Saturn.getDefaults()
  -- Path to the default configuration file
  local defaults_path = Saturn.PATH .. "/core/config/defaults.lua"

  -- Check if the default configuration file exists
  if not nfs.getInfo(defaults_path) then
    error("Unable to fetch default configs.")
  else
    -- Load the default configuration file
    local defaults_loader = loadfile(defaults_path)

    -- If the file is loaded successfully, execute it
    if defaults_loader then
      Saturn.DEFAULTS = defaults_loader() or nil

      -- Raise an error if the default configuration could not be read
      if not Saturn.DEFAULTS then
        error("Unable to read default config.")
      end
    end
  end
end

-- Function to load the user configuration
function Saturn.loadConfig()
  -- Path to the user configuration file
  local config_path = Saturn.PATH .. "/core/config/settings.lua"

  -- Check if the user configuration file exists
  if not nfs.getInfo(config_path) then
    -- If the file does not exist, write a new configuration
    Saturn.writeConfig()
  else
    -- Load the user configuration file
    local config_loader = loadfile(config_path)

    -- If the file is loaded successfully, execute it
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
  assert(load(nfs.read(Saturn.PATH .. "/core/logic/stack.lua")))()
  -- assert(load(nfs.read(Saturn.PATH .. "/core/logic/stats.lua")))()
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

local setting_tabRef = G.UIDEF.settings_tab
function G.UIDEF.settings_tab(tab)
  local setting_tab = setting_tabRef(tab)
  if tab == "Game" then
    local speeds = create_option_cycle({
      label = localize("b_set_gamespeed"),
      scale = 0.8,
      options = { 0.25, 0.5, 1, 2, 3, 4, 8, 16 },
      opt_callback = "change_gamespeed",
      current_option = (
        G.SETTINGS.GAMESPEED == 0.25 and 1
        or G.SETTINGS.GAMESPEED == 0.5 and 2
        or G.SETTINGS.GAMESPEED == 1 and 3
        or G.SETTINGS.GAMESPEED == 2 and 4
        or G.SETTINGS.GAMESPEED == 3 and 5
        or G.SETTINGS.GAMESPEED == 4 and 6
        or G.SETTINGS.GAMESPEED == 8 and 7
        or G.SETTINGS.GAMESPEED == 16 and 8
        or 3
      ),
    })
    setting_tab.nodes[1] = speeds
  end
  return setting_tab
end
