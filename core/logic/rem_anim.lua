-- Reference original functions
local cardEvalStatusTextRef = card_eval_status_text
local juiceCardRef = juice_card
local cardJuiceUpRef = Card.juice_up
local easeDollarsRef = ease_dollars
local updateHandTextRef = update_hand_text
local cardCalculateJokerRef = Card.calculate_joker
local cardUseConsumeableRef = Card.use_consumeable
local cardStartMaterializeRef = Card.start_materialize
local cardStartDissolveRef = Card.start_dissolve
local cardSetSealRef = Card.set_seal
local evalPlayRef = G.FUNCS.evaluate_play
local gameUpdateRef = Game.update

to_big = to_big or function(x)
  return x
end
to_number = to_number or function(x)
  return x
end

local function isCalculating()
  return G.STATE_COMPLETE
end

local caph = CardArea.parse_highlighted
function Game:update(dt)
  gameUpdateRef(self, dt)
  if G.latest_uht and G.latest_uht.config and G.latest_uht.vals then
    if
      Saturn.config.enable_dramatic_final_hand
      and G.GAME.current_round.hands_left == 0
    then
      sUpdateHandTextDramatic(G.latest_uht.config, G.latest_uht.vals)
    end
    sUpdateHandText(G.latest_uht.config, G.latest_uht.vals)
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

function Card:juice_up(...)
  if Saturn.config.remove_animations and isCalculating() then
    return
  end
  return cardJuiceUpRef(self, ...)
end

function card_eval_status_text(...)
  if Saturn.config.remove_animations and isCalculating() then
    return
  end
  cardEvalStatusTextRef(...)
end

function juice_card(...)
  if Saturn.config.remove_animations and isCalculating() then
    return
  end
  juiceCardRef(...)
end

function ease_dollars(mod, instant)
  mod = to_big(mod)
  if Saturn.config.remove_animations then
    if mod > to_big(0) then
      inc_career_stat("c_dollars_earned", mod)
    end
    Saturn.dollars_add_amount = to_big(Saturn.dollars_add_amount) + mod
    G.GAME.dollars = to_big(G.GAME.dollars) + mod
    check_and_set_high_score("most_money", G.GAME.dollars)
    check_for_unlock({ type = "money" })
    Saturn.dollars_update = true
  else
    easeDollarsRef(mod, instant)
  end
end

function update_hand_text(config, vals)
  if Saturn.config.remove_animations and not Saturn.using_consumeable then
    if G.latest_uht then
      vals.chips = vals.chips or to_big(G.latest_uht.vals.chips)
      vals.mult = vals.mult or to_big(G.latest_uht.vals.mult)
    end
    G.latest_uht = { config = config, vals = vals }
  else
    updateHandTextRef(config, vals)
  end
end

function Card:calculate_joker(context)
  Saturn.calculating_joker = true
  local ret = cardCalculateJokerRef(self, context)
  Saturn.calculating_joker = false
  return ret
end

function Card:use_consumeable(area, copier)
  -- Saturn.calculating_score = true
  Saturn.using_consumeable = true
  local ret = cardUseConsumeableRef(self, area, copier)
  Saturn.using_consumeable = false
  -- Saturn.calculating_score = false
  return ret
end

G.FUNCS.evaluate_play = function(e)
  Saturn.calculating_score = true
  local ret = evalPlayRef(e)
  Saturn.calculating_score = false
  return ret
end

function Card:start_materialize(dissolve_colours, silent, timefac)
  if not (Saturn.config.remove_animations and isCalculating()) then
    cardStartMaterializeRef(self, dissolve_colours, silent, timefac)
  end
end

function Card:start_dissolve(
  dissolve_colours,
  silent,
  dissolve_time_fac,
  no_juice
)
  if Saturn.config.remove_animations and isCalculating() then
    self:remove()
  else
    cardStartDissolveRef(
      self,
      dissolve_colours,
      silent,
      dissolve_time_fac,
      no_juice
    )
  end
end

function Card:set_seal(_seal, silent, immediate)
  local instant = Saturn.config.remove_animations and isCalculating()
    or immediate
  cardSetSealRef(self, _seal, silent, instant)
end

function format_delta(delta, value)
  delta = to_big(delta)
  local col = delta < to_big(0) and G.C.RED or G.C.GREEN
  if delta > to_big(0) then
    delta = "+" .. delta
  end
  return tostring(delta), col
end

function sUpdateHandText(config, vals)
  if not G.hand then
    return false
  end
  local col = G.C.GREEN

  -- Update chips
  if
    vals.chips
    and to_big(G.GAME.current_round.current_hand.chips) ~= to_big(vals.chips)
  then
    local delta = (
      (type(vals.chips) == "number" or type(vals.chips) == "table")
      and (
        type(G.GAME.current_round.current_hand.chips) == "number"
        or type(G.GAME.current_round.current_hand.chips) == "table"
      )
    )
        and (to_big(vals.chips) - to_big(
          G.GAME.current_round.current_hand.chips
        ))
      or to_big(0)
    delta, col = format_delta(delta, vals.chips)
    G.GAME.current_round.current_hand.chips = to_big(vals.chips)
    G.hand_text_area.chips:update(0)
    if vals.StatusText then
      attention_text({
        text = delta,
        scale = 0.8,
        hold = 1,
        cover = G.hand_text_area.chips.parent,
        cover_colour = mix_colours(G.C.CHIPS, col, 0.1),
        emboss = 0.05,
        align = "cm",
        cover_align = "cr",
      })
    end
  end

  -- Update mult
  if
    vals.mult
    and to_big(G.GAME.current_round.current_hand.mult) ~= to_big(vals.mult)
  then
    local delta = (
      (type(vals.mult) == "number" or type(vals.mult) == "table")
      and (
        type(G.GAME.current_round.current_hand.mult) == "number"
        or type(G.GAME.current_round.current_hand.mult) == "table"
      )
    )
        and (to_big(vals.mult) - to_big(G.GAME.current_round.current_hand.mult))
      or to_big(0)
    delta, col = format_delta(delta, vals.mult)
    G.GAME.current_round.current_hand.mult = to_big(vals.mult)
    G.hand_text_area.mult:update(0)
    if vals.StatusText then
      attention_text({
        text = delta,
        scale = 0.8,
        hold = 1,
        cover = G.hand_text_area.mult.parent,
        cover_colour = mix_colours(G.C.MULT, col, 0.1),
        emboss = 0.05,
        align = "cm",
        cover_align = "cl",
      })
    end
    if not G.TAROT_INTERRUPT then
      G.hand_text_area.mult:juice_up()
    end
  end

  -- Update handname
  if
    vals.handname
    and G.GAME.current_round.current_hand.handname ~= vals.handname
  then
    G.GAME.current_round.current_hand.handname = vals.handname
    if not config.nopulse then
      G.hand_text_area.handname.config.object:pulse(0.2)
    end
  end

  -- Update chip total
  if to_big(vals.chip_total) then
    G.GAME.current_round.current_hand.chip_total = to_big(vals.chip_total)
    G.hand_text_area.chip_total.config.object:pulse(0.5)
  end

  -- Update level
  if
    to_big(vals.level)
    and G.GAME.current_round.current_hand.hand_level
      ~= " " .. localize("k_lvl") .. tostring(vals.level)
  then
    if vals.level == "" then
      G.GAME.current_round.current_hand.hand_level = vals.level
    else
      G.GAME.current_round.current_hand.hand_level = " "
        .. localize("k_lvl")
        .. tostring(vals.level)
      if type(vals.level) == "number" or type(vals.level) == "table" then
        G.hand_text_area.hand_level.config.colour =
          G.C.HAND_LEVELS[to_number(math.min(to_big(vals.level), to_big(7)))]
      else
        G.hand_text_area.hand_level.config.colour = G.C.HAND_LEVELS[1]
      end
      G.hand_text_area.hand_level:juice_up()
    end
  end

  -- Play sound
  if config.sound and not config.modded then
    play_sound(config.sound, config.pitch or 1, config.volume or 1)
  end

  -- Handle modded configuration
  if config.modded then
    G.HUD_blind:get_UIE_by_ID("HUD_blind_debuff_1"):juice_up(0.3, 0)
    G.HUD_blind:get_UIE_by_ID("HUD_blind_debuff_2"):juice_up(0.3, 0)
    G.GAME.blind:juice_up()
    G.E_MANAGER:add_event(Event({
      trigger = "after",
      delay = 0.06 * G.SETTINGS.GAMESPEED,
      blockable = false,
      blocking = false,
      func = function()
        play_sound("tarot2", 0.76, 0.4)
        return true
      end,
    }))
    play_sound("tarot2", 1, 0.4)
  end

  return true
end

function sUpdateHandTextDramatic(config, vals)
  if not G.hand then
    return false
  end
  local col = G.C.GREEN

  -- Update chips
  if
    vals.chips
    and to_big(G.GAME.current_round.current_hand.chips) ~= to_big(vals.chips)
  then
    local delta = (
      (type(vals.chips) == "number" or type(vals.chips) == "table")
      and (
        type(G.GAME.current_round.current_hand.chips) == "number"
        or type(G.GAME.current_round.current_hand.chips) == "table"
      )
    )
        and (to_big(vals.chips) - to_big(
          G.GAME.current_round.current_hand.chips
        ))
      or to_big(0)
    delta, col = format_delta(delta, vals.chips)
    G.GAME.current_round.current_hand.chips = to_big(vals.chips)
    G.hand_text_area.chips:update(0)
    if vals.StatusText then
      attention_text({
        text = delta,
        scale = 0.8,
        hold = 1,
        cover = G.hand_text_area.chips.parent,
        cover_colour = mix_colours(G.C.CHIPS, col, 0.1),
        emboss = 0.05,
        align = "cm",
        cover_align = "cr",
      })
    end
  end

  -- Update mult
  if
    vals.mult
    and to_big(G.GAME.current_round.current_hand.mult) ~= to_big(vals.mult)
  then
    local delta = (
      (type(vals.mult) == "number" or type(vals.mult) == "table")
      and (
        type(G.GAME.current_round.current_hand.mult) == "number"
        or type(G.GAME.current_round.current_hand.mult) == "table"
      )
    )
        and (to_big(vals.mult) - to_big(G.GAME.current_round.current_hand.mult))
      or to_big(0)
    delta, col = format_delta(delta, vals.mult)
    G.GAME.current_round.current_hand.mult = to_big(vals.mult)
    G.hand_text_area.mult:update(0)
    if vals.StatusText then
      attention_text({
        text = delta,
        scale = 0.8,
        hold = 1,
        cover = G.hand_text_area.mult.parent,
        cover_colour = mix_colours(G.C.MULT, col, 0.1),
        emboss = 0.05,
        align = "cm",
        cover_align = "cl",
      })
    end
    if not G.TAROT_INTERRUPT then
      G.hand_text_area.mult:juice_up()
    end
  end

  -- Update handname
  if
    vals.handname
    and G.GAME.current_round.current_hand.handname ~= vals.handname
  then
    G.GAME.current_round.current_hand.handname = vals.handname
    if not config.nopulse then
      G.hand_text_area.handname.config.object:pulse(0.2)
    end
  end

  -- Update chip total
  if to_big(vals.chip_total) then
    G.GAME.current_round.current_hand.chip_total = to_big(vals.chip_total)
    G.hand_text_area.chip_total.config.object:pulse(0.5)
  end

  -- Update level
  if
    to_big(vals.level)
    and G.GAME.current_round.current_hand.hand_level
      ~= " " .. localize("k_lvl") .. tostring(vals.level)
  then
    if vals.level == "" then
      G.GAME.current_round.current_hand.hand_level = vals.level
    else
      G.GAME.current_round.current_hand.hand_level = " "
        .. localize("k_lvl")
        .. tostring(vals.level)
      if type(vals.level) == "number" or type(vals.level) == "table" then
        G.hand_text_area.hand_level.config.colour =
          G.C.HAND_LEVELS[to_number(math.min(to_big(vals.level), to_big(7)))]
      else
        G.hand_text_area.hand_level.config.colour = G.C.HAND_LEVELS[1]
      end
      G.hand_text_area.hand_level:juice_up()
    end
  end

  -- Play sound
  if config.sound and not config.modded then
    play_sound(config.sound, config.pitch or 1, config.volume or 1)
  end

  -- Handle modded configuration
  if config.modded then
    G.HUD_blind:get_UIE_by_ID("HUD_blind_debuff_1"):juice_up(0.3, 0)
    G.HUD_blind:get_UIE_by_ID("HUD_blind_debuff_2"):juice_up(0.3, 0)
    G.GAME.blind:juice_up()
    G.E_MANAGER:add_event(Event({
      trigger = "after",
      delay = 0.06 * G.SETTINGS.GAMESPEED,
      blockable = false,
      blocking = false,
      func = function()
        play_sound("tarot2", 0.76, 0.4)
        return true
      end,
    }))
    play_sound("tarot2", 1, 0.4)
  end

  return true
end
