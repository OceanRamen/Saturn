local nfs = require("nativefs")
local lovely = require("lovely")

local is_dev = false

Saturn = {
  -- Consts
  VERSION = "alpha-0.2.0-D",
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
  print("Loading Saturn files...")

  local function safeLoad(filePath)
    if nfs.getInfo(filePath) then
      local chunk, err = load(nfs.read(filePath))
      if chunk then
        local success, execErr = pcall(chunk)
        if not success then
          error("Error executing file: " .. filePath .. "\n" .. execErr)
        end
      else
        error("Error loading file: " .. filePath .. "\n" .. err)
      end
    else
      error("File not found: " .. filePath)
    end
  end

  -- Utils
  safeLoad(Saturn.PATH .. "/core/utils/table_utils.lua")
  safeLoad(Saturn.PATH .. "/core/utils/misc_funcs.lua")

  -- Loads other Saturn logic files for feature
  safeLoad(Saturn.PATH .. "/core/logic/rem_anim.lua")
  safeLoad(Saturn.PATH .. "/core/logic/stack/consumeable_stacking.lua")
  safeLoad(Saturn.PATH .. "/core/logic/stack/stack-ui.lua")
  -- safeLoad(Saturn.PATH .. "/core/logic/hide_played.lua")

  -- UI
  safeLoad(Saturn.PATH .. "/UI/definitions.lua")
  safeLoad(Saturn.PATH .. "/UI/functions.lua")

  if is_dev == true then
    safeLoad(Saturn.PATH .. "/Testing/ui_tests.lua")
    safeLoad(Saturn.PATH .. "/Testing/stat_tests.lua")
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
