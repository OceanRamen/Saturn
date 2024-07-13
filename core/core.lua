local lovely = require("lovely")
local nativefs = require("nativefs")
Saturn = {}
Saturn.MOD = {}
Saturn.MOD.VERSION = "1.2.2-PRE-ALPHA"
Saturn.MOD.RELEASE = false
Saturn.MOD.PATH = lovely.mod_dir .. "/Saturn/"

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

-- Function to convert table to a string in Lua code format
local function tableToString(tbl, indent)
  indent = indent or 0
  local result = "{\n"
  local padding = string.rep("  ", indent + 1)

  for k, v in pairs(tbl) do
    if type(k) == "string" then
      k = '"' .. k .. '"'
    end

    if type(v) == "table" then
      result = result .. padding .. "[" .. k .. "] = " .. tableToString(v, indent + 1) .. ",\n"
    else
      result = result .. padding .. "[" .. k .. "] = " .. tostring(v) .. ",\n"
    end
  end

  result = result .. string.rep("  ", indent) .. "}"
  return result
end

local default_settings = {
  ["STATTRACK"] = {
    ["ENABLED"] = true,
    ["MONEY_GEN"] = true,
    ["MISCELLANEOUS"] = true,
    ["PLUS_CHIPS"] = true,
    ["X_MULT"] = true,
    ["PLUS_MULT"] = true,
    ["CARD_GEN"] = true,
  },
  ["DECKVIEWER"] = {
    ["ENABLED"] = true,
    ["HIDE_PLAYED"] = {
      ["ENABLED"] = true,
    },
  },
  ["GENQOL"] = {
    ["ENABLED"] = true,
    ["RETRY_BUTTON"] = {
      ["ENABLED"] = true,
      ["COLOUR"] = HEX("13afce"),
    }
  }
}

local Timer = requireWithNFS(Saturn.MOD.PATH .. "functions/timer.lua")

function Saturn.initSaturn()
  local lovely = require("lovely")
  local nativefs = require("nativefs")
  
  Saturn.TOOLS.LOGGER = requireWithNFS(Saturn.MOD.PATH .. "tools/logger.lua")
  Saturn.TOOLS.INSPECTOR = requireWithNFS(Saturn.MOD.PATH .. "tools/inspector.lua")
  --- Load User Settings
  if nativefs.getInfo(Saturn.MOD.PATH .. "user/settings.lua") then
    local settings_file = STR_UNPACK(nativefs.read((Saturn.MOD.PATH .. "user/settings.lua")))
    if settings_file ~= nil then
      Saturn.USER.SETTINGS = settings_file
    else
      Saturn.USER.SETTINGS = default_settings
    end
  else
    Saturn.TOOLS.LOGGER.logInfo("settings.lua not found... attempting to create new settings.lua file")
    local settings_content = "return " .. tableToString(default_settings)
    local success, err = nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", settings_content)
    if success then
      Saturn.TOOLS.LOGGER.logInfo("Successfully created settings.lua")
      Saturn.USER.SETTINGS = default_settings
    else
      Saturn.TOOLS.LOGGER.logError("Unable to create settings.lua... please check your folder permissions")
    end
  end

  -- Saturn.TOOLS.LOGGER.logInfo(Saturn.TOOLS.INSPECTOR.inspectDepth(Saturn.USER.SETTINGS))
  --- Load Saturn Components
  assert(load(nativefs.read(Saturn.MOD.PATH .. "core/stattrack.lua")))()
  assert(load(nativefs.read(Saturn.MOD.PATH .. "core/usersettings.lua")))()
  assert(load(nativefs.read(Saturn.MOD.PATH .. "core/genqol.lua")))()
  Saturn.TOOLS.LOGGER.logInfo("initialization succesful")
end


local game_start_run_ref = Game.start_run
function Game:start_run(args)
  game_start_run_ref(self, args)
  if Saturn.USER.SETTINGS.GENQOL["ENABLED"] and Saturn.USER.SETTINGS.GENQOL.TIMER["ENABLED"] then
    Saturn.TIMER = Timer:new()
    Saturn.TIMER:start(onTimerStop)
    Game.runTimerHUD = UIBox({
      definition = create_UIBox_runTimer(),
      config = { align = "cri", offset = { x = -0.3, y = 2.1 }, major = G.ROOM_ATTACH },
    })
  end
end

local win_game_ref = win_game
function win_game()
  if Saturn.TIMER and Saturn.TIMER.running then 
    Saturn.TIMER:stop()
    print(Saturn.TIMER.elapsed)
  end
  win_game_ref()
end

local game_update_game_over_ref = Game.update_game_over
function Game:update_game_over(dt)
  if Saturn.TIMER and Saturn.TIMER.running then 
    Saturn.TIMER:stop()
    print(Saturn.TIMER.elapsed)
  end
  game_update_game_over_ref(self, dt)
end

local game_update_ref = Game.update
function Game:update(dt)
  game_update_ref(self, dt)
  if Saturn.TIMER and Saturn.TIMER.running then
    Saturn.TIMER:update(dt)
    Saturn.TIMER.disp = Saturn.TIMER:getFormattedTime()
  end

end


function create_UIBox_runTimer()
  return {
    n = G.UIT.ROOT,
    config = { align = "cm", padding = 0.03, colour = G.C.UI.TRANSPARENT_DARK, r = 0.1 },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.05, colour = G.C.DYN_UI.MAIN, r = 0.1 },
        nodes = {
          {
            n = G.UIT.R,
            config = { align = "cm", colour = G.C.DYN_UI.BOSS_DARK, r = 0.1, minw = 1.5, padding = 0.08 },
            nodes = {
              { n = G.UIT.R, config = { align = "cm", minh = 0.0 }, nodes = {} },
              {
                n = G.UIT.R,
                config = {
                  id = "speedrun_timer_right",
                  align = "cm",
                  padding = 0.05,
                  minw = 1.45,
                  emboss = 0.05,
                  r = 0.1,
                },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                      {
                        n = G.UIT.O,
                        config = {
                          object = DynaText({
                            string = { { ref_table = Saturn.TIMER, ref_value = "disp" } },
                            colours = { G.C.WHITE },
                            shadow = true,
                            bump = true,
                            scale = 0.6,
                            pop_in = 0.5,
                            maxw = 5,
                            silent = true,
                          }),
                          id = "timer",
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  }
end
