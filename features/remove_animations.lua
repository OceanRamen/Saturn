-- Reference original functions
local card_eval_status_text_ref = card_eval_status_text
local juice_card_ref = juice_card
local ease_dollars_ref = ease_dollars
local update_hand_text_ref = update_hand_text
local card_calculate_joker_ref = Card.calculate_joker
local card_use_consumeable_ref = Card.use_consumeable
local g_funcs_evaluate_play_ref = G.FUNCS.evaluate_play
local card_start_materialize_ref = Card.start_materialize
local card_start_dissolve_ref = Card.start_dissolve
local card_set_seal_ref = Card.set_seal

--- Evaluate card status text.
-- @param a Parameter a.
-- @param b Parameter b.
-- @param c Parameter c.
-- @param d Parameter d.
-- @param e Parameter e.
-- @param f Parameter f.
function card_eval_status_text(a, b, c, d, e, f)
  if not S.SETTINGS.modules.remove_animations.enabled then
    card_eval_status_text_ref(a, b, c, d, e, f)
  end
end

--- Juice card.
-- @param x Parameter x.
function juice_card(x)
  if not S.SETTINGS.modules.remove_animations.enabled then
    juice_card_ref(x)
  end
end

--- Ease dollars.
-- @param mod Amount to modify.
-- @param instant Whether the modification is instant.
function ease_dollars(mod, instant)
  if S.SETTINGS.modules.remove_animations.enabled then
    if mod > 0 then
      inc_career_stat("c_dollars_earned", mod)
    end
    S.add_dollar_amt = S.add_dollar_amt + mod
    G.GAME.dollars = G.GAME.dollars + mod
    check_and_set_high_score("most_money", G.GAME.dollars)
    check_for_unlock({ type = "money" })
    S.dollar_update = true
  else
    return ease_dollars_ref(mod, instant)
  end
end

--- Update hand text.
-- @param config Configuration table.
-- @param vals Values to update.
function s_update_hand_text(config, vals)
  local col = G.C.GREEN

  -- Update chips
  if vals.chips and G.GAME.current_round.current_hand.chips ~= vals.chips then
    local delta = (type(vals.chips) == "number" and type(G.GAME.current_round.current_hand.chips) == "number")
        and (vals.chips - G.GAME.current_round.current_hand.chips)
      or 0
    delta, col = format_delta(delta, vals.chips)
    G.GAME.current_round.current_hand.chips = vals.chips
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
  if vals.mult and G.GAME.current_round.current_hand.mult ~= vals.mult then
    local delta = (type(vals.mult) == "number" and type(G.GAME.current_round.current_hand.mult) == "number")
        and (vals.mult - G.GAME.current_round.current_hand.mult)
      or 0
    delta, col = format_delta(delta, vals.mult)
    G.GAME.current_round.current_hand.mult = vals.mult
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
  if vals.handname and G.GAME.current_round.current_hand.handname ~= vals.handname then
    G.GAME.current_round.current_hand.handname = vals.handname
    if not config.nopulse then
      G.hand_text_area.handname.config.object:pulse(0.2)
    end
  end

  -- Update chip total
  if vals.chip_total then
    G.GAME.current_round.current_hand.chip_total = vals.chip_total
    G.hand_text_area.chip_total.config.object:pulse(0.5)
  end

  -- Update level
  if
    vals.level and G.GAME.current_round.current_hand.hand_level ~= " " .. localize("k_lvl") .. tostring(vals.level)
  then
    if vals.level == "" then
      G.GAME.current_round.current_hand.hand_level = vals.level
    else
      G.GAME.current_round.current_hand.hand_level = " " .. localize("k_lvl") .. tostring(vals.level)
      if type(vals.level) == "number" then
        G.hand_text_area.hand_level.config.colour = G.C.HAND_LEVELS[math.min(vals.level, 7)]
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

--- Update hand text wrapper.
-- @param config Configuration table.
-- @param vals Values to update.
function update_hand_text(config, vals)
  if S.SETTINGS.modules.remove_animations.enabled then
    if G.latest_uht then
      local chips = G.latest_uht.vals.chips
      local mult = G.latest_uht.vals.mult
      if not vals.chips then
        vals.chips = chips
      end
      if not vals.mult then
        vals.mult = mult
      end
    end
    G.latest_uht = { config = config, vals = vals }
  else
    update_hand_text_ref(config, vals)
  end
end

--- Calculate joker for card.
-- @param context Context parameter.
function Card:calculate_joker(context)
  S.calculating_joker = true
  local ret = card_calculate_joker_ref(self, context)
  S.calculating_joker = false
  return ret
end

--- Use consumeable card.
-- @param x Parameter x.
-- @param y Parameter y.
function Card:use_consumeable(x, y)
  S.calculating_score = true
  local ret = card_use_consumeable_ref(self, x, y)
  S.calculating_score = false
  return ret
end

--- Evaluate play function wrapper.
-- @param e Parameter e.
G.FUNCS.evaluate_play = function(e)
  S.calculating_score = true
  local ret = g_funcs_evaluate_play_ref(e)
  S.calculating_score = false
  return ret
end

--- Start materialize card.
-- @param a Parameter a.
-- @param b Parameter b.
-- @param c Parameter c.
function Card:start_materialize(a, b, c)
  if
    S.SETTINGS.modules.remove_animations.enabled and (S.calculating_joker or S.calculating_score or S.calculating_card)
  then
    return
  end
  return card_start_materialize_ref(self, a, b, c)
end

--- Start dissolve card.
-- @param a Parameter a.
-- @param b Parameter b.
-- @param c Parameter c.
-- @param d Parameter d.
function Card:start_dissolve(a, b, c, d)
  if
    S.SETTINGS.modules.remove_animations.enabled and (S.calculating_joker or S.calculating_score or S.calculating_card)
  then
    self:remove()
    return
  end
  return card_start_dissolve_ref(self, a, b, c, d)
end

--- Set seal for card.
-- @param a Parameter a.
-- @param b Parameter b.
-- @param immediate Whether the seal is immediate.
function Card:set_seal(a, b, immediate)
  return card_set_seal_ref(
    self,
    a,
    b,
    S.SETTINGS.modules.remove_animations.enabled and (S.calculating_joker or S.calculating_score or S.calculating_card)
      or immediate
  )
end

--- Format the delta value and color.
-- @param delta Delta value.
-- @param value Value to compare.
-- @return Formatted delta and color.
function format_delta(delta, value)
  local col = G.C.GREEN
  if delta < 0 then
    delta = "" .. delta
    col = G.C.RED
  elseif delta > 0 then
    delta = "+" .. delta
  else
    delta = "" .. delta
  end
  if type(value) == "string" then
    delta = value
  end
  return delta, col
end
