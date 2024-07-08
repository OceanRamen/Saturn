function create_UIBox_game_over()
  local show_lose_cta = false


  local eased_red = copy_table(G.GAME.round_resets.ante <= G.GAME.win_ante and G.C.RED or G.C.BLUE)
  eased_red[4] = 0
  ease_value(eased_red, 4, 0.8, nil, nil, true)
  local t = create_UIBox_generic_options({ bg_colour = eased_red ,no_back = true, padding = 0, contents = {
    {n=G.UIT.R, config={align = "cm"}, nodes={
      {n=G.UIT.O, config={object = DynaText({string = {localize('ph_game_over')}, colours = {G.C.RED},shadow = true, float = true, scale = 1.5, pop_in = 0.4, maxw = 6.5})}},
    }},
    {n=G.UIT.R, config={align = "cm", padding = 0.15}, nodes={
      {n=G.UIT.C, config={align = "cm"}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.05, colour = G.C.BLACK, emboss = 0.05, r = 0.1}, nodes={
          {n=G.UIT.R, config={align = "cm", padding = 0.08}, nodes={
            create_UIBox_round_scores_row('hand'),
            create_UIBox_round_scores_row('poker_hand'),
          }},
          {n=G.UIT.R, config={align = "cm"}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.08}, nodes={
              create_UIBox_round_scores_row('cards_played', G.C.BLUE),
              create_UIBox_round_scores_row('cards_discarded', G.C.RED),
              create_UIBox_round_scores_row('cards_purchased', G.C.MONEY),
              create_UIBox_round_scores_row('times_rerolled', G.C.GREEN),
              create_UIBox_round_scores_row('new_collection', G.C.WHITE),
              create_UIBox_round_scores_row('seed', G.C.WHITE),
              UIBox_button({button = 'copy_seed', label = {localize('b_copy')}, colour = G.C.BLUE, scale = 0.3, minw = 2.3, minh = 0.4, focus_args = {nav = 'wide'}}),
            }},
            {n=G.UIT.C, config={align = "tr", padding = 0.08}, nodes={
              create_UIBox_round_scores_row('furthest_ante', G.C.FILTER),
              create_UIBox_round_scores_row('furthest_round', G.C.FILTER),
              create_UIBox_round_scores_row('defeated_by'),
            }}
          }}
        }},
        show_lose_cta and 
         {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
          {n=G.UIT.C, config={id = 'lose_cta', align = "cm", minw = 5, padding = 0.1, r = 0.1, hover = true, colour = G.C.GREEN, button = "show_main_cta", shadow = true}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
              {n=G.UIT.T, config={text = localize('b_next'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT, focus_args = {nav = 'wide', snap_to = true}}}
            }}
          }}
        }} or -- isChallenge and
        {n=G.UIT.R, config={align = "cm"}, nodes = {
          {n=G.UIT.C, config={align = "cl", padding = 0.1}, nodes={
            {n=G.UIT.R, config={id = 'from_game_over', align = "cm", minw = 5, padding = 0.1, r = 0.1, hover = true, colour = G.C.RED, button = "notify_then_setup_run", shadow = true, focus_args = {nav = 'wide', snap_to = true}}, nodes={
              {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true, maxw = 4.8}, nodes={
                {n=G.UIT.T, config={text = localize('b_start_new_run'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
              }}
            }},
            {n=G.UIT.R, config={align = "cm", minw = 5, padding = 0.1, r = 0.1, hover = true, colour = G.C.RED, button = "go_to_menu", shadow = true, focus_args = {nav = 'wide'}}, nodes={
              {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true, maxw = 4.8}, nodes={
                {n=G.UIT.T, config={text = localize('b_main_menu'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
              }}
            }}
          }},
          {n=G.UIT.C, config={align = "cl", padding = 0.1}, nodes={
            {n=G.UIT.R, config={id = 'retry_challenge_button', align = "cm", minh=1.35, minw = 1.35, padding = 0.1, r = 0.1, hover = true, colour = G.C.SECONDARY_SET.Planet, button = "retry_challenge", shadow = true, focus_args = {nav = 'wide', snap_to = true}}, nodes={
              {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true, maxw = 4.8}, nodes={
                {n=G.UIT.T, config={text = "Retry", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
              }}
            }},
          }},
        }}
        or 
        {
          -- Default without retry
        }
      }},
    }}
}})
  t.nodes[1] = {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
    {n=G.UIT.C, config={align = "cm", padding = 2}, nodes={
      {n=G.UIT.R, config={align = "cm"}, nodes={
        {n=G.UIT.O, config={padding = 0, id = 'jimbo_spot', object = Moveable(0,0,G.CARD_W*1.1, G.CARD_H*1.1)}},
      }},
    }},
    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={t.nodes[1]}}}
}
  --t.nodes[1].config.mid = true
  
  
  return t
end

G.FUNCS.retry_challenge = function(e)
  --- Retry challenge button
end