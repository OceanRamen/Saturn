local lovely = require("lovely")
local nativefs = require("nativefs")

-- putting the saturn button on the main menu
local create_UIBox_main_menu_buttons_ref = create_UIBox_main_menu_buttons
function create_UIBox_main_menu_buttons()
  local text_scale = 0.45
  local saturn_features_button = UIBox_button({
    id = "saturn_features_button",
    minh = 1.35,
    minw = 1.85,
    col = true,
    button = "saturn_features_button",
    colour = G.C.SECONDARY_SET.Planet,
    label = { "Saturn" },
    scale = text_scale * 1.2,
  })
  local menu = create_UIBox_main_menu_buttons_ref()
  local spacer = G.F_QUIT_BUTTON and { n = G.UIT.C, config = { align = "cm", minw = 0.2 }, nodes = {} } or nil
  table.insert(menu.nodes[1].nodes[1].nodes[2].nodes, 2, spacer)
  table.insert(menu.nodes[1].nodes[1].nodes[2].nodes, 3, saturn_features_button)
  menu.nodes[1].nodes[1].config =
    { align = "cm", padding = 0.15, r = 0.1, emboss = 0.1, colour = G.C.L_BLACK, mid = true }
  return menu
end

-- main tabs

G.FUNCS.s_change_tab = function(e)
  local tab_config = S.TAB_FUNCS[e.config.tab_func]()
  G.OVERLAY_MENU:remove()
  G.OVERLAY_MENU = UIBox({
    	definition = s_create_options({
      		apply_func = 'apply_settings',
      		back_func = 'options',
      		tabs = s_create_tabs(tab_config._tabs),
      		nodes = s_create_buttons(tab_config._buttons),
    	}),
      config = {
        align = "cm",
        offset = {x=0,y=0},
        major = G.ROOM_ATTACH,
        bond = 'Weak',
      },
  	})
  G.OVERLAY_MENU:recalculate()
end

-- tab functions
-- modules tab
G.FUNCS.saturn_features = function(e)
  	G.SETTINGS.paused = true
    
  	local ref_table = S.TEMP_SETTINGS.modules
  	local _buttons = {
    	{label = 'StatTracker', toggle_ref = ref_table.stattrack, ref_value = 'enabled', button_ref = 'config_stattracker',},
    	{label = 'DeckViewer+', toggle_ref = ref_table.deckviewer_plus, ref_value = 'enabled', button_ref = 'config_deckviewer',},
    	{label = 'Challenger+', toggle_ref = ref_table.challenger_plus, ref_value = 'enabled', button_ref = 'config_challenger',},
      {label = 'Run Timer', toggle_ref = ref_table.run_timer, ref_value = 'enabled', button_ref = 'config_run_timer',},
  	}
  	local _tabs = {
    	{label = 'Modules'},
    	{label = 'Options', button_ref = 's_change_tab', tab_func = 'saturn_options'},
    	{label = 'Stats', button_ref = 's_change_tab', tab_func = 'saturn_stats'},
  	}

  	G.FUNCS.overlay_menu({
    	definition = s_create_options({
      		apply_func = 'apply_settings',
      		back_func = 'options',
      		tabs = s_create_tabs(_tabs),
      		nodes = s_create_buttons(_buttons),
    	})
  	})
end

-- tab functions

S.TAB_FUNCS = {}

-- modules tab
S.TAB_FUNCS.saturn_features = function(e)

  	local ref_table = S.TEMP_SETTINGS.modules
  	local _buttons = {
    	{label = 'StatTracker', toggle_ref = ref_table.stattrack, ref_value = 'enabled', button_ref = 'config_stattracker',},
    	{label = 'DeckViewer+', toggle_ref = ref_table.deckviewer_plus, ref_value = 'enabled', button_ref = 'config_deckviewer',},
    	{label = 'Challenger+', toggle_ref = ref_table.challenger_plus, ref_value = 'enabled', button_ref = 'config_challenger',},
      {label = 'Run Timer', toggle_ref = ref_table.run_timer, ref_value = 'enabled', button_ref = 'config_run_timer',},
  	}
  	local _tabs = {
    	{label = 'Modules'},
    	{label = 'Options', button_ref = 's_change_tab', tab_func = 'saturn_options'},
    	{label = 'Stats', button_ref = 's_change_tab', tab_func = 'saturn_stats'},
  	}
    local t = {
      ref_table = ref_table,
      _buttons = _buttons,
      _tabs = _tabs,
    }
  	return t
end

-- options tab
S.TAB_FUNCS.saturn_options = function(e)
  	local ref_table = S.TEMP_SETTINGS.modules.preferences
  	local _buttons = {
    	{label = 'Animation Skip', toggle_ref = ref_table.remove_animations, ref_value = 'enabled',},
    	{label = 'Compact View', toggle_ref = ref_table.compact_view, ref_value = 'enabled'},
    	{label = 'Show Stickers', toggle_ref = ref_table.show_stickers, ref_value = 'enabled',},
  	}
  	local _tabs = {
		{label = "Modules", button_ref = 's_change_tab', tab_func = 'saturn_features'},
		{label = 'Options',},
		{label = 'Stats', button_ref = 's_change_tab', tab_func = 'saturn_stats',},
	}

	local t = {
      ref_table = ref_table,
      _buttons = _buttons,
      _tabs = _tabs,
    }
  return t
end

-- stats tab
S.TAB_FUNCS.saturn_stats = function(e)
	S.current_page = 0
	
	local _buttons = {
		{label = 'General Stats', button_ref = 'view_general', button_label = 'View', remove_enable = true,},
		{label = localize('b_jokers'), button_ref = 'view_jokers', button_label = 'View', remove_enable = true,},
		{label = 'Tarot Cards', button_ref = 'view_tarots', button_label = 'View', remove_enable = true,},
		{label = 'Planet Cards', button_ref = 'view_planets', button_label = 'View', remove_enable = true,},
		{label = 'Spectral Cards', button_ref = 'view_spectrals', button_label = 'View', remove_enable = true,},
		{label = 'Decks', button_ref = 'view_decks', button_label = 'View', remove_enable = true,},
	}
	local _tabs = {
		{label = "Modules", button_ref = 's_change_tab', tab_func = 'saturn_features'},
		{label = 'Options', button_ref = 's_change_tab', tab_func = 'saturn_options'},
		{label = 'Stats',},
	}

	local t = {
      ref_table = ref_table,
      _buttons = _buttons,
      _tabs = _tabs,
    }
  return t
end

-- config buttons

-- stat tracker config
G.FUNCS.config_stattracker = function(e)
	G.SETTINGS.paused = true

	local ref_table = S.TEMP_SETTINGS.modules.stattrack.features.joker_tracking.groups
	local _buttons = {
		{label = 'Money Generators', toggle_ref = ref_table, ref_value = 'money_generators', remove_enable = true,},
		{label = 'Card Generators', toggle_ref = ref_table, ref_value = 'card_generators', remove_enable = true,},
		{label = '+ Chip Jokers', toggle_ref = ref_table, ref_value = 'chips_plus', remove_enable = true,},
		{label = '+ Mult Jokers', toggle_ref = ref_table, ref_value = 'mult_plus', remove_enable = true,},
		{label = 'x Mult Jokers', toggle_ref = ref_table, ref_value = 'mult_mult', remove_enable = true,},
		{label = 'Miscellaneous', toggle_ref = ref_table, ref_value = 'miscellaneous', remove_enable = true,},
	}

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		apply_func = 'apply_settings',
		back_func = 'saturn_features',
		title = 'Joker StatTracker Options',
		nodes = s_create_buttons(_buttons),
		})
	})
end

-- run timer config
G.FUNCS.config_run_timer = function(e)
	G.SETTINGS.paused = true

	local _buttons = {
		{label = 'nothing to config yet', remove_enable = true,},
	}

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		apply_func = 'apply_settings',
		back_func = 'saturn_features',
		title = 'Run Timer Options',
		nodes = s_create_buttons(_buttons),
		})
	})
end

-- deckviewer config
G.FUNCS.config_deckviewer = function(e)
  G.SETTINGS.paused = true

  local ref_table = S.TEMP_SETTINGS.modules.deckviewer_plus.features
  local _buttons = {
    {label = 'Hide Played Cards', toggle_ref = ref_table, ref_value = 'hide_played_cards', remove_enable = true,},
  }

  G.FUNCS.overlay_menu({
    definition = s_create_options({
      apply_func = "apply_settings",
      back_func = "saturn_features",
      title = 'Deckviewer+ Options',
      nodes = s_create_buttons(_buttons),
    })
  })
end

-- challenger config
G.FUNCS.config_challenger = function(e)
  G.SETTINGS.paused = true

  local ref_table = S.TEMP_SETTINGS.modules.challenger_plus.features
  local _buttons = {
    {label = 'Retry Button', toggle_ref = ref_table, ref_value = 'retry_button', remove_enable = true,},
    {label = 'Mass Use', toggle_ref = ref_table, ref_value = 'mass_use_button', remove_enable = true,},
  }

  G.FUNCS.overlay_menu({
    definition = s_create_options({
      apply_func = "apply_settings",
      back_func = "saturn_features",
      title = 'Challenger+ Options',
      nodes = s_create_buttons(_buttons),
    })
  })
end

-- stat view buttons

-- general stats
G.FUNCS.view_general = function(e) end

-- joker stats
G.FUNCS.view_jokers = function(e)
	G.SETTINGS.paused = true

	local card_display = {_type = 'Joker', col = 5, row = 2,}

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		back_func = "saturn_stats",
		title = 'Click on a Card to view Stats',
		nodes = s_create_card_display(card_display),
		})
	})
end

-- tarot stats
G.FUNCS.view_tarots = function(e)
	G.SETTINGS.paused = true

	local card_display = {_type = 'Tarot', col = 5, row = 2,}

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		back_func = "saturn_stats",
		title = 'Click on a Card to view Stats',
		nodes = s_create_card_display(card_display),
		})
	})
end

-- planet stats
G.FUNCS.view_planets = function(e)
	G.SETTINGS.paused = true

	local card_display = {_type = 'Planet', col = 5, row = 2,}

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		back_func = "saturn_stats",
		title = 'Click on a Card to view Stats',
		nodes = s_create_card_display(card_display),
		})
	})
end

-- spectral stats
G.FUNCS.view_spectrals = function(e)
	G.SETTINGS.paused = true

	local card_display = {_type = 'Spectral', col = 5, row = 2,}

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		back_func = 'saturn_stats',
		title = 'Click on a Card to view Stats',
		nodes = s_create_card_display(card_display),
		})
	})
end

-- deck stats
G.FUNCS.view_decks = function(e)
	G.SETTINGS.paused = true

	local deck_display = {_type = 'Back', col = 5, row = 3,}

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		back_func = 'saturn_stats',
		title = 'Click on a Deck to view Stats',
		nodes = s_create_deck_display(deck_display),
		})
	})
end

-- individual card stats view buttons

-- specific card stats
G.FUNCS.card_stats = function(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		back_func = 'view_'..e.ability.set:lower()..'s',
		title = localize({type = 'name_text', set = e.ability.set, key = e.config.center.key}),
		nodes = s_create_stats_page(e)
		})
	})
end

-- specific deck stats
G.FUNCS.deck_stats = function(e)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = s_create_options({
		back_func = 'view_decks',
		title = localize({type = 'name_text', set = e.ability.set, key = e.config.center.key}),
		nodes = s_create_stats_page(e)
		})
	})
end

-- -- other button callbacks

-- page cycling for the stat card areas
G.FUNCS.statview_page_cycle = function(e)
	args = e.config.ref_table or {}
	args._type = args._type or 'Joker'
	args.col = args.col or 5
	args.row = args.row or 2
	args.dir = args.dir or 1
	local cards_per_page = args.col*args.row
	local current_center = 0

	for j = 1, args.row do
		for i = args.col, 1, -1 do
		local c = S.card_display[j]:remove_card(S.card_display[j].cards[i])
		if c then
			c:remove()
			c = nil
		end
		end
	end

	S.current_page = S.current_page + args.dir

	if S.current_page >= math.ceil(#G.P_CENTER_POOLS[args._type]/cards_per_page) then
		S.current_page = 0
	elseif S.current_page < 0 then
		S.current_page = math.ceil(#G.P_CENTER_POOLS[args._type]/cards_per_page)-1
	end

	S.current_page_text = (S.current_page+1)
	G.OVERLAY_MENU:get_UIE_by_ID('current_page_num'):update_text()

	for i = 1, args.row do
		for j = 1, args.col do
		current_center = current_center + 1
		local center = G.P_CENTER_POOLS[args._type][current_center + (S.current_page*(cards_per_page))]
		if not center then break end
		local card = Card(S.card_display[i].T.x + S.card_display[i].T.w/args.row, S.card_display[i].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
		card.s_stats = true
		if args._type == 'Joker' then
			card.sticker = get_joker_win_sticker(center)
		end
		S.card_display[i]:emplace(card)
		end
	end
end

G.FUNCS.use_consumeables = function(e)
	G.FUNCS:exit_overlay_menu()
	if G.consumeables and G.consumeables.cards then
		consume_cards(G.consumeables.cards)
	end
end

-- page cycling for the decks
G.FUNCS.deckview_page_cycle = function(e)
	args = e.config.ref_table or {}
	args._type = args._type or 'Back'
	args.col = args.col or 5
	args.row = args.row or 3
	args.dir = args.dir or 1
	local cards_per_page = args.col*args.row
	local current_center = 0

	for i = #S.card_display, 1, -1 do
		local c = S.card_display[i]:remove_card(S.card_display[i].cards[1])
		if c then
		c:remove()
		c = nil
		end
	end

	S.current_page = S.current_page + args.dir

	if S.current_page >= math.ceil(#G.P_CENTER_POOLS[args._type]/cards_per_page) then
		S.current_page = 0
	elseif S.current_page < 0 then
		S.current_page = math.ceil(#G.P_CENTER_POOLS[args._type]/cards_per_page)-1
	end

	S.current_page_text = (S.current_page+1)
	G.OVERLAY_MENU:get_UIE_by_ID('current_page_num'):update_text()

	for i = 1, #S.card_display do
		current_center = current_center + 1
		local center = G.P_CENTER_POOLS[args._type][current_center + (S.current_page*(args.row*args.col))]
		if not center then break end
		local card = Card(S.card_display[i].T.x + S.card_display[i].T.w/args.row, S.card_display[i].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
		card.s_stats = true
		card.s_deck = true
		S.card_display[i]:emplace(card)
	end
end