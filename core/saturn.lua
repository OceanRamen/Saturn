local nativefs = require("nativefs")
local lovely = require("lovely")

Saturn = Object:extend()

function Saturn:init()
  S = self

  self:set_globals()
end

function Saturn:start_up()
  self:fetch_settings()
  self:init_console()
end

function Saturn:update(dt)
  if self.REROLL and self.REROLL.active then self:update_reroll(dt) end

  if self.TIMER and self.TIMER.running then
    self.TIMER:update(dt)
    self.TIMER.disp = self.TIMER:getFormattedTime()
  end

  if G.latest_uht and G.latest_uht.config and G.latest_uht.vals then
    s_update_hand_text(G.latest_uht.config, G.latest_uht.vals)
    G.latest_uht = nil
  end 

  if S.dollar_update then
    local dollar_UI = G.HUD:get_UIE_by_ID("dollar_text_UI")
    dollar_UI.config.object:update()
    G.HUD:recalculate()
    local function _mod(mod)
      mod = mod or 0
      local text = "+" .. localize("$")
      local col = G.C.MONEY
      if mod < 0 then
        text = "-" .. localize("$")
        col = G.C.RED
      end
      attention_text({
        text = text .. tostring(math.abs(mod)),
        scale = 0.8,
        hold = 1.5,
        cover = dollar_UI.parent,
        cover_colour = col,
        align = "cm",
      })
      play_sound("coin1")
    end
    G.E_MANAGER:add_event(Event({
      trigger = "immediate",
      func = function()
        _mod(S.add_dollar_amt)
        S.add_dollar_amt = 0
        return true
      end,
    }), "other")
    S.dollar_update = false
  end
end

function Saturn:key_press_update(key)
  if key == "`" or self.CONSOLE.isOpen then
      self:handle_console(key)
  end
end

local game_start_run_ref = Game.start_run
function Game:start_run(args)
  game_start_run_ref(self, args)
  if S.SETTINGS.modules.run_timer.enabled then
    S.TIMER = Timer:new()
    S.TIMER:start(onTimerStop)
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

function Saturn:fetch_settings()
  if not nativefs.getInfo(self.MOD_PATH .. "user_settings.lua") then
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
    local settings_default = "return " .. tableToString(self.SETTINGS)
    local success, err = nativefs.write(self.MOD_PATH .. "user_settings.lua", settings_default)
    if not success then
      return error(err)
    end
  end
  local user_settings = STR_UNPACK(nativefs.read(self.MOD_PATH .. "user_settings.lua"))
  if user_settings ~= nil then
    self.SETTINGS = user_settings
  end
end

function Saturn:write_settings()
  nativefs.write(self.MOD_PATH .. "user_settings.lua", STR_PACK(self.SETTINGS))
  update_all_counters(true)
end
