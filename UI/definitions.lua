Saturn.ui.opts.box = function()
  local function wrapText(text, maxLineLength)
    local wrappedText = {}
    local line = ""
    for word in text:gmatch("%S+") do
      if #line + #word + 1 > maxLineLength then
        table.insert(wrappedText, line)
        line = word
      else
        if #line > 0 then
          line = line .. " " .. word
        else
          line = word
        end
      end
    end
    if #line > 0 then
      table.insert(wrappedText, line)
    end
    return wrappedText
  end
  local options = {
    -- stat_track = {
    --   title = "Stats Tracking",
    --   desc = "Track various statistics in game.",
    --   opts = {
    --     {
    --       id = "track_stats",
    --       default = false,
    --       name = "Track Stats",
    --       master = true,
    --     },
    --     {
    --       id = "track_money_gen",
    --       default = false,
    --       name = "Track Money Generation",
    --       master = true,
    --     },
    --     {
    --       id = "track_value_gen",
    --       default = false,
    --       name = "Track Value Generation",
    --       master = true,
    --     },
    --     {
    --       id = "track_card_gen",
    --       default = false,
    --       name = "Track Card Generation",
    --       master = true,
    --     },
    --     {
    --       id = "track_cards_add",
    --       default = false,
    --       name = "Track Cards Added",
    --       master = true,
    --     },
    --     {
    --       id = "track_cards_rem",
    --       default = false,
    --       name = "Track Cards Removed",
    --       master = true,
    --     },
    --     {
    --       id = "track_jokers_gen",
    --       default = false,
    --       name = "Track Jokers Generated",
    --       master = true,
    --     },
    --     {
    --       id = "track_jokers_rem",
    --       default = false,
    --       name = "Track Jokers Removed",
    --       master = true,
    --     },
    --     {
    --       id = "track_retriggers",
    --       default = false,
    --       name = "Track Retriggers",
    --       master = true,
    --     },
    --     {
    --       id = "track_hands_upgraded",
    --       default = false,
    --       name = "Track Hands Upgraded",
    --       master = true,
    --     },
    --     {
    --       id = "track_turned_gold",
    --       default = false,
    --       name = "Track Turned Gold",
    --       master = true,
    --     },
    --     {
    --       id = "track_plus_hands",
    --       default = false,
    --       name = "Track Plus Hands",
    --       master = true,
    --     },
    --   },
    -- },
    rem_anim = {
      title = "Remove Animations",
      desc = "Remove game animations to speed-up gameplay drastically.",
      opts = {
        {
          id = "remove_animations",
          default = false,
          name = "Remove animations",
          master = true,
        },
        {
          id = "enable_dramatic_final_hand",
          default = false,
          name = "Enable dramatic final hand",
          desc = "Gives you time to shuffle Jokers during the final hand",
          master = true,
        },
      },
    },
    stacking = {
      title = "Consumeable Stacking",
      desc = "Stack duplicate consumeables to reduce lag and clutter.",
      opts = {
        {
          id = "enable_stacking",
          default = false,
          name = "Enable Stacking",
          master = true,
        },
      },
    },
  }

  local function createSettingsPage()
    local function createOptionToggle(option)
      local text = ""
      if option.desc then
        text = wrapText(option.desc, 30)
      end
      return {
        n = G.UIT.R,
        config = {
          align = "cm",
          padding = 0.01,
          colour = G.C.CLEAR,
        },
        nodes = {
          create_custom_toggle({
            label = option.name,
            ref_table = Saturn.config,
            ref_value = option.id,
            active_colour = G.C.ORANGE,
            inactive_colour = darken(G.C.ORANGE, 0.75),
            info = (text ~= "" and text or nil),
            info_colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
          }),
        },
      }
    end

    local function createOptionSection(section)
      local nodes = {}
      for _, opt in ipairs(section.opts) do
        if opt.master then
          table.insert(nodes, createOptionToggle(opt))
        end
      end

      return {
        n = G.UIT.R,
        config = {
          align = "cm",
          padding = 0.05,
          colour = darken(G.C.BLUE, 0.25),
          r = 0.02,
        },
        nodes = nodes,
      }
    end

    local function createDynamicLayout(contents, maxWidth)
      local layout = {}
      local currentRow = {}
      local currentWidth = 0

      for _, section in ipairs(contents) do
        local sectionWidth = section.config.minw or 1 -- Assume a default width if not specified
        if currentWidth + sectionWidth > maxWidth then
          table.insert(layout, {
            n = G.UIT.R,
            config = {
              align = "cm",
              padding = 0.05,
              colour = G.C.CLEAR,
              r = 0.02,
            },
            nodes = currentRow,
          })
          currentRow = {}
          currentWidth = 0
        end
        table.insert(currentRow, section)
        currentWidth = currentWidth + sectionWidth
      end

      if #currentRow > 0 then
        table.insert(layout, {
          n = G.UIT.R,
          config = {
            align = "cm",
            padding = 0.05,
            colour = G.C.CLEAR,
            r = 0.02,
          },
          nodes = currentRow,
        })
      end

      return layout
    end

    local contents = {}
    for _, section in pairs(options) do
      local wrappedDesc = wrapText(section.desc, 30) -- Adjust maxLineLength as needed
      local descNodes = {}
      for _, line in ipairs(wrappedDesc) do
        table.insert(descNodes, {
          n = G.UIT.R,
          config = {
            align = "cm",
            colour = G.C.CLEAR,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                text = line,
                scale = 0.3,
                colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
              },
            },
          },
        })
      end

      table.insert(contents, {
        n = G.UIT.C,
        config = {
          align = "tmi",
          padding = 0.05,
          colour = darken(G.C.BLUE, 0.5),
          r = 0.02,
        },
        nodes = {
          {
            n = G.UIT.R,
            config = {
              align = "cm",
              padding = 0.05,
              colour = G.C.CLEAR,
              r = 0.02,
            },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  text = section.title,
                  scale = 0.4,
                  colour = G.C.UI.TEXT_LIGHT,
                },
              },
            },
          },
          {
            n = G.UIT.R,
            config = {
              align = "cm",
              padding = 0.05,
              colour = G.C.CLEAR,
              r = 0.02,
            },
            nodes = descNodes,
          },
          createOptionSection(section),
        },
      })
    end

    local maxWidth = 2 -- Define the maximum width for the layout
    local dynamicLayout = createDynamicLayout(contents, maxWidth)

    return {
      n = G.UIT.ROOT,
      config = {
        align = "cm",
        minw = G.ROOM.T.w * 5,
        minh = G.ROOM.T.h * 5,
        padding = 0.1,
        r = 0.1,
        colour = { G.C.BLACK[1], G.C.BLACK[2], G.C.BLACK[3], 0.7 },
      },
      nodes = {
        {
          n = G.UIT.R,
          config = {
            align = "cm",
            r = 0.2,
            padding = 0.05,
            colour = darken(G.C.BLUE, 0.25),
          },
          nodes = {
            {
              n = G.UIT.R,
              config = {
                align = "cm",
                r = 0.2,
                padding = 0.25,
              },
              nodes = {
                {
                  n = G.UIT.O,
                  config = {
                    object = DynaText({
                      string = {
                        "Saturn Config",
                      },
                      colours = { G.C.ORANGE },
                      shadow = true,
                      float = true,
                      rotate = true,
                      bump = true,
                      silent = true,
                      pop_in = 0.1,
                      scale = 1,
                    }),
                  },
                },
              },
            },
            {
              n = G.UIT.R,
              config = {
                align = "cm",
                r = 0.2,
                padding = 0.2,
                colour = darken(G.C.BLUE, 0.6),
              },
              nodes = dynamicLayout,
            },
            {
              n = G.UIT.R,
              config = {
                align = "cm",
                r = 0.2,
                padding = 0.2,
                colour = darken(G.C.BLUE, 0.5),
              },
              nodes = {
                UIBox_button({
                  button = "options",
                  label = { "Back" },
                  colour = G.C.BLUE,
                }),
              },
            },
          },
        },
      },
    }
  end
  return createSettingsPage()
end
