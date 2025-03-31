to_big = to_big or function(x)
  return x
end
to_number = to_number or function(x)
  return x
end

function format_delta(delta, value)
  delta = to_big(delta)
  local col = delta < to_big(0) and G.C.RED or G.C.GREEN
  if delta > to_big(0) then
    delta = "+" .. delta
  end
  return tostring(delta), col
end

local updateHandTextRef = update_hand_text
function update_hand_text(config, vals)
  if Saturn.should_skip_animation({ scoring = true }) then
    if G.latest_uht then
      vals.chips = vals.chips or G.latest_uht.vals.chips
      vals.mult = vals.mult or G.latest_uht.vals.mult
    end
    G.latest_uht = { config = config, vals = vals }
  else
    return updateHandTextRef(config, vals)
  end
end

local gameUpdateRef = Game.update
function Game:update(dt)
  gameUpdateRef(self, dt)

  if G.latest_uht and G.latest_uht.config and G.latest_uht.vals then
    G.latest_uht.config.immediate = true
    updateHandTextRef(G.latest_uht.config, G.latest_uht.vals)
    G.latest_uht = nil
  end

  if Saturn.dollars_update then
    local dollars_ui = G.HUD:get_UIE_by_ID("dollar_text_UI")
    dollars_ui.config.object:update()
    G.HUD:recalculate()
    local function _mod(mod)
      mod = mod or to_big(0)
      local text = "+" .. localize("$")
      local col = G.C.MONEY
      if mod < to_big(0) then
        text = "-" .. localize("$")
        col = G.C.RED
      end
      attention_text({
        text = text .. tostring(math.abs(mod)),
        scale = 0.8,
        hold = 1.5,
        cover = dollars_ui.parent,
        cover_colour = col,
        align = "cm",
      })
      play_sound("coin1")
    end
    G.E_MANAGER:add_event(
      Event({
        trigger = "immediate",
        func = function()
          _mod(Saturn.dollars_add_amount)
          Saturn.dollars_add_amount = to_big(0)
          return true
        end,
      }),
      "other"
    )
    Saturn.dollars_update = false
  end
end

local cardJuiceUpRef = Card.juice_up
function Card:juice_up(...)
  if Saturn.should_skip_animation() then
    return
  end
  return cardJuiceUpRef(self, ...)
end

local cardEvalStatusTextRef = card_eval_status_text
function card_eval_status_text(...)
  if Saturn.should_skip_animation() then
    return
  end
  return cardEvalStatusTextRef(...)
end

local juiceCardRef = juice_card
function juice_card(...)
  if Saturn.should_skip_animation() then
    return
  end
  return juiceCardRef(...)
end

local easeDollarsRef = ease_dollars
function ease_dollars(mod, instant)
  mod = to_big(mod)
  if Saturn.config.remove_animations then
    if mod > to_big(0) then
      inc_career_stat("c_dollars_earned", mod)
    end
    Saturn.dollars_add_amount = to_big(Saturn.dollars_add_amount) + mod
    G.GAME.dollars = to_big(G.GAME.dollars) + mod
    check_and_set_high_score("most_money", G.GAME.dollars)
    -- TODO: Wait for Talisman fix
    -- check_for_unlock({ type = "money" })
    Saturn.dollars_update = true
  else
    return easeDollarsRef(mod, instant)
  end
end

local cardStartDissolveRef = Card.start_dissolve
function Card:start_dissolve(...)
  if Saturn.should_skip_animation() then
    self:remove()
  else
    return cardStartDissolveRef(self, ...)
  end
end

local cardCalculateJokerRef = Card.calculate_joker
function Card:calculate_joker(...)
  Saturn.calculating_joker = true
  local ret = cardCalculateJokerRef(self, ...)
  Saturn.calculating_joker = false
  return ret
end

local cardUseConsumeableRef = Card.use_consumeable
function Card:use_consumeable(...)
  Saturn.using_consumeable = true
  local ret = cardUseConsumeableRef(self, ...)
  Saturn.using_consumeable = false
  return ret
end

local evaluatePlayRef = G.FUNCS.evaluate_play
G.FUNCS.evaluate_play = function(...)
  Saturn.calculating_score = true
  local ret = evaluatePlayRef(...)
  Saturn.calculating_score = false
  return ret
end

-- TODO: in question
-- local delayRef = delay
-- function delay(time, queue)
--   if Saturn.should_skip_animation() then
--     return
--   end
--   return delayRef(time, queue)
-- end

-- For debuging event queue

-- local callstep = 0
-- function printCallerInfo()
--   -- Get debug info for the caller of the function that called printCallerInfo
--   local info = debug.getinfo(3, "Sl")
--   callstep = callstep + 1
--   if info then
--     print(
--       "["
--         .. callstep
--         .. "] "
--         .. (info.short_src or "???")
--         .. ":"
--         .. (info.currentline or "unknown")
--     )
--   else
--     print("Caller information not available")
--   end
-- end
-- local emae = EventManager.add_event
-- function EventManager:add_event(x, y, z)
--   printCallerInfo()
--   return emae(self, x, y, z)
-- end
