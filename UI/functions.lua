Saturn.ui.curr_opt = "opt_main"
Saturn.ui.prev_opt = nil

local exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function()
  exit_overlay_menu_ref()
  Saturn.writeConfig()
end

Saturn.ui.opts.func = function(e)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu({
    definition = Saturn.ui.opts.box(),
    config = {
      offset = {
        x = 0,
        y = 0,
      },
    },
  })
end

G.FUNCS.saturn_config = function(e)
  Saturn.ui.opts.func(e)
end

function create_custom_toggle(args)
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

  local check = Sprite(
    0,
    0,
    0.5 * args.scale,
    0.5 * args.scale,
    G.ASSET_ATLAS["icons"],
    { x = 1, y = 0 }
  )
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
          {
            n = G.UIT.T,
            config = {
              text = v,
              scale = 0.25,
              colour = args.info_colour or G.C.UI.TEXT_LIGHT,
            },
          },
        },
      })
    end
    info = { n = G.UIT.R, config = { align = "cm", minh = 0.05 }, nodes = info }
  end

  local t = {
    n = args.col and G.UIT.C or G.UIT.R,
    config = {
      align = "cm",
      padding = 0.1,
      r = 0.1,
      colour = G.C.CLEAR,
      focus_args = { funnel_from = true },
    },
    nodes = {
      args.label and {
        n = G.UIT.C,
        config = { align = "cr", minw = args.w },
        nodes = {
          {
            n = G.UIT.T,
            config = {
              text = args.label,
              scale = args.label_scale,
              colour = G.C.UI.TEXT_LIGHT,
            },
          },
          { n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
        },
      },
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
  if args.info then
    t = {
      n = args.col and G.UIT.C or G.UIT.R,
      config = { align = "cm" },
      nodes = {
        t,
        info,
      },
    }
  end
  return t
end
