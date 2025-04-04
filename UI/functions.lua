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
        config = { align = "cm", minh = 0.0 },
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
    info = {
      n = G.UIT.R,
      config = {
        align = "cm",
        minh = 0.05,
      },
      nodes = info,
    }
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

function UIBox_button_custom(args)
  args = args or {}
  args.button = args.button or "exit_overlay_menu"
  args.func = args.func or nil
  args.colour = args.colour or G.C.RED
  args.choice = args.choice or nil
  args.chosen = args.chosen or nil
  args.label = args.label or { "LABEL" }
  args.minw = args.minw or 2.7
  args.maxw = args.maxw or (args.minw - 0.2)
  if args.minw < args.maxw then
    args.maxw = args.minw - 0.2
  end
  args.minh = args.minh or 0.9
  args.scale = args.scale or 0.5
  args.focus_args = args.focus_args or nil
  args.text_colour = args.text_colour or G.C.UI.TEXT_LIGHT
  local but_UIT = args.col == true and G.UIT.C or G.UIT.R

  local but_UI_label = {}

  local button_pip = nil
  for k, v in ipairs(args.label) do
    if
      k == #args.label
      and args.focus_args
      and args.focus_args.set_button_pip
    then
      button_pip = "set_button_pip"
    end
    table.insert(but_UI_label, {
      n = G.UIT.R,
      config = {
        align = "cm",
        padding = 0,
        minw = args.minw,
        maxw = args.maxw,
      },
      nodes = {
        -- {
        --   n = G.UIT.T,
        --   config = {
        --     text = v,
        --     scale = args.scale,
        --     colour = args.text_colour,
        --     shadow = args.shadow,
        --     focus_args = button_pip and args.focus_args or nil,
        --     func = button_pip,
        --     ref_table = args.ref_table,
        --   },
        -- },
        {
          n = G.UIT.O,
          config = {
            ref_table = args.ref_table,
            func = button_pip,
            focus_args = button_pip and args.focus_args or nil,
            object = DynaText({
              string = {
                v,
              },
              colours = { args.text_colour },
              shadow = args.shadow,
              float = true,
              bump = true,
              rotate = true,
              pop_in = 0.1,
              scale = args.scale * 1.25,
              silent = true,
            }),
          },
        },
      },
    })
  end

  if args.count then
    table.insert(but_UI_label, {
      n = G.UIT.R,
      config = { align = "cm", minh = 0.4 },
      nodes = {
        {
          n = G.UIT.T,
          config = {
            scale = 0.35,
            text = args.count.tally .. " / " .. args.count.of,
            colour = { 1, 1, 1, 0.9 },
          },
        },
      },
    })
  end

  return {
    n = but_UIT,
    config = { align = "cm" },
    nodes = {
      {
        n = G.UIT.C,
        config = {
          align = "cm",
          padding = args.padding or 0,
          r = 0.1,
          hover = true,
          colour = args.colour,
          one_press = args.one_press,
          button = (args.button ~= "nil") and args.button or nil,
          choice = args.choice,
          chosen = args.chosen,
          focus_args = args.focus_args,
          minh = args.minh - 0.3 * (args.count and 1 or 0),
          shadow = true,
          func = args.func,
          id = args.id,
          back_func = args.back_func,
          ref_table = args.ref_table,
          mid = args.mid,
        },
        nodes = but_UI_label,
      },
    },
  }
end
