local lovely = require("lovely")
local nativefs = require("nativefs")

local card_draw_ref = Card.draw
function Card:draw(layer)
    if self.ability and self.ability.set == 'Joker' and S.SETTINGS.modules.preferences.show_stickers.enabled then
        self.sticker = get_joker_win_sticker(self.config.center)
    else
        self.sticker = nil
  end
  card_draw_ref(self, layer)
end