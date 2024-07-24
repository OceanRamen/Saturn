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
    { val = "compact_view", table = ref_table, label = "Compact View" },
  }
  local col_left = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
  local col_right = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
  for k, v in pairs(settings) do
    col_left.nodes[#col_left.nodes + 1] = {
      n = G.UIT.R,
      config = { align = "cl", padding = 0.1 },
      nodes = {
        {
          n = G.UIT.R,
          config = { align = "cl", padding = 0.075 },
          nodes = {
            {
              n = G.UIT.O,
              config = {
                object = DynaText({
                  string = v.label,
                  colours = { G.C.WHITE },
                  shadow = true,
                  scale = 0.5,
                }),
              },
            },
          },
        },
      },
    }
    col_right.nodes[#col_right.nodes + 1] = s_create_toggle({
      label = "",
      ref_table = v.table,
      ref_value = v.val,
      active_colour = G.C.BOOSTER,
    })
  end
  local args = {}
  local apply_func = "apply_settings"
  local back_func = "saturn_preferences"
  print(inspectDepth(ref_table))
  local t = {
    n = G.UIT.ROOT,
    config = {
      align = "cm",
      minw = G.ROOM.T.w * 5,
      minh = G.ROOM.T.h * 5,
      padding = 0.1,
      r = 0.1,
      colour = args.bg_colour or { G.C.GREY[1], G.C.GREY[2], G.C.GREY[3], 0.7 },
    },
    nodes = {
      {
        n = G.UIT.R,
        config = {
          align = "cm",
          minh = 1,
          r = 0.3,
          padding = 0.07,
          minw = 1,
          colour = args.outline_colour or G.C.JOKER_GREY,
          emboss = 0.1,
        },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "cm", minh = 1, r = 0.2, padding = 0.2, minw = 1, colour = args.colour or G.C.L_BLACK },
            nodes = {
              {
                n = G.UIT.R,
                config = { align = "cm", padding = args.padding or 0, minw = args.minw or 7 },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    padding = 0,
                    nodes = {
                      {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            colour = lighten(G.C.JOKER_GREY, 0.5),
                            r = 0.1,
                            padding = 0.05,
                            emboss = 0.05,
                        },
                        nodes = {
                          {
                            n = G.UIT.R,
                            config = {
                                align = "cm",
                                colour = G.C.BLACK,
                                r = 0.1,
                                padding = 0.2,
                            },
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
                              }
                            }
                          }
                        }
                      },
                    },
                  },
                }
              },
              {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    colour = lighten(G.C.JOKER_GREY, 0.5),
                    r = 0.1,
                    padding = 0.05,
                    emboss = 0.05,
                },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        colour = G.C.BLACK,
                        r = 0.1,
                        padding = 0.1,
                    },
                    nodes = {
                      {
                        n = G.UIT.R,
                        config = {
                          align = "cm",
                          colour = G.C.CLEAR,
                          r = 0.1,
                        },
                        nodes = {
                          col_left,
                          col_right,
                        }
                      },
                      {
                        n = G.UIT.R,
                        config = {
                          align = "bm",
                          minh = 1,
                          r = 0.2,
                          padding = 0.2,
                          colour = args.colour or G.C.CLEAR
                        },
                        nodes = {
                          not args.no_apply and {
                            n = G.UIT.R,
                            config = {
                                align = "cm",
                                colour = lighten(G.C.JOKER_GREY, 0.5),
                                r = 0.1,
                                padding = 0.06,
                                emboss = 0.05,
                            },
                            nodes = {
                              {
                                n = G.UIT.R,
                                config = {
                                  id = args.apply_id or "overlay_menu_apply_button",
                                  align = "cm",
                                  minw = args.minw or 7.8,
                                  button_delay = args.back_delay,
                                  padding = 0.13,
                                  r = 0.1,
                                  hover = true,
                                  colour = args.apply_colour or G.C.GREEN,
                                  button = apply_func,
                                  shadow = false,
                                  focus_args = { nav = "wide", button = "a", snap_to = args.snap_back },
                                },
                                nodes = {
                                  {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0, no_fill = true },
                                    nodes = {
                                      {
                                        n = G.UIT.T,
                                        config = {
                                          id = args.apply_id or nil,
                                          text = args.apply_label or "Apply",
                                          scale = 0.5,
                                          colour = G.C.UI.TEXT_LIGHT,
                                          shadow = true,
                                          func = not args.no_pip and "set_button_pip" or nil,
                                          focus_args = not args.no_pip and { button = args.apply_button or "a" } or nil,
                                        },
                                      },
                                    },
                                  },
                                },
                              },
                            }
                          },
                          not args.no_back and {
                            n = G.UIT.R,
                            config = {
                                align = "cm",
                                colour = lighten(G.C.JOKER_GREY, 0.5),
                                r = 0.1,
                                padding = 0.05,
                                emboss = 0.05,
                            },
                            nodes = {
                              {
                                n = G.UIT.R,
                                config = {
                                  id = args.back_id or "overlay_menu_back_button",
                                  align = "cm",
                                  minw = args.minw or 7.8,
                                  button_delay = args.back_delay,
                                  padding = 0.13,
                                  r = 0.1,
                                  hover = true,
                                  colour = args.back_colour or G.C.ORANGE,
                                  button = back_func,
                                  shadow = false,
                                  focus_args = { nav = "wide", button = "b", snap_to = args.snap_back },
                                },
                                nodes = {
                                  {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0, no_fill = true },
                                    nodes = {
                                      {
                                        n = G.UIT.T,
                                        config = {
                                          id = args.back_id or nil,
                                          text = args.back_label or localize("b_back"),
                                          scale = 0.5,
                                          colour = G.C.UI.TEXT_LIGHT,
                                          shadow = true,
                                          func = not args.no_pip and "set_button_pip" or nil,
                                          focus_args = not args.no_pip and { button = args.back_button or "b" } or nil,
                                        },
                                      },
                                    },
                                  },
                                },
                              },
                            }
                          }
                        },
                      },
                    }
                  }
                }
              }
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          { n = G.UIT.O, config = { id = "overlay_menu_infotip", object = Moveable() } },
        },
      }
    },
  }
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
