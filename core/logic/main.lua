local nfs = require("nativefs")
local lovely = require("lovely")

local is_dev = false

to_big = to_big or function(x)
  return x
end
to_number = to_number or function(x)
  return x
end

Saturn = {
  -- Consts
  VERSION = "alpha-0.2.2-E",
  PATH = "",
  DEFAULTS = {},
  -- Vars
  config = {},
  -- Rem-Animation
  calculating_card = false,
  calculating_joker = false,
  calculating_score = false,
  using_consumeable = false,
  dollars_add_amount = to_big(0),
  dollars_update = false,
  -- stacking
  is_merging = false,
  is_splitting = false,
  waiting_to_merge = {},
  do_merge = false,

  ignore_skip_for_money = false,

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

function Saturn.serialize_string(s)
  return string.format("%q", s)
end

function Saturn.serialize_config(t, indent)
  indent = indent or ""
  local str = "{\n"
  for k, v in ipairs(t) do
    str = str .. indent .. "\t"
    if type(v) == "number" then
      str = str .. v
    elseif type(v) == "boolean" then
      str = str .. (v and "true" or "false")
    elseif type(v) == "string" then
      str = str .. Saturn.serialize_string(v)
    elseif type(v) == "table" then
      str = str .. Saturn.serialize_config(v, indent .. "\t")
    else
      -- not serializable
      str = str .. "nil"
    end
    str = str .. ",\n"
  end
  for k, v in pairs(t) do
    if type(k) == "string" then
      str = str .. indent .. "\t" .. "[" .. Saturn.serialize_string(k) .. "] = "

      if type(v) == "number" then
        str = str .. v
      elseif type(v) == "boolean" then
        str = str .. (v and "true" or "false")
      elseif type(v) == "string" then
        str = str .. Saturn.serialize_string(v)
      elseif type(v) == "table" then
        str = str .. Saturn.serialize_config(v, indent .. "\t")
      else
        -- not serializable
        str = str .. "nil"
      end
      str = str .. ",\n"
    end
  end
  str = str .. indent .. "}"
  return str
end

-- Function to load the user configuration
function Saturn.loadConfig()
  local lovely_mod_config = get_compressed("config/Saturn.jkr")
  if lovely_mod_config then
    Saturn.config = STR_UNPACK(lovely_mod_config)
  else
    local config_path = Saturn.PATH .. "/core/config/settings.lua"
    if not nfs.getInfo(config_path) then
      Saturn.writeConfig()
    else
      local config_loader = loadfile(config_path)
      if config_loader then
        Saturn.config = config_loader() or Saturn.DEFAULTS
      else
        Saturn.writeConfig()
      end
    end
  end
end

-- Function to save the user configuration
function Saturn.writeConfig()
  if SMODS and SMODS.save_mod_config and Saturn.current_mod then
    Saturn.current_mod.config = Saturn.config or Saturn.DEFAULTS or {}
    SMODS.save_mod_config(Saturn.current_mod)
  else
    love.filesystem.createDirectory("config")
    local serialized = "return "
      .. Saturn.serialize_config(Saturn.config or Saturn.DEFAULTS or {})
    love.filesystem.write("config/Saturn.jkr", serialized)
  end
end

function Saturn.loadLogic()
  -- Utils
  assert(load(nfs.read(Saturn.PATH .. "/core/utils/table_utils.lua")))()

  -- Loads other Saturn logic files for feature
  assert(load(nfs.read(Saturn.PATH .. "/core/logic/rem_anim.lua")))()
  assert(load(nfs.read(Saturn.PATH .. "/core/logic/stack.lua")))()
  assert(load(nfs.read(Saturn.PATH .. "/core/logic/hide_played.lua")))()
  -- UI
  assert(load(nfs.read(Saturn.PATH .. "/UI/definitions.lua")))()
  assert(load(nfs.read(Saturn.PATH .. "/UI/functions.lua")))()

  if is_dev == true then
    assert(load(nfs.read(Saturn.PATH .. "/Testing/ui_tests.lua")))()
    assert(load(nfs.read(Saturn.PATH .. "/Testing/stat_tests.lua")))()
  end
end

function Saturn.should_skip_animation(options)
  if not Saturn.config.remove_animations then
    return false
  end
  if options then
    if options.scoring then
      return G.STATE_COMPLETE and Saturn.calculating_score
    end
  end
  return G.STATE_COMPLETE or G.STATE == G.STATES.HAND_PLAYED
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
