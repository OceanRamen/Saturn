local lovely = require("lovely")
local nativefs = require("nativefs")

G.FUNCS.apply_settings = function(e)
  S.SETTINGS = deepcopy(S.TEMP_SETTINGS)
  S:write_settings('settings')
  G:set_language()
end

G.FUNCS.saturn_features_button = function(e)
  S.TEMP_SETTINGS = deepcopy(S.SETTINGS)
  return G.FUNCS.saturn_tabs()
end

function create_UIBox_runTimer()
  return {
    n = G.UIT.ROOT,
    config = { align = "cm", padding = 0.03, colour = G.C.UI.TRANSPARENT_DARK, r = 0.1 },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.05, colour = G.C.DYN_UI.MAIN, r = 0.1 },
        nodes = {
          {
            n = G.UIT.R,
            config = { align = "cm", colour = G.C.DYN_UI.BOSS_DARK, r = 0.1, minw = 1.5, padding = 0.08 },
            nodes = {
              { n = G.UIT.R, config = { align = "cm", minh = 0.0 }, nodes = {} },
              {
                n = G.UIT.R,
                config = {
                  id = "speedrun_timer_right",
                  align = "cm",
                  padding = 0.05,
                  minw = 1.45,
                  emboss = 0.05,
                  r = 0.1,
                },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                      {
                        n = G.UIT.O,
                        config = {
                          object = DynaText({
                            string = { { ref_table = S.TIMER, ref_value = "disp" } },
                            colours = { G.C.WHITE },
                            shadow = true,
                            bump = true,
                            scale = 0.6,
                            pop_in = 0.5,
                            maxw = 5,
                            silent = true,
                          }),
                          id = "timer",
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  }
end

function s_create_toggle(args)
    args = args or {}
    args.active_colour = args.active_colour or G.C.RED
    args.inactive_colour = args.inactive_colour or G.C.BLACK
    args.w = args.w or 1.5
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
      config = { align = "cr", padding = 0.1, r = 0.1, colour = G.C.CLEAR},
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
            outline = 1.15 * args.scale,
            -- line_emboss = 0.5 * args.scale,
            ref_table = args,
            colour = args.inactive_colour,
            button = "toggle_button",
            button_dist = 0.2,
            hover = true,
            toggle_callback = args.callback,
            func = "toggle",
          },
          nodes = {
            { n = G.UIT.O, config = { object = check } },
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

function s_create_buttons(args)
  args = args or {
    label = 'Label',
    toggle_ref = nil,
    ref_value = nil,
    button_ref = nil,
    button_label = 'Button',
    remove_enable = true,
  }
  
  local t = {
    n = G.UIT.R,
    config = { align = "cm", padding = 0.05, colour = G.C.CLEAR },
    nodes = {},
  }
  
  for k, v in pairs(args) do
    t.nodes[#t.nodes+1] = {
      n = G.UIT.R,
      config = {
          align = "cm",
          colour = G.C.CLEAR,
          r = 0.1,
          padding = 0,
      },
      nodes = {
        {
          n = G.UIT.R,
          config = { align = "cm", padding = 0.05, },
          nodes = {
            {
              n = G.UIT.C,
              config = { align = "cl", padding = 0.1, minw=3.6 },
              nodes = {
                {
                  n = G.UIT.O,
                  config = {
                    object = DynaText({ string = (not v.remove_enable and "Enable " .. v.label) or v.label, colours = { G.C.WHITE }, shadow = true, scale = 0.4 }),
                  },
                }
              }
            },
            {
              n = G.UIT.C,
              config = { align = "cr", padding = 0.1, minw=1},
              nodes = {
                ((v.button_ref == nil) and {
                  n = G.UIT.C,
                  config = {
                    align = "cm",
                    r = 0.1,
                    padding = 0,
                    minw = 1.8,
                    colour = G.C.CLEAR,
                  },
                })
                or nil,
                v.toggle_ref and 
                s_create_toggle({
                  scale = 0.9,
                  ref_table = v.toggle_ref,
                  ref_value = v.ref_value,
                  active_colour = G.C.SECONDARY_SET.Planet,
                  callback = function(x) end,
                  col = true,
                })
                or {
                  n = G.UIT.C,
                  config = {
                    align = "cm",
                    r = 0.1,
                    padding = 0.03,
                    minw = 0.45,
                    minh = 0.4,
                    colour = G.C.CLEAR,
                  },
                },
                ((v.toggle_ref and v.button_ref) and {
                  n = G.UIT.C,
                  config = {
                    align = "cm",
                    r = 0.1,
                    padding = 0,
                    minw = 0.1,
                    minh = 0.4,
                    colour = G.C.CLEAR,
                  },
                })
                or nil,
                v.button_ref and
                {
                  n = G.UIT.C,
                  config = {
                    id = "overlay_menu_config_button"..v.label,
                    align = "cm",
                    minw = 1.8,
                    button_delay = args.back_delay,
                    minh = 0.75,
                    padding = 0.13,
                    r = 0.1,
                    hover = true,
                    colour = G.C.SECONDARY_SET.Planet,
                    button = v.button_ref,
                    shadow = false,
                    outline_colour = lighten(G.C.JOKER_GREY, 0.5),
                    outline = 1.15,
                  },
                  nodes = {
                    {
                      n = G.UIT.C,
                      config = { align = "cm", padding = 0, no_fill = true },
                      nodes = {
                        {
                          n = G.UIT.T,
                          config = {
                            text = v.button_label or 'Config',
                            scale = 0.4,
                            colour = G.C.UI.TEXT_LIGHT,
                            shadow = true,
                            func = "set_button_pip",
                          },
                        },
                      },
                    },
                  },
                }
              }
            }
          },
        }
      }
    }
  end
  return {t}
end

function s_create_tabs(args)
  local tab_buttons = {}

  for i = 1, #args do
    tab_buttons[#tab_buttons+1] = args[i].button_ref and {
      n = G.UIT.C,
      config = {
        align = "cm",
        colour = G.C.CLEAR,
        r = 0.1,
        padding = 0,
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
            id = args[i].tab_id or "overlay_menu_tab_button"..i,
            align = "cm",
            colour = G.C.BLACK,
            minw = args[i].minw or 2,
            hover = true,
            button_delay = args[i].back_delay,
            button = 's_change_tab',
            tab_func = args[i].tab_func,
            shadow = false,
            r = 0.1,
            padding = 0.2,
            outline_colour = lighten(G.C.JOKER_GREY, 0.5),
            outline = 1.15,
          },
          nodes = {
            {
              n = G.UIT.R,
              config = { align = "cm", padding = 0, no_fill = true },
              nodes = {
                {
                  n = G.UIT.T,
                  config = {
                    id = (args[i].tab_id and args[i].tab_id..i) or nil,
                    text = args[i].label,
                    scale = 0.4,
                    colour = G.C.WHITE,
                    shadow = true,
                    func = nil,
                  },
                }
              },
            },
          }
        }
      }
    }
    or { 
      n = G.UIT.C,
      config = {
          align = "cm",
          colour = G.C.CLEAR,
          r = 0.1,
          padding = 0,
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
              align = "cm",
              colour = G.C.BLACK,
              r = 0.1,
              padding = 0.2,
              minw = 2,
              outline_colour = lighten(G.C.JOKER_GREY, 0.5),
              outline = 1.15,
          },
          nodes = {
            {
              n = G.UIT.O,
              config = {
                object = DynaText({
                  string = args[i].label or "Saturn",
                  colours = { G.C.WHITE },
                  shadow = true,
                  scale = 0.4,
                }),
              },
            }
          }
        }
      }
    }
    if i ~= #args then
      tab_buttons[#tab_buttons+1] = { 
        n = G.UIT.C,
        config = {
            align = "cm",
            colour = G.C.CLEAR,
            minw = 0.4,
            r = 0.1,
            padding = 0,
        },
      }
    end
  end
  return tab_buttons
end

function s_create_card_display(args)
  args = args or {}
  args._type = args._type or 'Joker'
  args.col = args.col or 5
  args.row = args.row or 2
  args.specific_center = args.specific_center or nil
  local deck_tables = {}
  local cards_per_page = args.col*args.row
  local current_center = 0

  S.card_display = {}

  for i = 1, args.row do
    S.card_display[i] = CardArea(
      G.ROOM.T.x + 0.2*G.ROOM.T.w/args.row,G.ROOM.T.h,
      args.col*G.CARD_W,
      0.95*G.CARD_H, 
      {card_limit = args.col, type = 'title', highlight_limit = 0, collection = false})
    table.insert(deck_tables, 
    {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
      {n=G.UIT.O, config={colour = G.C.CLEAR, object = S.card_display[i]}}
    }}
    )
  end

  if args.specific_center then
    local center = args.specific_center
    local card = Card(S.card_display[1].T.x + S.card_display[1].T.w/args.row, S.card_display[1].T.y, G.CARD_W, G.CARD_H, nil, center)
    if args._type == 'Joker' then
      card.sticker = get_joker_win_sticker(center)
    end
    S.card_display[1]:emplace(card)
    return {
      {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.CLEAR, emboss = 0.05}, nodes=deck_tables},
    }
  end

  for i = 1, args.row do
    for j = 1, args.col do
      current_center = current_center + 1
      local center = G.P_CENTER_POOLS[args._type][current_center + (S.current_page*(args.row*args.col))]
      if not center then break end
      local card = Card(S.card_display[i].T.x + S.card_display[i].T.w/args.row, S.card_display[i].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card.s_stats = true
      if args._type == 'Joker' then
        card.sticker = get_joker_win_sticker(center)
      end
      S.card_display[i]:emplace(card)
    end
  end
  
  local t = {
    {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.CLEAR, emboss = 0.05}, nodes=deck_tables}, 
    {n=G.UIT.R, config={align = "cm",}, nodes = s_create_page_cycle({_type = args._type, colour = G.C.SECONDARY_SET.Planet, _type = args._type, row = args.row, col = args.col})}
  }
  return t
end

function s_create_deck_display(args)
  args = args or {}
  args._type = args._type or 'Back'
  args.col = args.col or 5
  args.row = args.row or 2
  args.specific_center = args.specific_center or nil
  local deck_tables = {}
  local cards_per_page = args.col*args.row
  local current_center = 0
  local deck_limit = 20

  S.card_display = {}

  for i = 1, args.row do
    local row = {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={}}
    for j = 1, args.col do
      S.card_display[#S.card_display+1] = CardArea(
        G.ROOM.T.x + 0.2*G.ROOM.T.w/args.row,G.ROOM.T.h,
        G.CARD_W,
        0.95*G.CARD_H, 
        {card_limit = deck_limit, type = 'deck', highlight_limit = 0, collection = false})
      table.insert(row.nodes, 
      {n=G.UIT.C, config={align = "cm", padding = 0, no_fill = true}, nodes={
        {n=G.UIT.O, config={colour = G.C.CLEAR, object = S.card_display[#S.card_display]}}
      }}
      )
    end
    table.insert(deck_tables, row)
  end

  if args.specific_center then
    local center = args.specific_center
    for i = 1, deck_limit do
      local card = Card(S.card_display[1].T.x + S.card_display[1].T.w/args.row, S.card_display[1].T.y, G.CARD_W, G.CARD_H, nil, center)
      card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["centers"], center.pos)
      card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
      card.s_deck = true
      S.card_display[1]:emplace(card)
    end
    return {
      {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.CLEAR, emboss = 0.05}, nodes=deck_tables},
    }
  end

  for i = 1, #S.card_display do
    current_center = current_center + 1
    local center = G.P_CENTER_POOLS[args._type][current_center + (S.current_page*(args.row*args.col))]
    if not center then break end
    for j = 1, deck_limit do
      local card = Card(S.card_display[i].T.x + S.card_display[i].T.w/args.row, S.card_display[i].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["centers"], G.P_CENTER_POOLS.Back[current_center + (S.current_page*(args.row*args.col))].pos)
      card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
      card.s_stats = true
      card.s_deck = true
      S.card_display[i]:emplace(card)
    end
  end
  
  local t = {
    {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.CLEAR, emboss = 0.05}, nodes=deck_tables}, 
    (cards_per_page < #G.P_CENTER_POOLS[args._type]) and {n=G.UIT.R, config={align = "cm",}, nodes = s_create_page_cycle({_type = args._type, colour = G.C.SECONDARY_SET.Planet, row = args.row, col = args.col, button_func = 'deckview_page_cycle'})}
    or nil
  }
  return t
end

local card_click_ref = Card.click
function Card:click() 
  if self.s_stats and self.config.center.discovered then
    if self.ability.set == 'Back' then
      G.FUNCS.deck_stats(self)
    else
      G.FUNCS.card_stats(self)
    end
  end
  card_click_ref(self)
end

function Card:generate_deck_ui()
  local loc_args = nil
  local effect_config = G.P_CENTERS[self.config.center.key].config
  local name_to_check = self.ability.name
  if name_to_check == 'Blue Deck' then loc_args = {effect_config.hands}
  elseif name_to_check == 'Red Deck' then loc_args = {effect_config.discards}
  elseif name_to_check == 'Yellow Deck' then loc_args = {effect_config.dollars}
  elseif name_to_check == 'Green Deck' then loc_args = {effect_config.extra_hand_bonus, effect_config.extra_discard_bonus}
  elseif name_to_check == 'Black Deck' then loc_args = {effect_config.joker_slot, -effect_config.hands}
  elseif name_to_check == 'Magic Deck' then loc_args = {localize{type = 'name_text', key = 'v_crystal_ball', set = 'Voucher'}, localize{type = 'name_text', key = 'c_fool', set = 'Tarot'}}
  elseif name_to_check == 'Nebula Deck' then loc_args = {localize{type = 'name_text', key = 'v_telescope', set = 'Voucher'}, -1}
  elseif name_to_check == 'Ghost Deck' then
  elseif name_to_check == 'Abandoned Deck' then 
  elseif name_to_check == 'Checkered Deck' then
  elseif name_to_check == 'Zodiac Deck' then loc_args = {localize{type = 'name_text', key = 'v_tarot_merchant', set = 'Voucher'}, 
                      localize{type = 'name_text', key = 'v_planet_merchant', set = 'Voucher'},
                      localize{type = 'name_text', key = 'v_overstock_norm', set = 'Voucher'}}
  elseif name_to_check == 'Painted Deck' then loc_args = {effect_config.hand_size,effect_config.joker_slot}
  elseif name_to_check == 'Anaglyph Deck' then loc_args = {localize{type = 'name_text', key = 'tag_double', set = 'Tag'}}
  elseif name_to_check == 'Plasma Deck' then loc_args = {effect_config.ante_scaling}
  elseif name_to_check == 'Erratic Deck' then
  end
  local desc_nodes = {}
  localize{type = 'descriptions', key = self.config.center.key, set = 'Back', nodes = desc_nodes, vars = loc_args}
  self.config.h_popup = {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR}, nodes={
    {n=G.UIT.C, config={align = "cm", func = 'show_infotip',object = Moveable(),ref_table = nil}, nodes={
      {n=G.UIT.R, config={padding = 0.05, r = 0.12, colour = lighten(G.C.JOKER_GREY, 0.5), emboss = 0.07}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.1, r = 0.1, colour = adjust_alpha(G.C.BLACK, 0.8),}, nodes={
          name_from_rows(localize{type = 'name', set = self.ability.set, key = self.config.center.key, nodes = {}}),
          desc_from_rows(desc_nodes),
        }}
      }}
    }},
  }}
  local offset_above = self.T.y > G.CARD_H*0.8
  self.config.h_popup_config = {
    major = self,
    parent = self,
    xy_bond = 'Strong',
    r_bond = 'Weak',
    wh_bond = 'Weak',
    offset = {
        x = 0,
        y = (offset_above and -0.13) or 0.1
    },  
    type = (offset_above and 'tm') or 'bm'
  }
end

local hover_ref = Card.hover
function Card:hover()
  if self.s_deck and self.config.center.discovered then
    if self.ability.set == 'Back' then
      self:generate_deck_ui()
      Node.hover(self)
      return
    end
  end
  hover_ref(self)
end

function s_create_page_cycle(args)
  args = args or {}
  args._type = args._type or 'Joker'
  args.col = args.col or 5
  args.row = args.row or 2
  args.button_func = args.button_func or 'statview_page_cycle'

  S.current_page_text = (S.current_page+1)

  local t = {
    {
      n = G.UIT.C,
      config = {
        align = 'cm',
        colour = G.C.CLEAR,
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
            id = 'page_left',
            button = args.button_func,
            ref_table = {
              _type = args._type,
              col = args.col,
              row = args.row,
              current = S.current_page,
              dir = -1,
            },
            shadown = false,
            minw = 0.66,
            minh = 0.66,
            hover = true,
            align = "cm",
            colour = args.colour or G.C.BLACK,
            r = 0.1,
            padding = 0.2,
            outline_colour = lighten(G.C.JOKER_GREY, 0.5),
            outline = 1.15,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                text = '<',
                scale = 0.4,
                colour = G.C.UI.TEXT_LIGHT,
                shadow = true,
              },
            },
          }
        }
      }
    },
    { 
      n = G.UIT.C,
      config = {
          align = "cm",
          colour = G.C.CLEAR,
          minw = 0.2,
          r = 0.1,
          padding = 0,
      },
    },
    {
      n = G.UIT.C,
      config = {
        align = 'cm',
        colour = G.C.CLEAR,
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
              align = "cm",
              colour = args.colour or G.C.BLACK,
              minh = 0.66,
              r = 0.1,
              padding = 0.2,
              minw = 2,
              outline_colour = lighten(G.C.JOKER_GREY, 0.5),
              outline = 1.15,
          },
          nodes = {
            { 
              n = G.UIT.C,
              config = {
                  align = "cm",
                  colour = G.C.CLEAR,
                  minw = 0.5,
                  r = 0.1,
                  padding = 0,
              },
              nodes = {
                {
                  n = G.UIT.T,
                  config = {
                    id = 'current_page_num',
                    ref_table = S,
                    ref_value = 'current_page_text',
                    scale = 0.4,
                    colour = G.C.UI.TEXT_LIGHT,
                    shadow = true,
                  },
                },
              },
            },
            { 
              n = G.UIT.C,
              config = {
                  align = "cm",
                  colour = G.C.CLEAR,
                  minw = 0.2,
                  r = 0.1,
                  padding = 0,
              },
              nodes = {
                {
                  n = G.UIT.T,
                  config = {
                    text = '/',
                    scale = 0.4,
                    minw = 0.5,
                    colour = G.C.UI.TEXT_LIGHT,
                    shadow = true,
                  },
                },
              },
            },
            { 
              n = G.UIT.C,
              config = {
                  align = "cm",
                  colour = G.C.CLEAR,
                  minw = 0.5,
                  r = 0.1,
                  padding = 0,
              },
              nodes = {
                {
                  n = G.UIT.T,
                  config = {
                    text = tostring(math.ceil((#G.P_CENTER_POOLS[args._type]/(args.row*args.col)))),
                    scale = 0.4,
                    colour = G.C.UI.TEXT_LIGHT,
                    shadow = true,
                  },
                },
              }
            }
          }
        }
      }
    },
    { 
      n = G.UIT.C,
      config = {
          align = "cm",
          colour = G.C.CLEAR,
          minw = 0.2,
          r = 0.1,
          padding = 0,
      },
    },
    {
      n = G.UIT.C,
      config = {
        align = 'cm',
        colour = G.C.CLEAR,
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
            id = 'page_right',
            button = args.button_func,
            ref_table = {
              _type = args._type,
              col = args.col,
              row = args.row,
              current = S.current_page,
              dir = 1,
            },
            shadown = false,
            minw = 0.66,
            minh = 0.66,
            hover = true,
            align = "cm",
            colour = args.colour or G.C.BLACK,
            r = 0.1,
            padding = 0.2,
            outline_colour = lighten(G.C.JOKER_GREY, 0.5),
            outline = 1.15,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                text = '>',
                scale = 0.4,
                colour = G.C.UI.TEXT_LIGHT,
                shadow = true,
              },
            },
          }
        }
      }
    }
  }
  return t
end


function s_create_general_stats_page(args)

  --   "c_cards_sold",
  --   "c_hands_played",
  --   "c_jokers_sold",
  --   "c_vouchers_bought",
  --   "c_planetarium_used",
  --   "c_wins",
  --   "c_shop_rerolls",
  --   "c_cards_discarded",
  --   "c_tarots_bought",
  --   "c_cards_played",
  --   "c_shop_dollars_spent",
  --   "c_face_cards_played",
  --   "c_planets_bought",
  --   "c_single_hand_round_streak",
  --   "c_tarot_reading_used",
  --   "c_rounds",
  --   "c_playing_cards_bought",
  --   "c_dollars_earned",
  --   "c_losses",
  --   "c_round_interest_cap_streak",

  local career_stats = G.PROFILES[G.SETTINGS.profile].career_stats

  return nil
end

function s_create_stats_page(args)
  if not args.ability then return end

  local t = {
    {
      n = G.UIT.R,
      config = {
        align = 'cm',
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
            align = 'cm',
            padding = 0.1,
          },
          nodes = (args.ability.set ~= 'Back' and s_create_card_display({_type = args.ability.set, col = 1, row = 1, specific_center = args.config.center})) or s_create_deck_display({_type = args.ability.set, col = 1, row = 1, specific_center = args.config.center})
        },
        (args.ability.set == 'Joker' and s_create_joker_stats_page(args)) or 
        (args.ability.set ~= 'Back' and s_create_consumable_stats_page(args)) or
        nil
      }
    }
  }
  return t
end

function s_create_joker_stats_page(args)
  if not (args.ability and args.ability.set == 'Joker') then return end

  local t = {
    n = G.UIT.R,
    config = {
      align = 'cm',
      padding = 0.1,
    },
    nodes = s_create_joker_wl(args)
  }
  return t
end

function s_create_consumable_stats_page(args)
  if not (args.ability and args.ability.set ~= 'Joker') then return end

  local t = {
    n = G.UIT.R,
    config = {
      align = 'cm',
      padding = 0.1,
    },
    nodes = s_create_consumable_usage(args)
  }
  return t
end

function s_create_consumable_usage(args)
  local used = G.PROFILES[G.SETTINGS.profile]['consumeable_usage'][args.config.center.key] and G.PROFILES[G.SETTINGS.profile]['consumeable_usage'][args.config.center.key].count or 0
  local total_used = 0

  for k, v in pairs(G.P_CENTERS) do
    if v.set == args.ability.set then
      total_used = total_used + ((G.PROFILES[G.SETTINGS.profile]['consumeable_usage'][k] and G.PROFILES[G.SETTINGS.profile]['consumeable_usage'][k].count) or 0)
    end
  end

  local t = {
    {
      n = G.UIT.R,
      config = {
        align = 'cm',
        padding = 0.2,
        r = 0.1,
        colour = G.C.L_BLACK,
        outline_colour = lighten(G.C.JOKER_GREY, 0.5),
        outline = 1.15,
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
            align = 'cm',
            padding = 0.02,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                align = 'cm',
                text = 'Usage',
                scale = 0.4,
                colour = G.C.UI.TEXT_LIGHT,
                shadow = true,
              },
            }
          }
        },
        {
          n = G.UIT.R,
          config = {
            align = 'cm',
            padding = 0.1,
            r = 0.1,
            colour = G.C.BLACK,
            outline_colour = lighten(G.C.JOKER_GREY, 0.5),
            outline = 1.15,
          },
          nodes = {
            { 
              n = G.UIT.R,
              config = {
                align = 'cm',
                padding = 0.05,
              },
              nodes = {
                {
                  n = G.UIT.T,
                  config = {
                    align = 'cm',
                    text = 'Total Used: '..used,
                    scale = 0.4,
                    colour = G.C.UI.TEXT_LIGHT,
                    shadow = true,
                  },
                }
              }
            },
            {
              n = G.UIT.R,
              config = {
                align = 'cm',
                padding = 0.05,
              },
              nodes = {
                {
                  n = G.UIT.T,
                  config = {
                    align = 'cm',
                    text = round2(((used/total_used)*100), 2)..'% of Total '..args.ability.set..'s used',
                    scale = 0.4,
                    colour = G.C.UI.TEXT_LIGHT,
                    shadow = true,
                  },
                }
              }
            },
          }
        }
      }
    }
  }
  return t
end

-- function for rounding because apparently lua doesnt
-- have a built in function
function round2(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function s_create_joker_wl(args)
  if not (args.ability and args.ability.set == 'Joker') then return end
  local wins = {}
  local losses = {}
  local win_total = 0
  local loss_total = 0
  if not G.PROFILES[G.SETTINGS.profile]['joker_usage'][args.config.center.key] then 
    return {
      {
        n = G.UIT.R,
        config = {
          align = 'cm',
          padding = 0.2,
          r = 0.1,
          colour = G.C.L_BLACK,
          outline_colour = lighten(G.C.JOKER_GREY, 0.5),
          outline = 1.15,
        },
        nodes = {
          {
            n = G.UIT.R,
            config = {
              align = 'cm',
              padding = 0.02,
            },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  align = 'cm',
                  text = 'Wins/Losses',
                  scale = 0.4,
                  colour = G.C.UI.TEXT_LIGHT,
                  shadow = true,
                },
              }
            }
          },
          {
            n = G.UIT.R,
            config = {
              align = 'cm',
              padding = 0.02,
            },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  align = 'cm',
                  text = '0 / 0',
                  scale = 0.4,
                  colour = G.C.UI.TEXT_LIGHT,
                  shadow = true,
                },
              }
            }
          },
          {
            n = G.UIT.R,
            config = {
              align = 'cm',
              padding = 0.1,
              r = 0.1,
              colour = G.C.BLACK,
              outline_colour = lighten(G.C.JOKER_GREY, 0.5),
              outline = 1.15,
            },
            nodes = {
              {
                n = G.UIT.R,
                config = {
                  align = 'cm',
                  padding = 0.05,
                },
                nodes = s_create_stake_stats({{0,0,0,0,0,0,0,0,},{0,0,0,0,0,0,0,0,},})
              },
            }
          }
        }
      }
    }
  end

  for i = 1, 8 do
    wins[i] = G.PROFILES[G.SETTINGS.profile]['joker_usage'][args.config.center.key].wins[i] or 0
    win_total = win_total + (G.PROFILES[G.SETTINGS.profile]['joker_usage'][args.config.center.key].wins[i] or 0)
  end

  for i = 1, 8 do
    losses[i] = G.PROFILES[G.SETTINGS.profile]['joker_usage'][args.config.center.key].losses[i] or 0
    loss_total = loss_total + (G.PROFILES[G.SETTINGS.profile]['joker_usage'][args.config.center.key].losses[i] or 0)
  end

  local t = {
    {
      n = G.UIT.R,
      config = {
        align = 'cm',
        padding = 0.2,
        r = 0.1,
        colour = G.C.L_BLACK,
        outline_colour = lighten(G.C.JOKER_GREY, 0.5),
        outline = 1.15,
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
            align = 'cm',
            padding = 0.02,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                align = 'cm',
                text = 'Wins/Losses',
                scale = 0.4,
                colour = G.C.UI.TEXT_LIGHT,
                shadow = true,
              },
            }
          }
        },
        {
          n = G.UIT.R,
          config = {
            align = 'cm',
            padding = 0.02,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                align = 'cm',
                text = win_total..'/'..loss_total,
                scale = 0.4,
                colour = G.C.UI.TEXT_LIGHT,
                shadow = true,
              },
            }
          }
        },
        {
          n = G.UIT.R,
          config = {
            align = 'cm',
            padding = 0.1,
            r = 0.1,
            colour = G.C.BLACK,
            outline_colour = lighten(G.C.JOKER_GREY, 0.5),
            outline = 1.15,
          },
          nodes = {
            {
              n = G.UIT.R,
              config = {
                align = 'cm',
                padding = 0.05,
              },
              nodes = s_create_stake_stats({wins, losses})
            },
          }
        }
      }
    }
  }
  return t
end

function s_create_stake_stats(args)
  args = args or {}
  local wins = args[1] or {}
  local losses = args[2] or {}
  local rows = args[3] or 4
  local cols = args[4] or 2

  local stakes = {
    Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['chips'], {x = 0,y = 0}),
    Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['chips'], {x = 1,y = 0}),
    Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['chips'], {x = 2,y = 0}),
    Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['chips'], {x = 4,y = 0}),
    Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['chips'], {x = 3,y = 0}),
    Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['chips'], {x = 0,y = 1}),
    Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['chips'], {x = 1,y = 1}),
    Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS['chips'], {x = 2,y = 1}),
  }

  local t = {}

  for i = 1, rows do
    local row = {n = G.UIT.R, config = {align = 'cm', padding = 0.05, minw = 2}, nodes = {}}
    for j = 1, cols do
      row.nodes[#row.nodes+1] = {
        n = G.UIT.C,
        config = {
          align = 'cl',
          padding = 0,
          minw = 1.7,
        },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = stakes[j + ((i - 1)*cols)],
              align = 'cl',
            }
          },
          {
            n = G.UIT.T,
            config = {
              align = 'cl',
              padding = 0.05,
              text = wins[j + ((i - 1)*cols)]..'/'..losses[j + ((i - 1)*cols)],
              scale = 0.4,
              colour = G.C.UI.TEXT_LIGHT,
              shadow = true,
            },
          }
        }
      }
    end
    t[#t+1] = row
  end
  return t
end

function s_create_options(args)
  args = args or {}
  
  local apply_func = args.apply_func or "apply_settings"
  local back_func = args.back_func or "saturn_modules"
  args.nodes = args.nodes or { n = G.UIT.T, config = { text = "EMPTY", colour = G.C.UI.RED, scale = 0.4 } }
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
            config = { align = "cm", minh = 1, r = 0.2, padding = 0.25, minw = 1, colour = args.colour or G.C.L_BLACK },
            nodes = {
              {
                n = G.UIT.R,
                config = { align = "cm", padding = args.padding or 0, minw = args.minw or 2},
                nodes = {
                  {
                    n = G.UIT.R,
                    config = {
                      align = "cm" , 
                      id = 'tab_box',
                    },
                    padding = 0,
                    nodes = args.title and {
                      {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            colour = G.C.BLACK,
                            r = 0.1,
                            padding = 0.2,
                            outline_colour = lighten(G.C.JOKER_GREY, 0.5),
                            outline = 1.15,
                        },
                        nodes = {
                          {
                            n = G.UIT.O,
                            config = {
                              object = DynaText({
                                string = args.title or "Saturn",
                                colours = { G.C.WHITE },
                                shadow = true,
                                scale = 0.4,
                              }),
                            },
                          }
                        }
                      }
                    }
                    or args.tabs,
                  }
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
                          id = 'node_box',
                          colour = G.C.CLEAR,
                          r = 0.1,
                          minw = 7.3,
                          minh = 7.3,
                          padding = 0.2,
                        },
                        nodes = args.nodes or nil
                      },
                      {
                        n = G.UIT.R,
                        config = {
                          align = "bm",
                          minh = 0.1,
                          r = 0.2,
                          padding = 0.08,
                          colour = args.colour or G.C.CLEAR,
                        },
                        nodes = {
                          args.apply_func and {
                            n = G.UIT.R,
                            config = {
                              id = args.apply_id or "overlay_menu_apply_button",
                              align = "bm",
                              minw = args.minw or 3.5,
                              minh = args.minh or 0.6,
                              button_delay = args.back_delay,
                              padding = 0.1,
                              r = 0.1,
                              hover = true,
                              colour = args.apply_colour or lighten(G.C.GREEN, 0.03),
                              button = apply_func,
                              shadow = false,
                              outline_colour = lighten(G.C.JOKER_GREY, 0.5),
                              outline = 1.15,
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
                                      scale = 0.4,
                                      colour = G.C.UI.TEXT_LIGHT,
                                      shadow = true,
                                    },
                                  },
                                },
                              },
                            },
                          },
                          args.apply_func and {
                            n = G.UIT.R,
                            config = {
                              align = "bm",
                              colour = G.C.CLEAR,
                              minh = 0.035,
                              r = 0.1,
                            },
                          },
                          {
                            n = G.UIT.R,
                            config = {
                              id = args.back_id or "overlay_menu_back_button",
                              align = "bm",
                              minw = args.minw or 3.5,
                              minh = args.minh or 0.6,
                              button_delay = args.back_delay,
                              padding = 0.1,
                              r = 0.1,
                              hover = true,
                              colour = args.back_colour or G.C.RED,
                              button = back_func,
                              shadow = false,
                              outline_colour = lighten(G.C.JOKER_GREY, 0.5),
                              outline = 1.15,
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
                                      scale = 0.4,
                                      colour = G.C.UI.TEXT_LIGHT,
                                      shadow = true,
                                    },
                                  },
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  }
end