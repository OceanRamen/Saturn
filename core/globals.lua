local lovely = require("lovely")

VERSION = "1.0.0b"
VERSION = VERSION .. "-DEVELOPMENT"

function Saturn:set_globals()
  self.VERSION = VERSION
  self.MOD_PATH = lovely.mod_dir .. "/Saturn/"
  
  self.calculating_joker = false
  self.calculating_score = false
  self.calculating_card = false
  
  self.add_dollar_amt = 0
  self.dollar_update = false
  self.SETTINGS = {
    modules = {
      stattrack = {
        enabled = true,
        features = {
          joker_tracking = {
            enabled = true, 
            groups = {
              money_generators = true, 
              card_generators = true, 
              miscellaneous = true,
              chips_plus = false, 
              mult_plus = false, 
              mult_mult = false,
              compact_view = false,
            },
          },
        },
      },
      deckviewer_plus = {
        enabled = true,
        features = {
          hide_played_cards = true,
        },
      },
      challenger_plus = {
        enabled = true,
        features = {
          retry_button = true,
          mass_use_button = true,
        }
      },
      remove_animations = {
        enabled = true,
      }
    }
  }

  self.UI = {
    colour_scheme = {},
  }
end

S = Saturn()
