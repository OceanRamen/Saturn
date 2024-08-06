local lovely = require("lovely")
local nativefs = require("nativefs")

consp = {}

function Card:to_string()
  return string.format(
    "%s%s%s",
    self.label and self.label or "",
    self.edition and self.edition or "",
    self.sell_cost and self.sell_cost or ""
  )
end

G.FUNCS.disable_stacked_cons = function(e)
  local preview_card = e.config.ref_table
  e.states.visible = preview_card.stacked_quantity > 1
end

function Card:create_stacked_display()
  if
    not S.SETTINGS.modules.consumeable_plus.enabled
    and not S.SETTINGS.modules.consumeable_plus.features.stacked_consumeables
  then
    return
  end
  if not self.children.stack_display and self.qty > 1 then
    self.children.stack_display = UIBox({
      definition = {
        n = G.UIT.ROOT,
        config = {
          minh = 0.5,
          maxh = 1.2,
          minw = 0.43,
          maxw = 2,
          r = 0,
          padding = 0.1,
          align = "cm",
          colour = adjust_alpha(darken(G.C.BLACK, 0.2), 0.5),
          shadow = false,
          func = "disable_quantity_display",
          ref_table = self,
        },
        nodes = {
          {
            n = G.UIT.T,
            config = { text = "x", scale = 0.35, colour = G.C.WHITE },
            padding = -1,
          },
          {
            n = G.UIT.T,
            config = {
              ref_table = self,
              ref_value = "qty",
              scale = 0.35,
              colour = G.C.WHITE,
            },
          },
        },
      },
      config = {
        align = "br",
        bond = "Strong",
        parent = self,
      },
      states = {
        collide = {
          can = false,
        },
        drag = {
          can = true,
        },
      },
    })
  end
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
  card_load_ref(self, cardTable, other_card)
  if self.qty then
    self:create_stacked_display()
  end
end

local card_init_ref = Card.init
function Card:init(X, Y, W, H, config)
  card_init_ref(self, X, Y, W, H, config)
  self.qty = 0
end

local deckadd = Card.add_to_deck
function Card:add_to_deck(from_debuff)
  deckadd(self, from_debuff)
  if G.consumeables then
    if self:canStack() then
      --- increment qty on original Card
    end
  end
end

--- when drawing cards: 
--- if "stack_consumeables" is true, only draw non-duplicates.
--- else, run normally. 


function Card:canStack() end
function Card:useFromStack(num) end
function Card:sellFromStack(num) end
function Card:getQty() end