local lovely = require("lovely")
local nativefs = require("nativefs")
Saturn.UI = {}
Saturn.UI.COLOURS = {
  MAIN = G.C.SECONDARY_SET.Planet,
  MENUS = {
    BACKGROUND = G.C.L_BLACK,
    SUB_OPTION_BUTTON = G.C.BOOSTER,
    TAB_HEADING_BUTTON = G.C.SECONDARY_SET.Planet,
    CHECK_ACTIVE = G.C.BOOSTER,
  },
}

local G_FUNCS_options_ref = G.FUNCS.options
G.FUNCS.options = function(e)
  G_FUNCS_options_ref(e)
  nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
  G:set_language()
end

--- UI Helper function
function saturnUI_create_toggle(args)
  args = args or {}
  args.active_colour = args.active_colour or G.C.RED
  args.inactive_colour = args.inactive_colour or G.C.BLACK
  args.w = args.w or 3
  args.h = args.h or 0.5
  args.scale = args.scale or 1
  args.label = args.label or nil
  args.label_scale = args.label_scale or 0.4
  args.ref_table = args.ref_table or {}
  args.ref_value = args.ref_value or "test"

  local check = Sprite(0, 0, 0.5 * args.scale, 0.5 * args.scale, G.ASSET_ATLAS["icons"], { x = 1, y = 0 })
  check.states.drag.can = false
  check.states.visible = false

  local info = nil
  if args.info then
    info = {}
    for k, v in ipairs(args.info) do
      table.insert(info, {
        n = G.UIT.R,
        config = { align = "cm", minh = 0.05 },
        nodes = {
          { n = G.UIT.T, config = { text = v, scale = 0.25, colour = G.C.UI.TEXT_LIGHT } },
        },
      })
    end
    info = { n = G.UIT.R, config = { align = "cm", minh = 0.05 }, nodes = info }
  end

  local t = {
    n = args.col and G.UIT.C or G.UIT.R,
    config = { align = "cm", padding = 0.1, r = 0.1, colour = G.C.CLEAR, focus_args = { funnel_from = true } },
    nodes = {
      {
        n = G.UIT.C,
        config = { align = "cl", minw = 0.3 * args.w },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "cm", r = 0.1, colour = G.C.BLACK },
            nodes = {
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  r = 0.1,
                  padding = 0.03,
                  minw = 0.4 * args.scale,
                  minh = 0.4 * args.scale,
                  outline_colour = G.C.WHITE,
                  outline = 1.2 * args.scale,
                  line_emboss = 0.5 * args.scale,
                  ref_table = args,
                  colour = args.inactive_colour,
                  button = "toggle_button",
                  button_dist = 0.2,
                  hover = true,
                  toggle_callback = args.callback,
                  func = "toggle",
                  focus_args = { funnel_to = true },
                },
                nodes = {
                  { n = G.UIT.O, config = { object = check } },
                },
              },
            },
          },
        },
      },
    },
  }
  if args.label then
    ins = {
      n = G.UIT.C,
      config = { align = "cr", minw = args.w },
      nodes = {
        { n = G.UIT.T, config = { text = args.label, scale = args.label_scale, colour = G.C.UI.TEXT_LIGHT } },
        { n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
      },
    }
    table.insert(t.nodes, 1, ins)
  end
  if args.info then
    t = { n = args.col and G.UIT.C or G.UIT.R, config = { align = "cm" }, nodes = {
      t,
      info,
    } }
  end
  return t
end

--- UI Helper function
function saturnUI_create_tabs(args)
  args = args or {}
  args.colour = args.colour or G.C.RED
  args.tab_alignment = args.tab_alignment or "cm"
  args.opt_callback = args.opt_callback or nil
  args.scale = args.scale or 1
  args.tab_w = args.tab_w or 0
  args.tab_h = args.tab_h or 0
  args.text_scale = (args.text_scale or 0.5)
  args.tabs = args.tabs
    or {
      {
        label = "tab 1",
        chosen = true,
        func = nil,
        tab_definition_function = function()
          return {
            n = G.UIT.ROOT,
            config = { align = "cm" },
            nodes = {
              { n = G.UIT.T, config = { text = "A", scale = 1, colour = G.C.UI.TEXT_LIGHT } },
            },
          }
        end,
      },
      {
        label = "tab 2",
        chosen = false,
        tab_definition_function = function()
          return {
            n = G.UIT.ROOT,
            config = { align = "cm" },
            nodes = {
              { n = G.UIT.T, config = { text = "B", scale = 1, colour = G.C.UI.TEXT_LIGHT } },
            },
          }
        end,
      },
      {
        label = "tab 3",
        chosen = false,
        tab_definition_function = function()
          return {
            n = G.UIT.ROOT,
            config = { align = "cm" },
            nodes = {
              { n = G.UIT.T, config = { text = "C", scale = 1, colour = G.C.UI.TEXT_LIGHT } },
            },
          }
        end,
      },
    }

  local tab_buttons = {}

  for k, v in ipairs(args.tabs) do
    if v.chosen then
      args.current = { k = k, v = v }
    end
    tab_buttons[#tab_buttons + 1] = UIBox_button({
      id = "tab_but_" .. (v.label or ""),
      ref_table = v,
      button = "change_tab",
      colour = args.colour,
      label = { v.label },
      minh = 0.8 * args.scale,
      minw = 2.5 * args.scale,
      col = true,
      choice = true,
      scale = args.text_scale,
      chosen = v.chosen,
      func = v.func,
      focus_args = { type = "none" },
    })
  end

  local t = {
    n = G.UIT.R,
    config = { padding = 0.0, align = "cm", colour = G.C.CLEAR },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", colour = G.C.CLEAR },
        nodes = {
          (#args.tabs > 1 and not args.no_shoulders) and {
            n = G.UIT.C,
            config = {
              minw = 0.7,
              align = "cm",
              colour = G.C.CLEAR,
              func = "set_button_pip",
              focus_args = {
                button = "leftshoulder",
                type = "none",
                orientation = "cm",
                scale = 0.7,
                offset = { x = -0.1, y = 0 },
              },
            },
            nodes = {},
          } or nil,
          {
            n = G.UIT.C,
            config = {
              id = args.no_shoulders and "no_shoulders" or "tab_shoulders",
              ref_table = args,
              align = "cm",
              padding = 0.15,
              group = 1,
              collideable = true,
              focus_args = #args.tabs > 1
                  and { type = "tab", nav = "wide", snap_to = args.snap_to_nav, no_loop = args.no_loop }
                or nil,
            },
            nodes = tab_buttons,
          },
          (#args.tabs > 1 and not args.no_shoulders) and {
            n = G.UIT.C,
            config = {
              minw = 0.7,
              align = "cm",
              colour = G.C.CLEAR,
              func = "set_button_pip",
              focus_args = {
                button = "rightshoulder",
                type = "none",
                orientation = "cm",
                scale = 0.7,
                offset = { x = 0.1, y = 0 },
              },
            },
            nodes = {},
          } or nil,
        },
      },
      {
        n = G.UIT.R,
        config = {
          align = args.tab_alignment,
          padding = args.padding or 0.1,
          no_fill = true,
          minh = args.tab_h,
          minw = args.tab_w,
        },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              id = "tab_contents",
              object = UIBox({
                definition = args.current.v.tab_definition_function(args.current.v.tab_definition_function_args),
                config = { offset = { x = 0, y = 0 } },
              }),
            },
          },
        },
      },
    },
  }

  return t
end
--- UI Helper function
function saturnUI_create_UIBox_generic_options(args)
  args = args or {}
  local back_func = args.back_func or "exit_overlay_menu"
  local contents = args.contents or { n = G.UIT.T, config = { text = "EMPTY", colour = G.C.UI.RED, scale = 0.4 } }
  if args.infotip then
    G.E_MANAGER:add_event(Event({
      blocking = false,
      blockable = false,
      timer = "REAL",
      func = function()
        if G.OVERLAY_MENU then
          local _infotip_object = G.OVERLAY_MENU:get_UIE_by_ID("overlay_menu_infotip")
          if _infotip_object then
            _infotip_object.config.object:remove()
            _infotip_object.config.object = UIBox({
              definition = overlay_infotip(args.infotip),
              config = { offset = { x = 0, y = 0 }, align = "bm", parent = _infotip_object },
            })
          end
        end
        return true
      end,
    }))
  end

  return {
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
                config = { align = "cm", padding = args.padding or 0.2, minw = args.minw or 7 },
                nodes = contents,
              },
              not args.no_back and {
                n = G.UIT.R,
                config = {
                  id = args.back_id or "overlay_menu_back_button",
                  align = "cm",
                  minw = 2.5,
                  button_delay = args.back_delay,
                  padding = 0.1,
                  r = 0.1,
                  hover = true,
                  colour = args.back_colour or G.C.ORANGE,
                  button = back_func,
                  shadow = true,
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
              } or nil,
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
      },
    },
  }
end

--- title screen buttons ref function
local create_UIBox_main_menu_buttonsRef = create_UIBox_main_menu_buttons
function create_UIBox_main_menu_buttons()
  local text_scale = 0.45
  local saturnUI_preferences_button = UIBox_button({
    id = "saturnUI_prefs_button",
    minh = 1.35,
    minw = 1.85,
    col = true,
    button = "saturnUI_prefs_button",
    colour = G.C.SECONDARY_SET.Planet,
    label = { "Saturn" },
    scale = text_scale * 1.2,
  })
  local menu = create_UIBox_main_menu_buttonsRef()
  local spacer = G.F_QUIT_BUTTON and { n = G.UIT.C, config = { align = "cm", minw = 0.2 }, nodes = {} } or nil
  table.insert(menu.nodes[1].nodes[1].nodes[2].nodes, 2, spacer)
  table.insert(menu.nodes[1].nodes[1].nodes[2].nodes, 3, saturnUI_preferences_button)
  menu.nodes[1].nodes[1].config =
    { align = "cm", padding = 0.15, r = 0.1, emboss = 0.1, colour = G.C.L_BLACK, mid = true }
  return menu
end

--- StatTrack
function G.FUNCS.stattrack_options(e) -- StatTrack options button
  G.SETTINGS.paused = true
  left_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
  right_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
  local stattrack_settings = {
    { id = "MONEY_GEN", name = "Money Generating Jokers" },
    { id = "CARD_GEN", name = "Card Generating Jokers" },
    { id = "PLUS_CHIPS", name = "Plus Chips Jokers" },
    { id = "PLUS_MULT", name = "Plus Mult Jokers" },
    { id = "X_MULT", name = "X-Mult Jokers" },
    { id = "MISCELLANEOUS", name = "Misc. Jokers" },
  }
  for k, v in pairs(stattrack_settings) do
    right_settings.nodes[#right_settings.nodes + 1] = create_toggle({
      label = "",
      ref_table = Saturn.USER.SETTINGS.STATTRACK,
      ref_value = v.id,
      active_colour = Saturn.UI.COLOURS.MENUS.CHECK_ACTIVE,
      callback = function(x)
        nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
        G:set_language()
      end,
    })
    left_settings.nodes[#left_settings.nodes + 1] = {
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
                  string = v.name,
                  colours = { G.C.WHITE },
                  shadow = false,
                  scale = 0.5,
                }),
              },
            },
          },
        },
      },
    }
  end
  local t = create_UIBox_generic_options({
    back_func = "saturnUI_prefs_button",
    colour = Saturn.UI.COLOURS.MENUS.BACKGROUND,
    contents = {
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = "StatTrack Options",
                colours = { G.C.WHITE },
                shadow = true,
                scale = 0.4,
              }),
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = {
          align = "tm",
          padding = 0,
        },
        nodes = {
          left_settings,
          right_settings,
        },
      },
    },
  })
  G.FUNCS.overlay_menu({
    definition = t,
  })
end

--- DeckViewer+
function G.FUNCS.deckviewer_options(e)
  G.SETTINGS.paused = true
  left_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
  right_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
  local deckviewer_settings = {
    { feat = "HIDE_PLAYED", setting = "ENABLED", name = "Hide Played Cards" },
  }
  for k, v in pairs(deckviewer_settings) do
    right_settings.nodes[#right_settings.nodes + 1] = create_toggle({
      label = "",
      ref_table = Saturn.USER.SETTINGS.DECKVIEWER[v.feat],
      ref_value = v.setting,
      active_colour = Saturn.UI.COLOURS.MENUS.CHECK_ACTIVE,
      callback = function(x)
        nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
      end,
    })
    left_settings.nodes[#left_settings.nodes + 1] = {
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
                  string = v.name,
                  colours = { G.C.WHITE },
                  shadow = false,
                  scale = 0.5,
                }),
              },
            },
          },
        },
      },
    }
  end
  local t = create_UIBox_generic_options({
    back_func = "saturnUI_prefs_button",
    colour = Saturn.UI.COLOURS.MENUS.BACKGROUND,
    contents = {
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = "DeckViewer+ Options",
                colours = { G.C.WHITE },
                shadow = true,
                scale = 0.4,
              }),
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = {
          align = "tm",
          padding = 0,
        },
        nodes = {
          left_settings,
          right_settings,
        },
      },
    },
  })
  G.FUNCS.overlay_menu({
    definition = t,
  })
end

--- GENQOL
function G.FUNCS.genqol_options(e)
  G.SETTINGS.paused = true
  left_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
  right_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
  local genqol_settings = {
    { feat = "RETRY_BUTTON", setting = "ENABLED", name = "Show \"Retry\" Button" },
    { feat = "TIMER", setting = "ENABLED", name = "Show Run Timer"},
  }
  for k, v in pairs(genqol_settings) do
    right_settings.nodes[#right_settings.nodes + 1] = create_toggle({
      label = "",
      ref_table = Saturn.USER.SETTINGS.GENQOL[v.feat],
      ref_value = v.setting,
      active_colour = Saturn.UI.COLOURS.MENUS.CHECK_ACTIVE,
      callback = function(x)
        nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
      end,
    })
    left_settings.nodes[#left_settings.nodes + 1] = {
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
                  string = v.name,
                  colours = { G.C.WHITE },
                  shadow = false,
                  scale = 0.5,
                }),
              },
            },
          },
        },
      },
    }
  end
  local t = create_UIBox_generic_options({
    back_func = "saturnUI_prefs_button",
    colour = Saturn.UI.COLOURS.MENUS.BACKGROUND,
    contents = {
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = "GenQOL Options",
                colours = { G.C.WHITE },
                shadow = true,
                scale = 0.4,
              }),
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = {
          align = "tm",
          padding = 0,
        },
        nodes = {
          left_settings,
          right_settings,
        },
      },
    },
  })
  G.FUNCS.overlay_menu({
    definition = t,
  })
end

--- TODO: timer settings page

--- Saturn Settings Menu
function G.FUNCS.saturnUI_prefs_button(e) -- Saturn settings menu button
  G.SETTINGS.paused = true
  local _tabs = {}
  _tabs[#_tabs + 1] = {
    label = "Features",
    chosen = true,
    tab_definition_function = G.UIDEF.saturnUI_settings_tab,
    tab_definition_function_args = "Features",
  }
  _tabs[#_tabs + 1] = {
    label = "Aesthetics",
    tab_definition_function = G.UIDEF.saturnUI_settings_tab,
    tab_definition_function_args = "Aesthetics",
  }
  local t = saturnUI_create_UIBox_generic_options({
    back_func = "options",
    contents = {
      saturnUI_create_tabs({
        tabs = _tabs,
        tab_h = 7.05,
        tab_alignment = "tm",
        snap_to_nav = true,
        colour = Saturn.UI.COLOURS.MENUS.TAB_HEADING_BUTTON,
      }),
    },
  })
  G.FUNCS.overlay_menu({
    definition = t,
  })
end

function G.UIDEF.saturnUI_settings_tab(_tab) -- Saturn settings menu tabs
  if _tab == "Features" then
    local t = {
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, r = 0.3 },
        nodes = {
          {
            n = G.UIT.R,
            config = {
              align = "cm",
              padding = 0.05,
              colour = G.C.L_BLACK,
              r = 0.3,
            },
            nodes = {
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  {
                    n = G.UIT.O,
                    config = {
                      object = DynaText({
                        string = "Enable StatTracker",
                        colours = { G.C.WHITE },
                        shadow = false,
                        scale = 0.5,
                      }),
                    },
                  },
                },
              },
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  saturnUI_create_toggle({
                    ref_table = Saturn.USER.SETTINGS.STATTRACK,
                    ref_value = "ENABLED",
                    active_colour = Saturn.UI.COLOURS.MENUS.CHECK_ACTIVE,
                    callback = function(x)
                      nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
                      G:set_language()
                    end,
                    col = true,
                  }),
                },
              },
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  UIBox_button({
                    label = { "Config" },
                    button = "stattrack_options",
                    minw = 2,
                    minh = 0.75,
                    scale = 0.5,
                    colour = Saturn.UI.COLOURS.MENUS.SUB_OPTION_BUTTON,
                    col = true,
                  }),
                },
              },
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, r = 0.3 },
        nodes = {
          {
            n = G.UIT.R,
            config = {
              align = "cm",
              padding = 0.05,
              colour = G.C.L_BLACK,
              r = 0.3,
            },
            nodes = {
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  {
                    n = G.UIT.O,
                    config = {
                      object = DynaText({
                        string = "Enable DeckViewer+",
                        colours = { G.C.WHITE },
                        shadow = false,
                        scale = 0.5,
                      }),
                    },
                  },
                },
              },
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  saturnUI_create_toggle({
                    ref_table = Saturn.USER.SETTINGS.DECKVIEWER,
                    ref_value = "ENABLED",
                    active_colour = Saturn.UI.COLOURS.MENUS.CHECK_ACTIVE,
                    callback = function(x)
                      nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
                      G:set_language()
                    end,
                    col = true,
                  }),
                },
              },
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  UIBox_button({
                    label = { "Config" },
                    button = "deckviewer_options",
                    minw = 2,
                    minh = 0.75,
                    scale = 0.5,
                    colour = Saturn.UI.COLOURS.MENUS.SUB_OPTION_BUTTON,
                    col = true,
                  }),
                },
              },
            },
          },
        },
      },
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, r = 0.3 },
        nodes = {
          {
            n = G.UIT.R,
            config = {
              align = "cm",
              padding = 0.05,
              colour = G.C.L_BLACK,
              r = 0.3,
            },
            nodes = {
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  {
                    n = G.UIT.O,
                    config = {
                      object = DynaText({
                        string = "Enable GEN-QOL",
                        colours = { G.C.WHITE },
                        shadow = false,
                        scale = 0.5,
                      }),
                    },
                  },
                },
              },
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  saturnUI_create_toggle({
                    ref_table = Saturn.USER.SETTINGS.GENQOL,
                    ref_value = "ENABLED",
                    active_colour = Saturn.UI.COLOURS.MENUS.CHECK_ACTIVE,
                    callback = function(x)
                      nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
                    end,
                    col = true,
                  }),
                },
              },
              {
                n = G.UIT.C,
                config = {
                  align = "cm",
                  padding = 0.1,
                },
                nodes = {
                  UIBox_button({
                    label = { "Config" },
                    button = "genqol_options",
                    minw = 2,
                    minh = 0.75,
                    scale = 0.5,
                    colour = Saturn.UI.COLOURS.MENUS.SUB_OPTION_BUTTON,
                    col = true,
                  }),
                },
              },
            },
          },
        },
      },
    }
    return {
      n = G.UIT.ROOT,
      config = { align = "cm", padding = 0.05, colour = G.C.CLEAR },
      nodes = t,
    }
  end
  if _tab == "Aesthetics" then
    return {
      n = G.UIT.ROOT,
      config = { align = "cm", padding = 0.05, colour = G.C.CLEAR },
      nodes = {},
    }
  end

  return {
    n = G.UIT.ROOT,
    config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, minh = 5, minw = 5 },
    nodes = {},
  }
end
