G.FUNCS.retry_challenge = function(e)
  G.GAME.viewed_back = nil
  G.run_setup_seed = G.GAME.seeded
  G.challenge_tab = G.GAME and G.GAME.challenge and G.GAME.challenge_tab or nil
  G.forced_seed, G.setup_seed = nil, nil
  if G.GAME.seeded then
    G.forced_seed = G.GAME.pseudorandom.seed
  end
  local current_stake = G.GAME.stake
  local _seed = G.run_setup_seed and G.setup_seed or G.forced_seed or nil
  local _challenge = G.challenge_tab
  if not G.challenge_tab then
    _stake = current_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
  else
    _stake = 1
  end
  G:delete_run()
  G:start_run({ stake = _stake, seed = _seed, challenge = _challenge })
end

G.FUNCS.mass_use_card = function(e)
  local selected_card = e.config.ref_table

  local area = G.STATE
  local to_consume = {}
  local cards = G.consumeables.cards

  -- First pass: Collect cards to be consumed
  for k, v in pairs(cards) do
    if v:can_use_consumeable() then
      if v.label == selected_card.label then
        table.insert(to_consume, v)
      end
    end
  end

  if selected_card.ability.set == "Planet" then
    local area = G.STATE
    local to_consume = {}
    local cards = G.consumeables.cards

    -- First pass: Collect cards to be consumed
    for k, v in pairs(cards) do
      if v:can_use_consumeable() then
        if v.label == selected_card.label then
          table.insert(to_consume, v)
        end
      end
    end

    -- Second pass: Use the collected cards
    local n_levels = #to_consume

    for _, card in ipairs(to_consume) do
      local e = { config = { ref_table = card } }

      -- G.FUNCS.use_card(e)
      if card.area then
        card.area:remove_card(card)
      end
      for i = 1, #G.jokers.cards do
        G.jokers.cards[i]:calculate_joker({ using_consumeable = true, consumeable = card })
      end
      -- card:remove()
      card:start_dissolve()
    end

    update_hand_text({ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 }, {
      handname = localize(selected_card.ability.consumeable.hand_type, "poker_hands"),
      chips = G.GAME.hands[selected_card.ability.consumeable.hand_type].chips,
      mult = G.GAME.hands[selected_card.ability.consumeable.hand_type].mult,
      level = G.GAME.hands[selected_card.ability.consumeable.hand_type].level,
    })
    delay(1.3)
    level_up_hand(selected_card, selected_card.ability.consumeable.hand_type, nil, n_levels)
    update_hand_text(
      { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
      { mult = 0, chips = 0, handname = "", level = "" }
    )
  end

  if
    selected_card.ability.set == "Tarot"
    and (selected_card.ability.name == "Temperance" or selected_card.ability.name == "The Hermit")
  then
    local money_tot = G.GAME.dollars
    stop_use()
    if selected_card.ability.name == "The Hermit" then
      for i = 1, #to_consume do
        money_tot = money_tot + math.max(0, math.min(money_tot, selected_card.ability.extra))
      end
      money_tot = money_tot - G.GAME.dollars
      G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.4,
        func = function()
          play_sound("timpani")
          selected_card:juice_up(0.3, 0.5)
          ease_dollars(money_tot, true)
          return true
        end,
      }))
      delay(0.6)
    elseif selected_card.ability.name == "Temperance" then
      money_tot = 0
      for i = 1, #to_consume do
        money_tot = money_tot + selected_card.ability.money
      end
      G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.4,
        func = function()
          play_sound("timpani")
          selected_card:juice_up(0.3, 0.5)
          ease_dollars(money_tot, true)
          return true
        end,
      }))
      delay(0.6)
    end
  end

  -- Second pass: Use the collected cards
  for _, card in ipairs(to_consume) do
    if card.area then
      card:remove()
    end
    card:start_dissolve()
  end
end

G.FUNCS.check_mass_use = function(e)
  local card = e.config.ref_table
  if
    card:can_use_consumeable()
    and (
      (card.ability.set == "Planet")
      or (card.ability.set == "Tarot" and (card.ability.name == "Hermit" or card.ability.name == "Temperance"))
    )
  then
    return true
  else
    return false
  end
end

G.FUNCS.can_mass_use = function(e)
  local card = e.config.ref_table
  if
    card:can_use_consumeable()
    and (
      (card.ability.set == "Planet")
      or (card.ability.set == "Tarot" and (card.ability.name == "Hermit" or card.ability.name == "Temperance"))
    )
  then
    e.config.colour = G.C.SECONDARY_SET.Planet
    e.config.button = "mass_use_card"
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

function G.UIDEF.mass_use_button(card)
  local mass_use = {
    n = G.UIT.C,
    config = { align = "cl" },
    nodes = {
      {
        n = G.UIT.C,
        config = {
          ref_table = card,
          align = "cl",
          maxw = 1,
          padding = 0.1,
          r = 0.08,
          minw = 1,
          minh = (card.area and card.area.config.type == "joker") and 0 or 1,
          hover = true,
          shadow = true,
          colour = G.C.UI.BACKGROUND_INACTIVE,
          one_press = true,
          button = "mass_use_card",
          func = "can_mass_use",
        },
        nodes = {
          {
            n = G.UIT.T,
            config = {
              text = "MASS USE",
              colour = G.C.UI.TEXT_LIGHT,
              scale = 0.35,
              shadow = true,
            },
          },
          { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
        },
      },
    },
  }
  local t = {
    n = G.UIT.ROOT,
    config = { padding = 0, colour = G.C.CLEAR },
    nodes = {
      {
        n = G.UIT.C,
        config = { padding = 0.15, align = "cl" },
        nodes = {
          { n = G.UIT.R, config = { align = "cl" }, nodes = {
            mass_use,
          } },
        },
      },
    },
  }
  return t
end

--- From https://github.com/nh6574/JokerDisplay/blob/b0ac120b2c64ac509a74c42b0fa78a3c2e12ee20/JokerDisplay.lua

-- ---Returns what Joker the current card (i.e. Blueprint or Brainstorm) is copying.
-- ---@param card table Blueprint or Brainstorm card to calculate copy.
-- ---@param _cycle_count integer? Counts how many times the function has recurred to prevent loops.
-- ---@return table|nil name Copied Joker
-- JokerDisplay.calculate_blueprint_copy = function(card, _cycle_count)
--   if _cycle_count and _cycle_count > #G.jokers.cards + 1 then
--     return nil
--   end
--   local other_joker = nil
--   if card.ability.name == "Blueprint" then
--     for i = 1, #G.jokers.cards do
--       if G.jokers.cards[i] == card then
--         other_joker = G.jokers.cards[i + 1]
--       end
--     end
--   elseif card.ability.name == "Brainstorm" then
--     other_joker = G.jokers.cards[1]
--   end
--   if other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat then
--     if other_joker.ability.name == "Blueprint" or other_joker.ability.name == "Brainstorm" then
--       return JokerDisplay.calculate_blueprint_copy(other_joker, _cycle_count and _cycle_count + 1 or 1)
--     else
--       return other_joker
--     end
--   end
--   return nil
-- end
