G.FUNCS.canSplitOne = function(e)
  local card = e.config.ref_table
  if
      card.highlighted
      and card:canSplit()
      and canPerformActions(nil)
      and (card.stack:getSize() > 1)
      and not Saturn.is_splitting
      and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.GREEN
    e.config.button = "split_one"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.canSplitHalf = function(e)
  local card = e.config.ref_table
  if
      card.highlighted
      and card:canSplit()
      and canPerformActions(nil)
      and (card.stack:getSize() > 1)
      and not Saturn.is_splitting
      and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.GREEN
    e.config.button = "split_half"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.canMerge = function(e)
  local card = e.config.ref_table
  if
      card.highlighted
      and card:canStack()
      and canPerformActions(nil)
      and card:canMerge()
      and not Saturn.is_splitting
      and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.DARK_EDITION
    e.config.button = "merge_card"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.canMergeAll = function(e)
  local card = e.config.ref_table
  if
      card.highlighted
      and card:canStack()
      and canPerformActions(nil)
      and card:canMerge()
      and not Saturn.is_splitting
      and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.DARK_EDITION
    e.config.button = "merge_all"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.canMassUse = function(e)
  local card = e.config.ref_table
  if
      canPerformActions(nil)
      and card:canMassUse()
      and (inTable(CAN_USE_SET, card.ability.set) or inTable(
        CAN_USE_KEY,
        card.config.center_key
      ))
      and (card.stack:getSize() > 1)
      and card.highlighted
      and not Saturn.is_splitting
      and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.RED
    e.config.button = "mass_use"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.canMassSell = function(e)
  local card = e.config.ref_table
  if
      card.highlighted
      and canPerformActions(nil)
      and (card.stack:getSize())
      and not Saturn.is_splitting
      and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.GREEN
    e.config.button = "mass_sell"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end


G.FUNCS.splitOne = function(e)
  local card = e.config.ref_table
  card:split(1)
end

G.FUNCS.splitHalf = function(e)
  local card = e.config.ref_table
  local size = card.stack:getSize()
  card:split(math.floor(size / 2))
end

G.FUNCS.merge = function(e)
  local card = e.config.ref_table
  card:tryMerge()
end

G.FUNCS.mergeAll = function(e)
  local card = e.config.ref_table
  card:tryMergeAll()
end

G.FUNCS.massUse = function(e)
  local card = e.config.ref_table
  card:massUse()
end

G.FUNCS.massSell = function(e)
  local card = e.config.ref_table
  card:massSell()
end


G.FUNCS.disableStackUI = function(e)
  local card = e.config.ref_table
  if card.stack:getSize() > 1 then
    e.states.visible = true
  else
    e.states.visible = false
  end
end

function G.UIDEF.counterStackSize(card)
  local set_colour_map = {
    ["Planet"] = G.C.MONEY,
    ["Tarot"] = lighten(G.C.SECONDARY_SET.Planet, 0.3),
    ["Spectral"] = lighten(G.C.GREEN, 0.3),
  }
  local colour = set_colour_map[card.ability.set] or G.C.GREEN
  if card.children.stack_ui then return end
  if not card:canStack() then return end
  local definition = {
    n = G.UIT.ROOT,
    config = {
      align = "cm",
      colour = G.C.CLEAR,
      shadow = true,
      func = "disableStackUI",
      ref_table = card,
    },
    nodes = {
      {
        n = G.UIT.R,
        config = {
          align = "cm",
          minh = 0.3,
          maxh = 1,
          minw = 0.5,
          maxw = 1.5,
          padding = 0.1,
          r = 0.02,
          colour = HEX("22222266"),
          res = 0.5,
        },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = DynaText({
                string = {
                  {
                    prefix = "+",
                    ref_table = card.stack,
                    ref_value = "count"
                  },
                },
                colours = { colour },
                shadow = true,
                silent = true,
                bump = true,
                pop_in = 0.2,
                scale = 0.4,
              }),
            },
          },
        },
      },
    },
  }
  local config = {
    align = "cm",
    bond = "Strong",
    parent = card,
    offset = {
      x = -0.7,
      y = 1.2,
    }
  }
  local states = {
    collide = { can = false },
    drag = { can = true },
  }
  return UIBox({ definition = definition, config = config, states = states })
end

function G.UIDEF.buttonMassUseSell(card)
  local mass_use_button = {
    n = G.UIT.C,
    config = { align = "cl" },
    nodes = {
      {
        n = G.UIT.C,
        config = {
          ref_table = card,
          align = "cl",
          maxw = 1.25,
          padding = 0.1,
          r = 0.08,
          minw = 1.25,
          minh = (card.area and card.area.config.type == "joker") and 0 or 1,
          hover = true,
          shadow = true,
          colour = G.C.UI.BACKGROUND_INACTIVE,
          one_press = true,
          button = "mass_use",
          func = "can_mass_use",
        },
        nodes = {
          {
            n = G.UIT.C,
            config = {
              align = "cm",
            },
            nodes = {
              {
                n = G.UIT.R,
                config = {
                  align = "cm",
                  maxw = 1.25,
                },
                nodes = {
                  {
                    n = G.UIT.T,
                    config = {
                      text = "USE ALL",
                      colour = G.C.UI.TEXT_LIGHT,
                      scale = 0.3,
                      shadow = true,
                    },
                  },
                },
              },
              {
                n = G.UIT.R,
                config = {
                  align = "cr",
                  maxw = 1.25,
                },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = {
                      align = "cm",
                      minw = 0.3,
                    },
                    nodes = {
                      {
                        n = G.UIT.T,
                        config = {
                          text = "(",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          ref_table = card.stack,
                          ref_value = "count",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          text = ")",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
        },
      },
    },
  }
  local mass_sell_button = {
    n = G.UIT.C,
    config = { align = "cl" },
    nodes = {
      {
        n = G.UIT.C,
        config = {
          ref_table = card,
          align = "cl",
          padding = 0.1,
          r = 0.08,
          minw = 1.25,
          hover = true,
          shadow = true,
          colour = G.C.UI.BACKGROUND_INACTIVE,
          one_press = true,
          button = "mass_sell",
          func = "can_mass_sell",
        },
        nodes = {
          {
            n = G.UIT.C,
            config = {
              align = "cm",
            },
            nodes = {
              {
                n = G.UIT.R,
                config = {
                  align = "cm",
                  maxw = 1.25,
                },
                nodes = {
                  {
                    n = G.UIT.T,
                    config = {
                      text = "SELL ALL",
                      colour = G.C.UI.TEXT_LIGHT,
                      scale = 0.3,
                      shadow = true,
                    },
                  },
                },
              },
              {
                n = G.UIT.R,
                config = {
                  align = "cr",
                  maxw = 1.25,
                },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = {
                      align = "cm",
                      minw = 0.3,
                    },
                    nodes = {
                      {
                        n = G.UIT.T,
                        config = {
                          text = "(",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          text = localize("$"),
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          ref_table = card.ability,
                          ref_value = "stack_cost_label",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          text = ")",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                    },
                  },
                },
              },
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
          {
            n = G.UIT.R,
            config = { align = "cl" },
            nodes = {
              mass_sell_button,
            },
          },
          {
            n = G.UIT.R,
            config = { align = "cl" },
            nodes = {
              mass_use_button,
            },
          },
        },
      },
    },
  }
  return t
end

function G.UIDEF.buttonMerge(card)
  local merge = {
    n = G.UIT.C,
    config = {
      align = "cm",
      ref_table = card,
      minh = 0.3,
      maxh = 0.6,
      minw = 0.3,
      maxw = 4,
      r = 0.01,
      padding = 0.1,
      colour = G.C.DARK_EDITION,
      shadow = true,
      button = "merge",
      func = "canMerge",
    },
    nodes = {
      {
        n = G.UIT.T,
        config = {
          text = "MERGE",
          scale = 0.3,
          colour = G.C.UI.TEXT_LIGHT,
        },
      },
    },
  }
  return merge
end

function G.UIDEF.buttonMergeAll(card)
  local merge = {
    n = G.UIT.C,
    config = {
      align = "cm",
      ref_table = card,
      minh = 0.3,
      maxh = 0.6,
      minw = 0.3,
      maxw = 4,
      r = 0.01,
      padding = 0.1,
      colour = G.C.DARK_EDITION,
      shadow = true,
      button = "mergeAll",
      func = "canMergeAll",
    },
    nodes = {
      {
        n = G.UIT.T,
        config = {
          text = "MERGE ALL",
          scale = 0.3,
          colour = G.C.UI.TEXT_LIGHT,
        },
      },
    },
  }
  return merge
end

function G.UIDEF.buttonSplitOne(card)
  local t = {
    n = G.UIT.C,
    config = {
      align = "cm",
      ref_table = card,
      minh = 0.3,
      maxh = 0.6,
      minw = 0.3,
      maxw = 4,
      r = 0.01,
      padding = 0.1,
      colour = G.C.DARK_EDITION,
      shadow = true,
      button = "splitOne",
      func = "canSplitOne",
    },
    nodes = {
      {
        n = G.UIT.T,
        config = {
          text = "SPLIT ONE",
          scale = 0.3,
          colour = G.C.UI.TEXT_LIGHT,
        },
      },
    },
  }
  return t
end

function G.UIDEF.buttonSplitHalf(card)
  local t = {
    n = G.UIT.C,
    config = {
      align = "cm",
      ref_table = card,
      minh = 0.3,
      maxh = 0.6,
      minw = 0.3,
      maxw = 4,
      r = 0.01,
      padding = 0.1,
      colour = G.C.DARK_EDITION,
      shadow = true,
      button = "splitHalf",
      func = "canSplitHalf",
    },
    nodes = {
      {
        n = G.UIT.T,
        config = {
          text = "SPLIT HALF",
          scale = 0.3,
          colour = G.C.UI.TEXT_LIGHT,
        },
      },
    },
  }
  return t
end

-- Parent UI node for split, merge buttons
function G.UIDEF.stackActionContainer(card)
  local stackActions = UIBox({
    definition = {
      n = G.UIT.ROOT,
      config = { padding = 0 },
      nodes = {
        n = G.UIT.R,
        config = {
          padding = 0.5,
          colour = G.C.UI.TRANSPARENT_DARK,
        },
        nodes = {
          card:canSplit() and {
            G.UIDEF.buttonSplitOne(card)
          } or {},
          card:canSplit() and {
            G.UIDEF.buttonSplitHalf(card)
          } or {},
          card:canMerge() and {
            G.UIDEF.buttonMerge(card)
          } or {},
          card:canMergeAll() and {
            G.UIDEF.buttonMergeAll(card)
          } or {},
        },
      }
    },
    config = {
      align = "bmi",
      offset = {
        x = 0,
        y = 0,
      },
      bond = "Strong",
      parent = card,
    }
  })
  return stackActions
end
