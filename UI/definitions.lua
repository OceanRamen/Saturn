Saturn.ui.opts.box = function()
  local contents = {
    {
      n = G.UIT.R,
      config = {
        align = "cm",
        padding = 0.2,
        colour = G.C.CLEAR,
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
              n = G.UIT.C,
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
                    text = "OPTIONS",
                    scale = 0.5,
                    colour = G.C.UI.TEXT_LIGHT,
                  },
                },
              },
            },
          },
        },
        {
          n = G.UIT.R,
          config = {
            align = "cm",
            padding = 0.05,
          },
          nodes = {
            {
              n = G.UIT.R,
              config = {
                align = "cri",
                padding = 0.05,
                colour = darken(G.C.BLUE, 0.25),
                r = 0.02,
              },
              nodes = {
                {
                  n = G.UIT.R,
                  config = {
                    align = "cm",
                    padding = 0.05,
                    colour = G.C.CLEAR,
                  },
                  nodes = {
                    create_custom_toggle({
                      label = "Enable Animation Skip",
                      ref_table = Saturn.config,
                      ref_value = "remove_animations",
                      active_colour = G.C.ORANGE,
                      inactaive_colour = darken(G.C.ORANGE, 0.75),
                    }),
                  },
                },
                {
                  n = G.UIT.R,
                  config = {
                    align = "cm",
                    padding = 0.05,
                    colour = G.C.CLEAR,
                  },
                  nodes = {
                    create_custom_toggle({
                      label = "Enable Dramatic Last Hand",
                      ref_table = Saturn.config,
                      ref_value = "enable_dramatic_final_hand",
                      active_colour = G.C.ORANGE,
                      inactaive_colour = darken(G.C.ORANGE, 0.75),
                      info = {
                        "Gives you more time to shuffle",
                        "Jokers pre Gold Card activation.",
                      },
                      info_colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                    }),
                  },
                },
              },
            },
          },
        },
        {
          n = G.UIT.R,
          config = {
            align = "cm",
            colour = G.C.CLEAR,
          },
          nodes = {
            {
              n = G.UIT.R,
              config = {
                align = "cm",
                padding = 0.05,
                colour = G.C.ORANGE,
                r = 0.02,
                minh = 0.75,
                minw = 4,
                button = "options",
              },
              nodes = {
                {
                  n = G.UIT.T,
                  config = {
                    text = "BACK",
                    scale = 0.5,
                    colour = G.C.UI.TEXT_LIGHT,
                  },
                },
              },
            },
          },
        },
      },
    },
  }
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
            n = G.UIT.C,
            config = {
              align = "cm",
              r = 0.2,
              padding = 0.2,
              colour = darken(G.C.BLUE, 0.5),
            },
            nodes = contents,
          },
        },
      },
    },
  }
end
