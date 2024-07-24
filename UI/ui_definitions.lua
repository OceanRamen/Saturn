local lovely = require("lovely")
local nativefs = require("nativefs")

local create_UIBox_main_menu_buttons_ref = create_UIBox_main_menu_buttons
function create_UIBox_main_menu_buttons()
  local text_scale = 0.45
  local saturn_preferences_button = UIBox_button({
    id = "saturn_preferences_button",
    minh = 1.35,
    minw = 1.85,
    col = true,
    button = "saturn_preferences_button",
    colour = G.C.SECONDARY_SET.Planet,
    label = { "Saturn" },
    scale = text_scale * 1.2,
  })
  local menu = create_UIBox_main_menu_buttons_ref()
  local spacer = G.F_QUIT_BUTTON and { n = G.UIT.C, config = { align = "cm", minw = 0.2 }, nodes = {} } or nil
  table.insert(menu.nodes[1].nodes[1].nodes[2].nodes, 2, spacer)
  table.insert(menu.nodes[1].nodes[1].nodes[2].nodes, 3, saturn_preferences_button)
  menu.nodes[1].nodes[1].config =
    { align = "cm", padding = 0.15, r = 0.1, emboss = 0.1, colour = G.C.L_BLACK, mid = true }
  return menu
end

local function saturn_get_settings_tab(_tab)
  if _tab == "Features" then
    local t = {
      s_create_feature_options({
        name = "StatTracker",
        toggle_ref = S.TEMP_SETTINGS.modules.stattrack,
        config_button = "config_stattracker",
      }),
      s_create_feature_options({
        name = "DeckViewer+",
        toggle_ref = S.TEMP_SETTINGS.modules.deckviewer_plus,
        config_button = "config_deckviewer",
      }),
      s_create_feature_options({
        name = "Challenger+",
        toggle_ref = S.TEMP_SETTINGS.modules.challenger_plus,
        config_button = "config_challenger",
      }),
    }
    return {
      n = G.UIT.ROOT,
      config = { align = "cm", padding = 0.05, colour = G.C.CLEAR },
      nodes = t,
    }
  end

  return {
    n = G.UIT.ROOT,
    config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, minh = 5, minw = 5 },
    nodes = {},
  }
end

function G.FUNCS.saturn_preferences(e)
  G.SETTINGS.paused = true

  local _tabs = {}
  _tabs[#_tabs + 1] = {
    label = "Features",
    chosen = true,
    tab_definition_function = saturn_get_settings_tab,
    tab_definition_function_args = "Features",
  }

  local t = s_create_generic_options({
    apply_func = "apply_settings",
    back_func = "options",
    contents = {
      s_create_tabs({
        tabs = _tabs,
        tab_h = 7.05,
        tab_alignment = "tm",
        snap_to_nav = true,
        colour = G.C.BOOSTER,
      }),
    },
  })
  G.FUNCS.overlay_menu({
    definition = t,
  })
end

function G.FUNCS.config_stattracker(e)
  G.SETTINGS.paused = true
  local ref_table = S.TEMP_SETTINGS.modules.stattrack.features.joker_tracking.groups
  local settings = {
    { val = "money_generators", table = ref_table, label = "Money Generators" },
    { val = "card_generators", table = ref_table, label = "Card Generators" },
    { val = "chips_plus", table = ref_table, label = "+Chip Jokers" },
    { val = "mult_plus", table = ref_table, label = "+Mult Jokers" },
    { val = "mult_mult", table = ref_table, label = "xMult Jokers" },
    { val = "miscellaneous", table = ref_table, label = "Miscellaneous" },
  }
  print(inspectDepth(ref_table))
  local t = s_create_generic_options({
    apply_func = "apply_settings",
    back_func = "saturn_preferences",
    contents = {
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = "Joker Tracking Options",
                colours = { G.C.WHITE },
                shadow = true,
                scale = 0.4,
              }),
            },
          },
        },
      },
      s_create_config_options(settings, ref_table),
    },
  })
  G.FUNCS.overlay_menu({
    definition = t,
  })
end

function G.FUNCS.config_deckviewer(e)
  G.SETTINGS.paused = true
  local ref_table = S.TEMP_SETTINGS.modules.deckviewer_plus.features
  local settings = {
    { val = "hide_played_cards", table = ref_table, label = "Hide Played Cards" },
  }
  local t = s_create_generic_options({
    apply_func = "apply_settings",
    back_func = "saturn_preferences",
    contents = {
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = "Deckviewer+ Options",
                colours = { G.C.WHITE },
                shadow = true,
                scale = 0.4,
              }),
            },
          },
        },
      },
      s_create_config_options(settings, ref_table),
    },
  })
  G.FUNCS.overlay_menu({
    definition = t,
  })
end

function G.FUNCS.config_challenger(e)
  G.SETTINGS.paused = true
  local ref_table = S.TEMP_SETTINGS.modules.challenger_plus.features
  local settings = {
    { val = "retry_button", table = ref_table, label = "Retry Button" },
  }
  local t = s_create_generic_options({
    apply_func = "apply_settings",
    back_func = "saturn_preferences",
    contents = {
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = "Challenger+ Options",
                colours = { G.C.WHITE },
                shadow = true,
                scale = 0.4,
              }),
            },
          },
        },
      },
      s_create_config_options(settings),
    },
  })
  G.FUNCS.overlay_menu({
    definition = t,
  })
end


function G.FUNCS.use_consumeables(e)
  G.FUNCS:exit_overlay_menu()
  if G.consumeables and G.consumeables.cards then
    consume_cards(G.consumeables.cards)
  end
end

function consume_cards(cards)
  local area = G.STATE
  local to_consume = {}

  -- First pass: Collect cards to be consumed
  for k, v in pairs(cards) do
    if v:can_use_consumeable() then
      table.insert(to_consume, v)
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
