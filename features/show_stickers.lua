local lovely = require("lovely")
local nativefs = require("nativefs")

local card_draw_ref = Card.draw
function Card:draw(layer)
  if self.ability and self.ability.set == "Joker" and self.area and self.area.type ~= "title" then
    if S.SETTINGS.modules.preferences.show_stickers.enabled then
      self.sticker = get_joker_win_sticker(self.config.center)
    else
      self.sticker = nil
    end
  end
  card_draw_ref(self, layer)
end
