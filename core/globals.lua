local lovely = require("lovely")

VERSION = "1.0.0b"
VERSION = VERSION .. "-DEVELOPMENT"

function Saturn:set_globals()
  self.VERSION = VERSION
  self.MOD_PATH = lovely.mod_dir .. "/Saturn/"

  self.add_dollar_amt = 0
  self.dollar_update = false
  self.SETTINGS = {
    modules = {
      stattrack = {
        features = {
          joker_tracking = { 
            groups = {
              money_generators = true, 
              card_generators = true, 
              miscellaneous = true,
              chips_plus = false, 
              mult_plus = false, 
              mult_mult = false,
            },
          },
        },
        enabled = true,
      },
      preferences = {
        remove_animations = {
          enabled = false,
        },
        compact_view = {
          enabled = false,
        },
        show_stickers = {
          enabled = false,
        },
      },
      deckviewer_plus = {
        enabled = true,
        features = {
          hide_played_cards = true,
        },
      },
      run_timer = {
        enabled = true,
        config = {},
      },
      challenger_plus = {
        enabled = true,
        features = {
          retry_button = true,
          mass_use_button = true,
        }
      },
    }
  }

  self.UI = {
    colour_scheme = {},
  }
end

S = Saturn()
