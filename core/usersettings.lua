local lovely = require("lovely")
local nativefs = require("nativefs")

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

function G.FUNCS.saturnUI_prefs_button(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu({
    definition = saturnUI_create_UIBox_preferences_button(),
  })
end

function saturnUI_create_UIBox_preferences_button()
  local _tabs = {}
  _tabs[#_tabs + 1] = {
    label = "Preferences",
    chosen = true,
    tab_definition_function = G.UIDEF.saturnUI_settings_tab,
    tab_definition_function_args = "Preferences",
  }
  local t = saturnUI_create_UIBox_generic_options({
    back_func = "options",
    contents = {
      saturnUI_create_tabs({ tabs = _tabs, tab_h = 7.05, tab_alignment = "tm", snap_to_nav = true }),
    },
  })
  return t
end

function G.UIDEF.saturnUI_settings_tab(_tab)
  if _tab == "Preferences" then
    return {
      n = G.UIT.ROOT,
      config = { align = "cm", padding = 0.05, colour = G.C.CLEAR },
      nodes = {
        create_toggle({
          label = "StatTrack Jokers",
          ref_table = Saturn.USER.SETTINGS,
          ref_value = "STATTRACK",
          callback = function(_set_toggle)
            nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
            G:set_language()
          end,
        }),
        create_toggle({
          label = "Deck View: Hide Played Cards",
          ref_table = Saturn.USER.SETTINGS,
          ref_value = "HIDE_PLAYED",
          callback = function(_set_toggle)
            nativefs.write(Saturn.MOD.PATH .. "user/settings.lua", STR_PACK(Saturn.USER.SETTINGS))
          end,
        }),
      },
    }
  end

  return {
    n = G.UIT.ROOT,
    config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, minh = 5, minw = 5 },
    nodes = {},
  }
end
