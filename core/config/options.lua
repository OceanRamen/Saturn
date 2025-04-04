return {
  stat_track = {
    title = "Stats Tracking",
    desc = "Track various statistics in game.",
    opts = {
      { id = "track_stats", default = false, master = true },
      { id = "track_money_gen", default = false },
      { id = "track_value_gen", default = false },
      { id = "track_card_gen", default = false },
      { id = "track_cards_add", default = false },
      { id = "track_cards_rem", default = false },
      { id = "track_jokers_gen", default = false },
      { id = "track_jokers_rem", default = false },
      { id = "track_retriggers", default = false },
      { id = "track_hands_upgraded", default = false },
      { id = "track_turned_gold", default = false },
      { id = "track_plus_hands", default = false },
    },
  },
  rem_anim = {
    title = "Remove Animations",
    desc = "Remove game animations to speed-up gameplay drastically.",
    opts = {
      { id = "remove_animations", default = false, master = true },
      { id = "enable_dramatic_final_hand", default = false },
    },
  },
  stacking = {
    title = "Consumeable Stacking",
    desc = "Stack duplicate consumeables to reduce lag and clutter.",
    opts = {
      { id = "enable_stacking", default = false, master = true },
    },
  },
}
