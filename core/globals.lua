local lovely = require("lovely")

VERSION = "1.0.0b"
VERSION = VERSION .. "-DEVELOPMENT"

function Saturn:set_globals()
  self.VERSION = VERSION
  self.MOD_PATH = lovely.mod_dir .. "/Saturn/"
  
  self.SETTINGS = {
    modules = {
      stattrack = {
        enabled = false,
        features = {
          joker_tracking = {
            enabled = false, 
            groups = {
              money_generators = false, 
              card_generators = false, 
              miscellaneous = false,
              chips_plus = false, 
              mult_plus = false, 
              mult_mult = false,
              compact_view = false,
            },
          },
        },
      },
      deckviewer_plus = {
        enabled = false,
        features = {
          hide_played_cards = false,
        },
      },
      challenger_plus = {
        enabled = false,
        features = {
          retry_button = false,
        }
      }
    }
  }

  self.UI = {
    colour_scheme = {},
  }
end

S = Saturn()
