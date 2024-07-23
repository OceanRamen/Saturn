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

  if selected_card.ability.set == "Planet" then
    --- Mass_use planet cards
  end

  if selected_card.ability.set == "Tarot" and (selected_card.ability.name == "Temperance" or selected_card.ability.name == "Hermit") then
    --- Mass_use temperance + hermit
  end

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
  for _, card in ipairs(to_consume) do
    local e = { config = { ref_table = card } }
    -- G.FUNCS.use_card(e)
    if card.area then
      card.area:remove_card(card)
    end

    card:use_consumeable(area)
    draw_card(G.hand, G.play, 1, 'up', true, card, nil, mute)
    for i = 1, #G.jokers.cards do
      G.jokers.cards[i]:calculate_joker({ using_consumeable = true, consumeable = card })
    end
    -- card:remove()
    card:start_dissolve()
  end
end

G.FUNCS.can_mass_use = function(e)
  local card = e.config.ref_table
  if e.config.ref_table:can_use_consumeable() then
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
